import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/constants/biodata_templates.dart';
import 'package:banjarabio/core/models/biodata_template_type.dart';

void main() {
  group('BiodataTemplates Constants Tests', () {
    test('kBiodataTemplates is non-empty and contains valid template configurations', () {
      expect(kBiodataTemplates, isNotEmpty);
      expect(kBiodataTemplates.length, greaterThanOrEqualTo(5));

      final firstTemplate = kBiodataTemplates.first;
      expect(firstTemplate.type, equals(BiodataTemplateType.royalGold));
      expect(firstTemplate.name, equals('Royal Gold'));
      expect(firstTemplate.assetPath, isNotEmpty);
      expect(firstTemplate.marginLeft, greaterThan(0));
      expect(firstTemplate.marginTop, greaterThan(0));
    });

    test('all templates have distinct names and valid asset paths', () {
      final names = kBiodataTemplates.map((t) => t.name).toSet();
      expect(names.length, equals(kBiodataTemplates.length));

      for (final template in kBiodataTemplates) {
        expect(template.assetPath, startsWith('assets/images/biodata_templates/'));
      }
    });
  });
}
