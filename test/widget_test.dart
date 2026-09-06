import 'package:flutter_test/flutter_test.dart';
import 'package:buildcalc/main.dart';

void main() {
  testWidgets('BuildCalc App Launch & Navigation Test', (WidgetTester tester) async {
    // Build BuildCalc app and trigger a frame.
    await tester.pumpWidget(const BuildCalcApp());
    await tester.pumpAndSettle();

    // Verify BuildCalc branding is present on Home Screen
    expect(find.text('BUILDCALC'), findsWidgets);
    expect(find.text("Let's build."), findsOneWidget);

    // Verify 4 primary category tiles exist
    expect(find.text('Materials'), findsWidgets);
    expect(find.text('Roofing'), findsWidgets);
    expect(find.text('Stairs'), findsWidgets);
    expect(find.text('Measurements'), findsWidgets);

    // Tap on Materials navigation item
    await tester.tap(find.text('Materials').first);
    await tester.pumpAndSettle();

    // Verify Concrete Slab calculator is loaded
    expect(find.text('Concrete'), findsOneWidget);
    expect(find.text('Lumber (BF)'), findsOneWidget);
    expect(find.text('Masonry Block'), findsOneWidget);

    // Open settings dialog and switch to Metric
    await tester.tap(find.byTooltip('Unit & App Settings').first);
    await tester.pumpAndSettle();

    expect(find.text('Unit System Settings'), findsOneWidget);
    expect(find.text('International System (SI Metric)'), findsOneWidget);

    // Tap SI Metric option
    await tester.tap(find.text('International System (SI Metric)'));
    await tester.pumpAndSettle();

    // Tap Apply Settings
    await tester.tap(find.text('Apply Settings'));
    await tester.pumpAndSettle();

    // Verify UI dynamically updated to Metric labels
    expect(find.text('Lumber (m³ / BF)'), findsOneWidget);
  });
}
