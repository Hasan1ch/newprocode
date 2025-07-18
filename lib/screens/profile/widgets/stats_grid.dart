import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/providers/course_provider.dart';
import 'package:procode/config/theme.dart';
import 'package:shimmer/shimmer.dart';

/// Grid widget displaying user statistics in card format
/// Shows XP, level, streak, and enrolled courses with loading states
class StatsGrid extends StatelessWidget {
  const StatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Watch providers for real-time updates
    final userProvider = context.watch<UserProvider>();
    final courseProvider = context.watch<CourseProvider>();
    final stats = userProvider.stats;
    final isLoading = userProvider.isLoading;

    // Get actual enrolled courses count from course provider
    final enrolledCoursesCount = courseProvider.enrolledCourses.length;

    return GridView.count(
      shrinkWrap: true, // Important for use within scrollable widgets
      physics: const NeverScrollableScrollPhysics(), // Prevent nested scrolling
      crossAxisCount: 2, // Two cards per row
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5, // Width to height ratio
      children: [
        // Total XP card
        _StatCard(
          icon: Icons.bolt,
          title: 'Total XP',
          value: stats['totalXP']?.toString() ?? '0',
          gradient: AppTheme.primaryGradient,
          isLoading: isLoading,
        ),
        // Level card
        _StatCard(
          icon: Icons.emoji_events,
          title: 'Level',
          value: stats['level']?.toString() ?? '1',
          gradient: AppTheme.accentGradient,
          isLoading: isLoading,
        ),
        // Streak card
        _StatCard(
          icon: Icons.local_fire_department,
          title: 'Streak',
          value: '${stats['currentStreak'] ?? 0} days',
          gradient: LinearGradient(
            colors: [Colors.orange[600]!, Colors.red[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          isLoading: isLoading,
        ),
        // Courses card
        _StatCard(
          icon: Icons.school,
          title: 'Courses',
          value: enrolledCoursesCount.toString(),
          gradient: LinearGradient(
            colors: [Colors.green[600]!, Colors.teal[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          isLoading: isLoading || courseProvider.isLoading,
        ),
      ],
    );
  }
}

/// Individual stat card with gradient background and loading state
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final LinearGradient gradient;
  final bool isLoading;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.gradient,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // Use gradient in light mode, solid color in dark mode
        gradient: isDark ? null : gradient,
        color: isDark ? Theme.of(context).colorScheme.surface : null,
        borderRadius: BorderRadius.circular(16),
        // Shadow for depth effect
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
            // TODO: Navigate to detailed stats view
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stat icon
                Icon(
                  icon,
                  size: 32,
                  color: isDark ? gradient.colors[0] : Colors.white,
                ),
                const SizedBox(height: 8),
                // Value with shimmer loading effect
                if (isLoading)
                  Shimmer.fromColors(
                    baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    highlightColor:
                        isDark ? Colors.grey[500]! : Colors.grey[100]!,
                    child: Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                else
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
                // Stat title
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
