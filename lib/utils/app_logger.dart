import 'dart:developer' as developer;

/// Centralized logging utility for debugging and monitoring
/// This logger provides consistent logging across the app with different severity levels
/// Uses both developer console and print statements for maximum visibility
class AppLogger {
  // Toggle to enable/disable all logging - useful for production builds
  static bool _enableLogging = true;

  /// Enables logging output
  /// Call this during development or when debugging issues
  static void enable() {
    _enableLogging = true;
  }

  /// Disables all logging output
  /// Use this in production to improve performance and security
  static void disable() {
    _enableLogging = false;
  }

  /// Logs informational messages for general app flow
  /// Use this for tracking normal operations and state changes
  static void info(String message) {
    if (_enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      // Use Flutter's developer.log for better debugging experience
      developer.log(
        '[INFO] $message',
        time: DateTime.now(),
        name: 'ProCode',
      );
      // Also print to console for visibility in terminal
      print('[$timestamp] [INFO] $message');
    }
  }

  /// Logs warning messages for potentially problematic situations
  /// Use when something unexpected happens but app can continue
  static void warning(String message) {
    if (_enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      developer.log(
        '[WARNING] $message',
        time: DateTime.now(),
        name: 'ProCode',
        level: 900, // Higher level for warnings
      );
      print('[$timestamp] [WARNING] $message');
    }
  }

  /// Logs error messages with optional error object and stack trace
  /// Critical for debugging crashes and exceptions
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (_enableLogging) {
      final timestamp = DateTime.now().toIso8601String();

      // Build comprehensive error message
      String fullMessage = '[ERROR] $message';
      if (error != null) {
        fullMessage += '\nError: $error';
      }

      // Log to developer console with full error context
      developer.log(
        fullMessage,
        time: DateTime.now(),
        name: 'ProCode',
        level: 1000, // Highest level for errors
        error: error,
        stackTrace: stackTrace,
      );

      // Also print for terminal visibility
      print('[$timestamp] $fullMessage');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  /// Logs debug messages for detailed troubleshooting
  /// Use liberally during development, removed in production
  static void debug(String message) {
    if (_enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      developer.log(
        '[DEBUG] $message',
        time: DateTime.now(),
        name: 'ProCode',
        level: 500, // Lower level for debug messages
      );
      print('[$timestamp] [DEBUG] $message');
    }
  }

  /// Specialized logger for network requests
  /// Tracks API calls for debugging connectivity issues
  static void network(String method, String url,
      {int? statusCode, dynamic body}) {
    if (_enableLogging) {
      String message = '[NETWORK] $method $url';
      if (statusCode != null) {
        message += ' - Status: $statusCode';
      }
      if (body != null) {
        message += '\nBody: $body';
      }
      // Reuse info logger for network messages
      info(message);
    }
  }

  /// Tracks authentication events for security monitoring
  /// Helps debug login issues and track user sessions
  static void auth(String event, {String? userId}) {
    if (_enableLogging) {
      String message = '[AUTH] $event';
      if (userId != null) {
        message += ' - User: $userId';
      }
      info(message);
    }
  }

  /// Logs analytics events for behavior tracking
  /// Useful for understanding user interactions and app usage
  static void analytics(String event, {Map<String, dynamic>? parameters}) {
    if (_enableLogging) {
      String message = '[ANALYTICS] $event';
      if (parameters != null && parameters.isNotEmpty) {
        message += ' - Params: ${parameters.toString()}';
      }
      // Use debug level for analytics to reduce noise
      debug(message);
    }
  }
}
