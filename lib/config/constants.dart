import 'package:procode/models/achievement_model.dart';
import 'package:procode/config/env_config.dart';

// Main configuration file that stores all the app's constants and settings
class AppConstants {
  // Basic app information for branding and versioning
  static const String appName = 'ProCode';
  static const String appVersion = '1.0.0';

  // API Keys are now fetched from EnvConfig
  // NEVER hardcode API keys in your source code
  static String get geminiApiKey => EnvConfig.geminiApiKey;
  static String get judge0ApiKey => EnvConfig.judge0ApiKey;
  static String get judge0BaseUrl => EnvConfig.judge0BaseUrl;

  // External links for legal and support pages
  static const String termsUrl = 'https://procode.app/terms';
  static const String privacyUrl = 'https://procode.app/privacy';
  static const String supportUrl = 'https://procode.app/support';

  // Available learning paths users can choose from during onboarding
  // This helps personalize their learning experience
  static const List<String> learningGoals = [
    'Web Development',
    'Mobile App Development',
    'Data Science & AI',
    'Game Development',
    'Backend Development',
    'Full Stack Development',
    'DevOps & Cloud',
    'Cybersecurity',
    'General Programming',
  ];

  // Supported programming languages in the app
  // Users can select these as their preferred languages
  static const List<String> programmingLanguages = [
    'Python',
    'JavaScript',
    'Java',
    'C++',
    'HTML/CSS',
    'TypeScript',
    'Swift',
    'Kotlin',
    'Go',
    'Rust',
  ];

  // Course difficulty options for filtering and categorization
  static const List<String> difficultyLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  // Main course categories to organize learning content
  static const List<String> courseCategories = [
    'Programming Fundamentals',
    'Web Development',
    'Mobile Development',
    'Data Science',
    'Machine Learning',
    'Game Development',
    'Databases',
    'Algorithms',
    'System Design',
  ];

  // Experience points awarded for different activities
  // This drives the gamification system
  static const int lessonCompletionXP = 10; // Basic lesson completion
  static const int quizCompletionXP = 20; // Any quiz completion
  static const int perfectQuizXP = 50; // 100% score on quiz
  static const int challengeCompletionXP = 30; // Code challenge solved
  static const int dailyStreakXP = 5; // Daily login bonus
  static const int weeklyStreakXP = 25; // 7-day streak bonus
  static const int monthlyStreakXP = 100; // 30-day streak bonus

  // XP required to reach each level
  // Players progress through these levels as they learn
  static const Map<int, int> levelRequirements = {
    1: 0, // Starting point
    2: 100, // First milestone
    3: 300, // Getting serious
    4: 600, // Intermediate level
    5: 1000, // Advanced learner
    6: 1500, // Expert territory
    7: 2500, // Master level
  };

  // Display names for each level to show user progression
  static const Map<int, String> levelNames = {
    1: 'Beginner',
    2: 'Novice',
    3: 'Apprentice',
    4: 'Developer',
    5: 'Expert',
    6: 'Master',
    7: 'Guru',
  };

  // Pre-designed avatar options for user profiles
  // Users can choose from these during registration or profile edit
  static const List<String> defaultAvatars = [
    'avatar_1.png',
    'avatar_2.png',
    'avatar_3.png',
    'avatar_4.png',
    'avatar_5.png',
    'avatar_6.png',
    'avatar_7.png',
    'avatar_8.png',
    'avatar_9.png',
    'avatar_10.png',
    'avatar_11.png',
    'avatar_12.png',
  ];

  // Available themes for the code editor
  // Users can switch between these for comfortable coding
  static const Map<String, String> codeEditorThemes = {
    'light': 'Light',
    'dark': 'Dark',
    'monokai': 'Monokai',
    'dracula': 'Dracula',
  };

  // Language IDs for Judge0 API
  // These map our language names to Judge0's internal IDs
  static const Map<String, int> languageIds = {
    'python': 71,
    'javascript': 63,
    'java': 62,
    'cpp': 54,
    'c': 50,
    'html': 20,
    'css': 19,
  };
}

// All achievements available in the app
// Players unlock these by completing various tasks
final List<Achievement> achievements = [
  Achievement(
    id: 'first_steps',
    name: 'First Steps',
    description: 'Complete your first lesson',
    iconAsset: 'assets/images/achievements/first_steps.png',
    xpReward: 50,
    category: 'learning',
    rarity: 'common', // Easy to get, encourages new users
  ),
  Achievement(
    id: 'quiz_master',
    name: 'Quiz Master',
    description: 'Score 90% or higher on any quiz',
    iconAsset: 'assets/images/achievements/quiz_master.png',
    xpReward: 100,
    category: 'mastery',
    rarity: 'rare', // Requires skill and knowledge
  ),
  Achievement(
    id: 'streak_starter',
    name: 'Streak Starter',
    description: 'Maintain a 7-day learning streak',
    iconAsset: 'assets/images/achievements/streak_starter.png',
    xpReward: 75,
    category: 'dedication',
    rarity: 'common', // Encourages consistent learning
  ),
  Achievement(
    id: 'level_5',
    name: 'Rising Star',
    description: 'Reach level 5',
    iconAsset: 'assets/images/achievements/level_5.png',
    xpReward: 150,
    category: 'learning',
    rarity: 'rare', // Shows significant progress
  ),
  Achievement(
    id: 'course_complete',
    name: 'Course Complete',
    description: 'Complete your first course',
    iconAsset: 'assets/images/achievements/course_complete.png',
    xpReward: 200,
    category: 'learning',
    rarity: 'rare', // Major milestone
  ),
  Achievement(
    id: 'dedicated_learner',
    name: 'Dedicated Learner',
    description: 'Maintain a 30-day learning streak',
    iconAsset: 'assets/images/achievements/dedicated_learner.png',
    xpReward: 300,
    category: 'dedication',
    rarity: 'epic', // Shows real commitment
  ),
  Achievement(
    id: 'code_warrior',
    name: 'Code Warrior',
    description: 'Complete 50 coding challenges',
    iconAsset: 'assets/images/achievements/code_warrior.png',
    xpReward: 250,
    category: 'mastery',
    rarity: 'epic', // Proves coding skills
  ),
  Achievement(
    id: 'knowledge_seeker',
    name: 'Knowledge Seeker',
    description: 'Complete 5 different courses',
    iconAsset: 'assets/images/achievements/knowledge_seeker.png',
    xpReward: 500,
    category: 'learning',
    rarity: 'legendary', // Top tier achievement
  ),
];

// Visual indicators for achievements
class AchievementConstants {
  // Emoji icons to represent achievement categories
  static const Map<String, String> categoryIcons = {
    'learning': '📚', // Knowledge acquisition
    'social': '👥', // Community interaction
    'dedication': '🔥', // Consistency and streaks
    'mastery': '⭐', // Skill demonstration
  };

  // Color-coded emojis to show achievement rarity
  // Higher rarity means harder to obtain
  static const Map<String, String> rarityEmojis = {
    'common': '⚪', // Basic achievements
    'rare': '🔵', // Moderate difficulty
    'epic': '🟣', // Challenging
    'legendary': '🟡', // Elite status
  };
}
