import 'dart:math' as math;

/// Firebase configuration for ProCode project
class FirebaseConfig {
  // Collection names
  static const String usersCollection = 'users';
  static const String usernamesCollection = 'usernames';
  static const String userStatsCollection = 'user_stats';
  static const String coursesCollection = 'courses';
  static const String modulesCollection = 'modules';
  static const String lessonsCollection = 'lessons';
  static const String quizzesCollection = 'quizzes';
  static const String questionsCollection = 'questions';
  static const String quizResultsCollection = 'quiz_results';
  static const String progressCollection = 'progress';
  static const String achievementsCollection = 'achievements';
  static const String userAchievementsCollection = 'user_achievements';
  static const String codeChallengesCollection = 'code_challenges';
  static const String leaderboardCollection = 'leaderboard';
  static const String streaksCollection = 'streaks';

  // Storage paths
  static const String avatarsPath = 'avatars';
  static const String courseThumbnailsPath = 'courses/thumbnails';
  static const String achievementIconsPath = 'achievements/icons';
  static const String lessonImagesPath = 'lessons/images';

  // Firestore field names
  static const String timestampField = 'timestamp';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';

  // Rate limiting
  static const int maxLoginAttempts = 5;
  static const Duration loginAttemptWindow = Duration(minutes: 15);

  // Pagination
  static const int defaultPageSize = 20;
  static const int leaderboardPageSize = 50;

  // XP and Level Configuration
  static const int xpPerLesson = 10;
  static const int xpPerEasyQuiz = 20;
  static const int xpPerMediumQuiz = 35;
  static const int xpPerHardQuiz = 50;
  static const int xpPerCodeChallenge = 30;
  static const int xpPerStreak = 5;
  static const int xpPerAchievement = 25;

  // Level calculation
  static int calculateLevel(int xp) {
    // Level = floor(sqrt(xp / 100)) + 1
    return (math.sqrt(xp / 100)).floor() + 1;
  }

  static int xpForLevel(int level) {
    // XP = (level - 1)^2 * 100
    return ((level - 1) * (level - 1)) * 100;
  }

  static int xpForNextLevel(int currentXp) {
    final currentLevel = calculateLevel(currentXp);
    final nextLevel = currentLevel + 1;
    return xpForLevel(nextLevel) - currentXp;
  }

  // Quiz passing score
  static const int passingScorePercentage = 70;

  // Streak configuration
  static const Duration streakWindow = Duration(hours: 36);

  // Cache durations
  static const Duration userCacheDuration = Duration(minutes: 5);
  static const Duration courseCacheDuration = Duration(hours: 1);
  static const Duration leaderboardCacheDuration = Duration(minutes: 10);
}
