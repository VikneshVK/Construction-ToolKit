import 'fraction.dart';

/// Standard construction fieldwork rounding resolutions.
enum RoundingResolution {
  exact(0, 'Exact'),
  half(2, '1/2"'),
  quarter(4, '1/4"'),
  eighth(8, '1/8"'),
  sixteenth(16, '1/16"'),
  thirtySecond(32, '1/32"'),
  sixtyFourth(64, '1/64"');

  final int denominator;
  final String label;
  const RoundingResolution(this.denominator, this.label);

  Fraction apply(Fraction value) {
    if (this == RoundingResolution.exact || denominator == 0) {
      return value;
    }
    return value.roundToNearest(denominator);
  }
}
