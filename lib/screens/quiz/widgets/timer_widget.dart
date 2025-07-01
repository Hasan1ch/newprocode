import 'package:flutter/material.dart';
import 'package:procode/config/theme.dart';

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
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

    final progress = totalSeconds > 0 ? seconds / totalSeconds : 0.0;
    final isLowTime = seconds <= 60; // Less than 1 minute
    final isCriticalTime = seconds <= 30; // Less than 30 seconds

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCriticalTime
            ? AppTheme.error.withOpacity(0.1)
            : isLowTime
                ? AppTheme.warning.withOpacity(0.1)
                : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 24,
            height: 24,
            child: Stack(
              alignment: Alignment.center,
              children: [
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
    _controller = AnimationController(
      duration: Duration(seconds: widget.seconds),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _controller.forward();
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
        final remainingSeconds = (widget.seconds * _animation.value).ceil();
        final isLowTime = remainingSeconds <= 5;

        return Column(
          children: [
            Text(
              remainingSeconds.toString(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isLowTime ? AppTheme.error : AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
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
