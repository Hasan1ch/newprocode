import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/models/achievement_model.dart';
import 'package:procode/screens/profile/widgets/achievement_badge.dart';
import 'package:procode/widgets/common/loading_widget.dart';

import 'package:procode/config/constants.dart' as constants;

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Unlocked'),
            Tab(text: 'Locked'),
          ],
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return const LoadingWidget();
          }

          final user = userProvider.user;
          final achievements = userProvider.achievements;

          if (user == null || achievements.isEmpty) {
            return const Center(
              child: Text('No achievements available'),
            );
          }

          // Get all possible achievements
          final allAchievements = constants.achievements;

          // Separate unlocked and locked
          final unlockedAchievements = achievements.toList();
          final lockedAchievements = allAchievements
              .where((a) => !achievements.any((ua) => ua.id == a.id))
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // Unlocked Achievements
              _buildAchievementGrid(
                achievements: unlockedAchievements,
                isUnlocked: true,
                emptyMessage: 'No achievements unlocked yet',
              ),

              // Locked Achievements
              _buildAchievementGrid(
                achievements: lockedAchievements,
                isUnlocked: false,
                emptyMessage: 'All achievements unlocked!',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAchievementGrid({
    required List<Achievement> achievements,
    required bool isUnlocked,
    required String emptyMessage,
  }) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];

        return GestureDetector(
          onTap: () => _showAchievementDetails(achievement, isUnlocked),
          child: Column(
            children: [
              AchievementBadge(
                achievement: achievement,
                isUnlocked: isUnlocked,
                size: 80,
              ),
              const SizedBox(height: 8),
              Text(
                achievement.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isUnlocked
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAchievementDetails(Achievement achievement, bool isUnlocked) {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user!;
    final isFeatured = user.featuredAchievements.contains(achievement.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Achievement Badge
            AchievementBadge(
              achievement: achievement,
              isUnlocked: isUnlocked,
              size: 120,
            ),
            const SizedBox(height: 16),

            // Achievement Name
            Text(
              achievement.name,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStat(
                  icon: Icons.bolt,
                  label: 'XP Reward',
                  value: '+${achievement.xpReward}',
                ),
                const SizedBox(width: 32),
                _buildStat(
                  icon: Icons.stars,
                  label: 'Rarity',
                  value: achievement.rarity.toUpperCase(),
                ),
              ],
            ),

            if (isUnlocked) ...[
              const SizedBox(height: 24),
              // Feature Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (isFeatured) {
                      // Remove from featured
                      final featured =
                          List<String>.from(user.featuredAchievements);
                      featured.remove(achievement.id);
                      await userProvider.updateProfile();
                    } else if (user.featuredAchievements.length < 5) {
                      // Add to featured
                      await userProvider.featureAchievement(
                        achievement.id,
                        user.featuredAchievements.length,
                      );
                    } else {
                      // Show replace dialog
                      _showReplaceFeaturedDialog(achievement);
                    }
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(isFeatured ? Icons.star : Icons.star_outline),
                  label: Text(isFeatured
                      ? 'Remove from Featured'
                      : 'Feature Achievement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFeatured
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _showReplaceFeaturedDialog(Achievement newAchievement) {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user!;
    final achievements = userProvider.achievements;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace Featured Achievement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'You already have 5 featured achievements. Choose one to replace:'),
            const SizedBox(height: 16),
            ...user.featuredAchievements.asMap().entries.map((entry) {
              final achievement = achievements.firstWhere(
                (a) => a.id == entry.value,
                orElse: () => Achievement(
                  id: '',
                  name: 'Unknown',
                  description: '',
                  iconAsset: 'assets/images/achievements/default.png',
                  xpReward: 0,
                  category: 'learning',
                  rarity: 'common',
                ),
              );

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events, size: 24),
                ),
                title: Text(achievement.name),
                onTap: () async {
                  await userProvider.featureAchievement(
                      newAchievement.id, entry.key);
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
