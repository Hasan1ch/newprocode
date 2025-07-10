import 'package:flutter/material.dart';
import 'package:procode/config/theme.dart';

/// Compact timer widget for displaying remaining time in quizzes
/// Shows visual warnings when time is running low
class TimerWidget extends StatelessWidget {
  final int seconds;
  final int totalSeconds;

  const TimerWidget({
    Key? key,
    required this.seconds,
    required this.totalSeconds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert seconds to MM:SS format for display
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

    // Calculate progress for circular indicator
    final progress = totalSeconds > 0 ? seconds / totalSeconds : 0.0;

    // Visual warnings at different time thresholds
    final isLowTime = seconds <= 60; // Less than 1 minute - yellow warning
    final isCriticalTime = seconds <= 30; // Less than 30 seconds - red alert

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // Dynamic background color based on remaining time
        color: isCriticalTime
            ? AppTheme.error.withOpacity(0.1)
            : isLowTime
                ? AppTheme.warning.withOpacity(0.1)
                : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        // Matching border color for emphasis
        border: Border.all(
          color: isCriticalTime
              ? AppTheme.error
              : isLowTime
                  ? AppTheme.warning
                  : AppTheme.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated progress indicator with icon
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 24,
            height: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular progress shows time remaining visually
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCriticalTime
                        ? AppTheme.error
                        : isLowTime
                            ? AppTheme.warning
                            : AppTheme.primary,
                  ),
                ),
                // Timer icon in center
                Icon(
                  Icons.timer,
                  size: 14,
                  color: isCriticalTime
                      ? AppTheme.error
                      : isLowTime
                          ? AppTheme.warning
                          : AppTheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Time display with animated color changes
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCriticalTime
                  ? AppTheme.error
                  : isLowTime
                      ? AppTheme.warning
                      : AppTheme.text,
            ),
            child: Text(timeString),
          ),
        ],
      ),
    );
  }
}

/// Full-screen countdown timer for individual questions
/// Creates urgency and helps pace quiz-taking
class QuestionTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onTimeUp;

  const QuestionTimer({
    Key? key,
    required this.seconds,
    required this.onTimeUp,
  }) : super(key: key);

  @override
  State<QuestionTimer> createState() => _QuestionTimerState();
}

class _QuestionTimerState extends State<QuestionTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Create countdown animation matching the question duration
    _controller = AnimationController(
      duration: Duration(seconds: widget.seconds),
      vsync: this,
    );

    // Animation goes from 1.0 to 0.0 as time runs out
    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear, // Linear for accurate time representation
    ));

    // Start countdown immediately
    _controller.forward();

    // Trigger callback when time runs out
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTimeUp();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate remaining seconds from animation value
        final remainingSeconds = (widget.seconds * _animation.value).ceil();
        // Show warning state in last 5 seconds
        final isLowTime = remainingSeconds <= 5;

        return Column(
          children: [
            // Large countdown number for visibility
            Text(
              remainingSeconds.toString(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isLowTime ? AppTheme.error : AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            // Circular progress indicator
            Container(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main progress circle
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isLowTime ? AppTheme.error : AppTheme.primary,
                      ),
                    ),
                  ),
                  // Warning icon appears in last 5 seconds
                  if (isLowTime)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.warning,
                        size: 40,
                        color: AppTheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
