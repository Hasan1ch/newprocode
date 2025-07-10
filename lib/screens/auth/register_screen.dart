import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/auth_provider.dart';
import 'package:procode/widgets/common/custom_button.dart';
import 'package:procode/widgets/common/custom_text_field.dart';
import 'package:procode/widgets/common/gradient_container.dart';
import 'package:procode/utils/validators.dart';
import 'package:procode/config/routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:procode/config/app_colors.dart';

/// Registration screen with real-time username availability checking
/// Handles new user account creation with email verification
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();

  // UI state
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;

  // Username availability checking
  bool _isCheckingUsername = false;
  bool _isUsernameAvailable = true;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Listen for username changes to check availability
    _usernameController.addListener(_checkUsernameAvailability);
  }

  /// Initialize animations for smooth transitions
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  /// Check if username is available in real-time
  /// Shows loading indicator while checking
  Future<void> _checkUsernameAvailability() async {
    final username = _usernameController.text.trim();

    // Only check if username is at least 3 characters
    if (username.length < 3) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameAvailable = true;
      });
      return;
    }

    setState(() {
      _isCheckingUsername = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool available = await authProvider.checkUsernameAvailability(username);

    if (mounted) {
      setState(() {
        _isUsernameAvailable = available;
        _isCheckingUsername = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _displayNameController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Handle registration process
  /// Validates form and creates new user account
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      _showErrorSnackBar('Please agree to the Terms and Conditions');
      return;
    }

    if (!_isUsernameAvailable) {
      _showErrorSnackBar('Username is already taken');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
      displayName: _displayNameController.text.trim(),
    );

    if (success && mounted) {
      // Navigate to email verification
      Navigator.pushReplacementNamed(context, Routes.verifyEmail);
    } else {
      _showErrorSnackBar(authProvider.error ?? 'Registration failed');
    }
  }

  /// Handle Google sign in for quick registration
  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      _showErrorSnackBar(authProvider.error ?? 'Google sign in failed');
    }
  }

  /// Display error message to user
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Header
                        _buildHeader(),

                        const SizedBox(height: 32),

                        // Email Field
                        AuthTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 16),

                        // Username Field with availability check
                        AuthTextField(
                          controller: _usernameController,
                          hintText: 'Username',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            final error = Validators.validateUsername(value);
                            if (error != null) return error;
                            if (!_isUsernameAvailable) {
                              return 'Username is already taken';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          // Show loading or check/error icon
                          suffixIcon: _isCheckingUsername
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : (_usernameController.text.length >= 3
                                  ? Icon(
                                      _isUsernameAvailable
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: _isUsernameAvailable
                                          ? Colors.green
                                          : Colors.red,
                                    )
                                  : null),
                        ),

                        const SizedBox(height: 16),

                        // Display Name Field
                        AuthTextField(
                          controller: _displayNameController,
                          hintText: 'Display Name',
                          prefixIcon: Icons.badge_outlined,
                          validator: Validators.validateDisplayName,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 16),

                        // Password Field
                        AuthTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: !_isPasswordVisible,
                          validator: Validators.validatePassword,
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password Field
                        AuthTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: !_isConfirmPasswordVisible,
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleRegister(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Terms and Conditions
                        _buildTermsCheckbox(),

                        const SizedBox(height: 32),

                        // Register Button with loading state
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return CustomButton(
                              text: 'Create Account',
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _handleRegister,
                              isLoading: authProvider.isLoading,
                              width: double.infinity,
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        _buildDivider(),

                        const SizedBox(height: 24),

                        // Google Sign In
                        _buildSocialLogin(),

                        const SizedBox(height: 32),

                        // Login Link
                        _buildLoginLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build header with logo and title
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.code,
            size: 40,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          'Create Account',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),

        const SizedBox(height: 8),

        Text(
          'Start your coding journey today',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build terms and conditions checkbox
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            children: [
              Text(
                'I agree to the ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to terms and conditions
                },
                child: Text(
                  'Terms and Conditions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build divider with "OR" text
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  /// Build Google sign in button
  Widget _buildSocialLogin() {
    return CustomButton(
      text: 'Continue with Google',
      onPressed: _handleGoogleSignIn,
      variant: ButtonVariant.outline,
      width: double.infinity,
      icon: const FaIcon(
        FontAwesomeIcons.google,
        size: 20,
      ),
    );
  }

  /// Build login link for existing users
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, Routes.login);
          },
          child: const Text(
            'Login',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
