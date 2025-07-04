import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/models/code_challenge_model.dart';
import 'package:procode/services/judge0_service.dart';
import 'package:procode/services/gamification_service.dart';

// Add type alias at the top of the file
typedef CodeChallenge = CodeChallengeModel;

class CodeEditorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Judge0Service _judge0Service = Judge0Service();
  final GamificationService _gamificationService = GamificationService();

  // Get a specific code challenge
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

  // Get all code challenges for a specific language
  Future<List<CodeChallenge>> getCodeChallenges({
    String? language,
    String? difficulty,
  }) async {
    try {
      Query query = _firestore.collection('challenges');

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

  // Submit code solution with actual execution
  Future<Map<String, dynamic>> submitSolution({
    required String userId,
    required String challengeId,
    required String code,
    required String language,
  }) async {
    try {
      // Get the challenge details
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
          // Execute code with Judge0 or Piston
          final result = await _judge0Service.executeCodeWithPiston(
            code: code,
            language: language,
            stdin: testCase.input,
          );

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
          allPassed = false;
          testResults.add({
            'testCase': testCase.description,
            'passed': false,
            'error': e.toString(),
          });
        }
      }

      // Save submission to Firestore
      final submission = await _firestore.collection('submissions').add({
        'userId': userId,
        'challengeId': challengeId,
        'code': code,
        'language': language,
        'testResults': testResults,
        'allPassed': allPassed,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // If all tests passed, award XP and update progress
      if (allPassed) {
        await _gamificationService.awardXP(userId, challenge.xpReward);

        // Update user's completed challenges
        await _firestore.collection('users').doc(userId).update({
          'completedChallenges': FieldValue.arrayUnion([challengeId]),
        });

        // Check for achievements related to challenges
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

  // Get user's submission history
  Future<List<Map<String, dynamic>>> getUserSubmissions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('submissions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
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

  // Get code templates for different languages
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

  // Get code snippets for autocomplete
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

  // Save user's code progress (draft)
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

  // Get user's saved code draft
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

  // Get daily coding challenge
  Future<CodeChallenge?> getDailyChallenge() async {
    try {
      // Get today's date string
      final today = DateTime.now();
      final dateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Check if daily challenge exists for today
      final dailyDoc =
          await _firestore.collection('daily_challenges').doc(dateString).get();

      if (dailyDoc.exists) {
        final challengeId = dailyDoc.data()?['challengeId'];
        return await getCodeChallenge(challengeId);
      }

      // If no daily challenge, select a random easy/medium challenge
      final challenges = await getCodeChallenges();
      final eligibleChallenges = challenges
          .where((c) => c.difficulty == 'Easy' || c.difficulty == 'Medium')
          .toList();

      if (eligibleChallenges.isNotEmpty) {
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
