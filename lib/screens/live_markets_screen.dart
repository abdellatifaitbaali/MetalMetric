import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/metal.dart';
import '../providers/metal_prices_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';

/// Live Markets screen showing current metal prices and changes
class LiveMarketsScreen extends StatelessWidget {
  const LiveMarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MetalPricesProvider, SettingsProvider>(
      builder: (context, prices, settings, child) {
        return RefreshIndicator(
          onRefresh: () => prices.fetchPrices(
            currency: settings.selectedCurrency,
            forceRefresh: true,
          ),
          color: AppTheme.primaryGold,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Markets',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppTheme.primaryGold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pull to refresh prices',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Status indicators
              if (prices.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGold,
                      ),
                    ),
                  ),
                ),

              if (prices.isOffline)
                SliverToBoxAdapter(
                  child: _buildStatusBanner(
                    context,
                    icon: Icons.wifi_off,
                    message: 'Offline - Showing cached data',
                    color: Colors.orange,
                  ),
                ),

              if (prices.error != null && !prices.hasPrices)
                SliverToBoxAdapter(
                  child: _buildStatusBanner(
                    context,
                    icon: Icons.error_outline,
                    message: prices.error!,
                    color: AppTheme.errorRed,
                  ),
                ),

              // Metal price cards
              if (prices.hasPrices)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final metal = MetalType.values[index];
                        final price = prices.getPrice(metal);
                        final change = prices.getChangePercent(metal);

                        if (price == null) return const SizedBox.shrink();

                        return _MetalPriceCard(
                          metal: metal,
                          pricePerOz: price.pricePerTroyOz,
                          changePercent: change,
                          currency: settings.selectedCurrency,
                        );
                      },
                      childCount: MetalType.values.length,
                    ),
                  ),
                ),

              // Last updated
              if (prices.lastUpdated != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Last updated: ${formatTimeAgo(prices.lastUpdated!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBanner(
    BuildContext context, {
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card widget for displaying a single metal price
class _MetalPriceCard extends StatelessWidget {
  final MetalType metal;
  final double pricePerOz;
  final double? changePercent;
  final String currency;

  const _MetalPriceCard({
    required this.metal,
    required this.pricePerOz,
    this.changePercent,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final metalColor = Color(metal.colorValue);
    final isPositive = (changePercent ?? 0) >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Metal icon/indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: metalColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  metal.symbol.substring(1), // AU, AG, PT, etc.
                  style: TextStyle(
                    color: metalColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Metal name and symbol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metal.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    metal.symbol,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),

            // Price and change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(pricePerOz, currency),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: metalColor,
                      ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (changePercent != null) ...[
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 14,
                        color: isPositive
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        formatPercentage(changePercent),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isPositive
                                  ? AppTheme.successGreen
                                  : AppTheme.errorRed,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ] else
                      Text(
                        'per oz',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
