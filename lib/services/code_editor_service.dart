import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/models/code_challenge_model.dart';
import 'package:procode/services/judge0_service.dart';
import 'package:procode/services/gamification_service.dart';

// Type alias for cleaner code
typedef CodeChallenge = CodeChallengeModel;

/// Service for managing code challenges and user submissions
/// Handles code execution, validation, and progress tracking
class CodeEditorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Judge0Service _judge0Service = Judge0Service();
  final GamificationService _gamificationService = GamificationService();

  /// Retrieves a specific code challenge by ID
  Future<CodeChallenge?> getCodeChallenge(String challengeId) async {
    try {
      final doc =
          await _firestore.collection('challenges').doc(challengeId).get();

      if (doc.exists) {
        return CodeChallenge.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting code challenge: $e');
      return null;
    }
  }

  /// Gets all code challenges filtered by language and difficulty
  Future<List<CodeChallenge>> getCodeChallenges({
    String? language,
    String? difficulty,
  }) async {
    try {
      Query query = _firestore.collection('challenges');

      // Apply filters if specified
      if (language != null && language != 'All') {
        query = query.where('language', isEqualTo: language);
      }

      if (difficulty != null && difficulty != 'All') {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CodeChallenge.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Error getting code challenges: $e');
      return [];
    }
  }

  /// Submits user's code solution and runs it against test cases
  /// Returns results including test case outcomes and XP earned
  Future<Map<String, dynamic>> submitSolution({
    required String userId,
    required String challengeId,
    required String code,
    required String language,
  }) async {
    try {
      // Get the challenge to access test cases
      final challenge = await getCodeChallenge(challengeId);
      if (challenge == null) {
        throw Exception('Challenge not found');
      }

      // Execute code against all test cases
      final testResults = <Map<String, dynamic>>[];
      bool allPassed = true;

      for (int i = 0; i < challenge.testCases.length; i++) {
        final testCase = challenge.testCases[i];

        try {
          // Execute code with Piston API (Judge0 alternative)
          final result = await _judge0Service.executeCodeWithPiston(
            code: code,
            language: language,
            stdin: testCase.input,
          );

          // Compare output with expected result
          final actualOutput = (result['stdout'] ?? '').trim();
          final expectedOutput = testCase.expectedOutput.trim();
          final passed = actualOutput == expectedOutput;

          if (!passed) allPassed = false;

          testResults.add({
            'testCase': testCase.description,
            'passed': passed,
            'expected': expectedOutput,
            'actual': actualOutput,
            'executionTime': result['time'],
          });
        } catch (e) {
          // Handle execution errors (syntax errors, runtime errors, etc.)
          allPassed = false;
          testResults.add({
            'testCase': testCase.description,
            'passed': false,
            'error': e.toString(),
          });
        }
      }

      // Save submission to database for history
      final submission = await _firestore.collection('submissions').add({
        'userId': userId,
        'challengeId': challengeId,
        'code': code,
        'language': language,
        'testResults': testResults,
        'allPassed': allPassed,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Award XP and update progress if all tests passed
      if (allPassed) {
        await _gamificationService.awardXP(userId, challenge.xpReward);

        // Mark challenge as completed
        await _firestore.collection('users').doc(userId).update({
          'completedChallenges': FieldValue.arrayUnion([challengeId]),
        });

        // Check for challenge-related achievements
        await _gamificationService.checkAndAwardAchievements(
          userId,
          'challenges_completed',
          1,
        );
      }

      return {
        'success': allPassed,
        'testResults': testResults,
        'submissionId': submission.id,
        'xpEarned': allPassed ? challenge.xpReward : 0,
      };
    } catch (e) {
      print('Error submitting solution: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Gets user's submission history for review and learning
  Future<List<Map<String, dynamic>>> getUserSubmissions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('submissions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50) // Limit to last 50 submissions
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting user submissions: $e');
      return [];
    }
  }

  /// Provides language-specific code templates for challenges
  /// Helps users get started with proper input/output handling
  Map<String, String> getCodeTemplates() {
    return {
      'Python': '''def solution(input_data):
    # Parse input
    lines = input_data.strip().split('\\n')
    
    # Your code here
    
    # Return result
    return result

# Read input
input_data = input()
print(solution(input_data))
''',
      'JavaScript': '''function solution(inputData) {
    // Parse input
    const lines = inputData.trim().split('\\n');
    
    // Your code here
    
    // Return result
    return result;
}

// Read input and output result
const inputData = '';
console.log(solution(inputData));
''',
      'Java': '''import java.util.*;
import java.io.*;

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        
        // Read input
        String inputData = scanner.nextLine();
        
        // Process and output
        System.out.println(solution(inputData));
    }
    
    public static String solution(String inputData) {
        // Your code here
        
        return result;
    }
}
''',
      'C++': '''#include <iostream>
#include <string>
#include <vector>
using namespace std;

string solution(string inputData) {
    // Your code here
    
    return result;
}

int main() {
    string inputData;
    getline(cin, inputData);
    
    cout << solution(inputData) << endl;
    
    return 0;
}
''',
    };
  }

  /// Gets code snippets for autocomplete functionality
  Future<List<Map<String, dynamic>>> getCodeSnippets(String language) async {
    try {
      final snapshot = await _firestore
          .collection('code_snippets')
          .where('language', isEqualTo: language)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting code snippets: $e');
      return [];
    }
  }

  /// Saves user's code as a draft to prevent loss of work
  Future<void> saveCodeDraft({
    required String userId,
    required String challengeId,
    required String code,
  }) async {
    try {
      await _firestore
          .collection('code_drafts')
          .doc('${userId}_$challengeId')
          .set({
        'userId': userId,
        'challengeId': challengeId,
        'code': code,
        'lastModified': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving code draft: $e');
    }
  }

  /// Retrieves user's saved draft for a challenge
  Future<String?> getCodeDraft(String userId, String challengeId) async {
    try {
      final doc = await _firestore
          .collection('code_drafts')
          .doc('${userId}_$challengeId')
          .get();

      if (doc.exists) {
        return doc.data()?['code'];
      }
      return null;
    } catch (e) {
      print('Error getting code draft: $e');
      return null;
    }
  }

  /// Gets or generates the daily coding challenge
  /// Provides consistent daily practice opportunity
  Future<CodeChallenge?> getDailyChallenge() async {
    try {
      // Generate today's date string for consistent daily challenge
      final today = DateTime.now();
      final dateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Check if daily challenge already selected for today
      final dailyDoc =
          await _firestore.collection('daily_challenges').doc(dateString).get();

      if (dailyDoc.exists) {
        final challengeId = dailyDoc.data()?['challengeId'];
        return await getCodeChallenge(challengeId);
      }

      // No daily challenge set - select a random easy/medium challenge
      final challenges = await getCodeChallenges();
      final eligibleChallenges = challenges
          .where((c) => c.difficulty == 'Easy' || c.difficulty == 'Medium')
          .toList();

      if (eligibleChallenges.isNotEmpty) {
        // Use date-based random selection for consistency
        final random = eligibleChallenges[
            DateTime.now().millisecondsSinceEpoch % eligibleChallenges.length];

        // Save as today's challenge
        await _firestore.collection('daily_challenges').doc(dateString).set({
          'challengeId': random.id,
          'date': dateString,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return random;
      }

      return null;
    } catch (e) {
      print('Error getting daily challenge: $e');
      return null;
    }
  }
}
