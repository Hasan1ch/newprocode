import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:procode/config/theme.dart';
import 'package:intl/intl.dart';

// Define ChatMessage class here
/// Model representing a single chat message
/// Used throughout AI advisor screens for conversation display
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

/// Reusable chat bubble widget for AI conversations
/// Displays messages with different styles for user/AI and includes action buttons
class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLoading;

  const ChatBubble({
    super.key,
    required this.message,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Show loading indicator for pending AI responses
    if (isLoading) {
      return _buildLoadingBubble(context);
    }

    return Padding(
      padding: EdgeInsets.only(
        left: message.isUser ? 48 : 0,
        right: message.isUser ? 0 : 48,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar on the left
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Message bubble
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // User messages get gradient, AI messages get surface color
                    gradient: message.isUser ? AppTheme.primaryGradient : null,
                    color: !message.isUser
                        ? (message.isError
                            ? theme.colorScheme.errorContainer
                            : theme.colorScheme.surfaceContainerHighest)
                        : null,
                    // Different corner radius for sender/receiver
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message text - selectable for copying
                      SelectableText(
                        message.text,
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.white
                              : (message.isError
                                  ? theme.colorScheme.onErrorContainer
                                  : theme.colorScheme.onSurface),
                          fontSize: 15,
                        ),
                      ),
                      // Action buttons for AI messages
                      if (!message.isUser && !message.isError) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActionButton(
                              icon: Icons.copy_outlined,
                              tooltip: 'Copy',
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: message.text),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied to clipboard'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _ActionButton(
                              icon: Icons.thumb_up_outlined,
                              tooltip: 'Helpful',
                              onTap: () {
                                // Track helpful responses for AI improvement
                              },
                            ),
                            const SizedBox(width: 8),
                            _ActionButton(
                              icon: Icons.thumb_down_outlined,
                              tooltip: 'Not helpful',
                              onTap: () {
                                // Track unhelpful responses for AI improvement
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Timestamp display
                if (message.timestamp != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp!),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // User avatar on the right
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build loading indicator while AI is thinking
  Widget _buildLoadingBubble(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 48, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                  'Thinking...',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small action button for message interactions
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              icon,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
