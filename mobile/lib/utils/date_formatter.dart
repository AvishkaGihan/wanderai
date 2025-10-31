import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    // Logic for relative time (e.g., "5m ago", "Yesterday")
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(date);
    }
  }

  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${DateFormat('MMM dd').format(start)} - ${DateFormat('dd, yyyy').format(end)}';
    }
    return '${formatDate(start)} - ${formatDate(end)}';
  }
}
