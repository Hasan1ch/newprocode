import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a leaderboard entry
class LeaderboardEntry {
  final String userId;
  final String username;
  final String? avatarUrl;
  final int totalXP;
  final int level;
  final int currentStreak;
  final int completedCourses;
  final DateTime lastActive;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.totalXP,
    required this.level,
    required this.currentStreak,
    required this.completedCourses,
    required this.lastActive,
  });

  /// Create LeaderboardEntry from JSON
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
      totalXP: json['totalXP'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['currentStreak'] ?? 0,
      completedCourses: json['completedCourses'] ?? 0,
      lastActive: json['lastActive'] != null
          ? (json['lastActive'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert LeaderboardEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'totalXP': totalXP,
      'level': level,
      'currentStreak': currentStreak,
      'completedCourses': completedCourses,
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  /// Create a copy with updated fields
  LeaderboardEntry copyWith({
    String? userId,
    String? username,
    String? avatarUrl,
    int? totalXP,
    int? level,
    int? currentStreak,
    int? completedCourses,
    DateTime? lastActive,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      completedCourses: completedCourses ?? this.completedCourses,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
