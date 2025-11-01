// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DatabaseService _dbService = DatabaseService();

  // Sign up with email and password
  Future<AuthResponse?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // Store user data in database
      if (response.user != null) {
        await _dbService.createUserProfile(
          userId: response.user!.id,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
        );
      }

      print('User account created: ${response.user?.email}');
      return response;
    } on AuthException catch (e) {
      print('Supabase Auth Exception during signup: ${e.message}');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('User signed in: ${response.user?.email}');
      return response;
    } on AuthException catch (e) {
      print('Supabase Auth Exception during sign in: ${e.message}');
      rethrow;
    }
  }

  // Sign in with Google (OAuth)
  Future<bool> signInWithGoogle() async {
    try {
      final bool response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
      );
      print('Signed in user with Google');
      return response;
    } on AuthException catch (e) {
      print('Supabase Auth Exception during Google sign in: ${e.message}');
      return false;
    } catch (e) {
      print('Error during Google sign in: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      print('User signed out.');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      print('Password reset email sent to: $email');
    } on AuthException catch (e) {
      print('Error sending password reset email: ${e.message}');
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Supabase handles email verification differently
        // The email is verified after the user confirms via email link
        print('Verification email will be sent to: ${user.email}');
      }
    } catch (e) {
      print('Error sending email verification: $e');
      rethrow;
    }
  }

  // Check if email is verified
  bool isEmailVerified() {
    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}
