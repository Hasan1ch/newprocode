import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/quiz_provider.dart';
import 'package:procode/models/quiz_model.dart';
import 'package:procode/screens/quiz/quiz_intro_screen.dart';
import 'package:procode/widgets/animations/slide_animation.dart';
import 'package:procode/widgets/common/loading_widget.dart';
import 'package:procode/config/app_colors.dart';
import 'package:procode/widgets/common/error_widget.dart';

class QuizListScreen extends StatefulWidget {
  final String category;
  final String? courseId;
  final String? moduleId;

  const QuizListScreen({
    super.key,
    required this.category,
    this.courseId,
    this.moduleId,
  });

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  @override
  void initState() {
    super.initState();
    // Defer loading to after the first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuizzes();
    });
  }

  Future<void> _loadQuizzes() async {
    // Check if widget is still mounted
    if (!mounted) return;

    final quizProvider = context.read<QuizProvider>();
    if (widget.courseId != null && widget.moduleId != null) {
      await quizProvider.loadModuleQuizzes(widget.courseId!, widget.moduleId!);
    } else {
      await quizProvider.loadQuizzesByCategory(widget.category);
    }
  }

  String get _categoryTitle {
    switch (widget.category) {
      case 'module':
        return 'Module Quizzes';
      case 'quick':
        return 'Quick Challenges';
      case 'weekly':
        return 'Weekly Challenges';
      default:
        return 'Available Quizzes';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(_categoryTitle),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(child: LoadingWidget());
          }

          if (quizProvider.error != null) {
            return Center(
              child: CustomErrorWidget(
                message: quizProvider.error!,
                onRetry: _loadQuizzes,
              ),
            );
          }

          if (quizProvider.availableQuizzes.isEmpty) {
            return const Center(
              child: EmptyStateWidget(
                icon: Icons.quiz_outlined,
                title: 'No Quizzes Available',
                message: 'Check back later for new quizzes!',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadQuizzes,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: quizProvider.availableQuizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizProvider.availableQuizzes[index];
                return SlideAnimation(
                  delay: index * 0.1,
                  child: _buildQuizCard(quiz),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return FutureBuilder<bool>(
      future: context.read<QuizProvider>().hasCompletedQuiz(quiz.id),
      builder: (context, snapshot) {
        final hasCompleted = snapshot.data ?? false;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizIntroScreen(quiz: quiz),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (hasCompleted)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getIconColor(quiz.difficulty)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getQuizIcon(quiz.category),
                          color: _getIconColor(quiz.difficulty),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        quiz.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quiz.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: AppColors.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${quiz.timeLimit ~/ 60}m',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.help_outline,
                            size: 14,
                            color: AppColors.textGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${quiz.totalQuestions}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(quiz.difficulty)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quiz.difficulty.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getDifficultyColor(quiz.difficulty),
                          ),
                        ),
                      ),
                      if (hasCompleted) ...[
                        const SizedBox(height: 8),
                        FutureBuilder<int?>(
                          future: context
                              .read<QuizProvider>()
                              .getUserBestScore(quiz.id),
                          builder: (context, snapshot) {
                            final bestScore = snapshot.data;
                            if (bestScore != null) {
                              return Text(
                                'Best: $bestScore%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getQuizIcon(String category) {
    switch (category.toLowerCase()) {
      case 'python':
        return Icons.code;
      case 'javascript':
        return Icons.javascript;
      case 'html':
        return Icons.html;
      case 'css':
        return Icons.style;
      case 'module':
        return Icons.book_outlined;
      case 'quick':
        return Icons.flash_on;
      case 'weekly':
        return Icons.emoji_events;
      default:
        return Icons.quiz;
    }
  }

  Color _getIconColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}
