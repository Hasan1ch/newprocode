import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/models/quiz_model.dart';
import 'package:procode/providers/quiz_provider.dart';
import 'package:procode/screens/quiz/quiz_screen.dart';
import 'package:procode/widgets/animations/fade_animation.dart';
import 'package:procode/widgets/animations/slide_animation.dart';
import 'package:procode/widgets/common/custom_button.dart';
import 'package:procode/config/app_colors.dart';

class QuizIntroScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizIntroScreen({
    super.key,
    required this.quiz,
  });

  @override
  State<QuizIntroScreen> createState() => _QuizIntroScreenState();
}

class _QuizIntroScreenState extends State<QuizIntroScreen> {
  bool _hasCompleted = false;
  int? _bestScore;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    setState(() => _isLoading = true);

    final quizProvider = context.read<QuizProvider>();
    _hasCompleted = await quizProvider.hasCompletedQuiz(widget.quiz.id);
    if (_hasCompleted) {
      _bestScore = await quizProvider.getUserBestScore(widget.quiz.id);
    }

    setState(() => _isLoading = false);
  }

  void _startQuiz() async {
    final quizProvider = context.read<QuizProvider>();
    await quizProvider.startQuiz(widget.quiz.id);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const QuizScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeAnimation(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.quiz,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeAnimation(
                  delay: 0.1,
                  child: Text(
                    widget.quiz.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeAnimation(
                  delay: 0.2,
                  child: Text(
                    widget.quiz.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SlideAnimation(
                  delay: 0.3,
                  child: _buildInfoCard(
                    icon: Icons.help_outline,
                    title: 'Questions',
                    value: '${widget.quiz.totalQuestions}',
                    subtitle: 'Multiple choice, True/False, Code problems',
                  ),
                ),
                const SizedBox(height: 16),
                SlideAnimation(
                  delay: 0.4,
                  child: _buildInfoCard(
                    icon: Icons.timer_outlined,
                    title: 'Time Limit',
                    value: widget.quiz.formattedTimeLimit,
                    subtitle:
                        '${widget.quiz.timeLimit ~/ widget.quiz.totalQuestions} seconds per question',
                  ),
                ),
                const SizedBox(height: 16),
                SlideAnimation(
                  delay: 0.5,
                  child: _buildInfoCard(
                    icon: Icons.star_outline,
                    title: 'XP Rewards',
                    value: 'Up to ${widget.quiz.xpReward} XP',
                    subtitle: _getXPBreakdown(),
                  ),
                ),
                if (_hasCompleted && _bestScore != null) ...[
                  const SizedBox(height: 16),
                  SlideAnimation(
                    delay: 0.6,
                    child: _buildInfoCard(
                      icon: Icons.emoji_events_outlined,
                      title: 'Your Best Score',
                      value: '$_bestScore%',
                      subtitle: 'Can you beat it?',
                      color: AppColors.success,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                FadeAnimation(
                  delay: 0.7,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Quiz Rules',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildRule(
                            '• You cannot go back once you answer a question'),
                        _buildRule(
                            '• The quiz will auto-submit when time runs out'),
                        _buildRule(
                            '• AI will provide feedback on wrong answers'),
                        _buildRule('• Your progress is saved automatically'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SlideAnimation(
                  delay: 0.8,
                  direction: SlideDirection.up,
                  child: CustomButton(
                    text: _hasCompleted ? 'Retake Quiz' : 'Start Quiz',
                    onPressed: _isLoading ? null : _startQuiz,
                    isLoading: _isLoading,
                  ),
                ),
                const SizedBox(height: 16),
                SlideAnimation(
                  delay: 0.9,
                  direction: SlideDirection.up,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Maybe Later',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color ?? AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRule(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        rule,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textGrey,
          height: 1.4,
        ),
      ),
    );
  }

  String _getXPBreakdown() {
    switch (widget.quiz.category.toLowerCase()) {
      case 'module':
        return '90%+ = 50 XP, 70%+ = 35 XP, 50%+ = 20 XP';
      case 'quick':
        return '90%+ = 25 XP, 70%+ = 18 XP, 50%+ = 10 XP';
      case 'weekly':
        return '90%+ = 100 XP, 70%+ = 70 XP, 50%+ = 40 XP';
      default:
        return 'Earn XP based on your score';
    }
  }
}
