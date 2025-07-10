import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Judge0 Service - Handles code execution for the code editor feature
/// This service allows users to write, run, and test code directly in the app
/// Supports multiple programming languages with sandboxed execution
class Judge0Service {
  // API configuration from environment variables for security
  static String get _baseUrl =>
      dotenv.env['JUDGE0_BASE_URL'] ?? 'https://judge0-ce.p.rapidapi.com';

  // API key stored securely - never hardcode API keys!
  static String get _apiKey => dotenv.env['JUDGE0_API_KEY'] ?? '';

  /// Language ID mapping for Judge0 API
  /// Each language has a specific ID that tells Judge0 which compiler/interpreter to use
  final Map<String, int> _languageIds = {
    'Python': 71, // Python 3.8.1 - Most popular for beginners
    'JavaScript': 63, // Node.js 12.14.0 - Web development
    'Java': 62, // Java (OpenJDK 13.0.1) - Enterprise & Android
    'C++': 54, // C++ (GCC 9.2.0) - Competitive programming
    'C': 50, // C (GCC 9.2.0) - System programming
    'Dart': 90, // Dart 2.19.2 - Flutter development
    'Go': 60, // Go 1.13.5 - Modern backend
    'Ruby': 72, // Ruby 2.7.0 - Web development
    'PHP': 68, // PHP 7.4.1 - Web development
    'Swift': 83, // Swift 5.2.3 - iOS development
    'Kotlin': 78, // Kotlin 1.3.70 - Android development
    'Rust': 73, // Rust 1.40.0 - System programming
  };

  /// Main method to execute user code
  /// This is called when users click "Run" in the code editor
  Future<Map<String, dynamic>> executeCode({
    required String code,
    required String language,
    String? stdin, // Optional input for programs that need user input
    int timeLimit = 2, // Prevent infinite loops (seconds)
    int memoryLimit = 128000, // Prevent memory abuse (KB)
  }) async {
    try {
      // Check if API key is configured
      if (_apiKey.isEmpty) {
        throw Exception(
            'Judge0 API key not found. Please check your .env file.');
      }

      // Step 1: Submit code for execution
      final submissionId = await _createSubmission(
        code: code,
        language: language,
        stdin: stdin,
        timeLimit: timeLimit,
        memoryLimit: memoryLimit,
      );

      // Step 2: Poll for results (execution happens asynchronously)
      return await _getSubmissionResult(submissionId);
    } catch (e) {
      throw Exception('Code execution failed: $e');
    }
  }

  /// Creates a code submission on Judge0 servers
  /// Returns a token/ID to track the submission
  Future<String> _createSubmission({
    required String code,
    required String language,
    String? stdin,
    required int timeLimit,
    required int memoryLimit,
  }) async {
    // Get the numeric ID for the selected language
    final languageId = _languageIds[language];
    if (languageId == null) {
      throw Exception('Unsupported language: $language');
    }

    // Make API request to create submission
    final response = await http.post(
      Uri.parse('$_baseUrl/submissions?base64_encoded=true&wait=false'),
      headers: {
        'Content-Type': 'application/json',
        'X-RapidAPI-Key': _apiKey,
        'X-RapidAPI-Host': 'judge0-ce.p.rapidapi.com',
      },
      body: jsonEncode({
        // Base64 encode to handle special characters and newlines
        'source_code': base64Encode(utf8.encode(code)),
        'language_id': languageId,
        'stdin': stdin != null ? base64Encode(utf8.encode(stdin)) : null,
        'cpu_time_limit': timeLimit,
        'memory_limit': memoryLimit,
        'enable_network': false, // Security: disable network access
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['token']; // This token is used to retrieve results
    } else {
      throw Exception('Failed to create submission: ${response.body}');
    }
  }

  /// Polls Judge0 API to get execution results
  /// Uses exponential backoff to avoid overwhelming the server
  Future<Map<String, dynamic>> _getSubmissionResult(String token) async {
    const maxAttempts = 10; // Maximum polling attempts
    const delayMs = 1000; // Delay between polls (1 second)

    // Poll up to maxAttempts times
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(Duration(milliseconds: delayMs));

      final response = await http.get(
        Uri.parse('$_baseUrl/submissions/$token?base64_encoded=true'),
        headers: {
          'X-RapidAPI-Key': _apiKey,
          'X-RapidAPI-Host': 'judge0-ce.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];

        // Status IDs: 1 = In Queue, 2 = Processing, 3 = Accepted
        // Continue polling if still processing
        if (status['id'] <= 2) {
          continue; // Still processing
        }

        // Decode base64 outputs and return results
        return {
          'stdout': data['stdout'] != null
              ? utf8.decode(base64Decode(data['stdout']))
              : '',
          'stderr': data['stderr'] != null
              ? utf8.decode(base64Decode(data['stderr']))
              : '',
          'compile_output': data['compile_output'] != null
              ? utf8.decode(base64Decode(data['compile_output']))
              : '',
          'time': data['time'], // Execution time in seconds
          'memory': data['memory'], // Memory usage in KB
          'status': status['description'],
          'status_id': status['id'],
        };
      }
    }

    throw Exception('Submission timed out');
  }

  /// Alternative implementation using free Piston API
  /// This is a fallback option when Judge0 quota is exceeded
  /// No API key required but has fewer features
  Future<Map<String, dynamic>> executeCodeWithPiston({
    required String code,
    required String language,
    String? stdin,
  }) async {
    const pistonUrl = 'https://emkc.org/api/v2/piston/execute';

    // Piston uses different language names
    final pistonLanguages = {
      'Python': 'python',
      'JavaScript': 'javascript',
      'Java': 'java',
      'C++': 'cpp',
      'C': 'c',
      'Go': 'go',
      'Ruby': 'ruby',
      'PHP': 'php',
      'Swift': 'swift',
      'Kotlin': 'kotlin',
      'Rust': 'rust',
    };

    final pistonLang = pistonLanguages[language];
    if (pistonLang == null) {
      throw Exception('Unsupported language: $language');
    }

    try {
      // Piston API is simpler - no authentication needed
      final response = await http.post(
        Uri.parse(pistonUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'language': pistonLang,
          'version': '*', // Use latest version available
          'files': [
            {
              'content': code,
            }
          ],
          'stdin': stdin ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final run = data['run'];

        // Format response to match Judge0 structure
        return {
          'stdout': run['stdout'] ?? '',
          'stderr': run['stderr'] ?? '',
          'compile_output': run['compile_output'] ?? '',
          'time': '${run['runtime'] ?? 0}s',
          'memory': null, // Piston doesn't provide memory usage
          'status': run['code'] == 0 ? 'Accepted' : 'Runtime Error',
          'status_id': run['code'] == 0 ? 3 : 11,
        };
      } else {
        throw Exception('Piston API error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to execute code: $e');
    }
  }
}
