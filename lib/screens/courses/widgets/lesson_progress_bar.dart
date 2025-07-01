import 'package:flutter/material.dart';
import 'package:procode/config/app_colors.dart';

class LessonProgressBar extends StatelessWidget {
  final double progress;

  const LessonProgressBar({
    Key? key,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[900],
      ),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation<Color>(
          progress >= 0.95 ? Colors.green : AppColors.primary,
        ),
        minHeight: 4,
      ),
    );
  }
}
