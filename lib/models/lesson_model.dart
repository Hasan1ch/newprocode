import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a lesson in a module
class LessonModel {
  final String id;
  final String moduleId;
  final String courseId;
  final String title;
  final String content;
  final String videoUrl;
  final int orderIndex;
  final int estimatedMinutes;
  final int xpReward;
  final List<String> codeExamples;
  final List<String> keyPoints;
  final String? challengeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonModel({
    required this.id,
    required this.moduleId,
    required this.courseId,
    required this.title,
    required this.content,
    required this.videoUrl,
    required this.orderIndex,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.codeExamples,
    required this.keyPoints,
    this.challengeId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create LessonModel from JSON
  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] ?? '',
      moduleId: json['moduleId'] ?? '',
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      orderIndex: json['orderIndex'] ?? 0,
      estimatedMinutes: json['estimatedMinutes'] ?? 0,
      xpReward: json['xpReward'] ?? 10,
      codeExamples: List<String>.from(json['codeExamples'] ?? []),
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      challengeId: json['challengeId'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert LessonModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'courseId': courseId,
      'title': title,
      'content': content,
      'videoUrl': videoUrl,
      'orderIndex': orderIndex,
      'estimatedMinutes': estimatedMinutes,
      'xpReward': xpReward,
      'codeExamples': codeExamples,
      'keyPoints': keyPoints,
      'challengeId': challengeId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with updated fields
  LessonModel copyWith({
    String? id,
    String? moduleId,
    String? courseId,
    String? title,
    String? content,
    String? videoUrl,
    int? orderIndex,
    int? estimatedMinutes,
    int? xpReward,
    List<String>? codeExamples,
    List<String>? keyPoints,
    String? challengeId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonModel(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      content: content ?? this.content,
      videoUrl: videoUrl ?? this.videoUrl,
      orderIndex: orderIndex ?? this.orderIndex,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      xpReward: xpReward ?? this.xpReward,
      codeExamples: codeExamples ?? this.codeExamples,
      keyPoints: keyPoints ?? this.keyPoints,
      challengeId: challengeId ?? this.challengeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if lesson has a code challenge
  bool get hasChallenge => challengeId != null && challengeId!.isNotEmpty;

  /// Get lesson type based on content
  String get lessonType {
    if (videoUrl.isNotEmpty) return 'Video';
    if (codeExamples.isNotEmpty) return 'Code';
    return 'Reading';
  }
}

typedef Lesson = LessonModel;
