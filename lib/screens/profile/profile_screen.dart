import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/providers/auth_provider.dart';
import 'package:procode/screens/profile/edit_profile_screen.dart';
import 'package:procode/screens/profile/achievements_screen.dart';
import 'package:procode/screens/profile/widgets/stats_grid.dart';
import 'package:procode/screens/profile/widgets/achievement_badge.dart';
import 'package:procode/screens/leaderboard/leaderboard_screen.dart';
import 'package:procode/screens/settings/settings_screen.dart';
import 'package:procode/widgets/common/loading_widget.dart';
import 'package:procode/widgets/common/error_widget.dart';
import 'package:procode/widgets/common/gradient_container.dart';
import 'package:procode/config/app_colors.dart';
import 'package:procode/models/achievement_model.dart';
import 'package:fl_chart/fl_chart.dart';

/// Main profile screen displaying user information, stats, and achievements
/// Uses a custom sliver app bar with expandable header
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user data when screen initializes
    _loadUserData();
  }

  /// Loads user data from Firebase using the authenticated user's ID
  Future<void> _loadUserData() async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    if (authProvider.user != null) {
      await userProvider.loadUser(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          // Show loading indicator while fetching data
          if (userProvider.isLoading) {
            return const LoadingWidget();
          }

          // Show error widget if data loading failed
          if (userProvider.error != null) {
            return CustomErrorWidget(
              message: userProvider.error!,
              onRetry: _loadUserData,
            );
          }

          final user = userProvider.user;
          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => userProvider.refresh(),
            child: CustomScrollView(
              slivers: [
                // Custom App Bar with gradient background and avatar
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
                            // Avatar with hero animation for smooth transitions
                            Hero(
                              tag: 'profile_avatar',
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundImage: user.avatarUrl != null
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                                  child: user.avatarUrl == null
                                      ? Text(
                                          user.displayName[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // User display name
                            Text(
                              user.displayName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            // Username with @ prefix
                            Text(
                              '@${user.username}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    // Settings Button - quick access to app settings
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    // Leaderboard Button - view rankings
                    IconButton(
                      icon: const Icon(Icons.leaderboard_outlined),
                      tooltip: 'Leaderboard',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen(),
                          ),
                        );
                      },
                    ),
                    // Edit Profile Button
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit Profile',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Profile Content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Bio Section - shows user's bio and location if available
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user.bio!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (user.country != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        user.country!,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Stats Grid - displays user statistics like XP, streak, etc.
                      const StatsGrid(),
                      const SizedBox(height: 16),

                      // Quick Actions Section - shortcuts to settings and leaderboard
                      Row(
                        children: [
                          // Settings Card
                          Expanded(
                            child: Card(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SettingsScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.settings,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Settings',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Leaderboard Card
                          Expanded(
                            child: Card(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LeaderboardScreen(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.leaderboard,
                                            color: AppColors.secondary,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Leaderboard',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Featured Achievements section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Featured Achievements',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AchievementsScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Show placeholder if no achievements featured yet
                              if (user.featuredAchievements.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.emoji_events_outlined,
                                          size: 48,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No featured achievements yet',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                // Display featured achievement badges
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: user.featuredAchievements
                                      .map((achievementId) {
                                    // Find achievement details from provider
                                    final achievement =
                                        userProvider.achievements.firstWhere(
                                      (a) => a.id == achievementId,
                                      orElse: () => Achievement(
                                        id: '',
                                        name: 'Unknown',
                                        description: '',
                                        iconAsset:
                                            'assets/images/achievements/default.png',
                                        xpReward: 0,
                                        category: 'learning',
                                        rarity: 'common',
                                      ),
                                    );
                                    return AchievementBadge(
                                      achievement: achievement,
                                      isUnlocked: true,
                                      size: 80,
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Activity Chart - shows XP earned over last 30 days
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Activity (Last 30 Days)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: _buildActivityChart(user.activityData),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds a line chart showing user's XP activity over the last 30 days
  Widget _buildActivityChart(Map<DateTime, int> activityData) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Generate data points for last 30 days
    final now = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // Normalize date to midnight for consistent keys
      final dateKey = DateTime(date.year, date.month, date.day);
      final xp = activityData[dateKey] ?? 0;
      spots.add(FlSpot(29 - i.toDouble(), xp.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? Colors.white10 : Colors.black12,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 7, // Show dates weekly
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 7 == 0) {
                  final daysAgo = 29 - value.toInt();
                  final date = now.subtract(Duration(days: daysAgo));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${date.day}/${date.month}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 29,
        minY: 0,
        // Dynamic max Y based on highest value plus padding
        maxY:
            spots.map((s) => s.y).fold<double>(0, (a, b) => a > b ? a : b) + 20,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true, // Smooth curve for better aesthetics
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false), // Hide individual dots
            belowBarData: BarAreaData(
              show: true,
              // Gradient fill under the line
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.secondary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
