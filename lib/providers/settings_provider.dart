import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Provider for managing user settings
class SettingsProvider extends ChangeNotifier {
  static const String _currencyKey = 'selected_currency';
  static const String _apiKeyKey = 'api_key';

  SharedPreferences? _prefs;
  String _selectedCurrency = SupportedCurrencies.usd;
  String _apiKey = ApiConfig.defaultApiKey;
  bool _isLoading = true;

  SettingsProvider() {
    _loadSettings();
  }

  /// Current selected currency
  String get selectedCurrency => _selectedCurrency;

  /// Current API key
  String get apiKey => _apiKey;

  /// Whether settings are being loaded
  bool get isLoading => _isLoading;

  /// Whether user has set a custom API key
  bool get hasCustomApiKey => _apiKey != ApiConfig.defaultApiKey;

  /// Currency symbol for display
  String get currencySymbol =>
      SupportedCurrencies.symbols[_selectedCurrency] ?? '\$';

  /// Load settings from persistent storage
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _selectedCurrency =
        _prefs?.getString(_currencyKey) ?? SupportedCurrencies.usd;
    _apiKey = _prefs?.getString(_apiKeyKey) ?? ApiConfig.defaultApiKey;
    _isLoading = false;
    notifyListeners();
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
    _apiKey = apiKey.isEmpty ? ApiConfig.defaultApiKey : apiKey;
    await _prefs?.setString(_apiKeyKey, _apiKey);
    notifyListeners();
  }

  /// Reset settings to defaults
  Future<void> resetSettings() async {
    _selectedCurrency = SupportedCurrencies.usd;
    _apiKey = ApiConfig.defaultApiKey;
    await _prefs?.remove(_currencyKey);
    await _prefs?.remove(_apiKeyKey);
    notifyListeners();
  }
}
