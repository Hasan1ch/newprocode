import 'package:flutter/material.dart';
import 'package:procode/models/course_model.dart';
import 'package:procode/models/progress_model.dart';
import 'package:procode/config/app_colors.dart';
import 'package:procode/screens/courses/course_detail_screen.dart';

class ContinueLearningCard extends StatelessWidget {
  final Course course;
  final Progress? progress;
  final double completionPercentage;

  const ContinueLearningCard({
    Key? key,
    required this.course,
    this.progress,
    required this.completionPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate actual values from progress
    final lessonsCompleted = progress?.completedLessons.length ?? 0;
    final xpEarned = progress?.totalXpEarned ?? 0;
    final currentModule = progress?.currentModuleId ?? '';
    final moduleNumber =
        currentModule.isNotEmpty ? currentModule.split('_').last : '1';

    // Format last accessed time
    String lastAccessedText = 'Not started';
    if (progress?.lastAccessedAt != null) {
      final difference = DateTime.now().difference(progress!.lastAccessedAt);
      if (difference.inMinutes < 60) {
        lastAccessedText = '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        lastAccessedText = '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        lastAccessedText = 'Yesterday';
      } else {
        lastAccessedText = '${difference.inDays}d ago';
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(course: course),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Course Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getCourseColor(course.language).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  course.icon.isNotEmpty
                      ? course.icon
                      : course.language.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                    color: _getCourseColor(course.language),
                    fontSize: course.icon.isNotEmpty ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Course Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (currentModule.isNotEmpty) ...[
                        Text(
                          'Module $moduleNumber',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        lastAccessedText,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completionPercentage / 100,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getCourseColor(course.language),
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Stats Row
                  Row(
                    children: [
                      Text(
                        '$lessonsCompleted lessons',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      if (xpEarned > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$xpEarned XP',
                          style: TextStyle(
                            color: Colors.amber[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Completion Percentage
            Column(
              children: [
                Text(
                  '${completionPercentage.toInt()}%',
                  style: TextStyle(
                    color: completionPercentage >= 100
                        ? Colors.green
                        : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  completionPercentage >= 100 ? 'Completed' : 'Complete',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCourseColor(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return Colors.blue;
      case 'javascript':
        return Colors.amber;
      case 'java':
        return Colors.orange;
      case 'html':
      case 'css':
      case 'html_css':
        return Colors.deepOrange;
      case 'cpp':
      case 'c++':
        return Colors.indigo;
      case 'dart':
        return Colors.lightBlue;
      default:
        return AppColors.primary;
    }
  }
}
