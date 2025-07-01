import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/auth_provider.dart';
import 'package:procode/screens/ai_advisor/widgets/chat_bubble.dart';
import 'package:procode/screens/ai_advisor/learning_path_screen.dart';
import 'package:procode/services/gemini_service.dart';
import 'package:procode/widgets/common/custom_text_field.dart';
import 'package:procode/config/theme.dart';

class AIAdvisorScreen extends StatefulWidget {
  const AIAdvisorScreen({Key? key}) : super(key: key);

  @override
  State<AIAdvisorScreen> createState() => _AIAdvisorScreenState();
}

class _AIAdvisorScreenState extends State<AIAdvisorScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text: "Hi! I'm your AI Learning Advisor. I can help you with:\n\n"
              "• Creating personalized learning paths\n"
              "• Answering programming questions\n"
              "• Suggesting courses and resources\n"
              "• Setting learning goals\n"
              "• Providing career guidance\n\n"
              "What would you like help with today?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final user = context.read<AuthProvider>().user;
      final response = await _geminiService.getAIAdvice(
        message: message,
        userId: user?.uid ?? '',
        context: _buildContextFromMessages(),
      );

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "I'm sorry, I encountered an error. Please try again later.",
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _buildContextFromMessages() {
    return _messages
        .take(10) // Last 10 messages for context
        .map((m) => "${m.isUser ? 'User' : 'AI'}: ${m.text}")
        .join('\n');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Learning Advisor'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.route),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LearningPathScreen(),
                ),
              );
            },
            tooltip: 'Learning Path',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Actions
          Container(
            height: 40,
            margin: const EdgeInsets.all(8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _QuickActionChip(
                  label: 'Learning Path',
                  icon: Icons.route,
                  onTap: () => _sendQuickMessage(
                      "Help me create a personalized learning path"),
                ),
                const SizedBox(width: 8),
                _QuickActionChip(
                  label: 'Career Advice',
                  icon: Icons.work_outline,
                  onTap: () => _sendQuickMessage(
                      "What career paths are available in programming?"),
                ),
                const SizedBox(width: 8),
                _QuickActionChip(
                  label: 'Study Tips',
                  icon: Icons.lightbulb_outline,
                  onTap: () => _sendQuickMessage(
                      "Give me effective study tips for learning programming"),
                ),
                const SizedBox(width: 8),
                _QuickActionChip(
                  label: 'Project Ideas',
                  icon: Icons.build_outlined,
                  onTap: () => _sendQuickMessage(
                      "Suggest some beginner-friendly project ideas"),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const ChatBubble(
                    message: ChatMessage(
                      text: '',
                      isUser: false,
                      timestamp: null,
                    ),
                    isLoading: true,
                  );
                }

                return ChatBubble(message: _messages[index]);
              },
            ),
          ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _messageController,
                    hint: 'Ask me anything...',
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _sendMessage,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 24,
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

  void _sendQuickMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime? timestamp;
  final bool isError;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });
}
