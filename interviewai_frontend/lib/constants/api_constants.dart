// lib/constants/api_constants.dart
class ApiConstants {
  // Production backend on Google Cloud Run
  static const String apiBaseUrl =
      'https://interviewai-backend-995205797955.us-central1.run.app';

  // Supabase Configuration
  static const String supabaseUrl = 'https://ymnoeizgsmwgswswcpea.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inltbm9laXpnc213Z3N3c3djcGVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwNjk4OTksImV4cCI6MjA3NzY0NTg5OX0.4wYjZm9Zrld7trc3Fj2SQ1E3Tz1ntIPsfRqeWuPfd0c';

  // VAPI Configuration (Voice AI)
  static const String vapiPublicKey = '88b9f659-40d0-49c1-ae02-28649813f4d8';

  static const String generateInterviewEndpoint = '/api/interviews/generate';
  static const String feedbackEndpoint = '/api/feedback';
}
