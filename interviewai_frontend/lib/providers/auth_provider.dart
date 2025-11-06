// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:interviewai_frontend/main.dart'; // To get 'supabase'

part 'auth_provider.g.dart'; // Run 'flutter pub run build_runner build' to generate

// This provider exposes the Supabase auth state stream
@riverpod
Stream<AuthState> authState(Ref ref) {
  return supabase.auth.onAuthStateChange;
}

// This provider watches the auth state stream and exposes the current user
@riverpod
User? authUser(Ref ref) {
  // Watch the auth state stream
  final authStateAsync = ref.watch(authStateProvider);

  // Extract user from the auth state - handle AsyncValue properly
  return authStateAsync.maybeWhen(
    data: (authState) => authState.session?.user,
    orElse: () => null,
  );
}
