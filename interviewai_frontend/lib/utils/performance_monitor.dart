// lib/utils/performance_monitor.dart
import 'package:flutter/foundation.dart';
import 'package:interviewai_frontend/utils/logger.dart';
import 'dart:async';

/// Simple performance monitoring utility for development
/// Tracks long-running operations and logs violations
class PerformanceMonitor {
  static final List<PerformanceEntry> _entries = [];
  static Timer? _reportTimer;

  static void startMonitoring() {
    if (!kDebugMode) return;

    // Report stats every 30 seconds in debug mode
    _reportTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _printReport();
    });

    Logger.info('Performance monitoring started');
  }

  static void stopMonitoring() {
    _reportTimer?.cancel();
    _entries.clear();
    Logger.info('Performance monitoring stopped');
  }

  /// Measures execution time of a synchronous operation
  static T measure<T>(String label, T Function() operation) {
    if (!kDebugMode) return operation();

    final stopwatch = Stopwatch()..start();
    final result = operation();
    stopwatch.stop();

    _recordEntry(label, stopwatch.elapsedMilliseconds);
    return result;
  }

  /// Measures execution time of an asynchronous operation
  static Future<T> measureAsync<T>(
    String label,
    Future<T> Function() operation,
  ) async {
    if (!kDebugMode) return operation();

    final stopwatch = Stopwatch()..start();
    final result = await operation();
    stopwatch.stop();

    _recordEntry(label, stopwatch.elapsedMilliseconds);
    return result;
  }

  static void _recordEntry(String label, int milliseconds) {
    final entry = PerformanceEntry(
      label: label,
      duration: milliseconds,
      timestamp: DateTime.now(),
    );

    _entries.add(entry);

    // Log violations immediately
    if (milliseconds > 16) {
      Logger.performanceViolation(label, milliseconds);
    }

    // Keep only last 100 entries
    if (_entries.length > 100) {
      _entries.removeAt(0);
    }
  }

  static void _printReport() {
    if (_entries.isEmpty) return;

    final violations = _entries.where((e) => e.duration > 16).length;
    final avgDuration =
        _entries.map((e) => e.duration).reduce((a, b) => a + b) /
        _entries.length;
    final maxEntry = _entries.reduce((a, b) => a.duration > b.duration ? a : b);

    final report =
        '''
╔════════════════════════════════════════════════╗
║       PERFORMANCE REPORT (Last 30s)            ║
╠════════════════════════════════════════════════╣
║ Total Operations: ${_entries.length.toString().padRight(28)}║
║ Violations (>16ms): ${violations.toString().padRight(26)}║
║ Average Duration: ${avgDuration.toStringAsFixed(1)}ms${' ' * (26 - avgDuration.toStringAsFixed(1).length)}║
║ Slowest Operation: ${maxEntry.label.padRight(24)}║
║   Duration: ${maxEntry.duration}ms${' ' * (32 - maxEntry.duration.toString().length)}║
╚════════════════════════════════════════════════╝
''';
    Logger.info(report);
  }

  /// Get current statistics
  static Map<String, dynamic> getStats() {
    if (_entries.isEmpty) {
      return {'message': 'No data collected yet'};
    }

    final violations = _entries.where((e) => e.duration > 16).toList();
    final avgDuration =
        _entries.map((e) => e.duration).reduce((a, b) => a + b) /
        _entries.length;

    return {
      'totalOperations': _entries.length,
      'violations': violations.length,
      'violationRate': (violations.length / _entries.length * 100)
          .toStringAsFixed(1),
      'averageDuration': avgDuration.toStringAsFixed(1),
      'maxDuration': _entries
          .map((e) => e.duration)
          .reduce((a, b) => a > b ? a : b),
    };
  }
}

class PerformanceEntry {
  final String label;
  final int duration;
  final DateTime timestamp;

  PerformanceEntry({
    required this.label,
    required this.duration,
    required this.timestamp,
  });
}
