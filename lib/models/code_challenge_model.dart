import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a code challenge
class CodeChallengeModel {
  final String id;
  final String title;
  final String description;
  final String difficulty; // easy, medium, hard
  final String language; // python, javascript, java, etc.
  final String category; // arrays, strings, algorithms, etc.
  final String problemStatement;
  final String initialCode;
  final List<TestCase> testCases;
  final String solution;
  final String explanation;
  final int xpReward;
  final List<String> hints;
  final Map<String, dynamic>? constraints;
  final DateTime createdAt;

  CodeChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.language,
    required this.category,
    required this.problemStatement,
    required this.initialCode,
    required this.testCases,
    required this.solution,
    required this.explanation,
    required this.xpReward,
    required this.hints,
    this.constraints,
    required this.createdAt,
  });

  /// Create CodeChallengeModel from JSON
  factory CodeChallengeModel.fromJson(Map<String, dynamic> json) {
    return CodeChallengeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? 'easy',
      language: json['language'] ?? 'python',
      category: json['category'] ?? 'general',
      problemStatement: json['problemStatement'] ?? '',
      initialCode: json['initialCode'] ?? '',
      testCases: (json['testCases'] as List?)
              ?.map((tc) => TestCase.fromJson(tc))
              .toList() ??
          [],
      solution: json['solution'] ?? '',
      explanation: json['explanation'] ?? '',
      xpReward: json['xpReward'] ?? 30,
      hints: List<String>.from(json['hints'] ?? []),
      constraints: json['constraints'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert CodeChallengeModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'language': language,
      'category': category,
      'problemStatement': problemStatement,
      'initialCode': initialCode,
      'testCases': testCases.map((tc) => tc.toJson()).toList(),
      'solution': solution,
      'explanation': explanation,
      'xpReward': xpReward,
      'hints': hints,
      'constraints': constraints,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a copy with updated fields
  CodeChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    String? language,
    String? category,
    String? problemStatement,
    String? initialCode,
    List<TestCase>? testCases,
    String? solution,
    String? explanation,
    int? xpReward,
    List<String>? hints,
    Map<String, dynamic>? constraints,
    DateTime? createdAt,
  }) {
    return CodeChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      language: language ?? this.language,
      category: category ?? this.category,
      problemStatement: problemStatement ?? this.problemStatement,
      initialCode: initialCode ?? this.initialCode,
      testCases: testCases ?? this.testCases,
      solution: solution ?? this.solution,
      explanation: explanation ?? this.explanation,
      xpReward: xpReward ?? this.xpReward,
      hints: hints ?? this.hints,
      constraints: constraints ?? this.constraints,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Model representing a test case for code challenges
class TestCase {
  final String input;
  final String expectedOutput;
  final bool isHidden;
  final String? explanation;

  TestCase({
    required this.input,
    required this.expectedOutput,
    this.isHidden = false,
    this.explanation,
  });

  factory TestCase.fromJson(Map<String, dynamic> json) {
    return TestCase(
      input: json['input'] ?? '',
      expectedOutput: json['expectedOutput'] ?? '',
      isHidden: json['isHidden'] ?? false,
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input': input,
      'expectedOutput': expectedOutput,
      'isHidden': isHidden,
      'explanation': explanation,
    };
  }
}

typedef CodeChallenge = CodeChallengeModel;
