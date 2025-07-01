import 'package:flutter/material.dart';

// String Extensions
extension StringExtensions on String {
  // Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  // Capitalize each word
  String get capitalizeWords {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  // Convert to title case
  String get toTitleCase {
    return replaceAllMapped(
      RegExp(
          r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+'),
      (Match match) {
        return '${match[0]!.capitalize} ';
      },
    ).trim();
  }

  // Check if string is email
  bool get isEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  // Check if string is URL
  bool get isURL {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    return urlRegex.hasMatch(this);
  }

  // Check if string is phone number
  bool get isPhoneNumber {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    return phoneRegex.hasMatch(this) && length >= 10;
  }

  // Check if string contains only numbers
  bool get isNumeric {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  // Check if string contains only alphabets
  bool get isAlpha {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(this);
  }

  // Check if string contains only alphanumeric characters
  bool get isAlphanumeric {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);
  }

  // Remove all whitespace
  String get removeAllWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  // Truncate string with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  // Convert to slug (URL-friendly)
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^\w\-]'), '')
        .replaceAll(RegExp(r'\-+'), '-')
        .replaceAll(RegExp(r'^\-|\-$'), '');
  }

  // Check if string is null or empty
  bool get isNullOrEmpty {
    return isEmpty;
  }

  // Check if string is not null or empty
  bool get isNotNullOrEmpty {
    return isNotEmpty;
  }

  // Reverse string
  String get reverse {
    return split('').reversed.join('');
  }

  // Count words
  int get wordCount {
    return trim().isEmpty ? 0 : trim().split(RegExp(r'\s+')).length;
  }

  // Get file extension
  String get fileExtension {
    final parts = split('.');
    return parts.length > 1 ? parts.last : '';
  }

  // Get file name without extension
  String get fileNameWithoutExtension {
    final parts = split('.');
    if (parts.length > 1) {
      parts.removeLast();
      return parts.join('.');
    }
    return this;
  }
}

// DateTime Extensions
extension DateTimeExtensions on DateTime {
  // Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  // Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  // Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  // Check if date is in the past
  bool get isPast {
    return isBefore(DateTime.now());
  }

  // Check if date is in the future
  bool get isFuture {
    return isAfter(DateTime.now());
  }

  // Get time ago
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

  // Get start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  // Get end of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  // Get start of week (Monday)
  DateTime get startOfWeek {
    final daysToSubtract = weekday - 1;
    return subtract(Duration(days: daysToSubtract)).startOfDay;
  }

  // Get end of week (Sunday)
  DateTime get endOfWeek {
    final daysToAdd = 7 - weekday;
    return add(Duration(days: daysToAdd)).endOfDay;
  }

  // Get start of month
  DateTime get startOfMonth {
    return DateTime(year, month);
  }

  // Get end of month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  // Check if same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // Format to readable date
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

  // Format to readable time
  String get readableTime {
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }
}

// List Extensions
extension ListExtensions<T> on List<T> {
  // Get first or null
  T? get firstOrNull {
    return isEmpty ? null : first;
  }

  // Get last or null
  T? get lastOrNull {
    return isEmpty ? null : last;
  }

  // Get element at index or null
  T? getOrNull(int index) {
    return (index >= 0 && index < length) ? this[index] : null;
  }

  // Chunk list into smaller lists
  List<List<T>> chunk(int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += chunkSize) {
      chunks.add(sublist(i, (i + chunkSize).clamp(0, length)));
    }
    return chunks;
  }

  // Remove duplicates
  List<T> get removeDuplicates {
    return toSet().toList();
  }

  // Shuffle and return new list
  List<T> shuffled() {
    final shuffledList = List<T>.from(this);
    shuffledList.shuffle();
    return shuffledList;
  }
}

// int Extensions
extension IntExtensions on int {
  // Convert to duration
  Duration get milliseconds => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);
  Duration get days => Duration(days: this);

  // Convert to formatted string with commas
  String get formatted {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // Check if even
  bool get isEven => this % 2 == 0;

  // Check if odd
  bool get isOdd => this % 2 != 0;

  // Convert to ordinal (1st, 2nd, 3rd, etc.)
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

// double Extensions
extension DoubleExtensions on double {
  // Round to decimal places
  double roundToDecimals(int decimals) {
    final factor = pow(10, decimals).toDouble();
    return (this * factor).round() / factor;
  }

  // Convert to percentage string
  String toPercentage({int decimals = 0}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }

  // Check if whole number
  bool get isWhole => this == roundToDouble();
}

// Context Extensions
extension ContextExtensions on BuildContext {
  // Get theme
  ThemeData get theme => Theme.of(this);

  // Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Get media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  // Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  // Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  // Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  // Check if dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  // Get safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  // Navigation helpers
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

// pow function for double extension
double pow(num x, num exponent) {
  if (exponent == 0) return 1;
  if (exponent == 1) return x.toDouble();

  double result = 1;
  for (int i = 0; i < exponent; i++) {
    result *= x;
  }
  return result;
}
