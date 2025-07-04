import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  final String uid;
  final int totalXP;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int lessonsCompleted;
  final int quizzesCompleted;
  final int challengesCompleted;
  final int coursesCompleted;
  final int perfectQuizzes;
  final int totalTimeSpent; // in minutes
  final DateTime lastActiveDate;
  final Map<String, int> xpHistory; // date -> xp earned
  final Map<String, int> dailyXP; // date -> total xp for that day

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
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      uid: json['uid'] ?? '',
      totalXP: json['totalXP'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      // Handle both field names for backward compatibility
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
      lastActiveDate: json['lastActiveDate'] != null
          ? (json['lastActiveDate'] is Timestamp
              ? (json['lastActiveDate'] as Timestamp).toDate()
              : DateTime.parse(json['lastActiveDate'].toString()))
          : (json['lastUpdated'] !=
                  null // Fallback to lastUpdated if lastActiveDate is null
              ? (json['lastUpdated'] is Timestamp
                  ? (json['lastUpdated'] as Timestamp).toDate()
                  : DateTime.parse(json['lastUpdated'].toString()))
              : DateTime.now()),
      xpHistory: Map<String, int>.from(json['xpHistory'] ?? {}),
      dailyXP: Map<String, int>.from(json['dailyXP'] ?? {}),
    );
  }

  // Convert to Firestore document
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
      // Also include old field names for compatibility
      'totalLessonsCompleted': lessonsCompleted,
      'totalQuizzesCompleted': quizzesCompleted,
      'totalChallengesCompleted': challengesCompleted,
      'totalCoursesCompleted': coursesCompleted,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  // Copy with method for updates
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
  int getXPForDate(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return dailyXP[dateKey] ?? 0;
  }

  // Helper method to get total XP for last N days
  int getXPForLastDays(int days) {
    final now = DateTime.now();
    int totalXP = 0;

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      totalXP += getXPForDate(date);
    }

    return totalXP;
  }

  // Get weekly XP
  int get weeklyXP => getXPForLastDays(7);

  // Get monthly XP
  int get monthlyXP => getXPForLastDays(30);

  // Check if user is active today
  bool get isActiveToday {
    final now = DateTime.now();
    return lastActiveDate.year == now.year &&
        lastActiveDate.month == now.month &&
        lastActiveDate.day == now.day;
  }

  // Get completion rate
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
