import 'package:flutter/material.dart';
import 'package:procode/models/code_challenge_model.dart';
import 'package:procode/services/gemini_service.dart';
import 'package:procode/config/theme.dart';
import 'package:procode/config/app_colors.dart';

class AIAssistantPanel extends StatefulWidget {
  final String code;
  final String language;
  final CodeChallengeModel? challenge;
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
  final ScrollController _scrollController = ScrollController();

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
            'Hi! I\'m your AI coding assistant. I can help you understand, debug, and improve your ${widget.language} code. What would you like help with?',
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
    _scrollToBottom();

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

      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': response,
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': 'Sorry, I encountered an error. Please try again.',
          });
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.surfaceVariant,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
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
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.surfaceVariant,
                ),
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
                      color:
                          isSelected ? Colors.white : theme.colorScheme.primary,
                    ),
                    label: Text(
                      action['label'],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    backgroundColor: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surface,
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceVariant,
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
              controller: _scrollController,
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
                          backgroundColor: theme.colorScheme.primary,
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
                            gradient: isUser ? AppTheme.primaryGradient : null,
                            color: isUser
                                ? null
                                : theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SelectableText(
                            message['content']!,
                            style: TextStyle(
                              color: isUser
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
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
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.person,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
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
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
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
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.surfaceVariant,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything about your code...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor:
                          theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading
                          ? null
                          : () => _sendMessage(_queryController.text),
                      borderRadius: BorderRadius.circular(24),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
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
    _scrollController.dispose();
    super.dispose();
  }
}
