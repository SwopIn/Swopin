import 'package:firebase_analytics/firebase_analytics.dart';

import '../data/telegram/telegram_app.dart';

AnalyticsService get analytics => AnalyticsService._instance;

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() => _instance;

  late FirebaseAnalytics _analytics;

  AnalyticsService._internal() {
    _analytics = FirebaseAnalytics.instance;
  }

  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logDailyClaim({String? error}) async {
    await _analytics.logEvent(
        name: error == null ? 'daily_claim' : 'daily_claim_e',
        parameters: {
          "time": DateTime.now().toIso8601String(),
          "userId": telegram.userId.toString(),
          "error": error ?? 'no error'
        });
  }

  Future<void> logTaskSolve({String? error}) async {
    await _analytics.logEvent(
        name: error == null ? 'task_solve' : 'task_solve_e',
        parameters: {
          "time": DateTime.now().toIso8601String(),
          "userId": telegram.userId.toString(),
          "error": error ?? 'no error'
        });
  }

  Future<void> logRefRequest() async {
    await _analytics.logEvent(name: 'ref_request', parameters: {
      "time": DateTime.now().toIso8601String(),
      "userId": telegram.userId.toString()
    });
  }

  Future<void> logStatScreenOpen() async {
    await _analytics.logEvent(name: 'open_statistic', parameters: {
      "time": DateTime.now().toIso8601String(),
      "userId": telegram.userId.toString()
    });
  }

  Future<void> logRefScreenOpen() async {
    await _analytics.logEvent(name: 'open_referrals', parameters: {
      "time": DateTime.now().toIso8601String(),
      "userId": telegram.userId.toString()
    });
  }

  Future<void> logCommunityScreenOpen() async {
    await _analytics.logEvent(name: 'open_community', parameters: {
      "time": DateTime.now().toIso8601String(),
      "userId": telegram.userId.toString()
    });
  }

  Future<void> logErrorScreenOpen({required String error}) async {
    await _analytics.logEvent(name: 'error_screen', parameters: {
      "time": DateTime.now().toIso8601String(),
      "userId": telegram.userId.toString(),
      "error": error
    });
  }

  Future<void> logChartScreenOpen() async {
    await _analytics.logEvent(name: 'open_chart', parameters: {
      "time": DateTime.now().toIso8601String(),
      "userId": telegram.userId.toString(),
    });
  }
}
