import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing an achievement
class AchievementModel {
  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final int xpReward;
  final String category; // learning, social, dedication, mastery
  final String rarity; // common, rare, epic, legendary
  final DateTime? unlockedAt;

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

  /// Create AchievementModel from JSON
  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      // Handle both 'icon' and 'iconAsset' fields for Firebase compatibility
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

  /// Convert AchievementModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconAsset': iconAsset,
      'icon': iconAsset, // Include both for compatibility
      'xpReward': xpReward,
      'category': category,
      'rarity': rarity,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
    };
  }

  /// Create a copy with updated fields
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

  /// Check if achievement is unlocked
  bool get isUnlocked => unlockedAt != null;

  /// Get rarity color
  String get rarityColor {
    switch (rarity) {
      case 'common':
        return '#808080'; // Gray
      case 'rare':
        return '#0080FF'; // Blue
      case 'epic':
        return '#B300FF'; // Purple
      case 'legendary':
        return '#FFD700'; // Gold
      default:
        return '#808080';
    }
  }

  /// Get rarity XP multiplier
  double get rarityMultiplier {
    switch (rarity) {
      case 'common':
        return 1.0;
      case 'rare':
        return 1.5;
      case 'epic':
        return 2.0;
      case 'legendary':
        return 3.0;
      default:
        return 1.0;
    }
  }

  /// Get achievement icon emoji or asset path
  String get displayIcon {
    // If iconAsset looks like an emoji (single character or short string), return it
    if (iconAsset.length <= 2 || iconAsset.startsWith('assets/')) {
      return iconAsset;
    }
    // Otherwise, try to map common achievement names to emojis
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
        return '🏆';
    }
  }

  /// Get achievement description with XP
  String get fullDescription {
    return '$description (+$xpReward XP)';
  }

  /// Check if achievement meets unlock criteria
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
        return (lessonsCompleted ?? 0) >= 1;
      case 'quiz_master':
        return (perfectQuizzes ?? 0) >= 10;
      case 'streak_starter':
        return (currentStreak ?? 0) >= 7;
      case 'level_5':
        return (level ?? 0) >= 5;
      case 'course_complete':
        return (coursesCompleted ?? 0) >= 1;
      case 'dedicated_learner':
        return (currentStreak ?? 0) >= 30;
      case 'code_warrior':
        return (challengesCompleted ?? 0) >= 50;
      case 'knowledge_seeker':
        return (coursesCompleted ?? 0) >= 5;
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

// Type alias for backward compatibility
typedef Achievement = AchievementModel;
