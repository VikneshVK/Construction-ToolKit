import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saved calculation entry for the jobsite log.
class SavedCalculation {
  final String id;
  final String title;
  final String category; // 'materials', 'roofing', 'stairs', 'measurements'
  final String primaryResult;
  final String subtitle;
  final Map<String, String> inputs;
  final List<String> details;
  final DateTime timestamp;
  final bool isBookmarked;

  const SavedCalculation({
    required this.id,
    required this.title,
    required this.category,
    required this.primaryResult,
    required this.subtitle,
    required this.inputs,
    required this.details,
    required this.timestamp,
    this.isBookmarked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'primaryResult': primaryResult,
        'subtitle': subtitle,
        'inputs': inputs,
        'details': details,
        'timestamp': timestamp.toIso8601String(),
        'isBookmarked': isBookmarked,
      };

  factory SavedCalculation.fromJson(Map<String, dynamic> json) => SavedCalculation(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String,
        primaryResult: json['primaryResult'] as String,
        subtitle: json['subtitle'] as String,
        inputs: Map<String, String>.from(json['inputs'] as Map),
        details: List<String>.from(json['details'] as List),
        timestamp: DateTime.parse(json['timestamp'] as String),
        isBookmarked: json['isBookmarked'] as bool? ?? false,
      );
}

/// Offline-first local calculation history storage service.
class LocalStorageService {
  static const String _storageKey = 'buildcalc_saved_calculations_v1';
  static final LocalStorageService instance = LocalStorageService._();
  LocalStorageService._();

  final List<SavedCalculation> _cachedList = [];
  bool _isInitialized = false;
  SharedPreferences? _prefs;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    try {
      _prefs = await SharedPreferences.getInstance();
      final content = _prefs?.getString(_storageKey);
      if (content != null && content.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(content);
        _cachedList.clear();
        _cachedList.addAll(decoded.map((e) => SavedCalculation.fromJson(e as Map<String, dynamic>)));
      }
    } catch (_) {
      // Fallback to in-memory store
    }
  }

  Future<void> _persist() async {
    try {
      final data = jsonEncode(_cachedList.map((e) => e.toJson()).toList());
      await _prefs?.setString(_storageKey, data);
    } catch (_) {}
  }

  @visibleForTesting
  void resetForTesting() {
    _cachedList.clear();
    _isInitialized = false;
    _prefs = null;
  }

  List<SavedCalculation> getHistory() {
    return List.unmodifiable(_cachedList);
  }

  List<SavedCalculation> getSavedBookmarked() {
    return _cachedList.where((e) => e.isBookmarked).toList();
  }

  Future<void> addCalculation(SavedCalculation calc) async {
    // Keep max 50 recent items
    _cachedList.removeWhere((e) => e.id == calc.id);
    _cachedList.insert(0, calc);
    if (_cachedList.length > 50) {
      _cachedList.removeLast();
    }
    await _persist();
  }

  Future<void> toggleBookmark(String id) async {
    final index = _cachedList.indexWhere((e) => e.id == id);
    if (index != -1) {
      final old = _cachedList[index];
      _cachedList[index] = SavedCalculation(
        id: old.id,
        title: old.title,
        category: old.category,
        primaryResult: old.primaryResult,
        subtitle: old.subtitle,
        inputs: old.inputs,
        details: old.details,
        timestamp: old.timestamp,
        isBookmarked: !old.isBookmarked,
      );
      await _persist();
    }
  }

  Future<void> deleteCalculation(String id) async {
    _cachedList.removeWhere((e) => e.id == id);
    await _persist();
  }

  Future<void> clearHistory() async {
    _cachedList.removeWhere((e) => !e.isBookmarked);
    await _persist();
  }
}
