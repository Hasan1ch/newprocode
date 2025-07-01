import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/leaderboard_provider.dart';
import 'package:procode/providers/auth_provider.dart';
import 'package:procode/screens/leaderboard/widgets/leaderboard_item.dart';
import 'package:procode/screens/leaderboard/widgets/filter_chips.dart';
import 'package:procode/widgets/common/loading_widget.dart';
import 'package:procode/widgets/common/error_widget.dart';
import 'package:procode/widgets/common/gradient_container.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

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
              // Custom App Bar
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

              // Filter Chips
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

              // Content
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
                const SliverFillRemaining(
                  child: Center(
                    child: Text('No leaderboard data available'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Show user's entry if not in top list
                        if (index == leaderboardProvider.entries.length &&
                            leaderboardProvider.userEntry != null &&
                            leaderboardProvider.userRank != null &&
                            leaderboardProvider.userRank! > 100) {
                          return Column(
                            children: [
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

                        final entry = leaderboardProvider.entries[index];
                        final rank = index + 1;
                        final isCurrentUser = entry.userId == _userId;

                        return LeaderboardItem(
                          entry: entry,
                          rank: rank,
                          isCurrentUser: isCurrentUser,
                        );
                      },
                      childCount: leaderboardProvider.entries.length +
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
}

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
