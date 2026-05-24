from __future__ import annotations

import argparse
import json
import subprocess
import sys
import os
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Any


try:
    from py_ballisticcalc import Ammo, Angular, Atmo, Calculator, Distance, DragModel, Shot, TableG1, TableG7, Unit, Velocity, Weapon, Wind
except ImportError as exc:  # pragma: no cover - helper for local execution
    Ammo = Angular = Atmo = Calculator = Distance = DragModel = Shot = TableG1 = TableG7 = Unit = Velocity = Weapon = Wind = None  # type: ignore[assignment]
    _IMPORT_ERROR = exc
else:
    _IMPORT_ERROR = None


@dataclass(frozen=True)
class ComparisonRow:
    name: str
    app_value: float
    py_value: float

    @property
    def delta(self) -> float:
        return self.app_value - self.py_value

    @property
    def abs_delta(self) -> float:
        return abs(self.delta)


class ComparisonSkipped(Exception):
    pass


def _as_map(value: Any) -> dict[str, Any]:
    return dict(value) if isinstance(value, dict) else {}


def _as_float(value: Any, fallback: float = 0.0) -> float:
    if isinstance(value, (int, float)):
        return float(value)
    if isinstance(value, str):
        try:
            return float(value)
        except ValueError:
            return fallback
    return fallback


def _as_bool(value: Any, fallback: bool = False) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        normalized = value.strip().lower()
        if normalized in {"true", "1", "yes", "y"}:
            return True
        if normalized in {"false", "0", "no", "n"}:
            return False
    return fallback


def _merge_case(defaults: dict[str, Any], case_data: dict[str, Any]) -> dict[str, Any]:
    merged = dict(defaults)
    merged.update(case_data)
    for key in ("gun", "cartridge", "scope"):
        merged[key] = dict(defaults.get(key, {}))
        merged[key].update(case_data.get(key, {}))
    return merged


def _convert_pressure_to_hpa(pressure: float) -> float:
    if pressure >= 80000.0:
        return pressure / 100.0
    return pressure


def _resolve_dart_executable() -> str:
    env_override = os.environ.get("DART_EXE")
    if env_override:
        return env_override

    dart_path = shutil.which("dart")
    if dart_path:
        return dart_path

    flutter_path = shutil.which("flutter")
    if flutter_path:
        flutter_dir = Path(flutter_path).resolve().parent
        candidates = [
            flutter_dir / "dart.bat",
            flutter_dir / "dart.exe",
            flutter_dir / "cache" / "dart-sdk" / "bin" / "dart.bat",
            flutter_dir / "cache" / "dart-sdk" / "bin" / "dart.exe",
        ]
        for candidate in candidates:
            if candidate.exists():
                return str(candidate)

    raise FileNotFoundError(
        "Unable to locate Dart. Set DART_EXE or add dart/flutter to PATH before running the harness."
    )


def _bullet_diameter_inches(diameter_text: str) -> float:
    return _as_float(diameter_text, fallback=0.0) * 0.3937007874


def _app_twist_to_inches(twist_rate: float, cartridge_diameter_text: str) -> float:
    # The app expresses twist as calibres per rotation, while py-ballisticcalc expects length per turn.
    return twist_rate * _bullet_diameter_inches(cartridge_diameter_text)


