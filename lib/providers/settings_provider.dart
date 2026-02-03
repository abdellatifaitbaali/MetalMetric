import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Provider for managing user settings
class SettingsProvider extends ChangeNotifier {
  static const String _currencyKey = 'selected_currency';
  static const String _apiKeyKey = 'api_key';
  static const String _remoteApiKeyKey = 'remote_api_key';

  SharedPreferences? _prefs;
  String _selectedCurrency = SupportedCurrencies.usd;
  String _apiKey = ApiConfig.fallbackApiKey;
  String _remoteApiKey = ApiConfig.fallbackApiKey;
  bool _isLoading = true;

  SettingsProvider() {
    _loadSettings();
  }

  /// Current selected currency
  String get selectedCurrency => _selectedCurrency;

  /// Current API key (user custom or remote)
  String get apiKey => _apiKey;

  /// Whether settings are being loaded
  bool get isLoading => _isLoading;

  /// Whether user has set a custom API key
  bool get hasCustomApiKey {
    final stored = _prefs?.getString(_apiKeyKey);
    return stored != null && stored.isNotEmpty && stored != _remoteApiKey;
  }

  /// Currency symbol for display
  String get currencySymbol =>
      SupportedCurrencies.symbols[_selectedCurrency] ?? '\$';

  /// Load settings from persistent storage and fetch remote API key
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _selectedCurrency =
        _prefs?.getString(_currencyKey) ?? SupportedCurrencies.usd;

    // Load cached remote API key
    _remoteApiKey =
        _prefs?.getString(_remoteApiKeyKey) ?? ApiConfig.fallbackApiKey;

    // Load user's custom API key, or use remote/fallback
    _apiKey = _prefs?.getString(_apiKeyKey) ?? _remoteApiKey;

    _isLoading = false;
    notifyListeners();

    // Fetch latest remote API key in background
    _fetchRemoteApiKey();
  }

  /// Fetch the latest API key from the remote URL
  Future<void> _fetchRemoteApiKey() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.remoteApiKeyUrl));
      if (response.statusCode == 200) {
        final newKey = response.body.trim();
        if (newKey.isNotEmpty && newKey != _remoteApiKey) {
          _remoteApiKey = newKey;
          await _prefs?.setString(_remoteApiKeyKey, newKey);

          // If user hasn't set a custom key, update the active key
          if (!hasCustomApiKey) {
            _apiKey = newKey;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      // Silently fail - we'll use cached or fallback key
      debugPrint('Failed to fetch remote API key: $e');
    }
  }

  /// Update selected currency
  Future<void> setCurrency(String currency) async {
    if (!SupportedCurrencies.all.contains(currency)) return;

    _selectedCurrency = currency;
    await _prefs?.setString(_currencyKey, currency);
    notifyListeners();
  }

  /// Update API key
  Future<void> setApiKey(String apiKey) async {
    _apiKey = apiKey.isEmpty ? _remoteApiKey : apiKey;
    await _prefs?.setString(_apiKeyKey, _apiKey);
    notifyListeners();
  }

  /// Reset settings to defaults
  Future<void> resetSettings() async {
    _selectedCurrency = SupportedCurrencies.usd;
    _apiKey = _remoteApiKey;
    await _prefs?.remove(_currencyKey);
    await _prefs?.remove(_apiKeyKey);
    notifyListeners();
  }
}
