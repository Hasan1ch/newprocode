import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:procode/models/user_model.dart';
import 'package:procode/services/auth_service.dart';
import 'package:procode/services/database_service.dart';
import 'package:procode/utils/app_logger.dart';
import 'package:provider/provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/providers/course_provider.dart';

// Add AuthStatus enum
enum AuthStatus {
  uninitialized,
  authenticated,
  verifyingEmail,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _firebaseUser;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  AuthStatus _status = AuthStatus.uninitialized;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;
  AuthStatus get status => _status;

  // Constructor
  AuthProvider() {
    _init();
  }

  // Initialize auth state listener
  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadUserData(user.uid);
        _updateAuthStatus();
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  // Update auth status based on current state
  void _updateAuthStatus() {
    if (_firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
    } else if (!_firebaseUser!.emailVerified) {
      _status = AuthStatus.verifyingEmail;
    } else {
      _status = AuthStatus.authenticated;
    }
  }

  // Check auth state method for splash screen
  Future<void> checkAuthState() async {
    try {
      _status = AuthStatus.uninitialized;
      notifyListeners();

      // Get current user
      _firebaseUser = FirebaseAuth.instance.currentUser;

      if (_firebaseUser != null) {
        // Reload user to get latest email verification status
        await _firebaseUser!.reload();
        _firebaseUser = FirebaseAuth.instance.currentUser;

        // Load user data from Firestore
        await _loadUserData(_firebaseUser!.uid);

        // Update status
        _updateAuthStatus();
      } else {
        _status = AuthStatus.unauthenticated;
      }

      notifyListeners();
    } catch (e) {
      AppLogger.error('Error checking auth state', error: e);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _user = await _databaseService.getUser(uid);
      if (_user != null) {
        // Update last login date
        await _databaseService.updateLastLoginDate(uid);
      }
    } catch (e) {
      AppLogger.error('Error loading user data', error: e);
    }
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check username availability
      bool isAvailable =
          await _databaseService.checkUsernameAvailability(username);
      if (!isAvailable) {
        _error = 'Username is already taken';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create user with Firebase Auth
      final credential =
          await _authService.signUp(email: email, password: password);

      if (credential.user != null) {
        // Reserve username
        await _databaseService.reserveUsername(username, credential.user!.uid);

        // Create user profile in Firestore
        final newUser = UserModel(
          id: credential.user!.uid,
          email: email,
          username: username,
          displayName: displayName,
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

        // Send verification email
        await _authService.sendVerificationEmail();

        _status = AuthStatus.verifyingEmail;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Sign up error', error: e);
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);

      // Update auth status after sign in
      await checkAuthState();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Sign in error', error: e);
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
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
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user exists in Firestore
        final existingUser =
            await _databaseService.getUser(userCredential.user!.uid);

        if (existingUser == null) {
          // Create new user profile
          final username = userCredential.user!.email!.split('@')[0];
          final displayName = userCredential.user!.displayName ?? username;

          // Check if username is available, if not, append numbers
          String finalUsername = username;
          int counter = 1;
          while (!await _databaseService
              .checkUsernameAvailability(finalUsername)) {
            finalUsername = '$username$counter';
            counter++;
          }

          await _databaseService.reserveUsername(
              finalUsername, userCredential.user!.uid);

          final newUser = UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email!,
            username: finalUsername,
            displayName: displayName,
            avatarUrl: userCredential.user!.photoURL,
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
        }

        // Update auth status
        await checkAuthState();

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Google sign in error', error: e);
      return false;
    }
  }

  // Sign out with proper cleanup
  Future<void> signOut({BuildContext? context}) async {
    try {
      // Clear providers data before signing out
      if (context != null) {
        // Clear user provider data
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.clear();

        // Clear course provider data
        final courseProvider =
            Provider.of<CourseProvider>(context, listen: false);
        courseProvider.clearUserData();
      }

      // Sign out from Firebase
      await _authService.signOut();
      await _googleSignIn.signOut();

      // Clear local data
      _user = null;
      _firebaseUser = null;
      _status = AuthStatus.unauthenticated;

      notifyListeners();
      AppLogger.info('User signed out successfully');
    } catch (e) {
      AppLogger.error('Sign out error', error: e);
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Password reset error', error: e);
      return false;
    }
  }

  // Resend verification email
  Future<bool> resendVerificationEmail() async {
    try {
      await _authService.sendVerificationEmail();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      AppLogger.error('Resend verification error', error: e);
      return false;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.updateUser(_user!.id, updates);
      await _loadUserData(_user!.id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      AppLogger.error('Update profile error', error: e);
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ====== Wrapper methods for compatibility with auth screens ======

  // Login method (wrapper for signIn)
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    // Save email if rememberMe is true
    if (rememberMe) {
      await _authService.saveEmail(email);
    }
    return await signIn(email: email, password: password);
  }

  // Register method (wrapper for signUp)
  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    return await signUp(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
    );
  }

  // Logout method (wrapper for signOut) - Pass context for cleanup
  Future<void> logout({BuildContext? context}) async {
    await signOut(context: context);
  }

  // Send email verification (wrapper for resendVerificationEmail)
  Future<bool> sendEmailVerification() async {
    return await resendVerificationEmail();
  }

  // Check username availability
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      return await _databaseService.checkUsernameAvailability(username);
    } catch (e) {
      AppLogger.error('Check username availability error', error: e);
      return false;
    }
  }

  // Get saved email
  Future<String?> getSavedEmail() async {
    try {
      return await _authService.getSavedEmail();
    } catch (e) {
      AppLogger.error('Get saved email error', error: e);
      return null;
    }
  }

  // Get current user
  User? get currentUser => _firebaseUser;

  // Check email verification (returns bool)
  Future<bool> checkEmailVerification() async {
    try {
      await _firebaseUser?.reload();
      _firebaseUser = FirebaseAuth.instance.currentUser;
      _updateAuthStatus();
      notifyListeners();
      return _firebaseUser?.emailVerified ?? false;
    } catch (e) {
      AppLogger.error('Check email verification error', error: e);
      return false;
    }
  }
}
