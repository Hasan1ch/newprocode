import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:procode/providers/quiz_provider.dart';
import 'package:procode/screens/quiz/quiz_result_screen.dart';
import 'package:procode/screens/quiz/widgets/question_widget.dart';
import 'package:procode/screens/quiz/widgets/timer_widget.dart';
import 'package:procode/widgets/animations/fade_animation.dart';
import 'package:procode/widgets/animations/slide_animation.dart';
import 'package:procode/widgets/common/custom_button.dart';
import 'package:procode/config/theme.dart';

/// Main quiz screen where users answer questions
/// Manages timer, question navigation, and answer submission
class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Timer? _timer;
  String? _selectedAnswer;
  bool _isAnswerLocked = false;

  @override
  void initState() {
    super.initState();
    // Start the countdown timer immediately
    _startTimer();
  }

  @override
  void dispose() {
    // Clean up timer to prevent memory leaks
    _timer?.cancel();
    super.dispose();
  }

  /// Starts a countdown timer that updates every second
  void _startTimer() {
    final quizProvider = context.read<QuizProvider>();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remainingTime = quizProvider.remainingTime - 1;

      if (remainingTime <= 0) {
        timer.cancel();
        _handleTimeUp();
      } else {
        // Update remaining time in provider
        quizProvider.updateRemainingTime(remainingTime);
      }
    });
  }

  /// Handles quiz timeout - shows dialog and auto-submits
  void _handleTimeUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Time\'s Up!'),
        content: const Text(
            'The quiz time has expired. Your answers will be submitted.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submitQuiz();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Updates selected answer state when user taps an option
  void _selectAnswer(String answer) {
    if (!_isAnswerLocked) {
      setState(() {
        _selectedAnswer = answer;
      });
    }
  }

  /// Confirms the selected answer and locks it
  void _confirmAnswer() {
    if (_selectedAnswer != null) {
      final quizProvider = context.read<QuizProvider>();
      // Save answer to provider
      quizProvider.answerQuestion(_selectedAnswer!);

      setState(() {
        _isAnswerLocked = true;
      });

      // Auto-proceed after a short delay for better UX
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _nextQuestion();
        }
      });
    }
  }

  /// Moves to next question or submits quiz if on last question
  void _nextQuestion() {
    final quizProvider = context.read<QuizProvider>();

    // Reset answer selection for next question
    setState(() {
      _selectedAnswer = null;
      _isAnswerLocked = false;
    });

    if (quizProvider.isLastQuestion) {
      _submitQuiz();
    } else {
      quizProvider.nextQuestion();
    }
  }

  /// Submits the quiz and navigates to results screen
  void _submitQuiz() async {
    _timer?.cancel();

    final quizProvider = context.read<QuizProvider>();
    await quizProvider.submitQuiz();

    if (mounted) {
      // Replace current screen to prevent going back
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const QuizResultScreen(),
        ),
      );
    }
  }

  /// Shows confirmation dialog when user tries to exit quiz
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
            'Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit quiz
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Intercept back button to show exit confirmation
      onWillPop: () async {
        _showExitConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showExitConfirmation,
          ),
          title: Consumer<QuizProvider>(
            builder: (context, quizProvider, child) {
              final quiz = quizProvider.currentQuiz;
              return Text(
                quiz?.title ?? 'Quiz',
                style: const TextStyle(fontSize: 18),
              );
            },
          ),
          actions: [
            // Timer widget in app bar
            Consumer<QuizProvider>(
              builder: (context, quizProvider, child) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: TimerWidget(
                      seconds: quizProvider.remainingTime,
                      totalSeconds: quizProvider.currentQuiz?.timeLimit ?? 900,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<QuizProvider>(
          builder: (context, quizProvider, child) {
            final question = quizProvider.currentQuestion;

            if (question == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Progress bar showing quiz completion
                Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(
                    value: quizProvider.progress,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 8),

                // Question counter and navigation dots
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${quizProvider.currentQuestionIndex + 1} of ${quizProvider.currentQuestions.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      _buildQuestionNavigation(quizProvider),
                    ],
                  ),
                ),

                // Question content area
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: FadeAnimation(
                      // Unique key forces animation on question change
                      key: ValueKey(quizProvider.currentQuestionIndex),
                      child: QuestionWidget(
                        question: question,
                        selectedAnswer: _selectedAnswer,
                        isAnswerLocked: _isAnswerLocked,
                        onAnswerSelected: _selectAnswer,
                      ),
                    ),
                  ),
                ),

                // Bottom action bar with skip/confirm/next buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border(
                      top: BorderSide(color: AppTheme.border),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // Skip button (not shown on last question)
                        if (!quizProvider.isLastQuestion)
                          Expanded(
                            child: TextButton(
                              onPressed: _isAnswerLocked
                                  ? null
                                  : () {
                                      // Skip question without answering
                                      if (_selectedAnswer != null) {
                                        _confirmAnswer();
                                      }
                                    },
                              child: const Text(
                                'Skip',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        const SizedBox(width: 16),
                        // Main action button
                        Expanded(
                          flex: 2,
                          child: SlideAnimation(
                            direction: SlideDirection.up,
                            child: CustomButton(
                              text: _isAnswerLocked
                                  ? (quizProvider.isLastQuestion
                                      ? 'Submit Quiz'
                                      : 'Next')
                                  : 'Confirm',
                              onPressed: _isAnswerLocked
                                  ? _nextQuestion
                                  : (_selectedAnswer != null
                                      ? _confirmAnswer
                                      : null),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds question navigation dots for quick overview
  Widget _buildQuestionNavigation(QuizProvider quizProvider) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          quizProvider.currentQuestions.length,
          (index) {
            final isAnswered = quizProvider.userAnswers.containsKey(index);
            final isCurrent = index == quizProvider.currentQuestionIndex;

            return GestureDetector(
              // Allow navigation to answered questions only
              onTap:
                  isAnswered ? () => quizProvider.jumpToQuestion(index) : null,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppTheme.primary
                      : isAnswered
                          ? AppTheme.primary.withOpacity(0.3)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent || isAnswered
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
