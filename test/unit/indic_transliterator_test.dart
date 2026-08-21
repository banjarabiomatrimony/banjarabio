import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/pdf/indic_transliterator.dart';
import 'package:banjarabio/core/services/pdf/biodata_translations.dart';

void main() {
  group('IndicTransliterator Tests', () {
    test('transliterates Banti Rathod accurately across scripts', () {
      expect(
        IndicTransliterator.transliterate('Banti Rathod', 'Marathi'),
        equals('बंटी राठोड'),
      );
      expect(
        IndicTransliterator.transliterate('Banti Rathod', 'Hindi'),
        equals('बंटी राठौड़'),
      );
      expect(
        IndicTransliterator.transliterate('Banti Rathod', 'Telugu'),
        equals('బంటీ రాథోడ్'),
      );
      expect(
        IndicTransliterator.transliterate('Banti Rathod', 'Kannada'),
        equals('ಬಂಟಿ ರಾಥೋಡ್'),
      );
    });

    test('transliterates family names and locations', () {
      expect(
        BiodataTranslations.translate('Ramesh Rathod', 'Marathi'),
        equals('रमेश राठोड'),
      );
      expect(
        BiodataTranslations.translate('Kavita Rathod', 'Marathi'),
        equals('कविता राठोड'),
      );
      expect(
        BiodataTranslations.translate('Pune, Maharashtra', 'Marathi'),
        equals('पुणे, महाराष्ट्र'),
      );
      expect(
        BiodataTranslations.translate('Never Married', 'Marathi'),
        equals('अविवाहित'),
      );
    });

    test('translates partner expectations and about me long text', () {
      expect(
        BiodataTranslations.translate('Looking for educated partner from good family in Pune', 'Marathi'),
        contains('सुशिक्षित'),
      );
      expect(
        BiodataTranslations.translate('Simple, caring, vegetarian', 'Marathi'),
        contains('शाकाहारी'),
      );
      expect(
        BiodataTranslations.translate('Looking for educated partner in Hyderabad', 'Telugu'),
        contains('సుశిక్షితులు'),
      );
    });
  });
}
