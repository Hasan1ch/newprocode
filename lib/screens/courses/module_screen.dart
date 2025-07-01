import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/models/module_model.dart' as models;
import 'package:procode/models/lesson_model.dart' as models;
import 'package:procode/providers/course_provider.dart';
import 'package:procode/screens/courses/lesson_screen.dart';
import 'package:procode/widgets/common/custom_app_bar.dart';

class ModuleScreen extends StatefulWidget {
  final String courseId;
  final models.Module module;

  const ModuleScreen({
    super.key,
    required this.courseId,
    required this.module,
  });

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  List<models.Lesson> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final courseProvider = context.read<CourseProvider>();
    final lessons = await courseProvider.loadLessonsForModule(
      widget.courseId,
      widget.module.id,
    );

    setState(() {
      _lessons = lessons;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final progress = courseProvider.getProgressForCourse(widget.courseId);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: widget.module.title,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Module Description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Module Overview',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.module.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Estimated time: ${widget.module.estimatedMinutes} minutes',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Lessons
                  Text(
                    'Lessons',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_lessons.length, (index) {
                    final lesson = _lessons[index];
                    final isCompleted =
                        progress?.completedLessons.contains(lesson.id) ?? false;
                    final isLocked = index > 0 &&
                        !isCompleted &&
                        !(progress?.completedLessons
                                .contains(_lessons[index - 1].id) ??
                            false);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildLessonCard(
                        lesson: lesson,
                        index: index + 1,
                        isCompleted: isCompleted,
                        isLocked: isLocked,
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  // Quiz Card
                  if (widget.module.quizId != null) ...[
                    Text(
                      'Module Quiz',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuizCard(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildLessonCard({
    required models.Lesson lesson,
    required int index,
    required bool isCompleted,
    required bool isLocked,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isLocked
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonScreen(
                    courseId: widget.courseId,
                    moduleId: widget.module.id,
                    lesson: lesson,
                  ),
                ),
              );
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? Colors.green.withValues(alpha: 0.3)
                : isLocked
                    ? Colors.grey.withValues(alpha: 0.2)
                    : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.2)
                    : isLocked
                        ? Colors.grey.withValues(alpha: 0.2)
                        : theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.green, size: 20)
                    : isLocked
                        ? const Icon(Icons.lock_outline,
                            color: Colors.grey, size: 20)
                        : Text(
                            '$index',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isLocked ? Colors.grey : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson.estimatedMinutes} min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.bolt,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson.xpReward} XP',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isLocked
                  ? Colors.grey[600]
                  : theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard() {
    final theme = Theme.of(context);
    final progress =
        context.watch<CourseProvider>().getProgressForCourse(widget.courseId);
    final allLessonsCompleted = widget.module.lessonIds.every(
      (lessonId) => progress?.completedLessons.contains(lessonId) ?? false,
    );

    return InkWell(
      onTap: allLessonsCompleted
          ? () {
              // Navigate to quiz
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: allLessonsCompleted
                ? [Colors.purple, Colors.purple.withValues(alpha: 0.7)]
                : [Colors.grey[800]!, Colors.grey[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                allLessonsCompleted ? Icons.quiz : Icons.lock_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Module Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    allLessonsCompleted
                        ? 'Test your knowledge!'
                        : 'Complete all lessons to unlock',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.bolt,
                    color: Colors.amber,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '50 XP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
