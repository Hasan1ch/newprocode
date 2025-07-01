import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:procode/models/user_model.dart';
import 'package:procode/services/database_service.dart';
import 'package:procode/services/email_service.dart';
import 'package:procode/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DatabaseService _databaseService = DatabaseService();
  final EmailService _emailService = EmailService();

  // Rate limiting variables
  final Map<String, List<DateTime>> _loginAttempts = {};
  static const int _maxLoginAttempts = 5;
  static const Duration _rateLimitDuration = Duration(minutes: 15);

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Check if email is verified
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Sign up with email and password (matching AuthProvider's expected method name)
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

  // Sign in with email and password (matching AuthProvider's expected method name)
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Check rate limiting
      _checkRateLimit(email);

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Clear login attempts on successful login
      _loginAttempts.remove(email);

      return result;
    } on FirebaseAuthException catch (e) {
      // Record failed login attempt
      _recordFailedLoginAttempt(email);
      AppLogger.error('Sign in error: ${e.message}', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      AppLogger.error('Sign in error: $e', error: e);
      rethrow;
    }
  }

  // Sign out (matching AuthProvider's expected method name)
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();

      // Clear saved preferences
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

  // Send verification email (matching AuthProvider's expected method name)
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

  // Email/Password Registration (keeping for backward compatibility)
  Future<UserModel?> registerWithEmailPassword({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      // Check username availability
      bool isUsernameAvailable =
          await _databaseService.checkUsernameAvailability(username);
      if (!isUsernameAvailable) {
        throw Exception('Username is already taken');
      }

      // Create user with Firebase Auth
      UserCredential result = await signUp(email: email, password: password);

      User? user = result.user;
      if (user == null) throw Exception('Failed to create user');

      // Send verification email
      await sendVerificationEmail();

      // Create user document in Firestore
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

      // Reserve username
      await _databaseService.reserveUsername(username.trim(), user.uid);

      AppLogger.info('User registered successfully: ${user.uid}');
      return newUser;
    } catch (e) {
      AppLogger.error('Registration error: $e', error: e);
      rethrow;
    }
  }

  // Email/Password Login (keeping for backward compatibility)
  Future<UserModel?> loginWithEmailPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      UserCredential result = await signIn(email: email, password: password);

      User? user = result.user;
      if (user == null) throw Exception('Failed to login');

      // Save remember me preference
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', true);
        await prefs.setString('savedEmail', email);
        await prefs.setString('saved_email', email);
      }

      // Update last login date
      await _databaseService.updateLastLoginDate(user.uid);

      // Get user data
      UserModel? userModel = await _databaseService.getUser(user.uid);

      AppLogger.info('User logged in successfully: ${user.uid}');
      return userModel;
    } catch (e) {
      AppLogger.error('Login error: $e', error: e);
      rethrow;
    }
  }

  // Google Sign In with web support
  Future<UserModel?> signInWithGoogle() async {
    try {
      // For web, use signInSilently first to avoid the deprecated warning
      GoogleSignInAccount? googleUser;

      if (kIsWeb) {
        // Try silent sign-in first for web
        try {
          googleUser = await _googleSignIn.signInSilently();
        } catch (e) {
          // Silent sign-in failed, proceed with regular sign-in
          AppLogger.info('Silent sign-in failed, trying regular sign-in');
        }

        // If silent sign-in fails, use the regular sign-in
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

      // Get auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;
      if (user == null) throw Exception('Failed to sign in with Google');

      // Check if user exists in database
      UserModel? existingUser = await _databaseService.getUser(user.uid);

      if (existingUser == null) {
        // Generate unique username from email
        String baseUsername = user.email?.split('@')[0] ?? 'user';
        String username = await _generateUniqueUsername(baseUsername);

        // Create new user
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
        // Update last login
        await _databaseService.updateLastLoginDate(user.uid);
        AppLogger.info('Existing Google user logged in: ${user.uid}');
        return existingUser;
      }
    } catch (e) {
      AppLogger.error('Google sign in error: $e', error: e);
      rethrow;
    }
  }

  // Check email verification status
  Future<bool> checkEmailVerification() async {
    try {
      User? user = currentUser;
      if (user == null) return false;

      await user.reload();
      user = _auth.currentUser;

      if (user?.emailVerified ?? false) {
        // Update user document
        await _databaseService.updateEmailVerificationStatus(user!.uid, true);
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Error checking email verification: $e', error: e);
      return false;
    }
  }

  // Password reset
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

  // Update password
  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      User? user = currentUser;
      if (user == null) throw Exception('No user logged in');
      if (user.email == null)
        throw Exception('No email associated with account');

      // Re-authenticate user
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

  // Delete account
  Future<void> deleteAccount(String password) async {
    try {
      User? user = currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate for security
      if (user.email != null && password.isNotEmpty) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      } else if (user.providerData
          .any((info) => info.providerId == 'google.com')) {
        // Re-authenticate with Google
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

      // Delete user data from Firestore
      await _databaseService.deleteUser(user.uid);

      // Delete user from Firebase Auth
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

  // Logout (keeping for backward compatibility)
  Future<void> logout() async {
    return signOut();
  }

  // Save email for remember me functionality
  Future<void> saveEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);
    } catch (e) {
      AppLogger.error('Error saving email', error: e);
    }
  }

  // Get saved email
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

  // Clear saved email
  Future<void> clearSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
      await prefs.remove('savedEmail');
    } catch (e) {
      AppLogger.error('Error clearing saved email', error: e);
    }
  }

  // Rate limiting methods
  void _checkRateLimit(String email) {
    final attempts = _loginAttempts[email] ?? [];

    // Remove old attempts
    final now = DateTime.now();
    attempts
        .removeWhere((attempt) => now.difference(attempt) > _rateLimitDuration);

    if (attempts.length >= _maxLoginAttempts) {
      throw Exception('Too many login attempts. Please try again later.');
    }
  }

  void _recordFailedLoginAttempt(String email) {
    _loginAttempts[email] ??= [];
    _loginAttempts[email]!.add(DateTime.now());
  }

  // Generate unique username
  Future<String> _generateUniqueUsername(String base) async {
    String username = base.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    if (username.length < 3) username = 'user$username';
    if (username.length > 15) username = username.substring(0, 15);

    int counter = 1;
    String testUsername = username;

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

  // Handle Firebase Auth exceptions
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
