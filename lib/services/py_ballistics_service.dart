import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/calculation.dart';
import '../models/gun_model.dart';
import '../models/cartridge_model.dart';
import '../models/scope_model.dart';

class PyTrajectoryPoint {
  final double distance;
  final double dropVertical; // meters
  final double driftHorizontal; // meters
  final double time; // seconds
  final double velocity; // m/s

  PyTrajectoryPoint({
    required this.distance,
    required this.dropVertical,
    required this.driftHorizontal,
    required this.time,
    required this.velocity,
  });

  factory PyTrajectoryPoint.fromJson(Map<String, dynamic> json) {
    return PyTrajectoryPoint(
      distance: (json['distance'] as num).toDouble(),
      dropVertical: (json['drop'] as num).toDouble(),
      driftHorizontal: (json['drift'] as num).toDouble(),
      time: (json['time'] as num).toDouble(),
      velocity: (json['velocity'] as num).toDouble(),
    );
  }
}

class PyBallisticsService {
  /// Calculates the trajectory using py-ballisticcalc Python script.
  /// Throws an exception if it fails or if not running on a supported platform.
  static Future<List<PyTrajectoryPoint>> calculateTrajectory({
    required Calculation calculation,
    required Gun gun,
    required Cartridge cartridge,
    required Scope scope,
    required double maxDistance,
    required double step,
  }) async {
    // Check if we are on a desktop platform where Python could be installed
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      throw Exception('py-ballisticcalc comparison is only supported on Desktop platforms.');
    }

    // Build the configuration JSON expected by the python script
    final configMap = {
      "gun": gun.toMap(),
      "cartridge": cartridge.toJson(),
      "scope": scope.toJson(),
      "distance": calculation.distance,
      "maxDistance": maxDistance,
      "temperature": calculation.temperature,
      "pressure": calculation.pressure,
      "humidity": calculation.humidity,
      "altitudeM": 0.0, // Assuming 0 as we use pressure directly
      "latitude": calculation.latitude,
      "azimuthAngle": calculation.windDirection, // Assuming same for now
      "elevationAngle": calculation.angle,
      "windSpeed": calculation.windSpeed,
      "windDirection": calculation.windDirection,
    };

    // Save to a temporary file
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, 'py_ballistics_config_${DateTime.now().millisecondsSinceEpoch}.json'));
    await tempFile.writeAsString(jsonEncode(configMap));

    try {
      // Find the python script. 
      // This assumes the app is being run from the project root.
      final currentDir = Directory.current.path;
      final scriptPath = p.join(currentDir, 'tools', 'ballistics_harness', 'calculate_trajectory.py');
      
      if (!await File(scriptPath).exists()) {
        throw Exception('Python script not found at: $scriptPath\nPlease run the app from the project root directory.');
      }

      final result = await Process.run('python', [
        scriptPath,
        '--config',
        tempFile.path,
        '--step',
        step.toString(),
      ]);

      if (result.exitCode != 0) {
        print('Python script error: ${result.stderr}');
        throw Exception('Failed to run python script: ${result.stderr}\nMake sure python is installed and py-ballisticcalc is installed.');
      }

      final outputMap = jsonDecode(result.stdout) as Map<String, dynamic>;
      if (outputMap['error'] != null) {
        throw Exception('Python script error: ${outputMap['error']}');
      }

      final trajectoryList = outputMap['trajectory'] as List<dynamic>;
      return trajectoryList.map((e) => PyTrajectoryPoint.fromJson(e as Map<String, dynamic>)).toList();
    } finally {
      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
}
