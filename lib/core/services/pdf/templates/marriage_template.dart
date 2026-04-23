import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:banjarabio/core/services/pdf/templates/biodata_template_base.dart';

class MarriageTemplate extends BiodataTemplateBase {
  final PdfColor accentColor;
  final pw.MemoryImage? templateImage;

  MarriageTemplate({
    required super.content,
    required super.language,
    required super.font,
    required super.boldFont,
    required super.mantraFont,
    required this.accentColor,
    this.templateImage,
    super.logo,
    super.profilePhoto,
    super.isLocked = true,
  });

  @override
  Future<pw.Document> generate() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(120, 125, 120, 125),
          buildBackground: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Stack(
                children: [
                  if (templateImage != null)
                    pw.Image(
                      templateImage!,
                      fit: pw.BoxFit.fill,
                    ),
                  // Decorative border around the page (1.4pt)
                  pw.Container(
                    margin: const pw.EdgeInsets.all(20),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        width: 1.4,
                      ),
                    ),
                  ),
                  if (isLocked) buildWatermark(),
                ],
              ),
            );
          },
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildPersonalDetails(),
            pw.SizedBox(height: 15),
            _buildEducationProfession(),
            pw.SizedBox(height: 15),
            _buildFamilyDetails(),
            pw.SizedBox(height: 15),
            _buildLocationContact(),
            if (content.partnerExpectations.isNotEmpty) ...[
              pw.SizedBox(height: 15),
              _buildSectionTitle(label('Partner Expectations')),
              _buildLargeTextField(content.partnerExpectations),
            ],
            if (content.aboutMe.isNotEmpty) ...[
              pw.SizedBox(height: 15),
              _buildSectionTitle(label('About Me')),
              _buildLargeTextField(content.aboutMe),
            ],
            if (profilePhoto != null) ...[
              pw.SizedBox(height: 20),
              _buildProfilePhotoSection(),
            ],
            pw.SizedBox(height: 30),
            _buildMarriageFooter(),
          ];
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildHeader() {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            label('Biodata').toUpperCase(),
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 24,
              color: accentColor,
              letterSpacing: 2,
            ),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Center(
          child: pw.Container(
            height: 1.5,
            width: 80,
            color: accentColor,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildProfilePhotoSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label('Profile Photograph')),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Image(
              profilePhoto!,
              width: 300,
              height: 400,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border(left: pw.BorderSide(color: accentColor, width: 3)),
      ),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 12,
          color: accentColor,
        ),
      ),
    );
  }

  pw.Widget _buildPersonalDetails() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label('Personal Details')),
        _buildDetailsGrid(content.personalDetails),
      ],
    );
  }

  pw.Widget _buildEducationProfession() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label('Education & Profession')),
        _buildDetailsGrid(content.educationProfession, isSensitive: true),
      ],
    );
  }

  pw.Widget _buildFamilyDetails() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label('Family Details')),
        _buildDetailsGrid(content.familyDetails, isSensitive: true),
      ],
    );
  }

  pw.Widget _buildLocationContact() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label('Location & Contact')),
        _buildDetailsGrid(content.locationContact, isSensitive: true),
      ],
    );
  }

  pw.Widget _buildDetailsGrid(Map<String, String> details, {bool isSensitive = false}) {
    final List<pw.TableRow> rows = [];
    details.forEach((key, value) {
      String displayValue = value;
      if (isLocked && isSensitive && _isSensitiveField(key)) {
        displayValue = '********';
      }
      
      rows.add(
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(
                label(key),
                style: labelStyle(),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(
                ':  $displayValue',
                style: valueStyle(),
              ),
            ),
          ],
        ),
      );
    });

    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(120),
        1: const pw.FlexColumnWidth(),
      },
      children: rows,
    );
  }

  bool _isSensitiveField(String key) {
    final sensitiveKeys = [
      'Occupation', 'Job Details', 'Annual Income', 'Company',
      'Father Name', 'Father Occup.', 'Mother Name', 'Mother Occup.',
      'Contact No.', 'Current Location'
    ];
    return sensitiveKeys.contains(key);
  }

  pw.Widget _buildLargeTextField(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey200),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 10),
      ),
    );
  }

  pw.Widget _buildMarriageFooter() {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Column(
        children: [
          pw.Divider(color: PdfColors.grey300, thickness: 0.5),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              if (logo != null) ...[
                pw.Image(logo!, width: 25, height: 25),
                pw.SizedBox(width: 8),
              ],
              pw.Text(
                'BANJARA BIO',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                  color: accentColor,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            label('Download App Line'),
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'https://banjarabio.com',
            style: pw.TextStyle(
              font: font,
              fontSize: 9,
              color: accentColor,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
