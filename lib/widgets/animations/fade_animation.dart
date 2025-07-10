import 'package:flutter/material.dart';

/// Simple fade-in animation widget for smooth content appearance
/// Used throughout the app to make UI elements appear gracefully
/// Supports delayed animations for staggered effects
class FadeAnimation extends StatefulWidget {
  final Widget child;
  final double delay; // Delay in seconds before animation starts
  final Duration duration; // How long the fade takes
  final Curve curve; // Animation easing curve

  const FadeAnimation({
    Key? key,
    required this.child,
    this.delay = 0.0,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Create opacity animation from 0 to 1
    _animation = Tween<double>(
      begin: 0.0, // Fully transparent
      end: 1.0, // Fully opaque
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Handle delayed start if specified
    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
        // Check if widget is still mounted before starting
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      // Start immediately if no delay
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

/// Creates staggered fade animations for multiple widgets
/// Perfect for lists and grids where items should appear sequentially
/// Creates a cascading effect that guides the user's eye
class StaggeredFadeAnimation extends StatefulWidget {
  final List<Widget> children;
  final double delayIncrement; // Delay between each child
  final Duration duration;
  final Curve curve;
  final Axis direction; // Layout direction (vertical/horizontal)
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const StaggeredFadeAnimation({
    Key? key,
    required this.children,
    this.delayIncrement = 0.1, // 100ms between each item
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  State<StaggeredFadeAnimation> createState() => _StaggeredFadeAnimationState();
}

class _StaggeredFadeAnimationState extends State<StaggeredFadeAnimation> {
  @override
  Widget build(BuildContext context) {
    // Wrap each child with FadeAnimation, increasing delay for each
    final animatedChildren = widget.children.asMap().entries.map((entry) {
      return FadeAnimation(
        delay: entry.key * widget.delayIncrement, // Stagger based on index
        duration: widget.duration,
        curve: widget.curve,
        child: entry.value,
      );
    }).toList();

    // Return appropriate layout based on direction
    if (widget.direction == Axis.vertical) {
      return Column(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        children: animatedChildren,
      );
    } else {
      return Row(
        mainAxisAlignment: widget.mainAxisAlignment,
        crossAxisAlignment: widget.crossAxisAlignment,
        children: animatedChildren,
      );
    }
  }
}

/// Continuous pulsing fade animation for attention-grabbing elements
/// Used for CTAs, notifications, or important UI elements
/// Creates a breathing effect that draws user attention
class PulseFadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity; // Lowest opacity in pulse
  final double maxOpacity; // Highest opacity in pulse

  const PulseFadeAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.minOpacity = 0.5,
    this.maxOpacity = 1.0,
  }) : super(key: key);

  @override
  State<PulseFadeAnimation> createState() => _PulseFadeAnimationState();
}

class _PulseFadeAnimationState extends State<PulseFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Create repeating animation controller
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Animate between min and max opacity
    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Smooth breathing effect
    ));

    // Repeat forever with reverse (fade in and out)
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
