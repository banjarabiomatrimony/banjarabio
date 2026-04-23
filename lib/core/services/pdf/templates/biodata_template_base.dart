import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:banjarabio/core/models/biodata_content.dart';
import 'package:banjarabio/core/services/pdf/biodata_translations.dart';

abstract class BiodataTemplateBase {
  final BiodataContent content;
  final String language;
  final pw.Font font;
  final pw.Font boldFont;
  final pw.Font mantraFont; // New font for Ganesh Mantra
  pw.MemoryImage? logo;
  pw.MemoryImage? profilePhoto;
  pw.MemoryImage? premiumBorder;
  pw.MemoryImage? premiumGanesh;
  bool isLocked;
  bool isLandscape;

  BiodataTemplateBase({
    required this.content,
    required this.language,
    required this.font,
    required this.boldFont,
    required this.mantraFont,
    this.logo,
    this.profilePhoto,
    this.premiumBorder,
    this.premiumGanesh,
    this.isLocked = true,
    this.isLandscape = false,
  });

  // Premium Marriage Palette
  final royalMaroon = const PdfColor.fromInt(0xFF800000);
  final saffronGold = const PdfColor.fromInt(0xFFD4AF37);
  final navyBlue = const PdfColor.fromInt(0xFF000080);
  final classicCream = const PdfColor.fromInt(0xFFFFFDD0);
  final deepSaffron = const PdfColor.fromInt(0xFFFF9933);

  Future<pw.Document> generate();

  // Helper to get translated label
  String label(String key) => BiodataTranslations.translate(key, language);

  // Common styles
  pw.TextStyle sectionTitleStyle(PdfColor primaryColor) =>
      pw.TextStyle(font: boldFont, fontSize: 14, color: primaryColor);

