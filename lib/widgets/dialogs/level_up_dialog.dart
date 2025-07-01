import 'package:flutter/material.dart';
import 'package:procode/config/theme.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

import 'dart:math' as math;

class LevelUpDialog extends StatefulWidget {
  final String newLevel;
  final int levelNumber;
  final int currentXP;
  final int nextLevelXP;

  const LevelUpDialog({
    Key? key,
    required this.newLevel,
    required this.levelNumber,
    required this.currentXP,
    required this.nextLevelXP,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String newLevel,
    required int levelNumber,
    required int currentXP,
    required int nextLevelXP,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpDialog(
        newLevel: newLevel,
        levelNumber: levelNumber,
        currentXP: currentXP,
        nextLevelXP: nextLevelXP,
      ),
    );
  }

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;

  final List<_Star> _stars = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Generate stars
    for (int i = 0; i < 20; i++) {
      _stars.add(_Star(
        x: _random.nextDouble() * 400 - 200,
        y: _random.nextDouble() * 400 - 200,
        size: _random.nextDouble() * 3 + 1,
        speed: _random.nextDouble() * 0.5 + 0.5,
        delay: _random.nextDouble() * 2,
      ));
    }

    // Start animations
    _scaleController.forward();
    _rotateController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getLevelColor() {
    final colors = [
      Colors.grey, // Level 1
      Colors.green, // Level 2
      Colors.blue, // Level 3
      Colors.purple, // Level 4
      Colors.orange, // Level 5
      Colors.red, // Level 6
      Colors.amber, // Level 7+
    ];

    return colors[math.min(widget.levelNumber - 1, colors.length - 1)];
  }

  Widget _buildLevelBadge() {
    final levelColor = _getLevelColor();

    return Stack(
      alignment: Alignment.center,
      children: [
        // Rotating stars background
        AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotateAnimation.value,
              child: SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  children: _stars.map((star) {
                    final angle = _rotateAnimation.value + star.delay;
                    final distance = 50 + star.speed * 50;
                    final x = math.cos(angle) * distance;
                    final y = math.sin(angle) * distance;

                    return Positioned(
                      left: 100 + x - star.size / 2,
                      top: 100 + y - star.size / 2,
                      child: Container(
                        width: star.size * 2,
                        height: star.size * 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              blurRadius: star.size * 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),

        // Level badge
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _getDarkerShade(levelColor),
                      _getLighterShade(levelColor),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: levelColor.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LEVEL',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      '${widget.levelNumber}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 400,
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lottie animation
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/lottie/fireworks.json',
                          repeat: true,
                        ),
                        _buildLevelBadge(),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Title
                  Text(
                    'LEVEL UP!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 2,
                    ),
                  ),

                  SizedBox(height: 8),

                  // New Level
                  Text(
                    'You are now a',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    widget.newLevel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _getLevelColor(),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Progress to next level
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current XP',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${widget.currentXP} / ${widget.nextLevelXP}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: widget.currentXP / widget.nextLevelXP,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getLevelColor(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Share.share(
                            'I just reached Level ${widget.levelNumber} (${widget.newLevel}) in ProCode! 🎉',
                          );
                        },
                        icon: Icon(Icons.share),
                        label: Text('Share'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: Text('Continue Learning'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper methods to create color shades
  Color _getDarkerShade(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();
  }

  Color _getLighterShade(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0)).toColor();
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double delay;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.delay,
  });
}
