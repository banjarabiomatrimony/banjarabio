import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:banjarabio/core/services/pdf/templates/biodata_template_base.dart';

/// World-class Marriage Biodata PDF Template.
///
/// Uses 100% programmatic borders and layout — NO dependency on PNG
/// background images for content positioning. Template PNGs are rendered
/// as an optional faint watermark only.
///
/// Layout guarantees:
/// - Decorative double-line border is drawn at known PDF-point coordinates.
/// - Content margins are derived from the programmatic border, not from PNG pixel math.
/// - Works identically on all A4 pages regardless of image resolution or aspect ratio.
class MarriageTemplate extends BiodataTemplateBase {
  final PdfColor accentColor;
  final pw.MemoryImage? templateImage;

  /// Per-template safe area insets (PDF points).
  final double marginLeft;
  final double marginTop;
  final double marginRight;
  final double marginBottom;
  final String? headerMantra;

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
    this.marginLeft = 60,
    this.marginTop = 90,
    this.marginRight = 60,
    this.marginBottom = 80,
    this.headerMantra,
  });

  // ──────────────────────────────────────────────────────────────────────
  //  Design tokens
  // ──────────────────────────────────────────────────────────────────────
  static const double _borderInset = 18; // outer border from page edge
  static const double _innerBorderGap = 4; // gap between double-lines
  static const double _cornerSize = 22; // decorative corner extent

  // Fixed content margins inside the programmatic border
  static const double _contentMarginH = 38; // horizontal inside border
  static const double _contentMarginTop = 34; // top inside border
  static const double _contentMarginBot = 28; // bottom inside border

  // Effective margin from page edge to content
  double get _effectiveLeft => _borderInset + _innerBorderGap + _contentMarginH;
  double get _effectiveRight => _borderInset + _innerBorderGap + _contentMarginH;
  double get _effectiveTop => _borderInset + _innerBorderGap + _contentMarginTop;
  double get _effectiveBottom => _borderInset + _innerBorderGap + _contentMarginBot;

  // Colors derived from accent
  PdfColor get _accentMedium =>
      PdfColor(accentColor.red, accentColor.green, accentColor.blue, 0.25);

  // ──────────────────────────────────────────────────────────────────────
  //  Main generate()
  // ──────────────────────────────────────────────────────────────────────
  @override
  Future<pw.Document> generate() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.fromLTRB(
            _effectiveLeft,
            _effectiveTop,
            _effectiveRight,
            _effectiveBottom,
          ),
          buildBackground: _buildPageBackground,
        ),
        build: (pw.Context context) {
          return [
            // ── Ganesh Mantra ──
            _buildMantra(),
            pw.SizedBox(height: 10),

            // ── BIODATA Title ──
            _buildTitle(),
            pw.SizedBox(height: 14),

            // ── Photo + Name Card ──
            _buildHeaderCard(),
            pw.SizedBox(height: 14),

            // ── Personal Details ──
            _buildSection(
              label('Personal Details'),
              content.personalDetails,
            ),
            pw.SizedBox(height: 10),

            // ── Education & Profession ──
            _buildSection(
              label('Education & Profession'),
              content.educationProfession,
              isSensitive: true,
            ),
            pw.SizedBox(height: 10),

            // ── Family Details ──
            _buildSection(
              label('Family Details'),
              content.familyDetails,
              isSensitive: true,
            ),
            pw.SizedBox(height: 10),

            // ── Location & Contact ──
            _buildSection(
              label('Location & Contact'),
              content.locationContact,
              isSensitive: true,
            ),

            // ── Partner Expectations ──
            if (content.partnerExpectations.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              _buildSection(
                label('Partner Expectations'),
                {'': label(content.partnerExpectations)},
                isLongText: true,
              ),
            ],

            // ── About Me ──
            if (content.aboutMe.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              _buildSection(
                label('About Me'),
                {'': label(content.aboutMe)},
                isLongText: true,
              ),
            ],

            pw.SizedBox(height: 16),
            // ── Footer ──
            _buildBrandFooter(),
          ];
        },
      ),
    );

    addFullPagePhotoPage(pdf, accentColor: accentColor);
    return pdf;
  }

  // ──────────────────────────────────────────────────────────────────────
  //  Page background: programmatic border + optional PNG watermark
  // ──────────────────────────────────────────────────────────────────────
  pw.Widget _buildPageBackground(pw.Context context) {
    final isFirstPage = context.pageNumber == 1;

    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Stack(
        children: [
          // Optional faint template watermark (first page only)
          if (isFirstPage && templateImage != null)
            pw.Opacity(
              opacity: 0.06,
              child: pw.Image(
                templateImage!,
                fit: pw.BoxFit.fill,
              ),
            ),

          // Programmatic double-line border (ALL pages)
          _buildDoubleBorder(),

          // Corner ornaments
          _buildCornerOrnaments(),

          // Watermark overlay when locked
          if (isLocked) buildWatermark(),
        ],
      ),
    );
  }

  /// Draws a decorative double-line border at known PDF coordinates.
  pw.Widget _buildDoubleBorder() {
    return pw.Stack(
      children: [
        // Outer border
        pw.Container(
          margin: const pw.EdgeInsets.all(_borderInset),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: accentColor,
              width: 1.8,
            ),
          ),
        ),
        // Inner border
        pw.Container(
          margin: const pw.EdgeInsets.all(_borderInset + _innerBorderGap + 1.8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: _accentMedium,
              width: 0.6,
            ),
          ),
        ),
      ],
    );
  }

  /// Draws decorative L-shaped corner ornaments inside the border.
  pw.Widget _buildCornerOrnaments() {
    final inset = _borderInset + _innerBorderGap + 6;
    return pw.Stack(
      children: [
        // Top-left
        pw.Positioned(
          top: inset,
          left: inset,
          child: _cornerShape(),
        ),
        // Top-right
        pw.Positioned(
          top: inset,
          right: inset,
          child: pw.Transform.rotate(
            angle: 1.5708, // 90°
            child: _cornerShape(),
          ),
        ),
        // Bottom-left
        pw.Positioned(
          bottom: inset,
          left: inset,
          child: pw.Transform.rotate(
            angle: -1.5708,
            child: _cornerShape(),
          ),
        ),
        // Bottom-right
        pw.Positioned(
          bottom: inset,
          right: inset,
          child: pw.Transform.rotate(
            angle: 3.14159, // 180°
            child: _cornerShape(),
          ),
        ),
      ],
    );
  }

  pw.Widget _cornerShape() {
    return pw.Container(
      width: _cornerSize,
      height: _cornerSize,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: accentColor, width: 1.5),
          left: pw.BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  //  Content builders
  // ──────────────────────────────────────────────────────────────────────

  /// Header Blessing / Mantra
  pw.Widget _buildMantra() {
    final mantraText = headerMantra != null && headerMantra!.trim().isNotEmpty
        ? headerMantra!.trim()
        : '॥ जय सेवालाल ॥   ॥ श्री गणेशाय नमः ॥';

    return pw.Center(
      child: pw.Text(
        mantraText,
        style: pw.TextStyle(
          font: mantraFont,
          fontSize: AppTypography.bodySmallFixed,
          color: accentColor,
        ),
      ),
    );
  }

  /// Large BIODATA title with decorative underline.
  pw.Widget _buildTitle() {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            label('Biodata').toUpperCase(),
            style: pw.TextStyle(
              font: boldFont,
              fontSize: AppTypography.headingMediumFixed,
              color: accentColor,
              letterSpacing: language == 'English' ? 3.5 : 0.5,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        // Decorative divider: line – diamond – line
        pw.Center(
          child: pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(height: 1, width: 50, color: accentColor),
              pw.SizedBox(width: 6),
              pw.Transform.rotate(
                angle: 0.7854, // 45°
                child: pw.Container(
                  width: 6,
                  height: 6,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: accentColor),
                  ),
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Container(height: 1, width: 50, color: accentColor),
            ],
          ),
        ),
      ],
    );
  }

  /// Header card: profile photo (left) + key personal info (right).
  pw.Widget _buildHeaderCard() {
    // Extract key fields for the header
    final name = content.personalDetails['Full Name'] ?? '';
    final surname = content.personalDetails['Surname'] ?? '';
    final age = content.personalDetails['Age'] ?? '';
    final height = content.personalDetails['Height'] ?? '';
    final dob = content.personalDetails['Date of Birth'] ?? '';
    final maritalStatus = content.personalDetails['Marital Status'] ?? '';

    final hasPhoto = profilePhoto != null;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _accentMedium, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Profile Photo
          if (hasPhoto) ...[
            pw.Container(
              width: 90,
              height: 110,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: accentColor),
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(3)),
              ),
              child: pw.ClipRRect(
                horizontalRadius: 2,
                verticalRadius: 2,
                child: pw.Image(
                  profilePhoto!,
                  fit: pw.BoxFit.cover,
                  width: 90,
                  height: 110,
                ),
              ),
            ),
            pw.SizedBox(width: 14),
          ],

          // Key details
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Name
                pw.Text(
                  label(name),
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: AppTypography.bodyMediumFixed,
                    color: accentColor,
                  ),
                ),
                if (surname.isNotEmpty)
                  pw.Text(
                    label(surname),
                    style: pw.TextStyle(
                      font: font,
                      fontSize: AppTypography.labelTinyFixed,
                      color: PdfColors.black,
                    ),
                  ),
                pw.SizedBox(height: 6),
                pw.Divider(color: _accentMedium, thickness: 0.4),
                pw.SizedBox(height: 4),
                _headerRow(label('Age'), label(age)),
                _headerRow(label('Height'), label(height)),
                _headerRow(label('Date of Birth'), label(dob)),
                _headerRow(label('Marital Status'), label(maritalStatus)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _headerRow(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 85,
            child: pw.Text(key, style: pw.TextStyle(font: boldFont, fontSize: AppTypography.labelTinyFixed, color: PdfColors.black)),
          ),
          pw.Text(':  ', style: pw.TextStyle(font: font, fontSize: AppTypography.labelTinyFixed, color: PdfColors.black)),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: font, fontSize: AppTypography.labelTinyFixed, color: PdfColors.black)),
          ),
        ],
      ),
    );
  }

  /// A section with colored header bar + key-value table or long text.
  pw.Widget _buildSection(
    String title,
    Map<String, String> details, {
    bool isSensitive = false,
    bool isLongText = false,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Section header bar — white bg, black text, left accent border
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border(
              left: pw.BorderSide(color: accentColor, width: 3),
              bottom: const pw.BorderSide(color: PdfColors.grey300, width: 0.5),
            ),
          ),
          child: pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              font: boldFont,
              fontSize: AppTypography.labelTinyFixed,
              color: PdfColors.black,
              letterSpacing: 1,
            ),
          ),
        ),
        pw.SizedBox(height: 4),

        // Content
        if (isLongText)
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey200),
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(3)),
            ),
            child: pw.Text(
              label(details.values.first),
              style: pw.TextStyle(font: font, fontSize: AppTypography.labelTinyFixed, lineSpacing: 2),
            ),
          )
        else
          _buildKeyValueTable(details, isSensitive: isSensitive),
      ],
    );
  }

  /// Clean key-value table with alternating row shading.
  pw.Widget _buildKeyValueTable(
    Map<String, String> details, {
    bool isSensitive = false,
  }) {
    final rows = <pw.TableRow>[];

    details.forEach((key, value) {
      String displayValue = value;
      if (isLocked && isSensitive && _isSensitiveField(key)) {
        displayValue = '● ● ● ● ● ●';
      }

      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.white,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                  vertical: 3, horizontal: 6),
              child: pw.Text(
                label(key),
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: AppTypography.labelTinyFixed,
                  color: PdfColors.black,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                  vertical: 3, horizontal: 6),
              child: pw.Text(
                label(displayValue),
                style: pw.TextStyle(font: font, fontSize: AppTypography.labelTinyFixed, color: PdfColors.black),
              ),
            ),
          ],
        ),
      );
    });

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.3),
      columnWidths: {
        0: const pw.FixedColumnWidth(120),
        1: const pw.FlexColumnWidth(),
      },
      children: rows,
    );
  }

  bool _isSensitiveField(String key) {
    const sensitiveKeys = [
      'Occupation', 'Job Details', 'Annual Income', 'Company',
      'Father Name', 'Father Occup.', 'Mother Name', 'Mother Occup.',
      'Contact No.', 'Current Location',
    ];
    return sensitiveKeys.contains(key);
  }

  /// App branding footer.
  pw.Widget _buildBrandFooter() {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Column(
        children: [
          // Ornamental divider
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(height: 0.5, width: 60, color: PdfColors.grey400),
              pw.SizedBox(width: 8),
              pw.Container(
                width: 4,
                height: 4,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: accentColor,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Container(height: 0.5, width: 60, color: PdfColors.grey400),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              if (logo != null) ...[
                pw.Image(logo!, width: 18, height: 18),
                pw.SizedBox(width: 5),
              ],
              pw.Text(
                'BANJARA BIO MATRIMONY',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: AppTypography.labelTinyFixed,
                  color: accentColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            label('Download App Line'),
            style: pw.TextStyle(
              font: font,
              fontSize: AppTypography.labelTinyFixed,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'https://play.google.com/store/apps/details?id=com.avishio.banjarabio',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: AppTypography.labelTinyFixed,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
