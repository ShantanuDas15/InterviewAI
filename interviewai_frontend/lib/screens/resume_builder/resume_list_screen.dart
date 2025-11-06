// lib/screens/resume_builder/resume_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:interviewai_frontend/providers/resume_builder_provider.dart';

/// Screen to manage and view all resumes built by the user
class ResumeListScreen extends ConsumerStatefulWidget {
  const ResumeListScreen({super.key});

  @override
  ConsumerState<ResumeListScreen> createState() => _ResumeListScreenState();
}

class _ResumeListScreenState extends ConsumerState<ResumeListScreen> {
  String _sortBy = 'recent'; // recent, title, template
  String _filterTemplate = 'all';

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumesStream = ref.watch(builtResumesListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text(
          'My Resumes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1D1E33),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort By',
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'recent' ? Icons.check : Icons.access_time,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Most Recent'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'title',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'title' ? Icons.check : Icons.sort_by_alpha,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Title (A-Z)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'template',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'template' ? Icons.check : Icons.palette,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Template'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: resumesStream.when(
        data: (resumes) {
          if (resumes.isEmpty) {
            return _buildEmptyState();
          }

          // Apply sorting and filtering
          var filteredResumes = resumes;

          // Filter by template
          if (_filterTemplate != 'all') {
            filteredResumes = resumes.where((resume) {
              final template =
                  resume['user_input_data']?['template'] ?? 'modern';
              return template == _filterTemplate;
            }).toList();
          }

          // Sort resumes
          final sortedResumes = List<Map<String, dynamic>>.from(
            filteredResumes,
          );
          if (_sortBy == 'recent') {
            sortedResumes.sort((a, b) {
              final aDate = DateTime.parse(a['created_at'] ?? '');
              final bDate = DateTime.parse(b['created_at'] ?? '');
              return bDate.compareTo(aDate);
            });
          } else if (_sortBy == 'title') {
            sortedResumes.sort((a, b) {
              return (a['title'] ?? '').toString().toLowerCase().compareTo(
                (b['title'] ?? '').toString().toLowerCase(),
              );
            });
          } else if (_sortBy == 'template') {
            sortedResumes.sort((a, b) {
              final aTemplate = a['user_input_data']?['template'] ?? 'modern';
              final bTemplate = b['user_input_data']?['template'] ?? 'modern';
              return aTemplate.toString().compareTo(bTemplate.toString());
            });
          }

          return Column(
            children: [
              // Stats Header
              _buildStatsHeader(resumes.length, filteredResumes.length),

              // Resume Grid/List
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: sortedResumes.length,
                  // Performance: Add cache extent for smoother scrolling
                  cacheExtent: 500,
                  itemBuilder: (context, index) {
                    final resume = sortedResumes[index];
                    // Performance: Use unique key to prevent unnecessary rebuilds
                    return _buildResumeCard(
                      resume,
                      key: ValueKey(resume['id']),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D9FF)),
          ),
        ),
        error: (error, stack) => _buildErrorState(error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/resume-builder'),
        backgroundColor: const Color(0xFF00D9FF),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: Text(
          'New Resume',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildStatsHeader(int total, int filtered) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          _buildStatItem(Icons.description, total.toString(), 'Total'),
          const SizedBox(width: 24),
          _buildStatItem(Icons.filter_alt, filtered.toString(), 'Showing'),
          const Spacer(),
          if (_filterTemplate != 'all')
            Chip(
              label: Text(
                _filterTemplate.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              backgroundColor: const Color(0xFF00D9FF),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() {
                  _filterTemplate = 'all';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00D9FF), size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResumeCard(Map<String, dynamic> resume, {Key? key}) {
    final title = resume['title'] ?? 'Untitled Resume';
    final createdAt = DateTime.parse(
      resume['created_at'] ?? DateTime.now().toString(),
    );
    final template = resume['user_input_data']?['template'] ?? 'modern';
    final resumeId = resume['id'].toString();

    return Card(
      key: key, // Performance: Use key for widget identity
      color: const Color(0xFF1D1E33),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.go('/resume-builder/view/$resumeId'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview/Template indicator
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getTemplateGradient(template),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getTemplateIcon(template),
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        template.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Resume Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white60,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatTimeAgo(createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 20),
                    onPressed: () =>
                        context.go('/resume-builder/view/$resumeId'),
                    tooltip: 'View',
                    color: const Color(0xFF00D9FF),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, size: 20),
                    onPressed: () => _downloadResume(resumeId),
                    tooltip: 'Download',
                    color: Colors.white70,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _deleteResume(resumeId, title),
                    tooltip: 'Delete',
                    color: Colors.red.shade300,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getTemplateGradient(String template) {
    switch (template) {
      case 'modern':
        return [const Color(0xFF00D9FF), const Color(0xFF0077FF)];
      case 'classic':
        return [const Color(0xFF6B46C1), const Color(0xFF9F7AEA)];
      case 'creative':
        return [const Color(0xFFED8936), const Color(0xFFF6AD55)];
      case 'ats':
        return [const Color(0xFF38B2AC), const Color(0xFF4FD1C5)];
      default:
        return [const Color(0xFF00D9FF), const Color(0xFF0077FF)];
    }
  }

  IconData _getTemplateIcon(String template) {
    switch (template) {
      case 'modern':
        return Icons.flash_on;
      case 'classic':
        return Icons.article;
      case 'creative':
        return Icons.palette;
      case 'ats':
        return Icons.verified;
      default:
        return Icons.description;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description,
                size: 64,
                color: Color(0xFF00D9FF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Resumes Yet',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first AI-powered resume and stand out from the crowd!',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/resume-builder'),
              icon: const Icon(Icons.add),
              label: const Text('Create Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9FF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
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
              'Error loading resumes',
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
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: Text(
          'Filter Resumes',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Template',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('all', 'All'),
                _buildFilterChip('modern', 'Modern'),
                _buildFilterChip('classic', 'Classic'),
                _buildFilterChip('creative', 'Creative'),
                _buildFilterChip('ats', 'ATS'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterTemplate = 'all';
              });
              Navigator.pop(context);
            },
            child: Text('Clear', style: GoogleFonts.inter(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D9FF),
              foregroundColor: Colors.black,
            ),
            child: Text('Apply', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterTemplate == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterTemplate = value;
        });
      },
      backgroundColor: const Color(0xFF0A0E21),
      selectedColor: const Color(0xFF00D9FF),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        color: isSelected ? Colors.black : Colors.white70,
      ),
    );
  }

  void _downloadResume(String resumeId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Download feature coming soon!'),
        backgroundColor: Colors.blue.shade700,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            context.go('/resume-builder/view/$resumeId');
          },
        ),
      ),
    );
  }

  Future<void> _deleteResume(String resumeId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: Text(
          'Delete Resume?',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(color: Colors.white70),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: '"$title"',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D9FF),
                ),
              ),
              const TextSpan(text: '? This action cannot be undone.'),
            ],
          ),
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
        await ref.read(resumeDeleterProvider.notifier).deleteResume(resumeId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resume "$title" deleted successfully'),
              backgroundColor: Colors.green.shade700,
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
}
