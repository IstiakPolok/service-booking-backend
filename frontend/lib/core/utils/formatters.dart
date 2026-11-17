import 'package:intl/intl.dart';

class Formatters {
  static String currency(num amount) {
    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return format.format(amount);
  }

  static String currencyCompact(num amount) {
    if (amount % 1 == 0) {
      return '\$${amount.toInt()}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  static String duration(int minutes) {
    if (minutes < 60) {
      return '$minutes mins';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours hr${hours > 1 ? 's' : ''}';
    }
    return '$hours hr $remainingMinutes mins';
  }

  static String formatDate(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('EEE, MMM d, yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatDateShort(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }
}
