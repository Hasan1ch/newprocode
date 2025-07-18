import 'package:flutter/material.dart';
import 'package:procode/config/theme.dart';
import 'package:procode/models/achievement_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';

/// Achievement unlock dialog with confetti celebration
/// This creates a rewarding moment when users earn achievements
/// Features animations, rarity indicators, and social sharing
class AchievementDialog extends StatefulWidget {
  final AchievementModel achievement;

  const AchievementDialog({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  /// Static method to show the dialog easily from anywhere
  static void show(BuildContext context, AchievementModel achievement) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force user to see their achievement
      builder: (context) => AchievementDialog(achievement: achievement),
    );
  }

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti for celebration effect
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Main animation controller for dialog entrance
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Elastic scale animation for bouncy entrance
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Subtle rotation for playful effect
    _rotateAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _animationController.forward();
    _confettiController.play();

    // Auto dismiss after 5 seconds to prevent blocking
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Maps rarity to appropriate color scheme
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

  /// Creates lighter shade for gradient effects
  Color _getLighterShade(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
  }

  /// Builds star rating based on rarity
  /// Visual indicator of achievement importance
  Widget _getRarityStars() {
    final rarityLevel = {
          'common': 1,
          'rare': 2,
          'epic': 3,
          'legendary': 4,
        }[widget.achievement.rarity.toLowerCase()] ??
        1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Icon(
          index < rarityLevel ? Icons.star : Icons.star_border,
          size: 16,
          color: _getRarityColor(),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();

    return Stack(
      children: [
        // Main Dialog with animations
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: Container(
                    width: 350,
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      // Rarity-colored border
                      border: Border.all(
                        color: rarityColor,
                        width: 3,
                      ),
                      // Glowing shadow effect
                      boxShadow: [
                        BoxShadow(
                          color: rarityColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Achievement icon with glow
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow background
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    rarityColor.withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // Icon container
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: rarityColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: rarityColor.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.emoji_events,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Title
                        Text(
                          'ACHIEVEMENT UNLOCKED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.grey[600],
                          ),
                        ),

                        SizedBox(height: 8),

                        // Achievement Name
                        Text(
                          widget.achievement.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 8),

                        // Rarity Stars
                        _getRarityStars(),

                        SizedBox(height: 16),

                        // Description
                        Text(
                          widget.achievement.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 20),

                        // XP Reward Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '+${widget.achievement.xpReward} XP',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Share achievement
                            TextButton.icon(
                              onPressed: () {
                                Share.share(
                                  'I just unlocked the "${widget.achievement.name}" achievement in ProCode! 🎉',
                                );
                              },
                              icon: Icon(Icons.share),
                              label: Text('Share'),
                            ),
                            // Dismiss button
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
                              child: Text('Awesome!'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 50,
            minBlastForce: 20,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.2,
            // Rarity-themed colors
            colors: [
              rarityColor,
              _getLighterShade(rarityColor),
              Colors.amber,
              Colors.yellow,
              Colors.orange,
            ],
            strokeWidth: 1,
            strokeColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
