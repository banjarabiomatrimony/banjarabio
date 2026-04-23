import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/config/storage_config.dart';

void main() {
  group('StorageConfig - constants', () {
    test('profilePhotos bucket name is correct', () {
      expect(StorageConfig.profilePhotos, 'profile-photos');
    });

    test('verificationDocs bucket name is correct', () {
      expect(StorageConfig.verificationDocs, 'verification-docs');
    });
  });
}
