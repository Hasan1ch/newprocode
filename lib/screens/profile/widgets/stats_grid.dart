import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/config/theme.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<UserProvider>().stats;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          icon: Icons.bolt,
          title: 'Total XP',
          value: stats['totalXP']?.toString() ?? '0',
          gradient: AppTheme.primaryGradient,
        ),
        _StatCard(
          icon: Icons.emoji_events,
          title: 'Level',
          value: stats['level']?.toString() ?? '1',
          gradient: AppTheme.accentGradient,
        ),
        _StatCard(
          icon: Icons.local_fire_department,
          title: 'Streak',
          value: '${stats['currentStreak'] ?? 0} days',
          gradient: LinearGradient(
            colors: [Colors.orange[600]!, Colors.red[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        _StatCard(
          icon: Icons.school,
          title: 'Courses',
          value: stats['coursesCompleted']?.toString() ?? '0',
          gradient: LinearGradient(
            colors: [Colors.green[600]!, Colors.teal[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final LinearGradient gradient;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? null : gradient,
        color: isDark ? Theme.of(context).colorScheme.surface : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (isDark ? Colors.black : gradient.colors[0]).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Could show detailed stats in future
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: isDark ? gradient.colors[0] : Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Theme.of(context).colorScheme.onSurface
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
