import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:procode/models/question_model.dart';
import 'package:procode/config/app_colors.dart';
import 'package:procode/widgets/animations/fade_animation.dart';

/// Main widget that renders different types of quiz questions
/// This is the core component of our quiz system that dynamically
/// adapts its UI based on the question type
class QuestionWidget extends StatelessWidget {
  final Question question;
  final String? selectedAnswer;
  final bool isAnswerLocked;
  final Function(String) onAnswerSelected;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.isAnswerLocked,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamically render the appropriate UI based on question type
    // This allows us to support multiple question formats in our learning platform
    switch (question.type) {
      case 'mcq':
        return _buildMultipleChoice(context);
      case 'boolean':
        return _buildTrueFalse(context);
      case 'code_output':
        return _buildCodeOutput(context);
      case 'fill_code':
        return _buildFillCode(context);
      case 'debug':
        return _buildDebugCode(context);
      default:
        // Fallback to MCQ if unknown type to prevent crashes
        return _buildMultipleChoice(context);
    }
  }

  /// Builds the standard multiple choice question layout
  /// Most common question type in our programming quizzes
  Widget _buildMultipleChoice(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionHeader(context),

        // Only show code snippet if the question includes one
        // Many programming questions need code examples
        if (question.codeSnippet != null &&
            question.codeSnippet!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildCodeSnippet(context),
        ],

        const SizedBox(height: 24),
        // Generate option cards with staggered fade animation
        // Creates a smooth, professional presentation effect
        ...question.options!.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return FadeAnimation(
            delay: index * 0.1, // Stagger animations by 100ms
            child: _buildOptionCard(
              context,
              option,
              String.fromCharCode(65 + index), // Convert to A, B, C, D...
            ),
          );
        }),
      ],
    );
  }

  /// Builds the True/False question layout with large touch targets
  /// Simplified UI for binary choices makes it easier for users
  Widget _buildTrueFalse(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionHeader(context),

        // Display code snippet if present
        if (question.codeSnippet != null &&
            question.codeSnippet!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildCodeSnippet(context),
        ],

        const SizedBox(height: 32),
        // Side-by-side True/False buttons for better UX
        Row(
          children: [
            Expanded(
              child: FadeAnimation(
                child: _buildTrueFalseOption(context, 'True', true),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FadeAnimation(
                delay: 0.1,
                child: _buildTrueFalseOption(context, 'False', false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the code output prediction question
  /// Tests students' ability to mentally execute code
  Widget _buildCodeOutput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionHeader(context),
        const SizedBox(height: 16),
        if (question.codeSnippet != null) ...[
          _buildCodeSnippet(context),
          const SizedBox(height: 24),
        ],
        // Use monospace font for code output options
        ...question.options!.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return FadeAnimation(
            delay: index * 0.1,
            child: _buildCodeOptionCard(context, option),
          );
        }),
      ],
    );
  }

  /// Builds the fill-in-the-blank code question
  /// Students complete missing parts of code snippets
  Widget _buildFillCode(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionHeader(context),
        const SizedBox(height: 16),
        if (question.codeSnippet != null) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instruction text to guide the user
              const Text(
                'Complete the code:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 8),
              _buildCodeSnippet(context),
            ],
          ),
          const SizedBox(height: 24),
        ],
        // Options displayed with monospace font for code consistency
        ...question.options!.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return FadeAnimation(
            delay: index * 0.1,
            child: _buildCodeOptionCard(context, option),
          );
        }),
      ],
    );
  }

  /// Builds the debug question layout
  /// Challenges students to identify errors in code
  Widget _buildDebugCode(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionHeader(context),
        const SizedBox(height: 16),
        if (question.codeSnippet != null) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual indicator that this code has bugs
              Row(
                children: [
                  const Icon(
                    Icons.bug_report,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Debug this code:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Show code with error highlighting
              _buildCodeSnippet(context, showError: true),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'What\'s the issue?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Present possible bug explanations as options
        ...question.options!.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return FadeAnimation(
            delay: index * 0.1,
            child: _buildOptionCard(
              context,
              option,
              String.fromCharCode(65 + index),
            ),
          );
        }),
      ],
    );
  }

  /// Creates a styled code snippet container with line numbers
  /// Line numbers help during presentations and error discussions
  Widget _buildCodeSnippet(BuildContext context, {bool showError = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeBgColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: codeBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              showError ? AppColors.error.withOpacity(0.5) : AppColors.divider,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add line numbers for better readability
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line number column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: question.codeSnippet!
                      .split('\n')
                      .asMap()
                      .entries
                      .map((entry) {
                    return Text(
                      '${entry.key + 1}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: AppColors.textGrey,
                        height: 1.5,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 16),
                // Code content - selectable for easy copying
                SelectableText(
                  question.codeSnippet!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: textColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the question header with difficulty badge and question text
  /// Difficulty badges help users gauge question complexity
  Widget _buildQuestionHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final codeBgColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Difficulty indicator with color coding
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getDifficultyColor(question.difficulty).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            question.difficulty.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getDifficultyColor(question.difficulty),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Support markdown formatting for rich question content
        if (question.question.contains('```'))
          MarkdownBody(
            data: question.question,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 18,
                color: textColor,
                height: 1.5,
              ),
              code: TextStyle(
                backgroundColor: codeBgColor,
                fontFamily: 'monospace',
                color: AppColors.primary,
              ),
              codeblockDecoration: BoxDecoration(
                color: codeBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
            ),
          )
        else
          Text(
            question.question,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.5,
            ),
          ),
      ],
    );
  }

  /// Creates an option card for multiple choice questions
  /// Visual feedback shows selection state and correct/wrong answers
  Widget _buildOptionCard(BuildContext context, String option, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    final isSelected = selectedAnswer == option;
    final isCorrect = isAnswerLocked && option == question.correctAnswer;
    final isWrong =
        isAnswerLocked && isSelected && option != question.correctAnswer;

    return GestureDetector(
      onTap: isAnswerLocked ? null : () => onAnswerSelected(option),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Dynamic background colors for visual feedback
          color: isCorrect
              ? AppColors.success.withOpacity(0.1)
              : isWrong
                  ? AppColors.error.withOpacity(0.1)
                  : isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // Highlight correct/wrong answers after submission
            color: isCorrect
                ? AppColors.success
                : isWrong
                    ? AppColors.error
                    : isSelected
                        ? AppColors.primary
                        : AppColors.divider,
            width: isSelected || isCorrect || isWrong ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Option indicator with dynamic icons for feedback
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCorrect
                    ? AppColors.success
                    : isWrong
                        ? AppColors.error
                        : isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCorrect
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      )
                    : isWrong
                        ? const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          )
                        : Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates an option card specifically for code-related answers
  /// Uses monospace font for better code readability
  Widget _buildCodeOptionCard(BuildContext context, String option) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeBgColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    final isSelected = selectedAnswer == option;
    final isCorrect = isAnswerLocked && option == question.correctAnswer;
    final isWrong =
        isAnswerLocked && isSelected && option != question.correctAnswer;

    return GestureDetector(
      onTap: isAnswerLocked ? null : () => onAnswerSelected(option),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCorrect
              ? AppColors.success.withOpacity(0.1)
              : isWrong
                  ? AppColors.error.withOpacity(0.1)
                  : isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : codeBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCorrect
                ? AppColors.success
                : isWrong
                    ? AppColors.error
                    : isSelected
                        ? AppColors.primary
                        : AppColors.divider,
            width: isSelected || isCorrect || isWrong ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button style indicators for code options
            if (isCorrect)
              const Icon(Icons.check_circle, color: AppColors.success, size: 20)
            else if (isWrong)
              const Icon(Icons.cancel, color: AppColors.error, size: 20)
            else if (isSelected)
              const Icon(Icons.radio_button_checked,
                  color: AppColors.primary, size: 20)
            else
              const Icon(Icons.radio_button_unchecked,
                  color: AppColors.divider, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace', // Code font for consistency
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds large, touch-friendly True/False option buttons
  /// Design makes it easy to tap on mobile devices
  Widget _buildTrueFalseOption(BuildContext context, String label, bool value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    // IMPORTANT: Use capitalized string values to match database format
    // This ensures proper answer checking against stored correct answers
    final optionValue = value ? "True" : "False";
    final isSelected = selectedAnswer == optionValue;
    final isCorrect = isAnswerLocked && optionValue == question.correctAnswer;
    final isWrong =
        isAnswerLocked && isSelected && optionValue != question.correctAnswer;

    return GestureDetector(
      onTap: isAnswerLocked ? null : () => onAnswerSelected(optionValue),
      child: Container(
        height: 120, // Large touch target for better UX
        decoration: BoxDecoration(
          color: isCorrect
              ? AppColors.success.withOpacity(0.1)
              : isWrong
                  ? AppColors.error.withOpacity(0.1)
                  : isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCorrect
                ? AppColors.success
                : isWrong
                    ? AppColors.error
                    : isSelected
                        ? AppColors.primary
                        : AppColors.divider,
            width: isSelected || isCorrect || isWrong ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large icons for clear visual distinction
            Icon(
              value ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 48,
              color: isCorrect
                  ? AppColors.success
                  : isWrong
                      ? AppColors.error
                      : isSelected
                          ? AppColors.primary
                          : AppColors.textGrey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCorrect
                    ? AppColors.success
                    : isWrong
                        ? AppColors.error
                        : isSelected
                            ? AppColors.primary
                            : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Maps difficulty strings to appropriate colors
  /// Visual color coding helps users quickly identify question difficulty
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success; // Green for easy
      case 'medium':
        return AppColors.warning; // Orange for medium
      case 'hard':
        return AppColors.error; // Red for hard
      default:
        return AppColors.primary; // Default color
    }
  }
}
