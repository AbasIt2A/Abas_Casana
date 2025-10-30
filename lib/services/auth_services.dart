// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // For web check
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Initialize GoogleSignIn with required scopes
  static final GoogleSignIn _googleSignIn = GoogleSignIn.standard();

  final DatabaseService _dbService = DatabaseService();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile with full name
      await userCredential.user?.updateDisplayName(fullName);

      // Store user data in Firestore
      if (userCredential.user != null) {
        await _dbService.createUserProfile(
          userId: userCredential.user!.uid,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
        );
      }

      print('User account created: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception during signup: ${e.message}');
      rethrow; // Rethrow to handle in UI
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User signed in: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception during sign in: ${e.message}');
      rethrow; // Rethrow to handle in UI
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web sign-in
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        print('Signed in user (web): ${userCredential.user?.displayName}');
        return userCredential;
      } else {
        // Mobile sign-in
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          print('Google sign in cancelled by user');
          return null;
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        if (googleAuth.idToken == null) {
          print('Google sign in failed: idToken is null');
          return null;
        }
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        print('Signed in user: ${userCredential.user?.displayName}');
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception during Google sign in: ${e.message}');
      return null;
    } catch (e) {
      print('Error during Google sign in: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      print('User signed out.');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Auth state changes stream - listens for login/logout events
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      print('Error sending password reset email: ${e.message}');
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('Email verification sent to: ${user.email}');
      }
    } on FirebaseAuthException catch (e) {
      print('Error sending email verification: ${e.message}');
      rethrow;
    }
  }

  // Check if email is verified
  bool isEmailVerified() {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}