// lib/screens/resume/analysis_result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interviewai_frontend/services/resume_service.dart';
import 'package:interviewai_frontend/services/pdf_service.dart';

class AnalysisResultScreen extends ConsumerStatefulWidget {
  final String resumeId;

  const AnalysisResultScreen({super.key, required this.resumeId});

  @override
  ConsumerState<AnalysisResultScreen> createState() =>
      _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen> {
  Map<String, dynamic>? _analysis;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resumeService = ref.read(resumeServiceProvider);
      final analysis = await resumeService.getResumeAnalysis(widget.resumeId);

      if (mounted) {
        setState(() {
          _analysis = analysis;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    return 'Needs Improvement';
  }

  Future<void> _downloadPdf() async {
    if (_analysis == null) return;

    try {
      await PdfService.downloadResumeAnalysisPdf(
        analysis: _analysis!,
        fileName:
            'resume_analysis_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Analysis Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/upload-resume'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading analysis',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadAnalysis,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _analysis == null
          ? const Center(child: Text('No analysis found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Download PDF Button - Top
                      Align(
                        alignment: Alignment.topRight,
                        child: ElevatedButton.icon(
                          onPressed: _downloadPdf,
                          icon: const Icon(Icons.download),
                          label: const Text('Download PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Score Card
                      Card(
                        elevation: 4,
                        color: _getScoreColor(_analysis!['overall_score']),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Text(
                                'Overall Score',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${_analysis!['overall_score']}/100',
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getScoreLabel(_analysis!['overall_score']),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Strengths Section - Now displays structured analysis
                      _buildStructuredAnalysis(context),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.go('/upload-resume'),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Back to Upload'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.go('/dashboard'),
                              icon: const Icon(Icons.home),
                              label: const Text('Dashboard'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<dynamic> items,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: color.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructuredAnalysis(BuildContext context) {
    final strengths = _analysis!['strengths'] as Map<String, dynamic>;

    return Column(
      children: [
        // 1. Skills Assessment
        if (strengths.containsKey('skillsAssessment'))
          _buildExpandableSection(
            context,
            'Skills Assessment',
            Icons.psychology,
            Colors.blue,
            strengths['skillsAssessment'],
            subSections: ['technical', 'soft', 'domain'],
          ),

        const SizedBox(height: 16),

        // 2. Experience Evaluation
        if (strengths.containsKey('experienceEvaluation'))
          _buildSection(
            context,
            'Experience Evaluation',
            Icons.work,
            Colors.purple,
            List<dynamic>.from(strengths['experienceEvaluation'] ?? []),
          ),

        const SizedBox(height: 16),

        // 3. Education & Certifications
        if (strengths.containsKey('educationCertifications'))
          _buildSection(
            context,
            'Education & Certifications',
            Icons.school,
            Colors.indigo,
            List<dynamic>.from(strengths['educationCertifications'] ?? []),
          ),

        const SizedBox(height: 16),

        // 4. Resume Optimization
        if (strengths.containsKey('resumeOptimization'))
          _buildExpandableSection(
            context,
            'Resume Optimization',
            Icons.psychology,
            Colors.green,
            strengths['resumeOptimization'],
            subSections: ['ats', 'keywords', 'structure'],
          ),

        const SizedBox(height: 16),

        // 5. Interview Preparation
        if (strengths.containsKey('interviewPreparation'))
          _buildSection(
            context,
            'Interview Preparation',
            Icons.forum,
            Colors.orange,
            List<dynamic>.from(strengths['interviewPreparation'] ?? []),
          ),

        const SizedBox(height: 16),

        // 6. Career Advancement
        if (strengths.containsKey('careerAdvancement'))
          _buildExpandableSection(
            context,
            'Career Advancement',
            Icons.trending_up,
            Colors.teal,
            strengths['careerAdvancement'],
            subSections: ['jobRecommendations', 'growthOpportunities'],
          ),

        const SizedBox(height: 16),

        // 7. Professional Development
        if (strengths.containsKey('professionalDevelopment'))
          _buildSection(
            context,
            'Professional Development',
            Icons.school_outlined,
            Colors.deepPurple,
            List<dynamic>.from(strengths['professionalDevelopment'] ?? []),
          ),
      ],
    );
  }

  Widget _buildExpandableSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Map<String, dynamic> data, {
    required List<String> subSections,
  }) {
    return Card(
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: color, size: 32),
          title: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          initiallyExpanded: false,
          children: subSections.map((subSection) {
            final items = data[subSection];
            if (items == null) return const SizedBox.shrink();

            final itemList = items is List ? items : [items];
            final subTitle = subSection
                .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
                .trim()
                .split(' ')
                .map((word) => word[0].toUpperCase() + word.substring(1))
                .join(' ');

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List<dynamic>.from(itemList).map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Icon(
                              Icons.circle,
                              size: 6,
                              color: color.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.toString(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
