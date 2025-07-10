import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for coding challenges/exercises
/// Represents interactive programming problems users solve
class CodeChallengeModel {
  final String id;
  final String title;
  final String description; // Problem statement
  final String language; // Programming language required
  final String difficulty; // Easy, Medium, Hard
  final String category; // Problem type (algorithms, data structures, etc.)
  final String initialCode; // Starter code template
  final String solution; // Reference solution
  final List<TestCase> testCases; // Input/output validation
  final int xpReward; // Points earned on completion
  final Map<String, String> hints; // Progressive hints system
  final DateTime createdAt;
  final DateTime updatedAt;

  CodeChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.difficulty,
    required this.category,
    required this.initialCode,
    required this.solution,
    required this.testCases,
    required this.xpReward,
    required this.hints,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates challenge from Firestore document
  factory CodeChallengeModel.fromJson(Map<String, dynamic> json) {
    return CodeChallengeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      language: json['language'] ?? 'python', // Default to Python
      difficulty: json['difficulty'] ?? 'Easy',
      category: json['category'] ?? 'General',
      initialCode: json['initialCode'] ?? '',
      solution: json['solution'] ?? '',
      testCases: (json['testCases'] as List<dynamic>?)
              ?.map((e) => TestCase.fromJson(e))
              .toList() ??
          [],
      xpReward: json['xpReward'] ?? 10,
      hints: Map<String, String>.from(json['hints'] ?? {}),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Converts challenge to Firestore format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'language': language,
      'difficulty': difficulty,
      'category': category,
      'initialCode': initialCode,
      'solution': solution,
      'testCases': testCases.map((e) => e.toJson()).toList(),
      'xpReward': xpReward,
      'hints': hints,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// Individual test case for validating solutions
/// Contains input data and expected output
class TestCase {
  final String input; // Test input data
  final String expectedOutput; // Correct output
  final String description; // What this test checks
  final bool isHidden; // Hidden tests prevent hardcoding

  TestCase({
    required this.input,
    required this.expectedOutput,
    required this.description,
    this.isHidden = false,
  });

  /// Creates test case from JSON
  factory TestCase.fromJson(Map<String, dynamic> json) {
    return TestCase(
      input: json['input'] ?? '',
      expectedOutput: json['expectedOutput'] ?? '',
      description: json['description'] ?? '',
      isHidden: json['isHidden'] ?? false,
    );
  }

  /// Converts test case to JSON
  Map<String, dynamic> toJson() {
    return {
      'input': input,
      'expectedOutput': expectedOutput,
      'description': description,
      'isHidden': isHidden,
    };
  }
}
