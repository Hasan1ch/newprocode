import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/models/leaderboard_entry_model.dart';
import 'package:procode/services/database_service.dart';
import 'package:procode/utils/app_logger.dart';

// Filter options for leaderboard display
enum LeaderboardFilter { global, byCourse }

/// Provider managing leaderboard data and rankings
/// Implements caching and real-time updates for competitive features
class LeaderboardProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Leaderboard data
  List<LeaderboardEntry> _entries = [];
  LeaderboardFilter _currentFilter = LeaderboardFilter.global;
  String? _selectedCourseId;
  bool _isLoading = false;
  String? _error;
  int? _userRank;
  LeaderboardEntry? _userEntry;

  // Cache management to reduce database reads
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Real-time listeners for live updates
  StreamSubscription? _leaderboardSubscription;
  StreamSubscription? _userSubscription;
  String? _currentUserId;

  // Getters for UI binding
  List<LeaderboardEntry> get entries => _entries;
  LeaderboardFilter get currentFilter => _currentFilter;
  String? get selectedCourseId => _selectedCourseId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get userRank => _userRank;
  LeaderboardEntry? get userEntry => _userEntry;

  // Check if cache is still valid
  // Prevents excessive database queries
  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  // Load leaderboard data with caching
  // Uses cached data if available and fresh
  Future<void> loadLeaderboard({String? userId}) async {
    // Store current user ID for real-time updates
    _currentUserId = userId;

    // Check cache first
    if (_isCacheValid && _entries.isNotEmpty) {
      AppLogger.info('Using cached leaderboard data');
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Cancel existing subscriptions
      await _cancelSubscriptions();

      // Load based on current filter
      switch (_currentFilter) {
        case LeaderboardFilter.global:
          await _loadGlobalLeaderboard(userId);
          break;
        case LeaderboardFilter.byCourse:
          if (_selectedCourseId != null) {
            await _loadCourseLeaderboard(userId);
          }
          break;
      }

      _lastFetchTime = DateTime.now();
    } catch (e) {
      _error = 'Failed to load leaderboard';
      AppLogger.error('LeaderboardProvider.loadLeaderboard', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load global leaderboard with real-time listener
  // Shows top 100 users by total XP with live updates
  Future<void> _loadGlobalLeaderboard(String? userId) async {
    // Initial load
    _entries = await _databaseService.getGlobalLeaderboard(limit: 100);

    // Find user's rank if userId provided
    if (userId != null) {
      _findUserRank(userId);
    }

    // Set up real-time listener for top 100
    _leaderboardSubscription = _firestore
        .collection('users')
        .where('privacySettings.showOnLeaderboard', isEqualTo: true)
        .orderBy('totalXP', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) {
      _handleLeaderboardUpdate(snapshot, userId);
    });

    // Set up listener for user's own data if not in top 100
    if (userId != null && _userRank != null && _userRank! > 100) {
      _userSubscription = _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((snapshot) {
        _handleUserUpdate(snapshot, userId);
      });
    }
  }

  // Load course leaderboard
  // Shows rankings for a specific course
  Future<void> _loadCourseLeaderboard(String? userId) async {
    if (_selectedCourseId == null) return;

    _entries = await _databaseService.getCourseLeaderboard(
      courseId: _selectedCourseId!,
      limit: 100,
    );

    if (userId != null) {
      _userRank = await _databaseService.getUserCourseRank(
        userId: userId,
        courseId: _selectedCourseId!,
      );
      if (_userRank != null && _userRank! > 100) {
        _userEntry = await _databaseService.getLeaderboardEntry(userId);
      }
    }
  }

  // Handle real-time leaderboard updates
  // Updates rankings when users gain XP
  void _handleLeaderboardUpdate(QuerySnapshot snapshot, String? userId) {
    final entries = <LeaderboardEntry>[];
    int rank = 1;

    for (final doc in snapshot.docs) {
      final userData = doc.data() as Map<String, dynamic>;

      entries.add(LeaderboardEntry(
        id: doc.id,
        userId: doc.id,
        username: userData['username'] ?? '',
        displayName: userData['displayName'] ?? userData['username'] ?? '',
        avatarUrl: userData['avatarUrl'],
        totalXP: userData['totalXP'] ?? 0,
        weeklyXP: 0, // Would need calculation from activity data
        monthlyXP: 0, // Would need calculation from activity data
        level: userData['level'] ?? 1,
        currentStreak: userData['currentStreak'] ?? 0,
        completedCourses: (userData['completedCourses'] as List?)?.length ?? 0,
        rank: rank++,
        lastActive: userData['lastActiveDate'] != null
            ? (userData['lastActiveDate'] as Timestamp).toDate()
            : DateTime.now(),
        lastUpdated: userData['lastActiveDate'] != null
            ? (userData['lastActiveDate'] as Timestamp).toDate()
            : DateTime.now(),
      ));
    }

    _entries = entries;

    // Update user rank if they're in the list
    if (userId != null) {
      _findUserRank(userId);
    }

    notifyListeners();
  }

  // Handle user's own data updates
  // Tracks user's rank even if not in top 100
  void _handleUserUpdate(DocumentSnapshot snapshot, String userId) async {
    if (!snapshot.exists) return;

    final userData = snapshot.data() as Map<String, dynamic>;

    // Update user's rank
    _userRank = await _databaseService.getUserGlobalRank(userId);

    // Update user's entry
    _userEntry = LeaderboardEntry(
      id: userId,
      userId: userId,
      username: userData['username'] ?? '',
      displayName: userData['displayName'] ?? userData['username'] ?? '',
      avatarUrl: userData['avatarUrl'],
      totalXP: userData['totalXP'] ?? 0,
      weeklyXP: 0,
      monthlyXP: 0,
      level: userData['level'] ?? 1,
      currentStreak: userData['currentStreak'] ?? 0,
      completedCourses: (userData['completedCourses'] as List?)?.length ?? 0,
      rank: _userRank ?? 0,
      lastActive: userData['lastActiveDate'] != null
          ? (userData['lastActiveDate'] as Timestamp).toDate()
          : DateTime.now(),
      lastUpdated: userData['lastActiveDate'] != null
          ? (userData['lastActiveDate'] as Timestamp).toDate()
          : DateTime.now(),
    );

    notifyListeners();
  }

  // Change filter
  // Switches between global and course-specific leaderboards
  void setFilter(LeaderboardFilter filter, {String? courseId}) {
    if (_currentFilter != filter ||
        (filter == LeaderboardFilter.byCourse &&
            courseId != _selectedCourseId)) {
      _currentFilter = filter;
      _selectedCourseId = courseId;
      _lastFetchTime = null; // Invalidate cache
      loadLeaderboard(userId: _currentUserId);
    }
  }

  // Find user's rank in current leaderboard
  void _findUserRank(String userId) {
    _userRank = null;
    _userEntry = null;

    for (int i = 0; i < _entries.length; i++) {
      if (_entries[i].userId == userId) {
        _userRank = i + 1;
        _userEntry = _entries[i];
        break;
      }
    }

    // If user not in top 100, fetch their actual rank
    if (_userRank == null) {
      _fetchUserRank(userId);
    }
  }

  // Fetch user's actual rank if not in top 100
  // Shows user their position even if not on visible leaderboard
  Future<void> _fetchUserRank(String userId) async {
    try {
      switch (_currentFilter) {
        case LeaderboardFilter.global:
          _userRank = await _databaseService.getUserGlobalRank(userId);
          break;
        case LeaderboardFilter.byCourse:
          if (_selectedCourseId != null) {
            _userRank = await _databaseService.getUserCourseRank(
              userId: userId,
              courseId: _selectedCourseId!,
            );
          }
          break;
      }

      if (_userRank != null) {
        _userEntry = await _databaseService.getLeaderboardEntry(userId);
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error('LeaderboardProvider._fetchUserRank', error: e);
    }
  }

  // Refresh leaderboard (force reload, ignore cache)
  Future<void> refresh({String? userId}) async {
    _lastFetchTime = null; // Invalidate cache
    await loadLeaderboard(userId: userId);
  }

  // Clear data and cancel subscriptions
  void clear() {
    _entries = [];
    _userRank = null;
    _userEntry = null;
    _error = null;
    _lastFetchTime = null;
    _cancelSubscriptions();
    notifyListeners();
  }

  // Cancel all active subscriptions
  Future<void> _cancelSubscriptions() async {
    await _leaderboardSubscription?.cancel();
    await _userSubscription?.cancel();
    _leaderboardSubscription = null;
    _userSubscription = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
