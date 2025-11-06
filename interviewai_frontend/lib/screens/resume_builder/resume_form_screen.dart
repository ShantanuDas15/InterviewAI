// lib/screens/resume_builder/resume_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:interviewai_frontend/providers/resume_builder_provider.dart';
import 'dart:async';

/// Enhanced multi-step form for building a resume with AI enhancement
/// Features: Auto-save, template selection, validation, animations
class ResumeFormScreen extends ConsumerStatefulWidget {
  const ResumeFormScreen({super.key});

  @override
  ConsumerState<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends ConsumerState<ResumeFormScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Auto-save functionality
  Timer? _autoSaveTimer;
  bool _hasUnsavedChanges = false;
  DateTime? _lastSaved;

  // Template selection
  String _selectedTemplate = 'modern';
  final List<String> _templates = ['modern', 'classic', 'creative', 'ats'];

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _titleController = TextEditingController();

  // Personal Info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();

  // Experience (dynamic list)
  final List<Map<String, TextEditingController>> _experienceControllers = [];

  // Education (dynamic list)
  final List<Map<String, TextEditingController>> _educationControllers = [];

  // Skills
  final _skillsController = TextEditingController();

  // Projects (dynamic list)
  final List<Map<String, TextEditingController>> _projectControllers = [];

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Add initial experience entry
    _addExperienceEntry();
    // Add initial education entry
    _addEducationEntry();
    // Add initial project entry
    _addProjectEntry();

    // Setup auto-save
    _setupAutoSave();

