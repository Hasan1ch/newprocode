import 'package:flutter/material.dart';
import 'package:procode/models/leaderboard_entry_model.dart';
import 'package:procode/services/database_service.dart';
import 'package:procode/utils/app_logger.dart';

enum LeaderboardFilter { global, weekly, monthly, byCourse }

class LeaderboardProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<LeaderboardEntry> _entries = [];
  LeaderboardFilter _currentFilter = LeaderboardFilter.global;
  String? _selectedCourseId;
  bool _isLoading = false;
  String? _error;
  int? _userRank;
  LeaderboardEntry? _userEntry;

  List<LeaderboardEntry> get entries => _entries;
  LeaderboardFilter get currentFilter => _currentFilter;
  String? get selectedCourseId => _selectedCourseId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get userRank => _userRank;
  LeaderboardEntry? get userEntry => _userEntry;

  // Load leaderboard data
  Future<void> loadLeaderboard({String? userId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      switch (_currentFilter) {
        case LeaderboardFilter.global:
          _entries = await _databaseService.getGlobalLeaderboard(limit: 100);
          break;
        case LeaderboardFilter.weekly:
          _entries = await _databaseService.getWeeklyLeaderboard(limit: 100);
          break;
        case LeaderboardFilter.monthly:
          _entries = await _databaseService.getMonthlyLeaderboard(limit: 100);
          break;
        case LeaderboardFilter.byCourse:
          if (_selectedCourseId != null) {
            _entries = await _databaseService.getCourseLeaderboard(
              courseId: _selectedCourseId!,
              limit: 100,
            );
          }
          break;
      }

      // Find user's rank if userId provided
      if (userId != null) {
        _findUserRank(userId);
      }
    } catch (e) {
      _error = 'Failed to load leaderboard';
      AppLogger.error('LeaderboardProvider.loadLeaderboard', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change filter
  void setFilter(LeaderboardFilter filter, {String? courseId}) {
    if (_currentFilter != filter ||
        (filter == LeaderboardFilter.byCourse &&
            courseId != _selectedCourseId)) {
      _currentFilter = filter;
      _selectedCourseId = courseId;
      loadLeaderboard();
    }
  }

  // Find user's rank in current leaderboard
  void _findUserRank(String userId) {
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
  Future<void> _fetchUserRank(String userId) async {
    try {
      switch (_currentFilter) {
        case LeaderboardFilter.global:
          _userRank = await _databaseService.getUserGlobalRank(userId);
          break;
        case LeaderboardFilter.weekly:
          _userRank = await _databaseService.getUserWeeklyRank(userId);
          break;
        case LeaderboardFilter.monthly:
          _userRank = await _databaseService.getUserMonthlyRank(userId);
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

  // Refresh leaderboard
  Future<void> refresh({String? userId}) async {
    await loadLeaderboard(userId: userId);
  }

  // Clear data
  void clear() {
    _entries = [];
    _userRank = null;
    _userEntry = null;
    _error = null;
    notifyListeners();
  }
}
