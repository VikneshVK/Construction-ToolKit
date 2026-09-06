import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildcalc/core/math/measurement.dart';
import 'package:buildcalc/core/math/roofing_math.dart';
import 'package:buildcalc/core/components/guides/build_calc_roof_diagram.dart';
import 'package:buildcalc/features/roofing/roofing_screen.dart';

void main() {
  group('BuildCalcRoofDiagram Component Tests', () {
    testWidgets('Renders all 4 selectable measurement controls with correct initial values', (WidgetTester tester) async {
      final rafter = RoofingMath.solveCommonRafter(
        run: Length.fromFeet(12),
        pitch: RoofPitch(4),
        overhangRun: Length.fromInches(12),
      );

      RoofMeasurementMode selectedMode = RoofMeasurementMode.run;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return BuildCalcRoofDiagram(
                  pitch: rafter.pitch,
                  run: rafter.totalRun,
                  rise: rafter.totalRise,
                  overhang: rafter.overhangRun,
                  rafterLength: rafter.commonRafterLength,
                  activeMeasurement: selectedMode,
                  onMeasurementSelected: (m) => setState(() => selectedMode = m),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header
      expect(find.text('COMMON RAFTER'), findsOneWidget);

      // Verify 4 controls exist
      expect(find.text('Pitch'), findsOneWidget);
      expect(find.text('Run'), findsOneWidget);
      expect(find.text('Overhang'), findsOneWidget);
      expect(find.text('Rafter'), findsOneWidget);

      // Verify initial active mode explanation is Run
      expect(find.text('HORIZONTAL RUN'), findsWidgets);
      expect(find.text('Horizontal distance from the ridge plumb reference to the wall reference.'), findsOneWidget);

      // Tap Pitch control
      await tester.tap(find.text('Pitch'));
      await tester.pumpAndSettle();

      expect(selectedMode, RoofMeasurementMode.pitch);
      expect(find.text('PITCH'), findsWidgets);
      expect(find.text('4" vertical rise for every 12" of horizontal run.'), findsOneWidget);

      // Tap Overhang control
      await tester.tap(find.text('Overhang'));
      await tester.pumpAndSettle();

      expect(selectedMode, RoofMeasurementMode.overhang);
      expect(find.text('EAVE OVERHANG'), findsWidgets);
      expect(find.text('Horizontal projection of the roof rafter beyond the exterior wall line.'), findsOneWidget);

      // Tap Rafter control
      await tester.tap(find.text('Rafter'));
      await tester.pumpAndSettle();

      expect(selectedMode, RoofMeasurementMode.rafterLength);
      expect(find.text('RAFTER LENGTH'), findsWidgets);
      expect(find.text('True sloped line length of the common rafter from ridge peak to wall plate.'), findsOneWidget);
    });
  });

  group('RoofingScreen Integration Tests', () {
    testWidgets('RoofingScreen integrates BuildCalcRoofDiagram and updates on input change', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: RoofingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify screen title and diagram
      expect(find.text('Roofing & Rafter Cuts'), findsOneWidget);
      expect(find.byType(BuildCalcRoofDiagram), findsOneWidget);

      // Verify presets work and switch active mode to Pitch
      await tester.tap(find.text('Standard Roof (6/12 · 26°)'));
      await tester.pumpAndSettle();

      expect(find.text('PITCH'), findsWidgets);
      expect(find.text('6" vertical rise for every 12" of horizontal run.'), findsOneWidget);

      // Tap Horizontal Run input
      await tester.tap(find.widgetWithText(TextField, '12').first);
      await tester.pumpAndSettle();

      expect(find.text('HORIZONTAL RUN'), findsWidgets);
    });
  });
}
