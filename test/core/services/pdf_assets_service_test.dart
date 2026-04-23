import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/pdf_assets_service.dart';

void main() {
  group('PdfAssets', () {
    test('default constructor has null fields', () {
      const assets = PdfAssets();
      expect(assets.logoBytes, isNull);
      expect(assets.profilePhotoBytes, isNull);
    });

    test('constructor accepts Uint8List values', () {
      final logo = List<int>.generate(10, (i) => i);
      final photo = List<int>.generate(20, (i) => i + 10);
      final assets = PdfAssets(
        logoBytes: Uint8List.fromList(logo),
        profilePhotoBytes: Uint8List.fromList(photo),
      );
      expect(assets.logoBytes, isNotNull);
      expect(assets.logoBytes!.length, 10);
      expect(assets.profilePhotoBytes, isNotNull);
      expect(assets.profilePhotoBytes!.length, 20);
    });
  });

  group('PdfAssetsService', () {
    test('instance is a singleton', () {
      final a = PdfAssetsService.instance;
      final b = PdfAssetsService.instance;
      expect(identical(a, b), true);
    });

    test('getProfilePhotoBytes returns null for null profile', () async {
      final bytes = await PdfAssetsService.instance.getProfilePhotoBytes(null);
      expect(bytes, isNull);
    });
  });
}
