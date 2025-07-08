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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    AppLogger.info('Environment loaded successfully');

    // Verify critical environment variables
    final geminiKey = dotenv.env['GEMINI_API_KEY'];
    final judge0Key = dotenv.env['JUDGE0_API_KEY'];

    if (geminiKey == null || geminiKey.isEmpty) {
      AppLogger.error('GEMINI_API_KEY is missing in .env file');
    } else {
      AppLogger.info('GEMINI_API_KEY loaded successfully');
    }

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

  // Initialize Firebase
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
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(const ProCodeApp());
}

class ProCodeApp extends StatelessWidget {
  const ProCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'ProCode - Learn Programming Through Gaming',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            scaffoldMessengerKey: NotificationService.messengerKey,
            initialRoute: Routes.splash,
            routes: {
              Routes.splash: (context) => const SplashScreen(),
              Routes.login: (context) => const LoginScreen(),
              Routes.register: (context) => const RegisterScreen(),
              Routes.verifyEmail: (context) => const VerifyEmailScreen(),
              Routes.forgotPassword: (context) => const ForgotPasswordScreen(),
              Routes.dashboard: (context) => const DashboardScreen(),
              Routes.courses: (context) => const CoursesListScreen(),
              Routes.codeEditor: (context) => const CodeEditorScreen(),
              Routes.quiz: (context) => const QuizCategoriesScreen(),
              Routes.leaderboard: (context) => const LeaderboardScreen(),
              Routes.profile: (context) => const ProfileScreen(),
              Routes.settings: (context) => const SettingsScreen(),
              Routes.aiAdvisor: (context) => const AIAdvisorScreen(),
            },
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
