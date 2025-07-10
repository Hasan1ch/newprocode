import 'package:procode/models/achievement_model.dart';
import 'package:procode/models/user_model.dart';
import 'package:procode/services/database_service.dart';
import 'package:procode/services/notification_service.dart';
import 'package:procode/config/constants.dart' as constants;
import 'package:procode/utils/app_logger.dart';

/// Core service managing all gamification features in ProCode
/// This includes XP system, achievements, levels, and streaks
/// Gamification is proven to increase user engagement by 48% in e-learning apps
class GamificationService {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  /// Awards experience points to users for completing activities
  /// XP is the foundation of our gamification system
  Future<void> awardXP(String userId, int xpAmount) async {
    try {
      await _databaseService.awardXP(userId, xpAmount);

      // Check for level up - this creates exciting moments for users
      final user = await _databaseService.getUser(userId);
      if (user != null) {
        // Calculate if the new XP total results in a level increase
        final newLevel = UserModel.calculateLevel(user.totalXP + xpAmount);
        if (newLevel > user.level) {
          // Trigger celebration notification when user levels up
          await _notificationService.showLevelUpNotification(newLevel);
          // Check if this level up unlocks any achievements
          await checkAndAwardAchievements(userId, 'level_up', newLevel);
        }
      }

      AppLogger.info('Awarded $xpAmount XP to user: $userId');
    } catch (e) {
      AppLogger.error('Error awarding XP', error: e);
      rethrow;
    }
  }

  /// Central achievement checking system
  /// Monitors user progress and automatically awards achievements when conditions are met
  /// This creates surprise and delight moments throughout the learning journey
  Future<void> checkAndAwardAchievements(
    String userId,
    String triggerType,
    dynamic value,
  ) async {
    try {
      final user = await _databaseService.getUser(userId);
      if (user == null) return;

      // Get all achievements from our constants file
      final allAchievements = constants.achievements;

      // Loop through each achievement to check if user qualifies
      for (final achievement in allAchievements) {
        // Skip if user already has this achievement
        if (user.achievements.contains(achievement.id)) continue;

        bool shouldAward = false;

        // Achievement logic - each achievement has specific unlock criteria
        switch (achievement.id) {
          case 'first_steps':
            // Awarded for completing first lesson - encourages initial engagement
            if (triggerType == 'lesson_completed' &&
                user.completedCourses.isEmpty) {
              shouldAward = true;
            }
            break;

          case 'quiz_master':
            // Rewards excellence in quizzes - 90% or higher score
            if (triggerType == 'quiz_completed' && value >= 90) {
              shouldAward = true;
            }
            break;

          case 'streak_starter':
            // 7-day streak encourages daily practice habit formation
            if (triggerType == 'streak' && value >= 7) {
              shouldAward = true;
            }
            break;

          case 'level_5':
            // Milestone achievement for reaching level 5
            if (triggerType == 'level_up' && value >= 5) {
              shouldAward = true;
            }
            break;

          case 'course_complete':
            // Celebrates first course completion
            if (triggerType == 'course_completed') {
              shouldAward = true;
            }
            break;

          case 'dedicated_learner':
            // 30-day streak shows serious commitment to learning
            if (triggerType == 'streak' && value >= 30) {
              shouldAward = true;
            }
            break;

          case 'code_warrior':
            // 50 challenges completed - shows mastery through practice
            if (triggerType == 'challenges_completed' && value >= 50) {
              shouldAward = true;
            }
            break;

          case 'knowledge_seeker':
            // Completing 5 courses demonstrates breadth of learning
            if (triggerType == 'courses_completed' &&
                user.completedCourses.length >= 5) {
              shouldAward = true;
            }
            break;
        }

        if (shouldAward) {
          // Grant the achievement and notify the user
          await _databaseService.grantAchievement(userId, achievement.id);
          await _notificationService.showAchievementUnlockedNotification(
            achievement,
          );

          // Award bonus XP for unlocking achievement
          await awardXP(userId, achievement.xpReward);

          AppLogger.info(
              'Achievement unlocked: ${achievement.id} for user: $userId');
        }
      }
    } catch (e) {
      AppLogger.error('Error checking achievements', error: e);
    }
  }

