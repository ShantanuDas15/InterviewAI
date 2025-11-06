import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  /// Generates and downloads a PDF for resume analysis results
  static Future<void> downloadResumeAnalysisPdf({
    required Map<String, dynamic> analysis,
    required String fileName,
  }) async {
    final pdf = pw.Document();

    // Extract data - handle both camelCase and snake_case
    final overallScore =
        (analysis['overallScore'] ?? analysis['overall_score'] ?? 0) as int;
    final strengths = analysis['strengths'];
    final improvements = analysis['improvements'];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          _buildHeader('Resume Analysis Report'),
          pw.SizedBox(height: 20),

          // Overall Score
          _buildScoreCard(overallScore),
          pw.SizedBox(height: 28),

          // Analysis Content
          ..._buildAnalysisContent(strengths, improvements),
        ],
      ),
    );

    // Download the PDF
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: fileName,
    );
  }

  /// Generates and downloads a PDF for interview feedback
  static Future<void> downloadInterviewFeedbackPdf({
    required Map<String, dynamic> feedback,
    required String interviewTitle,
    required String fileName,
  }) async {
    final pdf = pw.Document();

    // Extract data - handle both camelCase and snake_case
    final overallScore =
        (feedback['overallScore'] ?? feedback['overall_score'] ?? 0) as int;
    final strengths = feedback['strengths'] ?? 'No strengths provided.';
    final improvements =
        feedback['areasForImprovement'] ??
        feedback['areas_for_improvement'] ??
        'No areas for improvement provided.';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          _buildHeader('Interview Feedback Report', subtitle: interviewTitle),
          pw.SizedBox(height: 20),

          // Overall Score
          _buildScoreCard(overallScore, label: 'Overall Performance Score'),
          pw.SizedBox(height: 28),

          // Strengths Section
          _buildTextSection(
            title: 'Strengths',
            content: strengths.toString(),
            color: PdfColors.green700,
          ),
          pw.SizedBox(height: 24),

          // Improvements Section
          _buildTextSection(
            title: 'Areas for Improvement',
            content: improvements.toString(),
            color: PdfColors.orange700,
          ),
        ],
      ),
    );

    // Download the PDF
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: fileName,
    );
  }

  // ===== HELPER METHODS =====

  static pw.Widget _buildHeader(String title, {String? subtitle}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        if (subtitle != null) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            subtitle,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ],
        pw.SizedBox(height: 8),
        pw.Text(
          'Generated: ${DateFormat.yMMMMd().add_jm().format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
      ],
    );
  }

  static pw.Widget _buildScoreCard(
    int score, {
    String label = 'Overall Score',
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: _getScoreColor(score), width: 3),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '$score/100',
            style: pw.TextStyle(
              fontSize: 32,
              fontWeight: pw.FontWeight.bold,
              color: _getScoreColor(score),
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildAnalysisContent(
    dynamic strengths,
    dynamic improvements,
  ) {
    final List<pw.Widget> widgets = [];

    // Handle structured analysis (Map with sections) or simple list
    if (strengths is Map) {
      // Structured analysis with multiple sections
      strengths.forEach((sectionKey, sectionValue) {
        final sectionTitle = _formatSectionTitle(sectionKey.toString());

        if (sectionValue is Map) {
          // Section with subsections (e.g., skillsAssessment with technical, soft, domain)
          widgets.add(
            _buildStructuredSection(
              sectionTitle,
              Map<String, dynamic>.from(sectionValue),
              PdfColors.blue700,
            ),
          );
        } else if (sectionValue is List) {
          // Section with simple list
          widgets.add(
            _buildListSection(sectionTitle, sectionValue, PdfColors.blue700),
          );
        }

        widgets.add(pw.SizedBox(height: 20));
      });
    } else if (strengths is List && strengths.isNotEmpty) {
      // Simple list of strengths
      widgets.add(
        _buildListSection('Strengths', strengths, PdfColors.green700),
      );
      widgets.add(pw.SizedBox(height: 20));
    }

    // Handle improvements (usually in the improvements field or similar structure)
    if (improvements != null) {
      widgets.add(
        _buildListSection(
          'Areas for Improvement',
          _extractList(improvements),
          PdfColors.orange700,
        ),
      );
    }

    return widgets;
  }

  static pw.Widget _buildStructuredSection(
    String title,
    Map<String, dynamic> subsections,
    PdfColor color,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 12),
          ...subsections.entries.map((entry) {
            final subTitle = _formatSectionTitle(entry.key);
            final items = _extractList(entry.value);

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  subTitle,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                ),
                pw.SizedBox(height: 6),
                ...items.map(
                  (item) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6, left: 12),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 6,
                          height: 6,
                          margin: const pw.EdgeInsets.only(top: 4, right: 8),
                          decoration: pw.BoxDecoration(
                            color: color,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            item,
                            style: const pw.TextStyle(
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _buildListSection(
    String title,
    List<dynamic> items,
    PdfColor color,
  ) {
    if (items.isEmpty) return pw.SizedBox();

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 12),
          ...items.map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8, left: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 8,
                    height: 8,
                    margin: const pw.EdgeInsets.only(top: 4, right: 10),
                    decoration: pw.BoxDecoration(
                      color: color,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      item.toString(),
                      style: const pw.TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTextSection({
    required String title,
    required String content,
    required PdfColor color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            content,
            style: const pw.TextStyle(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  static PdfColor _getScoreColor(int score) {
    if (score >= 80) return PdfColors.green700;
    if (score >= 60) return PdfColors.orange700;
    return PdfColors.red700;
  }

  static String _formatSectionTitle(String key) {
    // Convert camelCase to Title Case
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static List<String> _extractList(dynamic data) {
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    } else if (data is String) {
      return [data];
    }
    return [];
  }
}
