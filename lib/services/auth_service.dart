import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:procode/models/user_model.dart';
import 'package:procode/services/database_service.dart';
import 'package:procode/services/email_service.dart';
import 'package:procode/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service handling all auth operations
/// Includes email/password, Google Sign-In, and rate limiting
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _databaseService = DatabaseService();
  final EmailService _emailService = EmailService();

  // Rate limiting to prevent brute force attacks
  final Map<String, List<DateTime>> _loginAttempts = {};
  static const int _maxLoginAttempts = 5;
  static const Duration _rateLimitDuration = Duration(minutes: 15);

  // Get current authenticated user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes for reactive UI updates
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Quick check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Check if user has verified their email
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  /// Sign up with email and password (matching AuthProvider's expected method name)
  /// Creates Firebase Auth user but doesn't create Firestore document
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Sign up error: ${e.message}', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Sign up error: $e', error: e);
      rethrow;
    }
  }

  /// Sign in with email and password with rate limiting
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Check if user has exceeded login attempts
      _checkRateLimit(email);

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Clear login attempts on successful login
      _loginAttempts.remove(email);

      return result;
    } on FirebaseAuthException catch (e) {
      // Record failed attempt for rate limiting
      _recordFailedLoginAttempt(email);
      AppLogger.error('Sign in error: ${e.message}', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Sign in error: $e', error: e);
      rethrow;
    }
  }

  /// Sign out from all auth providers
  Future<void> signOut() async {
    try {
      // Sign out from Google if user signed in with Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();

      // Clear saved preferences for remember me functionality
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('rememberMe');
      await prefs.remove('savedEmail');
      await prefs.remove('saved_email');

      AppLogger.info('User signed out successfully');
    } catch (e) {
      AppLogger.error('Sign out error: $e', error: e);
      rethrow;
    }
  }

  /// Send email verification to current user
  Future<void> sendVerificationEmail() async {
    try {
      User? user = currentUser;
      if (user == null) throw Exception('No user logged in');

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        AppLogger.info('Verification email sent to ${user.email}');
      }
    } catch (e) {
      AppLogger.error('Error sending verification email: $e', error: e);
      rethrow;
    }
  }

  /// Complete registration flow with username and profile creation
  /// This method creates the Firestore user document after auth
  Future<UserModel?> registerWithEmailPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      // Check if username is available before creating account
      bool isUsernameAvailable =
          await _databaseService.checkUsernameAvailability(username);
      if (!isUsernameAvailable) {
        throw Exception('Username is already taken');
      }

      // Create user with Firebase Auth
      UserCredential result = await signUp(email: email, password: password);

      User? user = result.user;
      if (user == null) throw Exception('Failed to create user');

      // Send verification email immediately
      await sendVerificationEmail();

      // Create user document in Firestore with initial data
      UserModel newUser = UserModel(
        id: user.uid,
        uid: user.uid,
        email: email.trim(),
        username: username.trim(),
        displayName: displayName.trim(),
        totalXP: 0,
        level: 1,
        currentStreak: 0,
        longestStreak: 0,
        createdAt: DateTime.now(),
        completedCourses: [],
        enrolledCourses: [],
        progress: {},
        achievements: [],
        featuredAchievements: [],
        completedChallenges: [],
        privacySettings: {
          'showEmail': false,
          'showProgress': true,
          'showOnLeaderboard': true,
        },
        activityData: {},
      );

      await _databaseService.createUser(newUser);

      // Reserve username to prevent duplicates
      await _databaseService.reserveUsername(username.trim(), user.uid);

      AppLogger.info('User registered successfully: ${user.uid}');
      return newUser;
    } catch (e) {
      AppLogger.error('Registration error: $e', error: e);
      rethrow;
    }
  }

  /// Login with email/password and remember me functionality
  Future<UserModel?> loginWithEmailPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      UserCredential result = await signIn(email: email, password: password);

      User? user = result.user;
      if (user == null) throw Exception('Failed to login');

      // Save email for remember me feature
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', true);
        await prefs.setString('savedEmail', email);
        await prefs.setString('saved_email', email);
      }

      // Update last login date for streak tracking
      await _databaseService.updateLastLoginDate(user.uid);

      // Get user data from Firestore
      UserModel? userModel = await _databaseService.getUser(user.uid);

      AppLogger.info('User logged in successfully: ${user.uid}');
      return userModel;
    } catch (e) {
      AppLogger.error('Login error: $e', error: e);
      rethrow;
    }
  }

  /// Google Sign In with web support and automatic user creation
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Handle Google Sign-In differently for web
      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        // Try silent sign-in first for web to avoid deprecated warning
        try {
          googleUser = await _googleSignIn.signInSilently();
        } catch (e) {
          AppLogger.info('Silent sign-in failed, trying regular sign-in');
        }

        // If silent sign-in fails, use regular sign-in
        if (googleUser == null) {
          googleUser = await _googleSignIn.signIn();
        }
      } else {
        // For mobile platforms, use regular sign-in
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      // Get auth details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;
      if (user == null) throw Exception('Failed to sign in with Google');

      // Check if user already exists
      UserModel? existingUser = await _databaseService.getUser(user.uid);

      if (existingUser == null) {
        // New Google user - create profile
        String baseUsername = user.email?.split('@')[0] ?? 'user';
        String username = await _generateUniqueUsername(baseUsername);

        UserModel newUser = UserModel(
          id: user.uid,
          uid: user.uid,
          email: user.email ?? '',
          username: username,
          displayName: user.displayName ?? username,
          avatarUrl: user.photoURL ?? '',
          totalXP: 0,
          level: 1,
          currentStreak: 0,
          longestStreak: 0,
          lastActiveDate: DateTime.now(),
          createdAt: DateTime.now(),
          completedCourses: [],
          enrolledCourses: [],
          progress: {},
          achievements: [],
          featuredAchievements: [],
          completedChallenges: [],
          privacySettings: {
            'showEmail': false,
            'showProgress': true,
            'showOnLeaderboard': true,
          },
          activityData: {},
        );

        await _databaseService.createUser(newUser);
        await _databaseService.reserveUsername(username, user.uid);

        AppLogger.info('New Google user created: ${user.uid}');
        return newUser;
      } else {
        // Existing user - update last login
        await _databaseService.updateLastLoginDate(user.uid);
        AppLogger.info('Existing Google user logged in: ${user.uid}');
        return existingUser;
      }
    } catch (e) {
      AppLogger.error('Google sign in error: $e', error: e);
      rethrow;
    }
  }

  /// Check if user's email is verified and update database
  Future<bool> checkEmailVerification() async {
    try {
      User? user = currentUser;
      if (user == null) return false;

      // Reload user to get latest verification status
      await user.reload();
      user = _auth.currentUser;

      if (user?.emailVerified ?? false) {
        // Update verification status in Firestore
        await _databaseService.updateEmailVerificationStatus(user!.uid, true);
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error checking email verification: $e', error: e);
      return false;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      AppLogger.info('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password reset error: ${e.message}', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Password reset error: $e', error: e);
      rethrow;
    }
  }

  /// Update user password with reauthentication
  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      User? user = currentUser;
      if (user == null) throw Exception('No user logged in');
      if (user.email == null)
        throw Exception('No email associated with account');

      // Re-authenticate user for security
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      AppLogger.info('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Password update error: ${e.message}', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Password update error: $e', error: e);
      rethrow;
    }
  }

  /// Delete user account with proper cleanup
  Future<void> deleteAccount(String password) async {
    try {
      User? user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate based on provider
      if (user.email != null && password.isNotEmpty) {
        // Email/password user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      } else if (user.providerData
          .any((info) => info.providerId == 'google.com')) {
        // Google user
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null)
          throw Exception('Google re-authentication cancelled');

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Delete user data from Firestore first
      await _databaseService.deleteUser(user.uid);

      // Then delete from Firebase Auth
      await user.delete();

      AppLogger.info('Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Account deletion error: ${e.message}', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Account deletion error: $e', error: e);
      rethrow;
    }
  }

  /// Logout (keeping for backward compatibility)
  Future<void> logout() async {
    return signOut();
  }

  /// Save email for remember me functionality
  Future<void> saveEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);
    } catch (e) {
      AppLogger.error('Error saving email', error: e);
    }
  }

  /// Get saved email for login screen
  Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Check both keys for backward compatibility
      return prefs.getString('saved_email') ?? prefs.getString('savedEmail');
    } catch (e) {
      AppLogger.error('Error getting saved email', error: e);
      return null;
    }
  }

  /// Clear saved email when remember me is unchecked
  Future<void> clearSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
      await prefs.remove('savedEmail');
    } catch (e) {
      AppLogger.error('Error clearing saved email', error: e);
    }
  }

  /// Check if user has exceeded login attempts
  void _checkRateLimit(String email) {
    final attempts = _loginAttempts[email] ?? [];

    // Remove old attempts outside the rate limit window
    final now = DateTime.now();
    attempts
        .removeWhere((attempt) => now.difference(attempt) > _rateLimitDuration);

    if (attempts.length >= _maxLoginAttempts) {
      throw Exception('Too many login attempts. Please try again later.');
    }
  }

  /// Record failed login attempt for rate limiting
  void _recordFailedLoginAttempt(String email) {
    _loginAttempts[email] ??= [];
    _loginAttempts[email]!.add(DateTime.now());
  }

  /// Generate unique username from base (e.g., email prefix)
  Future<String> _generateUniqueUsername(String base) async {
    // Clean the base username
    String username = base.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    if (username.length < 3) username = 'user$username';
    if (username.length > 15) username = username.substring(0, 15);

    int counter = 1;
    String testUsername = username;

    // Keep trying until we find an available username
    while (!await _databaseService.checkUsernameAvailability(testUsername)) {
      testUsername = '$username$counter';
      counter++;

      // Ensure we don't exceed 15 characters
      if (testUsername.length > 15) {
        username =
            username.substring(0, username.length - counter.toString().length);
        testUsername = '$username$counter';
      }
    }

    return testUsername;
  }

  /// Convert Firebase Auth exceptions to user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Invalid password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'requires-recent-login':
        return 'Please login again to perform this action.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
