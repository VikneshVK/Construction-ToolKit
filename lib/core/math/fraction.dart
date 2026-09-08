/// High-precision, zero-drift exact Rational Fraction engine for BuildCalc.
/// Handles construction fractions up to 1/64", exact GCD reduction,
/// mixed number representations (e.g. 7 9/16"), and conversion to/from decimals.
class Fraction implements Comparable<Fraction> {
  final int numerator;
  final int denominator;

  /// Const constructor for pre-reduced / compile-time constants.
  const Fraction.raw(this.numerator, [this.denominator = 1]);

  /// Creates a fraction with automatic GCD reduction and sign normalization.
  factory Fraction(int numerator, [int denominator = 1]) {
    if (denominator == 0) {
      throw ArgumentError('Denominator cannot be zero');
    }
    if (numerator == 0) {
      return const Fraction.raw(0, 1);
    }

    // Normalize sign so denominator is always positive
    var num = numerator;
    var den = denominator;
    if (den < 0) {
      num = -num;
      den = -den;
    }

    // Reduce to lowest terms via Greatest Common Divisor (GCD)
    final gcdVal = _gcd(num.abs(), den);
    return Fraction.raw(num ~/ gcdVal, den ~/ gcdVal);
  }

  /// Zero fraction
  static const Fraction zero = Fraction.raw(0, 1);

  /// One fraction
  static const Fraction one = Fraction.raw(1, 1);

  /// Helper to calculate the Greatest Common Divisor (Euclid's algorithm).
  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  /// Helper to calculate Least Common Multiple.
  static int _lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a * b).abs() ~/ _gcd(a, b);
  }

  /// Converts a decimal (double) to the nearest exact fraction with a specified max precision denominator.
  /// Standard construction denominations: 2, 4, 8, 16, 32, 64.
  factory Fraction.fromDouble(double value, {int maxDenominator = 64}) {
    if (value.isNaN || value.isInfinite) {
      throw ArgumentError('Invalid double value');
    }

    final isNegative = value < 0;
    final absVal = value.abs();
    final whole = absVal.floor();
    final decimal = absVal - whole;

    if (decimal < 1e-9) {
      final num = isNegative ? -whole : whole;
      return Fraction(num, 1);
    }

    // Snap to nearest construction denominator
    final fractionNum = (decimal * maxDenominator).round();
    if (fractionNum == maxDenominator) {
      final num = isNegative ? -(whole + 1) : (whole + 1);
      return Fraction(num, 1);
    }

    final totalNum = whole * maxDenominator + fractionNum;
    final signedNum = isNegative ? -totalNum : totalNum;
    return Fraction(signedNum, maxDenominator);
  }

  /// Parses a string representation like "7 9/16", "3/4", "12", "-5 1/8", or "12.75".
  factory Fraction.parse(String text) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return Fraction.zero;

    // Check if it's a decimal format
    if (cleaned.contains('.') && !cleaned.contains('/')) {
      final doubleVal = double.tryParse(cleaned);
      if (doubleVal != null) {
        return Fraction.fromDouble(doubleVal);
      }
    }

    // Check for mixed fraction: "7 9/16" or "7-9/16"
    final mixedParts = cleaned.split(RegExp(r'[\s\-]+'));
    if (mixedParts.length == 2 && mixedParts[1].contains('/')) {
      final whole = int.parse(mixedParts[0]);
      final fracParts = mixedParts[1].split('/');
      final num = int.parse(fracParts[0]);
      final den = int.parse(fracParts[1]);

      final isNeg = whole < 0 || mixedParts[0].startsWith('-');
      final absWhole = whole.abs();
      final totalNum = absWhole * den + num;
      return Fraction(isNeg ? -totalNum : totalNum, den);
    }

    // Check for simple fraction: "9/16"
    if (cleaned.contains('/')) {
      final fracParts = cleaned.split('/');
      final num = int.parse(fracParts[0].trim());
      final den = int.parse(fracParts[1].trim());
      return Fraction(num, den);
    }

    // Plain integer
    final intVal = int.parse(cleaned);
    return Fraction(intVal, 1);
  }

  /// Tries to parse a string representation, returns null on failure.
  static Fraction? tryParse(String? text) {
    if (text == null) return null;
    try {
      return Fraction.parse(text);
    } catch (_) {
      return null;
    }
  }

  // --- Arithmetic Operators ---

  Fraction operator +(Fraction other) {
    final lcmVal = _lcm(denominator, other.denominator);
    final num1 = numerator * (lcmVal ~/ denominator);
    final num2 = other.numerator * (lcmVal ~/ other.denominator);
    return Fraction(num1 + num2, lcmVal);
  }

  Fraction operator -(Fraction other) {
    final lcmVal = _lcm(denominator, other.denominator);
    final num1 = numerator * (lcmVal ~/ denominator);
    final num2 = other.numerator * (lcmVal ~/ other.denominator);
    return Fraction(num1 - num2, lcmVal);
  }

  Fraction operator *(Fraction other) {
    return Fraction(numerator * other.numerator, denominator * other.denominator);
  }

  Fraction operator /(Fraction other) {
    if (other.numerator == 0) {
      throw UnsupportedError('Division by zero');
    }
    return Fraction(numerator * other.denominator, denominator * other.numerator);
  }

  Fraction operator -() => Fraction(-numerator, denominator);

  // --- Conversions and Formatting ---

  /// Returns the standard floating-point representation.
  double toDouble() => numerator / denominator;

  /// Returns the whole number component.
  int get wholePart => (numerator.abs() ~/ denominator) * (numerator < 0 ? -1 : 1);

  /// Returns the fractional remainder.
  Fraction get fractionalPart {
    final remNum = numerator.abs() % denominator;
    return Fraction(numerator < 0 ? -remNum : remNum, denominator);
  }

  /// Formats the fraction in construction notation:
  /// Examples:
  /// - `Fraction(121, 16)` -> `"7 9/16"`
  /// - `Fraction(12, 16)`  -> `"3/4"`
  /// - `Fraction(16, 16)`  -> `"1"`
  /// - `Fraction(0, 1)`    -> `"0"`
  String toMixedString({String unitSymbol = ''}) {
    if (numerator == 0) return '0$unitSymbol';

    final isNeg = numerator < 0;
    final absNum = numerator.abs();
    final whole = absNum ~/ denominator;
    final rem = absNum % denominator;

    final prefix = isNeg ? '-' : '';
    if (whole == 0) {
      return '$prefix$rem/$denominator$unitSymbol';
    } else if (rem == 0) {
      return '$prefix$whole$unitSymbol';
    } else {
      return '$prefix$whole $rem/$denominator$unitSymbol';
    }
  }

  /// Snaps this fraction to the nearest standard construction resolution (e.g. 16 for nearest 1/16").
  Fraction roundToNearest(int resolution) {
    if (resolution <= 0) return this;
    return Fraction.fromDouble(toDouble(), maxDenominator: resolution);
  }

  @override
  int compareTo(Fraction other) {
    return (numerator * other.denominator).compareTo(other.numerator * denominator);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Fraction &&
        other.numerator == numerator &&
        other.denominator == denominator;
  }

  @override
  int get hashCode => Object.hash(numerator, denominator);

  @override
  String toString() => toMixedString();
}
