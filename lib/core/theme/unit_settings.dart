import 'package:flutter/material.dart';

/// Available global measurement systems.
enum UnitSystem {
  imperial('American Standard (ft, in, yd³, BF)'),
  metric('SI Metric (m, cm, mm, m³)');

  final String label;
  const UnitSystem(this.label);
}

/// Global unit settings manager supporting live app-wide notification on change.
class UnitSettings extends ChangeNotifier {
  static final UnitSettings instance = UnitSettings._();
  UnitSettings._();

  UnitSystem _system = UnitSystem.imperial;
  UnitSystem get system => _system;

  bool get isMetric => _system == UnitSystem.metric;
  bool get isImperial => _system == UnitSystem.imperial;

  void setSystem(UnitSystem newSystem) {
    if (_system != newSystem) {
      _system = newSystem;
      notifyListeners();
    }
  }

  void toggle() {
    setSystem(_system == UnitSystem.imperial ? UnitSystem.metric : UnitSystem.imperial);
  }
}
