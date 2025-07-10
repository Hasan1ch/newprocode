import 'package:intl/intl.dart';

/// Centralized formatting utilities for consistent data presentation
/// This class ensures all numbers, dates, and strings are formatted
/// uniformly across the entire application
class Formatters {
  // Number Formatters - Used throughout the app for XP, scores, etc.

  /// Formats integers with thousand separators
  /// Example: 1234567 → "1,234,567"
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  /// Formats decimals to specified precision
  /// Used for percentage displays and calculations
  static String formatDecimal(double number, {int decimals = 2}) {
    return number.toStringAsFixed(decimals);
  }

  /// Formats currency values with proper symbol and decimals
  /// Currently using USD, but extensible for other currencies
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return NumberFormat.currency(symbol: symbol, decimalDigits: 2)
        .format(amount);
  }

  /// Converts decimal to percentage string
  /// Example: 0.856 → "85.6%"
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  /// Formats large numbers in compact notation
  /// Used in leaderboards: 1500 → "1.5K", 2000000 → "2.0M"
  static String formatCompactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Date and Time Formatters - Consistent date display across the app

  /// Standard date format for course dates
  /// Example: "Jan 15, 2024"
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Short date format for compact displays
  /// Example: "Jan 15"
  static String formatDateShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  /// Full date with day name for detailed views
  /// Example: "Monday, January 15, 2024"
  static String formatDateFull(DateTime date) {
    return DateFormat('EEEE, MMMM dd, yyyy').format(date);
  }

  /// 12-hour time format for user-friendly display
  /// Example: "3:45 PM"
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  /// 24-hour time format for international users
  /// Example: "15:45"
  static String formatTime24(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Combined date and time for timestamps
  /// Example: "Jan 15, 2024 • 3:45 PM"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  /// Human-readable relative time
  /// Creates friendly timestamps like "2 hours ago"
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Formats duration for lesson/course lengths
  /// Shows most relevant units: "2h 30m" or "45m 30s"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Verbose duration format for accessibility
  /// Example: "2 hours 30 minutes"
  static String formatDurationLong(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];

    if (hours > 0) {
      parts.add('$hours hour${hours > 1 ? 's' : ''}');
    }
    if (minutes > 0) {
      parts.add('$minutes minute${minutes > 1 ? 's' : ''}');
    }
    if (seconds > 0 || parts.isEmpty) {
      parts.add('$seconds second${seconds > 1 ? 's' : ''}');
    }

    return parts.join(' ');
  }

  // String Formatters - User input and display formatting

  /// Formats phone numbers for display
  /// Handles US format: (123) 456-7890
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Format based on length
    if (digits.length == 10) {
      // US format: (123) 456-7890
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      // US format with country code: +1 (123) 456-7890
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }

    return phoneNumber;
  }

  /// Formats credit card numbers with spacing
  /// Example: "1234 5678 9012 3456"
  static String formatCreditCard(String cardNumber) {
    // Remove all non-digit characters
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');

    // Add spaces every 4 digits
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }

  /// Masks credit card for security display
  /// Shows only last 4 digits: "**** **** **** 3456"
  static String maskCreditCard(String cardNumber) {
    // Remove all non-digit characters
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 8) {
      return cardNumber;
    }

    // Show only last 4 digits
    final masked =
        '*' * (digits.length - 4) + digits.substring(digits.length - 4);
    return formatCreditCard(masked);
  }

  /// Formats file sizes in human-readable units
  /// Used for course resource downloads
  static String formatFileSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Truncates long text with ellipsis
  /// Essential for course descriptions in card views
  static String truncateText(String text, int maxLength,
      {String suffix = '...'}) {
    if (text.length <= maxLength) {
      return text;
    }

    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Capitalizes first letter of string
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitalizes each word in string
  /// Used for proper formatting of names and titles
  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalizeFirst(word)).join(' ');
  }

  // XP and Gamification Formatters - Specific to our app's features

  /// Formats XP with proper notation
  /// Example: 1500 → "1.5K XP"
  static String formatXP(int xp) {
    return '${formatCompactNumber(xp)} XP';
  }

  /// Formats user level display
  static String formatLevel(int level) {
    return 'Level $level';
  }

  /// Formats streak with proper pluralization
  static String formatStreak(int days) {
    if (days == 0) {
      return 'No streak';
    } else if (days == 1) {
      return '1 day streak';
    } else {
      return '$days day streak';
    }
  }

  /// Formats leaderboard rankings with ordinals
  /// 1 → "1st", 2 → "2nd", 3 → "3rd", 4 → "4th"
  static String formatRank(int rank) {
    if (rank == 1) return '1st';
    if (rank == 2) return '2nd';
    if (rank == 3) return '3rd';
    if (rank >= 4 && rank <= 20) return '${rank}th';

    final lastDigit = rank % 10;
    final lastTwoDigits = rank % 100;

    // Special case for 11th, 12th, 13th
    if (lastTwoDigits >= 11 && lastTwoDigits <= 13) {
      return '${rank}th';
    }

    switch (lastDigit) {
      case 1:
        return '${rank}st';
      case 2:
        return '${rank}nd';
      case 3:
        return '${rank}rd';
      default:
        return '${rank}th';
    }
  }

  // Code and Course Formatters - Educational content specific

  /// Maps language codes to full names
  /// Used in code editor language selector
  static String formatCodeLanguage(String language) {
    final languageMap = {
      'js': 'JavaScript',
      'ts': 'TypeScript',
      'py': 'Python',
      'java': 'Java',
      'cpp': 'C++',
      'c': 'C',
      'cs': 'C#',
      'rb': 'Ruby',
      'go': 'Go',
      'rs': 'Rust',
      'php': 'PHP',
      'swift': 'Swift',
      'kt': 'Kotlin',
      'dart': 'Dart',
      'html': 'HTML',
      'css': 'CSS',
      'sql': 'SQL',
    };

    return languageMap[language.toLowerCase()] ?? language;
  }

  /// Formats course duration from minutes
  /// Example: 90 → "1 hour 30 min"
  static String formatCourseDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    }

    return '$hours hour${hours > 1 ? 's' : ''} $remainingMinutes min';
  }

  /// Formats module count with proper pluralization
  static String formatModuleCount(int count) {
    if (count == 1) {
      return '1 module';
    }
    return '$count modules';
  }

  /// Formats lesson count with proper pluralization
  static String formatLessonCount(int count) {
    if (count == 1) {
      return '1 lesson';
    }
    return '$count lessons';
  }

  /// Formats quiz scores as fractions
  /// Example: "8 / 10"
  static String formatQuizScore(int correct, int total) {
    return '$correct / $total';
  }

  /// Formats completion percentage
  /// Example: 0.75 → "75% Complete"
  static String formatCompletionRate(double rate) {
    return '${(rate * 100).toStringAsFixed(0)}% Complete';
  }
}
