import 'package:flutter/material.dart';
import 'package:procode/models/achievement_model.dart';

/// Widget displaying an achievement badge with unlock status
/// Shows different styles for locked vs unlocked achievements
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final double size;
  final bool showLabel; // Whether to show achievement name below badge

  const AchievementBadge({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    this.size = 60,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Achievement badge container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Gradient for unlocked achievements, grey for locked
            gradient: isUnlocked
                ? LinearGradient(
                    colors: [
                      _getAchievementColor(achievement.name)[0],
                      _getAchievementColor(achievement.name)[1],
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: !isUnlocked
                ? (isDark ? Colors.grey[800] : Colors.grey[300])
                : null,
            // Glow effect for unlocked achievements
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: _getAchievementColor(achievement.name)[0]
                          .withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            // Show achievement icon or lock icon based on status
            child: isUnlocked
                ? _getAchievementIcon(achievement.iconAsset)
                : Icon(
                    Icons.lock_outline,
                    size: size * 0.4,
                    color: isDark ? Colors.grey[600] : Colors.grey[500],
                  ),
          ),
        ),
        // Optional achievement name label
        if (showLabel) ...[
          const SizedBox(height: 8),
          Text(
            achievement.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isUnlocked
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Returns appropriate emoji icon based on achievement type
  /// TODO: Replace with actual image assets when available
  Widget _getAchievementIcon(String iconAsset) {
    // Map icon asset names to emojis for now
    if (iconAsset.contains('first_steps')) {
      return Text('🎯', style: TextStyle(fontSize: size * 0.5));
    } else if (iconAsset.contains('quiz_master')) {
      return Text('🧠', style: TextStyle(fontSize: size * 0.5));
    } else if (iconAsset.contains('streak')) {
      return Text('🔥', style: TextStyle(fontSize: size * 0.5));
    } else if (iconAsset.contains('level')) {
      return Text('⭐', style: TextStyle(fontSize: size * 0.5));
    } else if (iconAsset.contains('course_complete')) {
      return Text('🎓', style: TextStyle(fontSize: size * 0.5));
    } else if (iconAsset.contains('dedicated')) {
      return Text('💪', style: TextStyle(fontSize: size * 0.5));
    } else if (iconAsset.contains('code_warrior')) {
      return Text('⚔️', style: TextStyle(fontSize: size * 0.5));
    } else if (iconAsset.contains('knowledge')) {
      return Text('📚', style: TextStyle(fontSize: size * 0.5));
    } else {
      return Text('🏆', style: TextStyle(fontSize: size * 0.5));
    }
  }

  /// Returns gradient colors based on achievement category
  /// Each achievement type has its own color scheme
  List<Color> _getAchievementColor(String name) {
    switch (name) {
      case 'First Steps':
        return [Colors.green[400]!, Colors.green[600]!];
      case 'Quiz Master':
        return [Colors.blue[400]!, Colors.blue[600]!];
      case 'Streak Starter':
      case 'Dedicated Learner':
        return [Colors.orange[400]!, Colors.orange[600]!];
      case 'Rising Star':
        return [Colors.purple[400]!, Colors.purple[600]!];
      case 'Course Complete':
        return [Colors.red[400]!, Colors.red[600]!];
      case 'Code Warrior':
        return [Colors.teal[400]!, Colors.teal[600]!];
      case 'Knowledge Seeker':
        return [Colors.amber[400]!, Colors.amber[600]!];
      default:
        return [Colors.grey[400]!, Colors.grey[600]!];
    }
  }
}