def _build_py_shot(case_data: dict[str, Any]) -> Shot:
    gun = _as_map(case_data["gun"])
    cartridge = _as_map(case_data["cartridge"])
    scope = _as_map(case_data["scope"])

    bc_model_type = case_data.get("bcModelType", cartridge.get("bcModelType", 0))
    drag_table = TableG7 if int(bc_model_type or 0) == 1 else TableG1
    drag_model = DragModel(
        _as_float(cartridge.get("ballisticCoefficient"), fallback=0.504),
        drag_table,
    )

    ammo = Ammo(
        dm=drag_model,
        mv=Velocity.MPS(_as_float(gun.get("muzzleVelocity"), fallback=820.0)),
    )

    sight_height = _as_float(scope.get("sightHeight"), fallback=2.17)
    sight_height_units = int(scope.get("units", 0) or 0)
    if sight_height_units == 1:
        sight_height_unit = Unit.Centimeter(sight_height)
    else:
        sight_height_unit = Unit.Inch(sight_height)

    twist_inches = _app_twist_to_inches(
        _as_float(gun.get("twistRate"), fallback=12.0),
        str(cartridge.get("diameter", "0.782")),
    )

    weapon = Weapon(
        sight_height=sight_height_unit,
        twist=Unit.Inch(twist_inches),
    )

    altitude_m = _as_float(case_data.get("altitudeM"), fallback=0.0)
    pressure_hpa = _convert_pressure_to_hpa(_as_float(case_data.get("pressure"), fallback=1013.25))
    temperature_c = _as_float(case_data.get("temperature"), fallback=15.0)
    humidity = _as_float(case_data.get("humidity"), fallback=50.0)
    latitude = _as_float(case_data.get("latitude"), fallback=0.0)
    azimuth = _as_float(case_data.get("azimuthAngle"), fallback=0.0)
    look_angle = _as_float(case_data.get("elevationAngle"), fallback=0.0)

    atmo = Atmo(
        altitude=Unit.Meter(altitude_m),
        pressure=Unit.hPa(pressure_hpa),
        temperature=Unit.Celsius(temperature_c),
        humidity=humidity,
    )

    shot = Shot(
        weapon=weapon,
        ammo=ammo,
        atmo=atmo,
        look_angle=Angular.Degree(look_angle),
        azimuth=Angular.Degree(azimuth),
        latitude=latitude,
    )

    wind_speed = _as_float(case_data.get("windSpeed"), fallback=0.0)
    if wind_speed:
        # The app uses 0° = headwind, 90° = wind from left to right.
        # py-ballisticcalc uses 0° = from behind shooter, so we rotate by 180°.
        wind_direction_from = (180.0 - _as_float(case_data.get("windDirection"), fallback=0.0)) % 360.0
        shot.winds = [Wind(Velocity.MPS(wind_speed), Angular.Degree(wind_direction_from))]

    return shot


def _extract_py_result(case_data: dict[str, Any]) -> dict[str, float]:
    shot = _build_py_shot(case_data)
    gun = _as_map(case_data["gun"])
    zero_range = _as_float(gun.get("zeroRange"), fallback=100.0)
    distance = _as_float(case_data.get("distance"), fallback=zero_range)
    trajectory_range = max(distance, zero_range) + 100.0

    calc = Calculator()
    calc.set_weapon_zero(shot, Distance.Meter(zero_range))

    trajectory = calc.fire(
        shot,
        trajectory_range=Distance.Meter(trajectory_range),
        trajectory_step=Distance.Meter(max(distance / 20.0, 1.0)),
    )
    try:
        point = trajectory.get_at("distance", Distance.Meter(distance))
    except ArithmeticError as exc:
        raise ComparisonSkipped(str(exc)) from exc

    return {
        "height_m": float(point.height >> Distance.Meter),
        "windage_m": float(point.windage >> Distance.Meter),
        "drop_angle_mil": float(point.drop_angle >> Angular.Mil),
        "windage_angle_mil": float(point.windage_angle >> Angular.Mil),
        "time_s": float(point.time),
        "velocity_mps": float(point.velocity >> Velocity.MPS),
    }


def _run_app_runner(config_path: Path, runner_path: Path) -> dict[str, Any]:
    dart_executable = _resolve_dart_executable()
    command = [
        dart_executable,
        "run",
        str(runner_path),
        "--input",
        str(config_path),
    ]
    if dart_executable.lower().endswith((".bat", ".cmd")):
        command = ["cmd", "/c", *command]
    completed = subprocess.run(command, capture_output=True, text=True, check=True)
    return json.loads(completed.stdout)


