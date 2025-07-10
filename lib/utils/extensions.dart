import 'package:flutter/material.dart';

/// Extension methods add functionality to existing Dart classes
/// This file contains utility extensions that make common operations more concise
/// Using extensions improves code readability throughout the app

// String Extensions - Common string manipulations
extension StringExtensions on String {
  /// Capitalizes the first letter of a string
  /// Used for formatting user names and titles
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes each word in a string
  /// Perfect for formatting course titles and display names
  String get capitalizeWords {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Converts camelCase or PascalCase to readable title case
  /// Useful for displaying enum values in the UI
  String get toTitleCase {
    return replaceAllMapped(
      RegExp(
          r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
      (Match match) {
        return '${match[0]!.capitalize} ';
      },
    ).trim();
  }

  /// Email validation using RFC-compliant regex
  /// Critical for user registration and profile updates
  bool get isEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// URL validation for link inputs
  /// Used in course resources and external links
  bool get isURL {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    return urlRegex.hasMatch(this);
  }

  /// Phone number validation with international format support
  /// Used in user profiles for contact information
  bool get isPhoneNumber {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    return phoneRegex.hasMatch(this) && length >= 10;
  }

  /// Checks if string contains only numbers
  /// Useful for OTP and verification code inputs
  bool get isNumeric {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  /// Checks if string contains only letters
  /// Used for name validation
  bool get isAlpha {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  /// Checks if string contains only letters and numbers
  /// Used for username validation
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  /// Removes all whitespace from string
  /// Useful for comparing user inputs
  String get removeAllWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Truncates long strings with ellipsis
  /// Essential for UI text that might overflow
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Converts string to URL-friendly slug
  /// Used for creating shareable course links
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^\w\-]'), '')
        .replaceAll(RegExp(r'\-+'), '-')
        .replaceAll(RegExp(r'^\-|\-$'), '');
  }

  /// Quick empty check
  bool get isNullOrEmpty {
    return isEmpty;
  }

  /// Quick non-empty check
  bool get isNotNullOrEmpty {
    return isNotEmpty;
  }

  /// Reverses string characters
  /// Used in some gamification animations
  String get reverse {
    return split('').reversed.join('');
  }

  /// Counts words in string
  /// Used for lesson content statistics
  int get wordCount {
    return trim().isEmpty ? 0 : trim().split(RegExp(r'\s+')).length;
  }

  /// Extracts file extension from filename
  /// Used in code editor for syntax highlighting
  String get fileExtension {
    final parts = split('.');
    return parts.length > 1 ? parts.last : '';
  }

  /// Gets filename without extension
  /// Used for display purposes
  String get fileNameWithoutExtension {
    final parts = split('.');
    if (parts.length > 1) {
      parts.removeLast();
      return parts.join('.');
    }
    return this;
  }
}

// DateTime Extensions - Date/time formatting and comparisons
extension DateTimeExtensions on DateTime {
  /// Checks if date is today
  /// Used for streak tracking and daily challenges
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Checks if date is yesterday
  /// Used for streak calculations
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Checks if date is tomorrow
  /// Used for scheduling notifications
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Checks if timestamp is in the past
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Checks if timestamp is in the future
  bool get isFuture {
    return isAfter(DateTime.now());
  }

  /// Generates human-readable relative time strings
  /// Creates friendly timestamps like "2 hours ago"
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

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

  /// Gets midnight of current date
  /// Used for daily reset calculations
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Gets last moment of current date
  /// Used for date range queries
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Gets Monday of current week
  /// Used for weekly statistics
  DateTime get startOfWeek {
    final daysToSubtract = weekday - 1;
    return subtract(Duration(days: daysToSubtract)).startOfDay;
  }

  /// Gets Sunday of current week
  DateTime get endOfWeek {
    final daysToAdd = 7 - weekday;
    return add(Duration(days: daysToAdd)).endOfDay;
  }

  /// Gets first day of current month
  DateTime get startOfMonth {
    return DateTime(year, month);
  }

  /// Gets last day of current month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  /// Compares dates ignoring time
  /// Used for streak calculations
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Formats date in readable format
  /// Example: "January 15, 2024"
  String get readableDate {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[month - 1]} $day, $year';
  }

  /// Formats time in 12-hour format
  /// Example: "3:45 PM"
  String get readableTime {
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }
}

// List Extensions - Collection utilities
extension ListExtensions<T> on List<T> {
  /// Safe first element access
  /// Returns null instead of throwing if list is empty
  T? get firstOrNull {
    return isEmpty ? null : first;
  }

