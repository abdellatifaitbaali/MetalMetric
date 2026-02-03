import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';
import '../providers/metal_prices_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _showApiKey = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current API key
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = context.read<SettingsProvider>();
      if (settings.hasCustomApiKey) {
        _apiKeyController.text = settings.apiKey;
      }
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryGold,
                    ),
              ),
              const SizedBox(height: 24),

              // Currency Selection
              _buildSectionHeader(context, 'Currency'),
              const SizedBox(height: 12),
              _buildCurrencySelector(settings),
              const SizedBox(height: 24),

              // API Key
              _buildSectionHeader(context, 'API Configuration'),
              const SizedBox(height: 12),
              _buildApiKeySection(settings),
              const SizedBox(height: 24),

              // Data Management Section
              _buildSectionHeader(context, 'Data Management'),
              const SizedBox(height: 12),
              _buildDataManagementSection(settings),
              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader(context, 'About'),
              const SizedBox(height: 12),
              _buildAboutSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
    );
  }

  Widget _buildCurrencySelector(SettingsProvider settings) {
    return Card(
      child: Column(
        children: SupportedCurrencies.all.map((currency) {
          final isSelected = settings.selectedCurrency == currency;
          final symbol = SupportedCurrencies.symbols[currency] ?? '';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? AppTheme.primaryGold.withValues(alpha: 0.2)
                  : AppTheme.surfaceColor,
              child: Text(
                symbol,
                style: TextStyle(
                  color: isSelected
                      ? AppTheme.primaryGold
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(currency),
            subtitle: Text(_getCurrencyName(currency)),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppTheme.primaryGold)
                : null,
            onTap: () async {
              await settings.setCurrency(currency);
              if (context.mounted) {
                // Refresh prices with new currency
                final pricesProvider = context.read<MetalPricesProvider>();
                await pricesProvider.fetchPrices(
                  currency: currency,
                  forceRefresh: true,
                );
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApiKeySection(SettingsProvider settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  settings.hasCustomApiKey
                      ? Icons.vpn_key
                      : Icons.warning_amber_rounded,
                  color: settings.hasCustomApiKey
                      ? AppTheme.successGreen
                      : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  settings.hasCustomApiKey ? 'API Key Set' : 'No API Key',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Get your free API key from metalpriceapi.com',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              obscureText: !_showApiKey,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'Enter your API key',
                prefixIcon: const Icon(Icons.key),
                suffixIcon: IconButton(
                  icon: Icon(
                      _showApiKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _showApiKey = !_showApiKey;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final apiKey = _apiKeyController.text.trim();
                      await settings.setApiKey(apiKey);

                      if (context.mounted) {
                        // Reinitialize prices provider with new key
                        final pricesProvider =
                            context.read<MetalPricesProvider>();
                        pricesProvider.initialize(
                            apiKey.isEmpty ? ApiConfig.fallbackApiKey : apiKey);
                        await pricesProvider.fetchPrices(
                          currency: settings.selectedCurrency,
                          forceRefresh: true,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('API key saved'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryGold),
                    ),
                    child: const Text('Save Key'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    _apiKeyController.clear();
                    settings.setApiKey('');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppTheme.errorRed.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                        color: AppTheme.errorRed.withValues(alpha: 0.8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementSection(SettingsProvider settings) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: AppTheme.errorRed.withValues(alpha: 0.8),
            ),
            title: const Text('Delete All Data'),
            subtitle: const Text('Clear all cached prices and settings'),
            trailing: Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
            onTap: () => _showDeleteConfirmation(settings),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(SettingsProvider settings) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will clear all cached prices, settings, and your custom API key. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await settings.resetSettings();
      _apiKeyController.clear();

      final pricesProvider = context.read<MetalPricesProvider>();
      pricesProvider.clearCache();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data deleted'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGold, AppTheme.secondaryGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.insert_chart,
                color: AppTheme.darkBackground,
              ),
            ),
            title: const Text('MetalMetric'),
            subtitle: const Text('Version 1.0.0'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline, color: AppTheme.textSecondary),
            title: Text('Mineral Price Calculator'),
            subtitle:
                Text('Calculate real-time market value of precious metals'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.api, color: AppTheme.textSecondary),
            title: const Text('Powered by'),
            subtitle: const Text('FreeGoldPrice API'),
            trailing: const Icon(Icons.open_in_new,
                size: 16, color: AppTheme.textSecondary),
            onTap: () => _launchUrl('https://freegoldprice.org'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined,
                color: AppTheme.textSecondary),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new,
                size: 16, color: AppTheme.textSecondary),
            onTap: () => _launchUrl(
                'https://metalmetric.nexodev.site/privacy-policy.html'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined,
                color: AppTheme.textSecondary),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new,
                size: 16, color: AppTheme.textSecondary),
            onTap: () => _launchUrl(
                'https://metalmetric.nexodev.site/terms-of-service.html'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'USD':
        return 'United States Dollar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'British Pound Sterling';
      default:
        return code;
    }
  }
}
