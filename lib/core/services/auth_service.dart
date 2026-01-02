import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // FIX 1: Re-add the 'scopes' parameter to the GoogleSignIn constructor for older package versions.
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // ========== EMAIL/PASSWORD SIGN UP ==========
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      print('🔐 Signing up user: $email');

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('✅ User created: ${credential.user!.uid}');

      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();

      print('✅ Display name updated');

      await _saveUserToFirestore(
        uid: credential.user!.uid,
        email: email.trim(),
        displayName: displayName.trim(),
      );

      print('✅ User saved to Firestore');

      return credential.user;
    } catch (e) {
      print('❌ Sign up error: $e');
      throw _getAuthError(e.toString());
    }
  }

  // ========== EMAIL/PASSWORD SIGN IN ==========
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Signing in user: $email');

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('✅ User signed in: ${credential.user!.uid}');

      await _ensureUserExistsInFirestore(
        uid: credential.user!.uid,
        email: email.trim(),
        displayName: credential.user!.displayName ?? 'Detective',
        photoURL: credential.user!.photoURL,
      );

      print('✅ User verified in Firestore');

      return credential.user;
    } catch (e) {
      print('❌ Sign in error: $e');
      throw _getAuthError(e.toString());
    }
  }

  // ========== GOOGLE SIGN IN ==========
  Future<User?> signInWithGoogle() async {
    try {
      print('🔐 Starting Google sign in');

      // FIX 2: Call the correct signIn method for older package versions.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ Google sign in cancelled');
        throw Exception('Sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // FIX 3: For older package versions, 'accessToken' is required here.
        accessToken: googleAuth.accessToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      print('✅ Firebase Google sign in successful: ${userCredential.user!.uid}');

      await _ensureUserExistsInFirestore(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
        displayName: userCredential.user!.displayName ?? googleUser.displayName ?? 'Detective',
        photoURL: userCredential.user!.photoURL ?? googleUser.photoUrl,
      );

      print('✅ Google user verified in Firestore');

      return userCredential.user;
    } catch (e) {
      print('❌ Google sign in error: $e');
      throw _getAuthError(e.toString());
    }
  }

  // ========== PASSWORD RESET ==========
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      print('📧 Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email.trim());
      print('✅ Password reset email sent');
    } catch (e) {
      print('❌ Password reset error: $e');
      throw _getAuthError(e.toString());
    }
  }

  // ========== SIGN OUT ==========
  Future<void> signOut() async {
    try {
      print('🚪 Signing out user');
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('✅ User signed out');
    } catch (e) {
      print('❌ Sign out error: $e');
      throw Exception('Failed to sign out');
    }
  }

  // ========== DELETE ACCOUNT ==========
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      print('🗑️ Deleting account: ${user.uid}');

      await _firestore.collection('users').doc(user.uid).delete();
      print('✅ User data deleted from Firestore');

      await user.delete();
      print('✅ User account deleted from Auth');

    } catch (e) {
      print('❌ Delete account error: $e');
      throw _getAuthError(e.toString());
    }
  }

  // ========== UPDATE PROFILE ==========
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      print('📝 Updating profile for: ${user.uid}');

      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoURL != null) await user.updatePhotoURL(photoURL);

      await user.reload();

      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName.trim(),
        if (photoURL != null) 'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Profile updated successfully');

    } catch (e) {
      print('❌ Update profile error: $e');
      throw _getAuthError(e.toString());
    }
  }

  // ========== GET USER DATA ==========
  Stream<Map<String, dynamic>?> getUserData(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.exists ? snapshot.data() : null);
  }

  // ========== CHECK TERMS ACCEPTANCE ==========
  Future<bool> hasAcceptedTerms(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final acceptedTerms = doc.data()?['acceptedTerms'] as bool? ?? false;
        print('📋 Terms acceptance status for $uid: $acceptedTerms');
        return acceptedTerms;
      }
      return false;
    } catch (e) {
      print('❌ Check terms acceptance error: $e');
      return false;
    }
  }

  // ========== UPDATE TERMS ACCEPTANCE ==========
  Future<void> updateTermsAcceptance({
    required String uid,
    required bool accepted,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'acceptedTerms': accepted,
        'termsAcceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Terms acceptance updated for $uid: $accepted');
    } catch (e) {
      print('❌ Update terms acceptance error: $e');
      throw Exception('Failed to update terms acceptance');
    }
  }

  // ========== PRIVATE HELPER METHODS ==========
  Future<void> _saveUserToFirestore({
    required String uid,
    required String email,
    required String displayName,
    String? photoURL,
  }) async {
    try {
      final userData = {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'acceptedTerms': false, // NEW: Default to false for new users
        'rank': 'rookie',
        'casesCompleted': 0,
        'cluesFound': 0,
        'puzzlesSolved': 0,
        'score': 0,
        'totalPlayTime': 0,
        'achievements': [],
        'currentCase': 1,
        'currentScene': 'start',
      };

      await _firestore.collection('users').doc(uid).set(userData, SetOptions(merge: true));
      print('💾 User data saved to Firestore for: $uid');

    } catch (e) {
      print('❌ Firestore save error: $e');
      throw Exception('Failed to save user data');
    }
  }

  Future<void> _ensureUserExistsInFirestore({
    required String uid,
    required String email,
    required String displayName,
    String? photoURL,
  }) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        print('📝 Creating Firestore entry for existing user: $uid');
        await _saveUserToFirestore(
          uid: uid,
          email: email,
          displayName: displayName,
          photoURL: photoURL,
        );
      } else {
        print('✅ User already exists in Firestore: $uid');
        // Ensure acceptedTerms field exists for existing users
        final data = doc.data();
        if (data != null && !data.containsKey('acceptedTerms')) {
          await _firestore.collection('users').doc(uid).update({
            'acceptedTerms': false, // Add missing field
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('📝 Added missing acceptedTerms field for: $uid');
        } else {
          await _firestore.collection('users').doc(uid).update({
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('❌ Ensure user exists error: $e');
      throw Exception('Failed to verify user data');
    }
  }

  String _getAuthError(String error) {
    print('🔍 Parsing auth error: $error');

    if (error.contains('user-not-found') || error.contains('wrong-password')) {
      return 'Invalid email or password';
    } else if (error.contains('email-already-in-use')) {
      return 'This email is already registered. Please login instead.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Please use at least 6 characters.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address format.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled.';
    } else if (error.contains('operation-not-allowed')) {
      return 'Email/password sign-in is not enabled.';
    } else if (error.contains('requires-recent-login')) {
      return 'Please login again to perform this action.';
    } else if (error.contains('account-exists-with-different-credential')) {
      return 'An account already exists with the same email but different sign-in credentials.';
    } else if (error.contains('credential-already-in-use')) {
      return 'This credential is already associated with a different user account.';
    } else if (error.contains('provider-already-linked')) {
      return 'This provider is already linked to your account.';
    } else if (error.contains('no-such-provider')) {
      return 'This provider is not linked to your account.';
    } else if (error.contains('invalid-credential')) {
      return 'The credential is malformed or has expired.';
    }

    String cleaned = error
        .replaceAll('Exception: ', '')
        .replaceAll('FirebaseAuthException: ', '')
        .replaceAll('[firebase_auth/', '')
        .replaceAll(']', '');

    return cleaned.isNotEmpty ? cleaned : 'An error occurred. Please try again.';
  }

  // ========== PROGRESS & GAME DATA METHODS ==========
  Future<void> updateProgress({
    int? casesCompleted,
    int? cluesFound,
    int? puzzlesSolved,
    int? score,
    int? playTime,
    String? rank,
    int? currentCase,
    String? currentScene,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final updates = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};

      if (casesCompleted != null) updates['casesCompleted'] = FieldValue.increment(casesCompleted);
      if (cluesFound != null) updates['cluesFound'] = FieldValue.increment(cluesFound);
      if (puzzlesSolved != null) updates['puzzlesSolved'] = FieldValue.increment(puzzlesSolved);
      if (score != null) updates['score'] = FieldValue.increment(score);
      if (playTime != null) updates['totalPlayTime'] = FieldValue.increment(playTime);
      if (rank != null) updates['rank'] = rank;
      if (currentCase != null) updates['currentCase'] = currentCase;
      if (currentScene != null) updates['currentScene'] = currentScene;

      await _firestore.collection('users').doc(user.uid).update(updates);
      print('📊 Progress updated for user: ${user.uid}');
    } catch (e) {
      print('❌ Update progress error: $e');
      throw Exception('Failed to update progress');
    }
  }

  Future<void> addAchievement(String achievementId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await _firestore.collection('users').doc(user.uid).update({
        'updatedAt': FieldValue.serverTimestamp(),
        'achievements': FieldValue.arrayUnion([achievementId]),
      });

      print('🏆 Achievement added: $achievementId for user: ${user.uid}');
    } catch (e) {
      print('❌ Add achievement error: $e');
      throw Exception('Failed to add achievement');
    }
  }

  // ========== CHECK USER EXISTS ==========
  // FIX 4: Use the older 'fetchSignInMethodsForEmail' method name.
  Future<bool> userExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email.trim()); //<- OLDER METHOD NAME
      return methods.isNotEmpty;
    } catch (e) {
      print('❌ Check user exists error: $e');
      // Return false on error to avoid blocking sign-up flows.
      return false;
    }
  }

  // ========== GET TERMS ACCEPTANCE STREAM ==========
  Stream<bool> getTermsAcceptanceStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data()?['acceptedTerms'] as bool? ?? false;
      }
      return false;
    });
  }
}