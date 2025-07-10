import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/services/gemini_service.dart';
import 'package:procode/widgets/common/loading_widget.dart';
import 'package:procode/config/theme.dart';
import 'package:procode/config/app_colors.dart';
import 'package:procode/utils/app_logger.dart';

/// Debug version of AI Advisor screen with API status monitoring
/// Used for development to test Gemini AI integration and conversation flow
class AIAdvisorDebugScreen extends StatefulWidget {
  const AIAdvisorDebugScreen({super.key});

  @override
  State<AIAdvisorDebugScreen> createState() => _AIAdvisorDebugScreenState();
}

class _AIAdvisorDebugScreenState extends State<AIAdvisorDebugScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();

  // Chat state
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _apiConnected = false;
  String? _apiError;

  // Conversation flow state
  int _currentStep = 0;
  Map<String, String> _userResponses = {};

  // Define the conversation steps for personalized learning path
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
    _checkAPIStatus();
  }

  /// Check Gemini API connection status
  /// Validates API key and tests connection before starting conversation
  Future<void> _checkAPIStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if API key exists
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

      if (apiKey.isEmpty) {
        setState(() {
          _apiError = 'GEMINI_API_KEY not found in .env file';
          _apiConnected = false;
          _isLoading = false;
        });
        return;
      }

      // Test connection
      final isConnected = await _geminiService.testConnection();

      setState(() {
        _apiConnected = isConnected;
        _apiError = isConnected ? null : 'Failed to connect to Gemini API';
        _isLoading = false;
      });

      if (isConnected) {
        _startConversation();
      }
    } catch (e) {
      setState(() {
        _apiError = 'Error: $e';
        _apiConnected = false;
        _isLoading = false;
      });
    }
  }

  /// Start the AI advisor conversation
  /// Sends initial greeting and explains the process
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

  /// Add message to chat and scroll to bottom
  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  /// Auto-scroll to latest message
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

  /// Handle user message submission
  /// Processes user input and generates appropriate AI response
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
      // Get AI response based on current conversation step
      String aiResponse = await _getAIResponse(text);

      _addMessage(ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      // Move to next step if not at recommendations
      if (_currentStep < _conversationSteps.length - 1) {
        _currentStep++;
      }
    } catch (e) {
      AppLogger.error('Error sending message', error: e);
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

  /// Generate AI response based on conversation step
  /// Each step has specific prompts to guide the conversation
  Future<String> _getAIResponse(String userInput) async {
    switch (_conversationSteps[_currentStep]) {
      case 'goal':
        // First step: Understand user's programming goals
        return await _geminiService.getChatResponse(
          message: userInput,
          systemPrompt:
              '''You are a friendly AI Learning Advisor for ProCode app. The user wants to: "$userInput".

Respond warmly and ask about their programming experience. Be conversational, like texting a helpful friend.

Example response style:
"That's awesome! Game development is such an exciting field! 🎮 

I'd love to know more about your programming background:
• Have you written any code before?
• Do you know any programming languages?
• Would you say you're a complete beginner, or do you have some experience?"

Keep it short, friendly, and use emojis sparingly. Max 100 words.''',
        );

      case 'experience':
        // Second step: Assess experience level
        return await _geminiService.getChatResponse(
          message: userInput,
          systemPrompt: '''Goal: ${_userResponses['goal']}
Experience: "$userInput"

Acknowledge their experience warmly and ask about time commitment. Be encouraging and conversational.

Example style:
"Perfect! [Comment on their experience level positively]

Let's figure out a schedule that works for you:
• How many hours per week can you dedicate to learning?
• Do you prefer intensive study or steady progress?
• Any deadline for your goals?"

Keep it friendly and under 100 words.''',
        );

      case 'time':
        // Third step: Understand time availability
        return await _geminiService.getChatResponse(
          message: userInput,
          systemPrompt: '''Goal: ${_userResponses['goal']}
Experience: ${_userResponses['experience']}
Time: "$userInput"

Great! Last question - ask about their interests and learning style. Keep it simple and friendly.

Example style:
"[Positive comment about their time commitment]

One more thing - what excites you most?
• Any specific type of projects you'd love to build?
• Do you prefer learning theory first or jumping into coding?
• Any particular tech/tools you're curious about?"

Max 80 words, conversational tone.''',
        );

      case 'interests':
        // Fourth step: Generate personalized recommendations
        return await _geminiService.getChatResponse(
          message: userInput,
          systemPrompt: '''Based on the conversation:
Goal: ${_userResponses['goal']}
Experience: ${_userResponses['experience']}
Time: ${_userResponses['time']}
Interests: "$userInput"

Create a personalized learning path. Format your response like this:

🎯 **Your Learning Path**
Write a brief 2-3 sentence overview of their personalized journey.

📚 **Recommended Courses** (list 4-5 courses in order)

**1. [Course Name]**
→ What you'll learn: [Brief description]
→ Duration: [X weeks] | Level: [Beginner/Intermediate/Advanced]

**2. [Course Name]**
→ What you'll learn: [Brief description]
→ Duration: [X weeks] | Level: [Beginner/Intermediate/Advanced]

(Continue for all courses...)

📅 **Your Weekly Schedule**
Based on ${_userResponses['time']}, here's how to organize your week:
• Monday/Wednesday/Friday: [Specific activity]
• Tuesday/Thursday: [Specific activity]
• Weekend: [Specific activity]

🚀 **Start This Week**
• Day 1-2: [Specific action]
• Day 3-4: [Specific action]
• Day 5-7: [Specific action]

💡 **Tips for Success**
• [Practical tip 1]
• [Practical tip 2]
• [Practical tip 3]

Keep the language friendly, encouraging, and easy to read. NO TABLES.''',
        );

      case 'recommendations':
        // Follow-up: Handle questions about recommendations
        return await _geminiService.getChatResponse(
          message: userInput,
          systemPrompt: '''The user is responding to your recommendations. 
Their goal was: ${_userResponses['goal']}

Provide a helpful follow-up. They might be asking for clarification or alternatives.
Be supportive and offer to adjust recommendations if needed.
Keep response conversational and under 150 words.''',
        );

      default:
        return 'I\'m here to help! What would you like to know?';
    }
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _messages.clear();
                _currentStep = 0;
                _userResponses.clear();
              });
              _checkAPIStatus();
            },
            tooltip: 'Restart',
          ),
        ],
      ),
      body: Column(
        children: [
          // API Status Bar - Shows connection status for debugging
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _apiConnected
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: _apiConnected ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _apiConnected ? Icons.check_circle : Icons.error,
                  color: _apiConnected ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _apiConnected
                        ? 'Gemini API Connected'
                        : _apiError ?? 'API Disconnected',
                    style: TextStyle(
                      color: _apiConnected ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (!_apiConnected)
                  TextButton(
                    onPressed: _checkAPIStatus,
                    child: const Text('Retry'),
                  ),
              ],
            ),
          ),

          // Progress Indicator - Shows conversation progress
          if (_currentStep < _conversationSteps.length - 1 && _apiConnected)
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

          // Chat Messages or Loading
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const Center(child: LoadingWidget())
                : ListView.builder(
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
          if (_apiConnected)
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

  /// Build message bubble for chat display
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

  /// Build loading indicator for AI response
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

  /// Get human-readable step name
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

/// Simple chat message model
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
