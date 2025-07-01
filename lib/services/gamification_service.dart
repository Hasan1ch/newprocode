import 'package:procode/models/achievement_model.dart';
import 'package:procode/models/user_model.dart';
import 'package:procode/services/database_service.dart';
import 'package:procode/services/notification_service.dart';
import 'package:procode/config/constants.dart' as constants;
import 'package:procode/utils/app_logger.dart';

class GamificationService {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  // Award XP to user
  Future<void> awardXP(String userId, int xpAmount) async {
    try {
      await _databaseService.awardXP(userId, xpAmount);

      // Check for level up
      final user = await _databaseService.getUser(userId);
      if (user != null) {
        final newLevel = UserModel.calculateLevel(user.totalXP + xpAmount);
        if (newLevel > user.level) {
          await _notificationService.showLevelUpNotification(newLevel);
          await checkAndAwardAchievements(userId, 'level_up', newLevel);
        }
      }

      AppLogger.info('Awarded $xpAmount XP to user: $userId');
    } catch (e) {
      AppLogger.error('Error awarding XP', error: e);
      rethrow;
    }
  }

  // Check and award achievements
  Future<void> checkAndAwardAchievements(
    String userId,
    String triggerType,
    dynamic value,
  ) async {
    try {
      final user = await _databaseService.getUser(userId);
      if (user == null) return;

      // Get all achievements
      final allAchievements = constants.achievements;

      for (final achievement in allAchievements) {
        // Skip if user already has this achievement
        if (user.achievements.contains(achievement.id)) continue;

        bool shouldAward = false;

        switch (achievement.id) {
          case 'first_steps':
            if (triggerType == 'lesson_completed' &&
                user.completedCourses.isEmpty) {
              shouldAward = true;
            }
            break;

          case 'quiz_master':
            if (triggerType == 'quiz_completed' && value >= 90) {
              shouldAward = true;
            }
            break;

          case 'streak_starter':
            if (triggerType == 'streak' && value >= 7) {
              shouldAward = true;
            }
            break;

          case 'level_5':
            if (triggerType == 'level_up' && value >= 5) {
              shouldAward = true;
            }
            break;

          case 'course_complete':
            if (triggerType == 'course_completed') {
              shouldAward = true;
            }
            break;

          case 'dedicated_learner':
            if (triggerType == 'streak' && value >= 30) {
              shouldAward = true;
            }
            break;

          case 'code_warrior':
            if (triggerType == 'challenges_completed' && value >= 50) {
              shouldAward = true;
            }
            break;

          case 'knowledge_seeker':
            if (triggerType == 'courses_completed' &&
                user.completedCourses.length >= 5) {
              shouldAward = true;
            }
            break;
        }

        if (shouldAward) {
          await _databaseService.grantAchievement(userId, achievement.id);
          await _notificationService.showAchievementUnlockedNotification(
            achievement,
          );

          // Award achievement XP
          await awardXP(userId, achievement.xpReward);

          AppLogger.info(
              'Achievement unlocked: ${achievement.id} for user: $userId');
        }
      }
    } catch (e) {
      AppLogger.error('Error checking achievements', error: e);
    }
  }

  // Update user streak
  Future<void> updateStreak(String userId) async {
    try {
      await _databaseService.updateStreak(userId);

      // Check streak achievements
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

  // Mark lesson as completed
  Future<void> markLessonCompleted(
    String userId,
    String lessonId,
    int xpReward,
  ) async {
    try {
      await _databaseService.markLessonCompleted(userId, lessonId, xpReward);
      await checkAndAwardAchievements(userId, 'lesson_completed', lessonId);
    } catch (e) {
      AppLogger.error('Error marking lesson completed', error: e);
      rethrow;
    }
  }

  // Mark quiz as completed
  Future<void> markQuizCompleted(
    String userId,
    String quizId,
    int score,
    int xpReward,
  ) async {
    try {
      await _databaseService.markQuizCompleted(userId, quizId, score, xpReward);
      await checkAndAwardAchievements(userId, 'quiz_completed', score);
    } catch (e) {
      AppLogger.error('Error marking quiz completed', error: e);
      rethrow;
    }
  }

  // Mark course as completed
  Future<void> markCourseCompleted(
    String userId,
    String courseId,
  ) async {
    try {
      // Update user's completed courses
      await _databaseService.updateUser(userId, {
        'completedCourses': [
          ...(await _databaseService.getUser(userId))!.completedCourses,
          courseId
        ],
      });

      await checkAndAwardAchievements(userId, 'course_completed', courseId);

      // Check for multiple courses achievement
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

  // Get user achievements
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final user = await _databaseService.getUser(userId);
      if (user == null) return [];

      return constants.achievements
          .where((achievement) => user.achievements.contains(achievement.id))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting user achievements', error: e);
      return [];
    }
  }

  // Get available achievements
  List<Achievement> getAvailableAchievements() {
    return constants.achievements;
  }

  // Calculate XP for next level
  int getXPForNextLevel(int currentLevel) {
    // Simple progression: each level requires more XP
    final xpThresholds = [
      0, // Level 1
      100, // Level 2
      300, // Level 3
      600, // Level 4
      1000, // Level 5
      1500, // Level 6
      2500, // Level 7
      4000, // Level 8
      6000, // Level 9
      9000, // Level 10
    ];

    if (currentLevel >= xpThresholds.length) {
      // For levels beyond 10, each level requires 3000 more XP
      return xpThresholds.last +
          (currentLevel - xpThresholds.length + 1) * 3000;
    }

    return xpThresholds[currentLevel];
  }

  // Get user progress to next level
  double getLevelProgress(int totalXP, int currentLevel) {
    final currentLevelXP =
        currentLevel > 1 ? getXPForNextLevel(currentLevel - 1) : 0;
    final nextLevelXP = getXPForNextLevel(currentLevel);
    final xpInCurrentLevel = totalXP - currentLevelXP;
    final xpNeededForLevel = nextLevelXP - currentLevelXP;

    return (xpInCurrentLevel / xpNeededForLevel).clamp(0.0, 1.0);
  }
}
