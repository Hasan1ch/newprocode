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

class CodeEditorScreen extends StatefulWidget {
  final CodeChallengeModel? challenge;
  final String? initialCode;
  final String? language;

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
  late CodeController _codeController;
  final CodeEditorService _codeService = CodeEditorService();
  final Judge0Service _judge0Service = Judge0Service();

  // Editor settings
  String _selectedLanguage = 'Python';
  String _selectedTheme = 'Dark';
  double _fontSize = 14;
  bool _wrapLines = false;
  final bool _showLineNumbers = true;
  bool _showAIAssistant = false;

  // Output
  String _output = '';
  String _error = '';
  bool _isRunning = false;
  List<Map<String, dynamic>>? _testResults;

  // Auto-save
  DateTime? _lastSaveTime;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  void _initializeEditor() {
    // Set initial language
    if (widget.language != null) {
      _selectedLanguage = widget.language!;
    } else if (widget.challenge != null) {
      _selectedLanguage = widget.challenge!.language;
    }

    // Initialize code controller
    _codeController = CodeController(
      text: widget.initialCode ??
          widget.challenge?.initialCode ??
          _getDefaultCode(_selectedLanguage),
      language: _getLanguageMode(_selectedLanguage),
    );

    // Listen for code changes
    _codeController.addListener(_onCodeChanged);

    // Load saved draft if exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDraft();
    });
  }

  void _onCodeChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });

    // Auto-save after 2 seconds of inactivity
    Future.delayed(const Duration(seconds: 2), () {
      if (_hasUnsavedChanges &&
          (_lastSaveTime == null ||
              DateTime.now().difference(_lastSaveTime!) >
                  const Duration(seconds: 2))) {
        _saveDraft();
      }
    });
  }

  Future<void> _loadDraft() async {
    if (widget.challenge != null) {
      final userProvider = context.read<UserProvider>();
      final user = userProvider.user;

      if (user != null) {
        final draft = await _codeService.getCodeDraft(
          user.id,
          widget.challenge!.id,
        );

        if (draft != null && draft.isNotEmpty && mounted) {
          setState(() {
            _codeController.text = draft;
          });
        }
      }
    }
  }

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

        if (mounted) {
          setState(() {
            _hasUnsavedChanges = false;
            _lastSaveTime = DateTime.now();
          });
        }
      }
    }
  }

  Future<void> _runCode() async {
    setState(() {
      _isRunning = true;
      _output = '';
      _error = '';
      _testResults = null;
    });

    try {
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

      // Run test cases if this is a challenge
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

  Future<void> _runTestCases() async {
    if (widget.challenge == null) return;

    final results = <Map<String, dynamic>>[];

    for (int i = 0; i < widget.challenge!.testCases.length; i++) {
      final testCase = widget.challenge!.testCases[i];

      try {
        final result = await _judge0Service.executeCodeWithPiston(
          code: _codeController.text,
          language: _selectedLanguage,
          stdin: testCase.input,
        );

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

    // If all tests passed, submit the solution
    if (results.every((r) => r['passed'] == true) && widget.challenge != null) {
      final userProvider = context.read<UserProvider>();
      final user = userProvider.user;

      if (user != null) {
        await _codeService.submitSolution(
          userId: user.id,
          challengeId: widget.challenge!.id,
          code: _codeController.text,
          language: _selectedLanguage,
        );

        // Show success dialog
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        // Show login required message
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
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _formatCode() {
    // Basic formatting - you can enhance this
    String code = _codeController.text;

    // Remove extra blank lines
    code = code.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');

    // Trim trailing whitespace
    code = code.split('\n').map((line) => line.trimRight()).join('\n');

    setState(() {
      _codeController.text = code;
    });
  }

  void _clearConsole() {
    setState(() {
      _output = '';
      _error = '';
      _testResults = null;
    });
  }

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
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _isRunning ? null : _runCode,
            tooltip: 'Run Code (Ctrl+Enter)',
            color: Colors.green,
          ),
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
          // Challenge Description (if exists)
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

          // Editor Toolbar
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

          // Main Content Area
          Expanded(
            child: Row(
              children: [
                // Code Editor
                Expanded(
                  child: Container(
                    color: _selectedTheme == 'Light'
                        ? Colors.white
                        : const Color(0xFF1E1E1E),
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (event) {
                        // Handle keyboard shortcuts
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
                            minLines: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // AI Assistant Panel
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

          // Output Console
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
