import 'package:flutter/material.dart';
import 'package:procode/models/achievement_model.dart';
import 'package:procode/utils/app_logger.dart';

/// In-app notification service for displaying user feedback
/// Uses Material Design SnackBars for consistent, non-intrusive notifications
/// This creates a better UX than dialog boxes for transient messages
class NotificationService {
  // Singleton pattern ensures only one instance manages notifications
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Global key allows us to show notifications from anywhere in the app
  // This is attached to the root MaterialApp's ScaffoldMessenger
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Initialize notification service
  /// For web/mobile compatibility - extensible for push notifications later
  Future<void> initialize() async {
    // No special initialization needed for web
    // Just log that the service is ready
    AppLogger.info('NotificationService initialized');
  }

  /// Celebrates when users reach a new level
  /// This positive reinforcement encourages continued engagement
  Future<void> showLevelUpNotification(int newLevel) async {
    try {
      _showNotification(
        title: 'Level Up! 🎉',
        message: 'Congratulations! You\'ve reached Level $newLevel',
        icon: Icons.arrow_upward,
        backgroundColor: Colors.purple, // Purple for special achievements
        duration: const Duration(seconds: 4),
      );
      AppLogger.info('Level up notification shown for level $newLevel');
    } catch (e) {
      AppLogger.error('Error showing level up notification', error: e);
    }
  }

  /// Shows achievement unlocked with rarity-based colors
  /// Different colors create excitement for rare achievements
  Future<void> showAchievementUnlockedNotification(
      Achievement achievement) async {
    try {
      _showNotification(
        title: 'Achievement Unlocked! 🏆',
        message: '${achievement.name}: ${achievement.description}',
        icon: Icons.emoji_events,
        backgroundColor: _getColorForRarity(achievement.rarity),
        duration:
            const Duration(seconds: 5), // Longer duration for achievements
      );
      AppLogger.info(
          'Achievement unlocked notification shown: ${achievement.name}');
    } catch (e) {
      AppLogger.error('Error showing achievement notification', error: e);
    }
  }

  /// Quick XP notification for immediate feedback
  /// Shows users their progress in real-time
  void showXPEarnedNotification(int xp) {
    _showNotification(
      title: 'XP Earned! ⭐',
      message: '+$xp XP',
      icon: Icons.star,
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 2), // Brief for frequent notifications
    );
  }

  /// Motivates users to maintain their daily learning habit
  /// Streaks are powerful psychological motivators
  void showStreakNotification(int streakDays) {
    _showNotification(
      title: 'Streak Maintained! 🔥',
      message: '$streakDays day streak',
      icon: Icons.local_fire_department,
      backgroundColor: Colors.deepOrange, // Fire colors for streaks
      duration: const Duration(seconds: 3),
    );
  }

  /// Major milestone notification for completing courses
  /// This acknowledgment makes users feel accomplished
  void showCourseCompletionNotification(String courseName) {
    _showNotification(
      title: 'Course Completed! 🎓',
      message: 'You\'ve completed $courseName',
      icon: Icons.school,
      backgroundColor: Colors.green, // Green for success
      duration: const Duration(seconds: 4),
    );
  }

  /// Quiz feedback notification with pass/fail indication
  /// Different styling helps users quickly understand results
  void showQuizResultNotification(int score, bool passed) {
    _showNotification(
      title: passed ? 'Quiz Passed! ✅' : 'Quiz Complete 📝',
      message: 'Score: $score%',
      icon: passed ? Icons.check_circle : Icons.quiz,
      backgroundColor: passed ? Colors.green : Colors.blue,
      duration: const Duration(seconds: 3),
    );
  }

  /// Error notifications for user-facing issues
  /// Red color and error icon clearly indicate problems
  void showErrorNotification(String message) {
    _showNotification(
      title: 'Error',
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
    );
  }

  /// Success notifications for completed actions
  /// Provides positive feedback for user actions
  void showSuccessNotification(String message) {
    _showNotification(
      title: 'Success',
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
    );
  }

  /// Informational notifications for neutral messages
  /// Blue color indicates informational content
  void showInfoNotification(String message) {
    _showNotification(
      title: 'Info',
      message: message,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue,
      duration: const Duration(seconds: 3),
    );
  }

  /// Warning notifications for important alerts
  /// Orange color grabs attention without causing alarm
  void showWarningNotification(String message) {
    _showNotification(
      title: 'Warning',
      message: message,
      icon: Icons.warning_amber_outlined,
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 3),
    );
  }

  /// Core notification display method
  /// Creates consistent, branded notifications throughout the app
  void _showNotification({
    required String title,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Duration duration,
  }) {
    final context = messengerKey.currentContext;
    if (context == null) return;

    final messenger = ScaffoldMessenger.of(context);

    // Clear any existing snackbars to prevent stacking
    messenger.clearSnackBars();

    // Show new snackbar with custom styling
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Icon provides visual context
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            // Expanded allows text to wrap properly
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bold title for hierarchy
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  // Message only shown if not empty
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating, // Modern floating style
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 6, // Shadow for depth
        // Dismiss action for better UX
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Maps achievement rarity to appropriate colors
  /// Creates visual hierarchy for achievement importance
  Color _getColorForRarity(String rarity) {
    switch (rarity) {
      case 'common':
        return Colors.grey; // Common achievements
      case 'rare':
        return Colors.blue; // Rare achievements stand out
      case 'epic':
        return Colors.purple; // Epic achievements feel special
      case 'legendary':
        return Colors.amber; // Legendary achievements are golden
      default:
        return Colors.grey;
    }
  }

  /// Advanced notification with custom widget content
  /// Allows for complex notification designs when needed
  void showCustomNotification({
    required Widget Function(BuildContext) builder,
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    ShapeBorder? shape,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    final context = messengerKey.currentContext;
    if (context == null) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Builder(builder: builder),
        duration: duration,
        backgroundColor: backgroundColor,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
        behavior: behavior,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Clears all active notifications
  /// Used when navigating away or resetting UI state
  void clearNotifications() {
    messengerKey.currentState?.clearSnackBars();
  }
}
