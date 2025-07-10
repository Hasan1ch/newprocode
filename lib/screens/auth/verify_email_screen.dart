import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/auth_provider.dart';
import 'package:procode/widgets/common/custom_button.dart';
import 'package:procode/widgets/common/gradient_container.dart';
import 'package:procode/config/routes.dart';
import 'package:procode/config/app_colors.dart';

/// Email verification screen with automatic status checking
/// Polls Firebase to detect when user verifies their email
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  // Timers for automatic checking and resend cooldown
  Timer? _verificationTimer;
  Timer? _resendCountdownTimer;
  int _resendTimer = 0;
  bool _isCheckingVerification = false;

  // Animation controller for icon animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _startVerificationCheck();
    _sendInitialVerificationEmail();
  }

  /// Initialize scale animation for email icon
  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  /// Send verification email on screen load
  Future<void> _sendInitialVerificationEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.sendEmailVerification();
    _startResendTimer();
  }

  /// Start periodic check for email verification
  /// Automatically navigates to dashboard when verified
  void _startVerificationCheck() {
    _verificationTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      // Check if widget is still mounted before doing anything
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_isCheckingVerification) return;

      // Set checking state only if mounted
      if (mounted) {
        setState(() {
          _isCheckingVerification = true;
        });
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool isVerified = await authProvider.checkEmailVerification();

      // Check mounted before navigation and setState
      if (mounted) {
        if (isVerified) {
          timer.cancel();
          Navigator.pushReplacementNamed(context, Routes.dashboard);
        } else {
          setState(() {
            _isCheckingVerification = false;
          });
        }
      }
    });
  }

  /// Start countdown timer for resend button
  /// Prevents spam by enforcing 60 second cooldown
  void _startResendTimer() {
    if (mounted) {
      setState(() {
        _resendTimer = 60;
      });
    }

    _resendCountdownTimer?.cancel(); // Cancel any existing timer
    _resendCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendTimer == 0) {
        timer.cancel();
      } else {
        setState(() {
          _resendTimer--;
        });
      }
    });
  }

  /// Resend verification email with cooldown check
  Future<void> _resendVerificationEmail() async {
    if (_resendTimer > 0) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.sendEmailVerification();

    if (mounted) {
      if (success) {
        _showSuccessSnackBar('Verification email sent successfully');
        _startResendTimer();
      } else {
        _showErrorSnackBar(
            authProvider.error ?? 'Failed to send verification email');
      }
    }
  }

  /// Display success message
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Display error message
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Handle logout to change email
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  void dispose() {
    // Cancel all timers to prevent memory leaks
    _verificationTimer?.cancel();
    _resendCountdownTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userEmail = authProvider.currentUser?.email ?? '';

    return Scaffold(
      body: GradientContainer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated email icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 100,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Verify Your Email',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'We\'ve sent a verification email to',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // User email display
                Text(
                  userEmail,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 32),

                // Instructions box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your email and click the verification link to continue.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Once verified, you\'ll be automatically redirected to the dashboard.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Checking status indicator
                if (_isCheckingVerification)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Checking verification status...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Resend Button with countdown
                CustomButton(
                  text: _resendTimer > 0
                      ? 'Resend Email (${_resendTimer}s)'
                      : 'Resend Email',
                  onPressed: _resendTimer > 0 ? null : _resendVerificationEmail,
                  variant: ButtonVariant.outline,
                  width: double.infinity,
                ),

                const SizedBox(height: 16),

                // Change Email Button
                CustomButton(
                  text: 'Change Email',
                  onPressed: _handleLogout,
                  variant: ButtonVariant.text,
                  width: double.infinity,
                ),

                const Spacer(),

                // Tips for troubleshooting
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tips',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Check your spam/junk folder\n'
                        '• Make sure the email address is correct\n'
                        '• Add noreply@procode.app to your contacts',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
