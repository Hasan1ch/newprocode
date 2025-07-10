import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/models/course_model.dart' as models;
import 'package:procode/providers/course_provider.dart';
import 'package:procode/providers/auth_provider.dart' as app_auth;
import 'package:procode/screens/courses/widgets/module_card.dart';

/// Detailed course view screen showing course information, progress, and modules
/// Allows users to enroll in courses and track their learning progress
class CourseDetailScreen extends StatefulWidget {
  final models.Course course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load course modules after the widget is built to avoid provider issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().loadModulesForCourse(widget.course.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers for reactive UI updates
    final courseProvider = context.watch<CourseProvider>();
    final authProvider = context.watch<app_auth.AuthProvider>();

    // Get course-specific data from the provider
    final modules = courseProvider.getModulesForCourse(widget.course.id);
    print('Modules loaded: ${modules.length}'); // Debug logging
    final progress = courseProvider.getProgressForCourse(widget.course.id);
    final isEnrolled =
        courseProvider.enrolledCourses.any((c) => c.id == widget.course.id);
    final completionPercentage =
        courseProvider.getCourseCompletionPercentage(widget.course.id);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Collapsible header with course information
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                // Language-specific gradient background
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getCourseColor(widget.course.language),
                      _getCourseColor(widget.course.language)
                          .withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Course icon with language abbreviation
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              widget.course.language
                                  .substring(0, 2)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Course title
                        Text(
                          widget.course.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Course metadata row
                        Row(
                          children: [
                            // Difficulty indicator
                            Icon(
                              Icons.signal_cellular_alt,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.course.difficulty,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Estimated duration
                            Icon(
                              Icons.timer_outlined,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.course.estimatedHours} hours',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Custom back button for better visibility
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Course content section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course description
                  Text(
                    widget.course.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Different UI based on enrollment status
                  if (isEnrolled) ...[
                    // Progress tracking card for enrolled students
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Overall progress header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Course Progress',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${completionPercentage.toInt()}%',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Visual progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: completionPercentage / 100,
                              backgroundColor:
                                  isDark ? Colors.grey[800] : Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Course statistics grid
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                '${progress?.completedLessons.length ?? 0}',
                                'Lessons',
                                Icons.book_outlined,
                              ),
                              _buildStatItem(
                                '${progress?.totalXpEarned ?? 0}',
                                'XP Earned',
                                Icons.bolt,
                              ),
                              _buildStatItem(
                                '${modules.length}',
                                'Modules',
                                Icons.view_module_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    // Enrollment button for non-enrolled users
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // Only allow enrollment if user is authenticated
                        onPressed: authProvider.isAuthenticated
                            ? () async {
                                await courseProvider
                                    .enrollInCourse(widget.course.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Successfully enrolled in course!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Enroll Now - It\'s Free!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Modules section header
                  Text(
                    'Course Modules',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Dynamic module list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final module = modules[index];
                // Calculate module-specific progress
                final isCompleted =
                    progress?.completedModules.contains(module.id) ?? false;
                final completedLessons = progress?.completedLessons
                        .where(
                            (lessonId) => module.lessonIds.contains(lessonId))
                        .length ??
                    0;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ModuleCard(
                    module: module,
                    courseId: widget.course.id,
                    isCompleted: isCompleted,
                    completedLessons: completedLessons,
                    totalLessons: module.lessonIds.length,
                    // Lock modules after the first one for non-enrolled users
                    isLocked: !isEnrolled && index > 0,
                  ),
                );
              },
              childCount: modules.length,
            ),
          ),
          // Bottom padding for better scrolling experience
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  /// Builds a statistic item widget for the progress card
  Widget _buildStatItem(String value, String label, IconData icon) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Returns language-specific color for visual consistency
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
        return Theme.of(context).colorScheme.primary;
    }
  }
}
