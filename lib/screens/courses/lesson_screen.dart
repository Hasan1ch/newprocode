import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:procode/models/lesson_model.dart' as models;
import 'package:procode/providers/course_provider.dart';
import 'package:procode/providers/auth_provider.dart' as app_auth;
import 'package:procode/services/analytics_service.dart';
import 'package:procode/screens/courses/widgets/lesson_progress_bar.dart';
import 'package:procode/widgets/common/custom_app_bar.dart';

class LessonScreen extends StatefulWidget {
  final String courseId;
  final String moduleId;
  final models.Lesson lesson;

  const LessonScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
    required this.lesson,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final ScrollController _scrollController = ScrollController();
  final AnalyticsService _analyticsService = AnalyticsService();
  double _scrollProgress = 0.0;
  bool _isCompleted = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _scrollController.addListener(_updateScrollProgress);
    _trackLessonView();
    _checkIfCompleted();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollProgress);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollProgress() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      setState(() {
        _scrollProgress = maxScroll > 0 ? (currentScroll / maxScroll) : 0;

        // Mark as completed when scrolled to bottom
        if (_scrollProgress >= 0.95 && !_isCompleted) {
          _completeLesson();
        }
      });
    }
  }

  void _checkIfCompleted() {
    final courseProvider = context.read<CourseProvider>();
    final progress = courseProvider.getProgressForCourse(widget.courseId);
    _isCompleted =
        progress?.completedLessons.contains(widget.lesson.id) ?? false;
  }

  Future<void> _trackLessonView() async {
    final authProvider = context.read<app_auth.AuthProvider>();
    if (authProvider.user != null) {
      await _analyticsService.trackLessonView(
        userId: authProvider.user!.id,
        courseId: widget.courseId,
        moduleId: widget.moduleId,
        lessonId: widget.lesson.id,
      );
    }
  }

  Future<void> _completeLesson() async {
    if (_isCompleted) return;

    final courseProvider = context.read<CourseProvider>();
    final authProvider = context.read<app_auth.AuthProvider>();

    setState(() {
      _isCompleted = true;
    });

    // Calculate time spent
    final timeSpent = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : 0;

    // Track completion
    if (authProvider.user != null) {
      await _analyticsService.trackLessonCompletion(
        userId: authProvider.user!.id,
        courseId: widget.courseId,
        moduleId: widget.moduleId,
        lessonId: widget.lesson.id,
        timeSpentSeconds: timeSpent,
      );
    }

    // Update progress
    await courseProvider.completeLesson(
      widget.courseId,
      widget.moduleId,
      widget.lesson.id,
    );

    // Show completion dialog
    if (mounted) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Lesson Completed!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+${widget.lesson.xpReward} XP',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: widget.lesson.title,
        actions: [
          IconButton(
            icon: Icon(
              _isCompleted ? Icons.bookmark : Icons.bookmark_border,
              color: _isCompleted ? Colors.amber : null,
            ),
            onPressed: () {
              // Toggle bookmark
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LessonProgressBar(progress: _scrollProgress),
          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lesson Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          Icons.timer_outlined,
                          '${widget.lesson.estimatedMinutes} min',
                          'Duration',
                        ),
                        _buildInfoItem(
                          Icons.bolt,
                          '${widget.lesson.xpReward} XP',
                          'Reward',
                          color: Colors.amber,
                        ),
                        _buildInfoItem(
                          _isCompleted
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          _isCompleted ? 'Complete' : 'In Progress',
                          'Status',
                          color: _isCompleted ? Colors.green : Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Markdown Content
                  MarkdownBody(
                    data: widget.lesson.content,
                    styleSheet: MarkdownStyleSheet(
                      h1: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      h2: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      h3: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      p: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                      code: TextStyle(
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      blockquote: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      listBullet: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 20,
                      ),
                    ),
                    builders: {
                      'code': CodeBlockBuilder(),
                    },
                  ),
                  // Code Examples
                  if (widget.lesson.codeExamples.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Code Examples',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.lesson.codeExamples.asMap().entries.map((entry) {
                      final index = entry.key;
                      final codeExample = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildCodeExample(
                          title: 'Example ${index + 1}',
                          code: codeExample,
                          language:
                              'dart', // Default language, could be parsed from content
                        ),
                      );
                    }).toList(),
                  ],
                  // Key Points
                  if (widget.lesson.keyPoints.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text(
                      'Key Points',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.lesson.keyPoints.map((point) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    point,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Complete Button
                  if (!_isCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _completeLesson,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Mark as Complete',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label,
      {Color? color}) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon,
            color: color ?? theme.colorScheme.onSurfaceVariant, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
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

  Widget _buildCodeExample({
    required String title,
    required String code,
    required String language,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      language.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      color: theme.colorScheme.onSurfaceVariant,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Code
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: HighlightView(
              code,
              language: language,
              theme: monokaiSublimeTheme,
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  @override
  Widget visitElementAfter(element, preferredStyle) {
    var language = '';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: HighlightView(
              element.textContent,
              language: language,
              theme: monokaiSublimeTheme,
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.copy, size: 18),
              color: Colors.grey[400],
              onPressed: () {
                Clipboard.setData(ClipboardData(text: element.textContent));
              },
            ),
          ),
        ],
      ),
    );
  }
}
