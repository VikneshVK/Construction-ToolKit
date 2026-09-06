import 'package:flutter_test/flutter_test.dart';
import 'package:buildcalc/core/math/fraction.dart';

void main() {
  group('Fraction Exact Engine Tests', () {
    test('Simplification & GCD Reduction', () {
      final f1 = Fraction(12, 16);
      expect(f1.numerator, 3);
      expect(f1.denominator, 4);
      expect(f1.toMixedString(), '3/4');

      final f2 = Fraction(121, 16);
      expect(f2.toMixedString(), '7 9/16');

      final f3 = Fraction(16, 16);
      expect(f3.toMixedString(), '1');

      final f4 = Fraction(0, 8);
      expect(f4.toMixedString(), '0');
    });

    test('Arithmetic Operators', () {
      // 1/2 + 1/4 = 3/4
      final sum = Fraction(1, 2) + Fraction(1, 4);
      expect(sum, Fraction(3, 4));

      // 7/8 - 1/8 = 3/4 (6/8 reduced)
      final diff = Fraction(7, 8) - Fraction(1, 8);
      expect(diff, Fraction(3, 4));

      // 3/4 * 2/3 = 1/2 (6/12 reduced)
      final prod = Fraction(3, 4) * Fraction(2, 3);
      expect(prod, Fraction(1, 2));

      // 1/2 / 1/4 = 2/1
      final div = Fraction(1, 2) / Fraction(1, 4);
      expect(div, Fraction(2, 1));
    });

    test('String Parsing', () {
      expect(Fraction.parse('7 9/16'), Fraction(121, 16));
      expect(Fraction.parse('3/4'), Fraction(3, 4));
      expect(Fraction.parse('12'), Fraction(12, 1));
      expect(Fraction.parse('0.875'), Fraction(7, 8));
      expect(Fraction.parse('0.5'), Fraction(1, 2));
    });

    test('Precision Double Conversion (Edge Cases)', () {
      // 7/8 = 0.875 (Reported failure in competitor apps)
      final f = Fraction.fromDouble(0.875, maxDenominator: 16);
      expect(f, Fraction(7, 8));
      expect(f.toMixedString(), '7/8');

      // 7 9/16 = 7.5625
      final fMixed = Fraction.fromDouble(7.5625, maxDenominator: 64);
      expect(fMixed, Fraction(121, 16));
      expect(fMixed.toMixedString(), '7 9/16');

      // 1/64 = 0.015625
      final f64 = Fraction.fromDouble(0.015625, maxDenominator: 64);
      expect(f64, Fraction(1, 64));
    });
  });
}
