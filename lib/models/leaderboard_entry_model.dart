import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a leaderboard entry
class LeaderboardEntry {
  final String id; // Added for database service compatibility
  final String userId;
  final String username;
  final String displayName; // Added for database service
  final String? avatarUrl;
  final int totalXP;
  final int weeklyXP; // Added for weekly leaderboard
  final int monthlyXP; // Added for monthly leaderboard
  final int level;
  final int currentStreak;
  final int completedCourses;
  final int rank; // Added for ranking
  final DateTime lastActive;
  final DateTime lastUpdated; // Added for database service

  LeaderboardEntry({
    String? id, // Made optional with fallback to userId
    required this.userId,
    required this.username,
    String? displayName, // Made optional with fallback to username
    this.avatarUrl,
    required this.totalXP,
    int? weeklyXP, // Made optional with default
    int? monthlyXP, // Made optional with default
    required this.level,
    required this.currentStreak,
    required this.completedCourses,
    int? rank, // Made optional with default
    required this.lastActive,
    DateTime? lastUpdated, // Made optional with fallback
  })  : id = id ?? userId, // Use userId as id if not provided
        displayName = displayName ??
            username, // Use username as displayName if not provided
        weeklyXP = weeklyXP ?? 0,
        monthlyXP = monthlyXP ?? 0,
        rank = rank ?? 0,
        lastUpdated = lastUpdated ?? lastActive;

  /// Create LeaderboardEntry from JSON
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

  /// Convert LeaderboardEntry to JSON
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

  /// Create a copy with updated fields
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

  /// Compare entries for sorting
  int compareTo(LeaderboardEntry other) {
    // Sort by total XP in descending order
    return other.totalXP.compareTo(totalXP);
  }

  /// Check if this entry represents the current user
  bool isCurrentUser(String currentUserId) {
    return userId == currentUserId;
  }

  /// Get formatted XP display
  String getFormattedXP() {
    if (totalXP >= 1000000) {
      return '${(totalXP / 1000000).toStringAsFixed(1)}M';
    } else if (totalXP >= 1000) {
      return '${(totalXP / 1000).toStringAsFixed(1)}K';
    }
    return totalXP.toString();
  }

  /// Get rank display with suffix
  String getRankDisplay() {
    if (rank <= 0) return '-';

    if (rank % 100 >= 11 && rank % 100 <= 13) {
      return '${rank}th';
    }

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

  /// Get rank badge color based on position
  String getRankBadgeColor() {
    switch (rank) {
      case 1:
        return '#FFD700'; // Gold
      case 2:
        return '#C0C0C0'; // Silver
      case 3:
        return '#CD7F32'; // Bronze
      default:
        return '#9E9E9E'; // Default gray
    }
  }
}
