import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:musca/models/cartridge_model.dart';
import 'package:musca/models/gun_model.dart';
import 'package:musca/models/scope_model.dart';
import 'package:musca/services/ballistics_calculator.dart';

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.from(value);
  }
  if (value is Map) {
    return value.map((key, nestedValue) => MapEntry(key.toString(), nestedValue));
  }
  return <String, dynamic>{};
}

double _asDouble(dynamic value, {double fallback = 0.0}) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }
  return fallback;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
  }
  return fallback;
}

Map<String, dynamic> _mergeMaps(Map<String, dynamic> defaults, Map<String, dynamic> overrides) {
  return <String, dynamic>{...defaults, ...overrides};
}

Gun _buildGun(Map<String, dynamic> data) {
  return Gun(
    id: (data['id'] ?? 'harness-gun').toString(),
    name: (data['name'] ?? 'Harness Gun').toString(),
    twistRate: _asDouble(data['twistRate'], fallback: 12.0),
    twistDirection: _asInt(data['twistDirection'], fallback: 1),
    muzzleVelocity: _asDouble(data['muzzleVelocity'], fallback: 820.0),
    zeroRange: _asDouble(data['zeroRange'], fallback: 100.0),
  );
}

Cartridge _buildCartridge(Map<String, dynamic> data) {
  return Cartridge(
    id: (data['id'] ?? 'harness-cartridge').toString(),
    name: (data['name'] ?? 'Harness Cartridge').toString(),
    diameter: (data['diameter'] ?? '0.782').toString(),
    bulletWeight: _asDouble(data['bulletWeight'], fallback: 150.0),
    bulletLength: _asDouble(data['bulletLength'], fallback: 0.0),
    ballisticCoefficient: _asDouble(data['ballisticCoefficient'], fallback: 0.504),
    bcModelType: data['bcModelType'] == null ? null : _asInt(data['bcModelType']),
    tofA0: data['tofA0'] == null ? null : _asDouble(data['tofA0']),
    tofA1: data['tofA1'] == null ? null : _asDouble(data['tofA1']),
    tofA2: data['tofA2'] == null ? null : _asDouble(data['tofA2']),
    tofA3: data['tofA3'] == null ? null : _asDouble(data['tofA3']),
  );
}

Scope _buildScope(Map<String, dynamic> data) {
  return Scope(
    id: (data['id'] ?? 'harness-scope').toString(),
    name: (data['name'] ?? 'Harness Scope').toString(),
    sightHeight: _asDouble(data['sightHeight'], fallback: 2.17),
    units: _asInt(data['units'], fallback: 0),
  );
}

Map<String, dynamic> _ballisticsResultToMap(BallisticsResult result) {
  return <String, dynamic>{
    'driftHorizontal': result.driftHorizontal,
    'dropVertical': result.dropVertical,
    'driftMrad': result.driftMrad,
    'dropMrad': result.dropMrad,
    'driftMrad20': result.driftMrad20,
    'dropMrad20': result.dropMrad20,
    'driftMoa': result.driftMoa,
    'dropMoa': result.dropMoa,
    'driftMoa2': result.driftMoa2,
    'dropMoa2': result.dropMoa2,
    'driftMoa3': result.driftMoa3,
    'dropMoa3': result.dropMoa3,
    'driftMoa4': result.driftMoa4,
    'dropMoa4': result.dropMoa4,
    'driftMoa8': result.driftMoa8,
    'dropMoa8': result.dropMoa8,
    'driftInches': result.driftInches,
    'dropInches': result.dropInches,
    'driftCm': result.driftCm,
    'dropCm': result.dropCm,
  };
}

