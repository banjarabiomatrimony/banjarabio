import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:banjarabio/core/models/biodata_content.dart';
import 'package:banjarabio/core/models/biodata_template_type.dart';
import 'package:banjarabio/core/constants/biodata_templates.dart';
import 'package:banjarabio/core/services/pdf/templates/biodata_template_base.dart';
import 'package:banjarabio/core/services/pdf/templates/marriage_template.dart';

class BiodataTemplateFactory {
  static BiodataTemplateBase createTemplate({
    required BiodataTemplateType type,
    required BiodataContent content,
    required String language,
    required pw.Font font,
    required pw.Font boldFont,
    required pw.Font mantraFont,
    pw.MemoryImage? templateImage,
    pw.MemoryImage? logo,
    pw.MemoryImage? profilePhoto,
    bool isLocked = true,
  }) {
    // Get accent color from central constants
    final templateConfig = kBiodataTemplates.firstWhere(
      (t) => t.type == type,
      orElse: () => kBiodataTemplates.first,
    );
    
    final accentColor = PdfColor.fromInt(templateConfig.accentColor.toARGB32());

    return MarriageTemplate(
      content: content,
      language: language,
      font: font,
      boldFont: boldFont,
      mantraFont: mantraFont,
      accentColor: accentColor,
      templateImage: templateImage,
      logo: logo,
      profilePhoto: profilePhoto,
      isLocked: isLocked,
      marginLeft: templateConfig.marginLeft,
      marginTop: templateConfig.marginTop,
      marginRight: templateConfig.marginRight,
      marginBottom: templateConfig.marginBottom,
    );
  }
}
