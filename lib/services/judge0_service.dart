import 'dart:convert';
import 'package:http/http.dart' as http;

class Judge0Service {
  // Using Judge0 public API (you can also host your own instance)
  static const String _baseUrl = 'https://judge0-ce.p.rapidapi.com';

  // You need to get your own API key from RapidAPI
  // https://rapidapi.com/judge0-official/api/judge0-ce
  static const String _apiKey =
      '6a7488d9e2msh2d046a8ad2a723bp16d39ajsn7ed3c95e55b4';

  final Map<String, int> _languageIds = {
    'Python': 71, // Python 3.8.1
    'JavaScript': 63, // Node.js 12.14.0
    'Java': 62, // Java (OpenJDK 13.0.1)
    'C++': 54, // C++ (GCC 9.2.0)
    'C': 50, // C (GCC 9.2.0)
    'Dart': 90, // Dart 2.19.2
    'Go': 60, // Go 1.13.5
    'Ruby': 72, // Ruby 2.7.0
    'PHP': 68, // PHP 7.4.1
    'Swift': 83, // Swift 5.2.3
    'Kotlin': 78, // Kotlin 1.3.70
    'Rust': 73, // Rust 1.40.0
  };

  Future<Map<String, dynamic>> executeCode({
    required String code,
    required String language,
    String? stdin,
    int timeLimit = 2,
    int memoryLimit = 128000,
  }) async {
    try {
      // Create submission
      final submissionId = await _createSubmission(
        code: code,
        language: language,
        stdin: stdin,
        timeLimit: timeLimit,
        memoryLimit: memoryLimit,
      );

      // Poll for results
      return await _getSubmissionResult(submissionId);
    } catch (e) {
      throw Exception('Code execution failed: $e');
    }
  }

  Future<String> _createSubmission({
    required String code,
    required String language,
    String? stdin,
    required int timeLimit,
    required int memoryLimit,
  }) async {
    final languageId = _languageIds[language];
    if (languageId == null) {
      throw Exception('Unsupported language: $language');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/submissions?base64_encoded=true&wait=false'),
      headers: {
        'Content-Type': 'application/json',
        'X-RapidAPI-Key': _apiKey,
        'X-RapidAPI-Host': 'judge0-ce.p.rapidapi.com',
      },
      body: jsonEncode({
        'source_code': base64Encode(utf8.encode(code)),
        'language_id': languageId,
        'stdin': stdin != null ? base64Encode(utf8.encode(stdin)) : null,
        'cpu_time_limit': timeLimit,
        'memory_limit': memoryLimit,
        'enable_network': false,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Failed to create submission: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> _getSubmissionResult(String token) async {
    const maxAttempts = 10;
    const delayMs = 1000;

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
        if (status['id'] <= 2) {
          continue; // Still processing
        }

        // Decode base64 outputs
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
          'time': data['time'],
          'memory': data['memory'],
          'status': status['description'],
          'status_id': status['id'],
        };
      }
    }

    throw Exception('Submission timed out');
  }

  // Alternative: Use free Piston API (no API key required)
  Future<Map<String, dynamic>> executeCodeWithPiston({
    required String code,
    required String language,
    String? stdin,
  }) async {
    const pistonUrl = 'https://emkc.org/api/v2/piston/execute';

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
      final response = await http.post(
        Uri.parse(pistonUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'language': pistonLang,
          'version': '*', // Use latest version
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
