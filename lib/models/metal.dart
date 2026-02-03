import '../utils/constants.dart';

/// Types of metals supported by the app
enum MetalType {
  gold,
  silver,
  platinum,
  palladium,
}

/// Extension to get properties for each metal type
extension MetalTypeExtension on MetalType {
  /// Get the ISO 4217 symbol for this metal (for display)
  String get symbol {
    switch (this) {
      case MetalType.gold:
        return MetalSymbols.gold;
      case MetalType.silver:
        return MetalSymbols.silver;
      case MetalType.platinum:
        return MetalSymbols.platinum;
      case MetalType.palladium:
        return MetalSymbols.palladium;
    }
  }

  /// Get the API response key for this metal
  String get apiKey {
    switch (this) {
      case MetalType.gold:
        return 'gold';
      case MetalType.silver:
        return 'silver';
      case MetalType.platinum:
        return 'platinum';
      case MetalType.palladium:
        return 'palladium';
    }
  }

  /// Get the display name for this metal
  String get displayName {
    switch (this) {
      case MetalType.gold:
        return 'Gold';
      case MetalType.silver:
        return 'Silver';
      case MetalType.platinum:
        return 'Platinum';
      case MetalType.palladium:
        return 'Palladium';
    }
  }

  /// Get available purity options for this metal
  Map<String, double> get purities {
    switch (this) {
      case MetalType.gold:
        return PurityValues.gold;
      case MetalType.silver:
        return PurityValues.silver;
      case MetalType.platinum:
        return PurityValues.platinum;
      case MetalType.palladium:
        return PurityValues.palladium;
    }
  }

  /// Get the default purity for this metal
  String get defaultPurity {
    return purities.keys.first;
  }

  /// Get an icon color hint for this metal
  int get colorValue {
    switch (this) {
      case MetalType.gold:
        return 0xFFD4AF37; // Gold
      case MetalType.silver:
        return 0xFFC0C0C0; // Silver
      case MetalType.platinum:
        return 0xFFE5E4E2; // Platinum
      case MetalType.palladium:
        return 0xFFCED0DD; // Palladium
    }
  }
}

/// Weight units for input
enum WeightUnit {
  grams,
  ounces,
  kilograms,
}

/// Extension for weight unit conversions
extension WeightUnitExtension on WeightUnit {
  /// Get the display abbreviation
  String get abbreviation {
    switch (this) {
      case WeightUnit.grams:
        return 'g';
      case WeightUnit.ounces:
        return 'oz';
      case WeightUnit.kilograms:
        return 'kg';
    }
  }

  /// Get the display name
  String get displayName {
    switch (this) {
      case WeightUnit.grams:
        return 'Grams';
      case WeightUnit.ounces:
        return 'Ounces';
      case WeightUnit.kilograms:
        return 'Kilograms';
    }
  }

  /// Convert a weight in this unit to troy ounces
  double toTroyOunces(double weight) {
    switch (this) {
      case WeightUnit.grams:
        return weight * WeightConversions.gramsToTroyOz;
      case WeightUnit.ounces:
        return weight * WeightConversions.troyOzToTroyOz;
      case WeightUnit.kilograms:
        return weight * WeightConversions.kilogramsToTroyOz;
    }
  }
}
