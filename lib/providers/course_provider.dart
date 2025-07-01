import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/models/course_model.dart';
import 'package:procode/models/module_model.dart';
import 'package:procode/models/lesson_model.dart';
import 'package:procode/models/progress_model.dart';
import 'package:procode/config/firebase_config.dart';
import 'package:procode/services/auth_service.dart';

// Type aliases to match model names
typedef Course = CourseModel;
typedef Module = ModuleModel;
typedef Lesson = LessonModel;
typedef Progress = ProgressModel;

class CourseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  List<Course> _courses = [];
  List<Course> _enrolledCourses = [];
  Map<String, List<Module>> _courseModules = {};
  Map<String, Progress> _userProgress = {};
  Course? _selectedCourse;
  Module? _selectedModule;
  Lesson? _currentLesson;
  bool _isLoading = false;
  String? _error;

  // Getters
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

  // Load all courses
  Future<void> loadCourses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection(FirebaseConfig.coursesCollection)
          .orderBy('orderIndex') // Changed from 'order' to match your model
          .get();

      _courses = snapshot.docs
          .map((doc) => Course.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      // Load user's enrolled courses
      if (_authService.currentUser != null) {
        await _loadEnrolledCourses();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load courses: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load enrolled courses
  Future<void> _loadEnrolledCourses() async {
    try {
      final userId = _authService.currentUser!.uid;
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
        _userProgress[progress.courseId] = progress;
      }
    } catch (e) {
      print('Error loading enrolled courses: $e');
    }
  }

  // Load modules for a course
  Future<void> loadModulesForCourse(String courseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection(FirebaseConfig.coursesCollection)
          .doc(courseId)
          .collection(FirebaseConfig.modulesCollection)
          .orderBy('orderIndex') // Changed from 'order' to match your model
          .get();

      _courseModules[courseId] = snapshot.docs
          .map((doc) => Module.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

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
      final snapshot = await _firestore
          .collection(FirebaseConfig.coursesCollection)
          .doc(courseId)
          .collection(FirebaseConfig.modulesCollection)
          .doc(moduleId)
          .collection(FirebaseConfig.lessonsCollection)
          .orderBy('orderIndex') // Changed from 'order' to match your model
          .get();

      return snapshot.docs
          .map((doc) => Lesson.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      print('Error loading lessons: $e');
      return [];
    }
  }

  // Enroll in a course
  Future<void> enrollInCourse(String courseId) async {
    try {
      final userId = _authService.currentUser!.uid;

      final progress = Progress(
        id: '',
        userId: userId,
        courseId: courseId,
        completedLessons: [],
        completedModules: [],
        currentModuleId: '',
        currentLessonId: '',
        lastAccessedLesson: '', // Added this
        lastAccessedAt: DateTime.now(),
        enrolledAt: DateTime.now(),
        totalXpEarned: 0,
        quizScores: {},
        completionPercentage: 0.0, // Added this
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

  // Mark lesson as completed
  Future<void> completeLesson(
      String courseId, String moduleId, String lessonId) async {
    try {
      final userId = _authService.currentUser!.uid;
      final progress = _userProgress[courseId];

      if (progress == null) return;

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

      // Update progress
      final updatedProgress = progress.copyWith(
        completedLessons: updatedLessons,
        completedModules: updatedModules,
        totalXpEarned: progress.totalXpEarned + FirebaseConfig.xpPerLesson,
        lastAccessedAt: DateTime.now(),
        lastAccessedLesson: lessonId,
        completionPercentage: totalLessonsInCourse > 0
            ? (updatedLessons.length / totalLessonsInCourse) * 100
            : 0.0,
      );

      await _firestore
          .collection(FirebaseConfig.progressCollection)
          .doc(progress.id)
          .update(updatedProgress.toJson());

      _userProgress[courseId] = updatedProgress;

      // Update user stats
      await _updateUserStats(FirebaseConfig.xpPerLesson);

      notifyListeners();
    } catch (e) {
      _error = 'Failed to complete lesson: $e';
      notifyListeners();
    }
  }

  // Update user stats
  Future<void> _updateUserStats(int xpGained) async {
    try {
      final userId = _authService.currentUser!.uid;
      await _firestore
          .collection(FirebaseConfig.userStatsCollection)
          .doc(userId)
          .update({
        'totalXP': FieldValue.increment(xpGained),
        'lastActiveDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  // Get next lesson
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

  @override
  void dispose() {
    _courses.clear();
    _enrolledCourses.clear();
    _courseModules.clear();
    _userProgress.clear();
    super.dispose();
  }
}
