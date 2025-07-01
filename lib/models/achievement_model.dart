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
      iconAsset: json['iconAsset'] ?? '',
      xpReward: json['xpReward'] ?? 0,
      category: json['category'] ?? 'learning',
      rarity: json['rarity'] ?? 'common',
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
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
      'xpReward': xpReward,
      'category': category,
      'rarity': rarity,
      'unlockedAt': unlockedAt?.toIso8601String(),
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
}

// Type alias for backward compatibility
typedef Achievement = AchievementModel;
