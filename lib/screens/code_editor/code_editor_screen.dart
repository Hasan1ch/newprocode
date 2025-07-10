import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/highlight_core.dart';
import 'package:provider/provider.dart';
import 'package:procode/models/code_challenge_model.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/screens/code_editor/widgets/ai_assistant_panel.dart';
import 'package:procode/screens/code_editor/widgets/editor_toolbar.dart';
import 'package:procode/screens/code_editor/widgets/output_console.dart';
import 'package:procode/services/code_editor_service.dart';
import 'package:procode/services/judge0_service.dart';
import 'package:procode/widgets/common/custom_app_bar.dart';

/// Main code editor screen that provides an interactive coding environment
/// Students can write, run, and test their code solutions here
/// Supports multiple programming languages and themes for better learning experience
class CodeEditorScreen extends StatefulWidget {
  final CodeChallengeModel? challenge; // Optional challenge to solve
  final String? initialCode; // Pre-filled code when opening the editor
  final String? language; // Preferred programming language

  const CodeEditorScreen({
    super.key,
    this.challenge,
    this.initialCode,
    this.language,
  });

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  late CodeController _codeController; // Controls the code editor widget
  final CodeEditorService _codeService =
      CodeEditorService(); // Handles code-related operations
  final Judge0Service _judge0Service =
      Judge0Service(); // External service for code execution

  // Editor customization settings that enhance the coding experience
  String _selectedLanguage =
      'Python'; // Default to Python as it's beginner-friendly
  String _selectedTheme = 'Dark'; // Most developers prefer dark themes
  double _fontSize = 14; // Readable font size for code
  bool _wrapLines = false; // Line wrapping can help with long lines
  final bool _showLineNumbers =
      true; // Always show line numbers for easy reference
  bool _showAIAssistant = false; // Toggle for AI coding assistant panel

  // Code execution results and state management
  String _output = ''; // Program output from stdout
  String _error = ''; // Error messages from stderr
  bool _isRunning = false; // Prevents multiple simultaneous executions
  List<Map<String, dynamic>>? _testResults; // Results from running test cases

