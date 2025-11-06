// lib/screens/feedback/feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:interviewai_frontend/providers/feedback_provider.dart';
import 'package:interviewai_frontend/services/pdf_service.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  final String feedbackId;
  final Map<String, dynamic>? initialData;

  const FeedbackScreen({super.key, required this.feedbackId, this.initialData});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen>
    with TickerProviderStateMixin {
  late Map<String, AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = {
      'rotation': AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      )..repeat(),
      'rotationReverse': AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      )..repeat(),
      'pulse': AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      )..repeat(reverse: true),
      'progress': AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      )..repeat(),
    };
  }

  @override
  void dispose() {
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Watch ref properly within ConsumerState
  @override
  WidgetRef get ref => super.ref;

  @override
  Widget build(BuildContext context) {
    // Watch the provider
    final feedbackAsync = ref.watch(
      feedbackDetailsProvider(feedbackId: widget.feedbackId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Interview Feedback',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            onPressed: () => context.go('/dashboard'),
            tooltip: 'Go to Dashboard',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0E27),
              const Color(0xFF1A1F3A).withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              // If we have initial data and the async hasn't loaded yet, show it immediately
              child: (widget.initialData != null && !feedbackAsync.hasValue)
                  ? _buildFeedbackContent(context, widget.initialData!)
                  : feedbackAsync.when(
                      loading: () => _buildAnalyzingAnimation(context),
                      error: (err, stack) => _buildErrorState(context, err),
                      data: (feedback) {
                        return _buildFeedbackContent(context, feedback);
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackContent(
    BuildContext context,
    Map<String, dynamic> feedback,
  ) {
    final overallScore = feedback['overallScore'] ?? 0;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Hero Section with Score
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF00D9FF).withValues(alpha: 0.2),
                const Color(0xFF7B2FF7).withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Score Circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getScoreColor(overallScore),
                      _getScoreColor(overallScore).withValues(alpha: 0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getScoreColor(
                        overallScore,
                      ).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$overallScore',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        '/ 100',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Overall Performance',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getScoreLabel(overallScore),
                style: TextStyle(
                  fontSize: 16,
                  color: _getScoreColor(overallScore),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              // Download PDF Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadPdf(context, feedback),
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text(
                    'Download PDF Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9FF),
                    foregroundColor: const Color(0xFF0A0E27),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Strengths Section
        _buildEnhancedFeedbackSection(
          context,
          'Strengths',
          feedback['strengths'] ?? 'No strengths provided.',
          Icons.emoji_events_rounded,
          const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 24),

        // Areas for Improvement Section
        _buildEnhancedFeedbackSection(
          context,
          'Areas for Improvement',
          feedback['areasForImprovement'] ??
              'No areas for improvement provided.',
          Icons.trending_up_rounded,
          const Color(0xFFFF9800),
        ),
        const SizedBox(height: 32),

        // Transcript Section
        _buildTranscriptSection(
          context,
          feedback['transcript'] ?? 'No transcript available.',
        ),
      ],
    );
  }

  Widget _buildEnhancedFeedbackSection(
    BuildContext context,
    String title,
    String text,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptSection(BuildContext context, String transcript) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D9FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF00D9FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Full Transcript',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D9FF),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E27),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              transcript,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.6,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Feedback',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/dashboard'),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Go to Dashboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9FF),
                foregroundColor: const Color(0xFF0A0E27),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFF00D9FF);
    if (score >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFf44336);
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Excellent Performance!';
    if (score >= 60) return 'Good Performance';
    if (score >= 40) return 'Fair Performance';
    return 'Needs Improvement';
  }

  void _downloadPdf(BuildContext context, Map<String, dynamic> feedback) async {
    try {
      await PdfService.downloadInterviewFeedbackPdf(
        feedback: feedback,
        interviewTitle: feedback['interviewTitle'] ?? 'Interview Feedback',
        fileName:
            'interview_feedback_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Build immersive analyzing feedback loading animation
  Widget _buildAnalyzingAnimation(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated analyzing icon with rotating particles
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating ring
                AnimatedBuilder(
                  animation: _createRotationAnimation(),
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _createRotationAnimation().value * 2 * pi,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Middle rotating ring (inverted)
                AnimatedBuilder(
                  animation: _createRotationAnimation(reverse: true),
                  builder: (context, child) {
                    return Transform.rotate(
                      angle:
                          _createRotationAnimation(reverse: true).value *
                          2 *
                          pi,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Pulsing center icon
                ScaleTransition(
                  scale: _createPulseAnimation(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.psychology,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Animated text with typing effect
          SizedBox(
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Analyzing Your Feedback',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 20, child: _AnimatedDots()),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Animated progress bar
          Container(
            width: 200,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.grey.withValues(alpha: 0.2),
            ),
            child: AnimatedBuilder(
              animation: _createProgressAnimation(),
              builder: (context, child) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 200 * _createProgressAnimation().value,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).secondaryHeaderColor,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Loading status text
          Text(
            'Processing AI Analysis...',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Create rotation animation controller
  Animation<double> _createRotationAnimation({bool reverse = false}) {
    final controller =
        _animationControllers[reverse ? 'rotationReverse' : 'rotation']!;
    return Tween<double>(begin: 0, end: 1).animate(controller);
  }

  /// Create pulse animation for center icon
  Animation<double> _createPulseAnimation() {
    final controller = _animationControllers['pulse']!;
    return Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  /// Create progress animation
  Animation<double> _createProgressAnimation() {
    final controller = _animationControllers['progress']!;
    return Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }
}

/// Animated dots widget for loading text
class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        final dots = ((value * 3) % 3).toInt();
        final dotText = '.' * (dots + 1);

        return Text(
          'Analyzing$dotText',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}
