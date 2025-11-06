// lib/utils/logger.dart
import 'package:flutter/foundation.dart';

/// Logging utility for production-ready logging
/// Provides consistent logging across the application
class Logger {
  static const String _prefix = '[InterviewAI]';

  /// Log info level messages
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix [INFO] $message');
    }
  }

  /// Log warning level messages
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix [WARNING] ⚠️ $message');
    }
  }

  /// Log error level messages
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_prefix [ERROR] ❌ $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  /// Log debug level messages
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix [DEBUG] 🐛 $message');
    }
  }

  /// Log performance metrics
  static void performance(String label, int milliseconds) {
    if (kDebugMode) {
      final icon = milliseconds > 16 ? '⚠️' : '✅';
      debugPrint('$_prefix [PERFORMANCE] $icon $label took ${milliseconds}ms');
    }
  }

  /// Log performance violations
  static void performanceViolation(String label, int milliseconds) {
    if (kDebugMode) {
      final icon = milliseconds > 100 ? '🔴' : '⚠️';
      debugPrint(
        '$_prefix [PERFORMANCE_VIOLATION] $icon $label took ${milliseconds}ms',
      );
    }
  }
}
