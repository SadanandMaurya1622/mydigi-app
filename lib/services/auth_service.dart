import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import 'firestore_service.dart';

/// Service responsible for managing Firebase Authentication and Google Sign-In.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '740310683452-f32uo8c3k1hkrhele1mu4gjik439kh1t.apps.googleusercontent.com',
    scopes: <String>[
      'email',
      'profile',
    ],
  );

  /// Current authenticated Firebase User (or null if signed out)
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in using Google OAuth Credentials via Firebase
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger the interactive Google Sign-In flow directly
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
      final user = userCredential.user;
      debugPrint('[AuthService] Successfully signed in via Google: ${user?.email}');

      // 5. Asynchronously create/update User record in Cloud Firestore & RTDB without blocking navigation
      if (user != null) {
        final realName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
            ? user.displayName!.trim()
            : (googleUser.displayName != null && googleUser.displayName!.trim().isNotEmpty)
                ? googleUser.displayName!.trim()
                : (user.email != null && user.email!.contains('@'))
                    ? user.email!.split('@').first
                    : 'Google User';

        final realEmail = user.email ?? googleUser.email;
        final realPhoto = user.photoURL ?? googleUser.photoUrl;

        // Background save (non-blocking)
        FirestoreService().saveUserProfile(
          UserProfile(
            name: realName,
            email: realEmail,
            phone: user.phoneNumber ?? '',
            photoUrl: realPhoto,
            uid: user.uid,
            isPro: true,
          ),
        );
      }

      return userCredential;
    } catch (e) {
      debugPrint('[AuthService] Unexpected error during Google Sign-In: $e');
      rethrow;
    }
  }

  /// Sign in or register instantly with Firebase Authentication (creates real user in Firebase Auth Console)
  Future<UserCredential> quickFirebaseLogin({
    String name = 'Sadanand Maurya',
    String email = 'sadanandmaurya.rj@gmail.com',
    String phone = '+91 98200 12345',
  }) async {
    UserCredential userCredential;
    const defaultPass = 'MyDigi@2026Secure!';

    try {
      // 1. Attempt creating new Firebase Auth user with Email & Password
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: defaultPass,
      );
      debugPrint('[AuthService] New Firebase Auth user created: ${userCredential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // User already exists in Firebase Auth, sign in
        debugPrint('[AuthService] Email already exists, logging in with Firebase Auth...');
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: defaultPass,
        );
      } else if (e.code == 'operation-not-allowed' || e.code == 'admin-restricted-operation') {
        // If email/password provider is not yet enabled in Firebase Console, fallback to Anonymous Auth
        debugPrint('[AuthService] Email auth disabled in console, using Firebase Anonymous Auth...');
        userCredential = await _auth.signInAnonymously();
      } else {
        debugPrint('[AuthService] Firebase Auth error ($e), attempting Anonymous Auth fallback...');
        userCredential = await _auth.signInAnonymously();
      }
    } catch (e) {
      debugPrint('[AuthService] General error during Firebase quick login, falling back to Anonymous: $e');
      userCredential = await _auth.signInAnonymously();
    }

    final user = userCredential.user;
    if (user != null) {
      try {
        await user.updateDisplayName(name);
      } catch (_) {}

      // Save user profile to Cloud Firestore
      await FirestoreService().saveUserProfile(
        UserProfile(
          name: name,
          email: (user.email != null && user.email!.isNotEmpty) ? user.email! : email,
          phone: phone,
          photoUrl: user.photoURL,
          uid: user.uid,
          isPro: true,
        ),
      );
    }

    return userCredential;
  }

  /// Sign Up with Email and Password in Firebase Authentication
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      try {
        await user.updateDisplayName(name.trim());
      } catch (_) {}

      await FirestoreService().saveUserProfile(
        UserProfile(
          name: name.trim(),
          email: email.trim(),
          phone: phone?.trim() ?? '',
          photoUrl: null,
          uid: user.uid,
          isPro: true,
        ),
      );
    }

    return userCredential;
  }

  /// Sign In with Email and Password in Firebase Authentication
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      final existingProfile = await FirestoreService().fetchUserProfile(user.uid);
      if (existingProfile == null) {
        await FirestoreService().saveUserProfile(
          UserProfile(
            name: user.displayName ?? email.split('@').first,
            email: user.email ?? email,
            phone: user.phoneNumber ?? '',
            photoUrl: user.photoURL,
            uid: user.uid,
            isPro: true,
          ),
        );
      }
    }

    return userCredential;
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
