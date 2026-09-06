import 'dart:math' as math;
import 'measurement.dart';

/// Solving mode for the stair calculation.
enum StairSolveMode {
  comfortableTread('Comfort Mode', 'Optimizes for code-compliant, comfortable tread depth (10" - 11")'),
  fixedTotalRun('Constrained Space Mode', 'Fits stairs within a fixed horizontal opening run');

  final String label;
  final String description;
  const StairSolveMode(this.label, this.description);
}

/// Verification status against building codes.
enum StairCodeStatus {
  pass('Pass — Within selected IRC limits'),
  warning('Warning — Exceeds selected IRC limits'),
  error('Error — Invalid geometry');

  final String label;
  const StairCodeStatus(this.label);
}

/// Building code compliance report for stairs.
class StairCodeReport {
  final StairCodeStatus status;
  final String ruleReference; // e.g. "IRC 2024 Section R311.7"
  final List<String> details;
  final bool isRiserCompliant;
  final bool isTreadCompliant;
  final bool isComfortCompliant;

  const StairCodeReport({
    required this.status,
    required this.ruleReference,
    required this.details,
    required this.isRiserCompliant,
    required this.isTreadCompliant,
    required this.isComfortCompliant,
  });
}

/// Output result of the stair calculation.
class StairResult {
  final int numberOfRisers;
  final int numberOfTreads;
  final Length riserHeight;
  final Length treadDepth;
  final Length totalRise;
  final Length totalRun;
  final Length stringerLength;
  final double inclineAngleDegrees;
  final StairCodeReport codeReport;

  const StairResult({
    required this.numberOfRisers,
    required this.numberOfTreads,
    required this.riserHeight,
    required this.treadDepth,
    required this.totalRise,
    required this.totalRun,
    required this.stringerLength,
    required this.inclineAngleDegrees,
    required this.codeReport,
  });
}

/// Mathematical solver and IRC Building Code sentinel for stairs.
class StairMath {
  // IRC 2024 Standard Limits (inches)
  static const double ircMaxRiser = 7.75; // 7 3/4"
  static const double ircMinTread = 10.0; // 10"
  static const double ircMaxVariation = 0.375; // 3/8"

  /// Solves stairs based on total rise and either desired tread or fixed available run.
  static StairResult solve({
    required Length totalRise,
    Length? availableRun,
    Length? preferredTread,
    StairSolveMode mode = StairSolveMode.comfortableTread,
    double maxRiserLimit = ircMaxRiser,
    double minTreadLimit = ircMinTread,
  }) {
    final riseInches = totalRise.toInches();
    if (riseInches <= 0) {
      return _buildErrorResult(totalRise, 'Total rise must be greater than zero');
    }

    // 1. Calculate number of risers targeting ~7" comfortable riser
    // Target riser: 7.0 inches
    int risers = (riseInches / 7.0).round();
    if (risers < 1) risers = 1;

    double calculatedRiserHeight = riseInches / risers;

    // If initial calculation exceeds max riser limit, increment risers
    while (calculatedRiserHeight > maxRiserLimit && risers < 50) {
      risers++;
      calculatedRiserHeight = riseInches / risers;
    }

    final int treads = risers - 1;
    double calculatedTreadDepth;
    double totalRunInches;

    if (mode == StairSolveMode.fixedTotalRun && availableRun != null && availableRun.totalInches > 0) {
      totalRunInches = availableRun.totalInches;
      calculatedTreadDepth = treads > 0 ? totalRunInches / treads : 0;
    } else {
      calculatedTreadDepth = preferredTread?.toInches() ?? 10.0;
      totalRunInches = calculatedTreadDepth * treads;
    }

    // 2. Stringer length and incline angle
    final stringerInches = math.sqrt(math.pow(riseInches, 2) + math.pow(totalRunInches, 2));
    final angleRads = totalRunInches > 0 ? math.atan(riseInches / totalRunInches) : 0.0;
    final angleDeg = angleRads * (180.0 / math.pi);

    // 3. IRC 2024 Code Evaluation
    final codeReport = _evaluateIrcCode(
      riserHeight: calculatedRiserHeight,
      treadDepth: calculatedTreadDepth,
      maxRiserLimit: maxRiserLimit,
      minTreadLimit: minTreadLimit,
    );

    return StairResult(
      numberOfRisers: risers,
      numberOfTreads: treads,
      riserHeight: Length.fromInches(calculatedRiserHeight),
      treadDepth: Length.fromInches(calculatedTreadDepth),
      totalRise: totalRise,
      totalRun: Length.fromInches(totalRunInches),
      stringerLength: Length.fromInches(stringerInches),
      inclineAngleDegrees: angleDeg,
      codeReport: codeReport,
    );
  }

  static StairCodeReport _evaluateIrcCode({
    required double riserHeight,
    required double treadDepth,
    required double maxRiserLimit,
    required double minTreadLimit,
  }) {
    final List<String> details = [];
    bool isRiserOk = true;
    bool isTreadOk = true;

    if (riserHeight > maxRiserLimit) {
      isRiserOk = false;
      details.add('Riser height (${Length.fromInches(riserHeight).toInchesFraction()}) exceeds IRC maximum of ${Length.fromInches(maxRiserLimit).toInchesFraction()}');
    }

    if (treadDepth < minTreadLimit) {
      isTreadOk = false;
      details.add('Tread depth (${Length.fromInches(treadDepth).toInchesFraction()}) is less than IRC minimum of ${Length.fromInches(minTreadLimit).toInchesFraction()}');
    }

    // Blondel's Rule of Comfort: 2R + T = 24" - 25"
    final blondelSum = (2 * riserHeight) + treadDepth;
    final isComfortOk = blondelSum >= 24.0 && blondelSum <= 25.5;
    if (!isComfortOk && isRiserOk && isTreadOk) {
      details.add('Comfort rule (2R + T = ${blondelSum.toStringAsFixed(1)}") is outside ideal range (24" - 25.5")');
    }

    final hasErrors = !isRiserOk || !isTreadOk;
    return StairCodeReport(
      status: hasErrors ? StairCodeStatus.warning : StairCodeStatus.pass,
      ruleReference: 'IRC 2024 §R311.7 (Stairways)',
      details: details.isEmpty ? ['Configuration satisfies standard IRC residential code requirements.'] : details,
      isRiserCompliant: isRiserOk,
      isTreadCompliant: isTreadOk,
      isComfortCompliant: isComfortOk,
    );
  }

  static StairResult _buildErrorResult(Length totalRise, String reason) {
    return StairResult(
      numberOfRisers: 0,
      numberOfTreads: 0,
      riserHeight: Length.zero,
      treadDepth: Length.zero,
      totalRise: totalRise,
      totalRun: Length.zero,
      stringerLength: Length.zero,
      inclineAngleDegrees: 0,
      codeReport: StairCodeReport(
        status: StairCodeStatus.error,
        ruleReference: 'IRC 2024 §R311.7',
        details: [reason],
        isRiserCompliant: false,
        isTreadCompliant: false,
        isComfortCompliant: false,
      ),
    );
  }
}
