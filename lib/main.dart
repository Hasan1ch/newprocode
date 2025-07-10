import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:procode/config/theme.dart';
import 'package:procode/firebase_options.dart';
import 'package:procode/config/routes.dart';
import 'package:procode/providers/auth_provider.dart' as app_auth;
import 'package:procode/providers/theme_provider.dart';
import 'package:procode/providers/navigation_provider.dart';
import 'package:procode/providers/user_provider.dart';
import 'package:procode/providers/course_provider.dart';
import 'package:procode/providers/quiz_provider.dart';
import 'package:procode/providers/leaderboard_provider.dart';
import 'package:procode/services/notification_service.dart';
import 'package:procode/screens/splash/splash_screen.dart';
import 'package:procode/screens/auth/login_screen.dart';
import 'package:procode/screens/auth/register_screen.dart';
import 'package:procode/screens/auth/verify_email_screen.dart';
import 'package:procode/screens/auth/forgot_password_screen.dart';
import 'package:procode/screens/dashboard/dashboard_screen.dart';
import 'package:procode/screens/courses/courses_list_screen.dart';
import 'package:procode/screens/profile/profile_screen.dart';
import 'package:procode/screens/leaderboard/leaderboard_screen.dart';
import 'package:procode/screens/settings/settings_screen.dart';
import 'package:procode/screens/code_editor/code_editor_screen.dart';
import 'package:procode/screens/quiz/quiz_categories_screen.dart';
import 'package:procode/screens/ai_advisor/ai_advisor_screen.dart';
import 'package:procode/utils/app_logger.dart';

/// Main entry point for ProCode application
/// Initializes all required services before running the app
void main() async {
  // Ensure Flutter bindings are initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables for API keys and configuration
  try {
    await dotenv.load(fileName: ".env");
    AppLogger.info('Environment loaded successfully');

    // Verify critical API keys are present
    final geminiKey = dotenv.env['GEMINI_API_KEY'];
    final judge0Key = dotenv.env['JUDGE0_API_KEY'];

    // Check Gemini API key for AI features
    if (geminiKey == null || geminiKey.isEmpty) {
      AppLogger.error('GEMINI_API_KEY is missing in .env file');
    } else {
      AppLogger.info('GEMINI_API_KEY loaded successfully');
    }

    // Check Judge0 API key for code execution
    if (judge0Key == null || judge0Key.isEmpty) {
      AppLogger.error('JUDGE0_API_KEY is missing in .env file');
    } else {
      AppLogger.info('JUDGE0_API_KEY loaded successfully');
    }
  } catch (e) {
    AppLogger.error('Failed to load .env file', error: e);
    // Continue running the app even if .env fails to load
    // The app will use fallback responses for AI features
  }

  // Initialize Firebase for authentication and database
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('Firebase initialized successfully');
  } catch (e) {
    AppLogger.error('Failed to initialize Firebase', error: e);
  }

  // Configure Firestore for optimal performance
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // Enable offline support
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Unlimited cache
  );

  // Initialize notification service for in-app notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Run the main app
  runApp(const ProCodeApp());
}

/// Root widget of the ProCode application
/// Sets up providers, theming, and routing
class ProCodeApp extends StatelessWidget {
  const ProCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider setup for state management
    return MultiProvider(
      providers: [
        // Authentication state management
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        // Theme preferences (light/dark mode)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Bottom navigation state
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        // User profile and stats
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Course content and progress
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        // Quiz state and results
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        // Leaderboard rankings
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ProCode - Learn Programming Through Gaming',
            debugShowCheckedModeBanner: false, // Remove debug banner

            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode, // Dynamic theme switching

            // Global scaffold messenger for notifications
            scaffoldMessengerKey: NotificationService.messengerKey,

            // Routing configuration
            initialRoute: Routes.splash,
            routes: {
              // Authentication flow
              Routes.splash: (context) => const SplashScreen(),
              Routes.login: (context) => const LoginScreen(),
              Routes.register: (context) => const RegisterScreen(),
              Routes.verifyEmail: (context) => const VerifyEmailScreen(),
              Routes.forgotPassword: (context) => const ForgotPasswordScreen(),

              // Main app screens
              Routes.dashboard: (context) => const DashboardScreen(),
              Routes.courses: (context) => const CoursesListScreen(),
              Routes.codeEditor: (context) => const CodeEditorScreen(),
              Routes.quiz: (context) => const QuizCategoriesScreen(),
              Routes.leaderboard: (context) => const LeaderboardScreen(),
              Routes.profile: (context) => const ProfileScreen(),
              Routes.settings: (context) => const SettingsScreen(),
              Routes.aiAdvisor: (context) => const AIAdvisorScreen(),
            },

            // Fallback for unknown routes
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
