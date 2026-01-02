import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // FIX: FirebaseAnalyticsObserver is now accessed via the instance
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  // Track screen views
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
        // FIX: Cast parameters to Map<String, Object>
        parameters: parameters?.cast<String, Object>(),
      );
      print('📊 Analytics: Screen viewed - $screenName');
    } catch (e) {
      print('❌ Analytics error: $e');
    }
  }

  // Track events
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        // FIX: Cast parameters to Map<String, Object>
        parameters: parameters?.cast<String, Object>(),
      );
      print('📊 Analytics: Event - $name');
    } catch (e) {
      print('❌ Analytics error: $e');
    }
  }

  // Track user properties
  Future<void> setUserProperties({
    String? userId,
    String? userRank,
    int? completedCases,
    int? totalScore,
  }) async {
    try {
      if (userId != null) {
        await _analytics.setUserId(id: userId);
      }

      await _analytics.setUserProperty(
        name: 'rank',
        value: userRank ?? 'rookie',
      );

      await _analytics.setUserProperty(
        name: 'completed_cases',
        value: (completedCases ?? 0).toString(),
      );

      await _analytics.setUserProperty(
        name: 'total_score',
        value: (totalScore ?? 0).toString(),
      );

      print('📊 Analytics: User properties set');
    } catch (e) {
      print('❌ Analytics error: $e');
    }
  }

  // Track case events
  Future<void> logCaseStarted(int caseNumber) async {
    await logEvent(
      name: 'case_started',
      parameters: {
        'case_number': caseNumber,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logCaseCompleted({
    required int caseNumber,
    required int score,
    required int cluesFound,
    required double timeSpent,
    required double accuracy,
  }) async {
    await logEvent(
      name: 'case_completed',
      parameters: {
        'case_number': caseNumber,
        'score': score,
        'clues_found': cluesFound,
        'time_spent_minutes': timeSpent,
        'accuracy_percentage': accuracy,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logClueFound(int caseNumber, String clueType) async {
    await logEvent(
      name: 'clue_found',
      parameters: {
        'case_number': caseNumber,
        'clue_type': clueType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logPuzzleSolved({
    required String puzzleType,
    required int attempts,
    required int timeTaken,
  }) async {
    await logEvent(
      name: 'puzzle_solved',
      parameters: {
        'puzzle_type': puzzleType,
        'attempts': attempts,
        'time_taken_seconds': timeTaken,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Track authentication events
  Future<void> logLogin(String method) async {
    await logEvent(
      name: 'login',
      parameters: {
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logSignup(String method) async {
    await logEvent(
      name: 'signup',
      parameters: {
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Track app performance
  Future<void> logAppOpened() async {
    await logEvent(
      name: 'app_opened',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logAppBackgrounded() async {
    await logEvent(
      name: 'app_backgrounded',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Track errors
  Future<void> logError(String errorType, String errorMessage) async {
    await logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Track settings changes
  Future<void> logSettingsChanged({
    String? settingName,
    dynamic oldValue,
    dynamic newValue,
  }) async {
    await logEvent(
      name: 'settings_changed',
      parameters: {
        'setting_name': settingName,
        'old_value': oldValue.toString(),
        'new_value': newValue.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Get analytics instance
  FirebaseAnalytics get analytics => _analytics;
}