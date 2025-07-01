import 'package:flutter/material.dart';

enum SlideDirection { left, right, up, down }

class SlideAnimation extends StatefulWidget {
  final Widget child;
  final double delay;
  final Duration duration;
  final Curve curve;
  final SlideDirection direction;
  final double offset;

  const SlideAnimation({
    Key? key,
    required this.child,
    this.delay = 0.0,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    this.direction = SlideDirection.left,
    this.offset = 30.0,
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
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    final beginOffset = _getBeginOffset();

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

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

  Offset _getBeginOffset() {
    final normalizedOffset = widget.offset / 100;
    switch (widget.direction) {
      case SlideDirection.left:
        return Offset(-normalizedOffset, 0);
      case SlideDirection.right:
        return Offset(normalizedOffset, 0);
      case SlideDirection.up:
        return Offset(0, -normalizedOffset);
      case SlideDirection.down:
        return Offset(0, normalizedOffset);
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

class StaggeredSlideAnimation extends StatefulWidget {
  final List<Widget> children;
  final double delayIncrement;
  final Duration duration;
  final Curve curve;
  final SlideDirection direction;
  final double offset;
  final Axis axis;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const StaggeredSlideAnimation({
    Key? key,
    required this.children,
    this.delayIncrement = 0.1,
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
    final animatedChildren = widget.children.asMap().entries.map((entry) {
      return SlideAnimation(
        delay: entry.key * widget.delayIncrement,
        duration: widget.duration,
        curve: widget.curve,
        direction: widget.direction,
        offset: widget.offset,
        child: entry.value,
      );
    }).toList();

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

class BounceSlideAnimation extends StatefulWidget {
  final Widget child;
  final double delay;
  final Duration duration;
  final SlideDirection direction;

  const BounceSlideAnimation({
    Key? key,
    required this.child,
    this.delay = 0.0,
    this.duration = const Duration(milliseconds: 800),
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

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

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

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideDirection.left:
        return const Offset(-1.0, 0);
      case SlideDirection.right:
        return const Offset(1.0, 0);
      case SlideDirection.up:
        return const Offset(0, -1.0);
      case SlideDirection.down:
        return const Offset(0, 1.0);
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
