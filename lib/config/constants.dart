import 'package:procode/models/achievement_model.dart';

class AppConstants {
  // App Info
  static const String appName = 'ProCode';
  static const String appVersion = '1.0.0';

  // API Keys - In production, these should be stored securely
  // For development, you can temporarily hardcode them here
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY_HERE',
  );
  static const String judge0ApiKey = String.fromEnvironment(
    'JUDGE0_API_KEY',
    defaultValue: '6a7488d9e2msh2d046a8ad2a723bp16d39ajsn7ed3c95e55b4',
  );

  // URLs
  static const String termsUrl = 'https://procode.app/terms';
  static const String privacyUrl = 'https://procode.app/privacy';
  static const String supportUrl = 'https://procode.app/support';

  // Learning Goals
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

  // Programming Languages
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

  // Difficulty Levels
  static const List<String> difficultyLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  // Course Categories
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

  // XP Rewards
  static const int lessonCompletionXP = 10;
  static const int quizCompletionXP = 20;
  static const int perfectQuizXP = 50;
  static const int challengeCompletionXP = 30;
  static const int dailyStreakXP = 5;
  static const int weeklyStreakXP = 25;
  static const int monthlyStreakXP = 100;

  // Level Requirements
  static const Map<int, int> levelRequirements = {
    1: 0, // Beginner
    2: 100, // Novice
    3: 300, // Apprentice
    4: 600, // Developer
    5: 1000, // Expert
    6: 1500, // Master
    7: 2500, // Guru
  };

  // Level Names
  static const Map<int, String> levelNames = {
    1: 'Beginner',
    2: 'Novice',
    3: 'Apprentice',
    4: 'Developer',
    5: 'Expert',
    6: 'Master',
    7: 'Guru',
  };

  // Default Avatars
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

  // Code Editor Themes
  static const Map<String, String> codeEditorThemes = {
    'light': 'Light',
    'dark': 'Dark',
    'monokai': 'Monokai',
    'dracula': 'Dracula',
  };

  // Supported Languages for Code Editor
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

// Achievement definitions - Outside the AppConstants class
final List<Achievement> achievements = [
  Achievement(
    id: 'first_steps',
    name: 'First Steps',
    description: 'Complete your first lesson',
    iconAsset: 'assets/images/achievements/first_steps.png',
    xpReward: 50,
    category: 'learning',
    rarity: 'common',
  ),
  Achievement(
    id: 'quiz_master',
    name: 'Quiz Master',
    description: 'Score 90% or higher on any quiz',
    iconAsset: 'assets/images/achievements/quiz_master.png',
    xpReward: 100,
    category: 'mastery',
    rarity: 'rare',
  ),
  Achievement(
    id: 'streak_starter',
    name: 'Streak Starter',
    description: 'Maintain a 7-day learning streak',
    iconAsset: 'assets/images/achievements/streak_starter.png',
    xpReward: 75,
    category: 'dedication',
    rarity: 'common',
  ),
  Achievement(
    id: 'level_5',
    name: 'Rising Star',
    description: 'Reach level 5',
    iconAsset: 'assets/images/achievements/level_5.png',
    xpReward: 150,
    category: 'learning',
    rarity: 'rare',
  ),
  Achievement(
    id: 'course_complete',
    name: 'Course Complete',
    description: 'Complete your first course',
    iconAsset: 'assets/images/achievements/course_complete.png',
    xpReward: 200,
    category: 'learning',
    rarity: 'rare',
  ),
  Achievement(
    id: 'dedicated_learner',
    name: 'Dedicated Learner',
    description: 'Maintain a 30-day learning streak',
    iconAsset: 'assets/images/achievements/dedicated_learner.png',
    xpReward: 300,
    category: 'dedication',
    rarity: 'epic',
  ),
  Achievement(
    id: 'code_warrior',
    name: 'Code Warrior',
    description: 'Complete 50 coding challenges',
    iconAsset: 'assets/images/achievements/code_warrior.png',
    xpReward: 250,
    category: 'mastery',
    rarity: 'epic',
  ),
  Achievement(
    id: 'knowledge_seeker',
    name: 'Knowledge Seeker',
    description: 'Complete 5 different courses',
    iconAsset: 'assets/images/achievements/knowledge_seeker.png',
    xpReward: 500,
    category: 'learning',
    rarity: 'legendary',
  ),
];

// Other achievement-related constants
class AchievementConstants {
  static const Map<String, String> categoryIcons = {
    'learning': '📚',
    'social': '👥',
    'dedication': '🔥',
    'mastery': '⭐',
  };

  static const Map<String, String> rarityEmojis = {
    'common': '⚪',
    'rare': '🔵',
    'epic': '🟣',
    'legendary': '🟡',
  };
}
