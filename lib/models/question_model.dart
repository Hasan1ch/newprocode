/// Model representing a quiz question
class QuestionModel {
  final String id;
  final String type; // mcq, boolean, code_output, fill_code, debug
  final String question;
  final String? codeSnippet;
  final List<String>? options;
  final String correctAnswer;
  final String explanation;
  final String difficulty; // easy, medium, hard
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
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'mcq',
      question: json['question'] ?? '',
      codeSnippet: json['codeSnippet'],
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ?? 'easy',
      points: json['points'] ?? 1,
    );
  }

  /// Convert QuestionModel to JSON
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
enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInTheBlank,
  coding,
  ordering,
}

typedef Question = QuestionModel;
