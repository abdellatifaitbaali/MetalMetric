import 'metal.dart';

/// Represents the current price data for a metal
class MetalPrice {
  final MetalType metal;
  final double pricePerTroyOz;
  final double? changePercent;
  final DateTime timestamp;
  final String currency;

  const MetalPrice({
    required this.metal,
    required this.pricePerTroyOz,
    this.changePercent,
    required this.timestamp,
    required this.currency,
  });

  /// Create from API response
  factory MetalPrice.fromApiResponse({
    required MetalType metal,
    required double rate,
    required String currency,
    required int timestamp,
    double? changePercent,
  }) {
    // API returns rate as currency per 1 oz of metal
    // e.g., 1 XAU = 1856.90 USD means gold is $1856.90/oz
    return MetalPrice(
      metal: metal,
      pricePerTroyOz: rate,
      changePercent: changePercent,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
      currency: currency,
    );
  }

  /// Calculate the value of a given weight and purity
  double calculateValue({
    required double weightInTroyOz,
    required double purity,
  }) {
    return weightInTroyOz * pricePerTroyOz * purity;
  }

  /// Create a copy with updated fields
  MetalPrice copyWith({
    MetalType? metal,
    double? pricePerTroyOz,
    double? changePercent,
    DateTime? timestamp,
    String? currency,
  }) {
    return MetalPrice(
      metal: metal ?? this.metal,
      pricePerTroyOz: pricePerTroyOz ?? this.pricePerTroyOz,
      changePercent: changePercent ?? this.changePercent,
      timestamp: timestamp ?? this.timestamp,
      currency: currency ?? this.currency,
    );
  }

  @override
  String toString() {
    return 'MetalPrice(${metal.displayName}: $pricePerTroyOz $currency/oz, change: $changePercent%)';
  }
}

/// Response from the API containing multiple metal prices
class MetalPricesResponse {
  final Map<MetalType, MetalPrice> prices;
  final DateTime fetchedAt;
  final bool isFromCache;

  const MetalPricesResponse({
    required this.prices,
    required this.fetchedAt,
    this.isFromCache = false,
  });

  /// Get price for a specific metal
  MetalPrice? getPrice(MetalType metal) => prices[metal];

  /// Check if we have prices for all metals
  bool get hasAllPrices => prices.length == MetalType.values.length;
}
