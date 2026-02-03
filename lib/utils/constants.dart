/// Metal symbols for display (ISO 4217 style)
class MetalSymbols {
  static const String gold = 'XAU';
  static const String silver = 'XAG';
  static const String platinum = 'XPT';
  static const String palladium = 'XPD';

  static const List<String> all = [gold, silver, platinum, palladium];
}

/// Purity values for different metals
class PurityValues {
  /// Gold karat purities (karat -> decimal)
  static const Map<String, double> gold = {
    '24K': 1.0,
    '22K': 0.9167,
    '18K': 0.75,
    '14K': 0.5833,
    '10K': 0.4167,
  };

  /// Silver purities
  static const Map<String, double> silver = {
    '.999 Fine': 0.999,
    '.925 Sterling': 0.925,
    '.900 Coin': 0.90,
    '.800': 0.80,
  };

  /// Platinum purities
  static const Map<String, double> platinum = {
    '99.95%': 0.9995,
    '95%': 0.95,
    '90%': 0.90,
  };

  /// Palladium purities
  static const Map<String, double> palladium = {
    '99.95%': 0.9995,
    '95%': 0.95,
    '90%': 0.90,
  };
}

/// Weight unit conversion factors to troy ounces
class WeightConversions {
  /// 1 gram = 0.0321507 troy ounces
  static const double gramsToTroyOz = 0.0321507;

  /// 1 kilogram = 32.1507 troy ounces
  static const double kilogramsToTroyOz = 32.1507;

  /// 1 avoirdupois ounce = 0.911458 troy ounces
  static const double ozToTroyOz = 0.911458;

  /// Troy ounce to troy ounce (identity)
  static const double troyOzToTroyOz = 1.0;
}

/// Supported currencies
class SupportedCurrencies {
  static const String usd = 'USD';
  static const String eur = 'EUR';
  static const String gbp = 'GBP';

  static const List<String> all = [usd, eur, gbp];

  static const Map<String, String> symbols = {
    usd: '\$',
    eur: '€',
    gbp: '£',
  };
}

/// API Configuration for FreeGoldPrice API V2
class ApiConfig {
  static const String baseUrl = 'https://freegoldprice.org/api/v2';

  /// Action code for all metals (Gold, Silver, Platinum, Palladium) in JSON
  static const String action = 'GSPPJ';

  /// Default API key - user should replace with their own key
  static const String defaultApiKey =
      'N4AwbZJ3w3RTPKL4fnH92vOAbw4uH0SnE8cp9aWIgqZ6qOaglOmb4RUpMVjk';
}
