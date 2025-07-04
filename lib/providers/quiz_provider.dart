import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:procode/models/quiz_model.dart';
import 'package:procode/models/question_model.dart';
import 'package:procode/models/quiz_result_model.dart';
import 'package:procode/services/database_service.dart';
import 'package:procode/services/gamification_service.dart';
import 'package:procode/services/gemini_service.dart';
import 'package:procode/utils/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final GamificationService _gamificationService = GamificationService();
  final GeminiService _geminiService = GeminiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Quiz> _availableQuizzes = [];
  Quiz? _currentQuiz;
  List<QuestionModel> _currentQuestions = [];
  int _currentQuestionIndex = 0;
  final Map<int, String> _userAnswers = {};
  DateTime? _quizStartTime;
  int _remainingTime = 0;
  bool _isLoading = false;
  String? _error;
  QuizResultModel? _lastResult;
  final Map<int, String> _wrongAnswerExplanations = {};
  String? _aiFeedback;
  List<String> _recommendations = [];
  String? _motivationalMessage;

  // Helper to get current user ID
  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Getters
  List<Quiz> get availableQuizzes => _availableQuizzes;
  Quiz? get currentQuiz => _currentQuiz;
  List<QuestionModel> get currentQuestions => _currentQuestions;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuestionModel? get currentQuestion => _currentQuestions.isNotEmpty
      ? _currentQuestions[_currentQuestionIndex]
      : null;
  Map<int, String> get userAnswers => _userAnswers;
  int get remainingTime => _remainingTime;
  bool get isLoading => _isLoading;
  String? get error => _error;
  QuizResultModel? get lastResult => _lastResult;
  Map<int, String> get wrongAnswerExplanations => _wrongAnswerExplanations;
  String? get aiFeedback => _aiFeedback;
  List<String> get recommendations => _recommendations;
  String? get motivationalMessage => _motivationalMessage;

  bool get isLastQuestion =>
      _currentQuestionIndex >= _currentQuestions.length - 1;
  int get answeredQuestionsCount => _userAnswers.length;
  double get progress => _currentQuestions.isEmpty
      ? 0.0
      : (_currentQuestionIndex + 1) / _currentQuestions.length;

  // Safe notify listeners that checks if we're in a build phase
  void _safeNotifyListeners() {
    // Use scheduleMicrotask to defer notification until after the current build phase
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Load quizzes for a category
  Future<void> loadQuizzesByCategory(String category) async {
    _isLoading = true;
    _error = null;

    // Use safe notification for initial loading state
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      _safeNotifyListeners();
    } else {
      notifyListeners();
    }

    try {
      _availableQuizzes = await _databaseService.getQuizzesByCategory(category);
    } catch (e) {
      _error = 'Failed to load quizzes: $e';
      AppLogger.error('Failed to load quizzes by category', error: e);
    } finally {
      _isLoading = false;
      // Always use safe notification for the final state
      _safeNotifyListeners();
    }
  }

  // Load quizzes for a specific module
  Future<void> loadModuleQuizzes(String courseId, String moduleId) async {
    _isLoading = true;
    _error = null;

    // Use safe notification for initial loading state
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      _safeNotifyListeners();
    } else {
      notifyListeners();
    }

    try {
      _availableQuizzes =
          await _databaseService.getModuleQuizzes(courseId, moduleId);
    } catch (e) {
      _error = 'Failed to load module quizzes: $e';
      AppLogger.error('Failed to load module quizzes', error: e);
    } finally {
      _isLoading = false;
      // Always use safe notification for the final state
      _safeNotifyListeners();
    }
  }

  // Start a quiz
  Future<void> startQuiz(String quizId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentQuiz = await _databaseService.getQuizById(quizId);
      if (_currentQuiz == null) {
        throw Exception('Quiz not found');
      }

      _currentQuestions = await _databaseService.getQuizQuestions(quizId);
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _wrongAnswerExplanations.clear();
      _aiFeedback = null;
      _recommendations.clear();
      _motivationalMessage = null;
      _quizStartTime = DateTime.now();
      _remainingTime = _currentQuiz!.timeLimit;

      notifyListeners();
    } catch (e) {
      _error = 'Failed to start quiz: $e';
      AppLogger.error('Failed to start quiz', error: e);
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  // Answer current question
  void answerQuestion(String answer) {
    if (_currentQuestionIndex < _currentQuestions.length) {
      _userAnswers[_currentQuestionIndex] = answer;
      notifyListeners();
    }
  }

  // Move to next question
  Future<void> nextQuestion() async {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    } else {
      await submitQuiz();
    }
  }

  // Move to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // Jump to specific question
  void jumpToQuestion(int index) {
    if (index >= 0 && index < _currentQuestions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  // Update remaining time
  void updateRemainingTime(int seconds) {
    _remainingTime = seconds;
    if (_remainingTime <= 0) {
      submitQuiz();
    }
    notifyListeners();
  }

  // Helper method to compare boolean answers
  bool _compareBooleanAnswers(String userAnswer, String correctAnswer) {
    // Handle various boolean answer formats
    final userLower = userAnswer.toLowerCase().trim();
    final correctLower = correctAnswer.toString().toLowerCase().trim();

    // Direct comparison after normalization
    if (userLower == correctLower) {
      return true;
    }

    // Handle different capitalizations
    if ((userLower == 'true' && correctLower == 'true') ||
        (userLower == 'false' && correctLower == 'false')) {
      return true;
    }

    // Handle boolean vs string mismatches
    if ((userAnswer == 'True' &&
            (correctLower == 'true' || correctAnswer == 'True')) ||
        (userAnswer == 'False' &&
            (correctLower == 'false' || correctAnswer == 'False'))) {
      return true;
    }

    return false;
  }

  // Submit quiz
  Future<void> submitQuiz() async {
    if (_currentQuiz == null || _quizStartTime == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Calculate results
      int correctAnswers = 0;
      final wrongQuestions = <QuestionModel>[];
      Map<String, QuestionResult> questionResults = {};

      for (int i = 0; i < _currentQuestions.length; i++) {
        final question = _currentQuestions[i];
        final userAnswer = _userAnswers[i] ?? '';
        final correctAnswer = question.correctAnswer;

        // Special handling for boolean questions
        bool isCorrect = false;

        if (question.type == 'boolean' ||
            (question.options != null &&
                question.options!.length == 2 &&
                question.options!.any((opt) => opt.toLowerCase() == 'true') &&
                question.options!.any((opt) => opt.toLowerCase() == 'false'))) {
          // Use special boolean comparison
          isCorrect = _compareBooleanAnswers(userAnswer, correctAnswer);

          // Debug logging for boolean questions
          final questionPreview = question.question.length > 50
              ? '${question.question.substring(0, 50)}...'
              : question.question;
          AppLogger.info('Boolean question: $questionPreview');
          AppLogger.info(
              'User answer: "$userAnswer", Correct answer: "$correctAnswer"');
          AppLogger.info('Is correct: $isCorrect');
        } else {
          // Regular string comparison for other question types
          isCorrect = userAnswer == correctAnswer;
        }

        if (isCorrect) {
          correctAnswers++;
        } else {
          wrongQuestions.add(question);
          // Generate AI explanation for wrong answer
          if (userAnswer.isNotEmpty) {
            try {
              final explanation = await _geminiService.explainWrongAnswer(
                question: question,
                userAnswer: userAnswer,
              );
              _wrongAnswerExplanations[i] = explanation;
            } catch (e) {
              AppLogger.error('Failed to generate explanation for question $i',
                  error: e);
              _wrongAnswerExplanations[i] =
                  'Unable to generate explanation at this time.';
            }
          }
        }

        // Create question result
        questionResults[question.id] = QuestionResult(
          questionId: question.id,
          userAnswer: userAnswer,
          correctAnswer: correctAnswer,
          isCorrect: isCorrect,
          pointsEarned: isCorrect ? question.points : 0,
          timeTaken: 0, // You can implement per-question timing if needed
        );
      }

      final timeTaken = DateTime.now().difference(_quizStartTime!).inSeconds;
      final score = (correctAnswers / _currentQuestions.length * 100).round();
      final passed = score >= _currentQuiz!.passingScore;

      // Calculate XP based on score
      int xpEarned = 0;
      if (score >= 90) {
        xpEarned = _currentQuiz!.xpReward;
      } else if (score >= 70) {
        xpEarned = (_currentQuiz!.xpReward * 0.7).round();
      } else if (score >= 50) {
        xpEarned = (_currentQuiz!.xpReward * 0.4).round();
      } else {
        xpEarned = (_currentQuiz!.xpReward * 0.2).round();
      }

      // Create quiz result
      _lastResult = QuizResultModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUserId,
        quizId: _currentQuiz!.id,
        courseId: _currentQuiz!.courseId,
        moduleId: _currentQuiz!.moduleId ?? '',
        score: score,
        totalQuestions: _currentQuestions.length,
        correctAnswers: correctAnswers,
        timeTaken: timeTaken,
        passed: passed,
        xpEarned: xpEarned,
        questionResults: questionResults,
        completedAt: DateTime.now(),
      );

      // Save result to database
      await _databaseService.saveQuizResult(_lastResult!);

      // Award XP
      await _gamificationService.awardXP(_currentUserId, xpEarned);

      // Mark quiz as completed in user stats
      await _databaseService.markQuizCompleted(
        _currentUserId,
        _currentQuiz!.id,
        score,
        xpEarned,
      );

      // Generate AI feedback (optional, can be disabled if causing issues)
      try {
        _aiFeedback = await _geminiService.generateQuizFeedback(
          quizResult: _lastResult!,
          questions: _currentQuestions,
          userAnswers: _userAnswers,
        );
      } catch (e) {
        AppLogger.error('Failed to generate AI feedback', error: e);
        _aiFeedback = null;
      }

      // Generate learning recommendations
      if (wrongQuestions.isNotEmpty) {
        try {
          _recommendations =
              await _geminiService.generateLearningRecommendations(
            quizResult: _lastResult!,
            wrongQuestions: wrongQuestions,
            courseName: _currentQuiz!.category,
          );
        } catch (e) {
          AppLogger.error('Failed to generate recommendations', error: e);
          _recommendations = [];
        }
      }

      // Generate motivational message
      try {
        _motivationalMessage =
            await _geminiService.generateMotivationalMessage(score);
      } catch (e) {
        AppLogger.error('Failed to generate motivational message', error: e);
        _motivationalMessage = score >= 70
            ? "Great job! Keep up the excellent work!"
            : "Don't give up! Every attempt brings you closer to mastery.";
      }
    } catch (e) {
      _error = 'Failed to submit quiz: $e';
      AppLogger.error('Failed to submit quiz', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset quiz state
  void resetQuiz() {
    _currentQuiz = null;
    _currentQuestions = [];
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _wrongAnswerExplanations.clear();
    _quizStartTime = null;
    _remainingTime = 0;
    _lastResult = null;
    _aiFeedback = null;
    _recommendations.clear();
    _motivationalMessage = null;
    notifyListeners();
  }

  // Get quiz history for user
  Future<List<QuizResultModel>> getUserQuizHistory() async {
    try {
      return await _databaseService.getUserQuizHistory(_currentUserId);
    } catch (e) {
      AppLogger.error('Error loading quiz history', error: e);
      return [];
    }
  }

  // Check if user has completed a quiz
  Future<bool> hasCompletedQuiz(String quizId) async {
    try {
      return await _databaseService.hasUserCompletedQuiz(
          _currentUserId, quizId);
    } catch (e) {
      AppLogger.error('Error checking quiz completion', error: e);
      return false;
    }
  }

  // Get user's best score for a quiz
  Future<int?> getUserBestScore(String quizId) async {
    try {
      return await _databaseService.getUserBestScore(_currentUserId, quizId);
    } catch (e) {
      AppLogger.error('Error getting best score', error: e);
      return null;
    }
  }

  // Get quiz statistics
  Map<String, dynamic> getQuizStatistics() {
    if (_lastResult == null) return {};

    return {
      'score': _lastResult!.score,
      'totalQuestions': _lastResult!.totalQuestions,
      'correctAnswers': _lastResult!.correctAnswers,
      'incorrectAnswers':
          _lastResult!.totalQuestions - _lastResult!.correctAnswers,
      'percentage': _lastResult!.percentage,
      'timeTaken': _lastResult!.formattedTime,
      'passed': _lastResult!.passed,
      'xpEarned': _lastResult!.xpEarned,
    };
  }

  // Get question statistics
  Map<String, dynamic> getQuestionStatistics(int questionIndex) {
    if (questionIndex >= _currentQuestions.length || _lastResult == null) {
      return {};
    }

    final question = _currentQuestions[questionIndex];
    final questionResult = _lastResult!.questionResults[question.id];

    if (questionResult == null) return {};

    return {
      'question': question.question,
      'userAnswer': questionResult.userAnswer,
      'correctAnswer': questionResult.correctAnswer,
      'isCorrect': questionResult.isCorrect,
      'pointsEarned': questionResult.pointsEarned,
      'explanation': question.explanation,
      'wrongAnswerExplanation': _wrongAnswerExplanations[questionIndex],
    };
  }
}
