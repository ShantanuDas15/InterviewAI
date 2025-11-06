// lib/screens/interview/interview_screen.dart
import 'dart:async';
import 'dart:math';
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
    _vapiMessageSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(vapiNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🎙️ Live Interview Session',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1a1f3a).withValues(alpha: 0.95),
                const Color(0xFF0f1425).withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: false,
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A0E27),
                  Color.lerp(
                    const Color(0xFF1a237e),
                    const Color(0xFF004d40),
                    (sin(_gradientController.value * 2 * pi) + 1) / 2,
                  )!,
                  const Color(0xFF0A0E27),
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Animated Status with modern design
              _buildModernStatus(callState),
              const SizedBox(height: 20),

              // Main Interview Card - Enhanced
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
                    child: Column(
                      children: [
                        _buildEnhancedInterviewCard(callState, screenWidth),
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
      ),
    );
  }

  Widget _buildModernStatus(CallState state) {
    String text;
    Color color;
    IconData icon;

    switch (state) {
      case CallState.starting:
        text = 'Connecting to AI...';
        color = const Color(0xFF00D9FF);
        icon = Icons.sync;
        break;
      case CallState.inProgress:
        text = 'Interview in Progress';
        color = const Color(0xFF00FF87);
        icon = Icons.circle;
        break;
      case CallState.ending:
        text = 'Wrapping Up...';
        color = const Color(0xFFFFB300);
        icon = Icons.hourglass_bottom;
        break;
      case CallState.ended:
        text = 'Analyzing Your Performance';
        color = const Color(0xFF9C27B0);
        icon = Icons.analytics;
        break;
      case CallState.error:
        text = 'Connection Error';
        color = const Color(0xFFFF3D00);
        icon = Icons.error_outline;
        break;
      default:
        text = 'Initializing...';
        color = Colors.grey;
        icon = Icons.hourglass_empty;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
        ),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state == CallState.starting || state == CallState.ending)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedInterviewCard(CallState callState, double screenWidth) {
    final isDesktop = screenWidth > 600;

    return Container(
      constraints: BoxConstraints(
        maxWidth: isDesktop ? 500 : screenWidth * 0.9,
      ),
      child: Card(
        elevation: 30,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E2A47).withValues(alpha: 0.98),
                const Color(0xFF1a1f3a).withValues(alpha: 0.95),
                const Color(0xFF0f1425).withValues(alpha: 0.98),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
                blurRadius: 40,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decorative header
                _buildCardHeader(),
                const SizedBox(height: 24),

                // AI Interviewer Image
                _buildInterviewerImage(callState),
                const SizedBox(height: 24),

                // Status Text
                _buildStatusText(callState),
                const SizedBox(height: 20),

                // Progress Indicator
                _buildProgressIndicator(callState),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(callState),
                const SizedBox(height: 16),

                // Decorative footer
                _buildCardFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00D9FF), Color(0xFF0099FF)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            '✨ AI-Powered Interview',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterviewerImage(CallState callState) {
    return Hero(
      tag: 'interviewer',
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF00D9FF).withValues(alpha: 0.3),
              const Color(0xFF0099FF).withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.5),
              blurRadius: 40,
              spreadRadius: 10,
            ),
            BoxShadow(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
              blurRadius: 80,
              spreadRadius: 20,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating ring for active call
            if (callState == CallState.inProgress)
              RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_gradientController),
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00D9FF).withValues(alpha: 0.5),
                      width: 3,
                    ),
                  ),
                ),
              ),
            // Pulsing effect
            ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.05).animate(
                CurvedAnimation(
                  parent: _gradientController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: ClipOval(
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00D9FF).withValues(alpha: 0.6),
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/Interviewer.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF00D9FF).withValues(alpha: 0.6),
                                const Color(0xFF0099FF).withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Recording indicator
            if (callState == CallState.inProgress)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3D00),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3D00).withValues(alpha: 0.6),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusText(CallState callState) {
    String mainText;
    String subText;

    switch (callState) {
      case CallState.starting:
        mainText = 'Connecting...';
        subText = 'Preparing your interview session';
        break;
      case CallState.inProgress:
        mainText = 'Interview Active';
        subText = 'Answer confidently and take your time';
        break;
      case CallState.ending:
        mainText = 'Concluding...';
        subText = 'Saving your responses';
        break;
      case CallState.ended:
        mainText = 'Session Complete';
        subText = 'Generating your feedback report';
        break;
      case CallState.error:
        mainText = 'Connection Error';
        subText = 'Please check your connection';
        break;
      default:
        mainText = 'Preparing';
        subText = 'Please wait...';
    }

    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00D9FF), Color(0xFF00FF87)],
          ).createShader(bounds),
          child: Text(
            mainText,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subText,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(CallState callState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isActive = false;
        if (callState == CallState.starting && index == 0) {
          isActive = true;
        } else if (callState == CallState.inProgress && index <= 1) {
          isActive = true;
        } else if (callState == CallState.ending && index <= 2) {
          isActive = true;
        } else if (callState == CallState.ended && index <= 3) {
          isActive = true;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 40 : 12,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF00FF87)],
                  )
                : null,
            color: isActive ? null : Colors.white.withValues(alpha: 0.2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF00D9FF).withValues(alpha: 0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons(CallState callState) {
    return Column(
      children: [
        // End Interview Button
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient:
                callState == CallState.inProgress ||
                    callState == CallState.starting
                ? const LinearGradient(
                    colors: [Color(0xFFFF3D00), Color(0xFFFF6F00)],
                  )
                : LinearGradient(
                    colors: [Colors.grey.shade700, Colors.grey.shade800],
                  ),
            boxShadow:
                callState == CallState.inProgress ||
                    callState == CallState.starting
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF3D00).withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap:
                  (callState == CallState.inProgress ||
                      callState == CallState.starting)
                  ? _endCallAndSubmitFeedback
                  : null,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.call_end, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'End Interview',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tips_and_updates,
            color: const Color(0xFF00D9FF).withValues(alpha: 0.8),
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Speak clearly and confidently for best results',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptSection() {
    if (_transcriptMessages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.white.withValues(alpha: 0.3),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Conversation will appear here',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E2A47).withValues(alpha: 0.6),
            const Color(0xFF0f1425).withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF0099FF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.transcribe, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Live Transcript',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3D00),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3D00).withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fiber_manual_record,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _transcriptMessages.length,
              itemBuilder: (context, index) {
                final message = _transcriptMessages[index];
                final isUser = message['role'] == 'user';
                return _buildEnhancedChatBubble(
                  text: message['text']!,
                  isUser: isUser,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedChatBubble({
    required String text,
    required bool isUser,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF00D9FF), Color(0xFF0099FF)],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.08),
                  ],
                ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUser
                ? const Radius.circular(20)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? const Color(0xFF00D9FF).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person : Icons.smart_toy,
                  size: 14,
                  color: isUser ? Colors.white : const Color(0xFF00D9FF),
                ),
                const SizedBox(width: 6),
                Text(
                  isUser ? 'You' : 'AI Interviewer',
                  style: GoogleFonts.poppins(
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.9)
                        : const Color(0xFF00D9FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: GoogleFonts.inter(
                color: isUser
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.95),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _endCallAndSubmitFeedback() async {
    final vapiNotifier = ref.read(vapiNotifierProvider.notifier);
    await vapiNotifier.stopCall();
    final transcript = vapiNotifier.fullTranscript;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Analyzing feedback...',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );

    try {
      final api = ref.read(apiServiceProvider);
      final feedbackResponse = await api.submitFeedback(
        interviewId: widget.interviewId,
        transcript: transcript,
      );
      final newFeedbackId = feedbackResponse['id'];

      if (mounted) Navigator.of(context).pop();
      if (mounted) context.go('/feedback/$newFeedbackId');
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      final friendlyMessage = e.toString().replaceFirst('Exception: ', '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $friendlyMessage'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}
