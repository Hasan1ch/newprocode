import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/services/gemini_service.dart';
import 'package:procode/widgets/common/loading_widget.dart';
import 'package:procode/config/theme.dart';
import 'package:procode/config/app_colors.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Production AI Advisor screen for personalized learning path generation
/// Guides users through a conversation to understand their goals and create recommendations
class AIAdvisorScreen extends StatefulWidget {
  const AIAdvisorScreen({super.key});

  @override
  State<AIAdvisorScreen> createState() => _AIAdvisorScreenState();
}

class _AIAdvisorScreenState extends State<AIAdvisorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();

  // Chat state
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Conversation flow state
  int _currentStep = 0;
  Map<String, String> _userResponses = {};

  // Define conversation steps for structured learning path creation
  final List<String> _conversationSteps = [
    'goal',
    'experience',
    'time',
    'interests',
    'recommendations'
  ];

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  /// Initialize conversation with friendly greeting
  void _startConversation() {
    _addMessage(
      ChatMessage(
        text:
            '''👋 Hello! I'm your AI Learning Advisor. I'm here to help you create a personalized learning path.

Let's start with understanding your goals. What would you like to achieve in programming?

For example:
• Become a web developer
• Build mobile apps
• Create games
• Work with data and AI
• Backend development
• Or something else?

Please tell me about your programming goals and dreams!''',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Add message to chat and auto-scroll
  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  /// Smooth scroll to latest message
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Process user input and generate AI response
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    _addMessage(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _messageController.clear();

    // Store user response for context
    _userResponses[_conversationSteps[_currentStep]] = text;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get AI response based on current step
      String aiResponse = await _getAIResponse(text);

      _addMessage(ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      // Progress to next step if not at final recommendations
      if (_currentStep < _conversationSteps.length - 1) {
        _currentStep++;
      }
    } catch (e) {
      _addMessage(ChatMessage(
        text: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Generate context-aware AI responses based on conversation step
  Future<String> _getAIResponse(String userInput) async {
    switch (_conversationSteps[_currentStep]) {
      case 'goal':
        // Step 1: Understand programming goals
        return await _geminiService.getChatResponse(
          message: userInput,
          systemPrompt:
              '''You are an AI Learning Advisor having a conversation. The user just told you their programming goals: "$userInput".

Acknowledge their goal enthusiastically and ask about their current experience level. Be specific and friendly.

Ask them:
- Have they done any programming before?
- What languages do they know (if any)?
- Rate their experience: complete beginner, some basics, intermediate, or advanced?

Keep it conversational and encouraging.''',
        );

      case 'experience':
        // Step 2: Assess current skill level
        return await _geminiService.getChatResponse(
          message: userInput,
          systemPrompt: '''The user's goal is: ${_userResponses['goal']}
Their experience level: "$userInput"

Acknowledge their experience level positively. Now ask about their time commitment:
- How many hours per week can they dedicate to learning?
- Are they looking for intensive learning or steady progress?
- Do they have a timeline for achieving their goal?

Be encouraging and realistic about time expectations.''',
        );

      case 'time':
        // Step 3: Understand time availability
        return await _geminiService.getChatResponse(
          message: userInput,
          systemPrompt: '''User's goal: ${_userResponses['goal']}
Experience: ${_userResponses['experience']}
Time commitment: "$userInput"

Great! Now ask about their specific interests and preferred learning style:
- What type of projects excite them most?
- Do they prefer theory first or hands-on learning?
- Any specific technologies or frameworks they're curious about?
- What motivates them to learn?

Keep it friendly and show genuine interest.''',
        );

      case 'interests':
        // Step 4: Generate personalized learning path
        return await _geminiService.getChatResponse(
          message: userInput,
          systemPrompt: '''Based on the conversation:
Goal: ${_userResponses['goal']}
Experience: ${_userResponses['experience']}
Time: ${_userResponses['time']}
Interests: "$userInput"

Now provide a detailed, personalized learning path. Include:

1. **Summary of their profile** - Briefly summarize what you understand about them

2. **Recommended Learning Path** with 4-6 courses in order:
   - Course name
   - What they'll learn
   - Why it's important for their goal
   - Estimated duration
   - Difficulty level

3. **Learning Strategy**:
   - Daily/weekly schedule suggestion
   - Project ideas along the way
   - Milestones to track progress

4. **Tips for Success**:
   - Specific advice based on their situation
   - Resources and communities to join
   - How to stay motivated

5. **Next Steps**:
   - What to start with today
   - First week goals

Be detailed, encouraging, and specific to their situation. Format with clear sections using markdown.''',
        );

      case 'recommendations':
        // Follow-up: Handle questions about recommendations
        return await _geminiService.getChatResponse(
          message: userInput,
          systemPrompt: '''The user is responding to your recommendations. 
Their original goal: ${_userResponses['goal']}

Provide helpful follow-up based on their message. They might be:
- Asking for clarification
- Requesting alternative paths
- Asking about specific technologies
- Wanting more details

Be helpful and offer to adjust recommendations if needed. Always be encouraging and supportive.''',
        );

      default:
        return 'I\'m here to help! What would you like to know?';
    }
  }

  /// Save conversation to file and share
  /// Allows users to keep their personalized learning path
  Future<void> _saveConversation() async {
    try {
      final StringBuffer content = StringBuffer();
      content.writeln('ProCode - AI Learning Advisor Conversation');
      content
          .writeln('Generated on: ${DateTime.now().toString().split('.')[0]}');
      content.writeln('=' * 50);
      content.writeln();

      // Format conversation for readability
      for (var message in _messages) {
        content.writeln(message.isUser ? 'You:' : 'AI Advisor:');
        content.writeln(message.text);
        content.writeln();
      }

      content.writeln('=' * 50);
      content
          .writeln('Saved from ProCode - Your AI-Powered Learning Companion');

      // Save to temporary file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'procode_ai_conversation_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(content.toString());

      // Share using system share sheet
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'ProCode AI Learning Path',
        text: 'My personalized learning path from ProCode AI Advisor',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversation saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Reset conversation to start over
  void _resetConversation() {
    setState(() {
      _messages.clear();
      _currentStep = 0;
      _userResponses.clear();
    });
    _startConversation();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('AI Learning Advisor'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          // Save button appears after meaningful conversation
          if (_messages.length > 2)
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: _saveConversation,
              tooltip: 'Save Conversation',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetConversation,
            tooltip: 'Start Over',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator shows conversation flow
          if (_currentStep < _conversationSteps.length - 1)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.surfaceVariant,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Step ${_currentStep + 1} of 4',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _getStepName(_currentStep),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 4,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingIndicator();
                }

                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Input Area
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
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
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
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
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
                      onTap: _isLoading ? null : _sendMessage,
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

  /// Build individual message bubble
  Widget _buildMessageBubble(ChatMessage message) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(
                Icons.auto_awesome,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isUser ? AppTheme.primaryGradient : null,
                color: isUser ? null : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: SelectableText(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.surfaceVariant,
              child: Icon(
                Icons.person,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build loading indicator while AI generates response
  Widget _buildLoadingIndicator() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(
              Icons.auto_awesome,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
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
        ],
      ),
    );
  }

  /// Get human-readable step name for progress indicator
  String _getStepName(int step) {
    switch (step) {
      case 0:
        return 'Understanding Your Goals';
      case 1:
        return 'Assessing Experience';
      case 2:
        return 'Time Commitment';
      case 3:
        return 'Learning Preferences';
      default:
        return 'Recommendations';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

/// Chat message model for conversation
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
