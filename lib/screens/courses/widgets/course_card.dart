import 'package:flutter/material.dart';
import 'package:procode/models/course_model.dart';
import 'package:procode/screens/courses/course_detail_screen.dart';
import 'package:procode/config/app_colors.dart';

/// Course card widget for displaying courses in a grid layout
/// Shows course information with visual indicators for enrollment status and progress
class CourseCard extends StatelessWidget {
  final Course course;
  final bool isEnrolled;
  final double completionPercentage;

  const CourseCard({
    Key? key,
    required this.course,
    required this.isEnrolled,
    required this.completionPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to detailed course view when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          // Highlight enrolled courses with a subtle border
          border: Border.all(
            color: isEnrolled
                ? AppColors.primary.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course header with language-specific gradient background
            Container(
              height: 120,
              decoration: BoxDecoration(
                // Each programming language gets its own color theme
                gradient: LinearGradient(
                  colors: [
                    _getCourseColor(course.language),
                    _getCourseColor(course.language).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                // Display language abbreviation as a large icon
                child: Text(
                  course.language.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Course information section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course title with ellipsis for long names
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Difficulty badge with color coding
                    Text(
                      course.difficulty,
                      style: TextStyle(
                        color: _getDifficultyColor(course.difficulty),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Bottom section shows different info based on enrollment status
                    if (isEnrolled) ...[
                      // For enrolled users, show progress tracking
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${completionPercentage.toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Visual progress bar for quick status check
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: completionPercentage / 100,
                              backgroundColor: Colors.grey[800],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // For non-enrolled users, show enrollment count
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.enrolledCount} enrolled',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a color theme based on the programming language
  /// This helps users quickly identify course types visually
  Color _getCourseColor(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return Colors.blue;
      case 'javascript':
        return Colors.amber;
      case 'html':
      case 'css':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  /// Maps difficulty levels to colors for visual hierarchy
  /// Green for beginner, orange for intermediate, red for advanced
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
