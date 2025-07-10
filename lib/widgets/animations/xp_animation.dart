import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated XP gain notification with particle effects
/// Creates a rewarding visual feedback when users earn experience points
/// The particle system adds excitement to the gamification experience
class XPAnimation extends StatefulWidget {
  final int xp;
  final VoidCallback? onComplete;

  const XPAnimation({
    Key? key,
    required this.xp,
    this.onComplete,
  }) : super(key: key);

  @override
  State<XPAnimation> createState() => _XPAnimationState();
}

class _XPAnimationState extends State<XPAnimation>
    with TickerProviderStateMixin {
  // Multiple controllers for complex animation choreography
  late AnimationController _floatController; // Upward movement
  late AnimationController _fadeController; // Fade out
  late AnimationController _scaleController; // Initial pop-in
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Particle system for celebratory effect
  final List<Particle> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Float animation - makes XP text rise upward
    _floatController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // Fade animation - gradually disappears
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    // Scale animation - elastic entrance
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    // Configure float to move upward
    _floatAnimation = Tween<double>(
      begin: 0,
      end: -100, // Move up 100 pixels
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeOut, // Decelerate as it rises
    ));

    // Fade out during last 30% of animation
    _fadeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Interval(0.7, 1.0, curve: Curves.easeIn),
    ));

    // Bouncy scale entrance
    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut, // Bouncy effect
    ));

    // Generate particle burst
    _generateParticles();

    // Start animation sequence
    _scaleController.forward();
    _floatController.forward();
    _fadeController.forward().then((_) {
      // Notify completion after animations finish
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  /// Creates random particles for explosion effect
  /// Each particle has random properties for variety
  void _generateParticles() {
    for (int i = 0; i < 10; i++) {
      _particles.add(Particle(
        x: _random.nextDouble() * 100 - 50, // Random X position
        y: _random.nextDouble() * 100 - 50, // Random Y position
        size: _random.nextDouble() * 4 + 2, // Size between 2-6
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
        speed: _random.nextDouble() * 2 + 1, // Speed multiplier
      ));
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Center on screen
      top: MediaQuery.of(context).size.height / 2,
      left: MediaQuery.of(context).size.width / 2,
      child: AnimatedBuilder(
        // Listen to all animations
        animation: Listenable.merge([
          _floatAnimation,
          _fadeAnimation,
          _scaleAnimation,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value), // Float upward
            child: Opacity(
              opacity: _fadeAnimation.value, // Fade out
              child: Transform.scale(
                scale: _scaleAnimation.value, // Scale in
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Particle explosion effect
                    ..._particles.map((particle) {
                      // Calculate particle position based on animation progress
                      final progress = _floatController.value;
                      final x = particle.x * progress * particle.speed;
                      final y = particle.y * progress * particle.speed;
                      final opacity = 1 - progress; // Fade as they spread

                      return Transform.translate(
                        offset: Offset(x, y),
                        child: Container(
                          width: particle.size,
                          height: particle.size,
                          decoration: BoxDecoration(
                            color: particle.color.withOpacity(opacity),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),

                    // Main XP badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        // Golden gradient for XP
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade600,
                            Colors.amber.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '+${widget.xp} XP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Particle data model for explosion effect
/// Each particle moves independently with its own properties
class Particle {
  final double x; // X direction
  final double y; // Y direction
  final double size; // Particle size
  final Color color; // Particle color
  final double speed; // Movement speed multiplier

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
  });
}
