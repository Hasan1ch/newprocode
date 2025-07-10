/// Model representing a quiz question
/// Supports multiple question types including MCQ, coding challenges, and debugging
class QuestionModel {
  final String id;
  // Question types: mcq, boolean, code_output, fill_code, debug
  final String type;
  final String question;
  // Optional code snippet for programming questions
  final String? codeSnippet;
  // Answer options for multiple choice questions
  final List<String>? options;
  final String correctAnswer;
  // Explanation shown after answering to reinforce learning
  final String explanation;
  // Difficulty levels: easy, medium, hard
  final String difficulty;
  // Points awarded for correct answer, varies by difficulty
  final int points;

  QuestionModel({
    required this.id,
    required this.type,
    required this.question,
    this.codeSnippet,
    this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.points,
  });

  /// Create QuestionModel from JSON
  /// Provides default values to handle incomplete data from Firestore
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'mcq', // Default to multiple choice
      question: json['question'] ?? '',
      codeSnippet: json['codeSnippet'],
      // Safely convert options list, null if not present
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ?? 'easy', // Default to easy
      points: json['points'] ?? 1, // Default 1 point
    );
  }

  /// Convert QuestionModel to JSON
  /// Prepares data for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'question': question,
      'codeSnippet': codeSnippet,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty,
      'points': points,
    };
  }

  /// Create a copy with updated fields
  /// Used when editing questions or creating variations
  QuestionModel copyWith({
    String? id,
    String? type,
    String? question,
    String? codeSnippet,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    String? difficulty,
    int? points,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      question: question ?? this.question,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
      points: points ?? this.points,
    );
  }
}

/// Question type enum - moved outside the class
/// Provides type-safe question type constants
enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInTheBlank,
  coding,
  ordering,
}

// Type alias for backward compatibility
typedef Question = QuestionModel;
