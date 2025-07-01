import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/quiz_provider.dart';
import 'package:procode/models/quiz_result_model.dart';
import 'package:procode/screens/quiz/widgets/result_chart.dart';
import 'package:procode/screens/quiz/quiz_categories_screen.dart';
import 'package:procode/widgets/animations/fade_animation.dart';
import 'package:procode/widgets/animations/slide_animation.dart';
import 'package:procode/widgets/common/custom_button.dart';
import 'package:procode/config/app_colors.dart';
import 'package:confetti/confetti.dart';

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({super.key});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;
  late AnimationController _xpController;
  late Animation<double> _xpAnimation;
  late ConfettiController _confettiController;
  bool _showDetails = false;
  final Map<int, bool> _expandedAnswers = {};

  @override
  void initState() {
    super.initState();

    _scoreController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _xpController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    final quizResult = context.read<QuizProvider>().lastResult!;

    // Calculate score percentage
    final totalQuestions = quizResult.totalQuestions;
    final scorePercentage = totalQuestions > 0
        ? (quizResult.correctAnswers / totalQuestions * 100).round()
        : 0;

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: scorePercentage.toDouble(),
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutBack,
    ));

    _xpAnimation = Tween<double>(
      begin: 0,
      end: quizResult.xpEarned.toDouble(),
    ).animate(CurvedAnimation(
      parent: _xpController,
      curve: Curves.elasticOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _scoreController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    _xpController.forward();

    final result = context.read<QuizProvider>().lastResult!;
    final totalQuestions = result.totalQuestions;
    final scorePercentage = totalQuestions > 0
        ? (result.correctAnswers / totalQuestions * 100).round()
        : 0;

    if (scorePercentage >= 70) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _xpController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // Calculate incorrect answers from total and correct
  int _getIncorrectAnswers(QuizResultModel result) {
    return result.totalQuestions - result.correctAnswers;
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.read<QuizProvider>();
    final result = quizProvider.lastResult;

    if (result == null) {
      return const Scaffold(
        body: Center(
          child: Text('No quiz result found'),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const QuizCategoriesScreen(),
            ),
            (route) => route.isFirst,
          );
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Score Section
                      FadeAnimation(
                        child: AnimatedBuilder(
                          animation: _scoreAnimation,
                          builder: (context, child) {
                            return Column(
                              children: [
                                Text(
                                  'Quiz Complete!',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ResultChart(
                                        correctAnswers: result.correctAnswers,
                                        wrongAnswers:
                                            _getIncorrectAnswers(result),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${_scoreAnimation.value.toInt()}%',
                                            style: TextStyle(
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                              color: _getScoreColor(
                                                  _scoreAnimation.value
                                                      .toInt()),
                                            ),
                                          ),
                                          Text(
                                            'Score',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.textGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Stats Row
                      SlideAnimation(
                        delay: 0.5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              'Correct',
                              '${result.correctAnswers}',
                              AppColors.success,
                              Icons.check_circle,
                            ),
                            _buildStatCard(
                              'Wrong',
                              '${_getIncorrectAnswers(result)}',
                              AppColors.error,
                              Icons.cancel,
                            ),
                            _buildStatCard(
                              'Time',
                              _formatTime(result.timeTaken),
                              AppColors.primary,
                              Icons.timer,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // XP Earned
                      SlideAnimation(
                        delay: 0.7,
                        child: AnimatedBuilder(
                          animation: _xpAnimation,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '+${_xpAnimation.value.toInt()} XP',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Motivational Message
                      const SizedBox(height: 24),
                      SlideAnimation(
                        delay: 0.9,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            _getMotivationalMessage(result),
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      // Wrong Answers Review
                      if (_getIncorrectAnswers(result) > 0) ...[
                        const SizedBox(height: 24),
                        SlideAnimation(
                          delay: 1.2,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _showDetails = !_showDetails;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _showDetails
                                      ? 'Hide Wrong Answers'
                                      : 'Review Wrong Answers',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Icon(
                                  _showDetails
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_showDetails) ...[
                          const SizedBox(height: 16),
                          ...List.generate(
                            quizProvider.currentQuestions.length,
                            (index) {
                              final question =
                                  quizProvider.currentQuestions[index];
                              final userAnswer =
                                  quizProvider.userAnswers[index];
                              final isWrong =
                                  userAnswer != question.correctAnswer;

                              if (!isWrong) return const SizedBox.shrink();

                              return FadeAnimation(
                                delay: 1.3 + (index * 0.1),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: AppColors.divider),
                                  ),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      tilePadding: const EdgeInsets.all(16),
                                      childrenPadding: const EdgeInsets.all(16),
                                      title: Text(
                                        'Question ${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        question.question,
                                        style: TextStyle(
                                          color: AppColors.textGrey,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      initiallyExpanded:
                                          _expandedAnswers[index] ?? false,
                                      onExpansionChanged: (expanded) {
                                        setState(() {
                                          _expandedAnswers[index] = expanded;
                                        });
                                      },
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.cancel,
                                                  color: AppColors.error,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Your answer: ${userAnswer ?? "Not answered"}',
                                                    style: TextStyle(
                                                      color: AppColors.error,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: AppColors.success,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Correct answer: ${question.correctAnswer}',
                                                    style: TextStyle(
                                                      color: AppColors.success,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (quizProvider
                                                        .wrongAnswerExplanations[
                                                    index] !=
                                                null) ...[
                                              const SizedBox(height: 12),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.psychology,
                                                          color:
                                                              AppColors.primary,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          'AI Explanation',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      quizProvider
                                                              .wrongAnswerExplanations[
                                                          index]!,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: textColor,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],

                      // Action Buttons
                      const SizedBox(height: 32),
                      SlideAnimation(
                        delay: 1.5,
                        direction: SlideDirection.up,
                        child: PrimaryButton(
                          text: 'Continue Learning',
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const QuizCategoriesScreen(),
                              ),
                              (route) => route.isFirst,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SlideAnimation(
                        delay: 1.6,
                        direction: SlideDirection.up,
                        child: TextButton(
                          onPressed: () {
                            // Share result functionality
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.share,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Share Result',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                  Colors.orange,
                  Colors.purple,
                ],
                numberOfParticles: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return AppColors.success;
    if (score >= 70) return AppColors.warning;
    if (score >= 50) return Colors.orange;
    return AppColors.error;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String _getMotivationalMessage(QuizResultModel result) {
    final percentage = result.percentage;

    if (percentage >= 90) {
      return "Outstanding performance! You're a true master! 🌟";
    } else if (percentage >= 80) {
      return "Excellent work! You've got great skills! 🎯";
    } else if (percentage >= 70) {
      return "Good job! You passed with flying colors! ✨";
    } else if (percentage >= 60) {
      return "Nice effort! Keep practicing to improve! 💪";
    } else if (percentage >= 50) {
      return "You're getting there! A bit more practice will help! 📚";
    } else {
      return "Don't give up! Every expert was once a beginner! 🚀";
    }
  }
}