Future<void> main(List<String> args) async {
  String? inputPath;
  bool includeLogs = false;

  for (var index = 0; index < args.length; index++) {
    final arg = args[index];
    if (arg == '--input' && index + 1 < args.length) {
      inputPath = args[++index];
    } else if (arg == '--include-logs') {
      includeLogs = true;
    }
  }

  inputPath ??= 'tools/ballistics_harness/scenarios.example.json';

  final inputFile = File(inputPath);
  if (!await inputFile.exists()) {
    stderr.writeln('Input file not found: $inputPath');
    exitCode = 2;
    return;
  }

  final Map<String, dynamic> root = jsonDecode(await inputFile.readAsString()) as Map<String, dynamic>;
  final Map<String, dynamic> defaults = _asMap(root['defaults']);
  final List<dynamic> cases = (root['cases'] as List<dynamic>? ?? <dynamic>[]);
  final List<Map<String, dynamic>> outputCases = <Map<String, dynamic>>[];

  for (final dynamic rawCase in cases) {
    final Map<String, dynamic> caseMap = _asMap(rawCase);
    final Map<String, dynamic> merged = _mergeMaps(defaults, caseMap);
    final Map<String, dynamic> gunMap = _mergeMaps(_asMap(defaults['gun']), _asMap(caseMap['gun']));
    final Map<String, dynamic> cartridgeMap = _mergeMaps(_asMap(defaults['cartridge']), _asMap(caseMap['cartridge']));
    final Map<String, dynamic> scopeMap = _mergeMaps(_asMap(defaults['scope']), _asMap(caseMap['scope']));

    final Gun gun = _buildGun(gunMap);
    final Cartridge cartridge = _buildCartridge(cartridgeMap);
    final Scope scope = _buildScope(scopeMap);

    final double distance = _asDouble(merged['distance'], fallback: gun.zeroRange);
    final double windSpeed = _asDouble(merged['windSpeed']);
    final double windDirection = _asDouble(merged['windDirection']);
    final double temperature = _asDouble(merged['temperature'], fallback: 15.0);
    final double pressure = _asDouble(merged['pressure'], fallback: 1013.25);
    final double humidity = _asDouble(merged['humidity'], fallback: 50.0);
    final double elevationAngle = _asDouble(merged['elevationAngle']);
    final double azimuthAngle = _asDouble(merged['azimuthAngle']);
    final double slopeAngle = _asDouble(merged['slopeAngle']);
    final double latitude = _asDouble(merged['latitude']);
    final double? fixedLosSlope = merged['fixedLosSlope'] == null ? null : _asDouble(merged['fixedLosSlope']);
    final bool useFixedLos = _asBool(merged['useFixedLos']);

    final List<String> capturedLogs = <String>[];
    final BallisticsResult result = runZoned<BallisticsResult>(() {
      if (useFixedLos) {
        return BallisticsCalculator.calculateWithFixedLos(
          distance,
          windSpeed,
          windDirection,
          gun,
          cartridge,
          scope,
          temperature: temperature,
          pressure: pressure,
          humidity: humidity,
          elevationAngle: elevationAngle,
          azimuthAngle: azimuthAngle,
          slopeAngle: slopeAngle,
          latitude: latitude,
        );
      }

      return BallisticsCalculator.calculateWithProfiles(
        distance,
        windSpeed,
        windDirection,
        gun,
        cartridge,
        scope,
        temperature: temperature,
        pressure: pressure,
        humidity: humidity,
        elevationAngle: elevationAngle,
        azimuthAngle: azimuthAngle,
        slopeAngle: slopeAngle,
        latitude: latitude,
        fixedLosSlope: fixedLosSlope,
      );
    }, zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, message) {
        capturedLogs.add(message);
      },
    ));

    final Map<String, dynamic> caseOutput = <String, dynamic>{
      'id': (merged['id'] ?? caseMap['id'] ?? 'case-${outputCases.length + 1}').toString(),
      'distance': distance,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'temperature': temperature,
      'pressure': pressure,
      'humidity': humidity,
      'elevationAngle': elevationAngle,
      'azimuthAngle': azimuthAngle,
      'slopeAngle': slopeAngle,
      'latitude': latitude,
      'useFixedLos': useFixedLos,
      'result': _ballisticsResultToMap(result),
    };

    if (includeLogs && capturedLogs.isNotEmpty) {
      caseOutput['debugLogs'] = capturedLogs;
    }

    outputCases.add(caseOutput);
  }

  stdout.writeln(jsonEncode(<String, dynamic>{
    'source': inputPath,
    'cases': outputCases,
  }));
}