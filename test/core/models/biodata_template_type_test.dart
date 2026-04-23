import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/biodata_template_type.dart';

void main() {
  group('BiodataTemplateType - displayName', () {
    test('modern returns "Modern"', () {
      expect(BiodataTemplateType.modern.displayName, 'Modern');
    });

    test('classic returns "Classic"', () {
      expect(BiodataTemplateType.classic.displayName, 'Classic');
    });

    test('minimal returns "Minimal"', () {
      expect(BiodataTemplateType.minimal.displayName, 'Minimal');
    });

    test('traditional returns "Traditional"', () {
      expect(BiodataTemplateType.traditional.displayName, 'Traditional');
    });

    test('premium returns "Premium"', () {
      expect(BiodataTemplateType.premium.displayName, 'Premium');
    });

    test('simple returns "Simple"', () {
      expect(BiodataTemplateType.simple.displayName, 'Simple');
    });
  });

  group('BiodataTemplateType - isPremium', () {
    test('all template types return isPremium = true', () {
      for (final type in BiodataTemplateType.values) {
        expect(type.isPremium, true, reason: '${type.name} should be premium');
      }
    });
  });

  group('BiodataTemplateType - enum values', () {
    test('has exactly 6 values', () {
      expect(BiodataTemplateType.values.length, 6);
    });

    test('contains all expected enum values', () {
      final names = BiodataTemplateType.values.map((e) => e.name).toSet();
      expect(names, containsAll(['modern', 'classic', 'minimal', 'traditional', 'premium', 'simple']));
    });
  });
}
