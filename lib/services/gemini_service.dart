import 'package:procode/models/question_model.dart';
import 'package:procode/models/quiz_result_model.dart';
import 'package:procode/utils/app_logger.dart';

class GeminiService {
  // Initialize with your API key from constants
  static const String _apiKey = 'AIzaSyBU11tY-o3SpExV5lXbS71Rs2LKhvcazr4';

  // Add this method for AI Advisor Screen
  Future<String> getAIAdvice({
    required String message,
    required String userId,
    required String context,
  }) async {
    try {
      // TODO: Implement actual Gemini API call
      // For now, return a contextual response based on the message
      await Future.delayed(const Duration(seconds: 1));

      if (message.toLowerCase().contains('learning path')) {
        return "I'd be happy to help you create a personalized learning path! "
            "Based on your profile, I recommend starting with fundamental programming concepts "
            "and gradually moving to more advanced topics. Would you like me to create a detailed "
            "learning path based on your current skill level and goals?";
      } else if (message.toLowerCase().contains('career')) {
        return "There are many exciting career paths in programming! Some popular options include:\n\n"
            "• Frontend Developer - Building user interfaces\n"
            "• Backend Developer - Server-side programming\n"
            "• Full Stack Developer - Both frontend and backend\n"
            "• Mobile Developer - iOS/Android apps\n"
            "• Data Scientist - Analyzing and interpreting data\n"
            "• DevOps Engineer - Infrastructure and deployment\n\n"
            "What area interests you the most?";
      } else if (message.toLowerCase().contains('study tips')) {
        return "Here are some effective study tips for learning programming:\n\n"
            "1. **Practice Daily** - Even 30 minutes a day makes a difference\n"
            "2. **Build Projects** - Apply what you learn immediately\n"
            "3. **Read Others' Code** - Learn from open source projects\n"
            "4. **Join Communities** - Connect with other learners\n"
            "5. **Take Breaks** - Avoid burnout with regular breaks\n"
            "6. **Document Your Learning** - Keep notes and create tutorials\n\n"
            "Which aspect would you like to focus on first?";
      } else if (message.toLowerCase().contains('project ideas')) {
        return "Here are some beginner-friendly project ideas:\n\n"
            "**Web Development:**\n"
            "• Personal portfolio website\n"
            "• Todo list application\n"
            "• Weather app using API\n\n"
            "**Games:**\n"
            "• Tic-tac-toe\n"
            "• Memory card game\n"
            "• Simple quiz game\n\n"
            "**Utilities:**\n"
            "• Calculator\n"
            "• Unit converter\n"
            "• Expense tracker\n\n"
            "Which type of project appeals to you?";
      } else {
        return "I understand you're asking about: $message\n\n"
            "Based on your learning profile, I can help you with:\n"
            "• Creating personalized learning paths\n"
            "• Explaining programming concepts\n"
            "• Suggesting practice exercises\n"
            "• Providing career guidance\n"
            "• Recommending resources\n\n"
            "What specific aspect would you like to explore?";
      }
    } catch (e) {
      AppLogger.error('Error getting AI advice', error: e);
      return 'I apologize, but I encountered an error. Please try again.';
    }
  }

  // Add this method for AI Assistant Panel
  Future<String> getAIResponse({
    required String code,
    required String question,
    required String language,
  }) async {
    try {
      // TODO: Implement actual Gemini API call
      await Future.delayed(const Duration(seconds: 1));

      return "I can help you with your $language code. Based on your question about '$question', "
          "here are some suggestions:\n\n"
          "1. Make sure your syntax is correct\n"
          "2. Check for any logic errors\n"
          "3. Consider edge cases\n\n"
          "Would you like me to explain a specific part of the code?";
    } catch (e) {
      AppLogger.error('Error getting AI response', error: e);
      return 'Unable to generate response at this time.';
    }
  }

