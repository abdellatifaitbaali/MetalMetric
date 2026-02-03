import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/metal.dart';
import '../models/metal_price.dart';
import '../utils/constants.dart';

/// Exception thrown when API request fails
class MetalPriceApiException implements Exception {
  final String message;
  final int? statusCode;

  MetalPriceApiException(this.message, {this.statusCode});

  @override
  String toString() => 'MetalPriceApiException: $message (status: $statusCode)';
}

/// Service for fetching metal prices from FreeGoldPrice API V2
class MetalPriceService {
  final String _apiKey;
  final http.Client _client;

  MetalPriceService({
    required String apiKey,
    http.Client? client,
  })  : _apiKey = apiKey,
        _client = client ?? http.Client();

  /// Fetch latest metal prices
  /// FreeGoldPrice API returns all currencies in one response
  Future<MetalPricesResponse> getLatestPrices({
    String baseCurrency = 'USD',
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}?key=$_apiKey&action=${ApiConfig.action}',
    );

    try {
      final response = await _client.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw MetalPriceApiException(
          'API request failed',
          statusCode: response.statusCode,
        );
      }

      final rawData = jsonDecode(response.body) as Map<String, dynamic>;

      // Check for error response
      if (rawData.containsKey('error')) {
        throw MetalPriceApiException(
          rawData['error']?.toString() ?? 'Unknown API error',
        );
      }

      // Unwrap the GSPPJ wrapper
      final data = rawData['GSPPJ'] as Map<String, dynamic>? ?? rawData;

      // Parse timestamp - format: "2026-02-03 14:27:00"
      final dateStr = data['date'] as String?;
      int timestamp;
      if (dateStr != null) {
        // Handle the date format "YYYY-MM-DD HH:MM:SS"
        final parsed = DateTime.tryParse(dateStr.replaceAll(' ', 'T'));
        timestamp = (parsed?.millisecondsSinceEpoch ??
                DateTime.now().millisecondsSinceEpoch) ~/
            1000;
      } else {
        timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }

      final prices = <MetalType, MetalPrice>{};

      // Metal keys are capitalized in the API response
      final metalKeyMap = {
        MetalType.gold: 'Gold',
        MetalType.silver: 'Silver',
        MetalType.platinum: 'Platinum',
        MetalType.palladium: 'Palladium',
      };

      for (final metalType in MetalType.values) {
        final metalKey = metalKeyMap[metalType]!;
        final metalData = data[metalKey] as Map<String, dynamic>?;

        if (metalData != null) {
          final currencyData = metalData[baseCurrency] as Map<String, dynamic>?;

          if (currencyData != null) {
            // Use 'ask' price as the primary price
            final askPrice = currencyData['ask'];
            if (askPrice != null) {
              final pricePerOz = (askPrice is num)
                  ? askPrice.toDouble()
                  : double.tryParse(askPrice.toString()) ?? 0.0;

              prices[metalType] = MetalPrice.fromApiResponse(
                metal: metalType,
                rate: pricePerOz,
                currency: baseCurrency,
                timestamp: timestamp,
              );
            }
          }
        }
      }

      if (prices.isEmpty) {
        throw MetalPriceApiException('No price data in API response');
      }

      return MetalPricesResponse(
        prices: prices,
        fetchedAt: DateTime.now(),
      );
    } on http.ClientException catch (e) {
      throw MetalPriceApiException('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw MetalPriceApiException('Invalid response format: ${e.message}');
    } catch (e) {
      if (e is MetalPriceApiException) rethrow;
      throw MetalPriceApiException('Unexpected error: $e');
    }
  }

  /// Fetch price changes for metals
  /// Note: FreeGoldPrice API doesn't provide change data, returning empty map
  Future<Map<MetalType, double>> getPriceChanges({
    String baseCurrency = 'USD',
  }) async {
    // FreeGoldPrice API doesn't provide price change data
    return {};
  }

  /// Dispose of resources
  void dispose() {
    _client.close();
  }
}