  /// Safe last element access
  T? get lastOrNull {
    return isEmpty ? null : last;
  }

  /// Safe index access
  /// Prevents index out of bounds errors
  T? getOrNull(int index) {
    return (index >= 0 && index < length) ? this[index] : null;
  }

  /// Splits list into smaller chunks
  /// Used for pagination in course lists
  List<List<T>> chunk(int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += chunkSize) {
      chunks.add(sublist(i, (i + chunkSize).clamp(0, length)));
    }
    return chunks;
  }

  /// Removes duplicate elements while preserving order
  List<T> get removeDuplicates {
    return toSet().toList();
  }

  /// Creates shuffled copy without modifying original
  /// Used for randomizing quiz questions
  List<T> shuffled() {
    final shuffledList = List<T>.from(this);
    shuffledList.shuffle();
    return shuffledList;
  }
}

// int Extensions - Number formatting and conversions
extension IntExtensions on int {
  /// Quick duration creators for animations and delays
  Duration get milliseconds => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);
  Duration get days => Duration(days: this);

  /// Formats numbers with thousands separators
  /// Example: 1234567 becomes "1,234,567"
  String get formatted {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Mathematical helpers
  bool get isEven => this % 2 == 0;
  bool get isOdd => this % 2 != 0;

  /// Converts number to ordinal string
  /// Used for rankings: 1st, 2nd, 3rd, etc.
  String get ordinal {
    if (this >= 11 && this <= 13) {
      return '${this}th';
    }
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }
}

// double Extensions - Decimal operations
extension DoubleExtensions on double {
  /// Rounds to specified decimal places
  /// Used for displaying scores and percentages
  double roundToDecimals(int decimals) {
    final factor = pow(10, decimals).toDouble();
    return (this * factor).round() / factor;
  }

  /// Converts decimal to percentage string
  /// Example: 0.856 becomes "85.6%"
  String toPercentage({int decimals = 0}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }

  /// Checks if double represents a whole number
  bool get isWhole => this == roundToDouble();
}

// Context Extensions - Flutter UI helpers
extension ContextExtensions on BuildContext {
  /// Quick theme access shortcuts
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Media query shortcuts for responsive design
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Theme mode detection
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Keyboard visibility check
  /// Used to adjust UI when keyboard appears
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Safe area padding for notched devices
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// Navigation shortcuts - reduces boilerplate code
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  Future<T?> push<T>(Widget page) => Navigator.of(this).push<T>(
        MaterialPageRoute(builder: (_) => page),
      );

  Future<T?> pushReplacement<T>(Widget page) =>
      Navigator.of(this).pushReplacement<T, dynamic>(
        MaterialPageRoute(builder: (_) => page),
      );

  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);

  Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) =>
      Navigator.of(this)
          .pushReplacementNamed<T, dynamic>(routeName, arguments: arguments);

  void popUntil(String routeName) =>
      Navigator.of(this).popUntil(ModalRoute.withName(routeName));
}

/// Simple power function for extension use
/// Avoids importing dart:math for basic operations
double pow(num x, num exponent) {
  if (exponent == 0) return 1;
  if (exponent == 1) return x.toDouble();

  double result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= x;
  }
  return result;
}