def _compare_case(case_output: dict[str, Any], case_input: dict[str, Any], tolerances: dict[str, float]) -> tuple[list[ComparisonRow], list[str]]:
    distance = _as_float(case_output.get("distance"), fallback=_as_float(case_input.get("distance"), fallback=0.0))
    app_result = _as_map(case_output.get("result"))
    py_result = _extract_py_result(case_input)

    app_linear_drop = _as_float(app_result.get("dropMrad"), fallback=0.0) * distance / 1000.0
    app_linear_drift = _as_float(app_result.get("driftMrad"), fallback=0.0) * distance / 1000.0
    app_drop_angle = _as_float(app_result.get("dropMrad"), fallback=0.0)
    app_drift_angle = _as_float(app_result.get("driftMrad"), fallback=0.0)

    # Convert py-ballisticcalc angular corrections to linear for consistent comparison
    # Using angle * distance / 1000 avoids apples-to-oranges with absolute height for inclined shots
    py_linear_drop = py_result["drop_angle_mil"] * distance / 1000.0
    py_linear_drift = py_result["windage_angle_mil"] * distance / 1000.0

    rows = [
        ComparisonRow("drop_linear_m", app_linear_drop, py_linear_drop),
        ComparisonRow("drift_linear_m", app_linear_drift, py_linear_drift),
        ComparisonRow("drop_angle_mil", app_drop_angle, py_result["drop_angle_mil"]),
        ComparisonRow("drift_angle_mil", app_drift_angle, py_result["windage_angle_mil"]),
    ]

    failures: list[str] = []
    for row in rows:
        tolerance_key = "linear_m" if "linear" in row.name else "angle_mil"
        tolerance = tolerances[tolerance_key]
        if row.abs_delta > tolerance:
            failures.append(
                f"{row.name}: app={row.app_value:.6f}, py={row.py_value:.6f}, delta={row.delta:.6f}, tol={tolerance:.6f}"
            )

    return rows, failures


def main() -> int:
    parser = argparse.ArgumentParser(description="Compare Musca ballistics results against py-ballisticcalc")
    parser.add_argument("--config", default="tools/ballistics_harness/scenarios.example.json", help="Scenario JSON file")
    parser.add_argument("--runner", default="tools/ballistics_harness/run_app_ballistics.dart", help="Dart runner to invoke")
    parser.add_argument("--linear-tolerance", type=float, default=0.05, help="Maximum allowed difference in meters")
    parser.add_argument("--angle-tolerance", type=float, default=0.05, help="Maximum allowed difference in mil")
    parser.add_argument("--fail-fast", action="store_true", help="Stop at the first failing case")
    args = parser.parse_args()

    if _IMPORT_ERROR is not None:
        print(
            "py-ballisticcalc is not installed. Run `python -m pip install -r tools/ballistics_harness/requirements.txt` first.",
            file=sys.stderr,
        )
        return 2

    config_path = Path(args.config).resolve()
    runner_path = Path(args.runner).resolve()

    if not config_path.exists():
        print(f"Scenario file not found: {config_path}", file=sys.stderr)
        return 2
    if not runner_path.exists():
        print(f"Dart runner not found: {runner_path}", file=sys.stderr)
        return 2

    scenario = json.loads(config_path.read_text(encoding="utf-8"))
    defaults = _as_map(scenario.get("defaults"))
    case_items = scenario.get("cases", [])

    app_output = _run_app_runner(config_path, runner_path)
    app_cases = app_output.get("cases", [])

    tolerances = {"linear_m": args.linear_tolerance, "angle_mil": args.angle_tolerance}
    exit_code = 0

    print("Case | Metric | App | py-ballisticcalc | Delta | Status")
    print("-----|--------|-----|------------------|-------|-------")

    for index, case_item in enumerate(case_items):
        case_input = _merge_case(defaults, _as_map(case_item))
        case_output = _as_map(app_cases[index]) if index < len(app_cases) else {}
        case_name = str(case_output.get("id") or case_input.get("id") or f"case-{index + 1}")

        try:
            rows, failures = _compare_case(case_output, case_input, tolerances)
        except ComparisonSkipped as exc:
            print(f"{case_name} | skipped | py-ballisticcalc trajectory does not reach target: {exc}")
            continue

        for row in rows:
            status = "OK"
            tolerance_key = "linear_m" if "linear" in row.name else "angle_mil"
            if row.abs_delta > tolerances[tolerance_key]:
                status = "FAIL"
                exit_code = 1
            print(
                f"{case_name} | {row.name} | {row.app_value:.6f} | {row.py_value:.6f} | {row.delta:.6f} | {status}"
            )

        if failures:
            print(f"{case_name} mismatches:", file=sys.stderr)
            for failure in failures:
                print(f"  - {failure}", file=sys.stderr)
            if args.fail_fast:
                return 1

    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())