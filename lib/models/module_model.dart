/// Model representing a course module
class ModuleModel {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final int orderIndex;
  final List<String> lessonIds;
  final String quizId;
  final int estimatedMinutes;

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

  /// Create ModuleModel from JSON
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

  /// Convert ModuleModel to JSON
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

  /// Create a copy with updated fields
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

typedef Module = ModuleModel;
