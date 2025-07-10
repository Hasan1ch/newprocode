import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// General helper utilities used throughout the app
/// This class contains commonly used functions to avoid code duplication
/// and maintain consistency across the application
class Helpers {
  // Define colors here temporarily until we get AppColors from constants
  // These match our brand identity and Material Design guidelines
  static const Color primaryColor = Color(0xFF6C63FF); // ProCode purple
  static const Color successColor =
      Color(0xFF4CAF50); // Green for positive feedback
  static const Color warningColor = Color(0xFFFF9800); // Orange for warnings
  static const Color errorColor = Color(0xFFF44336); // Red for errors
  static const Color textGreyColor = Color(0xFF757575); // Secondary text

  // Define constants for gamification calculations
  static const int levelUpRequirement = 1000; // XP needed per level

  /// Generates unique IDs for database entries
  /// Combines timestamp with random number to ensure uniqueness
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '$timestamp$random';
  }

  /// Creates random colors for dynamic UI elements
  /// Used for user avatars when no image is provided
  static Color generateRandomColor() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  /// Extracts initials from user's name for avatar display
  /// Handles single names and multiple word names gracefully
  static String getInitials(String name) {
    if (name.isEmpty) return '';

    final words = name.trim().split(' ');
    if (words.length >= 2) {
      // Take first letter of first two words
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      // For single word, take up to first two characters
      return name.substring(0, min(2, name.length)).toUpperCase();
    }
  }

  /// Returns time-appropriate greeting for personalized experience
  /// Makes the app feel more welcoming and human
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

  /// Estimates reading time based on average reading speed
  /// Helps users gauge time commitment for lessons
  static int calculateReadingTime(String text) {
    const wordsPerMinute = 200; // Average adult reading speed
    final wordCount = text.split(' ').length;
    final minutes = (wordCount / wordsPerMinute).ceil();
    return minutes;
  }

  /// Maps programming languages to their brand colors
  /// Creates visual consistency when displaying language tags
  static Color getLanguageColor(String language) {
    final colors = {
      'python': const Color(0xFF3776AB), // Python blue
      'javascript': const Color(0xFFF7DF1E), // JS yellow
      'typescript': const Color(0xFF3178C6), // TS blue
      'java': const Color(0xFF007396), // Java blue
      'cpp': const Color(0xFF00599C), // C++ blue
      'c': const Color(0xFFA8B9CC), // C gray
      'csharp': const Color(0xFF239120), // C# green
      'ruby': const Color(0xFFCC342D), // Ruby red
      'go': const Color(0xFF00ADD8), // Go cyan
      'rust': const Color(0xFFDEA584), // Rust orange
      'php': const Color(0xFF777BB4), // PHP purple
      'swift': const Color(0xFFFA7343), // Swift orange
      'kotlin': const Color(0xFF7F52FF), // Kotlin purple
      'dart': const Color(0xFF0175C2), // Dart blue
      'html': const Color(0xFFE34C26), // HTML orange
      'css': const Color(0xFF1572B6), // CSS blue
      'sql': const Color(0xFF4479A1), // SQL blue
    };

    return colors[language.toLowerCase()] ?? primaryColor;
  }

  /// Assigns colors to difficulty levels for quick visual identification
  /// Green = easy, Orange = medium, Red = hard
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

  /// Calculates user level based on total XP
  /// Each level requires 1000 XP (defined in levelUpRequirement)
  static int calculateLevel(int xp) {
    return (xp / levelUpRequirement).floor() + 1;
  }

  /// Calculates progress percentage within current level
  /// Used for level progress bars in user profiles
  static double calculateLevelProgress(int xp) {
    final currentLevelXP = xp % levelUpRequirement;
    return currentLevelXP / levelUpRequirement;
  }

  /// Calculates remaining XP needed for next level
  /// Helps motivate users by showing proximity to next level
  static int calculateXPNeeded(int xp) {
    final currentLevelXP = xp % levelUpRequirement;
    return levelUpRequirement - currentLevelXP;
  }

  /// Maps user level to rank titles for gamification
  /// Creates sense of progression and achievement
  static String getRankTitle(int level) {
    if (level < 5) return 'Novice';
    if (level < 10) return 'Apprentice';
    if (level < 20) return 'Practitioner';
    if (level < 30) return 'Expert';
    if (level < 50) return 'Master';
    if (level < 75) return 'Grandmaster';
    if (level < 100) return 'Legend';
    return 'Mythic'; // Highest rank for dedication
  }

  /// Assigns appropriate icons based on user rank
  /// Visual representation of user's progress journey
  static IconData getRankIcon(int level) {
    if (level < 5) return Icons.star_border; // Empty star
    if (level < 10) return Icons.star_half; // Half star
    if (level < 20) return Icons.star; // Full star
    if (level < 30) return Icons.military_tech; // Medal
    if (level < 50) return Icons.emoji_events; // Trophy
    if (level < 75) return Icons.workspace_premium; // Premium badge
    if (level < 100) return Icons.diamond; // Diamond
    return Icons.auto_awesome; // Sparkles for mythic
  }

  /// Opens external URLs in browser
  /// Used for course resources and external documentation
  static Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Opens email client with pre-filled fields
  /// Makes it easy for users to contact support
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

  /// Placeholder for sharing functionality
  /// Would integrate with share_plus package in production
  static Future<void> shareText(String text) async {
    // This would use share_plus package in a real app
    // For now, just copy to clipboard
    // Clipboard.setData(ClipboardData(text: text));
  }

  /// Checks if app is in dark mode
  /// Used for conditional styling and theme-aware components
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Calculates contrast color for text on colored backgrounds
  /// Ensures text readability on dynamic backgrounds
  static Color getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Shows styled snackbar notifications
  /// Consistent with our notification service but for simple messages
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

  /// Displays loading indicator during async operations
  /// Prevents user interaction during critical operations
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false, // User can't dismiss
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

  /// Dismisses loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Shows confirmation dialog for destructive actions
  /// Prevents accidental deletions or important changes
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

  /// Extracts file extension from filename
  /// Used for determining file types in uploads
  static String getFileExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  /// Validates email format using regex
  /// Ensures proper email format before Firebase operations
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates URL format
  /// Used for course resource links validation
  static bool isValidUrl(String url) {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    return urlRegex.hasMatch(url);
  }

  /// Generates secure random passwords
  /// Used for temporary passwords or password reset
  static String generateRandomPassword({int length = 12}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure(); // Cryptographically secure
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Detects device type for responsive design
  /// Helps optimize UI for different screen sizes
  static String getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 'phone';
    if (width < 1200) return 'tablet';
    return 'desktop';
  }

  /// Quick check for larger screens
  /// Used for adaptive layouts
  static bool isTabletOrDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Calculates grid columns based on screen width
  /// Creates responsive grids for course cards
  static int getResponsiveColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1; // Phone: single column
    if (width < 900) return 2; // Small tablet: 2 columns
    if (width < 1200) return 3; // Large tablet: 3 columns
    return 4; // Desktop: 4 columns
  }
}
