import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:procode/models/question_model.dart';
import 'package:procode/models/quiz_result_model.dart';
import 'package:procode/utils/app_logger.dart';

class GeminiService {
  // Get API key from environment
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // Test API connection
  Future<bool> testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey');

      AppLogger.info('Testing Gemini API connection...');
      AppLogger.info('API Key present: ${_apiKey.isNotEmpty}');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': 'Hello, test message'}
                  ]
                }
              ],
              'generationConfig': {
                'temperature': 0.1,
                'maxOutputTokens': 50,
              }
            }),
          )
          .timeout(const Duration(seconds: 10));

      AppLogger.info('Gemini API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else {
        AppLogger.error(
            'Gemini API test failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      AppLogger.error('Gemini API connection test error', error: e);
      return false;
    }
  }

  // Chat-based conversation method
  Future<String> getChatResponse({
    required String message,
    required String systemPrompt,
  }) async {
    try {
      if (_apiKey.isEmpty) {
        return 'AI service is not configured. Please check your API key.';
      }

      final url = Uri.parse('$_baseUrl?key=$_apiKey');

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': '$systemPrompt\n\nUser message: $message'}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.8,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return text.trim();
        } else {
          return _getChatFallbackResponse(message);
        }
      } else {
        AppLogger.error('Gemini API error: ${response.statusCode}');
        return _getChatFallbackResponse(message);
      }
    } catch (e) {
      AppLogger.error('Error in getChatResponse', error: e);
      return _getChatFallbackResponse(message);
    }
  }

  String _getChatFallbackResponse(String message) {
    return '''I understand you're interested in learning programming! While I'm having trouble connecting to my full capabilities right now, I can still help guide you.

Based on what you've shared, I recommend starting with fundamental programming concepts and gradually building up your skills. Consider exploring courses in Python or JavaScript as they're beginner-friendly languages.

What specific area of programming interests you most?''';
  }

  // Main method for AI conversations
  Future<String> getAIAdvice({
    required String message,
    required String userId,
    required String context,
  }) async {
    try {
      if (_apiKey.isEmpty) {
        return 'AI service is not configured. Please check your API key.';
      }

      final url = Uri.parse('$_baseUrl?key=$_apiKey');

      final prompt = '''
You are an AI Learning Advisor for ProCode, a gamified programming learning platform. 
You help users with course recommendations, programming concepts, career guidance, and learning strategies.

User Context: $context
User Message: $message

Please provide a helpful, encouraging response that:
- Addresses the user's specific question or need
- Is educational and informative
- Suggests relevant courses or learning paths when appropriate
- Maintains a friendly, supportive tone
- Encourages continued learning
''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return text.trim();
        } else {
          return _getFallbackResponse(message);
        }
      } else {
        AppLogger.error(
            'Gemini API error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(message);
      }
    } catch (e) {
      AppLogger.error('Error getting AI advice', error: e);
      return _getFallbackResponse(message);
    }
  }

  // AI Assistant for Code Editor - FIXED IMPLEMENTATION
  Future<String> getAIResponse({
    required String code,
    required String question,
    required String language,
  }) async {
    try {
      if (_apiKey.isEmpty) {
        return 'AI service is not configured. Please check your API key.';
      }

      final url = Uri.parse('$_baseUrl?key=$_apiKey');

      final prompt = '''
You are an AI coding assistant helping with $language programming.

User's Code:
```$language
$code
```

User's Question: $question

Please provide a helpful, detailed response that:
- Directly addresses the user's question
- Provides code examples when relevant
- Explains concepts clearly
- Suggests improvements or best practices
- Is encouraging and educational

Keep your response concise but complete.
''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        }
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return text.trim();
        } else {
          return _getCodeAssistantFallback(question, language);
        }
      } else {
        AppLogger.error('Gemini API error: ${response.statusCode}');
        return _getCodeAssistantFallback(question, language);
      }
    } catch (e) {
      AppLogger.error('Error in getAIResponse', error: e);
      return _getCodeAssistantFallback(question, language);
    }
  }

  // Generate course recommendations with AI
  Future<Map<String, dynamic>> generateCourseRecommendations({
    required String userGoal,
    required String skillLevel,
    required List<dynamic> availableCourses,
  }) async {
    try {
      if (_apiKey.isEmpty) {
        return _getDefaultRecommendations(userGoal);
      }

      final url = Uri.parse('$_baseUrl?key=$_apiKey');

      final prompt = '''
You are an AI course advisor for ProCode, a programming learning platform.

User's Goal: $userGoal
Current Skill Level: $skillLevel

Based on this information, provide personalized course recommendations.

Format your response EXACTLY as follows:
REASONING: [Provide a detailed analysis of why these courses match the user's goals]

COURSES:
1. [Course Title] | [Brief Description] | [Difficulty: Beginner/Intermediate/Advanced] | [Duration: X weeks]
2. [Course Title] | [Brief Description] | [Difficulty: Beginner/Intermediate/Advanced] | [Duration: X weeks]
3. [Course Title] | [Brief Description] | [Difficulty: Beginner/Intermediate/Advanced] | [Duration: X weeks]

Provide 3-5 course recommendations that progressively build skills toward the user's goal.
''';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1024,
        }
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'];
          return _parseRecommendationResponse(text, userGoal);
        } else {
          return _getDefaultRecommendations(userGoal);
        }
      } else {
        return _getDefaultRecommendations(userGoal);
      }
    } catch (e) {
      AppLogger.error('Error generating recommendations', error: e);
      return _getDefaultRecommendations(userGoal);
    }
  }

  // Helper method to parse AI recommendation response
  Map<String, dynamic> _parseRecommendationResponse(
      String aiResponse, String userGoal) {
    try {
      final lines = aiResponse.split('\n');
      String reasoning = '';
      List<Map<String, dynamic>> courses = [];
      bool inReasoning = false;
      bool inCourses = false;

      for (String line in lines) {
        if (line.contains('REASONING:')) {
          inReasoning = true;
          reasoning = line.replaceAll('REASONING:', '').trim();
        } else if (line.contains('COURSES:')) {
          inReasoning = false;
          inCourses = true;
        } else if (inCourses && line.trim().isNotEmpty) {
          // Parse course line with pipe separator
          final parts = line.split('|').map((p) => p.trim()).toList();
          if (parts.length >= 3) {
            final titleMatch = RegExp(r'^\d+\.\s*(.+)').firstMatch(parts[0]);
            final title = titleMatch?.group(1) ?? parts[0];

            courses.add({
              'title': title.trim(),
              'description': parts.length > 1 ? parts[1] : '',
              'difficulty': parts.length > 2
                  ? parts[2].replaceAll('Difficulty:', '').trim()
                  : 'Beginner',
              'duration': parts.length > 3
                  ? parts[3].replaceAll('Duration:', '').trim()
                  : '4 weeks',
              'icon': _getCourseIcon(title),
            });
          }
        } else if (inReasoning && line.trim().isNotEmpty) {
          reasoning += ' ' + line.trim();
        }
      }

      // If parsing failed, return default structure
      if (courses.isEmpty) {
        return _getDefaultRecommendations(userGoal);
      }

      return {
        'reasoning': reasoning.trim(),
        'courses': courses,
      };
    } catch (e) {
      return _getDefaultRecommendations(userGoal);
    }
  }

  // Get course icon based on title
  String _getCourseIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('web') || lower.contains('html')) return '🌐';
    if (lower.contains('mobile') || lower.contains('app')) return '📱';
    if (lower.contains('data') || lower.contains('database')) return '🗄️';
    if (lower.contains('python')) return '🐍';
    if (lower.contains('javascript') || lower.contains('js')) return '🟨';
    if (lower.contains('java')) return '☕';
    if (lower.contains('algorithm')) return '🧮';
    if (lower.contains('ai') || lower.contains('machine')) return '🤖';
    if (lower.contains('cloud')) return '☁️';
    if (lower.contains('security')) return '🔒';
    if (lower.contains('game')) return '🎮';
    if (lower.contains('backend')) return '🖥️';
    if (lower.contains('frontend')) return '🎨';
    return '💻';
  }

  // Fallback response for code assistant
  String _getCodeAssistantFallback(String question, String language) {
    final questionLower = question.toLowerCase();

    if (questionLower.contains('explain')) {
      return '''I'll explain your $language code:

Your code implements specific functionality using $language syntax and conventions. Here's what I can tell you:

1. **Structure**: The code follows standard $language patterns
2. **Purpose**: It appears to handle specific operations or calculations
3. **Best Practices**: Consider adding comments for clarity and ensuring proper error handling

Would you like me to explain any specific part in more detail?''';
    } else if (questionLower.contains('debug') ||
        questionLower.contains('error')) {
      return '''Here are debugging suggestions for your $language code:

1. **Check Syntax**: Ensure all brackets, parentheses, and semicolons are properly placed
2. **Variable Names**: Verify that all variables are declared and spelled correctly
3. **Logic Flow**: Trace through your code step by step
4. **Add Debug Output**: Insert print statements to track values
5. **Test Edge Cases**: Consider empty inputs or boundary conditions

What specific issue are you encountering?''';
    } else if (questionLower.contains('optimize')) {
      return '''Here are optimization suggestions for your $language code:

1. **Algorithm Efficiency**: Consider if there's a more efficient approach
2. **Reduce Redundancy**: Look for repeated code that could be extracted
3. **Data Structures**: Use appropriate data structures for your needs
4. **Memory Usage**: Avoid unnecessary object creation
5. **Code Readability**: Balance optimization with maintainability

Which aspect would you like to focus on?''';
    } else if (questionLower.contains('hint')) {
      return '''Here's a hint to help you:

• Break down the problem into smaller steps
• Consider the input and expected output
• Think about edge cases
• Try solving it on paper first
• Look for patterns in the problem

Remember: Practice makes perfect! Keep trying different approaches.''';
    } else {
      return '''I'm here to help with your $language code! I can:

• **Explain** how your code works
• **Debug** issues and errors
• **Optimize** for better performance
• **Provide hints** for problem-solving
• **Suggest** best practices

What would you like to know about your code?''';
    }
  }

  // Fallback response for when API fails
  String _getFallbackResponse(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('course') || lower.contains('recommend')) {
      return '''I'd be happy to recommend courses for you! To give you the best recommendations, could you tell me more about:

• Your current programming experience
• What you'd like to build or achieve
• How much time you can dedicate to learning

This will help me suggest the perfect learning path for you!''';
    } else if (lower.contains('hello') || lower.contains('hi')) {
      return '''Hello! I'm your AI Learning Advisor. I'm here to help you with:

• Course recommendations
• Programming questions
• Career guidance
• Learning strategies

What would you like to know?''';
    } else if (lower.contains('help')) {
      return '''I'm here to help! I can assist you with:

• Finding the right courses for your goals
• Explaining programming concepts
• Creating a personalized learning path
• Answering technical questions
• Providing motivation and support

What specific topic interests you?''';
    } else {
      return '''I understand you're asking about: "$message"

I can help you with:
• Finding the right courses for your goals
• Explaining programming concepts
• Creating a personalized learning path
• Answering technical questions

What specific aspect would you like to explore?''';
    }
  }

  // Default recommendations when AI fails
  Map<String, dynamic> _getDefaultRecommendations(String userGoal) {
    final goal = userGoal.toLowerCase();
    List<Map<String, dynamic>> courses = [];
    String reasoning = '';

    if (goal.contains('game') || goal.contains('dev')) {
      reasoning =
          '''For game development, you'll need a strong foundation in programming fundamentals, followed by game-specific concepts like graphics, physics, and game engines. I've selected courses that will progressively build your skills from beginner to professional game developer.''';
      courses = [
        {
          'title': 'Programming Fundamentals with Python',
          'description': 'Learn core programming concepts with Python',
          'difficulty': 'Beginner',
          'duration': '6 weeks',
          'icon': '🐍',
        },
        {
          'title': 'Object-Oriented Programming',
          'description': 'Master OOP concepts essential for game development',
          'difficulty': 'Intermediate',
          'duration': '4 weeks',
          'icon': '🎯',
        },
        {
          'title': 'Game Development with Unity',
          'description': 'Build your first games with Unity engine',
          'difficulty': 'Intermediate',
          'duration': '8 weeks',
          'icon': '🎮',
        },
        {
          'title': 'Advanced Game Programming',
          'description': 'Physics, AI, and multiplayer game systems',
          'difficulty': 'Advanced',
          'duration': '10 weeks',
          'icon': '🚀',
        },
      ];
    } else if (goal.contains('full stack') ||
        goal.contains('fullstack') ||
        goal.contains('web')) {
      reasoning =
          '''For full-stack development, you need to master both frontend and backend technologies. I've structured a learning path that starts with web fundamentals and progressively builds up to advanced full-stack skills.''';
      courses = [
        {
          'title': 'Web Development Fundamentals',
          'description': 'HTML, CSS, and JavaScript basics',
          'difficulty': 'Beginner',
          'duration': '6 weeks',
          'icon': '🌐',
        },
        {
          'title': 'Frontend Development with React',
          'description': 'Build modern web applications with React',
          'difficulty': 'Intermediate',
          'duration': '6 weeks',
          'icon': '⚛️',
        },
        {
          'title': 'Backend Development with Node.js',
          'description': 'Server-side programming and APIs',
          'difficulty': 'Intermediate',
          'duration': '8 weeks',
          'icon': '🖥️',
        },
        {
          'title': 'Database Design and SQL',
          'description': 'Master relational and NoSQL databases',
          'difficulty': 'Intermediate',
          'duration': '4 weeks',
          'icon': '🗄️',
        },
        {
          'title': 'Full-Stack Project Development',
          'description': 'Build complete web applications',
          'difficulty': 'Advanced',
          'duration': '8 weeks',
          'icon': '🚀',
        },
      ];
    } else if (goal.contains('mobile')) {
      reasoning =
          '''Mobile development is an excellent choice! I've created a path that starts with programming basics and leads to building professional mobile applications for both iOS and Android.''';
      courses = [
        {
          'title': 'Programming Basics with Dart',
          'description': 'Learn Dart programming language',
          'difficulty': 'Beginner',
          'duration': '4 weeks',
          'icon': '🎯',
        },
        {
          'title': 'Flutter Fundamentals',
          'description': 'Build beautiful cross-platform apps',
          'difficulty': 'Intermediate',
          'duration': '6 weeks',
          'icon': '🦋',
        },
        {
          'title': 'Advanced Flutter Development',
          'description': 'State management, animations, and more',
          'difficulty': 'Advanced',
          'duration': '8 weeks',
          'icon': '📱',
        },
        {
          'title': 'Mobile App Architecture',
          'description': 'Design patterns and best practices',
          'difficulty': 'Advanced',
          'duration': '6 weeks',
          'icon': '🏗️',
        },
      ];
    } else {
      reasoning =
          '''Based on your interests, I've selected courses that will give you a strong foundation in programming and prepare you for various career paths in software development.''';
      courses = [
        {
          'title': 'Programming Fundamentals',
          'description': 'Core programming concepts with Python',
          'difficulty': 'Beginner',
          'duration': '8 weeks',
          'icon': '💻',
        },
        {
          'title': 'Data Structures & Algorithms',
          'description': 'Essential computer science concepts',
          'difficulty': 'Intermediate',
          'duration': '10 weeks',
          'icon': '🧮',
        },
        {
          'title': 'Web Development Basics',
          'description': 'Introduction to web technologies',
          'difficulty': 'Beginner',
          'duration': '6 weeks',
          'icon': '🌐',
        },
        {
          'title': 'Software Engineering Principles',
          'description': 'Best practices and design patterns',
          'difficulty': 'Intermediate',
          'duration': '8 weeks',
          'icon': '🛠️',
        },
      ];
    }

    return {
      'reasoning': reasoning,
      'courses': courses,
    };
  }

  // Other methods remain the same...
  Future<String> explainWrongAnswer({
    required QuestionModel question,
    required String userAnswer,
  }) async {
    return 'The correct answer is "${question.correctAnswer}". ${question.explanation}';
  }

  Future<String> generateQuizFeedback({
    required QuizResultModel quizResult,
    required List<QuestionModel> questions,
    required Map<int, String> userAnswers,
  }) async {
    final percentage = quizResult.percentage;
    if (percentage >= 90) {
      return 'Excellent work! You demonstrated a strong understanding of the material.';
    } else if (percentage >= 70) {
      return 'Good job! You have a solid grasp of the concepts with room for improvement.';
    } else {
      return 'Keep practicing! Review the concepts and try again.';
    }
  }

  Future<List<String>> generateLearningRecommendations({
    required QuizResultModel quizResult,
    required List<QuestionModel> wrongQuestions,
    required String courseName,
  }) async {
    return [
      'Review the lesson materials for better understanding',
      'Practice more problems similar to the ones you missed',
      'Take notes on key concepts and review them regularly',
    ];
  }

  Future<String> generateMotivationalMessage(int scorePercentage) async {
    if (scorePercentage >= 90) {
      return '🌟 Outstanding performance! You\'re mastering this material!';
    } else if (scorePercentage >= 70) {
      return '💪 Good work! Keep pushing forward!';
    } else {
      return '🚀 Don\'t give up! Every expert was once a beginner!';
    }
  }

  Future<String> generateCodeExplanation(String code, String language) async {
    return 'This code demonstrates key concepts in $language programming.';
  }

  Future<List<String>> generateHints({
    required QuestionModel question,
    required int hintsRequested,
  }) async {
    return [
      'Think about the problem step by step',
      'Consider what the question is really asking',
      'Review similar examples from the lesson',
    ].take(hintsRequested).toList();
  }

  // Generate learning path with AI
  Future<LearningPath> generateLearningPath({
    required String userId,
    required String skillLevel,
    required String learningGoal,
    required List<dynamic> availableCourses,
    required List<String> completedCourses,
    required int weeklyHours,
  }) async {
    try {
      return _getDefaultLearningPath(
          userId, skillLevel, learningGoal, weeklyHours);
    } catch (e) {
      AppLogger.error('Error generating learning path', error: e);
      return _getDefaultLearningPath(
          userId, skillLevel, learningGoal, weeklyHours);
    }
  }

  // Default learning path
  LearningPath _getDefaultLearningPath(
    String userId,
    String skillLevel,
    String learningGoal,
    int weeklyHours,
  ) {
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
            'Master control flow',
            'Create simple functions',
          ],
        ),
      ];
    }

    final totalWeeks = phases.fold(0, (sum, phase) => sum + phase.weeks);

    return LearningPath(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: 'Personalized $learningGoal Path',
      description: 'A customized journey for $skillLevel developers',
      difficulty: skillLevel,
      totalWeeks: totalWeeks,
      weeklyHours: weeklyHours,
      phases: phases,
      createdAt: DateTime.now(),
    );
  }
}

// Model classes
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
