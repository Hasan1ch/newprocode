import 'package:flutter/material.dart';
import 'package:procode/models/achievement_model.dart';
import 'package:procode/utils/app_logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Global key for accessing scaffold messenger
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Initialize notification service (for web compatibility)
  Future<void> initialize() async {
    // No special initialization needed for web
    // Just log that the service is ready
    AppLogger.info('NotificationService initialized');
  }

  // Show level up notification
  Future<void> showLevelUpNotification(int newLevel) async {
    try {
      _showNotification(
        title: 'Level Up! 🎉',
        message: 'Congratulations! You\'ve reached Level $newLevel',
        icon: Icons.arrow_upward,
        backgroundColor: Colors.purple,
        duration: const Duration(seconds: 4),
      );
      AppLogger.info('Level up notification shown for level $newLevel');
    } catch (e) {
      AppLogger.error('Error showing level up notification', error: e);
    }
  }

  // Show achievement unlocked notification
  Future<void> showAchievementUnlockedNotification(
      Achievement achievement) async {
    try {
      _showNotification(
        title: 'Achievement Unlocked! 🏆',
        message: '${achievement.name}: ${achievement.description}',
        icon: Icons.emoji_events,
        backgroundColor: _getColorForRarity(achievement.rarity),
        duration: const Duration(seconds: 5),
      );
      AppLogger.info(
          'Achievement unlocked notification shown: ${achievement.name}');
    } catch (e) {
      AppLogger.error('Error showing achievement notification', error: e);
    }
  }

  // Show XP earned notification
  void showXPEarnedNotification(int xp) {
    _showNotification(
      title: 'XP Earned! ⭐',
      message: '+$xp XP',
      icon: Icons.star,
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 2),
    );
  }

  // Show streak notification
  void showStreakNotification(int streakDays) {
    _showNotification(
      title: 'Streak Maintained! 🔥',
      message: '$streakDays day streak',
      icon: Icons.local_fire_department,
      backgroundColor: Colors.deepOrange,
      duration: const Duration(seconds: 3),
    );
  }

  // Show course completion notification
  void showCourseCompletionNotification(String courseName) {
    _showNotification(
      title: 'Course Completed! 🎓',
      message: 'You\'ve completed $courseName',
      icon: Icons.school,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 4),
    );
  }

  // Show quiz result notification
  void showQuizResultNotification(int score, bool passed) {
    _showNotification(
      title: passed ? 'Quiz Passed! ✅' : 'Quiz Complete 📝',
      message: 'Score: $score%',
      icon: passed ? Icons.check_circle : Icons.quiz,
      backgroundColor: passed ? Colors.green : Colors.blue,
      duration: const Duration(seconds: 3),
    );
  }

  // Show error notification
  void showErrorNotification(String message) {
    _showNotification(
      title: 'Error',
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 4),
    );
  }

  // Show success notification
  void showSuccessNotification(String message) {
    _showNotification(
      title: 'Success',
      message: message,
      icon: Icons.check_circle_outline,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
    );
  }

  // Show info notification
  void showInfoNotification(String message) {
    _showNotification(
      title: 'Info',
      message: message,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue,
      duration: const Duration(seconds: 3),
    );
  }

  // Show warning notification
  void showWarningNotification(String message) {
    _showNotification(
      title: 'Warning',
      message: message,
      icon: Icons.warning_amber_outlined,
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 3),
    );
  }

  // Private method to show notification
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

    // Clear any existing snackbars
    messenger.clearSnackBars();

    // Show new snackbar
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 6,
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

  // Get color based on achievement rarity
  Color _getColorForRarity(String rarity) {
    switch (rarity) {
      case 'common':
        return Colors.grey;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  // Show custom notification with builder
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

  // Clear all notifications
  void clearNotifications() {
    messengerKey.currentState?.clearSnackBars();
  }
}
