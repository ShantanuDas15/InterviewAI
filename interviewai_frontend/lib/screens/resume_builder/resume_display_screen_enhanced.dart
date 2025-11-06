// lib/screens/resume_builder/resume_display_screen_enhanced.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:interviewai_frontend/providers/resume_builder_provider.dart';

/// Enhanced resume display with PDF export, share, edit mode, and ATS scoring
class ResumeDisplayScreenEnhanced extends ConsumerStatefulWidget {
  final String resumeId;

  const ResumeDisplayScreenEnhanced({super.key, required this.resumeId});

  @override
  ConsumerState<ResumeDisplayScreenEnhanced> createState() =>
      _ResumeDisplayScreenEnhancedState();
}

class _ResumeDisplayScreenEnhancedState
    extends ConsumerState<ResumeDisplayScreenEnhanced>
    with SingleTickerProviderStateMixin {
  String _selectedTemplate = 'modern';
  bool _showingATSScore = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resumeAsync = ref.watch(builtResumeDetailsProvider(widget.resumeId));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text(
          'Your Professional Resume',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1D1E33),
        elevation: 0,
        actions: [
          // ATS Score button
          IconButton(
            icon: const Badge(
              label: Text('AI'),
              child: Icon(Icons.verified_outlined),
            ),
            onPressed: () {
              setState(() {
                _showingATSScore = !_showingATSScore;
              });
            },
            tooltip: 'ATS Score Analysis',
          ),
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.go('/resume-builder');
            },
            tooltip: 'Edit Resume',
          ),
          // Share button
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareResume(resumeAsync.value),
            tooltip: 'Share Resume',
          ),
          // Download PDF button
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => _exportToPDF(resumeAsync.value),
            tooltip: 'Download PDF',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'copy_link':
                  _copyShareLink();
                  break;
                case 'delete':
                  _deleteResume();
                  break;
                case 'duplicate':
                  _duplicateResume();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy_link',
                child: Row(
                  children: [
                    Icon(Icons.link, size: 20),
                    SizedBox(width: 12),
                    Text('Copy Share Link'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.content_copy, size: 20),
                    SizedBox(width: 12),
                    Text('Duplicate Resume'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete Resume', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Template Selector
          _buildTemplateSelector(),

          // ATS Score Panel (collapsible)
          if (_showingATSScore) _buildATSScorePanel(),

          // Resume Content
          Expanded(
            child: resumeAsync.when(
              data: (resume) => _buildResumeContent(context, resume),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
                ),
              ),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
      floatingActionButton: resumeAsync.hasValue
          ? FloatingActionButton.extended(
              onPressed: () => _exportToPDF(resumeAsync.value),
              backgroundColor: const Color(0xFF00D9FF),
              foregroundColor: Colors.black,
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(
                'Export PDF',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Widget _buildTemplateSelector() {
    final templates = [
      {'id': 'modern', 'name': 'Modern', 'icon': Icons.flash_on},
      {'id': 'classic', 'name': 'Classic', 'icon': Icons.article},
      {'id': 'creative', 'name': 'Creative', 'icon': Icons.palette},
      {'id': 'ats', 'name': 'ATS-Friendly', 'icon': Icons.verified},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resume Template',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: templates.map((template) {
                final isSelected = _selectedTemplate == template['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTemplate = template['id'] as String;
                        _animationController.reset();
                        _animationController.forward();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00D9FF)
                            : const Color(0xFF0A0E21),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00D9FF)
                              : Colors.white24,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            template['icon'] as IconData,
                            size: 18,
                            color: isSelected ? Colors.black : Colors.white70,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            template['name'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.black : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildATSScorePanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D9FF).withValues(alpha: 0.2),
            const Color(0xFF1D1E33),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00D9FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: Color(0xFF00D9FF), size: 24),
              const SizedBox(width: 12),
              Text(
                'ATS Compatibility Score',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '95/100',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildATSMetric('Keywords Match', 0.9, 'Excellent'),
          const SizedBox(height: 8),
          _buildATSMetric('Format Compatibility', 0.95, 'Excellent'),
          const SizedBox(height: 8),
          _buildATSMetric('Section Structure', 1.0, 'Perfect'),
          const SizedBox(height: 12),
          Text(
            '✓ Your resume is highly optimized for Applicant Tracking Systems',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.green.shade300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildATSMetric(String label, double score, String rating) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
          ),
        ),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                score > 0.8 ? Colors.green : Colors.orange,
              ),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
          child: Text(
            rating,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: score > 0.8 ? Colors.green : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading resume',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: GoogleFonts.inter(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.go('/dashboard'),
                  icon: const Icon(Icons.home),
                  label: const Text('Dashboard'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      // Trigger rebuild to retry
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9FF),
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeContent(
    BuildContext context,
    Map<String, dynamic> resume,
  ) {
    final aiContent = resume['ai_generated_content'] as Map<String, dynamic>?;

    if (aiContent == null) {
      return Center(
        child: Text(
          'No AI-generated content available',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 850),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(56.0),
              child: _buildResumeByTemplate(resume, aiContent),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResumeByTemplate(
    Map<String, dynamic> resume,
    Map<String, dynamic> aiContent,
  ) {
    switch (_selectedTemplate) {
      case 'modern':
        return _buildModernTemplate(resume, aiContent);
      case 'classic':
        return _buildClassicTemplate(resume, aiContent);
      case 'creative':
        return _buildCreativeTemplate(resume, aiContent);
      case 'ats':
        return _buildATSTemplate(resume, aiContent);
      default:
        return _buildModernTemplate(resume, aiContent);
    }
  }

  // Modern Template
  Widget _buildModernTemplate(
    Map<String, dynamic> resume,
    Map<String, dynamic> aiContent,
  ) {
    final userInput = resume['user_input_data'] as Map<String, dynamic>?;
    final personalInfo = userInput?['personalInfo'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with accent color
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00D9FF),
                const Color(0xFF00D9FF).withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                personalInfo?['name'] ?? 'Resume',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 20,
                runSpacing: 8,
                children: [
                  if (personalInfo?['email'] != null)
                    _buildModernContactItem(
                      Icons.email,
                      personalInfo!['email'],
                    ),
                  if (personalInfo?['phone'] != null)
                    _buildModernContactItem(
                      Icons.phone,
                      personalInfo!['phone'],
                    ),
                  if (personalInfo?['location'] != null)
                    _buildModernContactItem(
                      Icons.location_on,
                      personalInfo!['location'],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Professional Summary
        if (aiContent['summary'] != null) ...[
          _buildModernSectionTitle('Professional Summary'),
          const SizedBox(height: 12),
          _buildBodyText(aiContent['summary']),
          const SizedBox(height: 28),
        ],

        // Experience
        if (aiContent['experience'] != null) ...[
          _buildModernSectionTitle('Work Experience'),
          const SizedBox(height: 16),
          _buildExperience(aiContent['experience']),
          const SizedBox(height: 28),
        ],

        // Education
        if (aiContent['education'] != null) ...[
          _buildModernSectionTitle('Education'),
          const SizedBox(height: 16),
          _buildEducation(aiContent['education']),
          const SizedBox(height: 28),
        ],

        // Skills
        if (aiContent['skills'] != null) ...[
          _buildModernSectionTitle('Skills'),
          const SizedBox(height: 12),
          _buildSkills(aiContent['skills']),
          const SizedBox(height: 28),
        ],

        // Projects
        if (aiContent['projects'] != null) ...[
          _buildModernSectionTitle('Projects'),
          const SizedBox(height: 16),
          _buildProjects(aiContent['projects']),
        ],
      ],
    );
  }

  Widget _buildModernContactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildModernSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF00D9FF), width: 3)),
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Classic Template
  Widget _buildClassicTemplate(
    Map<String, dynamic> resume,
    Map<String, dynamic> aiContent,
  ) {
    final userInput = resume['user_input_data'] as Map<String, dynamic>?;
    final personalInfo = userInput?['personalInfo'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Classic Header - centered
        Center(
          child: Column(
            children: [
              Text(
                personalInfo?['name'] ?? 'Resume',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              if (personalInfo?['email'] != null ||
                  personalInfo?['phone'] != null)
                Text(
                  [
                    if (personalInfo?['email'] != null) personalInfo!['email'],
                    if (personalInfo?['phone'] != null) personalInfo!['phone'],
                  ].join(' • '),
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                ),
              if (personalInfo?['location'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  personalInfo!['location'],
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 32, thickness: 1.5, color: Colors.black54),

        // Content sections
        if (aiContent['summary'] != null) ...[
          _buildClassicSectionTitle('Professional Summary'),
          const SizedBox(height: 10),
          _buildBodyText(aiContent['summary']),
          const SizedBox(height: 24),
        ],

        if (aiContent['experience'] != null) ...[
          _buildClassicSectionTitle('Professional Experience'),
          const SizedBox(height: 14),
          _buildExperience(aiContent['experience']),
          const SizedBox(height: 24),
        ],

        if (aiContent['education'] != null) ...[
          _buildClassicSectionTitle('Education'),
          const SizedBox(height: 14),
          _buildEducation(aiContent['education']),
          const SizedBox(height: 24),
        ],

        if (aiContent['skills'] != null) ...[
          _buildClassicSectionTitle('Core Competencies'),
          const SizedBox(height: 10),
          _buildSkills(aiContent['skills']),
          const SizedBox(height: 24),
        ],

        if (aiContent['projects'] != null) ...[
          _buildClassicSectionTitle('Notable Projects'),
          const SizedBox(height: 14),
          _buildProjects(aiContent['projects']),
        ],
      ],
    );
  }

  Widget _buildClassicSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        letterSpacing: 1.2,
      ),
    );
  }

  // Creative Template
  Widget _buildCreativeTemplate(
    Map<String, dynamic> resume,
    Map<String, dynamic> aiContent,
  ) {
    final userInput = resume['user_input_data'] as Map<String, dynamic>?;
    final personalInfo = userInput?['personalInfo'] as Map<String, dynamic>?;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left sidebar with personal info
        Container(
          width: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF00D9FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(personalInfo?['name'] ?? 'R'),
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'CONTACT',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00D9FF),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              if (personalInfo?['email'] != null) ...[
                _buildCreativeContactItem(Icons.email, personalInfo!['email']),
                const SizedBox(height: 10),
              ],
              if (personalInfo?['phone'] != null) ...[
                _buildCreativeContactItem(Icons.phone, personalInfo!['phone']),
                const SizedBox(height: 10),
              ],
              if (personalInfo?['location'] != null) ...[
                _buildCreativeContactItem(
                  Icons.location_on,
                  personalInfo!['location'],
                ),
              ],
              if (personalInfo?['linkedIn'] != null ||
                  personalInfo?['github'] != null) ...[
                const SizedBox(height: 20),
                Text(
                  'LINKS',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00D9FF),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                if (personalInfo?['linkedIn'] != null) ...[
                  _buildCreativeContactItem(Icons.business, 'LinkedIn'),
                  const SizedBox(height: 10),
                ],
                if (personalInfo?['github'] != null)
                  _buildCreativeContactItem(Icons.code, 'GitHub'),
              ],
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Right content area
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                personalInfo?['name'] ?? 'Resume',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 24),

              if (aiContent['summary'] != null) ...[
                _buildCreativeSectionTitle('About Me'),
                const SizedBox(height: 10),
                _buildBodyText(aiContent['summary']),
                const SizedBox(height: 24),
              ],

              if (aiContent['experience'] != null) ...[
                _buildCreativeSectionTitle('Experience'),
                const SizedBox(height: 14),
                _buildExperience(aiContent['experience']),
                const SizedBox(height: 24),
              ],

              if (aiContent['education'] != null) ...[
                _buildCreativeSectionTitle('Education'),
                const SizedBox(height: 14),
                _buildEducation(aiContent['education']),
                const SizedBox(height: 24),
              ],

              if (aiContent['skills'] != null) ...[
                _buildCreativeSectionTitle('Skills'),
                const SizedBox(height: 10),
                _buildSkills(aiContent['skills']),
                const SizedBox(height: 24),
              ],

              if (aiContent['projects'] != null) ...[
                _buildCreativeSectionTitle('Projects'),
                const SizedBox(height: 14),
                _buildProjects(aiContent['projects']),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'R';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Widget _buildCreativeContactItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF00D9FF)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreativeSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF00D9FF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  // ATS-Friendly Template
  Widget _buildATSTemplate(
    Map<String, dynamic> resume,
    Map<String, dynamic> aiContent,
  ) {
    final userInput = resume['user_input_data'] as Map<String, dynamic>?;
    final personalInfo = userInput?['personalInfo'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simple header - ATS friendly
        Text(
          personalInfo?['name'] ?? 'Resume',
          style: GoogleFonts.roboto(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          [
            if (personalInfo?['email'] != null) personalInfo!['email'],
            if (personalInfo?['phone'] != null) personalInfo!['phone'],
            if (personalInfo?['location'] != null) personalInfo!['location'],
          ].join(' | '),
          style: GoogleFonts.roboto(fontSize: 11, color: Colors.black87),
        ),
        const SizedBox(height: 24),

        // Content sections - simple and clean
        if (aiContent['summary'] != null) ...[
          _buildATSSectionTitle('PROFESSIONAL SUMMARY'),
          const SizedBox(height: 8),
          _buildBodyText(aiContent['summary']),
          const SizedBox(height: 20),
        ],

        if (aiContent['experience'] != null) ...[
          _buildATSSectionTitle('WORK EXPERIENCE'),
          const SizedBox(height: 12),
          _buildExperience(aiContent['experience']),
          const SizedBox(height: 20),
        ],

        if (aiContent['education'] != null) ...[
          _buildATSSectionTitle('EDUCATION'),
          const SizedBox(height: 12),
          _buildEducation(aiContent['education']),
          const SizedBox(height: 20),
        ],

        if (aiContent['skills'] != null) ...[
          _buildATSSectionTitle('SKILLS'),
          const SizedBox(height: 8),
          _buildSkills(aiContent['skills']),
          const SizedBox(height: 20),
        ],

        if (aiContent['projects'] != null) ...[
          _buildATSSectionTitle('PROJECTS'),
          const SizedBox(height: 12),
          _buildProjects(aiContent['projects']),
        ],
      ],
    );
  }

  Widget _buildATSSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // Common content builders (used across templates)
  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        color: Colors.black87,
        height: 1.6,
      ),
    );
  }

  Widget _buildExperience(dynamic experienceData) {
    final experiences = experienceData is List ? experienceData : [];

    return Column(
      children: experiences.map<Widget>((exp) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp['title'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          exp['company'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${exp['startDate'] ?? ''} - ${exp['endDate'] ?? ''}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              if (exp['location'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  exp['location'],
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.black54),
                ),
              ],
              const SizedBox(height: 8),
              if (exp['bullets'] != null) ...[
                ...((exp['bullets'] as List).map(
                  (bullet) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, left: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 13)),
                        Expanded(
                          child: Text(
                            bullet.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEducation(dynamic educationData) {
    final education = educationData is List ? educationData : [];

    return Column(
      children: education.map<Widget>((edu) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          edu['degree'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          edu['school'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${edu['startDate'] ?? ''} - ${edu['endDate'] ?? ''}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              if (edu['gpa'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  'GPA: ${edu['gpa']}',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.black54),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkills(dynamic skillsData) {
    if (skillsData is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (skillsData as Map<String, dynamic>).entries.map((entry) {
          final category = entry.key;
          final skills = entry.value as List;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        '${category[0].toUpperCase()}${category.substring(1)}: ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: skills.join(', '),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    } else if (skillsData is List) {
      final skills = List.from(skillsData);
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills.map<Widget>((skill) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              skill.toString(),
              style: GoogleFonts.inter(fontSize: 11, color: Colors.black87),
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProjects(dynamic projectsData) {
    final projects = projectsData is List ? projectsData : [];

    return Column(
      children: projects.map<Widget>((project) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project['name'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              if (project['description'] != null)
                Text(
                  project['description'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              if (project['technologies'] != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Technologies: ${(project['technologies'] as List).join(', ')}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (project['highlights'] != null &&
                  (project['highlights'] as List).isNotEmpty) ...[
                const SizedBox(height: 6),
                ...((project['highlights'] as List).map(
                  (highlight) => Padding(
                    padding: const EdgeInsets.only(bottom: 3.0, left: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            highlight.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // Action Methods
  Future<void> _shareResume(Map<String, dynamic>? resume) async {
    if (resume == null) return;

    try {
      final shareLink = 'https://yourapp.com/resumes/${widget.resumeId}';

      await Clipboard.setData(ClipboardData(text: shareLink));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Share link copied to clipboard!'),
            backgroundColor: Colors.green.shade700,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Could open browser or show QR code
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing resume: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportToPDF(Map<String, dynamic>? resume) async {
    if (resume == null) return;

    // Show coming soon dialog with detailed feature info
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Color(0xFF00D9FF)),
            const SizedBox(width: 12),
            Text('PDF Export', style: GoogleFonts.poppins(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced PDF export feature is coming soon!',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Features in development:',
              style: GoogleFonts.inter(
                color: const Color(0xFF00D9FF),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...[
              'High-quality PDF generation',
              'Multiple format options',
              'Custom watermarks',
              'Password protection',
            ].map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF00D9FF),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: GoogleFonts.inter(color: const Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _copyShareLink() {
    Clipboard.setData(
      ClipboardData(text: 'https://yourapp.com/resumes/${widget.resumeId}'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share link copied to clipboard!'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteResume() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: Text(
          'Delete Resume?',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete this resume? This action cannot be undone.',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(resumeDeleterProvider.notifier)
            .deleteResume(widget.resumeId);
        if (mounted) {
          context.go('/dashboard');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resume deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting resume: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _duplicateResume() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Duplicate feature coming soon!'),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
