import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'providers/calculator_provider.dart';
import 'providers/metal_prices_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/calculator_screen.dart';
import 'screens/live_markets_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const MetalMetricApp());
}

/// Main application widget
class MetalMetricApp extends StatelessWidget {
  const MetalMetricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => MetalPricesProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
      ],
      child: MaterialApp(
        title: 'MetalMetric',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainScreen(),
      ),
    );
  }
}

/// Main screen with bottom navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CalculatorScreen(),
    LiveMarketsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize api and fetch prices after settings are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePrices();
    });
  }

  Future<void> _initializePrices() async {
    // Wait a moment for settings to load
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final settings = context.read<SettingsProvider>();
    final pricesProvider = context.read<MetalPricesProvider>();

    // Initialize with API key
    pricesProvider.initialize(settings.apiKey);

    // Fetch initial prices
    await pricesProvider.fetchPrices(currency: settings.selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate),
              label: 'Calculator',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_outlined),
              activeIcon: Icon(Icons.trending_up),
              label: 'Live Markets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