    // Add listeners for unsaved changes
    _titleController.addListener(_markUnsavedChanges);
    _nameController.addListener(_markUnsavedChanges);
  }

  void _setupAutoSave() {
    // Reduced frequency and optimized to only save when truly needed
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      if (_hasUnsavedChanges && mounted) {
        _saveDraft();
      }
    });
  }

  void _markUnsavedChanges() {
    // Optimized: Only update state if actually changed and mounted
    if (!_hasUnsavedChanges && mounted) {
      _hasUnsavedChanges = true;
      // No setState needed here - only UI update on save
    }
  }

  Future<void> _saveDraft() async {
    if (!mounted) return;

    _lastSaved = DateTime.now();
    _hasUnsavedChanges = false;

    // Only update UI if needed - use setState sparingly
    if (mounted) {
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Draft saved automatically'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _animationController.dispose();
    _titleController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedInController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _skillsController.dispose();

    // Dispose experience controllers
    for (var exp in _experienceControllers) {
      for (var controller in exp.values) {
        controller.dispose();
      }
    }

    // Dispose education controllers
    for (var edu in _educationControllers) {
      for (var controller in edu.values) {
        controller.dispose();
      }
    }

    // Dispose project controllers
    for (var proj in _projectControllers) {
      for (var controller in proj.values) {
        controller.dispose();
      }
    }

    super.dispose();
  }

  void _addExperienceEntry() {
    setState(() {
      _experienceControllers.add({
        'title': TextEditingController(),
        'company': TextEditingController(),
        'location': TextEditingController(),
        'startDate': TextEditingController(),
        'endDate': TextEditingController(),
        'description': TextEditingController(),
      });
    });
  }

  void _removeExperienceEntry(int index) {
    setState(() {
      final exp = _experienceControllers.removeAt(index);
      for (var controller in exp.values) {
        controller.dispose();
      }
    });
  }

  void _addEducationEntry() {
    setState(() {
      _educationControllers.add({
        'degree': TextEditingController(),
        'school': TextEditingController(),
        'location': TextEditingController(),
        'startDate': TextEditingController(),
        'endDate': TextEditingController(),
        'gpa': TextEditingController(),
        'achievements': TextEditingController(),
      });
    });
  }

  void _removeEducationEntry(int index) {
    setState(() {
      final edu = _educationControllers.removeAt(index);
      for (var controller in edu.values) {
        controller.dispose();
      }
    });
  }

  void _addProjectEntry() {
    setState(() {
      _projectControllers.add({
        'name': TextEditingController(),
        'description': TextEditingController(),
        'technologies': TextEditingController(),
        'link': TextEditingController(),
      });
    });
  }

  void _removeProjectEntry(int index) {
    setState(() {
      final proj = _projectControllers.removeAt(index);
      for (var controller in proj.values) {
        controller.dispose();
      }
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showExitConfirmation() {
    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1D1E33),
          title: Text(
            'Unsaved Changes',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: Text(
            'You have unsaved changes. Do you want to save before leaving?',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: Text(
                'Discard',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _saveDraft();
                Navigator.pop(context);
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9FF),
                foregroundColor: Colors.black,
              ),
              child: Text('Save', style: GoogleFonts.inter()),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  Widget _buildTemplateSelector() {
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
            'Choose Template',
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
              children: _templates.map((template) {
                final isSelected = _selectedTemplate == template;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTemplate = template;
                        _markUnsavedChanges();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
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
                            _getTemplateIcon(template),
                            size: 18,
                            color: isSelected ? Colors.black : Colors.white70,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            template.toUpperCase(),
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

  Widget _buildProgressIndicator() {
    final progress = (_currentStep + 1) / 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${_currentStep + 1} of 5',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
              ),
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00D9FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF0A0E21),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00D9FF),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Build the request data
    final formData = {
      'title': _titleController.text,
      'template': _selectedTemplate,
      'personalInfo': {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
        'linkedIn': _linkedInController.text,
        'github': _githubController.text,
        'portfolio': _portfolioController.text,
      },
      'experience': _experienceControllers
          .map(
            (exp) => {
              'title': exp['title']!.text,
              'company': exp['company']!.text,
              'location': exp['location']!.text,
              'startDate': exp['startDate']!.text,
              'endDate': exp['endDate']!.text,
              'description': exp['description']!.text,
            },
          )
          .toList(),
      'education': _educationControllers
          .map(
            (edu) => {
              'degree': edu['degree']!.text,
              'school': edu['school']!.text,
              'location': edu['location']!.text,
              'startDate': edu['startDate']!.text,
              'endDate': edu['endDate']!.text,
              'gpa': edu['gpa']!.text,
              'achievements': edu['achievements']!.text,
            },
          )
          .toList(),
      'skills': _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'projects': _projectControllers
          .map(
            (proj) => {
              'name': proj['name']!.text,
              'description': proj['description']!.text,
              'technologies': proj['technologies']!.text,
              'link': proj['link']!.text,
            },
          )
          .toList(),
      'certifications': <Map<String, String>>[],
    };

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Building your professional resume...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Call the provider to build the resume
      final result = await ref
          .read(resumeBuilderProvider.notifier)
          .buildResume(formData);

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      if (result != null && result['id'] != null) {
        // Navigate to the display screen
        context.go('/resume-builder/view/${result['id']}');
      } else {
        throw Exception('Failed to get resume ID from response');
      }
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Show error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Resume Builder',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            if (_lastSaved != null)
              Text(
                'Last saved: ${_formatTime(_lastSaved!)}',
                style: GoogleFonts.inter(fontSize: 10, color: Colors.white60),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF1D1E33),
        elevation: 0,
        actions: [
          if (_hasUnsavedChanges)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Unsaved',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveDraft,
            tooltip: 'Save Draft',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Template Selector
              _buildTemplateSelector(),

              // Progress Indicator
              _buildProgressIndicator(),

              // Stepper Form
              Expanded(
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 4) {
                      setState(() => _currentStep++);
                      _animationController.reset();
                      _animationController.forward();
                    } else {
                      _submitForm();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                    } else {
                      _showExitConfirmation();
                    }
                  },
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D9FF),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              elevation: 8,
                              shadowColor: const Color(
                                0xFF00D9FF,
                              ).withValues(alpha: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentStep == 4
                                      ? 'Build Resume'
                                      : 'Continue',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentStep == 4
                                      ? Icons.psychology
                                      : Icons.arrow_forward,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: details.onStepCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              _currentStep == 0 ? 'Cancel' : 'Back',
                              style: GoogleFonts.inter(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  steps: [
                    // Step 0: Title and Personal Info
                    Step(
                      title: Text(
                        'Personal Information',
                        style: GoogleFonts.poppins(),
                      ),
                      isActive: _currentStep >= 0,
                      content: Column(
                        children: [
                          _buildTextField(
                            controller: _titleController,
                            label: 'Resume Title *',
                            hint: 'e.g., Software Engineer Resume',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name *',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email *',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _locationController,
                            label: 'Location',
                            hint: 'e.g., San Francisco, CA',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _linkedInController,
                            label: 'LinkedIn URL',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _githubController,
                            label: 'GitHub URL',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _portfolioController,
                            label: 'Portfolio URL',
                          ),
                        ],
                      ),
                    ),

                    // Step 1: Experience
                    Step(
                      title: Text(
                        'Work Experience',
                        style: GoogleFonts.poppins(),
                      ),
                      isActive: _currentStep >= 1,
                      content: Column(
                        children: [
                          ..._experienceControllers.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final controllers = entry.value;
                            return _buildExperienceCard(index, controllers);
                          }),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _addExperienceEntry,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Experience'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF00D9FF),
                              side: const BorderSide(color: Color(0xFF00D9FF)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Step 2: Education
                    Step(
                      title: Text('Education', style: GoogleFonts.poppins()),
                      isActive: _currentStep >= 2,
                      content: Column(
                        children: [
                          ..._educationControllers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final controllers = entry.value;
                            return _buildEducationCard(index, controllers);
                          }),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _addEducationEntry,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Education'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF00D9FF),
                              side: const BorderSide(color: Color(0xFF00D9FF)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Step 3: Skills
                    Step(
                      title: Text('Skills', style: GoogleFonts.poppins()),
                      isActive: _currentStep >= 3,
                      content: Column(
                        children: [
                          _buildTextField(
                            controller: _skillsController,
                            label: 'Skills (comma-separated) *',
                            hint: 'Python, Java, React, AWS, Git',
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter at least one skill';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your skills separated by commas',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Step 4: Projects
                    Step(
                      title: Text('Projects', style: GoogleFonts.poppins()),
                      isActive: _currentStep >= 4,
                      content: Column(
                        children: [
                          ..._projectControllers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final controllers = entry.value;
                            return _buildProjectCard(index, controllers);
                          }),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _addProjectEntry,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Project'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF00D9FF),
                              side: const BorderSide(color: Color(0xFF00D9FF)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFF1D1E33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        labelStyle: GoogleFonts.inter(color: Colors.white70),
        hintStyle: GoogleFonts.inter(color: Colors.white38),
      ),
      style: GoogleFonts.inter(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildExperienceCard(
    int index,
    Map<String, TextEditingController> controllers,
  ) {
    return Card(
      color: const Color(0xFF1D1E33),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Experience ${index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00D9FF),
                  ),
                ),
                if (_experienceControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeExperienceEntry(index),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['title']!,
              label: 'Job Title',
              hint: 'e.g., Software Engineer',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['company']!,
              label: 'Company',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['location']!,
              label: 'Location',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controllers['startDate']!,
                    label: 'Start Date',
                    hint: 'MM/YYYY',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: controllers['endDate']!,
                    label: 'End Date',
                    hint: 'MM/YYYY or Present',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['description']!,
              label: 'Description',
              hint: 'Describe your responsibilities and achievements',
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard(
    int index,
    Map<String, TextEditingController> controllers,
  ) {
    return Card(
      color: const Color(0xFF1D1E33),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Education ${index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00D9FF),
                  ),
                ),
                if (_educationControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeEducationEntry(index),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['degree']!,
              label: 'Degree',
              hint: 'e.g., Bachelor of Science in Computer Science',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['school']!,
              label: 'School',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['location']!,
              label: 'Location',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controllers['startDate']!,
                    label: 'Start Date',
                    hint: 'YYYY',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: controllers['endDate']!,
                    label: 'End Date',
                    hint: 'YYYY',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['gpa']!,
              label: 'GPA (optional)',
              hint: 'e.g., 3.8/4.0',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['achievements']!,
              label: 'Achievements (optional)',
              hint: 'Dean\'s List, Honors, etc.',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    int index,
    Map<String, TextEditingController> controllers,
  ) {
    return Card(
      color: const Color(0xFF1D1E33),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Project ${index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00D9FF),
                  ),
                ),
                if (_projectControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeProjectEntry(index),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['name']!,
              label: 'Project Name',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['description']!,
              label: 'Description',
              hint: 'Describe what you built and its impact',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['technologies']!,
              label: 'Technologies Used',
              hint: 'e.g., React, Node.js, MongoDB',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: controllers['link']!,
              label: 'Project Link (optional)',
              hint: 'GitHub, live demo, etc.',
            ),
          ],
        ),
      ),
    );
  }
}
