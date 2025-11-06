// lib/providers/resume_builder_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:interviewai_frontend/providers/interviews_provider.dart';

part 'resume_builder_provider.g.dart';

// --- Provider to expose Supabase client ---
@riverpod
SupabaseClient supabase(Ref ref) {
  return Supabase.instance.client;
}

// --- Provider to call the "build" endpoint ---
@riverpod
class ResumeBuilder extends _$ResumeBuilder {
  @override
  Future<Map<String, dynamic>?> build() async {
    return null; // Initial state
  }

  /// Calls the backend to build a resume with AI enhancement
  Future<Map<String, dynamic>?> buildResume(
    Map<String, dynamic> formData,
  ) async {
    state = const AsyncValue.loading();

    final api = ref.read(apiServiceProvider);

    state = await AsyncValue.guard(() async {
      return await api.buildResume(formData);
    });

    return state.value;
  }

  /// Resets the state back to null
  void reset() {
    state = const AsyncValue.data(null);
  }
}

// --- Provider to get all built resumes for the dashboard ---
@riverpod
Stream<List<Map<String, dynamic>>> builtResumesList(Ref ref) {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return Stream.value([]);
  }

  return supabase
      .from('built_resumes')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .map(
        (data) => data.map((item) => Map<String, dynamic>.from(item)).toList(),
      );
}

// --- Provider to get a single resume for the display page ---
@riverpod
Future<Map<String, dynamic>> builtResumeDetails(
  Ref ref,
  String resumeId,
) async {
  final supabase = ref.watch(supabaseProvider);

  final response = await supabase
      .from('built_resumes')
      .select()
      .eq('id', resumeId)
      .single();

  return Map<String, dynamic>.from(response);
}

// --- Provider to delete a resume ---
@riverpod
class ResumeDeleter extends _$ResumeDeleter {
  @override
  Future<bool> build() async {
    return false;
  }

  Future<bool> deleteResume(String resumeId) async {
    state = const AsyncValue.loading();

    final supabase = ref.read(supabaseProvider);

    state = await AsyncValue.guard(() async {
      await supabase.from('built_resumes').delete().eq('id', resumeId);
      return true;
    });

    return state.value ?? false;
  }
}
