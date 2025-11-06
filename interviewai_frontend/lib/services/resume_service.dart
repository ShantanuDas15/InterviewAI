// lib/services/resume_service.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interviewai_frontend/main.dart'; // For supabase
import 'package:interviewai_frontend/providers/interviews_provider.dart'; // For apiServiceProvider
import 'package:interviewai_frontend/services/api_service.dart'; // For ApiService
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For FileOptions

final resumeServiceProvider = Provider((ref) {
  return ResumeService(apiService: ref.watch(apiServiceProvider));
});

class ResumeService {
  final ApiService _apiService;

  // Constants for file validation
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

  ResumeService({required ApiService apiService}) : _apiService = apiService;

  String get _userId => supabase.auth.currentUser!.id;

  // Fetches the resume metadata from our DB
  Future<Map<String, dynamic>?> getCurrentResume() async {
    final response = await supabase
        .from('resumes')
        .select()
        .eq('user_id', _userId)
        .order('upload_date', ascending: false)
        .limit(1)
        .maybeSingle(); // Gets one or null
    return response;
  }

  // Fetches the analysis from our DB
  Future<Map<String, dynamic>?> getResumeAnalysis(String resumeId) async {
    final response = await supabase
        .from('resume_analysis')
        .select()
        .eq('resume_id', resumeId)
        .limit(1)
        .maybeSingle();
    return response;
  }

  // Uploads the file and saves metadata
  Future<Map<String, dynamic>?> uploadResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Required for web
    );

    if (result == null || result.files.first.bytes == null) {
      return null; // User canceled
    }

    final fileBytes = result.files.first.bytes!;
    final fileName = result.files.first.name;

    // Validate file size
    if (fileBytes.length > maxFileSizeBytes) {
      throw Exception(
        'File size exceeds 10 MB limit. Your file is ${formatFileSize(fileBytes.length)}',
      );
    }

    final filePath = '$_userId/$fileName';

    // 1. Upload to Supabase Storage
    await supabase.storage
        .from('resumes')
        .uploadBinary(
          filePath,
          fileBytes,
          fileOptions: const FileOptions(upsert: true),
        );

    // 2. Save metadata to 'resumes' table
    final metadata = {
      'user_id': _userId,
      'file_name': fileName,
      'file_path': filePath,
      'file_size_bytes': fileBytes.length,
    };

    // We use .select() to get the row back after inserting
    final response = await supabase
        .from('resumes')
        .insert(metadata)
        .select()
        .single();

    return response;
  }

  // Deletes file from Storage and DB
  Future<void> deleteResume(String resumeId, String filePath) async {
    // 1. Delete from storage
    await supabase.storage.from('resumes').remove([filePath]);
    // 2. Delete from database (cascade will delete analysis too)
    await supabase.from('resumes').delete().eq('id', resumeId);
  }

  // Calls our Spring Boot backend to trigger analysis
  Future<Map<String, dynamic>?> analyzeResume(String resumeId) {
    return _apiService.analyzeResume(resumeId);
  }

  // Helper functions
  String formatFileSize(int bytes) {
    return '${(bytes / 1048576).toStringAsFixed(2)} MB';
  }

  String formatUploadDate(String date) {
    final dateTime = DateTime.parse(date).toLocal();
    return DateFormat.yMMMd().add_jm().format(dateTime);
  }
}
