import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:banjarabio/core/services/pdf/templates/biodata_template_base.dart';

class PremiumTemplate extends BiodataTemplateBase {
  PremiumTemplate({
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
    final gold = saffronGold;
    final navy = navyBlue;
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
        build: (context) => [
          pw.Column(
            children: [
              _buildPremiumHeader(goldGradient, navy, gold),
              pw.SizedBox(height: 30),
              _buildPremiumSection(
                label('personal_details'),
                content.personalDetails,
                goldGradient,
                navy,
              ),
              _buildPremiumSection(
                label('education_profession'),
                content.educationProfession,
                goldGradient,
                navy,
              ),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildPremiumSection(
                      label('family_details'),
                      content.familyDetails,
                      goldGradient,
                      navy,
                    ),
                  ),
                  pw.SizedBox(width: 30),
                  pw.Expanded(
                    child: _buildPremiumSection(
                      label('location_contact'),
                      content.locationContact,
                      goldGradient,
                      navy,
                    ),
                  ),
                ],
              ),
              if (content.partnerExpectations.isNotEmpty) ...[
                buildBevelledHeader(
                  label('partner_expectations'),
                  goldGradient,
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 15),
                  child: pw.Text(
                    content.partnerExpectations,
                    style: valueStyle().copyWith(lineSpacing: 1.5),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
              pw.SizedBox(height: 40),
              buildFooter(),
            ],
          ),
        ],
      ),
    );
    return pdf;
  }

  pw.Widget _buildPremiumHeader(
    pw.LinearGradient goldGradient,
    PdfColor navy,
    PdfColor gold,
  ) {
    return pw.Column(
      children: [
        pw.Center(child: buildRoyalGanesh(gold, size: 75, showHalo: true)),
        pw.SizedBox(height: 5),
        buildGaneshMantra(gold),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            '॥ श्री ॥',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 16,
              color: gold,
              letterSpacing: 5,
            ),
          ),
        ),
        pw.SizedBox(height: 25),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  label('biodata').toUpperCase(),
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 14,
                    color: gold,
                    letterSpacing: 6,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  content.personalDetails['Full Name'] ?? 'PROFILE',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 34,
                    color: navy,
                    letterSpacing: 1,
                  ),
                ),
                pw.Container(
                  height: 3,
                  width: 180,
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
            if (profilePhoto != null)
              pw.Container(
                width: 110,
                height: 140,
                padding: const pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  gradient: goldGradient,
                  boxShadow: [
                    const pw.BoxShadow(
                      blurRadius: 8,
                      offset: PdfPoint(3, 3),
                    ),
                  ],
                ),
                child: pw.Stack(
                  children: [
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        image: pw.DecorationImage(
                          image: profilePhoto!,
                        ),
                      ),
                    ),
                    // Jeweled markers at corners
                    pw.Positioned(
                      top: 1,
                      left: 1,
                      child: buildJeweledMarker(size: 4),
                    ),
                    pw.Positioned(
                      top: 1,
                      right: 1,
                      child: buildJeweledMarker(size: 4),
                    ),
                    pw.Positioned(
                      bottom: 1,
                      left: 1,
                      child: buildJeweledMarker(size: 4),
                    ),
                    pw.Positioned(
                      bottom: 1,
                      right: 1,
                      child: buildJeweledMarker(size: 4),
                    ),
                  ],
                ),
              )
            else
              pw.SizedBox(width: 110),
          ],
        ),
        pw.SizedBox(height: 25),
        buildOrnateDivider(gold),
      ],
    );
  }

  pw.Widget _buildPremiumSubHeader(
    String title,
    pw.LinearGradient goldGradient,
  ) {
    return pw.Column(
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
      ],
    );
  }

  pw.Widget _buildPremiumSection(
    String title,
    Map<String, String> data,
    pw.LinearGradient goldGradient,
    PdfColor navy,
  ) {
    if (data.isEmpty) return pw.SizedBox();

    return pw.Column(
      children: [
        _buildPremiumSubHeader(title, goldGradient),
        pw.SizedBox(height: 15),
        ...data.entries.where((e) => e.key != 'Full Name').map((e) {
          return pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.SizedBox(
                  width: 120,
                  child: pw.Text(
                    e.key,
                    style: labelStyle().copyWith(
                      color: PdfColors.grey800,
                      fontSize: 11,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                  child: pw.Text(
                    ':',
                    style: labelStyle().copyWith(color: saffronGold),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    e.value,
                    style: valueStyle().copyWith(
                      font: boldFont,
                      fontSize: 11,
                      color: navy,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
