import 'dart:math' as math;

/// Firebase configuration for ProCode project
/// Centralizes all Firebase-related settings and calculations
class FirebaseConfig {
  // Firestore collection names - organized by feature
  static const String usersCollection = 'users'; // User profiles
  static const String usernamesCollection =
      'usernames'; // Unique username registry
  static const String userStatsCollection = 'user_stats'; // Learning statistics
  static const String coursesCollection = 'courses'; // Available courses
  static const String modulesCollection = 'modules'; // Course modules
  static const String lessonsCollection = 'lessons'; // Individual lessons
  static const String quizzesCollection = 'quizzes'; // Quiz content
  static const String questionsCollection = 'questions'; // Quiz questions
  static const String quizResultsCollection =
      'quiz_results'; // User quiz scores
  static const String progressCollection =
      'progress'; // Learning progress tracking
  static const String achievementsCollection =
      'achievements'; // Available achievements
  static const String userAchievementsCollection =
      'user_achievements'; // Unlocked achievements
  static const String codeChallengesCollection =
      'code_challenges'; // Coding exercises
  static const String leaderboardCollection =
      'leaderboard'; // Competition rankings
  static const String streaksCollection = 'streaks'; // Daily learning streaks

  // Firebase Storage paths for different asset types
  static const String avatarsPath = 'avatars'; // User profile pictures
  static const String courseThumbnailsPath =
      'courses/thumbnails'; // Course cover images
  static const String achievementIconsPath =
      'achievements/icons'; // Achievement badges
  static const String lessonImagesPath =
      'lessons/images'; // Lesson illustrations

  // Common field names for consistency across documents
  static const String timestampField = 'timestamp';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';

  // Security settings to prevent brute force attacks
  static const int maxLoginAttempts = 5;
  static const Duration loginAttemptWindow =
      Duration(minutes: 15); // Reset counter after 15 mins

  // Query optimization - limits data fetched at once
  static const int defaultPageSize = 20; // General pagination
  static const int leaderboardPageSize = 50; // More entries for rankings

  // Experience point rewards for different activities
  static const int xpPerLesson = 10; // Basic lesson completion
  static const int xpPerEasyQuiz = 20; // Beginner quiz
  static const int xpPerMediumQuiz = 35; // Intermediate quiz
  static const int xpPerHardQuiz = 50; // Advanced quiz
  static const int xpPerCodeChallenge = 30; // Coding exercise
  static const int xpPerStreak = 5; // Daily streak bonus
  static const int xpPerAchievement = 25; // Achievement unlock

  // Dynamic level calculation based on total XP
  // Uses square root formula for gradual progression
  static int calculateLevel(int xp) {
    // Level = floor(sqrt(xp / 100)) + 1
    // This creates a nice curve where early levels are easier
    return (math.sqrt(xp / 100)).floor() + 1;
  }

  // Calculate XP required for a specific level
  static int xpForLevel(int level) {
    // XP = (level - 1)^2 * 100
    // Inverse of the level calculation formula
    return ((level - 1) * (level - 1)) * 100;
  }

  // Calculate remaining XP needed for next level
  static int xpForNextLevel(int currentXp) {
    final currentLevel = calculateLevel(currentXp);
    final nextLevel = currentLevel + 1;
    return xpForLevel(nextLevel) - currentXp;
  }

  // Minimum score to pass quizzes
  static const int passingScorePercentage = 70; // 70% correct answers required

  // Streak tracking window - allows missing one day
  static const Duration streakWindow =
      Duration(hours: 36); // 1.5 days flexibility

  // Cache settings to reduce Firebase reads and improve performance
  static const Duration userCacheDuration =
      Duration(minutes: 5); // User data refresh
  static const Duration courseCacheDuration =
      Duration(hours: 1); // Course content refresh
  static const Duration leaderboardCacheDuration =
      Duration(minutes: 10); // Rankings refresh
}
