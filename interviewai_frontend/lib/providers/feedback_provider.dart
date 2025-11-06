// lib/providers/feedback_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:interviewai_frontend/providers/interviews_provider.dart'; // To get ApiService
import 'package:interviewai_frontend/main.dart';
import 'package:logger/logger.dart';

part 'feedback_provider.g.dart'; // Run build_runner

final _logger = Logger();

// This provider will fetch the feedback by its ID
@riverpod
Future<Map<String, dynamic>> feedbackDetails(
  Ref ref, {
  required String feedbackId,
}) {
  final api = ref.watch(apiServiceProvider);
  return api.getFeedback(feedbackId);
}

// This provider will fetch the feedback for a specific interview
@riverpod
Future<Map<String, dynamic>?> feedbackForInterview(
  Ref ref,
  String interviewId,
) {
  final api = ref.watch(apiServiceProvider);
  // This will return the feedback map, or null if 404
  return api.getFeedbackByInterviewId(interviewId);
}

// This provider fetches ALL feedback for the current user from Supabase
// Returns a Map where the key is the interview_id and value is the feedback data
@riverpod
Future<Map<String, Map<String, dynamic>>> allUserFeedback(Ref ref) async {
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return {};
  }

  try {
    _logger.i('🔍 Fetching feedback for user: $userId');

    // OPTIMIZED: Direct query with user_id (no need to fetch interviews first)
    final feedbackResponse = await supabase
        .from('feedback')
        .select()
        .eq('user_id', userId)
        .order('generated_at', ascending: false);

    _logger.d('📊 Feedback response count: ${feedbackResponse.length}');
    _logger.d('📊 Raw feedback data: $feedbackResponse');

    // Convert the list to a Map indexed by interview_id for easy lookup
    final feedbackMap = <String, Map<String, dynamic>>{};
    for (var feedback in feedbackResponse) {
      // Handle both string and UUID formats for interview_id
      var interviewId = feedback['interview_id'];
      String? interviewIdStr;

      if (interviewId is String) {
        interviewIdStr = interviewId;
      } else if (interviewId != null) {
        interviewIdStr = interviewId.toString();
      }

      _logger.d(
        'Processing feedback - interview_id: $interviewIdStr, score: ${feedback['overall_score']}',
      );

      if (interviewIdStr != null &&
          interviewIdStr.isNotEmpty &&
          interviewIdStr != 'null') {
        feedbackMap[interviewIdStr] = {
          'id': feedback['id'],
          'overallScore': feedback['overall_score'],
          'strengths': feedback['strengths'],
          'weaknesses': feedback['areas_for_improvement'],
          'recommendations':
              feedback['areas_for_improvement'], // Using same field
          'generated_at':
              feedback['generated_at'], // Keep original field name for dashboard
          'createdAt': feedback['generated_at'], // Also add for compatibility
        };
      }
    }

    _logger.i('✅ Final feedback map keys: ${feedbackMap.keys.toList()}');
    return feedbackMap;
  } catch (e, stackTrace) {
    _logger.e('❌ Error fetching all user feedback: $e');
    _logger.e('Stack trace: $stackTrace');
    return {};
  }
}
