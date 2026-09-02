import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Service responsible for managing Firebase Authentication and Google Sign-In.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

  /// Current authenticated Firebase User (or null if signed out)
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in using Google OAuth Credentials via Firebase
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger the interactive Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User aborted the Google Sign-In selection
        debugPrint('[AuthService] Google sign-in was cancelled by the user.');
        return null;
      }

      // 2. Obtain authentication tokens (ID Token and Access Token)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a Firebase credential with the tokens
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Authenticate with Firebase using the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      debugPrint('[AuthService] Successfully signed in: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] FirebaseAuthException [${e.code}]: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] Unexpected error during Google Sign-In: $e');
      rethrow;
    }
  }

  /// Sign out from both Firebase and Google
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      debugPrint('[AuthService] Successfully signed out.');
    } catch (e) {
      debugPrint('[AuthService] Error during sign out: $e');
    }
  }
}
