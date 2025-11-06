// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interviewai_frontend/constants/api_constants.dart';
import 'package:interviewai_frontend/main.dart'; // For supabase client

class ApiService {
  final String _baseUrl = ApiConstants.apiBaseUrl;

  // Helper method to get the authenticated headers
  Future<Map<String, String>> _getHeaders() async {
    final session = supabase.auth.currentSession;
    if (session == null) {
      throw Exception('Not authenticated');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  // --- API Methods ---

  // Corresponds to POST /api/interviews/generate
  Future<Map<String, dynamic>> generateInterview({
    required String title,
    required String role,
    required String experienceLevel,
  }) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'title': title,
      'role': role,
      'experienceLevel': experienceLevel,
    });

    final response = await http.post(
      Uri.parse(_baseUrl + ApiConstants.generateInterviewEndpoint),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate interview: ${response.body}');
    }
  }

  // Corresponds to POST /api/feedback
  Future<Map<String, dynamic>> submitFeedback({
    required String interviewId,
    required String transcript,
  }) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'interviewId': interviewId,
      'transcript': transcript,
    });

    final response = await http.post(
      Uri.parse(_baseUrl + ApiConstants.feedbackEndpoint),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Try to parse the Spring Boot error JSON
      try {
        final errorBody = jsonDecode(response.body);
        // "message" is the default key for Spring Boot exceptions
        final errorMessage =
            errorBody['message'] ?? 'An unknown server error occurred.';
        throw Exception(errorMessage);
      } catch (e) {
        // If parsing fails, check if we already have an Exception with a message
        if (e is Exception && e.toString().startsWith('Exception: ')) {
          rethrow;
        }
        // Otherwise, use the status code
        throw Exception(
          'Failed to submit feedback. Server responded with ${response.statusCode}',
        );
      }
    }
  }

  // Corresponds to GET /api/feedback/{id}
  Future<Map<String, dynamic>> getFeedback(String feedbackId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/feedback/$feedbackId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get feedback: ${response.body}');
    }
  }

  // Corresponds to GET /api/feedback/for-interview/{interviewId}
  Future<Map<String, dynamic>?> getFeedbackByInterviewId(
    String interviewId,
  ) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/feedback/for-interview/$interviewId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      // It's not an error if feedback doesn't exist yet
      return null;
    } else {
      throw Exception('Failed to get feedback: ${response.body}');
    }
  }

  // Corresponds to POST /api/resume/analyze
  Future<Map<String, dynamic>> analyzeResume(String resumeId) async {
    final headers = await _getHeaders();
    final body = jsonEncode({'resumeId': resumeId});

    final response = await http.post(
      Uri.parse('$_baseUrl/api/resume/analyze'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to analyze resume: ${response.body}');
    }
  }

  // Corresponds to POST /api/resume-builder/build
  Future<Map<String, dynamic>> buildResume(
    Map<String, dynamic> formData,
  ) async {
    final headers = await _getHeaders();
    final body = jsonEncode(formData);

    final response = await http.post(
      Uri.parse('$_baseUrl/api/resume-builder/build'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to build resume: ${response.body}');
    }
  }

  // Corresponds to GET /api/resume-builder/my-resumes
  Future<List<Map<String, dynamic>>> getMyResumes() async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/resume-builder/my-resumes'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to get resumes: ${response.body}');
    }
  }

  // Corresponds to GET /api/resume-builder/{id}
  Future<Map<String, dynamic>> getResumeById(String resumeId) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/resume-builder/$resumeId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Resume not found');
    } else {
      throw Exception('Failed to get resume: ${response.body}');
    }
  }

  // Corresponds to DELETE /api/resume-builder/{id}
  Future<void> deleteResume(String resumeId) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/resume-builder/$resumeId'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete resume: ${response.body}');
    }
  }
}
