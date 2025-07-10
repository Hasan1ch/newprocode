import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing an achievement in the gamification system
/// Achievements motivate users by rewarding progress milestones
class AchievementModel {
  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final int xpReward;
  final String
      category; // Type of achievement: learning, social, dedication, mastery
  final String rarity; // How difficult to obtain: common, rare, epic, legendary
  final DateTime? unlockedAt; // When user earned this achievement

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.xpReward,
    required this.category,
    required this.rarity,
    this.unlockedAt,
  });

  /// Creates achievement from Firestore document data
  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      // Handles both field names for backward compatibility
      iconAsset: json['iconAsset'] ?? json['icon'] ?? '',
      xpReward: json['xpReward'] ?? 0,
      category: json['category'] ?? 'learning',
      rarity: json['rarity'] ?? 'common',
      unlockedAt: json['unlockedAt'] != null
          ? (json['unlockedAt'] is Timestamp
              ? (json['unlockedAt'] as Timestamp).toDate()
              : DateTime.parse(json['unlockedAt']))
          : null,
    );
  }

  /// Converts achievement to Firestore document format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconAsset': iconAsset,
      'icon': iconAsset, // Duplicate field for compatibility with older data
      'xpReward': xpReward,
      'category': category,
      'rarity': rarity,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
    };
  }

  /// Creates a modified copy of the achievement
  AchievementModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconAsset,
    int? xpReward,
    String? category,
    String? rarity,
    DateTime? unlockedAt,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconAsset: iconAsset ?? this.iconAsset,
      xpReward: xpReward ?? this.xpReward,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  /// Quick check if user has earned this achievement
  bool get isUnlocked => unlockedAt != null;

  /// Returns hex color code based on achievement rarity
  String get rarityColor {
    switch (rarity) {
      case 'common':
        return '#808080'; // Gray - easily obtainable
      case 'rare':
        return '#0080FF'; // Blue - moderate challenge
      case 'epic':
        return '#B300FF'; // Purple - significant accomplishment
      case 'legendary':
        return '#FFD700'; // Gold - elite status
      default:
        return '#808080';
    }
  }

  /// XP bonus multiplier based on rarity
  /// Rarer achievements give more XP to reward difficulty
  double get rarityMultiplier {
    switch (rarity) {
      case 'common':
        return 1.0; // Base XP
      case 'rare':
        return 1.5; // 50% bonus
      case 'epic':
        return 2.0; // Double XP
      case 'legendary':
        return 3.0; // Triple XP
      default:
        return 1.0;
    }
  }

  /// Gets appropriate icon - either emoji or asset path
  String get displayIcon {
    // Short strings are likely emojis
    if (iconAsset.length <= 2 || iconAsset.startsWith('assets/')) {
      return iconAsset;
    }
    // Fallback emoji mapping for common achievements
    switch (id) {
      case 'first_steps':
        return '👶';
      case 'quiz_master':
        return '🎯';
      case 'streak_starter':
        return '🔥';
      case 'level_5':
        return '⭐';
      case 'course_complete':
        return '🎓';
      case 'dedicated_learner':
        return '💪';
      case 'code_warrior':
        return '⚔️';
      case 'knowledge_seeker':
        return '📚';
      default:
        return '🏆'; // Generic trophy
    }
  }

  /// Combines description with XP reward for display
  String get fullDescription {
    return '$description (+$xpReward XP)';
  }

  /// Checks if user stats meet requirements for this achievement
  /// Each achievement has specific unlock criteria
  bool meetsUnlockCriteria({
    int? lessonsCompleted,
    int? quizzesCompleted,
    int? perfectQuizzes,
    int? currentStreak,
    int? level,
    int? coursesCompleted,
    int? challengesCompleted,
  }) {
    switch (id) {
      case 'first_steps':
        return (lessonsCompleted ?? 0) >= 1; // Complete first lesson
      case 'quiz_master':
        return (perfectQuizzes ?? 0) >= 10; // 10 perfect quiz scores
      case 'streak_starter':
        return (currentStreak ?? 0) >= 7; // 7-day streak
      case 'level_5':
        return (level ?? 0) >= 5; // Reach level 5
      case 'course_complete':
        return (coursesCompleted ?? 0) >= 1; // Finish first course
      case 'dedicated_learner':
        return (currentStreak ?? 0) >= 30; // 30-day streak
      case 'code_warrior':
        return (challengesCompleted ?? 0) >= 50; // 50 code challenges
      case 'knowledge_seeker':
        return (coursesCompleted ?? 0) >= 5; // Complete 5 courses
      default:
        return false;
    }
  }

  @override
  String toString() {
    return 'AchievementModel(id: $id, name: $name, category: $category, rarity: $rarity, unlocked: $isUnlocked)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AchievementModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Alias for backward compatibility with older code
typedef Achievement = AchievementModel;
