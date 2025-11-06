// lib/providers/vapi_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vapi/vapi.dart';

part 'vapi_provider.g.dart'; // Run build_runner after

// Enum to represent the call state
enum CallState { idle, starting, inProgress, ending, ended, error }

@riverpod
class VapiNotifier extends _$VapiNotifier {
  late VapiClient vapiClient;
  VapiCall? currentCall;
  String _fullTranscript = ''; // Track full transcript

  // Getter for the transcript
  String get fullTranscript => _fullTranscript;

  @override
  CallState build() {
    // TODO: Add VAPI_PUBLIC_KEY to ApiConstants when ready
    // For now, use a placeholder or empty string
    final vapiPublicKey = ''; // Will be configured later

    if (vapiPublicKey.isEmpty) {
      if (kDebugMode) {
        print('Warning: VAPI_PUBLIC_KEY not configured. Voice calls will not work.');
      }
      // Initialize with empty key - voice features will be disabled
      vapiClient = VapiClient('');
      return CallState.idle;
    }

    vapiClient = VapiClient(vapiPublicKey);

    return CallState.idle;
  }

  // --- Call Controls ---
  Future<void> startCall(String assistantId, String questions) async {
    // Reset transcript for new call
    _fullTranscript = '';

    state = CallState.starting;
    try {
      // Parse and format questions for better readability
      String formattedQuestions = questions;
      try {
        final questionsList = jsonDecode(questions) as List;
        formattedQuestions = questionsList
            .asMap()
            .entries
            .map((e) => 'Question ${e.key + 1}: ${e.value}')
            .join('\n');
      } catch (e) {
        debugPrint('Questions are not JSON, using as-is: $e');
      }

      debugPrint('Formatted questions for Vapi:\n$formattedQuestions');

      // Start the call and get a VapiCall instance
      currentCall = await vapiClient.start(
        assistantId: assistantId,
        assistantOverrides: {
          'firstMessage':
              'Welcome to your mock interview. Are you ready to begin?',
          'variableValues': {'interview_questions': formattedQuestions},
          'voice': {
            'speed':
                0.85, // Reduce speed to 85% (default is 1.0, range: 0.5-2.0)
          },
        },
      );

      // Listen to events from the call
      currentCall!.onEvent.listen((event) {
        debugPrint('Vapi Event: ${event.label}');

        switch (event.label) {
          case 'call-start':
            state = CallState.inProgress;
            debugPrint('Vapi: Call started');
            break;
          case 'call-end':
            state = CallState.ended;
            debugPrint('Vapi: Call ended');
            break;
          case 'call-error':
            state = CallState.error;
            debugPrint('Vapi Error: Call error');
            break;
          case 'message':
            _handleMessage(event.value);
            debugPrint('Vapi Message: ${event.value}');
            break;
          case 'speech-start':
            debugPrint('Vapi: Speech started');
            break;
          case 'speech-end':
            debugPrint('Vapi: Speech ended');
            break;
        }
      });

      debugPrint('Vapi: Starting call with assistant $assistantId');
    } catch (e) {
      state = CallState.error;
      debugPrint('Vapi Error starting call: $e');
    }
  }

  void _handleMessage(dynamic message) {
    try {
      // Parse the message if it's a string
      final messageMap = message is String ? jsonDecode(message) : message;

      if (messageMap['type'] == 'transcript') {
        final transcriptType =
            messageMap['transcriptType']; // 'partial' or 'final'
        final text = messageMap['transcript'];

        // Only add final transcript segments
        if (transcriptType == 'final') {
          final role = messageMap['role']; // 'user' or 'assistant'
          _fullTranscript += '${role == 'user' ? 'You' : 'AI'}: $text\n';
          debugPrint('Added to transcript: $role: $text');
        }
      }
    } catch (e) {
      debugPrint('Error handling message: $e');
    }
  }

  Future<void> stopCall() async {
    if (currentCall == null) return;

    state = CallState.ending;
    try {
      await currentCall!.stop();
      currentCall!.dispose();
      currentCall = null;
      debugPrint('Vapi: Stopping call');
      debugPrint('Final transcript: $_fullTranscript');
    } catch (e) {
      debugPrint('Vapi Error stopping call: $e');
    }
  }

  void cleanup() {
    currentCall?.dispose();
    vapiClient.dispose();
  }
}
