import 'package:flutter/material.dart';
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

  UserModel? _user;
  UserStats? _userStats;
  List<Achievement> _achievements = [];
  Map<String, int> _stats = {};
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  UserStats? get userStats => _userStats;
  List<Achievement> get achievements => _achievements;
  Map<String, int> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize user data
  Future<void> loadUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _databaseService.getUser(userId);
      await loadUserStats();
      await _loadAchievements();
      await _loadStats();
    } catch (e) {
      _error = 'Failed to load user data';
      AppLogger.error('UserProvider.loadUser: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user stats
  Future<void> loadUserStats() async {
    if (_user == null) return;

    try {
      // Since your UserModel already has stats properties, create UserStats from it
      _userStats = UserStats(
        uid: _user!.id, // Changed from uid to id
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
    } catch (e) {
      AppLogger.error('UserProvider.loadUserStats: $e');
    }
  }

  // Update user profile
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

      // Update user model
      _user = _user!.copyWith(
        displayName: displayName ?? _user!.displayName,
        bio: bio ?? _user!.bio,
        country: country ?? _user!.country,
        learningGoal: learningGoal ?? _user!.learningGoal,
        avatarUrl: avatarUrl,
      );

      // Save to database
      await _databaseService.updateUser(_user!.id, _user!.toJson());
    } catch (e) {
      _error = 'Failed to update profile';
      AppLogger.error('UserProvider.updateProfile: $e');
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

      await _databaseService.updateUser(_user!.id, _user!.toJson());
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

      _user = _user!.copyWith(featuredAchievements: featured);
      await _databaseService.updateUser(_user!.id, _user!.toJson());
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update featured achievements';
      AppLogger.error('UserProvider.featureAchievement: $e');
    }
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

  // Refresh user data
  Future<void> refresh() async {
    if (_user != null) {
      await loadUser(_user!.id);
    }
  }

  // Clear user data (for logout)
  void clear() {
    _user = null;
    _userStats = null;
    _achievements = [];
    _stats = {};
    _error = null;
    notifyListeners();
  }
}
