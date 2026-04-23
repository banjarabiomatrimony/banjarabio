import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:banjarabio/core/services/pdf/templates/biodata_template_base.dart';

class TraditionalTemplate extends BiodataTemplateBase {
  TraditionalTemplate({
    required super.content,
    required super.language,
    required super.font,
    required super.boldFont,
    required super.mantraFont,
    super.logo,
    super.profilePhoto,
    super.isLocked,
  });

  @override
  Future<pw.Document> generate() async {
    final pdf = pw.Document();
    final color = royalMaroon;
    final accent = saffronGold;
    final goldGradiant = buildGoldFoilGradient();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: isLandscape
              ? PdfPageFormat.a4.landscape
              : PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (context) => buildBackground(
            accent,
            showMandala: true,
            luxuryTexture: true,
            goldenDust: true,
          ),
        ),
        header: (context) => _buildHeritageHeader(color, goldGradiant),
        footer: (context) => buildFooter(),
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 10),
              _buildTraditionalSection(
                label('personal_details'),
                content.personalDetails,
                color,
                goldGradiant,
              ),
              _buildTraditionalSection(
                label('education_profession'),
                content.educationProfession,
                color,
                goldGradiant,
              ),
              _buildTraditionalSection(
                label('family_details'),
                content.familyDetails,
                color,
                goldGradiant,
              ),
              _buildTraditionalSection(
                label('location_contact'),
                content.locationContact,
                color,
                goldGradiant,
              ),
              if (content.partnerExpectations.isNotEmpty) ...[
                buildBevelledHeader(
                  label('partner_expectations'),
                  goldGradiant,
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0x0D000000), // Very light shadow
                    border: pw.Border.all(color: color, width: 0.5),
                  ),
                  child: pw.Text(
                    content.partnerExpectations,
                    style: valueStyle().copyWith(lineSpacing: 2),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
    return pdf;
  }

  pw.Widget _buildHeritageHeader(
    PdfColor color,
    pw.LinearGradient goldGradiant,
  ) {
    return pw.Column(
      children: [
        pw.Center(child: buildRoyalGanesh(color, size: 75, showHalo: true)),
        pw.SizedBox(height: 5),
        buildGaneshMantra(color),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            if (logo != null) pw.Image(logo!, width: 75),
            pw.Column(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    gradient: goldGradiant,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(2),
                    ),
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
                      fontSize: 26,
                      color: PdfColors.black,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Container(height: 1, width: 70, color: color),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                      child: buildJeweledMarker(),
                    ),
                    pw.Container(height: 1, width: 70, color: color),
                  ],
                ),
              ],
            ),
            if (profilePhoto != null)
              pw.Container(
                width: 100,
                height: 130,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  gradient: goldGradiant,
                  boxShadow: [
                    const pw.BoxShadow(
                      blurRadius: 5,
                      offset: PdfPoint(2, 2),
                    ),
                  ],
                ),
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: color),
                  ),
                  child: pw.Image(profilePhoto!, fit: pw.BoxFit.cover),
                ),
              )
            else
              pw.SizedBox(width: 100),
          ],
        ),
        pw.SizedBox(height: 15),
        buildOrnateDivider(color),
      ],
    );
  }

  pw.Widget _buildSectionHeader(
    String title,
    PdfColor color,
    pw.LinearGradient gold,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 25, bottom: 12),
      child: pw.Row(
        children: [
          buildBevelledHeader(title, gold),
          pw.Expanded(
            child: pw.Container(
              height: 1,
              decoration: pw.BoxDecoration(gradient: gold),
              margin: const pw.EdgeInsets.only(left: 10),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 10),
            child: buildJeweledMarker(size: 6),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTraditionalSection(
    String title,
    Map<String, String> data,
    PdfColor color,
    pw.LinearGradient gold,
  ) {
    if (data.isEmpty) return pw.SizedBox();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title, color, gold),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 15),
          child: pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(140),
              1: const pw.FlexColumnWidth(),
            },
            children: data.entries.map((e) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 6),
                    child: pw.Text(
                      '${e.key} :',
                      style: labelStyle().copyWith(color: color, fontSize: 11),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 6),
                    child: pw.Text(
                      e.value,
                      style: valueStyle().copyWith(fontSize: 11),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }
}
