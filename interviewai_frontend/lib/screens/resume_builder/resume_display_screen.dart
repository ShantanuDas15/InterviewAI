// lib/screens/resume_builder/resume_display_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:interviewai_frontend/providers/resume_builder_provider.dart';

/// Displays the AI-generated professional resume
class ResumeDisplayScreen extends ConsumerWidget {
  final String resumeId;

  const ResumeDisplayScreen({super.key, required this.resumeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeAsync = ref.watch(builtResumeDetailsProvider(resumeId));

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
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              //Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              //Implement PDF export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF export coming soon!')),
              );
            },
          ),
        ],
      ),
      body: resumeAsync.when(
        data: (resume) => _buildResumeContent(context, resume),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading resume',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: GoogleFonts.inter(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with personal info
              _buildHeader(resume),
              const Divider(height: 32, thickness: 2),

              // Professional Summary
              if (aiContent['summary'] != null) ...[
                _buildSectionTitle('Professional Summary'),
                const SizedBox(height: 12),
                _buildBodyText(aiContent['summary']),
                const SizedBox(height: 24),
              ],

              // Experience
              if (aiContent['experience'] != null) ...[
                _buildSectionTitle('Work Experience'),
                const SizedBox(height: 16),
                _buildExperience(aiContent['experience']),
                const SizedBox(height: 24),
              ],

              // Education
              if (aiContent['education'] != null) ...[
                _buildSectionTitle('Education'),
                const SizedBox(height: 16),
                _buildEducation(aiContent['education']),
                const SizedBox(height: 24),
              ],

              // Skills
              if (aiContent['skills'] != null) ...[
                _buildSectionTitle('Skills'),
                const SizedBox(height: 12),
                _buildSkills(aiContent['skills']),
                const SizedBox(height: 24),
              ],

              // Projects
              if (aiContent['projects'] != null) ...[
                _buildSectionTitle('Projects'),
                const SizedBox(height: 16),
                _buildProjects(aiContent['projects']),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> resume) {
    final userInput = resume['user_input_data'] as Map<String, dynamic>?;
    final personalInfo = userInput?['personalInfo'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          personalInfo?['name'] ?? 'Resume',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            if (personalInfo?['email'] != null)
              _buildContactItem(Icons.email, personalInfo!['email']),
            if (personalInfo?['phone'] != null)
              _buildContactItem(Icons.phone, personalInfo!['phone']),
            if (personalInfo?['location'] != null)
              _buildContactItem(Icons.location_on, personalInfo!['location']),
            if (personalInfo?['linkedIn'] != null)
              _buildContactItem(Icons.business, 'LinkedIn'),
            if (personalInfo?['github'] != null)
              _buildContactItem(Icons.code, 'GitHub'),
          ],
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF00D9FF),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
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
          padding: const EdgeInsets.only(bottom: 20.0),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          exp['company'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14,
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
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              if (exp['location'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  exp['location'],
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                ),
              ],
              const SizedBox(height: 8),
              if (exp['bullets'] != null) ...[
                ...((exp['bullets'] as List).map(
                  (bullet) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, left: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            bullet.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 13,
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
          padding: const EdgeInsets.only(bottom: 16.0),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          edu['school'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14,
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
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              if (edu['gpa'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  'GPA: ${edu['gpa']}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                ),
              ],
              if (edu['achievements'] != null &&
                  (edu['achievements'] as List).isNotEmpty) ...[
                const SizedBox(height: 6),
                ...((edu['achievements'] as List).map(
                  (achievement) => Text(
                    '• $achievement',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black87,
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

  Widget _buildSkills(dynamic skillsData) {
    if (skillsData is Map) {
      // Categorized skills
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (skillsData as Map<String, dynamic>).entries.map((entry) {
          final category = entry.key;
          final skills = entry.value as List;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${category[0].toUpperCase()}${category.substring(1)}:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map<Widget>((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D9FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF00D9FF).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        skill.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else if (skillsData is List) {
      // Simple list of skills
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
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
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
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project['name'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              if (project['description'] != null)
                Text(
                  project['description'],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              if (project['technologies'] != null) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ((project['technologies'] as List).map<Widget>((
                    tech,
                  ) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tech.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  }).toList()),
                ),
              ],
              if (project['highlights'] != null &&
                  (project['highlights'] as List).isNotEmpty) ...[
                const SizedBox(height: 8),
                ...((project['highlights'] as List).map(
                  (highlight) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, left: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 13)),
                        Expanded(
                          child: Text(
                            highlight.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
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
}
