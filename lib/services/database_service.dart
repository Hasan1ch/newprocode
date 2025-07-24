import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/models/user_model.dart';
import 'package:procode/utils/app_logger.dart';
import 'package:procode/models/leaderboard_entry_model.dart';
import 'package:procode/models/quiz_model.dart';
import 'package:procode/models/question_model.dart';
import 'package:procode/models/quiz_result_model.dart';
import 'package:procode/models/user_stats_model.dart';
// Add these imports for course functionality
import 'package:procode/models/course_model.dart';
import 'package:procode/models/module_model.dart';
import 'package:procode/models/lesson_model.dart';
import 'package:procode/config/firebase_config.dart';

/// Main database service handling all Firestore operations
/// This is the central point for all database interactions in the app
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
  /// Creates a new user document in Firestore with all required fields
  /// Also creates a corresponding user_stats document for tracking metrics
  Future<void> createUser(UserModel user) async {
    try {
      // Ensure user has privacy settings
      final userDataWithPrivacy = user.toFirestore();
      if (!userDataWithPrivacy.containsKey('privacySettings') ||
          userDataWithPrivacy['privacySettings'] == null) {
        userDataWithPrivacy['privacySettings'] = {
          'showEmail': false,
          'showProgress': true,
          'showOnLeaderboard': true,
        };
      }

      await _usersCollection.doc(user.id).set(userDataWithPrivacy);

      // Create user stats document with same XP values
      await _userStatsCollection.doc(user.id).set({
        'totalXP': user.totalXP,
        'level': user.level,
        'currentStreak': user.currentStreak,
        'longestStreak': user.longestStreak,
        'lessonsCompleted': 0,
        'quizzesCompleted': 0,
        'challengesCompleted': 0,
        'coursesCompleted': 0,
        'perfectQuizzes': 0,
        'totalTimeSpent': 0,
        'lastActiveDate': FieldValue.serverTimestamp(),
        'xpHistory': {},
        'dailyXP': {},
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      AppLogger.info('User created in Firestore: ${user.id}');
    } catch (e) {
      AppLogger.error('Error creating user: $e', error: e);
      rethrow;
    }
  }

  // Get user by ID
  /// Retrieves a user document from Firestore by their unique ID
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
  /// Updates specific fields in a user document
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
  /// Deletes a user and all their associated data from the database
  /// Also releases their username for future use
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
  /// Checks if a username is available (case-insensitive)
  /// Returns true if available, false if taken
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
  /// Reserves a username for a specific user to prevent duplicates
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
  /// Releases a username back to the pool of available usernames
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
  /// Updates a user's username atomically, releasing the old one and reserving the new one
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
  /// Updates the last login date and triggers streak calculation
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
  /// Updates whether a user has verified their email address
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
  /// Calculates and updates the user's daily streak
  /// Handles consecutive days, broken streaks, and first-time users
  Future<void> updateStreak(String uid) async {
    try {
      // Use a transaction to ensure atomic updates
      await _firestore.runTransaction((transaction) async {
        // Get both user and user_stats documents
        DocumentSnapshot userDoc =
            await transaction.get(_usersCollection.doc(uid));
        DocumentSnapshot statsDoc =
            await transaction.get(_userStatsCollection.doc(uid));

        if (!userDoc.exists) return;

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        DateTime? lastActiveDate =
            (userData['lastActiveDate'] as Timestamp?)?.toDate();
        int currentStreak = userData['currentStreak'] ?? 0;
        int longestStreak = userData['longestStreak'] ?? 0;

        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);

        // Initialize streak if this is the first activity
        if (lastActiveDate == null) {
          currentStreak = 1;
          longestStreak = 1;
        } else {
          DateTime lastActiveDay = DateTime(
              lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);

          int daysDifference = today.difference(lastActiveDay).inDays;

          if (daysDifference == 0) {
            // Same day - don't update streak
            AppLogger.info(
                'User already active today, streak remains: $currentStreak');
            return;
          } else if (daysDifference == 1) {
            // Consecutive day - increase streak
            currentStreak++;
            if (currentStreak > longestStreak) {
              longestStreak = currentStreak;
            }
            AppLogger.info('Streak increased to: $currentStreak');
          } else {
            // Streak broken - reset to 1
            AppLogger.info('Streak broken. Was $currentStreak, reset to 1');
            currentStreak = 1;
          }
        }

        // Update both collections
        transaction.update(_usersCollection.doc(uid), {
          'currentStreak': currentStreak,
          'longestStreak': longestStreak,
          'lastActiveDate': FieldValue.serverTimestamp(),
        });

        // Update user_stats if it exists
        if (statsDoc.exists) {
          transaction.update(_userStatsCollection.doc(uid), {
            'currentStreak': currentStreak,
            'longestStreak': longestStreak,
            'lastActiveDate': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          // Create user_stats if it doesn't exist
          transaction.set(_userStatsCollection.doc(uid), {
            'totalXP': userData['totalXP'] ?? 0,
            'level': userData['level'] ?? 1,
            'currentStreak': currentStreak,
            'longestStreak': longestStreak,
            'lessonsCompleted': 0,
            'quizzesCompleted': 0,
            'challengesCompleted': 0,
            'coursesCompleted': userData['completedCourses']?.length ?? 0,
            'perfectQuizzes': 0,
            'totalTimeSpent': 0,
            'lastActiveDate': FieldValue.serverTimestamp(),
            'xpHistory': {},
            'dailyXP': {},
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      AppLogger.info('Streak updated successfully for user: $uid');
    } catch (e) {
      AppLogger.error('Error updating streak: $e', error: e);
    }
  }

  // FIXED addXP method to properly update both collections
  /// Adds XP to a user and recalculates their level
  /// Updates both users and user_stats collections for consistency
  Future<void> addXP(String uid, int xpToAdd) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc =
            await transaction.get(_usersCollection.doc(uid));
        DocumentSnapshot statsDoc =
            await transaction.get(_userStatsCollection.doc(uid));

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        int currentXP = data['totalXP'] ?? 0;
        int newXP = currentXP + xpToAdd;

        // Calculate new level using FirebaseConfig
        int newLevel = FirebaseConfig.calculateLevel(newXP);

        // Update users collection
        transaction.update(_usersCollection.doc(uid), {
          'totalXP': newXP,
          'xp': newXP, // For backward compatibility
          'level': newLevel,
          'lastActiveDate': FieldValue.serverTimestamp(),
        });

        // Update user_stats collection with daily XP tracking
        final today = DateTime.now();
        final dateKey =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

        if (statsDoc.exists) {
          final statsData = statsDoc.data() as Map<String, dynamic>;
          final dailyXP = Map<String, dynamic>.from(statsData['dailyXP'] ?? {});
          dailyXP[dateKey] = (dailyXP[dateKey] ?? 0) + xpToAdd;

          transaction.update(_userStatsCollection.doc(uid), {
            'totalXP': newXP,
            'level': newLevel,
            'dailyXP': dailyXP,
            'lastActiveDate': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          // Create user_stats if it doesn't exist
          transaction.set(_userStatsCollection.doc(uid), {
            'totalXP': newXP,
            'level': newLevel,
            'currentStreak': data['currentStreak'] ?? 0,
            'longestStreak': data['longestStreak'] ?? 0,
            'lessonsCompleted': 0,
            'quizzesCompleted': 0,
            'challengesCompleted': 0,
            'coursesCompleted': data['completedCourses']?.length ?? 0,
            'perfectQuizzes': 0,
            'totalTimeSpent': 0,
            'lastActiveDate': FieldValue.serverTimestamp(),
            'xpHistory': {},
            'dailyXP': {dateKey: xpToAdd},
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      AppLogger.info('Added $xpToAdd XP to user: $uid');
    } catch (e) {
      AppLogger.error('Error adding XP: $e', error: e);
      rethrow;
    }
  }

  // Progress tracking

  // Mark lesson as completed - FIXED to use addXP
  /// Marks a lesson as completed and awards XP to the user
  /// Updates both user document and stats collection
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

          // Update stats
          transaction.update(_userStatsCollection.doc(uid), {
            'lessonsCompleted': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      // Add XP after transaction
      await addXP(uid, xpReward);

      AppLogger.info('Lesson $lessonId marked as completed for user: $uid');
    } catch (e) {
      AppLogger.error('Error marking lesson completed: $e', error: e);
      rethrow;
    }
  }

  // Mark quiz as completed - FIXED to use addXP
  /// Records quiz completion and awards XP based on score
  /// Tracks perfect quizzes separately for achievements
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

          // Update stats
          final updates = {
            'quizzesCompleted': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          };

          // Track perfect quizzes
          if (score == 100) {
            updates['perfectQuizzes'] = FieldValue.increment(1);
          }

          transaction.update(_userStatsCollection.doc(uid), updates);
        }
      });

      // Add XP based on score
      int adjustedXP = (xpReward * score / 100).round();
      await addXP(uid, adjustedXP);

      AppLogger.info('Quiz $quizId marked as completed for user: $uid');
    } catch (e) {
      AppLogger.error('Error marking quiz completed: $e', error: e);
      rethrow;
    }
  }

  // Achievement operations

  // Grant achievement to user
  /// Grants an achievement to a user by adding it to their achievement list
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
  /// Retrieves user statistics as a raw map
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
  /// Searches for users whose username starts with the query string
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

  // ============= UPDATED LEADERBOARD METHODS WITH REAL DATA =============

  // Get global leaderboard with real user data
  /// Fetches the global leaderboard sorted by total XP
  /// Respects user privacy settings and filters accordingly
  Future<List<LeaderboardEntry>> getGlobalLeaderboard(
      {required int limit}) async {
    try {
      AppLogger.info('Fetching global leaderboard...');

      // Query users collection directly WITHOUT privacy filter first
      // We'll check privacy settings individually
      final snapshot = await _usersCollection
          .orderBy('totalXP', descending: true)
          .limit(limit * 2) // Get more to account for privacy filtering
          .get();

      AppLogger.info('Found ${snapshot.docs.length} users in database');

      final entries = <LeaderboardEntry>[];
      int rank = 1;

      for (final doc in snapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;

        // Log user data for debugging
        AppLogger.info(
            'Processing user: ${userData['username']}, XP: ${userData['totalXP']}');

        // Check privacy settings - default to true if not set
        final privacySettings =
            Map<String, dynamic>.from(userData['privacySettings'] ?? {});
        final showOnLeaderboard = privacySettings['showOnLeaderboard'] ?? true;

        if (showOnLeaderboard) {
          entries.add(LeaderboardEntry(
            id: doc.id,
            userId: doc.id,
            username: userData['username'] ?? '',
            displayName: userData['displayName'] ?? userData['username'] ?? '',
            avatarUrl: userData['avatarUrl'],
            totalXP: userData['totalXP'] ?? 0,
            weeklyXP: 0, // Will be calculated separately
            monthlyXP: 0, // Will be calculated separately
            level: userData['level'] ?? 1,
            currentStreak: userData['currentStreak'] ?? 0,
            completedCourses:
                (userData['completedCourses'] as List?)?.length ?? 0,
            rank: rank++,
            lastActive: userData['lastActiveDate'] != null
                ? (userData['lastActiveDate'] as Timestamp).toDate()
                : DateTime.now(),
            lastUpdated: userData['lastActiveDate'] != null
                ? (userData['lastActiveDate'] as Timestamp).toDate()
                : DateTime.now(),
          ));

          if (entries.length >= limit) break;
        }
      }

      AppLogger.info('Returning ${entries.length} leaderboard entries');
      return entries;
    } catch (e) {
      AppLogger.error('Error getting global leaderboard: $e', error: e);
      return [];
    }
  }

  // Get weekly leaderboard with calculated weekly XP
  /// Calculates weekly leaderboard based on XP earned in the last 7 days
  /// Uses dailyXP tracking from user_stats collection
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard(
      {required int limit}) async {
    try {
      AppLogger.info('Fetching weekly leaderboard...');

      final weekAgo = DateTime.now().subtract(const Duration(days: 7));

      // Get all users, we'll filter by activity
      final snapshot = await _usersCollection
          .orderBy('lastActiveDate', descending: true)
          .get();

      final entries = <LeaderboardEntry>[];

      for (final doc in snapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;

        // Check if user was active in the last week
        final lastActive = userData['lastActiveDate'] != null
            ? (userData['lastActiveDate'] as Timestamp).toDate()
            : null;

        if (lastActive == null || lastActive.isBefore(weekAgo)) continue;

        // Check privacy settings
        final privacySettings =
            Map<String, dynamic>.from(userData['privacySettings'] ?? {});
        final showOnLeaderboard = privacySettings['showOnLeaderboard'] ?? true;

        if (!showOnLeaderboard) continue;

        // Get user stats for weekly XP calculation
        final statsDoc = await _userStatsCollection.doc(doc.id).get();
        int weeklyXP = 0;

        if (statsDoc.exists) {
          final statsData = statsDoc.data() as Map<String, dynamic>;
          final dailyXP = Map<String, dynamic>.from(statsData['dailyXP'] ?? {});

          // Calculate weekly XP from dailyXP map
          for (int i = 0; i < 7; i++) {
            final date = DateTime.now().subtract(Duration(days: i));
            final dateKey =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            final xp = dailyXP[dateKey];
            if (xp != null) {
              weeklyXP += (xp as num).toInt();
            }
          }
        }

        if (weeklyXP > 0) {
          entries.add(LeaderboardEntry(
            id: doc.id,
            userId: doc.id,
            username: userData['username'] ?? '',
            displayName: userData['displayName'] ?? userData['username'] ?? '',
            avatarUrl: userData['avatarUrl'],
            totalXP: userData['totalXP'] ?? 0,
            weeklyXP: weeklyXP,
            monthlyXP: 0,
            level: userData['level'] ?? 1,
            currentStreak: userData['currentStreak'] ?? 0,
            completedCourses:
                (userData['completedCourses'] as List?)?.length ?? 0,
            rank: 0, // Will be set after sorting
            lastActive: lastActive,
            lastUpdated: lastActive,
          ));
        }
      }

      // Sort by weekly XP and assign ranks
      entries.sort((a, b) => b.weeklyXP.compareTo(a.weeklyXP));
      for (int i = 0; i < entries.length && i < limit; i++) {
        entries[i] = entries[i].copyWith(rank: i + 1);
      }

      AppLogger.info('Returning ${entries.length} weekly leaderboard entries');
      return entries.take(limit).toList();
    } catch (e) {
      AppLogger.error('Error getting weekly leaderboard: $e', error: e);
      return [];
    }
  }

  // Get monthly leaderboard with calculated monthly XP
  /// Calculates monthly leaderboard based on XP earned in the last 30 days
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard(
      {required int limit}) async {
    try {
      AppLogger.info('Fetching monthly leaderboard...');

      final monthAgo = DateTime.now().subtract(const Duration(days: 30));

      // Get all users, we'll filter by activity
      final snapshot = await _usersCollection
          .orderBy('lastActiveDate', descending: true)
          .get();

      final entries = <LeaderboardEntry>[];

      for (final doc in snapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;

        // Check if user was active in the last month
        final lastActive = userData['lastActiveDate'] != null
            ? (userData['lastActiveDate'] as Timestamp).toDate()
            : null;

        if (lastActive == null || lastActive.isBefore(monthAgo)) continue;

        // Check privacy settings
        final privacySettings =
            Map<String, dynamic>.from(userData['privacySettings'] ?? {});
        final showOnLeaderboard = privacySettings['showOnLeaderboard'] ?? true;

        if (!showOnLeaderboard) continue;

        // Get user stats for monthly XP calculation
        final statsDoc = await _userStatsCollection.doc(doc.id).get();
        int monthlyXP = 0;

        if (statsDoc.exists) {
          final statsData = statsDoc.data() as Map<String, dynamic>;
          final dailyXP = Map<String, dynamic>.from(statsData['dailyXP'] ?? {});

          // Calculate monthly XP from dailyXP map
          for (int i = 0; i < 30; i++) {
            final date = DateTime.now().subtract(Duration(days: i));
            final dateKey =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            final xp = dailyXP[dateKey];
            if (xp != null) {
              monthlyXP += (xp as num).toInt();
            }
          }
        }

        if (monthlyXP > 0) {
          entries.add(LeaderboardEntry(
            id: doc.id,
            userId: doc.id,
            username: userData['username'] ?? '',
            displayName: userData['displayName'] ?? userData['username'] ?? '',
            avatarUrl: userData['avatarUrl'],
            totalXP: userData['totalXP'] ?? 0,
            weeklyXP: 0,
            monthlyXP: monthlyXP,
            level: userData['level'] ?? 1,
            currentStreak: userData['currentStreak'] ?? 0,
            completedCourses:
                (userData['completedCourses'] as List?)?.length ?? 0,
            rank: 0, // Will be set after sorting
            lastActive: lastActive,
            lastUpdated: lastActive,
          ));
        }
      }

      // Sort by monthly XP and assign ranks
      entries.sort((a, b) => b.monthlyXP.compareTo(a.monthlyXP));
      for (int i = 0; i < entries.length && i < limit; i++) {
        entries[i] = entries[i].copyWith(rank: i + 1);
      }

      AppLogger.info('Returning ${entries.length} monthly leaderboard entries');
      return entries.take(limit).toList();
    } catch (e) {
      AppLogger.error('Error getting monthly leaderboard: $e', error: e);
      return [];
    }
  }

  // Get course leaderboard - unchanged but with privacy check
  /// Gets leaderboard for a specific course based on XP earned in that course
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
          .limit(limit * 2) // Get more to filter out privacy settings
          .get();

      final leaderboardEntries = <LeaderboardEntry>[];

      // For each progress document, get the user data
      for (final progressDoc in progressDocs.docs) {
        final progressData = progressDoc.data();
        final userId = progressData['userId'] as String;

        final userDoc = await _usersCollection.doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;

          // Check privacy settings
          final privacySettings =
              Map<String, dynamic>.from(userData['privacySettings'] ?? {});
          if (privacySettings['showOnLeaderboard'] != false) {
            leaderboardEntries.add(LeaderboardEntry(
              id: userId,
              userId: userId,
              username: userData['username'] ?? '',
              displayName:
                  userData['displayName'] ?? userData['username'] ?? '',
              avatarUrl: userData['avatarUrl'],
              totalXP: progressData['totalXpEarned'] ?? 0,
              weeklyXP: 0,
              monthlyXP: 0,
              level: userData['level'] ?? 1,
              currentStreak: userData['currentStreak'] ?? 0,
              completedCourses:
                  (userData['completedCourses'] as List?)?.length ?? 0,
              rank: leaderboardEntries.length + 1,
              lastActive: userData['lastActiveDate'] != null
                  ? (userData['lastActiveDate'] as Timestamp).toDate()
                  : DateTime.now(),
              lastUpdated: userData['lastActiveDate'] != null
                  ? (userData['lastActiveDate'] as Timestamp).toDate()
                  : DateTime.now(),
            ));

            if (leaderboardEntries.length >= limit) break;
          }
        }
      }

      return leaderboardEntries;
    } catch (e) {
      AppLogger.error('Error getting course leaderboard: $e', error: e);
      return [];
    }
  }

  // Get user global rank with privacy check
  /// Calculates a user's global rank considering privacy settings
  Future<int?> getUserGlobalRank(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>;
      final userXP = userData['totalXP'] ?? 0;

      // Count users with higher XP (considering privacy settings)
      final allUsers =
          await _usersCollection.where('totalXP', isGreaterThan: userXP).get();

      int rank = 1;
      for (final doc in allUsers.docs) {
        final otherUserData = doc.data() as Map<String, dynamic>;
        final privacySettings =
            Map<String, dynamic>.from(otherUserData['privacySettings'] ?? {});
        final showOnLeaderboard = privacySettings['showOnLeaderboard'] ?? true;

        if (showOnLeaderboard) {
          rank++;
        }
      }

      return rank;
    } catch (e) {
      AppLogger.error('Error getting user global rank: $e', error: e);
      return null;
    }
  }

  // Get user weekly rank
  /// Calculates user's rank based on weekly XP
  Future<int?> getUserWeeklyRank(String userId) async {
    try {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));

      // Get user's weekly XP
      final statsDoc = await _userStatsCollection.doc(userId).get();
      if (!statsDoc.exists) return null;

      final statsData = statsDoc.data() as Map<String, dynamic>;
      final dailyXP = Map<String, int>.from(statsData['dailyXP'] ?? {});

      int userWeeklyXP = 0;
      for (int i = 0; i < 7; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        userWeeklyXP += dailyXP[dateKey] ?? 0;
      }

      if (userWeeklyXP == 0) return null;

      // For simplicity, return global rank for now
      // You can implement proper weekly rank calculation if needed
      return await getUserGlobalRank(userId);
    } catch (e) {
      AppLogger.error('Error getting user weekly rank: $e', error: e);
      return null;
    }
  }

  // Get user monthly rank
  /// Calculates user's rank based on monthly XP
  Future<int?> getUserMonthlyRank(String userId) async {
    try {
      final monthAgo = DateTime.now().subtract(const Duration(days: 30));

      // Get user's monthly XP
      final statsDoc = await _userStatsCollection.doc(userId).get();
      if (!statsDoc.exists) return null;

      final statsData = statsDoc.data() as Map<String, dynamic>;
      final dailyXP = Map<String, int>.from(statsData['dailyXP'] ?? {});

      int userMonthlyXP = 0;
      for (int i = 0; i < 30; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        userMonthlyXP += dailyXP[dateKey] ?? 0;
      }

      if (userMonthlyXP == 0) return null;

      // For simplicity, return global rank for now
      // You can implement proper monthly rank calculation if needed
      return await getUserGlobalRank(userId);
    } catch (e) {
      AppLogger.error('Error getting user monthly rank: $e', error: e);
      return null;
    }
  }

  // Get user course rank
  /// Calculates user's rank within a specific course
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

  // Get leaderboard entry for a specific user
  /// Creates a complete leaderboard entry for a user with all calculated stats
  Future<LeaderboardEntry?> getLeaderboardEntry(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data() as Map<String, dynamic>;

      // Get user stats for weekly/monthly XP
      final statsDoc = await _userStatsCollection.doc(userId).get();
      int weeklyXP = 0;
      int monthlyXP = 0;

      if (statsDoc.exists) {
        final statsData = statsDoc.data() as Map<String, dynamic>;
        final dailyXP = Map<String, int>.from(statsData['dailyXP'] ?? {});

        // Calculate weekly and monthly XP
        for (int i = 0; i < 30; i++) {
          final date = DateTime.now().subtract(Duration(days: i));
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final dayXP = dailyXP[dateKey] ?? 0;

          if (i < 7) weeklyXP += dayXP;
          monthlyXP += dayXP;
        }
      }

      final rank = await getUserGlobalRank(userId) ?? 0;

      return LeaderboardEntry(
        id: userId,
        userId: userId,
        username: userData['username'] ?? '',
        displayName: userData['displayName'] ?? userData['username'] ?? '',
        avatarUrl: userData['avatarUrl'],
        totalXP: userData['totalXP'] ?? 0,
        weeklyXP: weeklyXP,
        monthlyXP: monthlyXP,
        level: userData['level'] ?? 1,
        currentStreak: userData['currentStreak'] ?? 0,
        completedCourses: (userData['completedCourses'] as List?)?.length ?? 0,
        rank: rank,
        lastActive: userData['lastActiveDate'] != null
            ? (userData['lastActiveDate'] as Timestamp).toDate()
            : DateTime.now(),
        lastUpdated: userData['lastActiveDate'] != null
            ? (userData['lastActiveDate'] as Timestamp).toDate()
            : DateTime.now(),
      );
    } catch (e) {
      AppLogger.error('Error getting leaderboard entry: $e', error: e);
      return null;
    }
  }

  // Migration method to ensure all users have privacy settings
  /// Adds default privacy settings to users who don't have them
  /// Used for database migration when adding new features
  Future<void> migrateUserPrivacySettings() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _usersCollection.get();

      int updateCount = 0;

      for (final doc in snapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;

        // Check if privacySettings exists
        if (!userData.containsKey('privacySettings') ||
            userData['privacySettings'] == null ||
            (userData['privacySettings'] as Map).isEmpty) {
          // Add default privacy settings
          batch.update(doc.reference, {
            'privacySettings': {
              'showEmail': false,
              'showProgress': true,
              'showOnLeaderboard': true,
            }
          });

          updateCount++;
        }
      }

      if (updateCount > 0) {
        await batch.commit();
        AppLogger.info('Updated privacy settings for $updateCount users');
      } else {
        AppLogger.info('All users already have privacy settings');
      }
    } catch (e) {
      AppLogger.error('Error migrating privacy settings: $e', error: e);
      rethrow;
    }
  }

  // ============= QUIZ METHODS =============

  // Get quizzes by category
  /// Fetches all quizzes in a specific category, ordered by difficulty
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
  /// Fetches quizzes associated with a specific module in a course
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
  /// Retrieves a specific quiz by its ID
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
  /// Fetches all questions for a quiz, ordered by their index
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
  /// Saves a user's quiz attempt result to the database
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
  /// Retrieves all quiz attempts by a user, ordered by most recent
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
  /// Checks if a user has attempted a specific quiz before
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
  /// Gets the highest score a user has achieved on a specific quiz
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
  /// Creates a new user stats document
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
  /// Retrieves user statistics as a strongly-typed model
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
  /// Helper method that wraps addXP for gamification service
  Future<void> awardXP(String userId, int xpAmount) async {
    try {
      await addXP(userId, xpAmount);
    } catch (e) {
      AppLogger.error('Error awarding XP: $e', error: e);
      rethrow;
    }
  }

  // ============= COURSE METHODS =============

  // Get all courses
  /// Fetches all available courses, ordered by creation date
  Future<List<CourseModel>> getAllCourses() async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting all courses: $e', error: e);
      return [];
    }
  }

  // Get courses by language
  /// Fetches courses filtered by programming language
  Future<List<CourseModel>> getCoursesByLanguage(String language) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('language', isEqualTo: language)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting courses by language: $e', error: e);
      return [];
    }
  }

  // Get featured courses
  /// Fetches courses marked as featured for homepage display
  Future<List<CourseModel>> getFeaturedCourses() async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CourseModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting featured courses: $e', error: e);
      return [];
    }
  }

  // Get course by ID
  /// Retrieves a specific course by its ID
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      final doc = await _firestore.collection('courses').doc(courseId).get();

      if (!doc.exists) return null;

      return CourseModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      AppLogger.error('Error getting course by id: $e', error: e);
      return null;
    }
  }

  // Get course modules
  /// Fetches all modules for a course, ordered by their index
  Future<List<ModuleModel>> getCourseModules(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection('modules')
          .where('courseId', isEqualTo: courseId)
          .orderBy('orderIndex')
          .get();

      return snapshot.docs
          .map((doc) => ModuleModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting course modules: $e', error: e);
      return [];
    }
  }

  // Get module lessons
  /// Fetches all lessons in a module, ordered by their index
  Future<List<LessonModel>> getModuleLessons(String moduleId) async {
    try {
      final snapshot = await _firestore
          .collection('lessons')
          .where('moduleId', isEqualTo: moduleId)
          .orderBy('orderIndex')
          .get();

      return snapshot.docs
          .map((doc) => LessonModel.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting module lessons: $e', error: e);
      return [];
    }
  }

  // Get lesson by ID
  /// Retrieves a specific lesson by its ID
  Future<LessonModel?> getLessonById(String lessonId) async {
    try {
      final doc = await _firestore.collection('lessons').doc(lessonId).get();

      if (!doc.exists) return null;

      return LessonModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
    } catch (e) {
      AppLogger.error('Error getting lesson by id: $e', error: e);
      return null;
    }
  }

  // ============= PROGRESS TRACKING METHODS =============

  // Create or update course progress
  /// Creates new progress or updates existing progress for a user in a course
  Future<void> createOrUpdateProgress({
    required String userId,
    required String courseId,
    required Map<String, dynamic> progressData,
  }) async {
    try {
      // Check if progress already exists
      final existingProgress = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .limit(1)
          .get();

      if (existingProgress.docs.isNotEmpty) {
        // Update existing progress
        await _firestore
            .collection('progress')
            .doc(existingProgress.docs.first.id)
            .update({
          ...progressData,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        AppLogger.info('Updated progress for user $userId in course $courseId');
      } else {
        // Create new progress
        await _firestore.collection('progress').add({
          'userId': userId,
          'courseId': courseId,
          ...progressData,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        AppLogger.info(
            'Created new progress for user $userId in course $courseId');
      }
    } catch (e) {
      AppLogger.error('Error creating/updating progress: $e', error: e);
      rethrow;
    }
  }

  // Get user's progress for a specific course
  /// Retrieves progress data for a user in a specific course
  Future<Map<String, dynamic>?> getUserCourseProgress({
    required String userId,
    required String courseId,
  }) async {
    try {
      final progressSnapshot = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .limit(1)
          .get();

      if (progressSnapshot.docs.isEmpty) {
        return null;
      }

      return {
        'id': progressSnapshot.docs.first.id,
        ...progressSnapshot.docs.first.data(),
      };
    } catch (e) {
      AppLogger.error('Error getting user course progress: $e', error: e);
      return null;
    }
  }

  // Get all progress for a user
  /// Retrieves all course progress records for a user
  Future<List<Map<String, dynamic>>> getUserAllProgress({
    required String userId,
  }) async {
    try {
      final progressSnapshot = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .get();

      return progressSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      AppLogger.error('Error getting user progress: $e', error: e);
      return [];
    }
  }

  // Delete user's progress for a course
  /// Removes all progress data for a user in a specific course
  Future<void> deleteUserCourseProgress({
    required String userId,
    required String courseId,
  }) async {
    try {
      final progressSnapshot = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .get();

      final batch = _firestore.batch();

      for (final doc in progressSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      AppLogger.info('Deleted progress for user $userId in course $courseId');
    } catch (e) {
      AppLogger.error('Error deleting user course progress: $e', error: e);
      rethrow;
    }
  }

  // Fix progress completion percentage
  /// Recalculates course completion percentage based on completed lessons
  Future<void> recalculateProgressPercentage({
    required String userId,
    required String courseId,
  }) async {
    try {
      // Get progress document
      final progressSnapshot = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .limit(1)
          .get();

      if (progressSnapshot.docs.isEmpty) {
        AppLogger.warning(
            'No progress found for user $userId in course $courseId');
        return;
      }

      final progressDoc = progressSnapshot.docs.first;
      final progressData = progressDoc.data();

      // Get all modules for the course
      final modules = await getCourseModules(courseId);

      // Calculate total lessons
      int totalLessons = 0;
      for (final module in modules) {
        totalLessons += module.lessonIds.length;
      }

      // Get completed lessons count
      final completedLessons =
          List<String>.from(progressData['completedLessons'] ?? []);
      final completedCount = completedLessons.length;

      // Calculate percentage
      final percentage =
          totalLessons > 0 ? (completedCount / totalLessons) * 100 : 0.0;

      // Update the progress document
      await progressDoc.reference.update({
        'completionPercentage': percentage,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      AppLogger.info(
          'Recalculated progress: $completedCount/$totalLessons = ${percentage.toStringAsFixed(2)}%');
    } catch (e) {
      AppLogger.error('Error recalculating progress percentage: $e', error: e);
      rethrow;
    }
  }

  // Ensure all progress documents have userId
  /// Validates that all progress documents have required userId field
  Future<void> validateAllProgressDocuments() async {
    try {
      final progressSnapshot = await _firestore.collection('progress').get();

      int invalidCount = 0;

      for (final doc in progressSnapshot.docs) {
        final data = doc.data();

        if (!data.containsKey('userId') ||
            data['userId'] == null ||
            data['userId'] == '') {
          invalidCount++;
          AppLogger.warning('Invalid progress document found: ${doc.id}');
        }
      }

      AppLogger.info(
          'Progress validation complete. Found $invalidCount invalid documents out of ${progressSnapshot.docs.length} total.');
    } catch (e) {
      AppLogger.error('Error validating progress documents: $e', error: e);
      rethrow;
    }
  }

  // SYNC XP DATA - Helper method to fix inconsistencies
  /// Syncs XP data between users and user_stats collections
  /// user_stats is considered the source of truth
  Future<void> syncUserXP(String uid) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Get user_stats document (source of truth)
        DocumentSnapshot statsDoc =
            await transaction.get(_userStatsCollection.doc(uid));

        if (statsDoc.exists) {
          Map<String, dynamic> statsData =
              statsDoc.data() as Map<String, dynamic>;
          int correctXP = statsData['totalXP'] ?? 0;
          int correctLevel = FirebaseConfig.calculateLevel(correctXP);

          // Update users collection to match
          transaction.update(_usersCollection.doc(uid), {
            'totalXP': correctXP,
            'xp': correctXP, // For backward compatibility
            'level': correctLevel,
          });

          // Also update level in stats if needed
          if (statsData['level'] != correctLevel) {
            transaction.update(_userStatsCollection.doc(uid), {
              'level': correctLevel,
            });
          }

          AppLogger.info(
              'Synced XP for user $uid: $correctXP XP, Level $correctLevel');
        }
      });
    } catch (e) {
      AppLogger.error('Error syncing user XP: $e', error: e);
    }
  }
}
