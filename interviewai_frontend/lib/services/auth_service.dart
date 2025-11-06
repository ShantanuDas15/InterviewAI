// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:interviewai_frontend/main.dart'; // To get 'supabase'

class AuthService {
  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // This is the URL Supabase will redirect back to
        redirectTo: kIsWeb ? null : 'io.supabase.interviewai://login-callback/',
      );
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
    }
  }

  // --- ADD THIS METHOD ---
  // We don't use try/catch here; we'll let the UI catch AuthException
  Future<void> signInWithEmailPassword(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  // --- AND ADD THIS METHOD ---
  Future<void> signUpWithEmailPassword(String email, String password) async {
    // Supabase will send a confirmation email
    await supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
