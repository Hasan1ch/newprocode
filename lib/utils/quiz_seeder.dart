// lib/utils/quiz_seeder.dart
// This can be run from within Flutter app to seed quiz data

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/models/quiz_model.dart';
import 'package:procode/models/question_model.dart';

/// Database seeder for populating initial quiz content
/// This utility creates sample quizzes and questions for testing
/// and provides initial content for new app installations
class QuizSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Main seeding method - creates all quiz categories
  /// Call this from a button in your app (admin screen) or from main.dart
  /// Only run once to avoid duplicate data
  static Future<void> seedQuizData() async {
    print('Starting quiz seeding...');

    try {
      // Create different types of quizzes for variety
      // Module Quizzes - tied to specific course modules
      await _createModuleQuizzes();

      // Quick Challenges - 5-minute daily challenges
      await _createQuickChallenges();

      // Weekly Challenges - comprehensive tests
      await _createWeeklyChallenges();

      print('Quiz seeding completed successfully!');
    } catch (e) {
      print('Error seeding quizzes: $e');
      rethrow;
    }
  }

  /// Creates quizzes tied to specific course modules
  /// These test understanding of individual lessons
  static Future<void> _createModuleQuizzes() async {
    print('Creating module quizzes...');

    // Python Variables & Data Types Quiz
    // This quiz tests fundamental Python concepts
    final pythonVariablesQuiz = QuizModel(
      id: '', // Firestore will generate ID
      title: 'Python Variables & Data Types',
      description: 'Test your understanding of Python variables and data types',
      courseId: 'python_fundamentals',
      moduleId: 'module_001',
      difficulty: 'beginner',
      category: 'module',
      timeLimit: 600, // 10 minutes
      passingScore: 70, // 70% to pass
      totalQuestions: 10,
      xpReward: 50, // Reward for completion
      isActive: true,
    );

    // Questions progressively increase in difficulty
    final pythonVariablesQuestions = [
      QuestionModel(
        id: '',
        type: 'mcq',
        question: 'Which of the following is a valid Python variable name?',
        options: ['2variable', '_variable', 'variable-name', 'class'],
        correctAnswer: '_variable',
        explanation:
            'Variable names can start with letters or underscore, but not numbers or contain hyphens. \'class\' is a reserved keyword.',
        difficulty: 'easy',
        points: 5,
      ),
      QuestionModel(
        id: '',
        type: 'mcq',
        question: 'What is the output of: type(3.14)',
        codeSnippet: 'type(3.14)', // Code shown to user
        options: [
          '<class \'int\'>',
          '<class \'float\'>',
          '<class \'str\'>',
          '<class \'number\'>'
        ],
        correctAnswer: '<class \'float\'>',
        explanation:
            '3.14 is a floating-point number, so its type is \'float\'',
        difficulty: 'easy',
        points: 5,
      ),
      QuestionModel(
        id: '',
        type: 'mcq',
        question: 'Which data type is mutable in Python?',
        options: ['int', 'str', 'list', 'tuple'],
        correctAnswer: 'list',
        explanation:
            'Lists are mutable (can be changed), while int, str, and tuple are immutable',
        difficulty: 'medium',
        points: 5,
      ),
      QuestionModel(
        id: '',
        type: 'boolean',
        question: 'True or False: Python is a statically typed language',
        options: ['True', 'False'],
        correctAnswer: 'False',
        explanation:
            'Python is dynamically typed - variable types are determined at runtime',
        difficulty: 'easy',
        points: 5,
      ),
      QuestionModel(
        id: '',
        type: 'mcq',
        question: 'What will be the output?',
        codeSnippet: 'x = 5\ny = \'5\'\nprint(x == y)',
        options: ['True', 'False', 'Error', 'None'],
        correctAnswer: 'False',
        explanation: '5 (int) is not equal to \'5\' (string) in Python',
        difficulty: 'medium',
        points: 5,
      ),
    ];

    await _createQuizWithQuestions(
        pythonVariablesQuiz, pythonVariablesQuestions);

    // Python Control Flow Quiz
    // Tests understanding of if statements, loops, etc.
    final pythonControlFlowQuiz = QuizModel(
      id: '',
      title: 'Python Control Flow',
      description: 'Master if statements, loops, and control structures',
      courseId: 'python_fundamentals',
      moduleId: 'module_002',
      difficulty: 'beginner',
      category: 'module',
      timeLimit: 900, // 15 minutes
      passingScore: 70,
      totalQuestions: 10,
      xpReward: 50,
      isActive: true,
    );

    final pythonControlFlowQuestions = [
      QuestionModel(
        id: '',
        type: 'mcq',
        question: 'What is the correct syntax for an if statement in Python?',
        options: ['if (x > 5):', 'if x > 5:', 'if x > 5 then:', 'if (x > 5) {'],
        correctAnswer: 'if x > 5:',
        explanation:
            'Python doesn\'t require parentheses for conditions and uses colon',
        difficulty: 'easy',
        points: 5,
      ),
      QuestionModel(
        id: '',
        type: 'mcq',
        question: 'What will this code print?',
        codeSnippet: 'for i in range(3):\n    print(i)',
        options: ['0 1 2', '1 2 3', '0 1 2 3', '1 2'],
        correctAnswer: '0 1 2',
        explanation: 'range(3) generates numbers 0, 1, 2',
        difficulty: 'easy',
        points: 5,
      ),
      QuestionModel(
        id: '',
        type: 'mcq',
        question: 'Which keyword is used to exit a loop prematurely?',
        options: ['exit', 'break', 'stop', 'end'],
        correctAnswer: 'break',
        explanation: 'The \'break\' keyword exits the current loop',
        difficulty: 'easy',
        points: 5,
      ),
    ];

    await _createQuizWithQuestions(
        pythonControlFlowQuiz, pythonControlFlowQuestions);
  }

  /// Creates quick 5-minute challenges for daily practice
  /// These keep users engaged with bite-sized content
  static Future<void> _createQuickChallenges() async {
    print('Creating quick challenges...');

    final pythonBasicsQuiz = QuizModel(
      id: '',
      title: 'Python Basics Speed Run',
      description: '5 quick questions to test your Python fundamentals',
      courseId: 'general', // Not tied to specific course
      difficulty: 'easy',
      category: 'quick',
      timeLimit: 300, // 5 minutes
      passingScore: 60, // Lower passing score for quick challenges
      totalQuestions: 5,
      xpReward: 25, // Smaller reward for quick quiz
      isActive: true,
    );

    final pythonBasicsQuestions = [
      QuestionModel(
        id: '',
        type: 'mcq',
        question: 'How do you print \'Hello World\' in Python?',
        options: [
          'echo \'Hello World\'',
          'print(\'Hello World\')',
          'console.log(\'Hello World\')',
          'printf(\'Hello World\')'
        ],
        correctAnswer: 'print(\'Hello World\')',
        explanation: 'print() is the function used to output text in Python',
        difficulty: 'easy',
        points: 5,
      ),
      QuestionModel(
        id: '',
        type: 'boolean',
        question:
            'True or False: Python uses indentation to define code blocks',
        options: ['True', 'False'],
        correctAnswer: 'True',
        explanation:
            'Python uses indentation instead of curly braces for code blocks',
        difficulty: 'easy',
        points: 5,
      ),
      QuestionModel(
        id: '',
        type: 'mcq',
        question: 'Which symbol is used for single-line comments in Python?',
        options: ['//', '#', '/*', '--'],
        correctAnswer: '#',
        explanation: '# is used for single-line comments in Python',
        difficulty: 'easy',
        points: 5,
      ),
    ];

    await _createQuizWithQuestions(pythonBasicsQuiz, pythonBasicsQuestions);
  }

  /// Creates comprehensive weekly challenges
  /// These test accumulated knowledge and provide bigger rewards
  static Future<void> _createWeeklyChallenges() async {
    print('Creating weekly challenges...');

    final weeklyChallenge = QuizModel(
      id: '',
      title: 'Python Master Challenge - Week 1',
      description: 'Comprehensive test covering all Python basics',
      courseId: 'general',
      difficulty: 'hard',
      category: 'weekly',
      timeLimit: 1800, // 30 minutes
      passingScore: 80, // Higher passing score for weekly challenges
      totalQuestions: 20,
      xpReward: 100, // Big reward for weekly completion
      isActive: true,
    );

    // Mix of easy, medium, and hard questions
    final weeklyChallengeQuestions = [
      QuestionModel(
        id: '',
        type: 'mcq',
        question: 'What is the output of this code?',
        codeSnippet: 'x = [1, 2, 3]\ny = x[:]\ny.append(4)\nprint(x)',
        options: ['[1, 2, 3]', '[1, 2, 3, 4]', 'Error', '[1, 2, 3, 4, 4]'],
        correctAnswer: '[1, 2, 3]',
        explanation:
            'x[:] creates a shallow copy, so modifying y doesn\'t affect x',
        difficulty: 'hard',
        points: 5,
      ),
      QuestionModel(
        id: '',
        type: 'mcq',
        question:
            'Which method would you use to remove and return the last element from a list?',
        options: ['.remove()', '.pop()', '.delete()', '.extract()'],
        correctAnswer: '.pop()',
        explanation:
            'pop() removes and returns the last element (or element at specified index)',
        difficulty: 'medium',
        points: 5,
      ),
      QuestionModel(
        id: '',
        type: 'mcq',
        question: 'What does the \'pass\' statement do?',
        options: [
          'Exits the function',
          'Does nothing',
          'Continues to next iteration',
          'Raises an error'
        ],
        correctAnswer: 'Does nothing',
        explanation:
            '\'pass\' is a null operation - a placeholder where code will eventually go',
        difficulty: 'medium',
        points: 5,
      ),
    ];

    await _createQuizWithQuestions(weeklyChallenge, weeklyChallengeQuestions);
  }

  /// Helper method to create quiz and its questions atomically
  /// Uses batch writes for better performance
  static Future<void> _createQuizWithQuestions(
      QuizModel quiz, List<QuestionModel> questions) async {
    try {
      // Create quiz document first
      final quizDoc = await _firestore.collection('quizzes').add(quiz.toJson());
      print('Created quiz: ${quiz.title}');

      // Create questions subcollection using batch write
      final batch = _firestore.batch();

      for (int i = 0; i < questions.length; i++) {
        final questionRef = _firestore
            .collection('quizzes')
            .doc(quizDoc.id)
            .collection('questions')
            .doc();

        // Add order index to maintain question sequence
        final questionData = questions[i].toJson();
        questionData['orderIndex'] = i;

        batch.set(questionRef, questionData);
      }

      await batch.commit();
      print('  Added ${questions.length} questions');
    } catch (e) {
      print('Error creating quiz ${quiz.title}: $e');
      rethrow;
    }
  }

  /// Checks if quizzes already exist to prevent duplicates
  /// Run this before seeding to avoid duplicate data
  static Future<bool> quizzesExist() async {
    final snapshot = await _firestore.collection('quizzes').limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  /// Clears all quizzes from database
  /// WARNING: This is destructive! Use only for testing
  static Future<void> clearAllQuizzes() async {
    final quizzes = await _firestore.collection('quizzes').get();

    for (final quiz in quizzes.docs) {
      // Delete questions subcollection first
      final questions = await quiz.reference.collection('questions').get();
      for (final question in questions.docs) {
        await question.reference.delete();
      }

      // Then delete quiz document
      await quiz.reference.delete();
    }

    print('All quizzes cleared');
  }
}

// Example usage - Add this to a temporary button in admin/debug screen:
// ElevatedButton(
//   onPressed: () async {
//     try {
//       // Check if quizzes already exist
//       if (await QuizSeeder.quizzesExist()) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Quizzes already exist!')),
//         );
//         return;
//       }
//       await QuizSeeder.seedQuizData();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Quiz data seeded successfully!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error seeding quizzes: $e')),
//       );
//     }
//   },
//   child: Text('Seed Quiz Data'),
// ),
