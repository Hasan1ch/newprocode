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

/// Login screen with email/password and Google authentication
/// Includes remember me functionality and password recovery
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // UI state
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedEmail();
  }

  /// Initialize animations for smooth screen transitions
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

  /// Load saved email if remember me was previously checked
  Future<void> _loadSavedEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? savedEmail = await authProvider.getSavedEmail();

    if (savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Handle email/password login
  /// Validates form and navigates based on email verification status
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (success) {
      if (authProvider.isEmailVerified) {
        Navigator.pushReplacementNamed(context, Routes.dashboard);
      } else {
        Navigator.pushReplacementNamed(context, Routes.verifyEmail);
      }
    } else {
      _showErrorSnackBar(authProvider.error ?? 'Login failed');
    }
  }

  /// Handle Google sign in
  /// Creates account if new user or logs in existing user
  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success = await authProvider.signInWithGoogle();

    if (success) {
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } else {
      _showErrorSnackBar(authProvider.error ?? 'Google sign in failed');
    }
  }

  /// Display error message to user
  void _showErrorSnackBar(String message) {
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo and Title
                        _buildHeader(),

                        const SizedBox(height: 48),

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

                        // Password Field
                        AuthTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: !_isPasswordVisible,
                          validator: Validators.validateLoginPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
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

                        // Remember Me and Forgot Password
                        _buildOptions(),

                        const SizedBox(height: 32),

                        // Login Button with loading state
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return CustomButton(
                              text: 'Login',
                              onPressed:
                                  authProvider.isLoading ? null : _handleLogin,
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

                        // Sign Up Link
                        _buildSignUpLink(),
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

  /// Build header with logo and welcome text
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.code,
            size: 50,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),

        const SizedBox(height: 24),

        // Welcome Text
        Text(
          'Welcome Back!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),

        const SizedBox(height: 8),

        Text(
          'Login to continue your learning journey',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color.fromARGB(255, 180, 172, 189),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build remember me checkbox and forgot password link
  Widget _buildOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),

        // Forgot Password
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, Routes.forgotPassword);
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w600,
            ),
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
            color: AppColors.textSecondary.withOpacity(0.3),
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
            color: AppColors.textSecondary.withOpacity(0.3),
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
        color: Color.fromARGB(255, 226, 51, 8),
        size: 20,
      ),
    );
  }

  /// Build sign up link for new users
  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, Routes.register);
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
