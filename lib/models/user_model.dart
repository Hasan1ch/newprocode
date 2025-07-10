import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/models/progress_model.dart';

/// Core user model representing a learner's complete profile
/// This model contains all user data including progress, achievements,
/// preferences, and gamification stats
class UserModel {
  final String id;
  final String uid; // Added for compatibility with Firebase Auth
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String? country;
  final String? learningGoal;
  // Gamification fields
  final int totalXP;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final DateTime createdAt;
  // Course tracking
  final List<String> completedCourses;
  final List<String> enrolledCourses;
  final Map<String, ProgressModel> progress; // Maps courseId to progress data
  // Achievements system
  final List<String> achievements;
  final List<String> featuredAchievements; // Displayed on profile
  final List<String> completedChallenges;
  // User preferences and settings
  final Map<String, dynamic> privacySettings;
  final Map<DateTime, int> activityData; // Daily activity tracking for streaks
  // Learning preferences captured during onboarding
  final String? skillLevel;
  final String? learningStyle;
  final List<String>? preferredLanguages;
  final int? weeklyHours;

  UserModel({
    required this.id,
    String? uid,
    required this.email,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.country,
    this.learningGoal,
    required this.totalXP,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActiveDate,
    required this.createdAt,
    required this.completedCourses,
    required this.enrolledCourses,
    required this.progress,
    required this.achievements,
    required this.featuredAchievements,
    required this.completedChallenges,
    required this.privacySettings,
    required this.activityData,
    this.skillLevel,
    this.learningStyle,
    this.preferredLanguages,
    this.weeklyHours,
  }) : uid = uid ?? id; // uid defaults to id for compatibility

  // Factory constructor for Firestore document
  // Handles direct conversion from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  // Main factory constructor for JSON parsing
  // Handles backward compatibility with multiple field names
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse progress map - converts JSON to ProgressModel instances
    Map<String, ProgressModel> progressMap = {};
    if (json['progress'] != null) {
      Map<String, dynamic> progressData =
          json['progress'] as Map<String, dynamic>;
      progressData.forEach((key, value) {
        progressMap[key] =
            ProgressModel.fromJson(value as Map<String, dynamic>);
      });
    }

    // Parse activity data - converts string dates to DateTime objects
    Map<DateTime, int> activityMap = {};
    if (json['activityData'] != null) {
      Map<String, dynamic> activityData =
          json['activityData'] as Map<String, dynamic>;
      activityData.forEach((key, value) {
        activityMap[DateTime.parse(key)] = value as int;
      });
    }

    return UserModel(
      // Handle both 'id' and 'uid' fields for compatibility
      id: json['id'] ?? json['uid'] ?? '',
      uid: json['uid'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      country: json['country'],
      learningGoal: json['learningGoal'],
      // Support both 'totalXP' and 'xp' field names for backward compatibility
      totalXP: json['totalXP'] ?? json['xp'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      // Handle both 'lastActiveDate' and 'lastLoginDate' for compatibility
      lastActiveDate: json['lastActiveDate'] != null
          ? (json['lastActiveDate'] as Timestamp).toDate()
          : json['lastLoginDate'] != null
              ? (json['lastLoginDate'] as Timestamp).toDate()
              : null,
      // Support both 'createdAt' and 'joinDate' field names
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : json['joinDate'] != null
              ? (json['joinDate'] as Timestamp).toDate()
              : DateTime.now(),
      completedCourses: List<String>.from(json['completedCourses'] ?? []),
      enrolledCourses: List<String>.from(json['enrolledCourses'] ?? []),
      progress: progressMap,
      achievements: List<String>.from(json['achievements'] ?? []),
      featuredAchievements:
          List<String>.from(json['featuredAchievements'] ?? []),
      completedChallenges: List<String>.from(json['completedChallenges'] ?? []),
      // Provide default privacy settings if not present
      privacySettings: Map<String, dynamic>.from(json['privacySettings'] ??
          {
            'showEmail': false,
            'showProgress': true,
            'showOnLeaderboard': true,
          }),
      activityData: activityMap,
      skillLevel: json['skillLevel'],
      learningStyle: json['learningStyle'],
      preferredLanguages: json['preferredLanguages'] != null
          ? List<String>.from(json['preferredLanguages'])
          : null,
      weeklyHours: json['weeklyHours'],
    );
  }

  // Convert to JSON for Firestore storage
  // Maintains backward compatibility by storing duplicate fields
  Map<String, dynamic> toJson() {
    // Convert progress map back to JSON
    Map<String, dynamic> progressJson = {};
    progress.forEach((key, value) {
      progressJson[key] = value.toJson();
    });

    // Convert activity data - DateTime objects to ISO strings
    Map<String, dynamic> activityJson = {};
    activityData.forEach((key, value) {
      activityJson[key.toIso8601String()] = value;
    });

    return {
      'id': id,
      'uid': uid,
      'email': email,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'country': country,
      'learningGoal': learningGoal,
      'totalXP': totalXP,
      'xp': totalXP, // Duplicate field for backward compatibility
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate':
          lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
      'lastLoginDate': // Duplicate field for backward compatibility
          lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'joinDate': Timestamp.fromDate(createdAt), // Duplicate for compatibility
      'completedCourses': completedCourses,
      'enrolledCourses': enrolledCourses,
      'progress': progressJson,
      'achievements': achievements,
      'featuredAchievements': featuredAchievements,
      'completedChallenges': completedChallenges,
      'privacySettings': privacySettings,
      'activityData': activityJson,
      'skillLevel': skillLevel,
      'learningStyle': learningStyle,
      'preferredLanguages': preferredLanguages,
      'weeklyHours': weeklyHours,
    };
  }

  // Convert to Firestore format (same as toJson)
  Map<String, dynamic> toFirestore() => toJson();

  // Create a copy with updated fields
  // Essential for state management when updating user data
  UserModel copyWith({
    String? id,
    String? uid,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? country,
    String? learningGoal,
    int? totalXP,
    int? level,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    DateTime? createdAt,
    List<String>? completedCourses,
    List<String>? enrolledCourses,
    Map<String, ProgressModel>? progress,
    List<String>? achievements,
    List<String>? featuredAchievements,
    List<String>? completedChallenges,
    Map<String, dynamic>? privacySettings,
    Map<DateTime, int>? activityData,
    String? skillLevel,
    String? learningStyle,
    List<String>? preferredLanguages,
    int? weeklyHours,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      learningGoal: learningGoal ?? this.learningGoal,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      createdAt: createdAt ?? this.createdAt,
      completedCourses: completedCourses ?? this.completedCourses,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      progress: progress ?? this.progress,
      achievements: achievements ?? this.achievements,
      featuredAchievements: featuredAchievements ?? this.featuredAchievements,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      privacySettings: privacySettings ?? this.privacySettings,
      activityData: activityData ?? this.activityData,
      skillLevel: skillLevel ?? this.skillLevel,
      learningStyle: learningStyle ?? this.learningStyle,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      weeklyHours: weeklyHours ?? this.weeklyHours,
    );
  }

  // Helper method to calculate level from XP
  // Uses a progressive scale where each level requires more XP
  static int calculateLevel(int xp) {
    // Simple level calculation - adjust as needed
    if (xp < 100) return 1;
    if (xp < 300) return 2;
    if (xp < 600) return 3;
    if (xp < 1000) return 4;
    if (xp < 1500) return 5;
    if (xp < 2500) return 6;
    if (xp < 4000) return 7;
    if (xp < 6000) return 8;
    if (xp < 9000) return 9;
    return 10; // Max level cap at 10
  }
}
