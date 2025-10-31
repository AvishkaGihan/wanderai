import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String currency = 'USD'}) {
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, {String currency = 'USD'}) {
    // Show amounts greater than 1 million or 1 thousand concisely
    if (amount >= 1000000) {
      return '${_getCurrencySymbol(currency)}${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${_getCurrencySymbol(currency)}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, currency: currency);
  }

  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        // Use the currency code itself if the symbol is unknown
        return currency;
    }
  }
}
