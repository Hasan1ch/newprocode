import 'package:flutter/material.dart';
import 'package:procode/models/module_model.dart';
import 'package:procode/screens/courses/module_screen.dart';
import 'package:procode/config/app_colors.dart';

/// Expandable module card that displays course module information
/// Shows completion status, lesson count, and provides access to module content
class ModuleCard extends StatefulWidget {
  final Module module;
  final String courseId;
  final bool isCompleted;
  final int completedLessons;
  final int totalLessons;
  final bool isLocked;

  const ModuleCard({
    Key? key,
    required this.module,
    required this.courseId,
    required this.isCompleted,
    required this.completedLessons,
    required this.totalLessons,
    required this.isLocked,
  }) : super(key: key);

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Initialize smooth expansion animation for better UX
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Toggles the expanded state with smooth animation
  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress as a fraction for the progress bar
    final progress = widget.totalLessons > 0
        ? (widget.completedLessons / widget.totalLessons)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        // Visual indicators for module status through border colors
        border: Border.all(
          color: widget.isCompleted
              ? Colors.green.withOpacity(0.3)
              : widget.isLocked
                  ? Colors.grey.withOpacity(0.2)
                  : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          // Main module header - always visible
          InkWell(
            onTap: widget.isLocked ? null : _toggleExpand,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Module status icon container
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          // Different colors indicate module status
                          color: widget.isCompleted
                              ? Colors.green.withOpacity(0.2)
                              : widget.isLocked
                                  ? Colors.grey.withOpacity(0.2)
                                  : AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          // Show appropriate icon based on module state
                          child: widget.isCompleted
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                )
                              : widget.isLocked
                                  ? const Icon(
                                      Icons.lock_outline,
                                      color: Colors.grey,
                                      size: 24,
                                    )
                                  : Text(
                                      '${widget.module.orderIndex}',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Module information section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.module.title,
                              style: TextStyle(
                                // Grey out locked modules
                                color: widget.isLocked
                                    ? Colors.grey
                                    : Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Module metadata - lessons and estimated time
                            Row(
                              children: [
                                Icon(
                                  Icons.book_outlined,
                                  color: Colors.grey[400],
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.totalLessons} lessons',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.timer_outlined,
                                  color: Colors.grey[400],
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.module.estimatedMinutes} min',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Animated expand/collapse indicator
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: _isExpanded ? 0.5 : 0,
                        child: Icon(
                          Icons.expand_more,
                          color: widget.isLocked
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  // Progress tracking section for unlocked modules with progress
                  if (!widget.isLocked && progress > 0) ...[
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${widget.completedLessons}/${widget.totalLessons} completed',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Visual progress indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.isCompleted
                                  ? Colors.green
                                  : AppColors.primary,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Expandable content section with smooth animation
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Divider between header and expanded content
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[800],
                    margin: const EdgeInsets.only(bottom: 16),
                  ),
                  // Module description text
                  Text(
                    widget.module.description,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action button to view module lessons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.isLocked
                          ? null
                          : () {
                              // Navigate to module lessons screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModuleScreen(
                                    courseId: widget.courseId,
                                    module: widget.module,
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isLocked
                            ? Colors.grey[800]
                            : AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.isLocked ? 'Locked' : 'View Lessons',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
