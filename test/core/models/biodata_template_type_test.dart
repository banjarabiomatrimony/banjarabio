import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/biodata_template_type.dart';

void main() {
  group('BiodataTemplateType - displayName', () {
    test('royalGold returns "Royal Gold"', () {
      expect(BiodataTemplateType.royalGold.displayName, 'Royal Gold');
    });

    test('sacredMaroon returns "Sacred Maroon"', () {
      expect(BiodataTemplateType.sacredMaroon.displayName, 'Sacred Maroon');
    });

    test('lotusGreen returns "Lotus Green"', () {
      expect(BiodataTemplateType.lotusGreen.displayName, 'Lotus Green');
    });

    test('peacockBlue returns "Peacock Blue"', () {
      expect(BiodataTemplateType.peacockBlue.displayName, 'Peacock Blue');
    });

    test('mandalaRose returns "Mandala Rose"', () {
      expect(BiodataTemplateType.mandalaRose.displayName, 'Mandala Rose');
    });

    test('saffronDiya returns "Saffron Diya"', () {
      expect(BiodataTemplateType.saffronDiya.displayName, 'Saffron Diya');
    });

    test('paisleyPurple returns "Paisley Purple"', () {
      expect(BiodataTemplateType.paisleyPurple.displayName, 'Paisley Purple');
    });

    test('divineTeal returns "Divine Teal"', () {
      expect(BiodataTemplateType.divineTeal.displayName, 'Divine Teal');
    });

    test('burgundyLattice returns "Burgundy Lattice"', () {
      expect(BiodataTemplateType.burgundyLattice.displayName, 'Burgundy Lattice');
    });

    test('ivoryClassic returns "Ivory Classic"', () {
      expect(BiodataTemplateType.ivoryClassic.displayName, 'Ivory Classic');
    });
  });

  group('BiodataTemplateType - isPremium', () {
    test('all template types return isPremium = false (growth campaign bypass)', () {
      for (final type in BiodataTemplateType.values) {
        expect(type.isPremium, false, reason: '${type.name} should be free during growth campaign');
      }
    });
  });

  group('BiodataTemplateType - enum values', () {
    test('has exactly 10 values', () {
      expect(BiodataTemplateType.values.length, 10);
    });

    test('contains all expected enum values', () {
      final names = BiodataTemplateType.values.map((e) => e.name).toSet();
      expect(names, containsAll([
        'royalGold', 'sacredMaroon', 'lotusGreen', 'peacockBlue',
        'mandalaRose', 'saffronDiya', 'paisleyPurple', 'divineTeal',
        'burgundyLattice', 'ivoryClassic',
      ]));
    });
  });
}
