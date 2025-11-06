// lib/providers/interviews_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:interviewai_frontend/services/api_service.dart';
import 'package:interviewai_frontend/main.dart';

part 'interviews_provider.g.dart'; // Run build_runner

// Provide an instance of our ApiService
@riverpod
ApiService apiService(Ref ref) {
  return ApiService();
}

// This provider will handle the "Create Interview" logic
@riverpod
class InterviewNotifier extends _$InterviewNotifier {
  @override
  Future<Map<String, dynamic>?> build() async {
    // Initial state is null (no interview created yet)
    return null;
  }

  // Method to call when the user clicks "Start"
  Future<void> createInterview({
    required String title,
    required String role,
    required String experienceLevel,
  }) async {
    // Set state to loading
    state = const AsyncValue.loading();

    // Get the ApiService
    final api = ref.read(apiServiceProvider);

    // Call the API and update the state
    state = await AsyncValue.guard(() {
      return api.generateInterview(
        title: title,
        role: role,
        experienceLevel: experienceLevel,
      );
    });
  }
}

// --- NEW PROVIDER FOR REAL-TIME INTERVIEWS LIST ---
@riverpod
Stream<List<Map<String, dynamic>>> interviewsList(Ref ref) {
  // Get the Supabase client and user
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    // If user is logged out, return an empty stream
    return Stream.value([]);
  }

  // 1. Create a stream that listens to the 'interviews' table
  final stream = supabase
      .from('interviews')
      .stream(primaryKey: ['id']) // Listen for changes
      .eq('user_id', userId) // Only for this user
      .order('created_at', ascending: false); // Newest first

  // 2. Map the stream of raw data into a List<Map>
  return stream.map((data) {
    return data.map((item) => item).toList();
  });
}