  /// Updates user's daily learning streak
  /// Streaks are powerful motivators - users don't want to break their streak
  Future<void> updateStreak(String userId) async {
    try {
      await _databaseService.updateStreak(userId);

      // Check if the new streak unlocks any achievements
      final user = await _databaseService.getUser(userId);
      if (user != null) {
        await checkAndAwardAchievements(
          userId,
          'streak',
          user.currentStreak,
        );
      }
    } catch (e) {
      AppLogger.error('Error updating streak', error: e);
    }
  }

  /// Records lesson completion and awards appropriate XP
  /// Each lesson has a predefined XP reward based on difficulty
  Future<void> markLessonCompleted(
    String userId,
    String lessonId,
    int xpReward,
  ) async {
    try {
      await _databaseService.markLessonCompleted(userId, lessonId, xpReward);
      // Check if this triggers any achievements (like first lesson)
      await checkAndAwardAchievements(userId, 'lesson_completed', lessonId);
    } catch (e) {
      AppLogger.error('Error marking lesson completed', error: e);
      rethrow;
    }
  }

  /// Records quiz completion with score-based XP rewards
  /// Higher scores earn more XP, encouraging mastery over completion
  Future<void> markQuizCompleted(
    String userId,
    String quizId,
    int score,
    int xpReward,
  ) async {
    try {
      await _databaseService.markQuizCompleted(userId, quizId, score, xpReward);
      // Check for quiz-related achievements (like Quiz Master for 90%+)
      await checkAndAwardAchievements(userId, 'quiz_completed', score);
    } catch (e) {
      AppLogger.error('Error marking quiz completed', error: e);
      rethrow;
    }
  }

  /// Major milestone - user has completed an entire course
  /// This triggers multiple achievement checks and substantial rewards
  Future<void> markCourseCompleted(
    String userId,
    String courseId,
  ) async {
    try {
      // Update user's completed courses list
      await _databaseService.updateUser(userId, {
        'completedCourses': [
          ...(await _databaseService.getUser(userId))!.completedCourses,
          courseId
        ],
      });

      // Check for first course completion achievement
      await checkAndAwardAchievements(userId, 'course_completed', courseId);

      // Also check if they've hit the milestone for multiple courses
      final user = await _databaseService.getUser(userId);
      if (user != null) {
        await checkAndAwardAchievements(
          userId,
          'courses_completed',
          user.completedCourses.length,
        );
      }
    } catch (e) {
      AppLogger.error('Error marking course completed', error: e);
      rethrow;
    }
  }

  /// Retrieves all achievements the user has unlocked
  /// Used in the profile/achievements screen to display progress
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final user = await _databaseService.getUser(userId);
      if (user == null) return [];

      // Filter all achievements to only return ones the user has earned
      return constants.achievements
          .where((achievement) => user.achievements.contains(achievement.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting user achievements', error: e);
      return [];
    }
  }

  /// Returns all possible achievements in the system
  /// Used to show users what they can work towards
  List<Achievement> getAvailableAchievements() {
    return constants.achievements;
  }

  /// Calculates XP required for each level using a progressive curve
  /// Higher levels require increasingly more XP to achieve
  int getXPForNextLevel(int currentLevel) {
    // Simple progression: each level requires more XP
    final xpThresholds = [
      0, // Level 1 - Starting level
      100, // Level 2 - Easy first level up
      300, // Level 3
      600, // Level 4
      1000, // Level 5 - First major milestone
      1500, // Level 6
      2500, // Level 7
      4000, // Level 8
      6000, // Level 9
      9000, // Level 10 - Elite status
    ];

    if (currentLevel >= xpThresholds.length) {
      // For levels beyond 10, each level requires 3000 more XP
      // This creates an infinite progression system
      return xpThresholds.last +
          (currentLevel - xpThresholds.length + 1) * 3000;
    }

    return xpThresholds[currentLevel];
  }

  /// Calculates user's progress towards their next level
  /// Returns a value between 0.0 and 1.0 for progress bar display
  double getLevelProgress(int totalXP, int currentLevel) {
    // Calculate XP boundaries for current level
    final currentLevelXP =
        currentLevel > 1 ? getXPForNextLevel(currentLevel - 1) : 0;
    final nextLevelXP = getXPForNextLevel(currentLevel);

    // Calculate progress within current level
    final xpInCurrentLevel = totalXP - currentLevelXP;
    final xpNeededForLevel = nextLevelXP - currentLevelXP;

    // Return percentage complete, clamped to valid range
    return (xpInCurrentLevel / xpNeededForLevel).clamp(0.0, 1.0);
  }
}
