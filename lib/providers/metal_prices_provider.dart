import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/metal.dart';
import '../models/metal_price.dart';
import '../services/metal_price_service.dart';

/// Provider for managing metal prices state
class MetalPricesProvider extends ChangeNotifier {
  MetalPriceService? _service;
  MetalPricesResponse? _pricesResponse;
  Map<MetalType, double> _priceChanges = {};

  bool _isLoading = false;
  bool _isOffline = false;
  String? _error;
  DateTime? _lastUpdated;

  /// Current prices response
  MetalPricesResponse? get pricesResponse => _pricesResponse;

  /// Get price for a specific metal
  MetalPrice? getPrice(MetalType metal) => _pricesResponse?.prices[metal];

  /// Price changes by metal
  Map<MetalType, double> get priceChanges => _priceChanges;

  /// Whether prices are currently being fetched
  bool get isLoading => _isLoading;

  /// Whether device is offline
  bool get isOffline => _isOffline;

  /// Error message if fetch failed
  String? get error => _error;

  /// When prices were last updated
  DateTime? get lastUpdated => _lastUpdated;

  /// Whether we have prices data
  bool get hasPrices => _pricesResponse != null;

  /// Initialize the service with API key
  void initialize(String apiKey) {
    _service?.dispose();
    _service = MetalPriceService(apiKey: apiKey);
  }

  /// Fetch latest prices
  Future<void> fetchPrices({
    required String currency,
    bool forceRefresh = false,
  }) async {
    if (_service == null) {
      _error = 'Service not initialized. Please set your API key.';
      notifyListeners();
      return;
    }

    // Check connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _isOffline = true;
      if (!hasPrices) {
        _error = 'No internet connection. Please check your network.';
      }
      notifyListeners();
      return;
    }
    _isOffline = false;

    // Don't refetch if we have recent data (within 1 minute) unless forced
    if (!forceRefresh && _lastUpdated != null) {
      final age = DateTime.now().difference(_lastUpdated!);
      if (age.inMinutes < 1) {
        return;
      }
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch latest prices
      final prices = await _service!.getLatestPrices(baseCurrency: currency);
      _pricesResponse = prices;
      _lastUpdated = DateTime.now();

      // Try to fetch price changes (may fail on free tier)
      try {
        _priceChanges = await _service!.getPriceChanges(baseCurrency: currency);
      } catch (e) {
        // Price changes may not be available on all plans
        debugPrint('Could not fetch price changes: $e');
      }

      _error = null;
    } on MetalPriceApiException catch (e) {
      _error = e.message;
      // Keep old prices if available
    } catch (e) {
      _error = 'Failed to fetch prices: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get the change percentage for a metal
  double? getChangePercent(MetalType metal) {
    return _priceChanges[metal];
  }

  /// Clear all cached data
  void clearCache() {
    _pricesResponse = null;
    _priceChanges = {};
    _lastUpdated = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }
}
