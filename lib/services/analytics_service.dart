import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/config/firebase_config.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track lesson view
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
      print('Error tracking lesson view: $e');
    }
  }

  // Track lesson completion
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
        'xpEarned': FirebaseConfig.xpPerLesson,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error tracking lesson completion: $e');
    }
  }

  // Track quiz attempt
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
        'percentage': (score / totalQuestions) * 100,
        'timeSpentSeconds': timeSpentSeconds,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error tracking quiz attempt: $e');
    }
  }

  // Track course enrollment
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

  // Track achievement unlock
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

  // Get user learning stats
  Future<Map<String, dynamic>> getUserLearningStats(String userId) async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      // Get events from last 30 days
      final eventsSnapshot = await _firestore
          .collection('analytics_events')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThan: thirtyDaysAgo)
          .get();

      int totalLessonsCompleted = 0;
      int totalQuizzesTaken = 0;
      int totalTimeSpent = 0;
      double averageQuizScore = 0;
      Set<String> activeDays = {};

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

        // Track active days
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        final dayKey = '${timestamp.year}-${timestamp.month}-${timestamp.day}';
        activeDays.add(dayKey);
      }

      if (totalQuizzesTaken > 0) {
        averageQuizScore /= totalQuizzesTaken;
      }

      return {
        'totalLessonsCompleted': totalLessonsCompleted,
        'totalQuizzesTaken': totalQuizzesTaken,
        'totalTimeSpentMinutes': totalTimeSpent ~/ 60,
        'averageQuizScore': averageQuizScore.round(),
        'activeDaysLast30': activeDays.length,
      };
    } catch (e) {
      print('Error getting user stats: $e');
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
