class TimeUtils {
  /// Formats seconds to human-readable duration (e.g., "1h 30m" or "45m")
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Formats a date string to relative time (e.g., "2 days ago")
  static String formatRelativeDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = difference.inDays ~/ 7;
        return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
      } else if (difference.inDays < 365) {
        final months = difference.inDays ~/ 30;
        return '$months ${months == 1 ? 'month' : 'months'} ago';
      } else {
        final years = difference.inDays ~/ 365;
        return '$years ${years == 1 ? 'year' : 'years'} ago';
      }
    } catch (e) {
      return dateString;
    }
  }
}
