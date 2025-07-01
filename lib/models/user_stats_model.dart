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

  // Create from Firestore document
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      uid: json['uid'] ?? '',
      totalXP: json['totalXP'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      quizzesCompleted: json['quizzesCompleted'] ?? 0,
      challengesCompleted: json['challengesCompleted'] ?? 0,
      coursesCompleted: json['coursesCompleted'] ?? 0,
      perfectQuizzes: json['perfectQuizzes'] ?? 0,
      totalTimeSpent: json['totalTimeSpent'] ?? 0,
      lastActiveDate:
          (json['lastActiveDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
}
