import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/leaderboard_provider.dart';
import 'package:procode/providers/course_provider.dart';

class FilterChips extends StatelessWidget {
  final LeaderboardFilter currentFilter;
  final Function(LeaderboardFilter, {String? courseId}) onFilterChanged;

  const FilterChips({
    Key? key,
    required this.currentFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: 'Global',
            icon: Icons.public,
            isSelected: currentFilter == LeaderboardFilter.global,
            onTap: () => onFilterChanged(LeaderboardFilter.global),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'This Week',
            icon: Icons.calendar_today,
            isSelected: currentFilter == LeaderboardFilter.weekly,
            onTap: () => onFilterChanged(LeaderboardFilter.weekly),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'This Month',
            icon: Icons.calendar_month,
            isSelected: currentFilter == LeaderboardFilter.monthly,
            onTap: () => onFilterChanged(LeaderboardFilter.monthly),
          ),
          const SizedBox(width: 8),
          _buildCourseFilterChip(context),
        ],
      ),
    );
  }

  Widget _buildCourseFilterChip(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, courseProvider, _) {
        final courses = courseProvider.courses;

        return PopupMenuButton<String>(
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder: (context) => courses
              .map((course) => PopupMenuItem(
                    value: course.id,
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              course.icon,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            course.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onSelected: (courseId) {
            onFilterChanged(LeaderboardFilter.byCourse, courseId: courseId);
          },
          child: _FilterChip(
            label: 'By Course',
            icon: Icons.school,
            isSelected: currentFilter == LeaderboardFilter.byCourse,
            onTap: null, // Handled by PopupMenuButton
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
