import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/leaderboard_provider.dart';
import 'package:procode/providers/auth_provider.dart';
import 'package:procode/models/leaderboard_entry_model.dart';
import 'package:procode/screens/leaderboard/widgets/leaderboard_item.dart';
import 'package:procode/screens/leaderboard/widgets/filter_chips.dart';
import 'package:procode/widgets/common/loading_widget.dart';
import 'package:procode/widgets/common/error_widget.dart';
import 'package:procode/widgets/common/gradient_container.dart';
import 'package:procode/config/app_colors.dart';

/// Main leaderboard screen showing user rankings with special top 3 display
/// Supports filtering by global rankings or individual course rankings
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String? _userId; // Current user's ID for highlighting their entry

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  /// Loads leaderboard data with current user context
  Future<void> _loadLeaderboard() async {
    final authProvider = context.read<AuthProvider>();
    _userId = authProvider.user?.uid;

    final leaderboardProvider = context.read<LeaderboardProvider>();
    await leaderboardProvider.loadLeaderboard(userId: _userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<LeaderboardProvider>(
        builder: (context, leaderboardProvider, _) {
          return CustomScrollView(
            slivers: [
              // Expandable app bar with gradient background
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                flexibleSpace: FlexibleSpaceBar(
                  background: GradientContainer(
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Trophy icon for visual appeal
                          const Icon(
                            Icons.emoji_events,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Leaderboard',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          // Show user's rank if available
                          if (leaderboardProvider.userRank != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Your Rank: #${leaderboardProvider.userRank}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Sticky filter chips header
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterHeaderDelegate(
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                      children: [
                        FilterChips(
                          currentFilter: leaderboardProvider.currentFilter,
                          onFilterChanged: (filter, {courseId}) {
                            leaderboardProvider.setFilter(filter,
                                courseId: courseId);
                          },
                        ),
                        const Divider(height: 1),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content area with different states
              if (leaderboardProvider.isLoading)
                const SliverFillRemaining(
                  child: LoadingWidget(),
                )
              else if (leaderboardProvider.error != null)
                SliverFillRemaining(
                  child: CustomErrorWidget(
                    message: leaderboardProvider.error!,
                    onRetry: _loadLeaderboard,
                  ),
                )
              else if (leaderboardProvider.entries.isEmpty)
                // Empty state with helpful message
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.leaderboard_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No leaderboard data available',
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getEmptyMessage(leaderboardProvider.currentFilter),
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Leaderboard entries list
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Special display for top 3 users
                        if (index == 0 &&
                            leaderboardProvider.entries.length >= 3) {
                          return Column(
                            children: [
                              _buildTop3Section(leaderboardProvider),
                              const SizedBox(height: 24),
                              // Section header for remaining entries
                              if (leaderboardProvider.entries.length > 3)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    'Other Rankings',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }

                        // Adjust index to account for top 3 special display
                        final adjustedIndex =
                            leaderboardProvider.entries.length >= 3
                                ? (index == 0 ? -1 : index + 2)
                                : index;

                        if (adjustedIndex == -1) return const SizedBox.shrink();

                        // Show user's position if they're not in visible list
                        if (adjustedIndex ==
                                leaderboardProvider.entries.length &&
                            leaderboardProvider.userEntry != null &&
                            leaderboardProvider.userRank != null &&
                            leaderboardProvider.userRank! > 100) {
                          return Column(
                            children: [
                              // Divider with "Your Position" label
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(child: Divider()),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Text('Your Position'),
                                    ),
                                    Expanded(child: Divider()),
                                  ],
                                ),
                              ),
                              LeaderboardItem(
                                entry: leaderboardProvider.userEntry!,
                                rank: leaderboardProvider.userRank!,
                                isCurrentUser: true,
                              ),
                            ],
                          );
                        }

                        if (adjustedIndex >=
                            leaderboardProvider.entries.length) {
                          return const SizedBox.shrink();
                        }

                        // Regular leaderboard entries
                        final entry =
                            leaderboardProvider.entries[adjustedIndex];
                        final rank = adjustedIndex + 1;
                        final isCurrentUser = entry.userId == _userId;

                        return LeaderboardItem(
                          entry: entry,
                          rank: rank,
                          isCurrentUser: isCurrentUser,
                        );
                      },
                      // Calculate total items including special sections
                      childCount: leaderboardProvider.entries.length >= 3
                          ? leaderboardProvider.entries.length -
                              2 +
                              (leaderboardProvider.userEntry != null &&
                                      leaderboardProvider.userRank != null &&
                                      leaderboardProvider.userRank! > 100
                                  ? 1
                                  : 0)
                          : leaderboardProvider.entries.length +
                              (leaderboardProvider.userEntry != null &&
                                      leaderboardProvider.userRank != null &&
                                      leaderboardProvider.userRank! > 100
                                  ? 1
                                  : 0),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Builds special podium-style display for top 3 users
  Widget _buildTop3Section(LeaderboardProvider provider) {
    final top3 = provider.entries.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Gradient background for emphasis
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second place (left side)
          if (top3.length > 1)
            Expanded(
              child: _buildTopUserCard(
                entry: top3[1],
                rank: 2,
                height: 120,
                isCurrentUser: top3[1].userId == _userId,
              ),
            ),

          // First place (center, tallest)
          if (top3.isNotEmpty)
            Expanded(
              child: _buildTopUserCard(
                entry: top3[0],
                rank: 1,
                height: 150,
                isCurrentUser: top3[0].userId == _userId,
              ),
            ),

          // Third place (right side)
          if (top3.length > 2)
            Expanded(
              child: _buildTopUserCard(
                entry: top3[2],
                rank: 3,
                height: 100,
                isCurrentUser: top3[2].userId == _userId,
              ),
            ),
        ],
      ),
    );
  }

  /// Builds individual card for top 3 users with special styling
  Widget _buildTopUserCard({
    required LeaderboardEntry entry,
    required int rank,
    required double height,
    required bool isCurrentUser,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Trophy/medal icon
        Icon(
          rank == 1 ? Icons.emoji_events : Icons.military_tech,
          color: _getRankColor(rank),
          size: rank == 1 ? 40 : 32,
        ),
        const SizedBox(height: 8),

        // User avatar with rank badge
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 40 : 35,
              backgroundImage: entry.avatarUrl != null
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              backgroundColor: isCurrentUser
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
              child: entry.avatarUrl == null
                  ? Text(
                      entry.username[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: rank == 1 ? 28 : 24,
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
            ),
            // Rank number badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _getRankColor(rank),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Username
        Text(
          entry.username,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: rank == 1 ? 16 : 14,
            color: isCurrentUser
                ? AppColors.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),

        // XP display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bolt,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.totalXP}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: rank == 1 ? 16 : 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ),

        // Level badge
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getLevelColor(entry.level).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Lv.${entry.level}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getLevelColor(entry.level),
            ),
          ),
        ),
      ],
    );
  }

  /// Returns color for rank medals
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

  /// Returns color based on level progression
  Color _getLevelColor(int level) {
    if (level >= 7) return Colors.purple;
    if (level >= 5) return Colors.indigo;
    if (level >= 3) return Colors.blue;
    return Colors.green;
  }

  /// Provides contextual empty state messages
  String _getEmptyMessage(LeaderboardFilter filter) {
    switch (filter) {
      case LeaderboardFilter.global:
        return 'Start learning to appear on the global leaderboard!';
      case LeaderboardFilter.byCourse:
        return 'Enroll in a course and complete lessons to compete!';
    }
  }
}

/// Custom sliver delegate for sticky filter header
class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
