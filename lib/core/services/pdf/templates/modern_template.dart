import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:banjarabio/core/services/pdf/templates/biodata_template_base.dart';

class ModernTemplate extends BiodataTemplateBase {
  ModernTemplate({
    required super.content,
    required super.language,
    required super.font,
    required super.boldFont,
    required super.mantraFont,
  });

  @override
  Future<pw.Document> generate() async {
    final pdf = pw.Document();
    final emeraldGreen = const PdfColor.fromInt(0xFF004D40); // Deeper Emerald
    final gold = saffronGold;
    final goldGradient = buildGoldFoilGradient();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: isLandscape
              ? PdfPageFormat.a4.landscape
              : PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (context) => buildBackground(
            gold,
            showMandala: true,
            luxuryTexture: true,
            goldenDust: true,
          ),
        ),
        header: (context) => _buildHeader(emeraldGreen, gold, goldGradient),
        footer: (context) => buildFooter(),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildPersonalDetails(emeraldGreen, goldGradient),
                pw.SizedBox(height: 20),
                _buildEducationProfession(emeraldGreen, goldGradient),
                pw.SizedBox(height: 20),
                _buildFamilyDetails(emeraldGreen, goldGradient),
                pw.SizedBox(height: 20),
                _buildLocationContact(emeraldGreen, goldGradient),
                if (content.partnerExpectations.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  _buildExpectations(emeraldGreen, goldGradient),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    addFullPagePhotoPage(pdf, accentColor: emeraldGreen);
    return pdf;
  }

  pw.Widget _buildHeader(
    PdfColor primaryColor,
    PdfColor gold,
    pw.LinearGradient goldGradient,
  ) {
    return pw.Column(
      children: [
        pw.Center(child: buildRoyalGanesh(gold, size: 75, showHalo: true)),
        pw.SizedBox(height: 5),
        buildGaneshMantra(gold),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            buildJeweledMarker(size: 12),
            pw.SizedBox(width: 25),
            pw.Column(
              children: [
                pw.Text(
                  label('biodata').toUpperCase(),
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 28,
                    color: primaryColor,
                    letterSpacing: 4,
                  ),
                ),
                pw.Container(
                  height: 3,
                  width: 150,
                  margin: const pw.EdgeInsets.only(top: 5),
                  decoration: pw.BoxDecoration(
                    gradient: goldGradient,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(width: 25),
            buildJeweledMarker(size: 12),
          ],
        ),
        pw.SizedBox(height: 15),
        buildOrnateDivider(gold),
      ],
    );
  }

  pw.Widget _buildSectionHeader(
    String title,
    PdfColor primaryColor,
    pw.LinearGradient goldGradient,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        children: [
          buildJeweledMarker(size: 10),
          pw.SizedBox(width: 10),
          buildBevelledHeader(title.toUpperCase(), goldGradient),
          pw.Expanded(
            child: pw.Container(
              height: 1,
              margin: const pw.EdgeInsets.only(left: 10),
              decoration: pw.BoxDecoration(gradient: goldGradient),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPersonalDetails(
    PdfColor primaryColor,
    pw.LinearGradient goldGradient,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          label('personal_details'),
          primaryColor,
          goldGradient,
        ),
        _buildTable(content.personalDetails, primaryColor),
      ],
    );
  }

  pw.Widget _buildEducationProfession(
    PdfColor primaryColor,
    pw.LinearGradient goldGradient,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          label('education_profession'),
          primaryColor,
          goldGradient,
        ),
        _buildTable(content.educationProfession, primaryColor),
      ],
    );
  }

  pw.Widget _buildFamilyDetails(
    PdfColor primaryColor,
    pw.LinearGradient goldGradient,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          label('family_details'),
          primaryColor,
          goldGradient,
        ),
        _buildTable(content.familyDetails, primaryColor),
      ],
    );
  }

  pw.Widget _buildLocationContact(
    PdfColor primaryColor,
    pw.LinearGradient goldGradient,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          label('location_contact'),
          primaryColor,
          goldGradient,
        ),
        _buildTable(content.locationContact, primaryColor),
      ],
    );
  }

  pw.Widget _buildExpectations(
    PdfColor primaryColor,
    pw.LinearGradient goldGradient,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          label('partner_expectations'),
          primaryColor,
          goldGradient,
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: primaryColor, width: 0.5),
          ),
          child: pw.Text(
            content.partnerExpectations,
            style: valueStyle().copyWith(lineSpacing: 1.5),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTable(Map<String, String> data, PdfColor labelColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12),
      child: pw.Table(
        columnWidths: {
          0: const pw.FixedColumnWidth(120),
          1: const pw.FlexColumnWidth(),
        },
        children: data.entries.map((e) {
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text(
                  '${e.key} :',
                  style: labelStyle().copyWith(color: labelColor),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text(e.value, style: valueStyle()),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
