// lib/screens/interview/interview_screen.dart
import 'dart:async';
import 'dart:math';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:interviewai_frontend/providers/vapi_provider.dart';
import 'package:interviewai_frontend/providers/interviews_provider.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  final String interviewId;
  final String questionsJson;

  const InterviewScreen({
    super.key,
    required this.interviewId,
    required this.questionsJson,
  });

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen>
    with TickerProviderStateMixin {
  final String _vapiAssistantId = '31a850a5-ce4f-4f12-a0a6-d282be0a83f4';
  late final AnimationController _gradientController;
  late final AnimationController _pulseController;
  StreamSubscription? _vapiMessageSubscription;

  final List<Map<String, String>> _transcriptMessages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start the call
      ref
          .read(vapiNotifierProvider.notifier)
          .startCall(_vapiAssistantId, widget.questionsJson);
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    _vapiMessageSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(vapiNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Live Interview',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _gradientController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0F172A), // Slate 900
                        Color.lerp(
                          const Color(0xFF1E1B4B), // Indigo 950
                          const Color(0xFF312E81), // Indigo 900
                          (sin(_gradientController.value * 2 * pi) + 1) / 2,
                        )!,
                        const Color(0xFF0F172A), // Slate 900
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Status Badge
                _buildStatusBadge(callState),
                const SizedBox(height: 20),

                // Main Interview Card
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      child: Column(
                        children: [
                          _buildGlassCard(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 30),
                                _buildInterviewerAvatar(callState),
                                const SizedBox(height: 30),
                                _buildStatusMessage(callState),
                                const SizedBox(height: 30),
                                _buildActionButtons(callState),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Live Transcript Section
                          _buildTranscriptSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(CallState state) {
    String text;
    Color color;
    IconData icon;

    switch (state) {
      case CallState.starting:
        text = 'Connecting';
        color = const Color(0xFF38BDF8); // Sky 400
        icon = Icons.sync;
        break;
      case CallState.inProgress:
        text = 'Live';
        color = const Color(0xFF4ADE80); // Green 400
        icon = Icons.fiber_manual_record;
        break;
      case CallState.ending:
        text = 'Finishing';
        color = const Color(0xFFFBBF24); // Amber 400
        icon = Icons.hourglass_bottom;
        break;
      case CallState.ended:
        text = 'Processing';
        color = const Color(0xFFA78BFA); // Violet 400
        icon = Icons.auto_awesome;
        break;
      case CallState.error:
        text = 'Error';
        color = const Color(0xFFF87171); // Red 400
        icon = Icons.error_outline;
        break;
      default:
        text = 'Ready';
        color = Colors.grey;
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewerAvatar(CallState callState) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        double glowRadius = 0;
        double glowOpacity = 0;

        if (callState == CallState.inProgress) {
          glowRadius = 10 + (_pulseController.value * 15);
          glowOpacity = 0.3 + (_pulseController.value * 0.3);
        }

        return Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withOpacity(glowOpacity),
                blurRadius: glowRadius * 2,
                spreadRadius: glowRadius,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF38BDF8).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/Interviewer.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white54,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusMessage(CallState callState) {
    if (callState == CallState.ended) {
      return Column(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Generating Insights...',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    String message = 'Preparing your session...';
    if (callState == CallState.inProgress) {
      message = 'Listening...';
    } else if (callState == CallState.starting) {
      message = 'Connecting to AI...';
    } else if (callState == CallState.ending) {
      message = 'Wrapping up...';
    } else if (callState == CallState.error) {
      message = 'Connection interrupted';
    }

    return Text(
      message,
      style: GoogleFonts.outfit(
        color: Colors.white.withOpacity(0.9),
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButtons(CallState callState) {
    bool isEnabled =
        callState == CallState.inProgress || callState == CallState.starting;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: InkWell(
        onTap: isEnabled ? _endCallAndSubmitFeedback : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? const LinearGradient(
                    colors: [
                      Color(0xFFEF4444),
                      Color(0xFFDC2626),
                    ], // Red 500-600
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.call_end,
                  color: isEnabled ? Colors.white : Colors.white38,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  'End Interview',
                  style: GoogleFonts.outfit(
                    color: isEnabled ? Colors.white : Colors.white38,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTranscriptSection() {
    if (_transcriptMessages.isEmpty) {
      return _buildGlassCard(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.graphic_eq,
                color: Colors.white.withOpacity(0.2),
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'Conversation will appear here',
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildGlassCard(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notes,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'LIVE TRANSCRIPT',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _transcriptMessages.length,
                itemBuilder: (context, index) {
                  final message = _transcriptMessages[index];
                  final isUser = message['role'] == 'user';
                  return _buildChatBubble(
                    text: message['text']!,
                    isUser: isUser,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble({required String text, required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF38BDF8).withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          border: Border.all(
            color: isUser
                ? const Color(0xFF38BDF8).withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Future<void> _endCallAndSubmitFeedback() async {
    final vapiNotifier = ref.read(vapiNotifierProvider.notifier);
    await vapiNotifier.stopCall();
    final transcript = vapiNotifier.fullTranscript;

    if (!mounted) return;

    try {
      final api = ref.read(apiServiceProvider);
      final feedbackResponse = await api.submitFeedback(
        interviewId: widget.interviewId,
        transcript: transcript,
      );
      final newFeedbackId = feedbackResponse['id'];

      if (mounted) context.go('/feedback/$newFeedbackId');
    } catch (e) {
      final friendlyMessage = e.toString().replaceFirst('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $friendlyMessage'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
