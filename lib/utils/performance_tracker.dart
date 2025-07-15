import 'package:procode/utils/app_logger.dart';

class PerformanceTracker {
  static final Map<String, int> _pageTimes = {};
  static final Map<String, List<int>> _apiTimes = {};
  static DateTime? _sessionStartTime;

  static void initSession() {
    _sessionStartTime = DateTime.now();
    print('🚀 Performance tracking session started');
  }

  static void trackPageLoad(String pageName, int loadTimeMs) {
    _pageTimes[pageName] = loadTimeMs;
    print('📱 $pageName loaded in: ${loadTimeMs}ms');
  }

  static void trackApiCall(String apiName, int responseTimeMs) {
    if (!_apiTimes.containsKey(apiName)) {
      _apiTimes[apiName] = [];
    }
    _apiTimes[apiName]!.add(responseTimeMs);
    print('⚡ $apiName API call: ${responseTimeMs}ms');
  }

  static void printSummary() {
    print('\n' + '=' * 50);
    print('📊 PERFORMANCE METRICS SUMMARY');
    print('=' * 50);

    if (_pageTimes.isNotEmpty) {
      print('\n📱 Page Load Times:');
      _pageTimes.forEach((page, time) {
        print('  $page: ${time}ms');
      });

      final avgPageTime =
          _pageTimes.values.reduce((a, b) => a + b) / _pageTimes.length;
      print('  Average: ${avgPageTime.toStringAsFixed(0)}ms');
    }

    if (_apiTimes.isNotEmpty) {
      print('\n🔌 API Response Times:');
      _apiTimes.forEach((api, times) {
        final avg = times.reduce((a, b) => a + b) / times.length;
        print('  $api: ${avg.toStringAsFixed(0)}ms (${times.length} calls)');
      });
    }

    print('=' * 50 + '\n');
  }
}
