import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/models/user_model.dart';
import 'package:procode/utils/app_logger.dart';
import 'package:procode/models/leaderboard_entry_model.dart';
import 'package:procode/models/quiz_model.dart';
import 'package:procode/models/question_model.dart';
import 'package:procode/models/quiz_result_model.dart';
import 'package:procode/models/user_stats_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _usernamesCollection =>
      _firestore.collection('usernames');
  CollectionReference get _userStatsCollection =>
      _firestore.collection('user_stats');

  // User CRUD operations

  // Create new user
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toFirestore());

      // Create user stats document
      await _userStatsCollection.doc(user.id).set({
        'totalXP': 0,
        'totalLessonsCompleted': 0,
        'totalQuizzesCompleted': 0,
        'totalTimeSpent': 0,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      AppLogger.info('User created in Firestore: ${user.id}');
    } catch (e) {
      AppLogger.error('Error creating user: $e', error: e);
      rethrow;
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting user: $e', error: e);
      rethrow;
    }
  }

  // Update user
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(uid).update(data);
      AppLogger.info('User updated: $uid');
    } catch (e) {
      AppLogger.error('Error updating user: $e', error: e);
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String uid) async {
    try {
      // Get username to release it
      DocumentSnapshot userDoc = await _usersCollection.doc(uid).get();
      if (userDoc.exists) {
        String? username = (userDoc.data() as Map<String, dynamic>)['username'];
        if (username != null) {
          await releaseUsername(username);
        }
      }

      // Delete user document
      await _usersCollection.doc(uid).delete();

      // Delete user stats
      await _userStatsCollection.doc(uid).delete();

      // Delete other user-related data
      // TODO: Add deletion of user's progress, achievements, etc.

      AppLogger.info('User deleted: $uid');
    } catch (e) {
      AppLogger.error('Error deleting user: $e', error: e);
      rethrow;
    }
  }

  // Username operations

  // Check if username is available
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      username = username.trim().toLowerCase();
      DocumentSnapshot doc = await _usernamesCollection.doc(username).get();
      return !doc.exists;
    } catch (e) {
      AppLogger.error('Error checking username availability: $e', error: e);
      return false;
    }
  }

  // Reserve username
  Future<void> reserveUsername(String username, String uid) async {
    try {
      username = username.trim().toLowerCase();
      await _usernamesCollection.doc(username).set({
        'uid': uid,
        'reservedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.info('Username reserved: $username for user $uid');
    } catch (e) {
      AppLogger.error('Error reserving username: $e', error: e);
      rethrow;
    }
  }

  // Release username (when changing username or deleting account)
  Future<void> releaseUsername(String username) async {
    try {
      username = username.trim().toLowerCase();
      await _usernamesCollection.doc(username).delete();
      AppLogger.info('Username released: $username');
    } catch (e) {
      AppLogger.error('Error releasing username: $e', error: e);
      rethrow;
    }
  }

  // Update username
  Future<void> updateUsername(
      String uid, String oldUsername, String newUsername) async {
    try {
      // Check new username availability
      bool isAvailable = await checkUsernameAvailability(newUsername);
      if (!isAvailable) {
        throw Exception('Username is already taken');
      }

      // Use transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        // Release old username
        transaction
            .delete(_usernamesCollection.doc(oldUsername.trim().toLowerCase()));

        // Reserve new username
        transaction
            .set(_usernamesCollection.doc(newUsername.trim().toLowerCase()), {
          'uid': uid,
          'reservedAt': FieldValue.serverTimestamp(),
        });

        // Update user document
        transaction.update(_usersCollection.doc(uid), {
          'username': newUsername.trim(),
        });
      });

      AppLogger.info('Username updated from $oldUsername to $newUsername');
    } catch (e) {
      AppLogger.error('Error updating username: $e', error: e);
      rethrow;
    }
  }

  // Authentication related operations

  // Update last login date
  Future<void> updateLastLoginDate(String uid) async {
    try {
      await _usersCollection.doc(uid).update({
        'lastLoginDate': FieldValue.serverTimestamp(),
      });

      // Update streak
      await updateStreak(uid);

      AppLogger.info('Last login date updated for user: $uid');
    } catch (e) {
      AppLogger.error('Error updating last login date: $e', error: e);
    }
  }

  // Update email verification status
  Future<void> updateEmailVerificationStatus(
      String uid, bool isVerified) async {
    try {
      await _usersCollection.doc(uid).update({
        'emailVerified': isVerified,
      });
      AppLogger.info('Email verification status updated for user: $uid');
    } catch (e) {
      AppLogger.error('Error updating email verification status: $e', error: e);
      rethrow;
    }
  }

  // Gamification operations

  // Update user streak
  Future<void> updateStreak(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return;

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime? lastLogin = (data['lastLoginDate'] as Timestamp?)?.toDate();
      int currentStreak = data['currentStreak'] ?? 0;
      int longestStreak = data['longestStreak'] ?? 0;

      if (lastLogin != null) {
        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);
        DateTime lastLoginDay =
            DateTime(lastLogin.year, lastLogin.month, lastLogin.day);

        int daysDifference = today.difference(lastLoginDay).inDays;

        if (daysDifference == 1) {
          // Consecutive day - increase streak
          currentStreak++;
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
        } else if (daysDifference > 1) {
          // Streak broken - reset to 1
          currentStreak = 1;
        }
        // If daysDifference == 0, user already logged in today, don't update

        await _usersCollection.doc(uid).update({
          'currentStreak': currentStreak,
          'longestStreak': longestStreak,
        });
      }
    } catch (e) {
      AppLogger.error('Error updating streak: $e', error: e);
    }
  }

  // Add XP to user
  Future<void> addXP(String uid, int xpToAdd) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc =
            await transaction.get(_usersCollection.doc(uid));

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        int currentXP = data['totalXP'] ?? 0;
        int newXP = currentXP + xpToAdd;

        // Calculate new level
        int newLevel = UserModel.calculateLevel(newXP);

        transaction.update(_usersCollection.doc(uid), {
          'totalXP': newXP,
          'level': newLevel,
        });

        // Update stats
        transaction.update(_userStatsCollection.doc(uid), {
          'totalXP': FieldValue.increment(xpToAdd),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });

      AppLogger.info('Added $xpToAdd XP to user: $uid');
    } catch (e) {
      AppLogger.error('Error adding XP: $e', error: e);
      rethrow;
    }
  }

  // Progress tracking

  // Mark lesson as completed
  Future<void> markLessonCompleted(
      String uid, String lessonId, int xpReward) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc =
            await transaction.get(_usersCollection.doc(uid));

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        List<String> completedLessons =
            List<String>.from(data['completedLessons'] ?? []);

        if (!completedLessons.contains(lessonId)) {
          completedLessons.add(lessonId);

          transaction.update(_usersCollection.doc(uid), {
            'completedLessons': completedLessons,
          });

          // Add XP
          await addXP(uid, xpReward);

          // Update stats
          transaction.update(_userStatsCollection.doc(uid), {
            'totalLessonsCompleted': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      AppLogger.info('Lesson $lessonId marked as completed for user: $uid');
    } catch (e) {
      AppLogger.error('Error marking lesson completed: $e', error: e);
      rethrow;
    }
  }

  // Mark quiz as completed
  Future<void> markQuizCompleted(
      String uid, String quizId, int score, int xpReward) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc =
            await transaction.get(_usersCollection.doc(uid));

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        List<String> completedQuizzes =
            List<String>.from(data['completedQuizzes'] ?? []);

        if (!completedQuizzes.contains(quizId)) {
          completedQuizzes.add(quizId);

          transaction.update(_usersCollection.doc(uid), {
            'completedQuizzes': completedQuizzes,
          });

          // Add XP based on score
          int adjustedXP = (xpReward * score / 100).round();
          await addXP(uid, adjustedXP);

          // Update stats
          transaction.update(_userStatsCollection.doc(uid), {
            'totalQuizzesCompleted': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      AppLogger.info('Quiz $quizId marked as completed for user: $uid');
    } catch (e) {
      AppLogger.error('Error marking quiz completed: $e', error: e);
      rethrow;
    }
  }

  // Achievement operations

  // Grant achievement to user
  Future<void> grantAchievement(String uid, String achievementId) async {
    try {
      await _usersCollection.doc(uid).update({
        'achievements': FieldValue.arrayUnion([achievementId]),
      });

      AppLogger.info('Achievement $achievementId granted to user: $uid');
    } catch (e) {
      AppLogger.error('Error granting achievement: $e', error: e);
      rethrow;
    }
  }

  // Get user stats (returns Map for backward compatibility)
  Future<Map<String, dynamic>?> getUserStatsMap(String uid) async {
    try {
      DocumentSnapshot doc = await _userStatsCollection.doc(uid).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting user stats: $e', error: e);
      rethrow;
    }
  }

  // Search users by username (for social features)
  Future<List<UserModel>> searchUsersByUsername(String query) async {
    try {
      query = query.trim().toLowerCase();

      // Search for usernames starting with the query
      QuerySnapshot snapshot = await _usersCollection
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + 'z')
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      AppLogger.error('Error searching users: $e', error: e);
      return [];
    }
  }

  // ============= LEADERBOARD METHODS =============

  // Get global leaderboard
  Future<List<LeaderboardEntry>> getGlobalLeaderboard(
      {required int limit}) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboard')
          .orderBy('totalXP', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting global leaderboard: $e', error: e);
      return [];
    }
  }

  // Get weekly leaderboard
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard(
      {required int limit}) async {
    try {
      final weekAgo = DateTime.now().subtract(Duration(days: 7));
      final snapshot = await _firestore
          .collection('leaderboard')
          .where('lastUpdated', isGreaterThan: Timestamp.fromDate(weekAgo))
          .orderBy('lastUpdated', descending: false)
          .orderBy('weeklyXP', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting weekly leaderboard: $e', error: e);
      return [];
    }
  }

  // Get monthly leaderboard
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard(
      {required int limit}) async {
    try {
      final monthAgo = DateTime.now().subtract(Duration(days: 30));
      final snapshot = await _firestore
          .collection('leaderboard')
          .where('lastUpdated', isGreaterThan: Timestamp.fromDate(monthAgo))
          .orderBy('lastUpdated', descending: false)
          .orderBy('monthlyXP', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LeaderboardEntry.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting monthly leaderboard: $e', error: e);
      return [];
    }
  }

  // Get course leaderboard
  Future<List<LeaderboardEntry>> getCourseLeaderboard({
    required String courseId,
    required int limit,
  }) async {
    try {
      // Query progress collection for users who have enrolled in this course
      final progressDocs = await _firestore
          .collection('progress')
          .where('courseId', isEqualTo: courseId)
          .orderBy('totalXpEarned', descending: true)
          .limit(limit)
          .get();

      final leaderboardEntries = <LeaderboardEntry>[];

      // For each progress document, get the user data
      for (final progressDoc in progressDocs.docs) {
        final progressData = progressDoc.data();
        final userId = progressData['userId'] as String;

        final userDoc = await _usersCollection.doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          leaderboardEntries.add(LeaderboardEntry.fromJson({
            'id': userId,
            'userId': userId,
            'username': userData['username'] ?? '',
            'displayName': userData['displayName'] ?? '',
            'avatarUrl': userData['avatarUrl'],
            'totalXP': progressData['totalXpEarned'] ?? 0,
            'level': userData['level'] ?? 1,
            'currentStreak': userData['currentStreak'] ?? 0,
            'rank': leaderboardEntries.length + 1,
          }));
        }
      }

      return leaderboardEntries;
    } catch (e) {
      AppLogger.error('Error getting course leaderboard: $e', error: e);
      return [];
    }
  }

  // Get user global rank
  Future<int?> getUserGlobalRank(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>;
      final userXP = userData['totalXP'] ?? 0;

      final higherRanked = await _usersCollection
          .where('totalXP', isGreaterThan: userXP)
          .count()
          .get();

      return (higherRanked.count ?? 0) + 1;
    } catch (e) {
      AppLogger.error('Error getting user global rank: $e', error: e);
      return null;
    }
  }

  // Get user weekly rank
  Future<int?> getUserWeeklyRank(String userId) async {
    try {
      // Simplified implementation - you may want to track weekly XP separately
      final weekAgo = DateTime.now().subtract(Duration(days: 7));
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>;
      final lastActive = (userData['lastActiveDate'] as Timestamp?)?.toDate();

      if (lastActive == null || lastActive.isBefore(weekAgo)) {
        return null;
      }

      return await getUserGlobalRank(userId); // Simplified for now
    } catch (e) {
      AppLogger.error('Error getting user weekly rank: $e', error: e);
      return null;
    }
  }

  // Get user monthly rank
  Future<int?> getUserMonthlyRank(String userId) async {
    try {
      // Simplified implementation
      final monthAgo = DateTime.now().subtract(Duration(days: 30));
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>;
      final lastActive = (userData['lastActiveDate'] as Timestamp?)?.toDate();

      if (lastActive == null || lastActive.isBefore(monthAgo)) {
        return null;
      }

      return await getUserGlobalRank(userId); // Simplified for now
    } catch (e) {
      AppLogger.error('Error getting user monthly rank: $e', error: e);
      return null;
    }
  }

  // Get user course rank
  Future<int?> getUserCourseRank({
    required String userId,
    required String courseId,
  }) async {
    try {
      final userProgress = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .limit(1)
          .get();

      if (userProgress.docs.isEmpty) return null;

      final userXP = userProgress.docs.first.data()['totalXpEarned'] ?? 0;

      final higherRanked = await _firestore
          .collection('progress')
          .where('courseId', isEqualTo: courseId)
          .where('totalXpEarned', isGreaterThan: userXP)
          .count()
          .get();

      return (higherRanked.count ?? 0) + 1;
    } catch (e) {
      AppLogger.error('Error getting user course rank: $e', error: e);
      return null;
    }
  }

  // Get leaderboard entry
  Future<LeaderboardEntry?> getLeaderboardEntry(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>;
      final rank = await getUserGlobalRank(userId) ?? 0;

      return LeaderboardEntry.fromJson({
        'id': userId,
        'userId': userId,
        'username': userData['username'] ?? '',
        'displayName': userData['displayName'] ?? '',
        'avatarUrl': userData['avatarUrl'],
        'totalXP': userData['totalXP'] ?? 0,
        'level': userData['level'] ?? 1,
        'currentStreak': userData['currentStreak'] ?? 0,
        'rank': rank ?? 0,
      });
    } catch (e) {
      AppLogger.error('Error getting leaderboard entry: $e', error: e);
      return null;
    }
  }

  // ============= QUIZ METHODS =============

  // Get quizzes by category
  Future<List<QuizModel>> getQuizzesByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .where('category', isEqualTo: category)
          .orderBy('difficulty')
          .get();

      return snapshot.docs
          .map((doc) => QuizModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting quizzes by category: $e', error: e);
      return [];
    }
  }

  // Get module quizzes
  Future<List<QuizModel>> getModuleQuizzes(
      String courseId, String moduleId) async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .where('courseId', isEqualTo: courseId)
          .where('moduleId', isEqualTo: moduleId)
          .get();

      return snapshot.docs
          .map((doc) => QuizModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting module quizzes: $e', error: e);
      return [];
    }
  }

  // Get quiz by ID
  Future<QuizModel?> getQuizById(String quizId) async {
    try {
      final doc = await _firestore.collection('quizzes').doc(quizId).get();

      if (!doc.exists) return null;

      return QuizModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      AppLogger.error('Error getting quiz by id: $e', error: e);
      return null;
    }
  }

  // Get quiz questions
  Future<List<QuestionModel>> getQuizQuestions(String quizId) async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .orderBy('orderIndex')
          .get();

      return snapshot.docs
          .map((doc) => QuestionModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting quiz questions: $e', error: e);
      return [];
    }
  }

  // Save quiz result
  Future<void> saveQuizResult(QuizResultModel result) async {
    try {
      await _firestore
          .collection('quiz_results')
          .doc(result.id)
          .set(result.toJson());

      AppLogger.info('Quiz result saved: ${result.id}');
    } catch (e) {
      AppLogger.error('Error saving quiz result: $e', error: e);
      rethrow;
    }
  }

  // Get user quiz history
  Future<List<QuizResultModel>> getUserQuizHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => QuizResultModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting user quiz history: $e', error: e);
      return [];
    }
  }

  // Check if user has completed quiz
  Future<bool> hasUserCompletedQuiz(String userId, String quizId) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .where('quizId', isEqualTo: quizId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      AppLogger.error('Error checking quiz completion: $e', error: e);
      return false;
    }
  }

  // Get user's best score
  Future<int?> getUserBestScore(String userId, String quizId) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .where('quizId', isEqualTo: quizId)
          .orderBy('score', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return snapshot.docs.first.data()['score'] as int?;
    } catch (e) {
      AppLogger.error('Error getting user best score: $e', error: e);
      return null;
    }
  }

  // ============= USER STATS METHODS =============

  // Create user stats
  Future<void> createUserStats(UserStats stats) async {
    try {
      await _userStatsCollection.doc(stats.uid).set(stats.toJson());
      AppLogger.info('User stats created for: ${stats.uid}');
    } catch (e) {
      AppLogger.error('Error creating user stats: $e', error: e);
      rethrow;
    }
  }

  // Get user stats as UserStats model
  Future<UserStats?> getUserStats(String uid) async {
    try {
      DocumentSnapshot doc = await _userStatsCollection.doc(uid).get();

      if (doc.exists) {
        return UserStats.fromJson({
          'uid': uid,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting user stats: $e', error: e);
      return null;
    }
  }

  // ============= GAMIFICATION SERVICE HELPER =============

  // Award XP to user
  Future<void> awardXP(String userId, int xpAmount) async {
    try {
      await addXP(userId, xpAmount);
    } catch (e) {
      AppLogger.error('Error awarding XP: $e', error: e);
      rethrow;
    }
  }
}
