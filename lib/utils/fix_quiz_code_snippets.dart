// lib/utils/fix_quiz_code_snippets.dart
// Run this from your Flutter app to fix missing code snippets

import 'package:cloud_firestore/cloud_firestore.dart';

class QuizCodeSnippetFixer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Call this method from a button in your app
  static Future<void> fixMissingCodeSnippets() async {
    print('Starting to fix missing code snippets...');

    try {
      // Get the specific quiz that's missing code snippets
      final quizzesSnapshot = await _firestore.collection('quizzes').get();

      int totalFixed = 0;

      for (final quizDoc in quizzesSnapshot.docs) {
        final quizData = quizDoc.data();
        final quizTitle = quizData['title'];

        print('Processing quiz: $quizTitle');

        // Get questions for this quiz
        final questionsSnapshot = await _firestore
            .collection('quizzes')
            .doc(quizDoc.id)
            .collection('questions')
            .get();

        final batch = _firestore.batch();
        int fixedInQuiz = 0;

        for (final questionDoc in questionsSnapshot.docs) {
          final questionData = questionDoc.data();
          final question = questionData['question'];
          final existingSnippet = questionData['codeSnippet'];

          // Check if this question needs a code snippet
          String? codeSnippet;

          // Python Variables & Data Types quiz
          if (quizTitle == "Python Variables & Data Types") {
            if (question == "What will be the output?" &&
                questionData['options']?.contains('True')) {
              codeSnippet = "x = 5\ny = '5'\nprint(x == y)";
            } else if (question.contains("10 // 3")) {
              codeSnippet = "10 // 3";
            } else if (question == "What is the output?" &&
                questionData['options']?.contains('[1, 2, 3, 4]')) {
              codeSnippet = "x = [1, 2, 3]\ny = x\ny.append(4)\nprint(x)";
            } else if (question.contains("type(3.14)")) {
              codeSnippet = "type(3.14)";
            }
          }

          // Python Control Flow quiz
          else if (quizTitle == "Python Control Flow") {
            if (question.contains("range(3)")) {
              codeSnippet = "for i in range(3):\n    print(i)";
            } else if (question == "What is the output?" &&
                questionData['options']?.contains('B')) {
              codeSnippet =
                  "x = 5\nif x > 10:\n    print('A')\nelif x > 3:\n    print('B')\nelse:\n    print('C')";
            } else if (question == "What is the output?" &&
                questionData['options']?.contains('2 4 6')) {
              codeSnippet = "for i in range(2, 8, 2):\n    print(i, end=' ')";
            } else if (question.contains("list comprehension")) {
              codeSnippet = "[x**2 for x in range(4) if x % 2 == 0]";
            }
          }

          // Python Master Challenge
          else if (quizTitle.contains("Python Master Challenge")) {
            if (question == "What is the output of this code?" &&
                questionData['options']?.contains('[1, 2, 3]')) {
              codeSnippet = "x = [1, 2, 3]\ny = x[:]\ny.append(4)\nprint(x)";
            } else if (question == "What is the output?" &&
                questionData['options']?.contains('7')) {
              codeSnippet =
                  "def func(a, b=2, c=3):\n    return a + b + c\n\nprint(func(1, c=4))";
            } else if (question.contains("'Python'[1:4]")) {
              codeSnippet = "'Python'[1:4]";
            } else if (question == "What is the output?" &&
                questionData['options']?.contains('[1, 2, 3]') &&
                questionData['correctAnswer'] == '[1, 2, 3]') {
              codeSnippet = "a = [1, 2, 3]\nb = a\na = a + [4]\nprint(b)";
            } else if (question == "What is the output?" &&
                questionData['correctAnswer'] == '2') {
              codeSnippet =
                  "def outer():\n    x = 1\n    def inner():\n        nonlocal x\n        x = 2\n    inner()\n    return x\n\nprint(outer())";
            }
          }

          // If we found a code snippet to add and it's missing
          if (codeSnippet != null &&
              (existingSnippet == null || existingSnippet == '')) {
            print('  Adding code snippet to: ${question.substring(0, 50)}...');

            batch.update(
              questionDoc.reference,
              {'codeSnippet': codeSnippet},
            );
            fixedInQuiz++;
          }
        }

        if (fixedInQuiz > 0) {
          await batch.commit();
          print('  Fixed $fixedInQuiz questions in $quizTitle');
          totalFixed += fixedInQuiz;
        }
      }

      print('Finished! Fixed $totalFixed questions total.');
    } catch (e) {
      print('Error fixing code snippets: $e');
      rethrow;
    }
  }

  // Quick fix for a specific quiz by ID
  static Future<void> fixSpecificQuiz(String quizId) async {
    try {
      final questionsSnapshot = await _firestore
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .orderBy('orderIndex')
          .get();

      final batch = _firestore.batch();

      // Map of question indices to code snippets for Python Variables quiz
      final codeSnippets = {
        1: "type(3.14)", // What is the output of: type(3.14)
        4: "x = 5\ny = '5'\nprint(x == y)", // What will be the output?
        6: "10 // 3", // What is the result of: 10 // 3
        9: "x = [1, 2, 3]\ny = x\ny.append(4)\nprint(x)", // What is the output?
      };

      for (int i = 0; i < questionsSnapshot.docs.length; i++) {
        final doc = questionsSnapshot.docs[i];
        final codeSnippet = codeSnippets[i];

        if (codeSnippet != null) {
          batch.update(doc.reference, {'codeSnippet': codeSnippet});
        }
      }

      await batch.commit();
      print('Fixed code snippets for quiz');
    } catch (e) {
      print('Error: $e');
    }
  }
}

// Example usage - Add this to a temporary button:
// ElevatedButton(
//   onPressed: () async {
//     try {
//       await QuizCodeSnippetFixer.fixMissingCodeSnippets();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Code snippets fixed!')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   },
//   child: Text('Fix Quiz Code Snippets'),
// ),
