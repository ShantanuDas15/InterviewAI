// lib/screens/dashboard/dashboard_screen.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:interviewai_frontend/providers/interviews_provider.dart';
import 'package:interviewai_frontend/providers/feedback_provider.dart';
import 'package:interviewai_frontend/services/auth_service.dart';
import 'package:interviewai_frontend/utils/logger.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  final _roleController = TextEditingController(text: 'Java Developer');
  final _experienceController = TextEditingController(text: 'Mid-level');
  late final AnimationController _gradientController;
  late final AnimationController _cardAnimationController;
  late final List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    // Optimized: Slower gradient animation to reduce CPU usage
    _gradientController = AnimationController(
      duration: const Duration(seconds: 30), // Increased from 20 to 30
      vsync: this,
    )..repeat();

    // Card entrance animations
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimations = List.generate(
      5,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            index * 0.15,
            0.4 + (index * 0.15),
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _cardAnimationController.forward();

    // Force refresh the interviews list when the dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.invalidate(interviewsListProvider);
        ref.invalidate(allUserFeedbackProvider);
      }
    });
  }

  @override
  void dispose() {
    _roleController.dispose();
    _experienceController.dispose();
    _gradientController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _startInterview() {
    ref
        .read(interviewNotifierProvider.notifier)
        .createInterview(
          title: '${_roleController.text} Interview',
          role: _roleController.text,
          experienceLevel: _experienceController.text,
        );
  }

  // 1. Placeholder method for the new button (as requested)
  void _uploadResume() {
    // Navigate to the upload resume screen
    context.go('/upload-resume');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const Color(0xFF1A1F3A),
                    const Color(0xFF162E4D),
                    (sin(_gradientController.value * 2 * pi) + 1) / 2,
                  )!,
                  const Color(0xFF0A0E27),
                ],
              ),
            ),
            child: child,
          );
        },
        child: Column(
          children: [
            _buildAppBar(context),
            // Enhanced scrolling layout with animations
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: _buildWelcomeSection(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            children: [
                              // Featured Cards in Grid
                              _buildFeaturedCardsGrid(),
                              const SizedBox(height: 32),

                              // Interview Creator
                              AnimatedBuilder(
                                animation: _cardAnimations[3],
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      30 * (1 - _cardAnimations[3].value),
                                    ),
                                    child: Opacity(
                                      opacity: _cardAnimations[3].value,
                                      child: _buildInterviewCreatorCard(
                                        context,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 32),

                              // Interview History
                              AnimatedBuilder(
                                animation: _cardAnimations[4],
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      30 * (1 - _cardAnimations[4].value),
                                    ),
                                    child: Opacity(
                                      opacity: _cardAnimations[4].value,
                                      child: _buildHistoryColumn(context),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D9FF), Color(0xFF0077FF)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.psychology, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'InterviewAI',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Your AI Interview Coach',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF00D9FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              tooltip: 'Logout',
              onPressed: () async {
                final navigator = GoRouter.of(context);
                await AuthService().signOut();
                if (mounted) navigator.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting = 'Good Evening';
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 18) {
      greeting = 'Good Afternoon';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ready to ace your next interview?',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCardsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _cardAnimations[0],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - _cardAnimations[0].value)),
                      child: Opacity(
                        opacity: _cardAnimations[0].value,
                        child: _buildResumeAnalyzerCard(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: AnimatedBuilder(
                  animation: _cardAnimations[1],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - _cardAnimations[1].value)),
                      child: Opacity(
                        opacity: _cardAnimations[1].value,
                        child: _buildResumeBuilderCard(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              AnimatedBuilder(
                animation: _cardAnimations[0],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - _cardAnimations[0].value)),
                    child: Opacity(
                      opacity: _cardAnimations[0].value,
                      child: _buildResumeAnalyzerCard(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _cardAnimations[1],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - _cardAnimations[1].value)),
                    child: Opacity(
                      opacity: _cardAnimations[1].value,
                      child: _buildResumeBuilderCard(),
                    ),
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }

  // Enhanced Resume Analyzer Card
  Widget _buildResumeAnalyzerCard() {
    return _buildEnhancedCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Resume Analyzer',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Upload your resume and get instant AI-powered feedback to make it stand out.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildGradientButton(
            onPressed: _uploadResume,
            label: 'Upload Resume',
            icon: Icons.upload_file_rounded,
            backgroundColor: Colors.white,
            textColor: const Color(0xFF667EEA),
          ),
        ],
      ),
    );
  }

  // Enhanced Resume Builder Card
  Widget _buildResumeBuilderCard() {
    return _buildEnhancedCard(
      gradient: const LinearGradient(
        colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_fix_high_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'AI Resume Builder',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create a professional resume with AI enhancement that transforms your details into polished content.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildGradientButton(
            onPressed: () => context.go('/resume-builder'),
            label: 'Build My Resume',
            icon: Icons.edit_note_rounded,
            backgroundColor: Colors.white,
            textColor: const Color(0xFFF5576C),
          ),
        ],
      ),
    );
  }

  // 4. --- EXISTING WIDGET: Interview Creation Card ---
  Widget _buildInterviewCreatorCard(BuildContext context) {
    final interviewState = ref.watch(interviewNotifierProvider);

    return _buildGlassCard(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: (interviewState.hasValue && interviewState.value != null)
            ? _buildSuccessCard(context, interviewState.value!)
            : _buildCreationForm(context, interviewState),
      ),
    );
  }

  // 5. --- EXISTING WIDGET: Interview History Card ---
  Widget _buildHistoryColumn(BuildContext context) {
    final listState = ref.watch(interviewsListProvider);
    final allFeedbackState = ref.watch(allUserFeedbackProvider);

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Interview History',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                onPressed: () {
                  ref.invalidate(interviewsListProvider);
                  ref.invalidate(allUserFeedbackProvider);
                },
                tooltip: 'Refresh',
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 32),
          // We use a fixed height here to avoid layout errors in a SingleChildScrollView
          SizedBox(
            height: 400, // You can adjust this height
            child: listState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(
                child: Text(
                  'Error: $e',
                  style: GoogleFonts.inter(color: Colors.red.shade300),
                ),
              ),
              data: (interviews) {
                if (interviews.isEmpty) {
                  return Center(
                    child: Text(
                      'No interviews yet. Create one to get started!',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return allFeedbackState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => ListView.builder(
                    itemCount: interviews.length,
                    itemBuilder: (context, index) =>
                        _buildInterviewCard(context, interviews[index], null),
                  ),
                  data: (feedbackMap) => ListView.builder(
                    shrinkWrap: true, // Allow list to take its content's height
                    itemCount: interviews.length,
                    itemBuilder: (context, index) => _buildInterviewCard(
                      context,
                      interviews[index],
                      feedbackMap,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS (Unchanged) ---

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24.0),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildEnhancedCard({
    required Widget child,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 8,
        shadowColor: backgroundColor.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreationForm(
    BuildContext context,
    AsyncValue<Map<String, dynamic>?> interviewState,
  ) {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D9FF), Color(0xFF0077FF)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.voice_chat_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mock Interview',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  Text(
                    'AI-Powered Practice',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF00D9FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Practice with an AI interviewer that adapts to your role and experience level.',
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        _buildStyledTextField(
          controller: _roleController,
          label: 'Job Role',
          icon: Icons.work_rounded,
        ),
        const SizedBox(height: 18),
        _buildStyledTextField(
          controller: _experienceController,
          label: 'Experience Level',
          icon: Icons.trending_up_rounded,
        ),
        const SizedBox(height: 28),
        if (interviewState.isLoading)
          Center(
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Generating your interview...',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          )
        else if (interviewState.hasError)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error: ${interviewState.error.toString()}',
                    style: GoogleFonts.inter(color: Colors.red.shade300),
                  ),
                ),
              ],
            ),
          ),
        if (!interviewState.isLoading && !interviewState.hasError) ...[
          _buildStyledButton(
            onPressed: _startInterview,
            label: 'Generate Interview',
            icon: Icons.psychology_alt_rounded,
          ),
        ],
      ],
    );
  }

  Widget _buildSuccessCard(
    BuildContext context,
    Map<String, dynamic> interview,
  ) {
    final questions = interview['questions'] ?? '[]';
    final interviewId = interview['id'] ?? 'N/A';

    return Column(
      key: const ValueKey('success'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Interview Ready!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your "${interview['title']}" interview has been generated.',
          style: GoogleFonts.inter(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const Icon(
          Icons.check_circle_outline,
          color: Color(0xFF00D9FF),
          size: 60,
        ),
        const SizedBox(height: 24),
        _buildStyledButton(
          onPressed: () {
            ref.invalidate(interviewNotifierProvider);
            ref.invalidate(interviewsListProvider);
            GoRouter.of(context).push(
              '/interview',
              extra: {
                'interviewId': interviewId.toString(),
                'questionsJson': questions.toString(),
              },
            );
          },
          label: 'Start Voice Call',
          icon: Icons.voice_chat,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            ref.invalidate(interviewNotifierProvider);
          },
          child: Text(
            'Create another',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildInterviewCard(
    BuildContext context,
    Map<String, dynamic> interview,
    Map<String, Map<String, dynamic>>? feedbackMap,
  ) {
    final interviewId = interview['id']?.toString() ?? 'N/A';
    final date = DateTime.parse(interview['created_at']).toLocal();
    final formattedDate = DateFormat.yMMMd().add_jm().format(date);

    Logger.debug('Building card for interview: $interviewId');
    Logger.debug('Available feedback keys: ${feedbackMap?.keys.toList()}');

    final feedback = feedbackMap?[interviewId];
    Logger.debug('Feedback for $interviewId: $feedback');

    String? feedbackDate;
    if (feedback != null && feedback['generated_at'] != null) {
      final fbDate = DateTime.parse(feedback['generated_at']).toLocal();
      feedbackDate = DateFormat.yMMMd().add_jm().format(fbDate);
    }

    final hasCompleted = feedback != null;
    final score = hasCompleted ? (feedback['overallScore'] ?? 0) : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasCompleted
              ? const Color(0xFF00D9FF).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: hasCompleted
            ? [
                BoxShadow(
                  color: const Color(0xFF00D9FF).withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasCompleted
                        ? const Color(0xFF00D9FF).withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasCompleted
                        ? Icons.check_circle_rounded
                        : Icons.pending_rounded,
                    color: hasCompleted
                        ? const Color(0xFF00D9FF)
                        : Colors.white54,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interview['title'] ?? 'Untitled Interview',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${interview['role']} � ${interview['experience_level']}',
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getScoreGradient(score),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _getScoreGradient(
                            score,
                          ).first.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$score',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'SCORE',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'Pending',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Colors.white60,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  if (feedbackDate != null) ...[
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.feedback_rounded,
                      size: 14,
                      color: Color(0xFF00D9FF),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feedbackDate,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF00D9FF).withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (feedback == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'This interview has not been completed yet.',
                          style: GoogleFonts.inter(),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.orange.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    return;
                  }
                  context.go('/feedback/$interviewId');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasCompleted
                      ? const Color(0xFF00D9FF)
                      : Colors.white.withValues(alpha: 0.1),
                  foregroundColor: hasCompleted ? Colors.black : Colors.white54,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: hasCompleted ? 4 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  hasCompleted ? Icons.visibility_rounded : Icons.lock_rounded,
                  size: 20,
                ),
                label: Text(
                  hasCompleted ? 'Review Feedback' : 'Complete Interview First',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getScoreGradient(int score) {
    if (score >= 80) {
      return [const Color(0xFF4ADE80), const Color(0xFF22C55E)];
    } else if (score >= 60) {
      return [const Color(0xFFF59E0B), const Color(0xFFEAB308)];
    } else {
      return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
    }
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00D9FF), width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildStyledButton({
    required VoidCallback? onPressed,
    required String label,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D9FF), Color(0xFF0077FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
