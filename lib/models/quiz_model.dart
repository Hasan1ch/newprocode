import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a quiz
class QuizModel {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String? moduleId;
  final String difficulty;
  final String category;
  final int timeLimit; // in seconds
  final int passingScore; // percentage
  final int totalQuestions;
  final int xpReward;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.moduleId,
    required this.difficulty,
    required this.category,
    required this.timeLimit,
    required this.passingScore,
    required this.totalQuestions,
    required this.xpReward,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  /// Create QuizModel from JSON
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      courseId: json['courseId'] ?? '',
      moduleId: json['moduleId'],
      difficulty: json['difficulty'] ?? 'easy',
      category: json['category'] ?? 'general',
      timeLimit: json['timeLimit'] ?? 600, // Default 10 minutes
      passingScore: json['passingScore'] ?? 70,
      totalQuestions: json['totalQuestions'] ?? 0,
      xpReward: json['xpReward'] ?? 50,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert QuizModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseId': courseId,
      'moduleId': moduleId,
      'difficulty': difficulty,
      'category': category,
      'timeLimit': timeLimit,
      'passingScore': passingScore,
      'totalQuestions': totalQuestions,
      'xpReward': xpReward,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create a copy with updated fields
  QuizModel copyWith({
    String? id,
    String? title,
    String? description,
    String? courseId,
    String? moduleId,
    String? difficulty,
    String? category,
    int? timeLimit,
    int? passingScore,
    int? totalQuestions,
    int? xpReward,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      moduleId: moduleId ?? this.moduleId,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      timeLimit: timeLimit ?? this.timeLimit,
      passingScore: passingScore ?? this.passingScore,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      xpReward: xpReward ?? this.xpReward,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted time limit
  String get formattedTimeLimit {
    final minutes = timeLimit ~/ 60;
    final seconds = timeLimit % 60;
    return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
  }

  /// Check if score passes
  bool isPassing(int score) {
    return score >= passingScore;
  }
}

// Type alias for backward compatibility
typedef Quiz = QuizModel;
