import 'package:flutter/material.dart';
import 'dart:math' as math;

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
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Particle> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _floatController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: 0,
      end: -100,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Interval(0.7, 1.0, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Generate particles
    _generateParticles();

    // Start animations
    _scaleController.forward();
    _floatController.forward();
    _fadeController.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  void _generateParticles() {
    for (int i = 0; i < 10; i++) {
      _particles.add(Particle(
        x: _random.nextDouble() * 100 - 50,
        y: _random.nextDouble() * 100 - 50,
        size: _random.nextDouble() * 4 + 2,
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
        speed: _random.nextDouble() * 2 + 1,
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
      top: MediaQuery.of(context).size.height / 2,
      left: MediaQuery.of(context).size.width / 2,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _floatAnimation,
          _fadeAnimation,
          _scaleAnimation,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Particles
                    ..._particles.map((particle) {
                      final progress = _floatController.value;
                      final x = particle.x * progress * particle.speed;
                      final y = particle.y * progress * particle.speed;
                      final opacity = 1 - progress;

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

                    // Main XP text
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
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

class Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
  });
}
