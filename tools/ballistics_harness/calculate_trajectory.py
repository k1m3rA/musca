from __future__ import annotations

import argparse
import json
import sys
from typing import Any

try:
    from py_ballisticcalc import Ammo, Angular, Atmo, Calculator, Distance, DragModel, Shot, TableG1, TableG7, Unit, Velocity, Weapon, Wind
except ImportError as exc:
    print(json.dumps({"error": "py-ballisticcalc is not installed"}))
    sys.exit(1)


def _as_float(value: Any, fallback: float = 0.0) -> float:
    if isinstance(value, (int, float)):
        return float(value)
    if isinstance(value, str):
        try:
            return float(value)
        except ValueError:
            return fallback
    return fallback


def _as_map(value: Any) -> dict[str, Any]:
    return dict(value) if isinstance(value, dict) else {}


def _convert_pressure_to_hpa(pressure: float) -> float:
    if pressure >= 80000.0:
        return pressure / 100.0
    return pressure


def _bullet_diameter_inches(diameter_text: str) -> float:
    return _as_float(diameter_text, fallback=0.0) * 0.3937007874


def _app_twist_to_inches(twist_rate: float, cartridge_diameter_text: str) -> float:
    return twist_rate * _bullet_diameter_inches(cartridge_diameter_text)


def _build_py_shot(case_data: dict[str, Any]) -> Shot:
    gun = _as_map(case_data.get("gun", {}))
    cartridge = _as_map(case_data.get("cartridge", {}))
    scope = _as_map(case_data.get("scope", {}))

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
    if sight_height_units == 0:
        sight_height_unit = Unit.Inch(sight_height)
    else:
        sight_height_unit = Unit.Centimeter(sight_height)

    twist_inches = _app_twist_to_inches(
        _as_float(gun.get("twistRate"), fallback=12.0),
        str(cartridge.get("diameter", "0.782")),
    )
    
    twist_direction = _as_float(gun.get("twistDirection"), fallback=1.0)
    # If left hand twist, we set it as negative twist distance
    if twist_direction < 0:
        twist_inches = -twist_inches

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
        wind_direction_from = (180.0 - _as_float(case_data.get("windDirection"), fallback=0.0)) % 360.0
        shot.winds = [Wind(Velocity.MPS(wind_speed), Angular.Degree(wind_direction_from))]

    return shot


def main() -> int:
    parser = argparse.ArgumentParser(description="Calculate trajectory using py-ballisticcalc")
    parser.add_argument("--config", required=True, help="JSON file with shot config")
    parser.add_argument("--step", type=float, default=1.0, help="Trajectory step size in meters")
    args = parser.parse_args()

    try:
        with open(args.config, "r", encoding="utf-8") as f:
            case_data = json.load(f)
    except Exception as exc:
        print(json.dumps({"error": f"Failed to load config: {exc}"}))
        return 1

    try:
        shot = _build_py_shot(case_data)
        gun = _as_map(case_data.get("gun", {}))
        zero_range = _as_float(gun.get("zeroRange"), fallback=100.0)
        
        # We need trajectory up to target distance (max distance)
        max_distance = _as_float(case_data.get("maxDistance"), fallback=1000.0)
        
        calc = Calculator()
        calc.set_weapon_zero(shot, Distance.Meter(zero_range))

        trajectory = calc.fire(
            shot,
            trajectory_range=Distance.Meter(max_distance),
            trajectory_step=Distance.Meter(args.step),
        )
        
        points = []
        for point in trajectory:
            distance_m = float(point.distance >> Distance.Meter)
            # drop and drift linear values
            drop_m = float(point.height >> Distance.Meter)
            drift_m = float(point.windage >> Distance.Meter)
            
            points.append({
                "distance": distance_m,
                "drop": drop_m,
                "drift": drift_m,
                "time": float(point.time),
                "velocity": float(point.velocity >> Velocity.MPS),
            })
            
        print(json.dumps({"success": True, "trajectory": points}))
        return 0
        
    except Exception as exc:
        print(json.dumps({"error": str(exc)}))
        return 1


if __name__ == "__main__":
    sys.exit(main())
