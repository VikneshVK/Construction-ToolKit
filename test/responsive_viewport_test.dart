import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildcalc/core/theme/app_theme.dart';
import 'package:buildcalc/core/theme/app_typography.dart';
import 'package:buildcalc/core/theme/app_colors.dart';
import 'package:buildcalc/core/components/display/buildcalc_info_card.dart';
import 'package:buildcalc/features/home/home_screen.dart';
import 'package:buildcalc/features/materials/materials_screen.dart';
import 'package:buildcalc/features/roofing/roofing_screen.dart';
import 'package:buildcalc/features/stairs/stairs_screen.dart';
import 'package:buildcalc/features/measurements/measurements_screen.dart';
import 'package:buildcalc/features/history/history_screen.dart';
import 'package:buildcalc/core/persistence/local_storage.dart';

void main() {
  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await LocalStorageService.instance.init();
  });

  const viewports = [
    Size(320, 640), // 320px width - small mobile
    Size(360, 740), // 360px width - standard Android
    Size(390, 844), // 390px width - modern iPhone
    Size(430, 932), // 430px width - large pro mobile
  ];

  Widget wrapWithApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: child,
    );
  }

  group('BuildCalc Type Scale & Semantic Color Verification', () {
    test('AppTypography defines canonical type scale without drift', () {
      expect(AppTypography.screenTitle.fontSize, 30.0);
      expect(AppTypography.screenTitle.fontWeight, FontWeight.w700);

      expect(AppTypography.sectionTitle.fontSize, 21.0);
      expect(AppTypography.sectionTitle.fontWeight, FontWeight.w700);

      expect(AppTypography.cardTitle.fontSize, 18.0);
      expect(AppTypography.cardTitle.fontWeight, FontWeight.w700);

      expect(AppTypography.primaryResult.fontSize, 52.0);
      expect(AppTypography.primaryResult.fontWeight, FontWeight.w800);

      expect(AppTypography.resultUnit.fontSize, 26.0);
      expect(AppTypography.resultUnit.fontWeight, FontWeight.w700);

      expect(AppTypography.inputLabel.fontSize, 17.0);
      expect(AppTypography.inputLabel.fontWeight, FontWeight.w500);

      expect(AppTypography.inputValue.fontSize, 28.0);
      expect(AppTypography.inputValue.fontWeight, FontWeight.w600);

      expect(AppTypography.body.fontSize, 16.0);
      expect(AppTypography.body.fontWeight, FontWeight.w400);

      expect(AppTypography.supportingText.fontSize, 14.0);
      expect(AppTypography.supportingText.fontWeight, FontWeight.w400);

      expect(AppTypography.microMeta.fontSize, 12.0);
      expect(AppTypography.microMeta.fontWeight, FontWeight.w500);
    });

    test('Semantic color roles are distinctly defined', () {
      // Gold = active/selected/interactive
      expect(AppColors.brandGold, const Color(0xFFD4AF37));
      // Green = pass/success/recommended
      expect(AppColors.statusSuccess, const Color(0xFF22C55E));
      // Blue = technical information & diagrams
      expect(AppColors.technicalBlue, const Color(0xFF38BDF8));
      // White = primary results
      expect(AppColors.textPrimary, const Color(0xFFF5F7FA));
      // Gray = secondary information
      expect(AppColors.textSecondary, const Color(0xFF9CA3AF));
    });

    testWidgets('BuildCalcInfoCard renders topic, value, and description correctly', (tester) async {
      await tester.pumpWidget(wrapWithApp(
        const Scaffold(
          body: BuildCalcInfoCard(
            topic: 'WALL LENGTH',
            value: '30 ft',
            description: 'Total horizontal length of the wall.',
          ),
        ),
      ));

      expect(find.text('WALL LENGTH'), findsOneWidget);
      expect(find.text('30 ft'), findsOneWidget);
      expect(find.text('Total horizontal length of the wall.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Multi-Viewport QA & Zero Layout Overflow Tests', () {
    for (final size in viewports) {
      final width = size.width.toInt();

      testWidgets('HomeScreen renders without overflow at ${width}px', (tester) async {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(wrapWithApp(
          HomeScreen(onSelectCategory: (_) {}),
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text("Let's build."), findsOneWidget);
        expect(find.text('Materials'), findsOneWidget);
        expect(find.text('Roofing'), findsOneWidget);
        expect(find.text('Stairs'), findsOneWidget);
        expect(find.text('Measurements'), findsOneWidget);
      });

      testWidgets('MaterialsScreen renders without overflow at ${width}px', (tester) async {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(wrapWithApp(const MaterialsScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Materials & Estimating'), findsOneWidget);

        // Switch to Lumber tab
        final lumberTab = find.textContaining('Lumber');
        if (lumberTab.evaluate().isNotEmpty) {
          await tester.ensureVisible(lumberTab.first);
          await tester.tap(lumberTab.first);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        // Switch to Masonry tab
        final masonryTab = find.textContaining('Masonry');
        if (masonryTab.evaluate().isNotEmpty) {
          await tester.ensureVisible(masonryTab.first);
          await tester.tap(masonryTab.first);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('RoofingScreen renders without overflow at ${width}px', (tester) async {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(wrapWithApp(const RoofingScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Roofing & Rafter Cuts'), findsOneWidget);

        // Switch to True-Cut Jack schedule tab
        final jackTab = find.text('True-Cut Jack Rafters');
        if (jackTab.evaluate().isNotEmpty) {
          await tester.ensureVisible(jackTab);
          await tester.tap(jackTab);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('StairsScreen renders without overflow at ${width}px', (tester) async {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(wrapWithApp(const StairsScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Stairs & Handrails'), findsOneWidget);
      });

      testWidgets('MeasurementsScreen renders without overflow at ${width}px', (tester) async {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(wrapWithApp(const MeasurementsScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Measurements & Conversions'), findsOneWidget);

        // Switch to mixed unit tab
        final mixedTab = find.text('Mixed-Unit Site Log');
        if (mixedTab.evaluate().isNotEmpty) {
          await tester.tap(mixedTab);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('HistoryScreen renders without overflow at ${width}px', (tester) async {
        tester.view.physicalSize = Size(size.width * 2, size.height * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(wrapWithApp(const HistoryScreen()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Jobsite History & Logs'), findsOneWidget);
      });
    }
  });
}
