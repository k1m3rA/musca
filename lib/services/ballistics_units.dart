/// Utility class for ballistics unit conversions and formatting
class BallisticsUnits {
  /// Conversion constants
  static const double mradToMoa = 1.0 / 0.290888;
  static const double moaToMrad = 0.290888;
  static const double metersToInches = 39.3701;
  static const double metersToCm = 100.0;
  static const double inchesToMeters = 0.0254;
  static const double cmToMeters = 0.01;
  static const double mbarToPa = 100.0;
  static const double paToMbar = 0.01;

  /// Convert angular correction from milliradians to various units
  static Map<String, double> convertAngularCorrection(double mrad) {
    final double moa = mrad * mradToMoa;
    
    return {
      'mrad': mrad,
      'mrad_20': _roundToIncrement(mrad, 0.05),
      'moa': moa,
      'moa_2': _roundToIncrement(moa, 0.5),
      'moa_3': _roundToIncrement(moa, 1.0/3.0),
      'moa_4': _roundToIncrement(moa, 0.25),
      'moa_8': _roundToIncrement(moa, 0.125),
    };
  }

  /// Convert linear distance from meters to various units
  static Map<String, double> convertLinearDistance(double meters) {
    return {
      'meters': meters,
      'inches': meters * metersToInches,
      'cm': meters * metersToCm,
    };
  }

  /// Round a value to the nearest increment
  static double _roundToIncrement(double value, double increment) {
    return (value / increment).round() * increment;
  }

  /// Format angular corrections with appropriate precision
  static String formatAngularCorrection(double value, String unit) {
    switch (unit.toLowerCase()) {
      case 'mrad':
        return '${value.toStringAsFixed(2)} MRAD';
      case 'mrad_20':
        return '${value.toStringAsFixed(2)} MRAD (1/20)';
      case 'moa':
        return '${value.toStringAsFixed(2)} MOA';
      case 'moa_2':
        return '${value.toStringAsFixed(1)} MOA (1/2)';
      case 'moa_3':
        return '${value.toStringAsFixed(3)} MOA (1/3)';
      case 'moa_4':
        return '${value.toStringAsFixed(2)} MOA (1/4)';
      case 'moa_8':
        return '${value.toStringAsFixed(3)} MOA (1/8)';
      default:
        return '${value.toStringAsFixed(2)} ${unit.toUpperCase()}';
    }
  }

  /// Format linear distance with appropriate precision
  static String formatLinearDistance(double value, String unit) {
    switch (unit.toLowerCase()) {
      case 'meters':
        return '${value.toStringAsFixed(3)} m';
      case 'inches':
        return '${value.toStringAsFixed(2)} in';
      case 'cm':
        return '${value.toStringAsFixed(1)} cm';
      default:
        return '${value.toStringAsFixed(2)} ${unit}';
    }
  }

  /// Get all available units for angular corrections
  static List<String> getAngularUnits() {
    return [
      'MRAD',
      '1/20 MRAD', 
      'MOA',
      '1/2 MOA',
      '1/3 MOA',
      '1/4 MOA',
      '1/8 MOA'
    ];
  }

  /// Get all available units for linear distance
  static List<String> getLinearUnits() {
    return ['inches', 'cm'];
  }

  /// Convert clicks to angular correction based on scope specifications
  static double clicksToAngularCorrection(int clicks, double clickValueMrad) {
    return clicks * clickValueMrad;
  }

  /// Convert angular correction to clicks based on scope specifications
  static int angularCorrectionToClicks(double mrad, double clickValueMrad) {
    return (mrad / clickValueMrad).round();
  }

  /// Get standardized unit display names
  static String getUnitDisplayName(String unit) {
    switch (unit.toLowerCase()) {
      case 'mrad':
        return 'MRAD';
      case 'mrad_20':
        return '1/20 MRAD';
      case 'moa':
        return 'MOA';
      case 'moa_2':
        return '1/2 MOA';
      case 'moa_3':
        return '1/3 MOA';
      case 'moa_4':
        return '1/4 MOA';
      case 'moa_8':
        return '1/8 MOA';
      case 'inches':
        return 'Inches';
      case 'cm':
        return 'Centimeters';
      default:
        return unit.toUpperCase();
    }
  }

  /// Calculate the precision needed for a given unit
  static int getPrecisionForUnit(String unit) {
    switch (unit.toLowerCase()) {
      case 'mrad':
      case 'mrad_20':
      case 'moa':
      case 'moa_4':
        return 2;
      case 'moa_2':
        return 1;
      case 'moa_3':
      case 'moa_8':
        return 3;
      case 'inches':
        return 2;
      case 'cm':
        return 1;
      default:
        return 2;
    }
  }

  /// Convert pressure to Pascals with intelligent unit detection
  static double convertPressureToPa(double pressure) {
    if (pressure >= 800 && pressure <= 1200) {
      // Typical atmospheric pressure range in mbar
      return pressure * mbarToPa;
    } else if (pressure >= 80000) {
      // Clearly in Pa range
      return pressure;
    } else if (pressure < 800) {
      // Low pressure, assume mbar
      return pressure * mbarToPa;
    } else {
      // Ambiguous range 1200-80000, assume Pa
      return pressure;
    }
  }

  /// Validate pressure input and return suggested unit
  static String getSuggestedPressureUnit(double pressure) {
    if (pressure >= 800 && pressure <= 1200) {
      return 'mbar';
    } else if (pressure >= 80000) {
      return 'Pa';
    } else if (pressure < 800) {
      return 'mbar (low pressure)';
    } else {
      return 'Pa (assumed)';
    }
  }

  /// Format pressure with appropriate units
  static String formatPressure(double pressure) {
    final String unit = getSuggestedPressureUnit(pressure);
    if (unit.contains('mbar')) {
      return '${pressure.toStringAsFixed(1)} mbar';
    } else {
      return '${pressure.toStringAsFixed(0)} Pa';
    }
  }
}