  pw.TextStyle labelStyle() =>
      pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.black);

  pw.TextStyle valueStyle() =>
      pw.TextStyle(font: font, fontSize: 10, color: PdfColors.black);

  // Ornate Border with layered lines
  pw.Widget buildOrnateBorder(PdfColor color, {bool luxury = false}) {
    if (luxury) {
      return pw.Stack(
        children: [
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: color, width: 3),
            ),
            margin: const pw.EdgeInsets.all(8),
            child: pw.Container(
              margin: const pw.EdgeInsets.all(2),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: color, width: 0.5),
              ),
            ),
          ),
          // Add inner decorative corners for luxury feel
          pw.Positioned(
            top: 15,
            left: 15,
            child: pw.Container(
              width: 40,
              height: 40,
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: color, width: 1.5),
                  left: pw.BorderSide(color: color, width: 1.5),
                ),
              ),
            ),
          ),
          pw.Positioned(
            top: 15,
            right: 15,
            child: pw.Container(
              width: 40,
              height: 40,
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: color, width: 1.5),
                  right: pw.BorderSide(color: color, width: 1.5),
                ),
              ),
            ),
          ),
          pw.Positioned(
            bottom: 15,
            left: 15,
            child: pw.Container(
              width: 40,
              height: 40,
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: color, width: 1.5),
                  left: pw.BorderSide(color: color, width: 1.5),
                ),
              ),
            ),
          ),
          pw.Positioned(
            bottom: 15,
            right: 15,
            child: pw.Container(
              width: 40,
              height: 40,
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: color, width: 1.5),
                  right: pw.BorderSide(color: color, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
      ),
      margin: const pw.EdgeInsets.all(8),
      padding: const pw.EdgeInsets.all(3),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 0.5),
        ),
      ),
    );
  }

  pw.LinearGradient buildGoldFoilGradient() {
    return const pw.LinearGradient(
      colors: [
        PdfColor.fromInt(0xFFBF953F), // Old Gold
        PdfColor.fromInt(0xFFFCF6BA), // Pale Gold
        PdfColor.fromInt(0xFFB38728), // Golden Brown
        PdfColor.fromInt(0xFFFBF5B7), // Light Gold
        PdfColor.fromInt(0xFFAA771C), // Deep Gold
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      begin: pw.Alignment.topLeft,
      end: pw.Alignment.bottomRight,
    );
  }

  pw.Widget buildJeweledMarker({double size = 8}) {
    return pw.Container(
      width: size,
      height: size,
      decoration: const pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        gradient: pw.RadialGradient(
          colors: [
            PdfColor.fromInt(0xFFFFFFFF), // Sparkle
            PdfColor.fromInt(0xFFFCF6BA), // Gold light
            PdfColor.fromInt(0xFFBF953F), // Deep gold
          ],
          stops: [0.1, 0.4, 1.0],
        ),
      ),
    );
  }

  pw.Widget buildBevelledHeader(String text, pw.LinearGradient goldGradient) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: pw.BoxDecoration(
        gradient: goldGradient,
        border: const pw.Border(
          top: pw.BorderSide(
            color: PdfColor.fromInt(0x80FFFFFF),
            width: 1.5,
          ), // 0x80 = 50% opacity
          bottom: pw.BorderSide(
            color: PdfColor.fromInt(0x4D000000),
            width: 1.5,
          ), // 0x4D = 30% opacity
        ),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: boldFont,
          fontSize: 14,
          color: PdfColors.black,
          letterSpacing: 2,
        ),
      ),
    );
  }

  pw.Widget buildGoldenDustBackground() {
    return pw.Stack(
      children: List.generate(15, (i) {
        final randX = (i * 70.5) % 600;
        final randY = (i * 123.2) % 800;
        final randSize = (i % 3) + 0.5;
        final randOpacity = (i % 5) * 0.02 + 0.05;

        return pw.Positioned(
          left: randX.toDouble(),
          top: randY.toDouble(),
          child: pw.Opacity(
            opacity: randOpacity,
            child: pw.Container(
              width: randSize,
              height: randSize,
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFFCF6BA),
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }

  pw.Widget buildFiligreePattern(PdfColor color) {
    return pw.Opacity(
      opacity: 0.03,
      child: pw.Stack(
        children: List.generate(6, (i) {
          return pw.Positioned(
            left: -50 + (i * 120.0),
            top: -50,
            child: pw.Transform.rotate(
              angle: 0.7,
              child: pw.Container(
                width: 2,
                height: 1500,
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    left: pw.BorderSide(color: color, width: 0.1),
                    right: pw.BorderSide(color: color, width: 0.1),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  pw.Widget buildPremiumTexture(PdfColor color, {double opacity = 0.02}) {
    return pw.Opacity(
      opacity: opacity,
      child: pw.Stack(
        children:
            List.generate(6, (i) {
              return pw.Positioned(
                left: (i * 100.0),
                top: 0,
                bottom: 0,
                child: pw.Container(width: 0.2, color: color),
              );
            }) +
            List.generate(9, (i) {
              return pw.Positioned(
                top: (i * 100.0),
                left: 0,
                right: 0,
                child: pw.Container(height: 0.2, color: color),
              );
            }),
      ),
    );
  }

  // Complex Mandala-style Motif
  pw.Widget buildMandalaMotif(PdfColor color, {double size = 100}) {
    return pw.Opacity(
      opacity: 0.1,
      child: pw.Stack(
        alignment: pw.Alignment.center,
        children: List.generate(6, (index) {
          return pw.Transform.rotate(
            angle: (index * 60) * 3.14159 / 180,
            child: pw.Container(
              width: size,
              height: size * 0.3,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: color, width: 0.2),
                borderRadius: pw.BorderRadius.all(
                  pw.Radius.circular(size * 0.15),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Om / Shree Spiritual Motif
  pw.Widget buildSpiritualMotif(PdfColor color, {double size = 40}) {
    return pw.Container(
      width: size,
      height: size,
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1.5),
        shape: pw.BoxShape.circle,
      ),
      child: pw.Center(
        child: pw.Text(
          '॥ श्री ॥',
          style: pw.TextStyle(
            font: boldFont,
            fontSize: size * 0.3,
            color: color,
          ),
        ),
      ),
    );
  }

  pw.Widget buildFlowerMotif(PdfColor color, {double size = 30}) {
    return pw.Stack(
      alignment: pw.Alignment.center,
      children: [
        pw.Container(
          width: size,
          height: size,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: color, width: 1.5),
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.Container(
          width: size * 0.7,
          height: size * 0.7,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: color),
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.Container(
          width: size * 0.2,
          height: size * 0.2,
          decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle),
        ),
      ],
    );
  }

  // Ganesh Motif (Hyper-Premium Royal version)
  pw.Widget buildRoyalGanesh(
    PdfColor color, {
    double size = 60,
    bool showHalo = false,
  }) {
    // Lightweight halo
    final aura = pw.Container(
      width: size * 1.5,
      height: size * 1.5,
      decoration: const pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        gradient: pw.RadialGradient(
          colors: [
            PdfColor.fromInt(0x33FCF6BA), // 20% alpha
            PdfColor.fromInt(0x00BF953F), // 0% alpha
          ],
        ),
      ),
    );

    pw.Widget mainWidget;
    if (premiumGanesh != null) {
      mainWidget = pw.Container(
        width: size,
        height: size,
        child: pw.Image(premiumGanesh!),
      );
    } else {
      // Stylized fallback
      mainWidget = pw.Container(
        width: size,
        height: size,
        child: pw.Stack(
          alignment: pw.Alignment.center,
          children: [
            pw.Container(
              width: size * 0.8,
              height: size * 0.9,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: color, width: 1.5),
                borderRadius: pw.BorderRadius.all(
                  pw.Radius.circular(size * 0.4),
                ),
              ),
            ),
            pw.Positioned(
              top: size * 0.2,
              child: pw.Container(
                width: size * 0.4,
                height: size * 0.4,
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  color: color,
                ),
              ),
            ),
            pw.Positioned(
              bottom: size * 0.1,
              child: pw.Container(width: size * 0.5, height: 2, color: color),
            ),
          ],
        ),
      );
    }

    if (showHalo) {
      return pw.Stack(
        alignment: pw.Alignment.center,
        children: [aura, mainWidget],
      );
    }
    return mainWidget;
  }

  // Universal Ganesh Mantra
  pw.Widget buildGaneshMantra(PdfColor color) {
    return pw.Center(
      child: pw.Text(
        '॥ श्री गणेशाय नमः ॥',
        style: pw.TextStyle(
          font: mantraFont,
          fontSize: 14,
          color: color,
          letterSpacing: 3,
        ),
      ),
    );
  }

  // Lotus Motif (Floral accent)
  pw.Widget buildLotusMotif(PdfColor color, {double size = 30}) {
    return pw.Stack(
      alignment: pw.Alignment.bottomCenter,
      children: [
        pw.Container(
          width: size,
          height: size * 0.5,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: color),
            borderRadius: pw.BorderRadius.vertical(
              top: pw.Radius.circular(size * 0.5),
            ),
          ),
        ),
        pw.Container(
          width: size * 0.3,
          height: size * 0.7,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: color),
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(size * 0.15)),
          ),
        ),
      ],
    );
  }

  // paisley / Kalki Motif
  pw.Widget buildPaisleyMotif(PdfColor color, {double size = 30}) {
    return pw.Transform.rotate(
      angle: 0.3,
      child: pw.Container(
        width: size,
        height: size * 1.2,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color),
          borderRadius: pw.BorderRadius.only(
            topLeft: pw.Radius.circular(size),
            bottomRight: pw.Radius.circular(size),
            topRight: pw.Radius.circular(size * 0.2),
          ),
        ),
      ),
    );
  }

  // Ornate Divider
  pw.Widget buildOrnateDivider(PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Container(width: 50, height: 1, color: color),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10),
            child: buildFlowerMotif(color, size: 12),
          ),
          pw.Container(width: 50, height: 1, color: color),
        ],
      ),
    );
  }

  pw.Widget buildCornerMotifs(PdfColor color) {
    return pw.Stack(
      children: [
        pw.Positioned(
          top: 20,
          left: 20,
          child: buildFlowerMotif(color, size: 25),
        ),
        pw.Positioned(
          top: 20,
          right: 20,
          child: buildFlowerMotif(color, size: 25),
        ),
        pw.Positioned(
          bottom: 20,
          left: 20,
          child: buildFlowerMotif(color, size: 25),
        ),
        pw.Positioned(
          bottom: 20,
          right: 20,
          child: buildFlowerMotif(color, size: 25),
        ),
      ],
    );
  }

  // Spanning-safe Background Builder
  pw.Widget buildBackground(
    PdfColor color, {
    bool showBorder = true,
    bool showCorners = true,
    bool showMandala = false,
    bool luxuryTexture = false,
    bool goldenDust = false,
  }) {
    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Stack(
        children: [
          if (luxuryTexture) buildPremiumTexture(color),
          if (goldenDust) buildGoldenDustBackground(),
          if (showMandala)
            pw.Positioned(
              right: -100,
              bottom: -100,
              child: pw.Opacity(
                opacity: 0.05,
                child: buildMandalaMotif(color, size: 400),
              ),
            ),
          if (showBorder)
            premiumBorder != null
                ? pw.Container(
                    decoration: pw.BoxDecoration(
                      image: pw.DecorationImage(
                        image: premiumBorder!,
                        fit: pw.BoxFit.fill,
                      ),
                    ),
                  )
                : buildOrnateBorder(color, luxury: luxuryTexture),
          if (showCorners && premiumBorder == null) buildCornerMotifs(color),
          if (isLocked) buildWatermark(),
        ],
      ),
    );
  }

  // Common UI helpers
  pw.Widget buildWatermark() {
    return pw.Opacity(
      opacity: 0.06,
      child: pw.Center(
        child: pw.Stack(
          alignment: pw.Alignment.center,
          children: [
            buildMandalaMotif(PdfColors.grey500, size: 500),
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                if (logo != null) ...[
                  pw.Image(logo!, width: 150),
                  pw.SizedBox(height: 20),
                ],
                pw.Text(
                  'PREMIUM BIODATA',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 40,
                    letterSpacing: 8,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Text(
                    'AUTHENTIC BY BANJARA BIO',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 12,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget buildFooter() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 40),
      alignment: pw.Alignment.center,
      child: pw.Column(
        children: [
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          pw.Text(
            'Created via Banjara Bio App',
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Download the app to find your life partner',
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: PdfColors.grey500,
            ),
          ),
          pw.Text(
            'https://banjarabio.com',
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: const PdfColor.fromInt(0xFF432C7A),
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget buildPageNumber(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey),
      ),
    );
  }
}
