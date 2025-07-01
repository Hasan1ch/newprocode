import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  // Define colors here temporarily until we get AppColors from constants
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color textGreyColor = Color(0xFF757575);

  // Define constants
  static const int levelUpRequirement = 1000;

  // Generate random ID
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '$timestamp$random';
  }

  // Generate random color
  static Color generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  // Generate avatar from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';

    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return name.substring(0, min(2, name.length)).toUpperCase();
    }
  }

  // Get greeting based on time
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Calculate reading time
  static int calculateReadingTime(String text) {
    const wordsPerMinute = 200;
    final wordCount = text.split(' ').length;
    final minutes = (wordCount / wordsPerMinute).ceil();
    return minutes;
  }

  // Get programming language color
  static Color getLanguageColor(String language) {
    final colors = {
      'python': const Color(0xFF3776AB),
      'javascript': const Color(0xFFF7DF1E),
      'typescript': const Color(0xFF3178C6),
      'java': const Color(0xFF007396),
      'cpp': const Color(0xFF00599C),
      'c': const Color(0xFFA8B9CC),
      'csharp': const Color(0xFF239120),
      'ruby': const Color(0xFFCC342D),
      'go': const Color(0xFF00ADD8),
      'rust': const Color(0xFFDEA584),
      'php': const Color(0xFF777BB4),
      'swift': const Color(0xFFFA7343),
      'kotlin': const Color(0xFF7F52FF),
      'dart': const Color(0xFF0175C2),
      'html': const Color(0xFFE34C26),
      'css': const Color(0xFF1572B6),
      'sql': const Color(0xFF4479A1),
    };

    return colors[language.toLowerCase()] ?? primaryColor;
  }

  // Get difficulty color
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return successColor;
      case 'intermediate':
        return warningColor;
      case 'advanced':
        return errorColor;
      default:
        return textGreyColor;
    }
  }

  // Calculate level from XP
  static int calculateLevel(int xp) {
    return (xp / levelUpRequirement).floor() + 1;
  }

  // Calculate XP progress for current level
  static double calculateLevelProgress(int xp) {
    final currentLevelXP = xp % levelUpRequirement;
    return currentLevelXP / levelUpRequirement;
  }

  // Calculate XP needed for next level
  static int calculateXPNeeded(int xp) {
    final currentLevelXP = xp % levelUpRequirement;
    return levelUpRequirement - currentLevelXP;
  }

  // Get rank title based on level
  static String getRankTitle(int level) {
    if (level < 5) return 'Novice';
    if (level < 10) return 'Apprentice';
    if (level < 20) return 'Practitioner';
    if (level < 30) return 'Expert';
    if (level < 50) return 'Master';
    if (level < 75) return 'Grandmaster';
    if (level < 100) return 'Legend';
    return 'Mythic';
  }

  // Get rank icon based on level
  static IconData getRankIcon(int level) {
    if (level < 5) return Icons.star_border;
    if (level < 10) return Icons.star_half;
    if (level < 20) return Icons.star;
    if (level < 30) return Icons.military_tech;
    if (level < 50) return Icons.emoji_events;
    if (level < 75) return Icons.workspace_premium;
    if (level < 100) return Icons.diamond;
    return Icons.auto_awesome;
  }

  // Launch URL
  static Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Launch email
  static Future<void> launchEmail(String email,
      {String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch email';
    }
  }

  // Share text
  static Future<void> shareText(String text) async {
    // This would use share_plus package in a real app
    // For now, just copy to clipboard
    // Clipboard.setData(ClipboardData(text: text));
  }

  // Check if dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Get contrast color
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? errorColor : successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(width: 20),
                Flexible(child: Text(message)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? errorColor : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // Get file extension
  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  // Check if email is valid
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Check if URL is valid
  static bool isValidUrl(String url) {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    return urlRegex.hasMatch(url);
  }

  // Generate random password
  static String generateRandomPassword({int length = 12}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Get device type
  static String getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 'phone';
    if (width < 1200) return 'tablet';
    return 'desktop';
  }

  // Check if tablet or desktop
  static bool isTabletOrDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  // Get responsive columns
  static int getResponsiveColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 3;
    return 4;
  }
}
