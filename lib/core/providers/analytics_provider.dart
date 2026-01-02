import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; // FIX: Add this import
import 'package:case_zero_detective/core/services/analytics_service.dart';

// Analytics Service Provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

// Analytics Observer Provider (for routing)
// FIX: Ensure FirebaseAnalyticsObserver is imported from firebase_analytics
final analyticsObserverProvider = Provider<FirebaseAnalyticsObserver>((ref) {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.observer;
});

// User Analytics Provider
final userAnalyticsProvider = Provider.family<void, Map<String, dynamic>>((ref, userData) {
  final analyticsService = ref.watch(analyticsServiceProvider);

  analyticsService.setUserProperties(
    userId: userData['uid'],
    userRank: userData['rank'],
    completedCases: userData['casesCompleted'],
    totalScore: userData['score'],
  );
});