  // Add this method for Learning Path Screen
  Future<LearningPath> generateLearningPath({
    required String userId,
    required String skillLevel,
    required String learningGoal,
    required List<dynamic> availableCourses,
    required List<String> completedCourses,
    required int weeklyHours,
  }) async {
    try {
      // TODO: Implement actual Gemini API call
      await Future.delayed(const Duration(seconds: 2));

      // Generate different paths based on skill level and goal
      List<LearningPhase> phases = [];

      if (skillLevel == 'beginner') {
        phases = [
          LearningPhase(
            name: 'Foundation Phase',
            description: 'Build strong fundamentals in programming concepts',
            weeks: 8,
            courses: [
              {
                'title': 'Introduction to Programming',
                'duration': '4 weeks',
                'icon': '💻',
              },
              {
                'title': 'Basic Data Structures',
                'duration': '4 weeks',
                'icon': '📊',
              },
            ],
            milestones: [
              'Write your first program',
              'Understand variables and data types',
              'Master control flow (if/else, loops)',
              'Create simple functions',
            ],
          ),
          LearningPhase(
            name: 'Development Phase',
            description: 'Learn practical development skills',
            weeks: 8,
            courses: [
              {
                'title': 'Web Development Basics',
                'duration': '4 weeks',
                'icon': '🌐',
              },
              {
                'title': 'Introduction to Databases',
                'duration': '4 weeks',
                'icon': '🗄️',
              },
            ],
            milestones: [
              'Build your first website',
              'Connect to a database',
              'Create a simple CRUD application',
            ],
          ),
        ];
      } else if (skillLevel == 'intermediate') {
        phases = [
          LearningPhase(
            name: 'Advanced Concepts',
            description: 'Deepen your programming knowledge',
            weeks: 6,
            courses: [
              {
                'title': 'Advanced Programming Patterns',
                'duration': '3 weeks',
                'icon': '🎯',
              },
              {
                'title': 'Algorithms & Data Structures',
                'duration': '3 weeks',
                'icon': '🧮',
              },
            ],
            milestones: [
              'Implement complex algorithms',
              'Optimize code performance',
              'Master design patterns',
            ],
          ),
          LearningPhase(
            name: 'Specialization Phase',
            description: 'Focus on your chosen path',
            weeks: 10,
            courses: [
              {
                'title': learningGoal.contains('Full Stack')
                    ? 'Full Stack Development'
                    : 'Advanced Web Development',
                'duration': '5 weeks',
                'icon': '🚀',
              },
              {
                'title': 'Cloud & DevOps',
                'duration': '5 weeks',
                'icon': '☁️',
              },
            ],
            milestones: [
              'Deploy applications to the cloud',
              'Implement CI/CD pipelines',
              'Build production-ready applications',
            ],
          ),
        ];
      } else {
        // Advanced
        phases = [
          LearningPhase(
            name: 'Expert Development',
            description: 'Master advanced software engineering',
            weeks: 12,
            courses: [
              {
                'title': 'System Design & Architecture',
                'duration': '6 weeks',
                'icon': '🏗️',
              },
              {
                'title': 'Performance & Scalability',
                'duration': '6 weeks',
                'icon': '📈',
              },
            ],
            milestones: [
              'Design scalable systems',
              'Optimize for millions of users',
              'Lead technical projects',
            ],
          ),
        ];
      }

      // Add a final project phase for everyone
      phases.add(
        LearningPhase(
          name: 'Capstone Project',
          description: 'Apply everything you\'ve learned',
          weeks: 4,
          courses: [
            {
              'title': 'Final Project',
              'duration': '4 weeks',
              'icon': '🎓',
            },
          ],
          milestones: [
            'Plan and design a complete application',
            'Implement all features',
            'Deploy and showcase your project',
          ],
        ),
      );

      final totalWeeks = phases.fold(0, (sum, phase) => sum + phase.weeks);

      return LearningPath(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: 'Personalized $learningGoal Path',
        description:
            'A customized $totalWeeks-week journey designed for $skillLevel developers '
            'focusing on $learningGoal with $weeklyHours hours of study per week.',
        difficulty: skillLevel,
        totalWeeks: totalWeeks,
        weeklyHours: weeklyHours,
        phases: phases,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      AppLogger.error('Error generating learning path', error: e);
      // Return a basic path as fallback
      return LearningPath(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: 'Standard Learning Path',
        description: 'A comprehensive programming journey',
        difficulty: 'beginner',
        totalWeeks: 12,
        weeklyHours: weeklyHours,
        phases: [
          LearningPhase(
            name: 'Getting Started',
            description: 'Begin your programming journey',
            weeks: 12,
            courses: [
              {
                'title': 'Programming Basics',
                'duration': '12 weeks',
                'icon': '📚',
              },
            ],
            milestones: ['Complete basic programming course'],
          ),
        ],
        createdAt: DateTime.now(),
      );
    }
  }

  // Explain wrong answer
  Future<String> explainWrongAnswer({
    required QuestionModel question,
    required String userAnswer,
  }) async {
    try {
      // TODO: Implement actual Gemini API call
      // For now, return a placeholder explanation
      return 'The correct answer is "${question.correctAnswer}". ${question.explanation}';
    } catch (e) {
      AppLogger.error('Error explaining wrong answer', error: e);
      return 'Unable to generate explanation at this time.';
    }
  }

  // Generate quiz feedback
  Future<String> generateQuizFeedback({
    required QuizResultModel quizResult,
    required List<QuestionModel> questions,
    required Map<int, String> userAnswers,
  }) async {
    try {
      // TODO: Implement actual Gemini API call
      // For now, return a placeholder feedback
      final percentage = quizResult.percentage;
      if (percentage >= 90) {
        return 'Excellent work! You demonstrated a strong understanding of the material.';
      } else if (percentage >= 70) {
        return 'Good job! You have a solid grasp of the concepts with room for improvement.';
      } else if (percentage >= 50) {
        return 'You\'re making progress! Review the incorrect answers and try again.';
      } else {
        return 'Keep practicing! Focus on understanding the core concepts before retaking the quiz.';
      }
    } catch (e) {
      AppLogger.error('Error generating quiz feedback', error: e);
      return 'Great effort on completing the quiz!';
    }
  }

  // Generate learning recommendations
  Future<List<String>> generateLearningRecommendations({
    required QuizResultModel quizResult,
    required List<QuestionModel> wrongQuestions,
    required String courseName,
  }) async {
    try {
      // TODO: Implement actual Gemini API call
      // For now, return placeholder recommendations
      return [
        'Review the lesson materials for better understanding',
        'Practice more problems similar to the ones you missed',
        'Take notes on key concepts and review them regularly',
        'Try explaining the concepts to someone else to reinforce learning',
      ];
    } catch (e) {
      AppLogger.error('Error generating recommendations', error: e);
      return ['Keep practicing to improve your understanding'];
    }
  }

  // Generate motivational message
  Future<String> generateMotivationalMessage(int scorePercentage) async {
    try {
      // TODO: Implement actual Gemini API call
      // For now, return score-based motivational messages
      if (scorePercentage >= 90) {
        return '🌟 Outstanding performance! You\'re mastering this material!';
      } else if (scorePercentage >= 80) {
        return '🎯 Great job! You\'re well on your way to mastery!';
      } else if (scorePercentage >= 70) {
        return '💪 Good work! Keep pushing forward!';
      } else if (scorePercentage >= 60) {
        return '📈 You\'re improving! Every attempt makes you stronger!';
      } else {
        return '🚀 Don\'t give up! Every expert was once a beginner!';
      }
    } catch (e) {
      AppLogger.error('Error generating motivational message', error: e);
      return 'Keep up the great work!';
    }
  }

  // Generate code explanation
  Future<String> generateCodeExplanation(String code, String language) async {
    try {
      // TODO: Implement actual Gemini API call
      return 'This code demonstrates key concepts in $language programming.';
    } catch (e) {
      AppLogger.error('Error generating code explanation', error: e);
      return 'Unable to generate explanation.';
    }
  }

  // Generate hints for a question
  Future<List<String>> generateHints({
    required QuestionModel question,
    required int hintsRequested,
  }) async {
    try {
      // TODO: Implement actual Gemini API call
      return [
        'Think about the problem step by step',
        'Consider what the question is really asking',
        'Review similar examples from the lesson',
      ].take(hintsRequested).toList();
    } catch (e) {
      AppLogger.error('Error generating hints', error: e);
      return ['Try breaking down the problem into smaller parts'];
    }
  }
}

// Model classes moved outside of GeminiService class
class LearningPath {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String difficulty;
  final int totalWeeks;
  final int weeklyHours;
  final List<LearningPhase> phases;
  final DateTime createdAt;

  LearningPath({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.totalWeeks,
    required this.weeklyHours,
    required this.phases,
    required this.createdAt,
  });
}

class LearningPhase {
  final String name;
  final String description;
  final int weeks;
  final List<Map<String, String>> courses;
  final List<String> milestones;

  LearningPhase({
    required this.name,
    required this.description,
    required this.weeks,
    required this.courses,
    required this.milestones,
  });
}
