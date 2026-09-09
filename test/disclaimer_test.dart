import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buildcalc/main.dart';
import 'package:buildcalc/core/persistence/local_storage.dart';
import 'package:buildcalc/features/disclaimer/disclaimer_screen.dart';
import 'package:buildcalc/core/components/legal/legal_disclaimer_content.dart';
import 'package:buildcalc/core/components/dialogs/unit_settings_dialog.dart';
import 'package:buildcalc/core/theme/app_theme.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocalStorageService.instance.resetForTesting();
    await LocalStorageService.instance.init();
  });

  group('Disclaimer Persistence & Storage Tests', () {
    test('Defaults to false on fresh install', () {
      expect(LocalStorageService.instance.hasAcceptedDisclaimer, isFalse);
    });

    test('setAcceptedDisclaimer updates cache and persists value', () async {
      expect(LocalStorageService.instance.hasAcceptedDisclaimer, isFalse);
      await LocalStorageService.instance.setAcceptedDisclaimer(true);
      expect(LocalStorageService.instance.hasAcceptedDisclaimer, isTrue);

      // Simulate app restart / re-initialization
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('buildcalc_accepted_disclaimer_v1'), isTrue);
    });
  });

  group('First-Launch Disclaimer Flow Tests', () {
    testWidgets('First launch displays DisclaimerScreen and shows all clauses', (tester) async {
      await tester.pumpWidget(const BuildCalcApp(showSplash: false, overrideDisclaimerAccepted: false));
      await tester.pumpAndSettle();

      expect(find.byType(DisclaimerScreen), findsOneWidget);
      expect(find.text('Legal & Professional Disclaimer'), findsOneWidget);
      expect(find.byType(LegalDisclaimerContent), findsOneWidget);
      expect(find.text('1. For Reference & Estimation Only'), findsOneWidget);
      expect(find.text('2. Not a Substitute for PE / Architectural Stamps'), findsOneWidget);
      expect(find.text('3. Building Codes & Authority Having Jurisdiction (AHJ)'), findsOneWidget);
      expect(find.text('4. Mandatory Field Verification ("Measure Twice")'), findsOneWidget);
      expect(find.text('5. "As-Is" Warranty & Limitation of Liability'), findsOneWidget);
      expect(find.text('6. 100% Offline Privacy Guarantee'), findsOneWidget);
      expect(find.text('Accept & Continue'), findsOneWidget);
    });

    testWidgets('Tapping Accept & Continue marks accepted and navigates to Home', (tester) async {
      await tester.pumpWidget(const BuildCalcApp(showSplash: false, overrideDisclaimerAccepted: false));
      await tester.pumpAndSettle();

      expect(find.byType(DisclaimerScreen), findsOneWidget);

      // Tap Accept & Continue button
      await tester.tap(find.text('Accept & Continue'));
      await tester.pumpAndSettle();

      // Verify disclaimer marked as accepted in LocalStorageService
      expect(LocalStorageService.instance.hasAcceptedDisclaimer, isTrue);

      // Verify navigated to Home Dashboard
      expect(find.text("Let's build."), findsOneWidget);
    });

    testWidgets('Subsequent launch with accepted disclaimer directly displays Home', (tester) async {
      // Mark accepted beforehand
      await LocalStorageService.instance.setAcceptedDisclaimer(true);

      await tester.pumpWidget(const BuildCalcApp(showSplash: false));
      await tester.pumpAndSettle();

      // Verify DisclaimerScreen is skipped
      expect(find.byType(DisclaimerScreen), findsNothing);
      expect(find.text("Let's build."), findsOneWidget);
    });
  });

  group('Settings Dialog Legal & Disclaimer Tab Tests', () {
    testWidgets('Settings dialog displays Legal tab and shows disclaimer clauses with accepted badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: UnitSettingsDialog(initialTab: 2), // Open directly to Legal tab
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title and tab
      expect(find.text('Legal & Disclaimer'), findsWidgets);
      expect(find.text('Terms & Disclaimer accepted on this device'), findsOneWidget);
      expect(find.text('1. For Reference & Estimation Only'), findsOneWidget);
      expect(find.text('Apply Settings'), findsOneWidget);
    });

    testWidgets('Can switch between Units, Glossary, and Legal tabs within Settings dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: UnitSettingsDialog(initialTab: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Starts on Units tab
      expect(find.text('Unit System Settings'), findsOneWidget);
      expect(find.text('American Standard (Imperial)'), findsOneWidget);

      // Tap Code & Glossary tab
      await tester.tap(find.text('Code & Glossary'));
      await tester.pumpAndSettle();
      expect(find.text('Code & Glossary'), findsWidgets);
      expect(find.text('IRC 2024 Building Safety Code (§R311.7)'), findsOneWidget);

      // Tap Legal tab
      await tester.tap(find.text('Legal'));
      await tester.pumpAndSettle();
      expect(find.text('Legal & Disclaimer'), findsOneWidget);
      expect(find.text('1. For Reference & Estimation Only'), findsOneWidget);

      // Tap Apply Settings button
      await tester.tap(find.text('Apply Settings'));
      await tester.pumpAndSettle();
    });

    testWidgets('Legal tab provides expandable Full Privacy Policy and Terms of Use', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: UnitSettingsDialog(initialTab: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to and expand Privacy Policy
      await tester.scrollUntilVisible(find.text('Full Privacy Policy'), 200);
      expect(find.text('Full Privacy Policy'), findsOneWidget);

      await tester.tap(find.text('Full Privacy Policy'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Zero Personal Data Collected'), findsOneWidget);

      // Scroll to and expand Terms of Use
      await tester.scrollUntilVisible(find.text('Terms of Use & License'), 200);
      await tester.tap(find.text('Terms of Use & License'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Commercial Trade Use'), findsOneWidget);

      // Scroll to footer
      await tester.scrollUntilVisible(find.text('BuildCalc v1.0.0 · Offline Jobsite Instrument'), 200);
      expect(find.text('BuildCalc v1.0.0 · Offline Jobsite Instrument'), findsOneWidget);
    });
  });
}
