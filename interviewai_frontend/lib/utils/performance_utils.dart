// lib/utils/performance_utils.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:interviewai_frontend/utils/logger.dart';

/// Utility class for performance optimizations across the app
class PerformanceUtils {
  /// Debounces a function call to prevent excessive executions
  /// Useful for search fields, text inputs, etc.
  static Timer? _debounceTimer;

  static void debounce({
    required VoidCallback action,
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }

  /// Throttles a function to execute at most once per specified duration
  /// Useful for scroll handlers, resize events, etc.
  static DateTime? _lastThrottleTime;

  static void throttle({
    required VoidCallback action,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    final now = DateTime.now();
    if (_lastThrottleTime == null ||
        now.difference(_lastThrottleTime!) > delay) {
      _lastThrottleTime = now;
      action();
    }
  }

  /// Schedules a callback for the next frame
  /// Useful for deferring heavy operations
  static void scheduleNextFrame(VoidCallback callback) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  /// Breaks a large task into smaller chunks to prevent blocking
  /// Returns a Stream that yields progress
  static Stream<double> chunkifyTask<T>({
    required List<T> items,
    required void Function(T) processItem,
    int chunkSize = 20,
  }) async* {
    int processed = 0;
    final total = items.length;

    for (int i = 0; i < total; i += chunkSize) {
      final end = (i + chunkSize < total) ? i + chunkSize : total;
      final chunk = items.sublist(i, end);

      for (final item in chunk) {
        processItem(item);
        processed++;
      }

      // Yield to the main thread
      await Future.delayed(Duration.zero);
      yield processed / total;
    }
  }

  /// Logs performance metrics in debug mode only
  static void measurePerformance(String label, VoidCallback action) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      action();
      stopwatch.stop();

      final elapsed = stopwatch.elapsedMilliseconds;
      Logger.performance(label, elapsed);
    } else {
      action();
    }
  }

  /// Cleans up all timers
  static void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _lastThrottleTime = null;
  }
}
