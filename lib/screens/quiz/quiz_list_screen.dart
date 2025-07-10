import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/quiz_provider.dart';
import 'package:procode/models/quiz_model.dart';
import 'package:procode/screens/quiz/quiz_intro_screen.dart';
import 'package:procode/widgets/animations/slide_animation.dart';
import 'package:procode/widgets/common/loading_widget.dart';
import 'package:procode/config/app_colors.dart';
import 'package:procode/widgets/common/error_widget.dart';

/// Displays a grid of available quizzes for a specific category
/// Can also show module-specific quizzes when courseId and moduleId are provided
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
    // This prevents the "setState called during build" error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuizzes();
    });
  }

  /// Loads quizzes based on category or module context
  Future<void> _loadQuizzes() async {
    // Check if widget is still mounted to prevent memory leaks
    if (!mounted) return;

    final quizProvider = context.read<QuizProvider>();
    if (widget.courseId != null && widget.moduleId != null) {
      // Load module-specific quizzes when coming from a course
      await quizProvider.loadModuleQuizzes(widget.courseId!, widget.moduleId!);
    } else {
      // Load general category quizzes
      await quizProvider.loadQuizzesByCategory(widget.category);
    }
  }

  /// Returns appropriate title based on quiz category
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
          // Show loading indicator while fetching quizzes
          if (quizProvider.isLoading) {
            return const Center(child: LoadingWidget());
          }

          // Show error message with retry option
          if (quizProvider.error != null) {
            return Center(
              child: CustomErrorWidget(
                message: quizProvider.error!,
                onRetry: _loadQuizzes,
              ),
            );
          }

          // Show empty state when no quizzes are available
          if (quizProvider.availableQuizzes.isEmpty) {
            return const Center(
              child: EmptyStateWidget(
                icon: Icons.quiz_outlined,
                title: 'No Quizzes Available',
                message: 'Check back later for new quizzes!',
              ),
            );
          }

          // Display quizzes in a responsive grid
          return RefreshIndicator(
            onRefresh: _loadQuizzes,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                childAspectRatio: 0.9, // Slightly taller than square
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: quizProvider.availableQuizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizProvider.availableQuizzes[index];
                return SlideAnimation(
                  delay: index * 0.1, // Stagger animations for visual effect
                  child: _buildQuizCard(quiz),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Creates a quiz card with completion status and best score
  Widget _buildQuizCard(Quiz quiz) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return FutureBuilder<bool>(
      // Check if user has completed this quiz before
      future: context.read<QuizProvider>().hasCompletedQuiz(quiz.id),
      builder: (context, snapshot) {
        final hasCompleted = snapshot.data ?? false;

        return GestureDetector(
          onTap: () {
            // Navigate to quiz intro screen
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
                // Completion checkmark badge
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
                      // Quiz icon with difficulty-based coloring
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
                      // Quiz title
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
                      // Quiz description
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
                      // Quiz metadata row
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
                      // Difficulty badge
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
                      // Show best score if quiz was completed
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

  /// Returns appropriate icon based on quiz category
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

  /// Returns color based on difficulty level for visual hierarchy
  Color _getIconColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success; // Green for easy
      case 'medium':
        return AppColors.warning; // Orange for medium
      case 'hard':
        return AppColors.error; // Red for hard
      default:
        return AppColors.primary;
    }
  }

  /// Returns color for difficulty badges
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
