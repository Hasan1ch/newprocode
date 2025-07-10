import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/models/course_model.dart';
import 'package:procode/models/module_model.dart';
import 'package:procode/models/lesson_model.dart';
import 'package:procode/models/progress_model.dart';
import 'package:procode/config/firebase_config.dart';
import 'package:procode/services/auth_service.dart';
import 'package:procode/services/database_service.dart';

// Type aliases to match model names
typedef Course = CourseModel;
typedef Module = ModuleModel;
typedef Lesson = LessonModel;
typedef Progress = ProgressModel;

/// Central provider for course management and learning progress
/// Handles real-time synchronization of course enrollment and completion tracking
class CourseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  // Real-time subscription management
  StreamSubscription<QuerySnapshot>? _progressSubscription;
  StreamSubscription<QuerySnapshot>? _modulesSubscription;

  // Course data storage
  List<Course> _courses = [];
  List<Course> _enrolledCourses = [];
  Map<String, List<Module>> _courseModules = {}; // courseId -> modules
  Map<String, Progress> _userProgress = {}; // courseId -> progress
  Course? _selectedCourse;
  Module? _selectedModule;
  Lesson? _currentLesson;

  // State management
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters for UI binding
  List<Course> get courses => _courses;
  List<Course> get enrolledCourses => _enrolledCourses;
  Course? get selectedCourse => _selectedCourse;
  Module? get selectedModule => _selectedModule;
  Lesson? get currentLesson => _currentLesson;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Module> getModulesForCourse(String courseId) {
    return _courseModules[courseId] ?? [];
  }

  Progress? getProgressForCourse(String courseId) {
    return _userProgress[courseId];
  }

  // Initialize real-time listeners
  // Sets up live updates for progress and modules when user is authenticated
  Future<void> initializeRealTimeListeners() async {
    if (_isInitialized || _authService.currentUser == null) return;

    _isInitialized = true;
    await _loadEnrolledCoursesRealtime();
    _loadModulesRealtime();
  }

  // Load all courses
  // Fetches available courses and initializes real-time updates
  Future<void> loadCourses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Use the database service instead of direct Firestore
      _courses = await _databaseService.getAllCourses();

      // Initialize real-time listeners if user is logged in
      if (_authService.currentUser != null && !_isInitialized) {
        await initializeRealTimeListeners();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load courses: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load enrolled courses (keeping original for compatibility)
  Future<void> _loadEnrolledCourses() async {
    try {
      final userId = _authService.currentUser!.uid;

      // CRITICAL FIX: Clear existing user progress first
      _userProgress.clear();
      _enrolledCourses.clear();

      final progressSnapshot = await _firestore
          .collection(FirebaseConfig.progressCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final courseIds = progressSnapshot.docs
          .map((doc) => doc.data()['courseId'] as String)
          .toList();

      _enrolledCourses =
          _courses.where((course) => courseIds.contains(course.id)).toList();

      // Load progress for each enrolled course
      for (final doc in progressSnapshot.docs) {
        final progress = Progress.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
        // Only add progress if it belongs to the current user
        if (progress.userId == userId) {
          _userProgress[progress.courseId] = progress;
        }
      }
    } catch (e) {
      print('Error loading enrolled courses: $e');
    }
  }

  // NEW: Load enrolled courses with real-time updates
  // Listens to progress changes and automatically updates enrolled courses
  Future<void> _loadEnrolledCoursesRealtime() async {
    try {
      final userId = _authService.currentUser!.uid;

      // Cancel existing subscription
      _progressSubscription?.cancel();

      // CRITICAL FIX: Clear existing data before setting up listener
      _userProgress.clear();
      _enrolledCourses.clear();

      // Set up real-time listener for progress collection
      _progressSubscription = _firestore
          .collection(FirebaseConfig.progressCollection)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) async {
        // Clear existing data to ensure fresh state
        _userProgress.clear();
        _enrolledCourses.clear();

        // Get course IDs from progress documents
        final courseIds = snapshot.docs
            .map((doc) => doc.data()['courseId'] as String)
            .toSet()
            .toList();

        // If courses haven't been loaded yet, load them first
        if (_courses.isEmpty) {
          _courses = await _databaseService.getAllCourses();
        }

        // Update enrolled courses
        _enrolledCourses =
            _courses.where((course) => courseIds.contains(course.id)).toList();

        // Update progress for each enrolled course
        for (final doc in snapshot.docs) {
          final progressData = doc.data();

          // CRITICAL: Verify this progress belongs to the current user
          if (progressData['userId'] == userId) {
            final progress = Progress.fromJson({
              'id': doc.id,
              ...progressData,
            });
            _userProgress[progress.courseId] = progress;

            // Load modules for this course if not already loaded
            if (!_courseModules.containsKey(progress.courseId)) {
              await loadModulesForCourse(progress.courseId);
            }
          }
        }

        notifyListeners();
        print(
            'Real-time progress update: ${_enrolledCourses.length} courses enrolled for user $userId');
      }, onError: (error) {
        print('Error in progress real-time listener: $error');
        // Fallback to regular loading
        _loadEnrolledCourses();
      });
    } catch (e) {
      print('Error loading enrolled courses with real-time: $e');
      // Fallback to regular loading
      await _loadEnrolledCourses();
    }
  }

  // Load modules with real-time updates
  // Automatically syncs module changes across all users
  void _loadModulesRealtime() {
    if (_authService.currentUser == null) return;

    _modulesSubscription?.cancel();

    // Listen to all modules (we'll filter by course as needed)
    _modulesSubscription =
        _firestore.collection('modules').snapshots().listen((snapshot) {
      // Group modules by course
      final modulesByCourse = <String, List<Module>>{};

      for (final doc in snapshot.docs) {
        final module = Module.fromJson({
          'id': doc.id,
          ...doc.data(),
        });

        if (!modulesByCourse.containsKey(module.courseId)) {
          modulesByCourse[module.courseId] = [];
        }
        modulesByCourse[module.courseId]!.add(module);
      }

      // Sort modules by orderIndex
      modulesByCourse.forEach((courseId, modules) {
        modules.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        _courseModules[courseId] = modules;
      });

      notifyListeners();
    }, onError: (error) {
      print('Error in modules real-time listener: $error');
    });
  }

  // Load modules for a course
  Future<void> loadModulesForCourse(String courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Use database service
      _courseModules[courseId] =
          await _databaseService.getCourseModules(courseId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load modules: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load lessons for a module
  Future<List<Lesson>> loadLessonsForModule(
      String courseId, String moduleId) async {
    try {
      // Use database service
      return await _databaseService.getModuleLessons(moduleId);
    } catch (e) {
      print('Error loading lessons: $e');
      return [];
    }
  }

  // Enroll in a course
  // Creates initial progress record and adds to enrolled courses
  Future<void> enrollInCourse(String courseId) async {
    try {
      final userId = _authService.currentUser!.uid;

      // Check if already enrolled
      final existingProgress = await _firestore
          .collection(FirebaseConfig.progressCollection)
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .get();

      if (existingProgress.docs.isNotEmpty) {
        _error = 'Already enrolled in this course';
        notifyListeners();
        return;
      }

      // Create initial progress record
      final progress = Progress(
        id: '',
        userId: userId,
        courseId: courseId,
        completedLessons: [],
        completedModules: [],
        currentModuleId: '',
        currentLessonId: '',
        lastAccessedLesson: '',
        lastAccessedAt: DateTime.now(),
        enrolledAt: DateTime.now(),
        totalXpEarned: 0,
        quizScores: {},
        completionPercentage: 0.0,
      );

      final docRef = await _firestore
          .collection(FirebaseConfig.progressCollection)
          .add(progress.toJson());

      progress.id = docRef.id;
      _userProgress[courseId] = progress;

      // Add to enrolled courses
      final course = _courses.firstWhere((c) => c.id == courseId);
      if (!_enrolledCourses.contains(course)) {
        _enrolledCourses.add(course);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to enroll in course: $e';
      notifyListeners();
    }
  }

  // FIXED: Mark lesson as completed with proper XP handling
  // Awards XP only on first completion and tracks module/course completion
  Future<void> completeLesson(
      String courseId, String moduleId, String lessonId) async {
    try {
      final userId = _authService.currentUser!.uid;
      final progress = _userProgress[courseId];

      if (progress == null || progress.userId != userId) return;

      // Check if lesson was already completed
      final wasAlreadyCompleted = progress.completedLessons.contains(lessonId);

      // Update completed lessons
      final updatedLessons = [...progress.completedLessons];
      if (!updatedLessons.contains(lessonId)) {
        updatedLessons.add(lessonId);
      }

      // Check if module is completed
      final module =
          _courseModules[courseId]?.firstWhere((m) => m.id == moduleId);
      final updatedModules = [...progress.completedModules];

      if (module != null) {
        final allLessonsCompleted =
            module.lessonIds.every((id) => updatedLessons.contains(id));
        if (allLessonsCompleted && !updatedModules.contains(moduleId)) {
          updatedModules.add(moduleId);
        }
      }

      // Calculate total lessons for completion percentage
      int totalLessonsInCourse = 0;
      final courseMods = _courseModules[courseId] ?? [];
      for (final mod in courseMods) {
        totalLessonsInCourse += mod.lessonIds.length;
      }

      // Calculate completion percentage
      final completionPercentage = totalLessonsInCourse > 0
          ? (updatedLessons.length / totalLessonsInCourse) * 100
          : 0.0;

      // Only award XP if this is the first time completing the lesson
      final xpToAward = wasAlreadyCompleted ? 0 : FirebaseConfig.xpPerLesson;

      // Update progress in Firestore
      final updatedProgress = progress.copyWith(
        completedLessons: updatedLessons,
        completedModules: updatedModules,
        totalXpEarned: progress.totalXpEarned + xpToAward,
        lastAccessedAt: DateTime.now(),
        lastAccessedLesson: lessonId,
        completionPercentage: completionPercentage,
      );

      await _firestore
          .collection(FirebaseConfig.progressCollection)
          .doc(progress.id)
          .update(updatedProgress.toJson());

      _userProgress[courseId] = updatedProgress;

      // Award XP using the database service if not already completed
      if (xpToAward > 0) {
        await _databaseService.markLessonCompleted(userId, lessonId, xpToAward);
      }

      // Check if course is completed
      if (completionPercentage >= 100 && !wasAlreadyCompleted) {
        await _checkAndCompleteCourse(courseId, userId);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to complete lesson: $e';
      notifyListeners();
      print('Error in completeLesson: $e');
    }
  }

  // Check and complete course with bonus XP
  // Awards bonus XP and updates user stats when course is fully completed
  Future<void> _checkAndCompleteCourse(String courseId, String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final completedCourses = List<String>.from(
        userDoc.data()!['completedCourses'] ?? [],
      );

      if (!completedCourses.contains(courseId)) {
        // Update user's completed courses
        await _firestore.collection('users').doc(userId).update({
          'completedCourses': FieldValue.arrayUnion([courseId]),
        });

        // Award bonus XP for course completion
        await _databaseService.addXP(userId, 50); // Bonus XP

        // Update course completed count in user_stats
        await _firestore.collection('user_stats').doc(userId).update({
          'coursesCompleted': FieldValue.increment(1),
        });

        print('Course $courseId completed by user $userId with bonus XP');
      }
    } catch (e) {
      print('Error checking course completion: $e');
    }
  }

  // Get next lesson
  // Finds the next uncompleted lesson in the course
  Lesson? getNextLesson(String courseId) {
    final progress = _userProgress[courseId];
    if (progress == null) return null;

    final modules = _courseModules[courseId] ?? [];

    for (final module in modules) {
      for (final lessonId in module.lessonIds) {
        if (!progress.completedLessons.contains(lessonId)) {
          // This would require loading the lesson, simplified for now
          return null;
        }
      }
    }

    return null;
  }

  // Calculate course completion percentage
  double getCourseCompletionPercentage(String courseId) {
    final progress = _userProgress[courseId];
    if (progress == null) return 0.0;

    final modules = _courseModules[courseId] ?? [];
    if (modules.isEmpty) return 0.0;

    final totalLessons =
        modules.fold<int>(0, (sum, module) => sum + module.lessonIds.length);
    if (totalLessons == 0) return 0.0;

    return (progress.completedLessons.length / totalLessons) * 100;
  }

  // Set selected course
  void setSelectedCourse(Course? course) {
    _selectedCourse = course;
    notifyListeners();
  }

  // Set selected module
  void setSelectedModule(Module? module) {
    _selectedModule = module;
    notifyListeners();
  }

  // Set current lesson
  void setCurrentLesson(Lesson? lesson) {
    _currentLesson = lesson;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get courses by language filter
  Future<List<Course>> getCoursesByLanguage(String language) async {
    try {
      if (language == 'all') {
        return _courses;
      }
      return await _databaseService.getCoursesByLanguage(language);
    } catch (e) {
      print('Error getting courses by language: $e');
      return [];
    }
  }

  // Get featured courses
  Future<List<Course>> getFeaturedCourses() async {
    try {
      return await _databaseService.getFeaturedCourses();
    } catch (e) {
      print('Error getting featured courses: $e');
      return [];
    }
  }

  // Search courses
  // Filters courses by title, description, or tags
  List<Course> searchCourses(String query) {
    if (query.isEmpty) {
      return _courses;
    }

    final lowercaseQuery = query.toLowerCase();
    return _courses.where((course) {
      return course.title.toLowerCase().contains(lowercaseQuery) ||
          course.description.toLowerCase().contains(lowercaseQuery) ||
          course.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Get course by ID
  Future<Course?> getCourseById(String courseId) async {
    try {
      return await _databaseService.getCourseById(courseId);
    } catch (e) {
      print('Error getting course by id: $e');
      return null;
    }
  }

  // Force refresh all data
  // Cancels subscriptions and reloads fresh data
  Future<void> refresh() async {
    // Cancel existing subscriptions first
    await _cancelSubscriptions();

    // Clear all data
    _isInitialized = false;
    _userProgress.clear();
    _enrolledCourses.clear();
    _courseModules.clear();

    // Reload if user is authenticated
    if (_authService.currentUser != null) {
      await loadCourses();
    }
  }

  // Clear data when user logs out
  void clearUserData() {
    _cancelSubscriptions();
    _userProgress.clear();
    _enrolledCourses.clear();
    _isInitialized = false;
    notifyListeners();
  }

  // Cancel all subscriptions
  Future<void> _cancelSubscriptions() async {
    await _progressSubscription?.cancel();
    await _modulesSubscription?.cancel();
    _progressSubscription = null;
    _modulesSubscription = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _courses.clear();
    _enrolledCourses.clear();
    _courseModules.clear();
    _userProgress.clear();
    _isInitialized = false;
    super.dispose();
  }
}
