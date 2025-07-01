import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing user progress in a course
class ProgressModel {
  String id; // Made non-final so we can update it after creation
  final String userId;
  final String courseId;
  final List<String> completedModules;
  final List<String> completedLessons;
  final Map<String, int> quizScores; // quizId: score
  final String currentModuleId;
  final String currentLessonId;
  final String lastAccessedLesson;
  final DateTime lastAccessedAt;
  final DateTime enrolledAt;
  final int totalXpEarned;
  final double completionPercentage;

  ProgressModel({
    this.id = '',
    required this.userId,
    required this.courseId,
    required this.completedModules,
    required this.completedLessons,
    required this.quizScores,
    required this.currentModuleId,
    required this.currentLessonId,
    required this.lastAccessedLesson,
    required this.lastAccessedAt,
    required this.enrolledAt,
    required this.totalXpEarned,
    required this.completionPercentage,
  });

  /// Create ProgressModel from JSON
  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      courseId: json['courseId'] ?? '',
      completedModules: List<String>.from(json['completedModules'] ?? []),
      completedLessons: List<String>.from(json['completedLessons'] ?? []),
      quizScores: Map<String, int>.from(json['quizScores'] ?? {}),
      currentModuleId: json['currentModuleId'] ?? '',
      currentLessonId: json['currentLessonId'] ?? '',
      lastAccessedLesson: json['lastAccessedLesson'] ?? '',
      lastAccessedAt: json['lastAccessedAt'] != null
          ? (json['lastAccessedAt'] as Timestamp).toDate()
          : DateTime.now(),
      enrolledAt: json['enrolledAt'] != null
          ? (json['enrolledAt'] as Timestamp).toDate()
          : DateTime.now(),
      totalXpEarned: json['totalXpEarned'] ?? 0,
      completionPercentage: (json['completionPercentage'] ?? 0).toDouble(),
    );
  }

  /// Convert ProgressModel to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'userId': userId,
      'courseId': courseId,
      'completedModules': completedModules,
      'completedLessons': completedLessons,
      'quizScores': quizScores,
      'currentModuleId': currentModuleId,
      'currentLessonId': currentLessonId,
      'lastAccessedLesson': lastAccessedLesson,
      'lastAccessedAt': Timestamp.fromDate(lastAccessedAt),
      'enrolledAt': Timestamp.fromDate(enrolledAt),
      'totalXpEarned': totalXpEarned,
      'completionPercentage': completionPercentage,
    };
  }

  /// Create a copy with updated fields
  ProgressModel copyWith({
    String? id,
    String? userId,
    String? courseId,
    List<String>? completedModules,
    List<String>? completedLessons,
    Map<String, int>? quizScores,
    String? currentModuleId,
    String? currentLessonId,
    String? lastAccessedLesson,
    DateTime? lastAccessedAt,
    DateTime? enrolledAt,
    int? totalXpEarned,
    double? completionPercentage,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      completedModules: completedModules ?? this.completedModules,
      completedLessons: completedLessons ?? this.completedLessons,
      quizScores: quizScores ?? this.quizScores,
      currentModuleId: currentModuleId ?? this.currentModuleId,
      currentLessonId: currentLessonId ?? this.currentLessonId,
      lastAccessedLesson: lastAccessedLesson ?? this.lastAccessedLesson,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}

// Type alias for CourseProvider compatibility
typedef Progress = ProgressModel;
