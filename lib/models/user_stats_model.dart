import 'package:cloud_firestore/cloud_firestore.dart';

/// Dedicated model for user statistics and analytics
/// Tracks detailed learning metrics for leaderboards and progress visualization
class UserStats {
  final String uid;
  // Core gamification metrics
  final int totalXP;
  final int level;
  final int currentStreak;
  final int longestStreak;
  // Learning activity counters
  final int lessonsCompleted;
  final int quizzesCompleted;
  final int challengesCompleted;
  final int coursesCompleted;
  final int perfectQuizzes; // Quizzes with 100% score
  final int totalTimeSpent; // in minutes
  final DateTime lastActiveDate;
  // Historical data for analytics and charts
  final Map<String, int> xpHistory; // date -> xp earned that day
  final Map<String, int> dailyXP; // date -> cumulative xp total

  UserStats({
    required this.uid,
    required this.totalXP,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.lessonsCompleted,
    required this.quizzesCompleted,
    required this.challengesCompleted,
    required this.coursesCompleted,
    required this.perfectQuizzes,
    required this.totalTimeSpent,
    required this.lastActiveDate,
    required this.xpHistory,
    required this.dailyXP,
  });

  // Create from Firestore document with field mapping
  // Handles multiple field names for backward compatibility
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      uid: json['uid'] ?? '',
      totalXP: json['totalXP'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      // Handle both new and legacy field names for smooth migration
      lessonsCompleted:
          json['lessonsCompleted'] ?? json['totalLessonsCompleted'] ?? 0,
      quizzesCompleted:
          json['quizzesCompleted'] ?? json['totalQuizzesCompleted'] ?? 0,
      challengesCompleted:
          json['challengesCompleted'] ?? json['totalChallengesCompleted'] ?? 0,
      coursesCompleted:
          json['coursesCompleted'] ?? json['totalCoursesCompleted'] ?? 0,
      perfectQuizzes: json['perfectQuizzes'] ?? 0,
      totalTimeSpent: json['totalTimeSpent'] ?? 0,
      // Flexible date parsing handles both Timestamp and String formats
      lastActiveDate: json['lastActiveDate'] != null
          ? (json['lastActiveDate'] is Timestamp
              ? (json['lastActiveDate'] as Timestamp).toDate()
              : DateTime.parse(json['lastActiveDate'].toString()))
          : (json['lastUpdated'] != null // Fallback to lastUpdated field
              ? (json['lastUpdated'] is Timestamp
                  ? (json['lastUpdated'] as Timestamp).toDate()
                  : DateTime.parse(json['lastUpdated'].toString()))
              : DateTime.now()),
      xpHistory: Map<String, int>.from(json['xpHistory'] ?? {}),
      dailyXP: Map<String, int>.from(json['dailyXP'] ?? {}),
    );
  }

  // Convert to Firestore document
  // Maintains backward compatibility by writing both old and new field names
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'totalXP': totalXP,
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lessonsCompleted': lessonsCompleted,
      'quizzesCompleted': quizzesCompleted,
      'challengesCompleted': challengesCompleted,
      'coursesCompleted': coursesCompleted,
      'perfectQuizzes': perfectQuizzes,
      'totalTimeSpent': totalTimeSpent,
      'lastActiveDate': Timestamp.fromDate(lastActiveDate),
      'xpHistory': xpHistory,
      'dailyXP': dailyXP,
      // Legacy field names for older app versions
      'totalLessonsCompleted': lessonsCompleted,
      'totalQuizzesCompleted': quizzesCompleted,
      'totalChallengesCompleted': challengesCompleted,
      'totalCoursesCompleted': coursesCompleted,
      'lastUpdated': FieldValue.serverTimestamp(), // Auto-update timestamp
    };
  }

  // Copy with method for updates
  // Essential for state management when incrementing stats
  UserStats copyWith({
    int? totalXP,
    int? level,
    int? currentStreak,
    int? longestStreak,
    int? lessonsCompleted,
    int? quizzesCompleted,
    int? challengesCompleted,
    int? coursesCompleted,
    int? perfectQuizzes,
    int? totalTimeSpent,
    DateTime? lastActiveDate,
    Map<String, int>? xpHistory,
    Map<String, int>? dailyXP,
  }) {
    return UserStats(
      uid: uid,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      challengesCompleted: challengesCompleted ?? this.challengesCompleted,
      coursesCompleted: coursesCompleted ?? this.coursesCompleted,
      perfectQuizzes: perfectQuizzes ?? this.perfectQuizzes,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      xpHistory: xpHistory ?? this.xpHistory,
      dailyXP: dailyXP ?? this.dailyXP,
    );
  }

  // Helper method to get XP for a specific date
  // Used for activity calendar and streak calculations
  int getXPForDate(DateTime date) {
    // Format date as YYYY-MM-DD for consistent key format
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return dailyXP[dateKey] ?? 0;
  }

  // Helper method to get total XP for last N days
  // Powers the weekly/monthly XP displays on dashboard
  int getXPForLastDays(int days) {
    final now = DateTime.now();
    int totalXP = 0;

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      totalXP += getXPForDate(date);
    }

    return totalXP;
  }

  // Get weekly XP for leaderboards
  int get weeklyXP => getXPForLastDays(7);

  // Get monthly XP for progress reports
  int get monthlyXP => getXPForLastDays(30);

  // Check if user is active today
  // Used for streak maintenance logic
  bool get isActiveToday {
    final now = DateTime.now();
    return lastActiveDate.year == now.year &&
        lastActiveDate.month == now.month &&
        lastActiveDate.day == now.day;
  }

  // Get completion rate
  // Calculates quiz perfection rate for achievements
  double get completionRate {
    final totalCompleted =
        lessonsCompleted + quizzesCompleted + challengesCompleted;
    return totalCompleted > 0 ? (perfectQuizzes / quizzesCompleted) : 0.0;
  }

  @override
  String toString() {
    return 'UserStats(uid: $uid, totalXP: $totalXP, level: $level, streak: $currentStreak)';
  }
}
