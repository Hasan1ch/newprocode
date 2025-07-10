import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing quiz results
/// This stores comprehensive data about a user's quiz attempt including
/// their performance, time taken, and detailed question-by-question results
class QuizResultModel {
  final String id;
  final String userId;
  final String quizId;
  final String courseId;
  final String moduleId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int timeTaken; // in seconds
  final bool passed;
  final int xpEarned;
  // Stores detailed results for each question - key is questionId
  final Map<String, QuestionResult> questionResults;
  final DateTime completedAt;

  QuizResultModel({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.courseId,
    required this.moduleId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTaken,
    required this.passed,
    required this.xpEarned,
    required this.questionResults,
    required this.completedAt,
  });

  /// Create QuizResultModel from JSON
  /// Handles conversion from Firestore document format including
  /// nested question results and timestamp conversions
  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    // Parse the nested question results map
    Map<String, QuestionResult> results = {};
    if (json['questionResults'] != null) {
      Map<String, dynamic> resultsData =
          json['questionResults'] as Map<String, dynamic>;
      resultsData.forEach((key, value) {
        results[key] = QuestionResult.fromJson(value as Map<String, dynamic>);
      });
    }

    return QuizResultModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      quizId: json['quizId'] ?? '',
      courseId: json['courseId'] ?? '',
      moduleId: json['moduleId'] ?? '',
      score: json['score'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      timeTaken: json['timeTaken'] ?? 0,
      passed: json['passed'] ?? false,
      xpEarned: json['xpEarned'] ?? 0,
      questionResults: results,
      // Convert Firestore timestamp to DateTime
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert QuizResultModel to JSON
  /// Prepares data for Firestore storage including converting
  /// DateTime to Timestamp and serializing nested question results
  Map<String, dynamic> toJson() {
    // Convert question results to JSON format
    Map<String, dynamic> resultsJson = {};
    questionResults.forEach((key, value) {
      resultsJson[key] = value.toJson();
    });

    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'courseId': courseId,
      'moduleId': moduleId,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeTaken': timeTaken,
      'passed': passed,
      'xpEarned': xpEarned,
      'questionResults': resultsJson,
      // Convert DateTime to Firestore Timestamp
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  /// Get percentage score
  /// Calculates the percentage score with safe division to avoid errors
  double get percentage =>
      totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  /// Get time taken formatted
  /// Converts seconds to a user-friendly "Xm Ys" format for display
  String get formattedTime {
    final minutes = timeTaken ~/ 60;
    final seconds = timeTaken % 60;
    return '${minutes}m ${seconds}s';
  }
}

/// Model representing individual question result
/// Tracks user's answer, correctness, and performance for each question
class QuestionResult {
  final String questionId;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int pointsEarned;
  final int timeTaken; // seconds spent on this question

  QuestionResult({
    required this.questionId,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.pointsEarned,
    required this.timeTaken,
  });

  // Parse from Firestore document format
  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionId: json['questionId'] ?? '',
      userAnswer: json['userAnswer'] ?? '',
      correctAnswer: json['correctAnswer'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      pointsEarned: json['pointsEarned'] ?? 0,
      timeTaken: json['timeTaken'] ?? 0,
    );
  }

  // Convert to Firestore document format
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
      'timeTaken': timeTaken,
    };
  }
}

// Type alias for backward compatibility with older code
typedef QuizResult = QuizResultModel;
