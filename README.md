# MetalMetric 📊

A beautiful mineral price calculator built with Flutter. Track real-time prices for Gold, Silver, Platinum, and Palladium.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- 💰 **Real-time prices** for Gold, Silver, Platinum & Palladium
- ⚖️ **Weight calculator** with support for grams, ounces, and kilograms
- 💎 **Purity selection** (24K, 22K, 18K for gold, Sterling for silver, etc.)
- 💱 **Multi-currency** support (USD, EUR, GBP)
- 🌙 **Dark theme** with premium gold accents
- 📱 **Responsive design** for all screen sizes

## Screenshots

*Coming soon*

## Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart 3.x or higher

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/abdellatifaitbaali/MetalMetric.git
   cd MetalMetric
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## API

This app uses the [FreeGoldPrice API](https://freegoldprice.org) for real-time metal prices.

The API key is fetched automatically from `api_key.txt` in this repository, so you don't need to configure anything.

### Custom API Key

If you want to use your own API key:
1. Register at [freegoldprice.org](https://freegoldprice.org)
2. Go to **Settings** → **API Configuration** in the app
3. Enter your API key

## Project Structure

```
lib/
├── main.dart                     # App entry point
├── config/app_theme.dart         # Dark theme styling
├── models/                       # Data models
├── providers/                    # State management
├── screens/                      # UI screens
├── services/                     # API integration
└── utils/                        # Constants & helpers
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

---

Built with ❤️ using Flutter
