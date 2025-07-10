import 'package:cloud_firestore/cloud_firestore.dart';
// Import required for Color
import 'package:flutter/material.dart';
export 'course_model.dart';

/// Model representing a programming course
/// Contains all metadata and content structure for a learning path
class CourseModel {
  final String id;
  final String title;
  final String description;
  final String
      language; // Programming language: python, javascript, html_css, web_dev
  final String difficulty; // Skill level: beginner, intermediate, advanced
  final int estimatedHours; // Total time to complete course
  final int moduleCount; // Number of modules/chapters
  final String thumbnailUrl; // Cover image for course card
  final List<String> prerequisites; // Required prior knowledge
  final DateTime createdAt;
  final DateTime updatedAt;
  final String icon; // Emoji or icon identifier
  final int enrolledCount; // Number of enrolled students
  final double rating; // Average user rating (0-5)
  final int xpReward; // XP earned on completion
  final List<String> tags; // Searchable keywords
  final bool isFeatured; // Highlighted on home screen
  final String category; // Course classification

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.language,
    required this.difficulty,
    required this.estimatedHours,
    required this.moduleCount,
    required this.thumbnailUrl,
    required this.prerequisites,
    required this.createdAt,
    required this.updatedAt,
    required this.icon,
    this.enrolledCount = 0,
    this.rating = 0.0,
    this.xpReward = 100,
    this.tags = const [],
    this.isFeatured = false,
    this.category = 'General',
  });

  /// Creates course from Firestore document
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      language: json['language'] ?? 'python',
      difficulty: json['difficulty'] ?? 'beginner',
      estimatedHours: json['estimatedHours'] ?? 0,
      moduleCount: json['moduleCount'] ?? 0,
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      icon: json['icon'] ?? '📚', // Default book emoji
      enrolledCount: json['enrolledCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      xpReward: json['xpReward'] ?? 100,
      tags: List<String>.from(json['tags'] ?? []),
      isFeatured: json['isFeatured'] ?? false,
      category: json['category'] ?? 'General',
    );
  }

  /// Converts course to Firestore document format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'language': language,
      'difficulty': difficulty,
      'estimatedHours': estimatedHours,
      'moduleCount': moduleCount,
      'thumbnailUrl': thumbnailUrl,
      'prerequisites': prerequisites,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'icon': icon,
      'enrolledCount': enrolledCount,
      'rating': rating,
      'xpReward': xpReward,
      'tags': tags,
      'isFeatured': isFeatured,
      'category': category,
    };
  }

  /// Creates a modified copy of the course
  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? language,
    String? difficulty,
    int? estimatedHours,
    int? moduleCount,
    String? thumbnailUrl,
    List<String>? prerequisites,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? icon,
    int? enrolledCount,
    double? rating,
    int? xpReward,
    List<String>? tags,
    bool? isFeatured,
    String? category,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      language: language ?? this.language,
      difficulty: difficulty ?? this.difficulty,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      moduleCount: moduleCount ?? this.moduleCount,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      prerequisites: prerequisites ?? this.prerequisites,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      icon: icon ?? this.icon,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      rating: rating ?? this.rating,
      xpReward: xpReward ?? this.xpReward,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      category: category ?? this.category,
    );
  }

  /// Returns appropriate color for difficulty level
  /// Used in UI to visually indicate course complexity
  Color getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50); // Green - easy start
      case 'intermediate':
        return const Color(0xFFFF9800); // Orange - moderate challenge
      case 'advanced':
        return const Color(0xFFF44336); // Red - expert level
      default:
        return const Color(0xFF9E9E9E); // Grey - undefined
    }
  }

  /// Formats language ID into readable display name
  String getLanguageDisplayName() {
    switch (language) {
      case 'python':
        return 'Python';
      case 'javascript':
        return 'JavaScript';
      case 'html_css':
        return 'HTML & CSS';
      case 'web_dev':
        return 'Web Development';
      case 'java':
        return 'Java';
      case 'cpp':
        return 'C++';
      default:
        return language; // Return as-is if not mapped
    }
  }
}

// Alias for cleaner code elsewhere
typedef Course = CourseModel;
