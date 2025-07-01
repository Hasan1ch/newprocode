import 'package:flutter/material.dart';
import 'package:procode/models/code_challenge_model.dart';
import 'package:procode/services/gemini_service.dart';
import 'package:procode/config/theme.dart';

class AIAssistantPanel extends StatefulWidget {
  final String code;
  final String language;
  final CodeChallenge? challenge;
  final VoidCallback onClose;
  final ValueChanged<String> onApplySuggestion;

  const AIAssistantPanel({
    super.key,
    required this.code,
    required this.language,
    this.challenge,
    required this.onClose,
    required this.onApplySuggestion,
  });

  @override
  State<AIAssistantPanel> createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends State<AIAssistantPanel> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _queryController = TextEditingController();

  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String _selectedAction = 'explain';

  final List<Map<String, dynamic>> _quickActions = [
    {
      'id': 'explain',
      'icon': Icons.help_outline,
      'label': 'Explain Code',
      'prompt': 'Explain this code in simple terms',
    },
    {
      'id': 'debug',
      'icon': Icons.bug_report,
      'label': 'Debug Help',
      'prompt': 'Help me debug this code',
    },
    {
      'id': 'optimize',
      'icon': Icons.speed,
      'label': 'Optimize',
      'prompt': 'Suggest optimizations for this code',
    },
    {
      'id': 'hint',
      'icon': Icons.lightbulb_outline,
      'label': 'Get Hint',
      'prompt': 'Give me a hint for solving this problem',
    },
  ];

  @override
  void initState() {
    super.initState();
    _sendInitialMessage();
  }

  void _sendInitialMessage() {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'content':
            'Hi! I\'m your AI coding assistant. I can help you understand, debug, and improve your code. What would you like help with?',
      });
    });
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'content': message,
      });
      _isLoading = true;
    });

    _queryController.clear();

    try {
      // Build the question with context
      String fullQuestion = message;

      if (widget.challenge != null) {
        fullQuestion = '''
$message

Challenge Context:
Title: ${widget.challenge!.title}
Description: ${widget.challenge!.description}
''';
      }

      final response = await _geminiService.getAIResponse(
        code: widget.code,
        question: fullQuestion,
        language: widget.language,
      );

      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': response,
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': 'Sorry, I encountered an error. Please try again.',
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleQuickAction(Map<String, dynamic> action) async {
    setState(() {
      _selectedAction = action['id'];
    });

    String prompt = action['prompt'];

    if (action['id'] == 'hint' && widget.challenge != null) {
      prompt += ' for the challenge: ${widget.challenge!.title}';
    }

    await _sendMessage(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Quick Actions
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickActions.length,
              itemBuilder: (context, index) {
                final action = _quickActions[index];
                final isSelected = _selectedAction == action['id'];

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ActionChip(
                    avatar: Icon(
                      action['icon'],
                      size: 18,
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                    ),
                    label: Text(
                      action['label'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor:
                        isSelected ? AppTheme.primaryColor : Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.grey[300]!,
                    ),
                    onPressed: () => _handleQuickAction(action),
                  ),
                );
              },
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primaryColor,
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser
                                ? AppTheme.primaryColor
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['content']!,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything about your code...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading
                      ? null
                      : () => _sendMessage(_queryController.text),
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}
