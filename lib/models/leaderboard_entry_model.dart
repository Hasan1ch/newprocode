import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a leaderboard entry
/// Tracks user rankings and competitive statistics
class LeaderboardEntry {
  final String id; // Database identifier
  final String userId; // Reference to user document
  final String username; // Unique username
  final String displayName; // Shown name (can differ from username)
  final String? avatarUrl; // Profile picture URL
  final int totalXP; // All-time experience points
  final int weeklyXP; // XP earned this week
  final int monthlyXP; // XP earned this month
  final int level; // Current user level
  final int currentStreak; // Days of consecutive learning
  final int completedCourses; // Number of finished courses
  final int rank; // Position on leaderboard
  final DateTime lastActive; // Last learning activity
  final DateTime lastUpdated; // Last database sync

  LeaderboardEntry({
    String? id, // Optional - defaults to userId
    required this.userId,
    required this.username,
    String? displayName, // Optional - defaults to username
    this.avatarUrl,
    required this.totalXP,
    int? weeklyXP, // Optional - defaults to 0
    int? monthlyXP, // Optional - defaults to 0
    required this.level,
    required this.currentStreak,
    required this.completedCourses,
    int? rank, // Optional - defaults to 0
    required this.lastActive,
    DateTime? lastUpdated, // Optional - defaults to lastActive
  })  : id = id ?? userId, // Fallback to userId if no id provided
        displayName = displayName ?? username, // Fallback to username
        weeklyXP = weeklyXP ?? 0,
        monthlyXP = monthlyXP ?? 0,
        rank = rank ?? 0,
        lastUpdated = lastUpdated ?? lastActive;

  /// Creates leaderboard entry from Firestore document
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] ?? json['userId'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
      totalXP: json['totalXP'] ?? 0,
      weeklyXP: json['weeklyXP'] ?? 0,
      monthlyXP: json['monthlyXP'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['currentStreak'] ?? 0,
      completedCourses: json['completedCourses'] ?? 0,
      rank: json['rank'] ?? 0,
      // Handle both Timestamp and String date formats
      lastActive: json['lastActive'] != null
          ? (json['lastActive'] is Timestamp
              ? (json['lastActive'] as Timestamp).toDate()
              : DateTime.parse(json['lastActive']))
          : (json['lastUpdated'] != null
              ? (json['lastUpdated'] is Timestamp
                  ? (json['lastUpdated'] as Timestamp).toDate()
                  : DateTime.parse(json['lastUpdated']))
              : DateTime.now()),
      lastUpdated: json['lastUpdated'] != null
          ? (json['lastUpdated'] is Timestamp
              ? (json['lastUpdated'] as Timestamp).toDate()
              : DateTime.parse(json['lastUpdated']))
          : (json['lastActive'] != null
              ? (json['lastActive'] is Timestamp
                  ? (json['lastActive'] as Timestamp).toDate()
                  : DateTime.parse(json['lastActive']))
              : DateTime.now()),
    );
  }

  /// Converts entry to Firestore document format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'totalXP': totalXP,
      'weeklyXP': weeklyXP,
      'monthlyXP': monthlyXP,
      'level': level,
      'currentStreak': currentStreak,
      'completedCourses': completedCourses,
      'rank': rank,
      'lastActive': Timestamp.fromDate(lastActive),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Creates a modified copy of the entry
  LeaderboardEntry copyWith({
    String? id,
    String? userId,
    String? username,
    String? displayName,
    String? avatarUrl,
    int? totalXP,
    int? weeklyXP,
    int? monthlyXP,
    int? level,
    int? currentStreak,
    int? completedCourses,
    int? rank,
    DateTime? lastActive,
    DateTime? lastUpdated,
  }) {
    return LeaderboardEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalXP: totalXP ?? this.totalXP,
      weeklyXP: weeklyXP ?? this.weeklyXP,
      monthlyXP: monthlyXP ?? this.monthlyXP,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      completedCourses: completedCourses ?? this.completedCourses,
      rank: rank ?? this.rank,
      lastActive: lastActive ?? this.lastActive,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Compares entries for leaderboard sorting
  /// Higher XP ranks higher
  int compareTo(LeaderboardEntry other) {
    // Sort by total XP in descending order
    return other.totalXP.compareTo(totalXP);
  }

  /// Checks if this entry belongs to the current user
  /// Used to highlight user's position
  bool isCurrentUser(String currentUserId) {
    return userId == currentUserId;
  }

  /// Formats large XP numbers for compact display
  /// Examples: 1.5M, 23.4K, 999
  String getFormattedXP() {
    if (totalXP >= 1000000) {
      return '${(totalXP / 1000000).toStringAsFixed(1)}M';
    } else if (totalXP >= 1000) {
      return '${(totalXP / 1000).toStringAsFixed(1)}K';
    }
    return totalXP.toString();
  }

  /// Formats rank with proper ordinal suffix
  /// Examples: 1st, 2nd, 3rd, 4th, 21st
  String getRankDisplay() {
    if (rank <= 0) return '-';

    // Special case for 11th, 12th, 13th
    if (rank % 100 >= 11 && rank % 100 <= 13) {
      return '${rank}th';
    }

    // Standard ordinal rules
    switch (rank % 10) {
      case 1:
        return '${rank}st';
      case 2:
        return '${rank}nd';
      case 3:
        return '${rank}rd';
      default:
        return '${rank}th';
    }
  }

  /// Returns color for rank badges
  /// Top 3 get special colors
  String getRankBadgeColor() {
    switch (rank) {
      case 1:
        return '#FFD700'; // Gold for 1st place
      case 2:
        return '#C0C0C0'; // Silver for 2nd place
      case 3:
        return '#CD7F32'; // Bronze for 3rd place
      default:
        return '#9E9E9E'; // Gray for everyone else
    }
  }
}
