import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './auth_provider.dart';

// Terms Guard State
enum TermsGuardState {
  checking,
  accepted,
  notAccepted,
  error,
}

// Terms Guard Provider
final termsGuardProvider = StreamProvider<TermsGuardState>((ref) async* {
  final authState = ref.watch(authStateProvider);

  yield TermsGuardState.checking;

  // Wait for auth state to be loaded
  await Future.delayed(const Duration(milliseconds: 500));

  final user = authState.value;

  if (user == null) {
    // No user logged in, no need to check terms
    yield TermsGuardState.accepted;
    return;
  }

  try {
    // Get terms acceptance from user profile
    final profile = ref.watch(userProfileProvider);

    yield* profile.when(
      data: (doc) {
        if (doc.exists) {
          final acceptedTerms = doc.data()?['acceptedTerms'] as bool? ?? false;
          return Stream.value(acceptedTerms ?
          TermsGuardState.accepted :
          TermsGuardState.notAccepted);
        }
        return Stream.value(TermsGuardState.notAccepted);
      },
      loading: () => Stream.value(TermsGuardState.checking),
      error: (error, stackTrace) => Stream.value(TermsGuardState.error),
    );

  } catch (e) {
    yield TermsGuardState.error;
  }
});

// Terms Check Required Provider
final termsCheckRequiredProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  final termsState = ref.watch(termsGuardProvider);

  // If user is logged in and hasn't accepted terms, check is required
  if (authState.value != null) {
    return termsState.when(
      data: (state) => state == TermsGuardState.notAccepted,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  return false;
});