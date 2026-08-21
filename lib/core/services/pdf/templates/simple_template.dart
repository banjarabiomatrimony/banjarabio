import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:banjarabio/core/services/pdf/templates/biodata_template_base.dart';

class SimpleTemplate extends BiodataTemplateBase {
  SimpleTemplate({
    required super.content,
    required super.language,
    required super.font,
    required super.boldFont,
    required super.mantraFont,
  });

  @override
  Future<pw.Document> generate() async {
    final pdf = pw.Document();
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
        header: (context) => _buildHeader(gold, goldGradient),
        footer: (context) => buildFooter(),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 10, left: 10, right: 10),
            child: pw.Column(
              children: [
                _buildSection(
                  label('personal_details'),
                  content.personalDetails,
                  goldGradient,
                  gold,
                ),
                pw.SizedBox(height: 20),
                _buildSection(
                  label('education_profession'),
                  content.educationProfession,
                  goldGradient,
                  gold,
                ),
                pw.SizedBox(height: 20),
                _buildSection(
                  label('family_details'),
                  content.familyDetails,
                  goldGradient,
                  gold,
                ),
                pw.SizedBox(height: 20),
                _buildSection(
                  label('location_contact'),
                  content.locationContact,
                  goldGradient,
                  gold,
                ),
                if (content.partnerExpectations.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  _buildTextSection(
                    label('partner_expectations'),
                    content.partnerExpectations,
                    goldGradient,
                    gold,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    addFullPagePhotoPage(pdf, accentColor: gold);
    return pdf;
  }

  pw.Widget _buildHeader(PdfColor gold, pw.LinearGradient goldGradient) {
    return pw.Column(
      children: [
        pw.Center(child: buildRoyalGanesh(gold, size: 70, showHalo: true)),
        pw.SizedBox(height: 5),
        buildGaneshMantra(gold),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            buildJeweledMarker(size: 10),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 25),
              child: pw.Text(
                label('biodata').toUpperCase(),
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: AppTypography.displayMediumFixed,
                  color: royalMaroon,
                  letterSpacing: 8,
                ),
              ),
            ),
            buildJeweledMarker(size: 10),
          ],
        ),
        pw.Container(
          height: 2.5,
          width: 180,
          margin: const pw.EdgeInsets.only(top: 8),
          decoration: pw.BoxDecoration(
            gradient: goldGradient,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
        ),
        pw.SizedBox(height: 20),
        buildOrnateDivider(gold),
      ],
    );
  }

  pw.Widget _buildSection(
    String title,
    Map<String, String> data,
    pw.LinearGradient goldGradient,
    PdfColor gold,
  ) {
    if (data.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            buildJeweledMarker(),
            pw.SizedBox(width: 12),
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
        pw.SizedBox(height: 10),
        _buildTable(data, royalMaroon),
      ],
    );
  }

  pw.Widget _buildTextSection(
    String title,
    String text,
    pw.LinearGradient goldGradient,
    PdfColor gold,
  ) {
    if (text.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            buildJeweledMarker(),
            pw.SizedBox(width: 12),
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
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: gold, width: 0.3),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text(
            text,
            style: valueStyle().copyWith(
              lineSpacing: 1.5,
              fontSize: AppTypography.bodyExtraSmallFixed,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTable(Map<String, String> data, PdfColor labelColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 20),
      child: pw.Table(
        columnWidths: {
          0: const pw.FixedColumnWidth(130),
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
