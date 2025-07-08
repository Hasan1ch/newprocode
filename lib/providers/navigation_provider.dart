import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Reset to home tab
  void resetToHome() {
    _currentIndex = 0;
    notifyListeners();
  }

  // Navigate to specific tabs
  void navigateToHome() => setIndex(0);
  void navigateToCourses() => setIndex(1);
  void navigateToAIAdvisor() => setIndex(2);
  void navigateToPractice() => setIndex(3);
  void navigateToQuiz() => setIndex(4);
  void navigateToProfile() => setIndex(5);
}