  // Auto-save functionality to prevent losing student work
  DateTime? _lastSaveTime; // Tracks when we last saved
  bool _hasUnsavedChanges = false; // Shows save indicator in UI

  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  /// Sets up the code editor with the appropriate language and initial code
  /// Prioritizes: widget.language > challenge.language > default Python
  void _initializeEditor() {
    // Determine which language to use based on context
    if (widget.language != null) {
      _selectedLanguage = widget.language!;
    } else if (widget.challenge != null) {
      _selectedLanguage = widget.challenge!.language;
    }

    // Initialize the code controller with syntax highlighting
    _codeController = CodeController(
      text: widget.initialCode ??
          widget.challenge?.initialCode ??
          _getDefaultCode(_selectedLanguage),
      language: _getLanguageMode(_selectedLanguage),
    );

    // Track code changes for auto-save functionality
    _codeController.addListener(_onCodeChanged);

    // Load any previously saved draft after the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDraft();
    });
  }

  /// Triggered whenever the user types in the editor
  /// Implements auto-save with a 2-second debounce to avoid excessive saves
  void _onCodeChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });

    // Debounced auto-save to prevent overwhelming the database
    Future.delayed(const Duration(seconds: 2), () {
      if (_hasUnsavedChanges &&
          (_lastSaveTime == null ||
              DateTime.now().difference(_lastSaveTime!) >
                  const Duration(seconds: 2))) {
        _saveDraft();
      }
    });
  }

  /// Loads previously saved code drafts so students don't lose their work
  /// Only loads drafts for authenticated users working on challenges
  Future<void> _loadDraft() async {
    if (widget.challenge != null) {
      final userProvider = context.read<UserProvider>();
      final user = userProvider.user;

      if (user != null) {
        final draft = await _codeService.getCodeDraft(
          user.id,
          widget.challenge!.id,
        );

        // Only update the editor if we found a saved draft
        if (draft != null && draft.isNotEmpty && mounted) {
          setState(() {
            _codeController.text = draft;
          });
        }
      }
    }
  }

  /// Saves the current code as a draft to prevent data loss
  /// This runs automatically after 2 seconds of inactivity
  Future<void> _saveDraft() async {
    if (widget.challenge != null) {
      final userProvider = context.read<UserProvider>();
      final user = userProvider.user;

      if (user != null) {
        await _codeService.saveCodeDraft(
          userId: user.id,
          challengeId: widget.challenge!.id,
          code: _codeController.text,
        );

        // Update UI to show the code has been saved
        if (mounted) {
          setState(() {
            _hasUnsavedChanges = false;
            _lastSaveTime = DateTime.now();
          });
        }
      }
    }
  }

  /// Executes the user's code using the Piston API (via Judge0 service)
  /// Handles both standalone code execution and challenge test cases
  Future<void> _runCode() async {
    // Reset the output area and show loading state
    setState(() {
      _isRunning = true;
      _output = '';
      _error = '';
      _testResults = null;
    });

    try {
      // Execute the code with Piston API for safe sandboxed execution
      final result = await _judge0Service.executeCodeWithPiston(
        code: _codeController.text,
        language: _selectedLanguage,
        stdin: widget.challenge?.testCases.first.input ?? '',
      );

      setState(() {
        _output = result['stdout'] ?? '';
        _error = result['stderr'] ?? '';
        _isRunning = false;
      });

      // If this is a challenge, run all test cases to check correctness
      if (widget.challenge != null) {
        await _runTestCases();
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isRunning = false;
      });
    }
  }

  /// Runs all test cases for a challenge and checks if the solution is correct
  /// Automatically submits the solution if all tests pass
  Future<void> _runTestCases() async {
    if (widget.challenge == null) return;

    final results = <Map<String, dynamic>>[];

    // Run each test case independently to check correctness
    for (int i = 0; i < widget.challenge!.testCases.length; i++) {
      final testCase = widget.challenge!.testCases[i];

      try {
        final result = await _judge0Service.executeCodeWithPiston(
          code: _codeController.text,
          language: _selectedLanguage,
          stdin: testCase.input,
        );

        // Compare actual output with expected output
        final actualOutput = (result['stdout'] ?? '').trim();
        final expectedOutput = testCase.expectedOutput.trim();
        final passed = actualOutput == expectedOutput;

        results.add({
          'testCase': testCase.description,
          'input': testCase.input,
          'expected': expectedOutput,
          'actual': actualOutput,
          'passed': passed,
          'executionTime': result['time'],
        });
      } catch (e) {
        // Handle execution errors for individual test cases
        results.add({
          'testCase': testCase.description,
          'input': testCase.input,
          'expected': testCase.expectedOutput,
          'actual': 'Error: ${e.toString()}',
          'passed': false,
        });
      }
    }

    setState(() {
      _testResults = results;
    });

    // Check if all tests passed and submit the solution
    if (results.every((r) => r['passed'] == true) && widget.challenge != null) {
      final userProvider = context.read<UserProvider>();
      final user = userProvider.user;

      if (user != null) {
        // Save the successful solution to track student progress
        await _codeService.submitSolution(
          userId: user.id,
          challengeId: widget.challenge!.id,
          code: _codeController.text,
          language: _selectedLanguage,
        );

        // Celebrate the student's success with XP rewards
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        // Prompt login for non-authenticated users
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to submit your solution'),
            ),
          );
        }
      }
    }
  }

  /// Shows a celebration dialog when the student completes a challenge
  /// This positive reinforcement encourages continued learning
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Challenge Completed!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You earned ${widget.challenge!.xpReward} XP!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to challenges list
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Basic code formatting to improve readability
  /// Currently handles extra blank lines and trailing whitespace
  void _formatCode() {
    String code = _codeController.text;

    // Remove excessive blank lines (more than 2 consecutive)
    code = code.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

    // Clean up trailing whitespace on each line
    code = code.split('\n').map((line) => line.trimRight()).join('\n');

    setState(() {
      _codeController.text = code;
    });
  }

  /// Clears the output console for a fresh start
  void _clearConsole() {
    setState(() {
      _output = '';
      _error = '';
      _testResults = null;
    });
  }

  /// Provides starter code templates for each supported language
  /// Helps beginners understand basic program structure
  String _getDefaultCode(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return '# Write your Python code here\n\ndef main():\n    print("Hello, World!")\n\nif __name__ == "__main__":\n    main()';
      case 'javascript':
        return '// Write your JavaScript code here\n\nfunction main() {\n    console.log("Hello, World!");\n}\n\nmain();';
      case 'java':
        return 'public class Main {\n    public static void main(String[] args) {\n        System.out.println("Hello, World!");\n    }\n}';
      case 'c++':
        return '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "Hello, World!" << endl;\n    return 0;\n}';
      case 'dart':
        return 'void main() {\n  print("Hello, World!");\n}';
      default:
        return '// Write your code here';
    }
  }

  /// Maps language names to their syntax highlighting modes
  Mode _getLanguageMode(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return python;
      case 'javascript':
        return javascript;
      case 'java':
        return java;
      case 'c++':
        return cpp;
      case 'dart':
        return dart;
      default:
        return python;
    }
  }

  /// Returns the appropriate syntax highlighting theme
  /// Different themes can help with eye strain during long coding sessions
  Map<String, TextStyle> _getTheme(String themeName) {
    switch (themeName) {
      case 'Light':
        return vsTheme;
      case 'Dark':
        return atomOneDarkTheme;
      case 'Monokai':
        return monokaiSublimeTheme;
      case 'Dracula':
        return draculaTheme;
      default:
        return atomOneDarkTheme;
    }
  }

  @override
  void dispose() {
    // Clean up listeners to prevent memory leaks
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: widget.challenge?.title ?? 'Code Editor',
        showBackButton: true,
        actions: [
          // Visual indicator when code hasn't been saved yet
          if (_hasUnsavedChanges)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text('Unsaved', style: TextStyle(fontSize: 12)),
                backgroundColor: Colors.orange.withValues(alpha: 0.2),
                side: const BorderSide(color: Colors.orange),
                padding: EdgeInsets.zero,
              ),
            ),
          // Run button with keyboard shortcut tooltip
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _isRunning ? null : _runCode,
            tooltip: 'Run Code (Ctrl+Enter)',
            color: Colors.green,
          ),
          // Toggle AI assistant for coding help
          IconButton(
            icon: Icon(
              _showAIAssistant ? Icons.close : Icons.auto_awesome,
            ),
            onPressed: () {
              setState(() {
                _showAIAssistant = !_showAIAssistant;
              });
            },
            tooltip: 'AI Assistant',
          ),
        ],
      ),
      body: Column(
        children: [
          // Challenge description header - shows what problem to solve
          if (widget.challenge != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.challenge!.description,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Difficulty indicator helps students choose appropriate challenges
                      Chip(
                        label: Text(widget.challenge!.difficulty),
                        backgroundColor: _getDifficultyColor(
                          widget.challenge!.difficulty,
                        ).withValues(alpha: 0.2),
                        side: BorderSide(
                          color:
                              _getDifficultyColor(widget.challenge!.difficulty),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 8),
                      // XP reward motivates students to complete challenges
                      Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text('${widget.challenge!.xpReward} XP'),
                          ],
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Toolbar for customizing the editor experience
          EditorToolbar(
            selectedLanguage: _selectedLanguage,
            selectedTheme: _selectedTheme,
            fontSize: _fontSize,
            wrapLines: _wrapLines,
            onLanguageChanged: (language) {
              setState(() {
                _selectedLanguage = language;
                _codeController.language = _getLanguageMode(language);
              });
            },
            onThemeChanged: (theme) {
              setState(() {
                _selectedTheme = theme;
              });
            },
            onFontSizeChanged: (size) {
              setState(() {
                _fontSize = size;
              });
            },
            onWrapLinesChanged: (wrap) {
              setState(() {
                _wrapLines = wrap;
              });
            },
            onFormat: _formatCode,
          ),

          // Main coding area with optional AI assistant
          Expanded(
            child: Row(
              children: [
                // The actual code editor with syntax highlighting
                Expanded(
                  child: Container(
                    color: _selectedTheme == 'Light'
                        ? Colors.white
                        : const Color(0xFF1E1E1E),
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (event) {
                        // Keyboard shortcut for running code quickly
                        if (event.isControlPressed &&
                            event.logicalKey == LogicalKeyboardKey.enter) {
                          _runCode();
                        }
                      },
                      child: CodeTheme(
                        data: CodeThemeData(styles: _getTheme(_selectedTheme)),
                        child: SingleChildScrollView(
                          child: CodeField(
                            controller: _codeController,
                            textStyle: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: _fontSize,
                            ),
                            wrap: _wrapLines,
                            lineNumbers: _showLineNumbers,
                            minLines: 30, // Ensures adequate editing space
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // AI Assistant side panel for coding help and suggestions
                if (_showAIAssistant)
                  AIAssistantPanel(
                    code: _codeController.text,
                    language: _selectedLanguage,
                    challenge: widget.challenge,
                    onClose: () {
                      setState(() {
                        _showAIAssistant = false;
                      });
                    },
                    onApplySuggestion: (suggestion) {
                      setState(() {
                        _codeController.text = suggestion;
                      });
                    },
                  ),
              ],
            ),
          ),

          // Output console shows execution results and test outcomes
          SizedBox(
            height: 250,
            child: OutputConsole(
              output: _output,
              error: _error,
              isRunning: _isRunning,
              testResults: _testResults,
              onClear: _clearConsole,
              onStop: _isRunning
                  ? () {
                      setState(() {
                        _isRunning = false;
                      });
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns appropriate color for difficulty levels
  /// Green for easy, orange for medium, red for hard
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
