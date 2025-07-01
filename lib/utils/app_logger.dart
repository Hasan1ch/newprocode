import 'dart:developer' as developer;

class AppLogger {
  static bool _enableLogging = true;

  static void enable() {
    _enableLogging = true;
  }

  static void disable() {
    _enableLogging = false;
  }

  /// Log info message
  static void info(String message) {
    if (_enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      developer.log(
        '[INFO] $message',
        time: DateTime.now(),
        name: 'ProCode',
      );
      print('[$timestamp] [INFO] $message');
    }
  }

  /// Log warning message
  static void warning(String message) {
    if (_enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      developer.log(
        '[WARNING] $message',
        time: DateTime.now(),
        name: 'ProCode',
        level: 900,
      );
      print('[$timestamp] [WARNING] $message');
    }
  }

  /// Log error message with optional error object
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (_enableLogging) {
      final timestamp = DateTime.now().toIso8601String();

      // Build error message
      String fullMessage = '[ERROR] $message';
      if (error != null) {
        fullMessage += '\nError: $error';
      }

      developer.log(
        fullMessage,
        time: DateTime.now(),
        name: 'ProCode',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );

      print('[$timestamp] $fullMessage');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  /// Log debug message
  static void debug(String message) {
    if (_enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      developer.log(
        '[DEBUG] $message',
        time: DateTime.now(),
        name: 'ProCode',
        level: 500,
      );
      print('[$timestamp] [DEBUG] $message');
    }
  }

  /// Log network request
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
      info(message);
    }
  }

  /// Log authentication events
  static void auth(String event, {String? userId}) {
    if (_enableLogging) {
      String message = '[AUTH] $event';
      if (userId != null) {
        message += ' - User: $userId';
      }
      info(message);
    }
  }

  /// Log analytics events
  static void analytics(String event, {Map<String, dynamic>? parameters}) {
    if (_enableLogging) {
      String message = '[ANALYTICS] $event';
      if (parameters != null && parameters.isNotEmpty) {
        message += ' - Params: ${parameters.toString()}';
      }
      debug(message);
    }
  }
}
