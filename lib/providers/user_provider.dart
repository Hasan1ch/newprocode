import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/models/user_model.dart';
import 'package:procode/models/achievement_model.dart';
import 'package:procode/models/user_stats_model.dart';
import 'package:procode/services/database_service.dart';
import 'package:procode/services/storage_service.dart';
import 'package:procode/services/gamification_service.dart';
import 'package:procode/utils/app_logger.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final GamificationService _gamificationService = GamificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream subscriptions for real-time updates
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<DocumentSnapshot>? _userStatsSubscription;
  StreamSubscription<QuerySnapshot>? _achievementsSubscription;

  UserModel? _user;
  UserStats? _userStats;
  List<Achievement> _achievements = [];
  Map<String, int> _stats = {};
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  UserModel? get user => _user;
  UserStats? get userStats => _userStats;
  List<Achievement> get achievements => _achievements;
  Map<String, int> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize user data with real-time listeners
  Future<void> loadUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      _currentUserId = userId;
      notifyListeners();

      // Cancel any existing subscriptions
      await _cancelSubscriptions();

      // Set up real-time listener for user document
      _userSubscription =
          _firestore.collection('users').doc(userId).snapshots().listen(
        (snapshot) {
          if (snapshot.exists) {
            _user = UserModel.fromFirestore(snapshot);
            _isLoading = false;

            // Load dependent data when user updates
            _loadUserStatsRealtime();
            _loadAchievementsRealtime();

            // Defer stats update to avoid setState during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateStats();
            });

            notifyListeners();
            AppLogger.info('User data updated in real-time');
          } else {
            _error = 'User not found';
            _isLoading = false;
            notifyListeners();
          }
        },
        onError: (error) {
          _error = 'Failed to load user data: $error';
          _isLoading = false;
          notifyListeners();
          AppLogger.error('Real-time user listener error: $error');
        },
      );
    } catch (e) {
      _error = 'Failed to initialize user data';
      _isLoading = false;
      notifyListeners();
      AppLogger.error('UserProvider.loadUser: $e');
    }
  }

  // Load user stats - now uses real-time updates
  Future<void> loadUserStats() async {
    if (_user == null) return;

    try {
      // If real-time subscription is not active, start it
      if (_userStatsSubscription == null) {
        _loadUserStatsRealtime();
      }

      // If we don't have stats yet, create from user model
      if (_userStats == null) {
        _userStats = UserStats(
          uid: _user!.id,
          totalXP: _user!.totalXP,
          level: _user!.level,
          currentStreak: _user!.currentStreak,
          longestStreak: _user!.longestStreak,
          lessonsCompleted: 0, // You'll need to calculate this
          quizzesCompleted: 0, // You'll need to calculate this
          challengesCompleted: _user!.completedChallenges.length,
          coursesCompleted: _user!.completedCourses.length,
          perfectQuizzes: 0, // You'll need to calculate this
          totalTimeSpent: 0,
          lastActiveDate: _user!.lastActiveDate ?? DateTime.now(),
          xpHistory: {},
          dailyXP: {},
        );
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('UserProvider.loadUserStats: $e');
    }
  }

  // Load user stats with real-time updates
  void _loadUserStatsRealtime() {
    if (_currentUserId == null) return;

    _userStatsSubscription?.cancel();

    _userStatsSubscription = _firestore
        .collection('user_stats')
        .doc(_currentUserId)
        .snapshots()
        .listen(
      (snapshot) {
        if (snapshot.exists) {
          _userStats = UserStats.fromJson({
            'uid': _currentUserId!,
            ...snapshot.data()!,
          });

          // Defer stats update to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateStats();
          });

          notifyListeners();
          AppLogger.info('User stats updated in real-time');
        } else if (_user != null) {
          // Create UserStats from UserModel if stats document doesn't exist
          _userStats = UserStats(
            uid: _user!.id,
            totalXP: _user!.totalXP,
            level: _user!.level,
            currentStreak: _user!.currentStreak,
            longestStreak: _user!.longestStreak,
            lessonsCompleted: _user!.completedCourses.length * 4, // Estimate
            quizzesCompleted: _user!.completedCourses.length, // Estimate
            challengesCompleted: _user!.completedChallenges.length,
            coursesCompleted: _user!.completedCourses.length,
            perfectQuizzes: 0,
            totalTimeSpent: 0,
            lastActiveDate: _user!.lastActiveDate ?? DateTime.now(),
            xpHistory: {},
            dailyXP: {},
          );

          // Defer stats update to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateStats();
          });

          notifyListeners();
        }
      },
      onError: (error) {
        AppLogger.error('Real-time user stats listener error: $error');
      },
    );
  }

  // Load user achievements
  Future<void> _loadAchievements() async {
    if (_user == null) return;

    try {
      _achievements = await _gamificationService.getUserAchievements(_user!.id);
    } catch (e) {
      AppLogger.error('UserProvider._loadAchievements: $e');
    }
  }

  // Load achievements with real-time updates
  void _loadAchievementsRealtime() {
    if (_currentUserId == null) return;

    _achievementsSubscription?.cancel();

    // Listen to achievements collection for user's achievements
    _achievementsSubscription =
        _firestore.collection('achievements').snapshots().listen(
      (snapshot) async {
        if (_user != null) {
          // Filter achievements that user has unlocked
          final allAchievements = snapshot.docs
              .map((doc) => Achievement.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }))
              .where(
                  (achievement) => _user!.achievements.contains(achievement.id))
              .toList();

          _achievements = allAchievements;
          notifyListeners();
          AppLogger.info('Achievements updated in real-time');
        }
      },
      onError: (error) {
        AppLogger.error('Real-time achievements listener error: $error');
      },
    );
  }

  // Load user stats (legacy format for compatibility)
  Future<void> _loadStats() async {
    if (_user == null || _userStats == null) return;

    try {
      _stats = {
        'totalXP': _userStats!.totalXP,
        'level': _userStats!.level,
        'currentStreak': _userStats!.currentStreak,
        'coursesCompleted': _userStats!.coursesCompleted,
        'lessonsCompleted': _userStats!.lessonsCompleted,
        'quizzesCompleted': _userStats!.quizzesCompleted,
        'challengesCompleted': _userStats!.challengesCompleted,
        'perfectQuizzes': _userStats!.perfectQuizzes,
      };
    } catch (e) {
      AppLogger.error('UserProvider._loadStats: $e');
    }
  }

  // Update stats from current data
  void _updateStats() {
    if (_userStats != null) {
      _stats = {
        'totalXP': _userStats!.totalXP,
        'level': _userStats!.level,
        'currentStreak': _userStats!.currentStreak,
        'coursesCompleted': _userStats!.coursesCompleted,
        'lessonsCompleted': _userStats!.lessonsCompleted,
        'quizzesCompleted': _userStats!.quizzesCompleted,
        'challengesCompleted': _userStats!.challengesCompleted,
        'perfectQuizzes': _userStats!.perfectQuizzes,
      };
    } else if (_user != null) {
      // Fallback to user model data
      _stats = {
        'totalXP': _user!.totalXP,
        'level': _user!.level,
        'currentStreak': _user!.currentStreak,
        'coursesCompleted': _user!.completedCourses.length,
        'lessonsCompleted': 0,
        'quizzesCompleted': 0,
        'challengesCompleted': _user!.completedChallenges.length,
        'perfectQuizzes': 0,
      };
    }
  }

  // Update user profile - FIXED VERSION
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? country,
    String? learningGoal,
    XFile? imageFile,
  }) async {
    if (_user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Upload avatar if provided
      String? avatarUrl = _user!.avatarUrl;
      if (imageFile != null) {
        avatarUrl = await _storageService.uploadAvatar(
          userId: _user!.id,
          imageFile: imageFile,
        );
      }

      // Prepare update data
      final updateData = <String, dynamic>{};

      if (displayName != null && displayName.isNotEmpty) {
        updateData['displayName'] = displayName;
      }

      if (bio != null) {
        updateData['bio'] = bio;
      }

      if (country != null) {
        updateData['country'] = country;
      }

      if (learningGoal != null) {
        updateData['learningGoal'] = learningGoal;
      }

      if (avatarUrl != null) {
        updateData['avatarUrl'] = avatarUrl;
      }

      // Update in Firestore directly
      await _databaseService.updateUser(_user!.id, updateData);

      AppLogger.info('Profile updated successfully with data: $updateData');
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      AppLogger.error('UserProvider.updateProfile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update privacy settings
  Future<void> updatePrivacySettings({
    bool? showEmail,
    bool? showProgress,
    bool? showOnLeaderboard,
  }) async {
    if (_user == null) return;

    try {
      // Update privacy settings from your UserModel structure
      final updatedPrivacySettings =
          Map<String, dynamic>.from(_user!.privacySettings);
      if (showEmail != null) updatedPrivacySettings['showEmail'] = showEmail;
      if (showProgress != null)
        updatedPrivacySettings['showProgress'] = showProgress;
      if (showOnLeaderboard != null)
        updatedPrivacySettings['showOnLeaderboard'] = showOnLeaderboard;

      _user = _user!.copyWith(
        privacySettings: updatedPrivacySettings,
      );

      await _databaseService.updateUser(_user!.id, {
        'privacySettings': updatedPrivacySettings,
      });
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update privacy settings';
      AppLogger.error('UserProvider.updatePrivacySettings: $e');
    }
  }

  // Feature achievement
  Future<void> featureAchievement(String achievementId, int position) async {
    if (_user == null || position < 0 || position > 4) return;

    try {
      List<String> featured = List.from(_user!.featuredAchievements);

      // Remove if already featured
      featured.remove(achievementId);

      // Add at position
      if (featured.length > position) {
        featured.insert(position, achievementId);
        // Keep only 5
        if (featured.length > 5) {
          featured = featured.sublist(0, 5);
        }
      } else {
        featured.add(achievementId);
      }

      await _databaseService.updateUser(_user!.id, {
        'featuredAchievements': featured,
      });
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update featured achievements';
      AppLogger.error('UserProvider.featureAchievement: $e');
    }
  }

  // Refresh user data
  Future<void> refresh() async {
    if (_user != null) {
      await loadUser(_user!.id);
    }
  }

  // Clear user data (for logout)
  void clear() {
    _cancelSubscriptions();
    _user = null;
    _userStats = null;
    _achievements = [];
    _stats = {};
    _error = null;
    _currentUserId = null;
    notifyListeners();
  }

  // Cancel all subscriptions
  Future<void> _cancelSubscriptions() async {
    await _userSubscription?.cancel();
    await _userStatsSubscription?.cancel();
    await _achievementsSubscription?.cancel();
    _userSubscription = null;
    _userStatsSubscription = null;
    _achievementsSubscription = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  // Utility method to manually trigger XP update (for testing)
  Future<void> debugAddXP(int amount) async {
    if (_user == null) return;

    try {
      await _firestore.collection('users').doc(_user!.id).update({
        'totalXP': FieldValue.increment(amount),
        'level': UserModel.calculateLevel(_user!.totalXP + amount),
      });

      // Also update user_stats
      await _firestore.collection('user_stats').doc(_user!.id).update({
        'totalXP': FieldValue.increment(amount),
        'level': UserModel.calculateLevel(_user!.totalXP + amount),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      AppLogger.info('Debug: Added $amount XP');
    } catch (e) {
      AppLogger.error('Debug XP update failed: $e');
    }
  }
}
