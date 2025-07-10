import 'package:flutter/material.dart';

/// Simple provider for managing bottom navigation state
/// Controls which tab is currently active in the main navigation
class NavigationProvider extends ChangeNotifier {
  // Current selected tab index
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  // Update the current tab index
  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Reset to home tab
  // Used when navigating from deep links or after certain actions
  void resetToHome() {
    _currentIndex = 0;
    notifyListeners();
  }

  // Navigate to specific tabs
  // Provides named methods for clearer navigation intent
  void navigateToHome() => setIndex(0);
  void navigateToCourses() => setIndex(1);
  void navigateToAIAdvisor() => setIndex(2);
  void navigateToPractice() => setIndex(3);
  void navigateToQuiz() => setIndex(4);
  void navigateToProfile() => setIndex(5);
}
