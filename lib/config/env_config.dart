import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  // Firebase Configuration
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAuthDomain =>
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  // API Keys
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get judge0ApiKey => dotenv.env['JUDGE0_API_KEY'] ?? '';
  static String get judge0BaseUrl =>
      dotenv.env['JUDGE0_BASE_URL'] ?? 'https://judge0-ce.p.rapidapi.com';

  // Environment
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'production';

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';

  static bool get hasGeminiApiKey => geminiApiKey.isNotEmpty;
  static bool get hasJudge0ApiKey => judge0ApiKey.isNotEmpty;
}
