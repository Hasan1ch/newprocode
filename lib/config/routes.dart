// Navigation route definitions for the entire app
// Centralizes all screen paths for easy maintenance and refactoring
class Routes {
  // Authentication flow routes
  static const String splash = '/'; // App launch screen with logo
  static const String login = '/login'; // Sign in screen
  static const String register = '/register'; // New user registration
  static const String forgotPassword = '/forgot-password'; // Password recovery
  static const String resetPassword = '/reset-password'; // Set new password
  static const String verifyEmail = '/verify-email'; // Email confirmation

  // First-time user experience
  static const String onboarding = '/onboarding'; // Welcome tutorial
  static const String selectLanguage =
      '/select-language'; // Programming language choice
  static const String selectLevel = '/select-level'; // Skill level selection

  // Main app navigation - bottom nav bar screens
  static const String dashboard = '/dashboard'; // Home screen with stats
  static const String courses = '/courses'; // Course catalog
  static const String leaderboard = '/leaderboard'; // Competition rankings
  static const String profile = '/profile'; // User profile

  // Learning content navigation
  static const String courseDetail =
      '/course-detail'; // Course overview and modules
  static const String moduleDetail = '/module-detail'; // Module lessons list
  static const String lesson = '/lesson'; // Lesson content viewer
  static const String codeEditor =
      '/code-editor'; // Interactive coding environment
  static const String quiz = '/quiz'; // Quiz questions screen
  static const String quizResult = '/quiz-result'; // Quiz score display

  // Profile management screens
  static const String editProfile = '/edit-profile'; // Update user information
  static const String achievements = '/achievements'; // Trophy collection
  static const String learningStats = '/learning-stats'; // Progress analytics
  static const String certificates =
      '/certificates'; // Course completion certificates

  // AI-powered features
  static const String aiAdvisor = '/ai-advisor'; // AI learning assistant
  static const String aiChat = '/ai-chat'; // Chat with AI tutor
  static const String codeReview = '/code-review'; // AI code analysis

  // App settings and preferences
  static const String settings = '/settings'; // Main settings menu
  static const String notifications =
      '/notifications'; // Push notification preferences
  static const String privacy = '/privacy'; // Privacy controls
  static const String about = '/about'; // App information
  static const String help = '/help'; // Support and FAQ

  // Coding challenge features
  static const String codeChallenge =
      '/code-challenge'; // Individual challenge screen
  static const String challengeList =
      '/challenge-list'; // Browse all challenges
  static const String challengeResult =
      '/challenge-result'; // Challenge completion stats

  // Social learning features
  static const String community = '/community'; // Discussion forum home
  static const String discussionThread =
      '/discussion-thread'; // Individual discussion
  static const String createPost = '/create-post'; // New forum post

  // Search functionality
  static const String search = '/search'; // Search interface
  static const String searchResults =
      '/search-results'; // Search results listing

  // Error handling screens
  static const String error404 = '/404'; // Page not found
  static const String error500 = '/500'; // Server error
  static const String noInternet = '/no-internet'; // Offline state
}
