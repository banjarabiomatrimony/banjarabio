import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/pdf_service.dart';
import 'package:banjarabio/core/models/profile_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // No mock required anymore as PdfAssetsService is test-aware
    // and PdfService handles font fallbacks.
  });

  test('PdfService.generateBiodataPdf generates PDF without crashing', () async {
    final profile = ProfileModel(
      id: 'test_id',
      userId: 'user_id',
      fullName: 'Test User',
      surname: 'Surname',
      age: 25,
      gender: 'Male',
      height: "5'10\"",
      education: 'Graduate',
      profession: 'Software Engineer',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await PdfService.generateBiodataPdf(profile);
    expect(result, isA<Uint8List>());
    expect(result.isNotEmpty, true);
  });
}
