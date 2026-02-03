import 'package:intl/intl.dart';
import '../utils/constants.dart';

/// Format a number as currency
String formatCurrency(double value, String currencyCode) {
  final symbol = SupportedCurrencies.symbols[currencyCode] ?? currencyCode;
  final formatter = NumberFormat.currency(
    symbol: symbol,
    decimalDigits: 2,
  );
  return formatter.format(value);
}

/// Format a percentage change
String formatPercentage(double? value) {
  if (value == null) return '--';
  final sign = value >= 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(2)}%';
}

/// Format a weight value with unit
String formatWeight(double value, String unit) {
  if (value == value.roundToDouble()) {
    return '${value.round()} $unit';
  }
  return '${value.toStringAsFixed(2)} $unit';
}

/// Format a timestamp for display
String formatTimestamp(DateTime timestamp) {
  final formatter = DateFormat('MMM d, yyyy HH:mm');
  return formatter.format(timestamp);
}

/// Format time ago for "Last updated" display
String formatTimeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    final mins = difference.inMinutes;
    return '$mins ${mins == 1 ? 'minute' : 'minutes'} ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  } else {
    return formatTimestamp(timestamp);
  }
}

/// Format a large number with abbreviations (K, M, B)
String formatCompactNumber(double value) {
  final formatter = NumberFormat.compact();
  return formatter.format(value);
}
