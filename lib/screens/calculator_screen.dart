import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/metal.dart';
import '../models/metal_price.dart';
import '../providers/calculator_provider.dart';
import '../providers/metal_prices_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';

/// Calculator screen for calculating metal values
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CalculatorProvider, MetalPricesProvider, SettingsProvider>(
      builder: (context, calculator, prices, settings, child) {
        final currentPrice = prices.getPrice(calculator.selectedMetal);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Calculate Value',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryGold,
                    ),
              ),
              const SizedBox(height: 24),

              // Metal Selection
              _buildMetalSelector(calculator),
              const SizedBox(height: 20),

              // Weight Input
              _buildWeightInput(calculator),
              const SizedBox(height: 16),

              // Unit Toggle
              _buildUnitToggle(calculator),
              const SizedBox(height: 20),

              // Purity Dropdown
              _buildPurityDropdown(calculator),
              const SizedBox(height: 24),

              // Calculate Button
              _buildCalculateButton(calculator, currentPrice),
              const SizedBox(height: 24),

              // Result Display
              if (calculator.calculatedValue != null)
                _buildResultCard(calculator, settings),

              // Current Price Info
              if (currentPrice != null)
                _buildPriceInfoCard(currentPrice, prices),

              // Last Updated
              if (prices.lastUpdated != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      'Last updated: ${formatTimeAgo(prices.lastUpdated!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetalSelector(CalculatorProvider calculator) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Metal',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MetalType.values.map((metal) {
                final isSelected = calculator.selectedMetal == metal;
                return ChoiceChip(
                  label: Text(metal.displayName),
                  selected: isSelected,
                  onSelected: (_) => calculator.setMetal(metal),
                  selectedColor: Color(metal.colorValue).withValues(alpha: 0.3),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Color(metal.colorValue)
                        : AppTheme.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? Color(metal.colorValue)
                        : AppTheme.dividerColor,
                  ),
                  backgroundColor: AppTheme.surfaceColor,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightInput(CalculatorProvider calculator) {
    return TextField(
      controller: _weightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Weight',
        hintText: 'Enter weight',
        suffixText: calculator.weightUnit.abbreviation,
        prefixIcon: const Icon(Icons.scale),
      ),
      onChanged: (value) {
        final weight = double.tryParse(value) ?? 0;
        calculator.setWeight(weight);
      },
    );
  }

  Widget _buildUnitToggle(CalculatorProvider calculator) {
    return SegmentedButton<WeightUnit>(
      segments: WeightUnit.values.map((unit) {
        return ButtonSegment<WeightUnit>(
          value: unit,
          label: Text(unit.abbreviation),
        );
      }).toList(),
      selected: {calculator.weightUnit},
      onSelectionChanged: (selection) {
        calculator.setWeightUnit(selection.first);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTheme.primaryGold.withValues(alpha: 0.2);
          }
          return AppTheme.surfaceColor;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTheme.primaryGold;
          }
          return AppTheme.textSecondary;
        }),
      ),
    );
  }

  Widget _buildPurityDropdown(CalculatorProvider calculator) {
    final purities = calculator.purityOptions;

    return DropdownButtonFormField<String>(
      value: calculator.selectedPurity,
      decoration: const InputDecoration(
        labelText: 'Purity',
        prefixIcon: Icon(Icons.diamond_outlined),
      ),
      dropdownColor: AppTheme.cardBackground,
      items: purities.keys.map((purity) {
        final decimal = purities[purity]!;
        return DropdownMenuItem<String>(
          value: purity,
          child: Text('$purity (${(decimal * 100).toStringAsFixed(1)}%)'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          calculator.setPurity(value);
        }
      },
    );
  }

  Widget _buildCalculateButton(
      CalculatorProvider calculator, MetalPrice? currentPrice) {
    return ElevatedButton.icon(
      onPressed: currentPrice != null && calculator.weight > 0
          ? () => calculator.calculate(currentPrice)
          : null,
      icon: const Icon(Icons.calculate),
      label: const Text('Calculate Value'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildResultCard(
      CalculatorProvider calculator, SettingsProvider settings) {
    return Card(
      color: AppTheme.primaryGold.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Estimated Value',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(
                  calculator.calculatedValue!, settings.selectedCurrency),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${calculator.weight} ${calculator.weightUnit.abbreviation} of ${calculator.selectedPurity} ${calculator.selectedMetal.displayName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInfoCard(MetalPrice price, MetalPricesProvider prices) {
    final changePercent = prices.getChangePercent(price.metal);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spot Price',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  formatCurrency(price.pricePerTroyOz, price.currency),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Color(price.metal.colorValue),
                      ),
                ),
                Text(
                  'per troy oz',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
            if (changePercent != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (changePercent >= 0
                          ? AppTheme.successGreen
                          : AppTheme.errorRed)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      changePercent >= 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 16,
                      color: changePercent >= 0
                          ? AppTheme.successGreen
                          : AppTheme.errorRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatPercentage(changePercent),
                      style: TextStyle(
                        color: changePercent >= 0
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
