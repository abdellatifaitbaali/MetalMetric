import 'package:flutter/foundation.dart';
import '../models/metal.dart';
import '../models/metal_price.dart';

/// Provider for managing calculator state
class CalculatorProvider extends ChangeNotifier {
  MetalType _selectedMetal = MetalType.gold;
  double _weight = 0;
  WeightUnit _weightUnit = WeightUnit.grams;
  String _selectedPurity = '';
  double? _calculatedValue;

  CalculatorProvider() {
    _selectedPurity = _selectedMetal.defaultPurity;
  }

  /// Currently selected metal
  MetalType get selectedMetal => _selectedMetal;

  /// Current weight input
  double get weight => _weight;

  /// Current weight unit
  WeightUnit get weightUnit => _weightUnit;

  /// Selected purity
  String get selectedPurity => _selectedPurity;

  /// Calculated value (null if not calculated yet)
  double? get calculatedValue => _calculatedValue;

  /// Get purity options for current metal
  Map<String, double> get purityOptions => _selectedMetal.purities;

  /// Get purity decimal for current selection
  double get purityDecimal => purityOptions[_selectedPurity] ?? 1.0;

  /// Update selected metal
  void setMetal(MetalType metal) {
    if (_selectedMetal == metal) return;

    _selectedMetal = metal;
    // Reset purity to default for new metal
    _selectedPurity = metal.defaultPurity;
    _calculatedValue = null;
    notifyListeners();
  }

  /// Update weight value
  void setWeight(double weight) {
    _weight = weight;
    _calculatedValue = null;
    notifyListeners();
  }

  /// Update weight unit
  void setWeightUnit(WeightUnit unit) {
    if (_weightUnit == unit) return;

    _weightUnit = unit;
    _calculatedValue = null;
    notifyListeners();
  }

  /// Update selected purity
  void setPurity(String purity) {
    if (_selectedPurity == purity) return;

    _selectedPurity = purity;
    _calculatedValue = null;
    notifyListeners();
  }

  /// Calculate value based on current inputs and price
  void calculate(MetalPrice price) {
    if (_weight <= 0) {
      _calculatedValue = null;
      notifyListeners();
      return;
    }

    // Convert weight to troy ounces
    final weightInTroyOz = _weightUnit.toTroyOunces(_weight);

    // Calculate value
    _calculatedValue = price.calculateValue(
      weightInTroyOz: weightInTroyOz,
      purity: purityDecimal,
    );

    notifyListeners();
  }

  /// Reset calculator to defaults
  void reset() {
    _selectedMetal = MetalType.gold;
    _weight = 0;
    _weightUnit = WeightUnit.grams;
    _selectedPurity = _selectedMetal.defaultPurity;
    _calculatedValue = null;
    notifyListeners();
  }
}
