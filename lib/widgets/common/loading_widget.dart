import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Different loading animation styles
enum LoadingType { circular, linear, shimmer, dots, custom }

/// Predefined sizes for loading indicators
enum LoadingSize { small, medium, large }

/// Versatile loading widget supporting multiple animation styles
/// This provides consistent loading states throughout ProCode
/// Supports circular, linear, shimmer, and custom animations
class LoadingWidget extends StatelessWidget {
  final LoadingType type;
  final LoadingSize size;
  final String? message;
  final Color? color;
  final double? value; // For determinate progress
  final Widget? customLoader;

  const LoadingWidget({
    Key? key,
    this.type = LoadingType.circular,
    this.size = LoadingSize.medium,
    this.message,
    this.color,
    this.value,
    this.customLoader,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loaderColor = color ?? theme.colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoader(context, loaderColor),
          // Optional loading message
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the appropriate loader based on type
  Widget _buildLoader(BuildContext context, Color loaderColor) {
    switch (type) {
      case LoadingType.circular:
        return _buildCircularLoader(loaderColor);
      case LoadingType.linear:
        return _buildLinearLoader(loaderColor);
      case LoadingType.shimmer:
        return _buildShimmerLoader(context);
      case LoadingType.dots:
        return _buildDotsLoader(loaderColor);
      case LoadingType.custom:
        return customLoader ?? _buildCircularLoader(loaderColor);
    }
  }

  /// Standard circular progress indicator
  Widget _buildCircularLoader(Color color) {
    return SizedBox(
      width: _getLoaderSize(),
      height: _getLoaderSize(),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        value: value, // null for indeterminate
        strokeWidth: _getStrokeWidth(),
      ),
    );
  }

  /// Linear progress bar
  Widget _buildLinearLoader(Color color) {
    return SizedBox(
      width: _getLinearLoaderWidth(),
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        value: value,
        minHeight: _getLinearLoaderHeight(),
      ),
    );
  }

  /// Shimmer effect for skeleton loading
  Widget _buildShimmerLoader(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surface,
      highlightColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
      child: Container(
        width: _getLoaderSize(),
        height: _getLoaderSize(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Animated dots loader (placeholder implementation)
  /// TODO: Implement actual dots animation
  Widget _buildDotsLoader(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _DotAnimation(index),
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _getDotSize(),
              height: _getDotSize(),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  /// Returns size based on LoadingSize
  double _getLoaderSize() {
    switch (size) {
      case LoadingSize.small:
        return 24;
      case LoadingSize.medium:
        return 36;
      case LoadingSize.large:
        return 48;
    }
  }

  /// Returns stroke width for circular loader
  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 3;
      case LoadingSize.large:
        return 4;
    }
  }

  /// Returns width for linear loader
  double _getLinearLoaderWidth() {
    switch (size) {
      case LoadingSize.small:
        return 120;
      case LoadingSize.medium:
        return 200;
      case LoadingSize.large:
        return 280;
    }
  }

  /// Returns height for linear loader
  double _getLinearLoaderHeight() {
    switch (size) {
      case LoadingSize.small:
        return 2;
      case LoadingSize.medium:
        return 4;
      case LoadingSize.large:
        return 6;
    }
  }

  /// Returns size for dot loader
  double _getDotSize() {
    switch (size) {
      case LoadingSize.small:
        return 8;
      case LoadingSize.medium:
        return 12;
      case LoadingSize.large:
        return 16;
    }
  }
}

/// Placeholder animation class for dots loader
/// TODO: Implement actual animation logic
class _DotAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  final int index;
  _DotAnimation(this.index);

  @override
  Animation<double> get parent => AlwaysStoppedAnimation(0);

  @override
  double get value => 0;
}

/// Full-page loading screen
/// Used during initial data loading or navigation
class PageLoadingWidget extends StatelessWidget {
  final String? message;

  const PageLoadingWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingWidget(
        type: LoadingType.circular,
        size: LoadingSize.large,
        message: message ?? 'Loading...',
      ),
    );
  }
}

/// Loading overlay that can be placed over existing content
/// Useful for form submissions or async operations
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.message,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        // Show overlay only when loading
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: LoadingWidget(
              type: LoadingType.circular,
              size: LoadingSize.medium,
              message: message,
              color: Colors.white, // White loader on dark overlay
            ),
          ),
      ],
    );
  }
}

// Shimmer Loading Widgets for skeleton screens

/// Shimmer list for loading state of list views
/// Creates realistic skeleton loading effect
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const ShimmerList({
    Key? key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerListItem(height: itemHeight);
      },
    );
  }
}

/// Individual shimmer list item
/// Mimics typical list item layout
class ShimmerListItem extends StatelessWidget {
  final double height;

  const ShimmerListItem({Key? key, this.height = 80}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar placeholder
            Container(
              width: height,
              height: height,
              color: Colors.white,
            ),
            const SizedBox(width: 16),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer grid for loading state of grid views
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const ShimmerGrid({
    Key? key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const ShimmerGridItem();
      },
    );
  }
}

/// Individual shimmer grid item
class ShimmerGridItem extends StatelessWidget {
  const ShimmerGridItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Custom circular progress with percentage display
/// Used for showing download or upload progress
class CustomCircularProgress extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final double value; // 0.0 to 1.0
  final Widget? child;

  const CustomCircularProgress({
    Key? key,
    this.size = 100,
    this.strokeWidth = 8,
    this.color,
    required this.value,
    this.child,
  }) : super(key: key);

  @override
  State<CustomCircularProgress> createState() => _CustomCircularProgressState();
}

class _CustomCircularProgressState extends State<CustomCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(CustomCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      // Animate from current value to new value
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CircularProgressPainter(
            value: _animation.value,
            color: progressColor,
            strokeWidth: widget.strokeWidth,
          ),
          child: Center(
            // Show percentage or custom child
            child: widget.child ??
                Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        );
      },
    );
  }
}

/// Custom painter for circular progress
class _CircularProgressPainter extends CustomPainter {
  final double value;
  final Color color;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.value,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Rounded ends

    // Start from top (-90 degrees)
    final startAngle = -90 * (3.14159 / 180);
    final sweepAngle = 360 * value * (3.14159 / 180);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
