import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:procode/models/question_model.dart';
import 'package:procode/config/app_colors.dart';
import 'package:procode/widgets/animations/fade_animation.dart';

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
        return _buildMultipleChoice(context);
    }
  }

  Widget _buildMultipleChoice(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionHeader(context),
        const SizedBox(height: 24),
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

  Widget _buildTrueFalse(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionHeader(context),
        const SizedBox(height: 32),
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

  Widget _buildCodeOutput(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeBgColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionHeader(context),
        const SizedBox(height: 16),
        if (question.codeSnippet != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: codeBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                question.codeSnippet!,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'What will be the output?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
        ],
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

  Widget _buildFillCode(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeBgColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionHeader(context),
        const SizedBox(height: 16),
        if (question.codeSnippet != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: codeBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete the code:',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    question.codeSnippet!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
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

  Widget _buildDebugCode(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeBgColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildQuestionHeader(context),
        const SizedBox(height: 16),
        if (question.codeSnippet != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: codeBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    question.codeSnippet!,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildQuestionHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final codeBgColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Difficulty badge instead of category
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                _getDifficultyColor(question.difficulty).withValues(alpha: 0.1),
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
          color: isCorrect
              ? AppColors.success.withValues(alpha: 0.1)
              : isWrong
                  ? AppColors.error.withValues(alpha: 0.1)
                  : isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : surfaceColor,
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
              ? AppColors.success.withValues(alpha: 0.1)
              : isWrong
                  ? AppColors.error.withValues(alpha: 0.1)
                  : isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
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
                  fontFamily: 'monospace',
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrueFalseOption(BuildContext context, String label, bool value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;

    final optionValue = value.toString();
    final isSelected = selectedAnswer == optionValue;
    final isCorrect = isAnswerLocked && optionValue == question.correctAnswer;
    final isWrong =
        isAnswerLocked && isSelected && optionValue != question.correctAnswer;

    return GestureDetector(
      onTap: isAnswerLocked ? null : () => onAnswerSelected(optionValue),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isCorrect
              ? AppColors.success.withValues(alpha: 0.1)
              : isWrong
                  ? AppColors.error.withValues(alpha: 0.1)
                  : isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppColors.success;
      case 'medium':
        return AppColors.warning;
      case 'hard':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}
