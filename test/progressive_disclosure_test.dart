import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildcalc/main.dart';
import 'package:buildcalc/core/components/inputs/buildcalc_info_button.dart';
import 'package:buildcalc/core/components/guides/visual_measurement_guide.dart';
import 'package:buildcalc/core/components/display/trade_details_expansion.dart';

void main() {
  testWidgets('Progressive Disclosure, Visual Guides, and Info Tooltip Tests', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const BuildCalcApp());
    await tester.pumpAndSettle();

    // 1. Navigate to Stairs
    await tester.tap(find.text('Stairs').first);
    await tester.pumpAndSettle();

    // Verify Visual Guide and Friendly Presets are rendered
    expect(find.byType(VisualMeasurementGuide), findsOneWidget);
    expect(find.text('Standard 8 ft Ceiling (244 cm)'), findsOneWidget);

    // Scroll down to see results
    await tester.drag(find.byType(SingleChildScrollView).last, const Offset(0, -400));
    await tester.pumpAndSettle();

    // Verify Beginner Friendly Output
    expect(find.text('STAIR STEPS SUMMARY'), findsOneWidget);
    expect(find.text('14 Steps Needed'), findsOneWidget);

    // Verify Trade Details progressive disclosure is collapsed initially
    expect(find.byType(TradeDetailsExpansion), findsOneWidget);
    expect(find.text('Show Stringer Wood Cut Details & Code Check'), findsOneWidget);
    expect(find.text('Show'), findsOneWidget);

    // Expand trade details
    await tester.tap(find.text('Show Stringer Wood Cut Details & Code Check'));
    await tester.pumpAndSettle();
    expect(find.text('Hide'), findsOneWidget);
    expect(find.text('Diagonal Stringer Board Length'), findsOneWidget);

    // 2. Open an Info Button (?) bottom sheet
    await tester.drag(find.byType(SingleChildScrollView).last, const Offset(0, 400));
    await tester.pumpAndSettle();

    final infoButtons = find.byType(BuildCalcInfoButton);
    expect(infoButtons, findsWidgets);
    await tester.tap(infoButtons.first);
    await tester.pumpAndSettle();

    // Verify bottom sheet content
    expect(find.text('Trade / Industry Term: Total Rise'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    // Close bottom sheet
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // 3. Open Settings and verify Glossary sub-tab
    await tester.tap(find.byTooltip('Unit & App Settings').first);
    await tester.pumpAndSettle();

    expect(find.text('Code & Glossary'), findsOneWidget);
    await tester.tap(find.text('Code & Glossary'));
    await tester.pumpAndSettle();

    expect(find.text('IRC 2024 Building Safety Code (§R311.7)'), findsOneWidget);
    expect(find.text("Blondel's Rule of Comfort"), findsOneWidget);

    // Close settings dialog
    await tester.tap(find.text('Apply Settings'));
    await tester.pumpAndSettle();

    // 4. Navigate to Materials and test Dynamic Measurement Guide
    await tester.tap(find.text('Materials').first);
    await tester.pumpAndSettle();

    expect(find.byType(VisualMeasurementGuide), findsOneWidget);
    expect(find.text('Concrete Slab Guide'), findsOneWidget);
    expect(find.text('Length (L)'), findsOneWidget);

    // Tap Width chip on the dynamic guide
    await tester.tap(find.textContaining('Width').first);
    await tester.pumpAndSettle();
    expect(find.text('Width (W)'), findsOneWidget);

    // Tap Thickness chip on the dynamic guide
    await tester.tap(find.textContaining('Thickness').first);
    await tester.pumpAndSettle();
    expect(find.text('Thickness (Depth)'), findsOneWidget);

    // 5. Switch to Wall sub-tab in Concrete and verify Concrete Wall Guide
    await tester.tap(find.text('Wall'));
    await tester.pumpAndSettle();

    expect(find.text('Concrete Wall Guide'), findsOneWidget);
    expect(find.text('Wall Length (L)'), findsOneWidget);

    // Tap Height chip on Concrete Wall guide
    await tester.tap(find.textContaining('Height').first);
    await tester.pumpAndSettle();
    expect(find.text('Wall Height (H)'), findsOneWidget);
  });
}
