import 'package:flutter/material.dart';
import 'package:procode/config/app_colors.dart';

/// Simple progress bar widget for displaying lesson completion status
/// Changes color to green when lesson is nearly complete (95%+)
class LessonProgressBar extends StatelessWidget {
  final double progress; // Progress value between 0.0 and 1.0

  const LessonProgressBar({
    Key? key,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        // Dark background for the progress track
        color: Colors.grey[900],
      ),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation<Color>(
          // Green color indicates lesson is complete or nearly complete
          // This provides positive reinforcement for students
          progress >= 0.95 ? Colors.green : AppColors.primary,
        ),
        minHeight: 4,
      ),
    );
  }
}
