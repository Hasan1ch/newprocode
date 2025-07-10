import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/config/firebase_config.dart';

/// Analytics service for tracking user learning activities and progress
/// Collects data for insights, progress tracking, and personalized recommendations
class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tracks when a user views a lesson
  /// This helps understand engagement and popular content
  Future<void> trackLessonView({
    required String userId,
    required String courseId,
    required String moduleId,
    required String lessonId,
  }) async {
    try {
      await _firestore.collection('analytics_events').add({
        'event': 'lesson_view',
        'userId': userId,
        'courseId': courseId,
        'moduleId': moduleId,
        'lessonId': lessonId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log error but don't throw - analytics shouldn't break the app
      print('Error tracking lesson view: $e');
    }
  }

  /// Tracks lesson completion with time spent
  /// Records XP earned and helps identify difficult lessons
  Future<void> trackLessonCompletion({
    required String userId,
    required String courseId,
    required String moduleId,
    required String lessonId,
    required int timeSpentSeconds,
  }) async {
    try {
      await _firestore.collection('analytics_events').add({
        'event': 'lesson_completion',
        'userId': userId,
        'courseId': courseId,
        'moduleId': moduleId,
        'lessonId': lessonId,
        'timeSpentSeconds': timeSpentSeconds,
        'xpEarned':
            FirebaseConfig.xpPerLesson, // Standard XP for lesson completion
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error tracking lesson completion: $e');
    }
  }

  /// Tracks quiz attempts with performance metrics
  /// Helps identify knowledge gaps and adjust difficulty
  Future<void> trackQuizAttempt({
    required String userId,
    required String courseId,
    required String moduleId,
    required String quizId,
    required int score,
    required int totalQuestions,
    required int timeSpentSeconds,
  }) async {
    try {
      await _firestore.collection('analytics_events').add({
        'event': 'quiz_attempt',
        'userId': userId,
        'courseId': courseId,
        'moduleId': moduleId,
        'quizId': quizId,
        'score': score,
        'totalQuestions': totalQuestions,
        'percentage': (score / totalQuestions) *
            100, // Calculate percentage for easy analysis
        'timeSpentSeconds': timeSpentSeconds,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error tracking quiz attempt: $e');
    }
  }

  /// Tracks when a user enrolls in a new course
  /// Useful for understanding course popularity and user interests
  Future<void> trackCourseEnrollment({
    required String userId,
    required String courseId,
  }) async {
    try {
      await _firestore.collection('analytics_events').add({
        'event': 'course_enrollment',
        'userId': userId,
        'courseId': courseId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error tracking course enrollment: $e');
    }
  }

  /// Tracks achievement unlocks for gamification insights
  /// Helps understand which achievements motivate users
  Future<void> trackAchievementUnlock({
    required String userId,
    required String achievementId,
    required int xpEarned,
  }) async {
    try {
      await _firestore.collection('analytics_events').add({
        'event': 'achievement_unlock',
        'userId': userId,
        'achievementId': achievementId,
        'xpEarned': xpEarned,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error tracking achievement unlock: $e');
    }
  }

  /// Aggregates user learning statistics from the last 30 days
  /// Provides insights for dashboard and progress tracking
  Future<Map<String, dynamic>> getUserLearningStats(String userId) async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      // Query events from last 30 days for this user
      final eventsSnapshot = await _firestore
          .collection('analytics_events')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThan: thirtyDaysAgo)
          .get();

      // Initialize counters
      int totalLessonsCompleted = 0;
      int totalQuizzesTaken = 0;
      int totalTimeSpent = 0;
      double averageQuizScore = 0;
      Set<String> activeDays = {};

      // Process each event
      for (final doc in eventsSnapshot.docs) {
        final data = doc.data();
        final event = data['event'] as String;

        if (event == 'lesson_completion') {
          totalLessonsCompleted++;
          totalTimeSpent += (data['timeSpentSeconds'] ?? 0) as int;
        } else if (event == 'quiz_attempt') {
          totalQuizzesTaken++;
          averageQuizScore += (data['percentage'] ?? 0) as num;
          totalTimeSpent += (data['timeSpentSeconds'] ?? 0) as int;
        }

        // Track unique active days
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final dayKey = '${timestamp.year}-${timestamp.month}-${timestamp.day}';
        activeDays.add(dayKey);
      }

      // Calculate average quiz score
      if (totalQuizzesTaken > 0) {
        averageQuizScore /= totalQuizzesTaken;
      }

      return {
        'totalLessonsCompleted': totalLessonsCompleted,
        'totalQuizzesTaken': totalQuizzesTaken,
        'totalTimeSpentMinutes': totalTimeSpent ~/ 60, // Convert to minutes
        'averageQuizScore': averageQuizScore.round(),
        'activeDaysLast30': activeDays.length,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      // Return empty stats on error
      return {
        'totalLessonsCompleted': 0,
        'totalQuizzesTaken': 0,
        'totalTimeSpentMinutes': 0,
        'averageQuizScore': 0,
        'activeDaysLast30': 0,
      };
    }
  }
}
