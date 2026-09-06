import 'dart:math' as math;
import 'measurement.dart';

/// Concrete element structure types.
enum ConcreteStructureType {
  slab('Slab', 'Rectangular slab or driveway'),
  footing('Footing', 'Continuous wall footing or trench'),
  column('Column', 'Cylindrical post or pier'),
  wall('Wall', 'Foundation or retaining wall');

  final String label;
  final String description;
  const ConcreteStructureType(this.label, this.description);
}

/// Result of a concrete structural volume calculation.
class ConcreteResult {
  final Volume netVolume;
  final Volume grossVolume;
  final double wastePercent;
  final double recommendedOrderYards; // Rounded up to nearest 0.25 or 0.5 yd³ for truck ordering

  const ConcreteResult({
    required this.netVolume,
    required this.grossVolume,
    required this.wastePercent,
    required this.recommendedOrderYards,
  });
}

/// Calculation engine for concrete structural volumes.
class ConcreteMath {
  /// Calculates volume for a rectangular slab: Length (ft) x Width (ft) x Thickness (in).
  static ConcreteResult calculateSlab({
    required Length length,
    required Length width,
    required Length thickness,
    double wastePercent = 10.0,
  }) {
    final lFeet = length.toFeet();
    final wFeet = width.toFeet();
    final tFeet = thickness.toInches() / 12.0;

    final cuFt = lFeet * wFeet * tFeet;
    final netVol = Volume.fromCubicFeet(cuFt);
    final grossVol = netVol.withWaste(wastePercent);

    // Concrete ready-mix order recommendation: round up to nearest 0.1 or 0.25 yd³
    final rawGross = grossVol.toCubicYards();
    final recommended = (rawGross * 10).ceil() / 10.0;

    return ConcreteResult(
      netVolume: netVol,
      grossVolume: grossVol,
      wastePercent: wastePercent,
      recommendedOrderYards: recommended,
    );
  }

  /// Calculates volume for a continuous footing: Length (ft) x Width (in) x Depth (in).
  static ConcreteResult calculateFooting({
    required Length length,
    required Length width,
    required Length depth,
    double wastePercent = 10.0,
  }) {
    final lFeet = length.toFeet();
    final wFeet = width.toInches() / 12.0;
    final dFeet = depth.toInches() / 12.0;

    final cuFt = lFeet * wFeet * dFeet;
    final netVol = Volume.fromCubicFeet(cuFt);
    final grossVol = netVol.withWaste(wastePercent);
    final recommended = (grossVol.toCubicYards() * 10).ceil() / 10.0;

    return ConcreteResult(
      netVolume: netVol,
      grossVolume: grossVol,
      wastePercent: wastePercent,
      recommendedOrderYards: recommended,
    );
  }

  /// Calculates volume for cylindrical columns: Diameter (in) x Height (ft) x Quantity.
  static ConcreteResult calculateColumn({
    required Length diameter,
    required Length height,
    int quantity = 1,
    double wastePercent = 10.0,
  }) {
    final radiusFeet = (diameter.toInches() / 2.0) / 12.0;
    final hFeet = height.toFeet();

    final singleCuFt = math.pi * radiusFeet * radiusFeet * hFeet;
    final totalCuFt = singleCuFt * quantity;

    final netVol = Volume.fromCubicFeet(totalCuFt);
    final grossVol = netVol.withWaste(wastePercent);
    final recommended = (grossVol.toCubicYards() * 10).ceil() / 10.0;

    return ConcreteResult(
      netVolume: netVol,
      grossVolume: grossVol,
      wastePercent: wastePercent,
      recommendedOrderYards: recommended,
    );
  }

  /// Calculates volume for foundation walls: Length (ft) x Height (ft) x Thickness (in).
  static ConcreteResult calculateWall({
    required Length length,
    required Length height,
    required Length thickness,
    double wastePercent = 10.0,
  }) {
    final lFeet = length.toFeet();
    final hFeet = height.toFeet();
    final tFeet = thickness.toInches() / 12.0;

    final cuFt = lFeet * hFeet * tFeet;
    final netVol = Volume.fromCubicFeet(cuFt);
    final grossVol = netVol.withWaste(wastePercent);
    final recommended = (grossVol.toCubicYards() * 10).ceil() / 10.0;

    return ConcreteResult(
      netVolume: netVol,
      grossVolume: grossVol,
      wastePercent: wastePercent,
      recommendedOrderYards: recommended,
    );
  }
}
