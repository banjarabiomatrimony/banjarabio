import 'package:flutter/material.dart';
import 'package:banjarabio/core/models/biodata_template_type.dart';

class BiodataTemplate {
  final BiodataTemplateType type;
  final String name;
  final String assetPath;
  final Color accentColor;

  /// Safe area insets (in PDF points) that keep content inside the
  /// template's decorative border. Each template image is 1024×1024px
  /// but rendered on A4 (595×842pt) via BoxFit.fill, so vertical borders
  /// are ~1.41× larger than horizontal. Margins must account for this
  /// non-uniform stretch.
  final double marginLeft;
  final double marginTop;
  final double marginRight;
  final double marginBottom;

  const BiodataTemplate({
    required this.type,
    required this.name,
    required this.assetPath,
    required this.accentColor,
    this.marginLeft = 0,
    this.marginTop = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
  });
}

/// Margin calibration math:
/// Template images are 1024×1024px, rendered on A4 (595×842pt) via BoxFit.fill.
/// Horizontal scale = 595/1024 = 0.581
/// Vertical scale   = 842/1024 = 0.822
///
/// For a border element at N pixels from the image edge:
///   leftMargin  = N × 0.581
///   topMargin   = N × 0.822
///
/// All values below include safety padding of ~5pt beyond the inner border edge.
const List<BiodataTemplate> kBiodataTemplates = [
  // 1 – Royal Gold: ~35px shadow + 20px border + 45px corner motifs = ~100px
  // Om motif at top extends to ~65px from top edge
  // H: 100×0.581 = 58pt, V: 100×0.822 = 82pt, top: 82pt
  BiodataTemplate(
    type: BiodataTemplateType.royalGold,
    name: 'Royal Gold',
    assetPath: 'assets/images/biodata_templates/template_1.png',
    accentColor: Color(0xFFB8860B),
    marginLeft: 60,
    marginTop: 85,
    marginRight: 60,
    marginBottom: 80,
  ),
  // 2 – Sacred Maroon: ~30px shadow + 30px border + 50px paisley = ~110px
  // Ganesh motif at top extends to ~85px from top
  // H: 110×0.581 = 64pt, V: 110×0.822 = 90pt, top with Ganesh: 95pt
  BiodataTemplate(
    type: BiodataTemplateType.sacredMaroon,
    name: 'Sacred Maroon',
    assetPath: 'assets/images/biodata_templates/template_2.png',
    accentColor: Color(0xFF8B1A1A),
    marginLeft: 65,
    marginTop: 100,
    marginRight: 65,
    marginBottom: 85,
  ),
  // 3 – Lotus Green: ~30px shadow + 25px border + 40px lotus = ~95px
  // Leaf arch motif at top extends to ~80px from top
  // H: 95×0.581 = 55pt, V: 95×0.822 = 78pt
  BiodataTemplate(
    type: BiodataTemplateType.lotusGreen,
    name: 'Lotus Green',
    assetPath: 'assets/images/biodata_templates/template_3.png',
    accentColor: Color(0xFF2E7D32),
    marginLeft: 58,
    marginTop: 90,
    marginRight: 58,
    marginBottom: 78,
  ),
  // 4 – Peacock Blue: ~30px shadow + 35px border + 55px feather = ~120px
  // Shree symbol at top extends to ~70px from top
  // H: 120×0.581 = 70pt, V: 120×0.822 = 99pt
  BiodataTemplate(
    type: BiodataTemplateType.peacockBlue,
    name: 'Peacock Blue',
    assetPath: 'assets/images/biodata_templates/template_4.png',
    accentColor: Color(0xFF1A237E),
    marginLeft: 70,
    marginTop: 100,
    marginRight: 70,
    marginBottom: 90,
  ),
  // 5 – Mandala Rose: ~20px padding + 15px border + 60px mandala corner = ~95px
  // Diya at top extends to ~55px from top
  // H: 95×0.581 = 55pt, V: 95×0.822 = 78pt
  BiodataTemplate(
    type: BiodataTemplateType.mandalaRose,
    name: 'Mandala Rose',
    assetPath: 'assets/images/biodata_templates/template_5.png',
    accentColor: Color(0xFFAD1457),
    marginLeft: 58,
    marginTop: 85,
    marginRight: 58,
    marginBottom: 80,
  ),
  // 6 – Saffron Diya: ~25px shadow + 35px border + 30px pattern = ~90px
  // Marigold garland at top extends to ~100px, diya at bottom to ~95px
  // H: 90×0.581 = 52pt, V-top: 100×0.822 = 82pt, V-bot: 95×0.822 = 78pt
  BiodataTemplate(
    type: BiodataTemplateType.saffronDiya,
    name: 'Saffron Diya',
    assetPath: 'assets/images/biodata_templates/template_6.png',
    accentColor: Color(0xFFE65100),
    marginLeft: 58,
    marginTop: 95,
    marginRight: 58,
    marginBottom: 90,
  ),
  // 7 – Paisley Purple: ~30px shadow + 30px border + 50px paisley = ~110px
  // Swastik at top extends to ~80px from top
  // H: 110×0.581 = 64pt, V: 110×0.822 = 90pt
  BiodataTemplate(
    type: BiodataTemplateType.paisleyPurple,
    name: 'Paisley Purple',
    assetPath: 'assets/images/biodata_templates/template_7.png',
    accentColor: Color(0xFF6A1B9A),
    marginLeft: 65,
    marginTop: 95,
    marginRight: 65,
    marginBottom: 85,
  ),
  // 8 – Divine Teal: ~25px shadow + 40px border + 210px scalloped arch+bells = ~275px from top
  // Side borders: ~25px shadow + 50px geometric = ~75px
  // H: 75×0.581 = 44pt, V-top: 275×0.822 = 226pt → clamp at 130pt to be usable
  // Bottom: ~65px → 65×0.822 = 53pt
  BiodataTemplate(
    type: BiodataTemplateType.divineTeal,
    name: 'Divine Teal',
    assetPath: 'assets/images/biodata_templates/template_8.png',
    accentColor: Color(0xFF00695C),
    marginLeft: 58,
    marginTop: 135,
    marginRight: 58,
    marginBottom: 65,
  ),
  // 9 – Burgundy Lattice: has background extending to edges
  // Border ~55px from edge, lotus top ~90px
  // H: 55×0.581 = 32pt (+safety), V: 90×0.822 = 74pt
  // But has thick lattice — inner edge at ~75px
  // H: 75×0.581 = 44pt, V: 90×0.822 = 74pt
  BiodataTemplate(
    type: BiodataTemplateType.burgundyLattice,
    name: 'Burgundy Lattice',
    assetPath: 'assets/images/biodata_templates/template_9.png',
    accentColor: Color(0xFF880E4F),
    marginLeft: 55,
    marginTop: 85,
    marginRight: 55,
    marginBottom: 70,
  ),
  // 10 – Ivory Classic: ~35px shadow + thin 10px double-line = ~45px
  // Om at top extends to ~50px from top, lotus buds at corners ~55px
  // H: 55×0.581 = 32pt, V: 55×0.822 = 45pt
  // Very thin border — most generous content area
  BiodataTemplate(
    type: BiodataTemplateType.ivoryClassic,
    name: 'Ivory Classic',
    assetPath: 'assets/images/biodata_templates/template_10.png',
    accentColor: Color(0xFFB8860B),
    marginLeft: 48,
    marginTop: 60,
    marginRight: 48,
    marginBottom: 55,
  ),
];
