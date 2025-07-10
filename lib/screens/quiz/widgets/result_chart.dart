import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:procode/config/theme.dart';

/// Animated pie chart widget that displays quiz results
/// Shows the percentage of correct vs wrong answers with smooth animations
class ResultChart extends StatefulWidget {
  final int correctAnswers;
  final int wrongAnswers;

  const ResultChart({
    Key? key,
    required this.correctAnswers,
    required this.wrongAnswers,
  }) : super(key: key);

  @override
  State<ResultChart> createState() => _ResultChartState();
}

class _ResultChartState extends State<ResultChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Create smooth animation for pie chart entrance
    // Makes the chart feel more dynamic and engaging
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic, // Smooth acceleration and deceleration
    ));

    // Start the animation immediately when widget loads
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.correctAnswers + widget.wrongAnswers;
    // Don't render chart if no questions were answered
    if (total == 0) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                // Rebuild on touch to show interactive feedback
                setState(() {});
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 2, // Small gap between sections for clarity
            centerSpaceRadius: 50, // Creates a donut chart effect
            sections: _showingSections(),
            startDegreeOffset: -90, // Start from top instead of right
          ),
        );
      },
    );
  }

  /// Generates the pie chart sections with animations
  /// Each section represents correct or wrong answers
  List<PieChartSectionData> _showingSections() {
    final total = widget.correctAnswers + widget.wrongAnswers;
    final correctPercentage = (widget.correctAnswers / total * 100).round();
    final wrongPercentage = (widget.wrongAnswers / total * 100).round();

    return [
      // Correct answers section - always shown
      PieChartSectionData(
        color: AppTheme.success,
        value: widget.correctAnswers.toDouble() *
            _animation.value, // Animate growth
        title: _animation.value > 0.5
            ? '$correctPercentage%'
            : '', // Show % after halfway
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        // Add badge icon after animation is mostly complete
        badgeWidget: _animation.value > 0.8
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.success.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.1, // Position badge outside the chart
      ),
      // Wrong answers section - only show if there are wrong answers
      if (widget.wrongAnswers > 0)
        PieChartSectionData(
          color: AppTheme.error,
          value: widget.wrongAnswers.toDouble() * _animation.value,
          title: _animation.value > 0.5 ? '$wrongPercentage%' : '',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: _animation.value > 0.8
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.error.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                )
              : null,
          badgePositionPercentageOffset: 1.1,
        ),
    ];
  }
}

/// Line chart widget that shows quiz score progression over time
/// Helps users visualize their learning progress
class QuizProgressChart extends StatelessWidget {
  final List<double> scores;
  final List<String> dates;

  const QuizProgressChart({
    Key? key,
    required this.scores,
    required this.dates,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Don't render if no data available
    if (scores.isEmpty || dates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          // Grid configuration for better readability
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 20, // Lines every 20%
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.border,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: AppTheme.border,
                strokeWidth: 1,
              );
            },
          ),
          // Axis titles configuration
          titlesData: FlTitlesData(
            show: true,
            // Hide right and top titles for cleaner look
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            // Bottom axis shows dates
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // Only show dates that exist in our data
                  if (value.toInt() >= 0 && value.toInt() < dates.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        dates[value.toInt()],
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            // Left axis shows percentage scores
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20, // Show 0%, 20%, 40%, 60%, 80%, 100%
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          // Chart border for definition
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppTheme.border),
          ),
          // Chart bounds
          minX: 0,
          maxX: scores.length - 1.0,
          minY: 0,
          maxY: 100, // Percentage scale
          // Main line data
          lineBarsData: [
            LineChartBarData(
              // Convert score list to chart points
              spots: scores.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value);
              }).toList(),
              isCurved: true, // Smooth curve for better aesthetics
              // Gradient line for visual appeal
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.accent,
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              // Show dots at each data point
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white, // White border for contrast
                  );
                },
              ),
              // Fill area under the line with gradient
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.3),
                    AppTheme.accent.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
