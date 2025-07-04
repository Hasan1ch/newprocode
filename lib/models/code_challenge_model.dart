import 'package:cloud_firestore/cloud_firestore.dart';

class CodeChallengeModel {
  final String id;
  final String title;
  final String description;
  final String language;
  final String difficulty;
  final String category;
  final String initialCode;
  final String solution;
  final List<TestCase> testCases;
  final int xpReward;
  final Map<String, String> hints;
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

  factory CodeChallengeModel.fromJson(Map<String, dynamic> json) {
    return CodeChallengeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      language: json['language'] ?? 'python',
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

class TestCase {
  final String input;
  final String expectedOutput;
  final String description;
  final bool isHidden;

  TestCase({
    required this.input,
    required this.expectedOutput,
    required this.description,
    this.isHidden = false,
  });

  factory TestCase.fromJson(Map<String, dynamic> json) {
    return TestCase(
      input: json['input'] ?? '',
      expectedOutput: json['expectedOutput'] ?? '',
      description: json['description'] ?? '',
      isHidden: json['isHidden'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input': input,
      'expectedOutput': expectedOutput,
      'description': description,
      'isHidden': isHidden,
    };
  }
}
