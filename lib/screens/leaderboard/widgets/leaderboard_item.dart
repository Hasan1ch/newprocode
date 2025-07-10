import 'package:flutter/material.dart';
import 'package:procode/models/leaderboard_entry_model.dart';
import 'package:procode/config/theme.dart';

/// Individual leaderboard entry widget displaying user ranking and stats
/// Highlights current user's entry with special styling
class LeaderboardItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardItem({
    Key? key,
    required this.entry,
    required this.rank,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        // Special gradient for current user to make them stand out
        gradient: isCurrentUser
            ? LinearGradient(
                colors: isDark
                    ? [
                        // Subtle gradient in dark mode
                        AppTheme.primaryGradient.colors[0].withOpacity(0.2),
                        AppTheme.primaryGradient.colors[1].withOpacity(0.2),
                      ]
                    : AppTheme.primaryGradient.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !isCurrentUser ? Theme.of(context).colorScheme.surface : null,
        borderRadius: BorderRadius.circular(12),
        // Shadow effect for depth
        boxShadow: [
          BoxShadow(
            color: (isCurrentUser && !isDark
                    ? AppTheme.primaryGradient.colors[0]
                    : Colors.black)
                .withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to user profile screen
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Rank indicator with special styling for top 3
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getRankColor(rank).withOpacity(isDark ? 0.3 : 0.2),
                  ),
                  child: Center(
                    child: rank <= 3
                        ? Icon(
                            _getRankIcon(rank),
                            color: _getRankColor(rank),
                            size: 28,
                          )
                        : Text(
                            '#$rank',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isCurrentUser && !isDark
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // User avatar with fallback to initial
                CircleAvatar(
                  radius: 20,
                  backgroundImage: entry.avatarUrl != null
                      ? NetworkImage(entry.avatarUrl!)
                      : null,
                  child: entry.avatarUrl == null
                      ? Text(
                          entry.username[0].toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCurrentUser && !isDark
                                ? AppTheme.primaryGradient.colors[0]
                                : null,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Username with overflow handling
                Expanded(
                  child: Text(
                    entry.username,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isCurrentUser && !isDark
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Stats section: streak, level, and XP
                Row(
                  children: [
                    // Streak indicator (only shown if user has active streak)
                    if (entry.currentStreak > 0) ...[
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: isCurrentUser && !isDark
                            ? Colors.white
                            : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.currentStreak}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: isCurrentUser && !isDark
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Level badge with color coding
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getLevelColor(entry.level).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Lv.${entry.level}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser && !isDark
                              ? Colors.white
                              : _getLevelColor(entry.level),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // XP display
                    Row(
                      children: [
                        Icon(
                          Icons.bolt,
                          size: 18,
                          color: isCurrentUser && !isDark
                              ? Colors.white
                              : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.totalXP}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isCurrentUser && !isDark
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns appropriate icon for top 3 ranks
  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // Trophy for first place
      case 2:
        return Icons.military_tech; // Medal for second place
      case 3:
        return Icons.grade; // Star for third place
      default:
        return Icons.star;
    }
  }

  /// Returns color theme for different ranks
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey; // Silver
      case 3:
        return Colors.brown; // Bronze
      default:
        return Colors.blue;
    }
  }

  /// Returns color based on user level for visual progression
  Color _getLevelColor(int level) {
    if (level >= 7) return Colors.purple; // Expert level
    if (level >= 5) return Colors.indigo; // Advanced level
    if (level >= 3) return Colors.blue; // Intermediate level
    return Colors.green; // Beginner level
  }
}
