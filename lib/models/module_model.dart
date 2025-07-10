import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a course module
/// Groups related lessons into chapters
class ModuleModel {
  final String id;
  final String courseId; // Parent course reference
  final String title;
  final String description;
  final int orderIndex; // Module sequence in course
  final List<String> lessonIds; // Ordered list of lessons
  final String quizId; // Module completion quiz
  final int estimatedMinutes; // Total time for all lessons

  ModuleModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.lessonIds,
    required this.quizId,
    required this.estimatedMinutes,
  });

  /// Creates module from Firestore document
  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      orderIndex: json['orderIndex'] ?? 0,
      lessonIds: List<String>.from(json['lessonIds'] ?? []),
      quizId: json['quizId'] ?? '',
      estimatedMinutes: json['estimatedMinutes'] ?? 0,
    );
  }

  /// Converts module to Firestore format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
      'lessonIds': lessonIds,
      'quizId': quizId,
      'estimatedMinutes': estimatedMinutes,
    };
  }

  /// Creates a modified copy of the module
  ModuleModel copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    int? orderIndex,
    List<String>? lessonIds,
    String? quizId,
    int? estimatedMinutes,
  }) {
    return ModuleModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      lessonIds: lessonIds ?? this.lessonIds,
      quizId: quizId ?? this.quizId,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }
}

// Alias for cleaner imports
typedef Module = ModuleModel;
