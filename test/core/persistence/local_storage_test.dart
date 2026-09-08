import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buildcalc/core/persistence/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    LocalStorageService.instance.resetForTesting();
    await LocalStorageService.instance.init();
  });

  group('LocalStorageService Persistent Storage Tests', () {
    test('Initial history is empty', () {
      expect(LocalStorageService.instance.getHistory(), isEmpty);
      expect(LocalStorageService.instance.getSavedBookmarked(), isEmpty);
    });

    test('addCalculation persists entry in memory and SharedPreferences', () async {
      final calc = SavedCalculation(
        id: 'calc_001',
        title: 'Concrete Slab 20x24',
        category: 'materials',
        primaryResult: '5.93 yd³',
        subtitle: '4" depth with 10% spillage',
        inputs: {'length': '20 ft', 'width': '24 ft', 'depth': '4 in'},
        details: ['Base Volume: 5.39 yd³', 'Order Volume: 5.93 yd³'],
        timestamp: DateTime.now(),
      );

      await LocalStorageService.instance.addCalculation(calc);

      final history = LocalStorageService.instance.getHistory();
      expect(history.length, 1);
      expect(history.first.id, 'calc_001');
      expect(history.first.title, 'Concrete Slab 20x24');
      expect(history.first.primaryResult, '5.93 yd³');
    });

    test('Data survives re-initialization (app restart simulation)', () async {
      final calc = SavedCalculation(
        id: 'calc_002',
        title: '7/12 Rafter Pitch',
        category: 'roofing',
        primaryResult: '14 ft 4 7/8 in',
        subtitle: 'Span 24 ft',
        inputs: {'pitch': '7/12', 'run': '12 ft'},
        details: ['Plumb cut: 30.26°', 'Level cut: 59.74°'],
        timestamp: DateTime.now(),
        isBookmarked: true,
      );

      await LocalStorageService.instance.addCalculation(calc);

      // Simulate app restart
      LocalStorageService.instance.resetForTesting();
      // Re-initialize without clearing mock SharedPreferences
      await LocalStorageService.instance.init();

      final reloaded = LocalStorageService.instance.getHistory();
      expect(reloaded.length, 1);
      expect(reloaded.first.id, 'calc_002');
      expect(reloaded.first.isBookmarked, isTrue);
      expect(LocalStorageService.instance.getSavedBookmarked().length, 1);
    });

    test('toggleBookmark toggles state and persists', () async {
      final calc = SavedCalculation(
        id: 'calc_003',
        title: '14 Riser Staircase',
        category: 'stairs',
        primaryResult: '14 Risers @ 7 1/2"',
        subtitle: '13 Treads @ 10"',
        inputs: {'rise': '105 in', 'tread': '10 in'},
        details: ['Total Run: 130 in', 'Stringer: 167 1/8 in'],
        timestamp: DateTime.now(),
        isBookmarked: false,
      );

      await LocalStorageService.instance.addCalculation(calc);
      expect(LocalStorageService.instance.getSavedBookmarked(), isEmpty);

      await LocalStorageService.instance.toggleBookmark('calc_003');
      expect(LocalStorageService.instance.getSavedBookmarked().length, 1);
      expect(LocalStorageService.instance.getHistory().first.isBookmarked, isTrue);

      await LocalStorageService.instance.toggleBookmark('calc_003');
      expect(LocalStorageService.instance.getSavedBookmarked(), isEmpty);
      expect(LocalStorageService.instance.getHistory().first.isBookmarked, isFalse);
    });

    test('deleteCalculation removes item from history', () async {
      final calc = SavedCalculation(
        id: 'calc_004',
        title: 'Masonry CMU Block Wall',
        category: 'materials',
        primaryResult: '113 Blocks',
        subtitle: '30 ft x 5 ft',
        inputs: {'length': '30 ft', 'height': '5 ft'},
        details: ['Mortar: 4 bags'],
        timestamp: DateTime.now(),
      );

      await LocalStorageService.instance.addCalculation(calc);
      expect(LocalStorageService.instance.getHistory().length, 1);

      await LocalStorageService.instance.deleteCalculation('calc_004');
      expect(LocalStorageService.instance.getHistory(), isEmpty);
    });

    test('clearHistory clears non-bookmarked calculations but preserves bookmarks', () async {
      final normal = SavedCalculation(
        id: 'calc_normal',
        title: 'Normal Run',
        category: 'measurements',
        primaryResult: '10 ft',
        subtitle: 'Converter',
        inputs: {},
        details: [],
        timestamp: DateTime.now(),
        isBookmarked: false,
      );
      final bookmarked = SavedCalculation(
        id: 'calc_bookmarked',
        title: 'Bookmarked Run',
        category: 'measurements',
        primaryResult: '20 ft',
        subtitle: 'Converter',
        inputs: {},
        details: [],
        timestamp: DateTime.now(),
        isBookmarked: true,
      );

      await LocalStorageService.instance.addCalculation(normal);
      await LocalStorageService.instance.addCalculation(bookmarked);
      expect(LocalStorageService.instance.getHistory().length, 2);

      await LocalStorageService.instance.clearHistory();
      final remaining = LocalStorageService.instance.getHistory();
      expect(remaining.length, 1);
      expect(remaining.first.id, 'calc_bookmarked');
    });
  });
}
