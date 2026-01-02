import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firebase Auth State
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges; // FIXED: Changed from authStateChange to authStateChanges
});

// Auth Loading State
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoading;
});

// Current Firebase User
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

// Firestore User Profile Provider
final userProfileProvider = StreamProvider<DocumentSnapshot<Map<String, dynamic>>>((ref) {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return const Stream.empty();
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots();
});

// User Data Provider
final userDataProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const Stream.empty();
  }
  final authService = ref.watch(authServiceProvider);
  return authService.getUserData(user.uid);
});

// Terms Acceptance Provider
final termsAcceptanceProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return const Stream.empty();
  }

  final authService = ref.watch(authServiceProvider);
  return authService.getTermsAcceptanceStream(user.uid);
});

// Has Accepted Terms Provider
final hasAcceptedTermsProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return false;
  }

  final authService = ref.watch(authServiceProvider);
  return await authService.hasAcceptedTerms(user.uid);
});

// Update Terms Acceptance Provider
final updateTermsProvider = FutureProvider.family<void, bool>((ref, accepted) async {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    throw Exception('No user logged in');
  }

  final authService = ref.watch(authServiceProvider);
  await authService.updateTermsAcceptance(
    uid: user.uid,
    accepted: accepted,
  );
});