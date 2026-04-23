import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:banjarabio/core/services/pdf/templates/biodata_template_base.dart';

class ClassicTemplate extends BiodataTemplateBase {
  ClassicTemplate({
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
        header: (context) => _buildClassicHeader(gold, goldGradient),
        footer: (context) => buildFooter(),
        build: (context) => [
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              children: [
                pw.SizedBox(height: 10),
                _buildClassicSection(
                  label('personal_details'),
                  content.personalDetails,
                  gold,
                  goldGradient,
                ),
                _buildClassicSection(
                  label('education_profession'),
                  content.educationProfession,
                  gold,
                  goldGradient,
                ),
                _buildClassicSection(
                  label('family_details'),
                  content.familyDetails,
                  gold,
                  goldGradient,
                ),
                _buildClassicSection(
                  label('location_contact'),
                  content.locationContact,
                  gold,
                  goldGradient,
                ),
                if (content.partnerExpectations.isNotEmpty)
                  _buildTextSection(
                    label('partner_expectations'),
                    content.partnerExpectations,
                    gold,
                    goldGradient,
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _buildClassicHeader(
    PdfColor color,
    pw.LinearGradient goldGradient,
  ) {
    return pw.Column(
      children: [
        pw.Center(child: buildRoyalGanesh(color, size: 75, showHalo: true)),
        pw.SizedBox(height: 5),
        buildGaneshMantra(color),
        pw.SizedBox(height: 25),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 45, vertical: 12),
          decoration: pw.BoxDecoration(
            gradient: goldGradient,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
            boxShadow: [
              const pw.BoxShadow(
                offset: PdfPoint(1, 1),
                blurRadius: 1,
              ),
            ],
          ),
          child: pw.Text(
            label('biodata').toUpperCase(),
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 34,
              color: PdfColors.black,
              letterSpacing: 10,
            ),
          ),
        ),
        pw.SizedBox(height: 20),
        buildOrnateDivider(color),
      ],
    );
  }

  pw.Widget _buildClassicSection(
    String title,
    Map<String, String> data,
    PdfColor color,
    pw.LinearGradient goldGradient,
  ) {
    if (data.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 30),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            buildJeweledMarker(),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20),
              child: buildBevelledHeader(title.toUpperCase(), goldGradient),
            ),
            buildJeweledMarker(),
          ],
        ),
        pw.SizedBox(height: 15),
        _buildTable(data, color),
      ],
    );
  }

  pw.Widget _buildTextSection(
    String title,
    String text,
    PdfColor color,
    pw.LinearGradient goldGradient,
  ) {
    if (text.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 25),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Container(
              height: 1,
              width: 60,
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(colors: [PdfColors.white, color]),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 15),
              child: pw.Text(
                title.toUpperCase(),
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 14,
                  color: color,
                  letterSpacing: 3,
                ),
              ),
            ),
            pw.Container(
              height: 1,
              width: 60,
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(colors: [color, PdfColors.white]),
              ),
            ),
          ],
        ),
        pw.Center(
          child: pw.Container(
            margin: const pw.EdgeInsets.only(top: 5, bottom: 15),
            height: 2.5,
            width: 100,
            decoration: pw.BoxDecoration(
              gradient: goldGradient,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
            ),
          ),
        ),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: color, width: 0.5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
          ),
          child: pw.Text(
            text,
            style: valueStyle().copyWith(lineSpacing: 1.5),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTable(Map<String, String> data, PdfColor labelColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10),
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
