import 'package:flutter/material.dart';
import 'package:procode/providers/leaderboard_provider.dart';

/// Filter chips for switching between global and course-specific leaderboards
/// Provides quick filtering options with course selection modal
class FilterChips extends StatelessWidget {
  final LeaderboardFilter currentFilter;
  final Function(LeaderboardFilter, {String? courseId}) onFilterChanged;

  const FilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Global leaderboard filter
          FilterChip(
            label: const Text('Global'),
            selected: currentFilter == LeaderboardFilter.global,
            onSelected: (selected) {
              if (selected) {
                onFilterChanged(LeaderboardFilter.global);
              }
            },
            // Show check icon when selected, otherwise show globe icon
            avatar: currentFilter == LeaderboardFilter.global
                ? const Icon(Icons.check, size: 18)
                : const Icon(Icons.public, size: 18),
          ),
          const SizedBox(width: 8),
          // Course-specific leaderboard filter
          FilterChip(
            label: const Text('By Course'),
            selected: currentFilter == LeaderboardFilter.byCourse,
            onSelected: (selected) {
              if (selected) {
                // Show course selection modal when selected
                _showCourseSelection(context);
              }
            },
            // Show check icon when selected, otherwise show school icon
            avatar: currentFilter == LeaderboardFilter.byCourse
                ? const Icon(Icons.check, size: 18)
                : const Icon(Icons.school, size: 18),
          ),
        ],
      ),
    );
  }

  /// Shows bottom sheet modal for course selection
  /// This allows users to filter leaderboard by specific courses
  void _showCourseSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Course',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // TODO: Replace with dynamic course list from CourseProvider
            // Currently showing hardcoded courses for demonstration
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Python Basics'),
              onTap: () {
                Navigator.pop(context);
                onFilterChanged(LeaderboardFilter.byCourse,
                    courseId: 'python_basics');
              },
            ),
            ListTile(
              leading: const Icon(Icons.javascript),
              title: const Text('JavaScript Fundamentals'),
              onTap: () {
                Navigator.pop(context);
                onFilterChanged(LeaderboardFilter.byCourse,
                    courseId: 'javascript_fundamentals');
              },
            ),
            ListTile(
              leading: const Icon(Icons.android),
              title: const Text('Java for Android'),
              onTap: () {
                Navigator.pop(context);
                onFilterChanged(LeaderboardFilter.byCourse,
                    courseId: 'java_android');
              },
            ),
          ],
        ),
      ),
    );
  }
}
