import 'package:flutter/material.dart';

/// Enum for slide animation directions
/// Makes the API more intuitive than using Offset values
enum SlideDirection { left, right, up, down }

/// Slide animation widget that combines slide and fade effects
/// Creates smooth entrance animations for UI elements
/// More visually appealing than simple fade-ins
class SlideAnimation extends StatefulWidget {
  final Widget child;
  final double delay; // Delay before animation starts (seconds)
  final Duration duration; // Animation duration
  final Curve curve; // Easing curve for natural motion
  final SlideDirection direction; // Where the widget slides from
  final double offset; // How far to slide (in pixels)

  const SlideAnimation({
    Key? key,
    required this.child,
    this.delay = 0.0,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic, // Smooth deceleration
    this.direction = SlideDirection.left,
    this.offset = 30.0, // Subtle slide distance
  }) : super(key: key);

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Single controller for both animations
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Calculate starting position based on direction
    final beginOffset = _getBeginOffset();

    // Slide animation from offset to center
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero, // Final position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Simultaneous fade for smoother appearance
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Handle delayed start
    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  /// Converts direction enum to normalized offset
  /// Normalized to percentage for responsive behavior
  Offset _getBeginOffset() {
    final normalizedOffset = widget.offset / 100;
    switch (widget.direction) {
      case SlideDirection.left:
        return Offset(-normalizedOffset, 0); // Start from left
      case SlideDirection.right:
        return Offset(normalizedOffset, 0); // Start from right
      case SlideDirection.up:
        return Offset(0, -normalizedOffset); // Start from top
      case SlideDirection.down:
        return Offset(0, normalizedOffset); // Start from bottom
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Creates staggered slide animations for lists of widgets
/// Each item slides in with a slight delay after the previous
/// Creates an elegant cascade effect for lists and grids
class StaggeredSlideAnimation extends StatefulWidget {
  final List<Widget> children;
  final double delayIncrement; // Delay between each item
  final Duration duration;
  final Curve curve;
  final SlideDirection direction;
  final double offset;
  final Axis axis; // Layout direction
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const StaggeredSlideAnimation({
    Key? key,
    required this.children,
    this.delayIncrement = 0.1, // 100ms stagger
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    this.direction = SlideDirection.left,
    this.offset = 30.0,
    this.axis = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  State<StaggeredSlideAnimation> createState() =>
      _StaggeredSlideAnimationState();
}

class _StaggeredSlideAnimationState extends State<StaggeredSlideAnimation> {
  @override
  Widget build(BuildContext context) {
    // Apply slide animation to each child with increasing delay
    final animatedChildren = widget.children.asMap().entries.map((entry) {
      return SlideAnimation(
        delay: entry.key * widget.delayIncrement, // Stagger by index
        duration: widget.duration,
        curve: widget.curve,
        direction: widget.direction,
        offset: widget.offset,
        child: entry.value,
      );
    }).toList();

    // Layout based on specified axis
    if (widget.axis == Axis.vertical) {
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

/// Playful bounce slide animation for special UI elements
/// Uses bounce curve for a fun, energetic entrance
/// Great for achievement popups or celebration moments
class BounceSlideAnimation extends StatefulWidget {
  final Widget child;
  final double delay;
  final Duration duration;
  final SlideDirection direction;

  const BounceSlideAnimation({
    Key? key,
    required this.child,
    this.delay = 0.0,
    this.duration =
        const Duration(milliseconds: 800), // Longer for bounce effect
    this.direction = SlideDirection.up,
  }) : super(key: key);

  @override
  State<BounceSlideAnimation> createState() => _BounceSlideAnimationState();
}

class _BounceSlideAnimationState extends State<BounceSlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final beginOffset = _getBeginOffset();

    // Bounce curve creates playful overshoot effect
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut, // Bouncy entrance
    ));

    // Fade in quickly during first half of animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Handle delayed start
    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  /// Full screen width/height offset for dramatic entrance
  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideDirection.left:
        return const Offset(-1.0, 0); // Full width from left
      case SlideDirection.right:
        return const Offset(1.0, 0); // Full width from right
      case SlideDirection.up:
        return const Offset(0, -1.0); // Full height from top
      case SlideDirection.down:
        return const Offset(0, 1.0); // Full height from bottom
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}
