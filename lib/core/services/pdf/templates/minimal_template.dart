import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:banjarabio/core/services/pdf/templates/biodata_template_base.dart';

class MinimalTemplate extends BiodataTemplateBase {
  MinimalTemplate({
    required super.content,
    required super.language,
    required super.font,
    required super.boldFont,
    required super.mantraFont,
  });

  @override
  Future<pw.Document> generate() async {
    final pdf = pw.Document();
    final navy = navyBlue;
    final goldGradient = buildGoldFoilGradient();
    final gold = saffronGold;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: isLandscape
              ? PdfPageFormat.a4.landscape
              : PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (context) => buildBackground(
            gold,
            luxuryTexture: true,
            goldenDust: true,
          ),
        ),
        header: (context) => _buildHeader(gold, navy, goldGradient),
        footer: (context) => buildFooter(),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              children: [
                _buildMinimalSection(
                  label('personal_details'),
                  content.personalDetails,
                  gold,
                  navy,
                  goldGradient,
                ),
                _buildMinimalSection(
                  label('education_profession'),
                  content.educationProfession,
                  gold,
                  navy,
                  goldGradient,
                ),
                _buildMinimalSection(
                  label('family_details'),
                  content.familyDetails,
                  gold,
                  navy,
                  goldGradient,
                ),
                _buildMinimalSection(
                  label('location_contact'),
                  content.locationContact,
                  gold,
                  navy,
                  goldGradient,
                ),
                if (content.partnerExpectations.isNotEmpty)
                  _buildExpectations(gold, navy, goldGradient),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _buildHeader(
    PdfColor gold,
    PdfColor navy,
    pw.LinearGradient goldGradient,
  ) {
    return pw.Column(
      children: [
        pw.Center(child: buildRoyalGanesh(gold, size: 65, showHalo: true)),
        pw.SizedBox(height: 5),
        buildGaneshMantra(gold),
        pw.SizedBox(height: 15),
        pw.Text(
          label('biodata').toUpperCase(),
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 22,
            letterSpacing: 10,
            color: navy,
          ),
        ),
        pw.Container(
          height: 2,
          width: 80,
          margin: const pw.EdgeInsets.symmetric(vertical: 12),
          decoration: pw.BoxDecoration(gradient: goldGradient),
        ),
      ],
    );
  }

  pw.Widget _buildMinimalSection(
    String title,
    Map<String, String> data,
    PdfColor primaryColor,
    PdfColor accentColor,
    pw.LinearGradient goldGradient,
  ) {
    if (data.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 25, bottom: 10),
          child: pw.Row(
            children: [
              buildJeweledMarker(),
              pw.SizedBox(width: 12),
              buildBevelledHeader(title.toUpperCase(), goldGradient),
              pw.Expanded(
                child: pw.Container(
                  height: 0.5,
                  margin: const pw.EdgeInsets.only(left: 10),
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [saffronGold, PdfColors.white],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 18),
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
                      e.key,
                      style: labelStyle().copyWith(
                        fontSize: 10.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text(
                      e.value,
                      style: valueStyle().copyWith(
                        fontSize: 10.5,
                        font: boldFont,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          height: 0.5,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [primaryColor, PdfColors.white],
              stops: [0.0, 0.8],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildExpectations(
    PdfColor primaryColor,
    PdfColor accentColor,
    pw.LinearGradient goldGradient,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 25, bottom: 10),
          child: pw.Row(
            children: [
              buildJeweledMarker(),
              pw.SizedBox(width: 12),
              buildBevelledHeader(
                label('partner_expectations').toUpperCase(),
                goldGradient,
              ),
              pw.Expanded(
                child: pw.Container(
                  height: 0.5,
                  margin: const pw.EdgeInsets.only(left: 10),
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [saffronGold, PdfColors.white],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 18),
          child: pw.Text(
            content.partnerExpectations,
            style: valueStyle().copyWith(fontSize: 11, lineSpacing: 1.5),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          height: 0.5,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            gradient: pw.LinearGradient(
              colors: [primaryColor, PdfColors.white],
              stops: [0.0, 0.8],
            ),
          ),
        ),
      ],
    );
  }
}
