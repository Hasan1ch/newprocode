import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:procode/models/achievement_model.dart';
import 'dart:math' as math;

// Add type alias
typedef Achievement = AchievementModel;

class AchievementUnlockAnimation extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onComplete;

  const AchievementUnlockAnimation({
    Key? key,
    required this.achievement,
    this.onComplete,
  }) : super(key: key);

  @override
  State<AchievementUnlockAnimation> createState() =>
      _AchievementUnlockAnimationState();
}

class _AchievementUnlockAnimationState extends State<AchievementUnlockAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _shimmerAnimation;

  bool _showDetails = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
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

    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    // Start animations
    _scaleController.forward();
    _rotateController.repeat();
    _shimmerController.repeat();

    // Show details after initial animation
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showDetails = true;
        });
      }
    });

    // Complete after 4 seconds
    Future.delayed(Duration(seconds: 4), () {
      if (widget.onComplete != null && mounted) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Color _getRarityColor() {
    switch (widget.achievement.rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
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
                      color: rarityColor.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lottie Animation Background
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating glow
                        AnimatedBuilder(
                          animation: _rotateAnimation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotateAnimation.value,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      rarityColor.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Achievement Icon
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                _getDarkerShade(rarityColor),
                                _getLighterShade(rarityColor),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: rarityColor.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Shimmer effect
                              AnimatedBuilder(
                                animation: _shimmerAnimation,
                                builder: (context, child) {
                                  return ClipOval(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.white24,
                                            Colors.transparent,
                                          ],
                                          stops: [0.0, 0.5, 1.0],
                                          begin: Alignment(-1, -1),
                                          end: Alignment(1, 1),
                                          transform: GradientRotation(
                                            _shimmerAnimation.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Icon
                              Center(
                                child: Icon(
                                  _getAchievementIcon(),
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Lottie celebration
                        if (_showDetails)
                          Lottie.asset(
                            'assets/animations/lottie/confetti.json',
                            width: 300,
                            height: 300,
                            repeat: false,
                          ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Achievement Details
                    AnimatedOpacity(
                      opacity: _showDetails ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Text(
                            'ACHIEVEMENT UNLOCKED!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            widget.achievement.name,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.achievement.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: rarityColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: rarityColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 20,
                                      color: rarityColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '+${widget.achievement.xpReward} XP',
                                      style: TextStyle(
                                        color: rarityColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: rarityColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: rarityColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  widget.achievement.rarity.toUpperCase(),
                                  style: TextStyle(
                                    color: rarityColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getAchievementIcon() {
    // Map achievement IDs to icons
    switch (widget.achievement.id) {
      case 'first_steps':
        return Icons.directions_walk;
      case 'quiz_master':
        return Icons.psychology;
      case 'streak_hero':
        return Icons.local_fire_department;
      case 'speed_learner':
        return Icons.speed;
      case 'bug_crusher':
        return Icons.bug_report;
      case 'night_owl':
        return Icons.nights_stay;
      case 'polyglot':
        return Icons.language;
      default:
        return Icons.emoji_events;
    }
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
