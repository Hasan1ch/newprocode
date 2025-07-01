import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:procode/models/code_challenge_model.dart';

// Add type alias at the top of the file
typedef CodeChallenge = CodeChallengeModel;

class CodeEditorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a specific code challenge
  Future<CodeChallenge?> getCodeChallenge(String challengeId) async {
    try {
      final doc =
          await _firestore.collection('challenges').doc(challengeId).get();

      if (doc.exists) {
        return CodeChallenge.fromJson(doc.data()!);
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

      if (language != null) {
        query = query.where('language', isEqualTo: language);
      }

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              CodeChallenge.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting code challenges: $e');
      return [];
    }
  }

  // Submit code solution
  Future<Map<String, dynamic>> submitSolution({
    required String userId,
    required String challengeId,
    required String code,
    required String language,
  }) async {
    try {
      // Here you would integrate with a code execution service
      // For now, we'll simulate the response
      final result = await _executeCode(code, challengeId);

      // Save submission to Firestore
      await _firestore.collection('submissions').add({
        'userId': userId,
        'challengeId': challengeId,
        'code': code,
        'language': language,
        'result': result,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return result;
    } catch (e) {
      print('Error submitting solution: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Simulate code execution (replace with actual code execution service)
  Future<Map<String, dynamic>> _executeCode(
      String code, String challengeId) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock response - replace with actual code execution service
    return {
      'success': true,
      'passed': true,
      'testResults': [
        {
          'testCase': 'Test Case 1',
          'passed': true,
          'expected': '[1, 2, 3]',
          'actual': '[1, 2, 3]',
        },
        {
          'testCase': 'Test Case 2',
          'passed': true,
          'expected': '[4, 5, 6]',
          'actual': '[4, 5, 6]',
        },
      ],
      'executionTime': '0.023s',
      'memory': '2.3MB',
    };
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
}
