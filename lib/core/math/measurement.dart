import 'dart:math' as math;
import 'fraction.dart';
import 'rounding.dart';

/// Available measurement units for physical lengths.
enum LengthUnit {
  inches('in', 'Inches', 1.0),
  feet('ft', 'Feet', 12.0),
  yards('yd', 'Yards', 36.0),
  millimeters('mm', 'Millimeters', 1.0 / 25.4),
  centimeters('cm', 'Centimeters', 10.0 / 25.4),
  meters('m', 'Meters', 1000.0 / 25.4);

  final String symbol;
  final String label;
  final double inchesMultiplier; // 1 unit = X inches

  const LengthUnit(this.symbol, this.label, this.inchesMultiplier);
}

/// Strongly typed physical Length representation with exact fractional formatting.
class Length {
  final double totalInches;

  const Length.fromInches(this.totalInches);
  factory Length.fromFeet(double feet) => Length.fromInches(feet * 12.0);
  factory Length.fromYards(double yards) => Length.fromInches(yards * 36.0);
  factory Length.fromMillimeters(double mm) => Length.fromInches(mm / 25.4);
  factory Length.fromCentimeters(double cm) => Length.fromInches((cm * 10.0) / 25.4);
  factory Length.fromMeters(double m) => Length.fromInches(m * 1000.0 / 25.4);
  factory Length.fromFeetAndInches(int feet, Fraction inches) {
    return Length.fromInches(feet * 12.0 + inches.toDouble());
  }

  static const Length zero = Length.fromInches(0);

  double toInches() => totalInches;
  double toFeet() => totalInches / 12.0;
  double toYards() => totalInches / 36.0;
  double toMillimeters() => totalInches * 25.4;
  double toCentimeters() => (totalInches * 25.4) / 10.0;
  double toMeters() => (totalInches * 25.4) / 1000.0;

  double as(LengthUnit unit) => totalInches / unit.inchesMultiplier;

  /// Returns feet and remainder inches in fraction format (e.g. `12' 7 3/8"`).
  String toFeetInchesFraction({RoundingResolution resolution = RoundingResolution.sixteenth}) {
    if (totalInches.abs() < 1e-9) return '0"';

    final isNeg = totalInches < 0;
    final absInches = totalInches.abs();
    final totalFeet = absInches ~/ 12;
    final remInchesDouble = absInches - (totalFeet * 12);

    final maxDenom = resolution == RoundingResolution.exact || resolution.denominator == 0
        ? 64
        : resolution.denominator;
    final roundedFraction = Fraction.fromDouble(remInchesDouble, maxDenominator: maxDenom);

    // If rounding pushed inches to 12", adjust feet
    var feet = totalFeet;
    var finalFrac = roundedFraction;
    if (finalFrac.toDouble() >= 12.0) {
      feet += 1;
      finalFrac = Fraction.zero;
    }

    final prefix = isNeg ? '-' : '';
    if (feet == 0) {
      return '$prefix${finalFrac.toMixedString(unitSymbol: '"')}';
    } else if (finalFrac == Fraction.zero) {
      return "$prefix$feet'";
    } else {
      return "$prefix$feet' ${finalFrac.toMixedString(unitSymbol: '"')}";
    }
  }

  /// Formats in plain inches with fraction (e.g. `98 1/2"`).
  String toInchesFraction({RoundingResolution resolution = RoundingResolution.sixteenth}) {
    final maxDenom = resolution == RoundingResolution.exact || resolution.denominator == 0
        ? 64
        : resolution.denominator;
    final frac = Fraction.fromDouble(totalInches, maxDenominator: maxDenom);
    return frac.toMixedString(unitSymbol: '"');
  }

  /// Formats in decimal with specified units (e.g. `2.45 m` or `24.00 ft`).
  String toFormatted(LengthUnit unit, {int decimals = 2}) {
    final val = as(unit);
    return '${val.toStringAsFixed(decimals)} ${unit.symbol}';
  }

  Length operator +(Length other) => Length.fromInches(totalInches + other.totalInches);
  Length operator -(Length other) => Length.fromInches(totalInches - other.totalInches);
  Length operator *(double factor) => Length.fromInches(totalInches * factor);
  Length operator /(double divisor) => Length.fromInches(totalInches / divisor);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Length && (other.totalInches - totalInches).abs() < 1e-9;

  @override
  int get hashCode => totalInches.hashCode;

  @override
  String toString() => toFeetInchesFraction();
}

/// Available measurement units for physical volume.
enum VolumeUnit {
  cubicYards('yd³', 'Cubic Yards', 1.0),
  cubicFeet('ft³', 'Cubic Feet', 1.0 / 27.0),
  cubicMeters('m³', 'Cubic Meters', 1.30795062),
  cubicInches('in³', 'Cubic Inches', 1.0 / 46656.0);

  final String symbol;
  final String label;
  final double cubicYardsMultiplier; // 1 unit = X cubic yards

  const VolumeUnit(this.symbol, this.label, this.cubicYardsMultiplier);
}

/// Strongly typed physical Volume representation.
class Volume {
  final double totalCubicYards;

  const Volume.fromCubicYards(this.totalCubicYards);
  factory Volume.fromCubicFeet(double cuFt) => Volume.fromCubicYards(cuFt / 27.0);
  factory Volume.fromCubicMeters(double cuM) => Volume.fromCubicYards(cuM * 1.30795062);
  factory Volume.fromCubicInches(double cuIn) => Volume.fromCubicYards(cuIn / 46656.0);

  static const Volume zero = Volume.fromCubicYards(0);

  double toCubicYards() => totalCubicYards;
  double toCubicFeet() => totalCubicYards * 27.0;
  double toCubicMeters() => totalCubicYards / 1.30795062;
  double toCubicInches() => totalCubicYards * 46656.0;

  double as(VolumeUnit unit) => totalCubicYards / unit.cubicYardsMultiplier;

  String toFormatted(VolumeUnit unit, {int decimals = 2}) {
    return '${as(unit).toStringAsFixed(decimals)} ${unit.symbol}';
  }

  /// Applies a waste buffer percentage (e.g. 10 for 10% waste).
  Volume withWaste(double wastePercent) {
    return Volume.fromCubicYards(totalCubicYards * (1.0 + (wastePercent / 100.0)));
  }

  @override
  String toString() => toFormatted(VolumeUnit.cubicYards);
}

/// Roof pitch representation (e.g. 4/12 or 18.43 degrees).
class RoofPitch {
  final double riseIn12; // Rise per 12 inches of horizontal run

  const RoofPitch(this.riseIn12);
  factory RoofPitch.fromDegrees(double degrees) {
    final rads = degrees * (math.pi / 180.0);
    return RoofPitch(math.tan(rads) * 12.0);
  }
  factory RoofPitch.fromRiseAndRun(Length rise, Length run) {
    if (run.totalInches == 0) return const RoofPitch(0);
    return RoofPitch((rise.totalInches / run.totalInches) * 12.0);
  }

  double get pitchDegrees => math.atan(riseIn12 / 12.0) * (180.0 / math.pi);
  double get slopeMultiplier => math.sqrt(1 + math.pow(riseIn12 / 12.0, 2));

  String get pitchNotation => '${riseIn12.toStringAsFixed(riseIn12 == riseIn12.roundToDouble() ? 0 : 2)}/12';

  @override
  String toString() => '$pitchNotation (${pitchDegrees.toStringAsFixed(1)}°)';
}
