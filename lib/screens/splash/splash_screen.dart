import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/auth_provider.dart';
import 'package:procode/widgets/common/gradient_container.dart';
import 'package:procode/config/app_colors.dart';
import 'package:procode/config/routes.dart';

/// Splash screen shown on app launch with animated logo and text
/// Handles initial authentication check and navigation routing
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers for logo and text
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animations and check authentication
    _initializeAnimations();
    _checkAuthStatus();
  }

  /// Sets up all animations for the splash screen
  void _initializeAnimations() {
    // Logo animations - scale and rotation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Elastic scale animation for bounce effect
    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Full rotation animation (2π radians)
    _logoRotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Text animations - fade and slide
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Fade in animation for text
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Slide up animation for text
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Start animations with staggered timing
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  /// Checks authentication status and navigates accordingly
  Future<void> _checkAuthStatus() async {
    // Wait for animations to complete for better UX
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check current authentication state
    await authProvider.checkAuthState();

    if (!mounted) return;

    // Navigate based on authentication status
    switch (authProvider.status) {
      case AuthStatus.authenticated:
        // User is logged in, go to dashboard
        Navigator.pushReplacementNamed(context, Routes.dashboard);
        break;
      case AuthStatus.verifyingEmail:
        // User needs to verify email
        Navigator.pushReplacementNamed(context, Routes.verifyEmail);
        break;
      case AuthStatus.unauthenticated:
      case AuthStatus.uninitialized:
      default:
        // User is not logged in, go to login screen
        Navigator.pushReplacementNamed(context, Routes.login);
        break;
    }
  }

  @override
  void dispose() {
    // Clean up animation controllers
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo with scale and rotation
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _logoRotateAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.code,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Animated Text with fade and slide
              FadeTransition(
                opacity: _textFadeAnimation,
                child: SlideTransition(
                  position: _textSlideAnimation,
                  child: Column(
                    children: [
                      // App name
                      Text(
                        'ProCode',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                      ),
                      const SizedBox(height: 8),
                      // Tagline
                      Text(
                        'Learn • Code • Level Up',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 1,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // Loading indicator
              FadeTransition(
                opacity: _textFadeAnimation,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
