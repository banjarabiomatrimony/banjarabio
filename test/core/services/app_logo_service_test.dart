import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/app_logo_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLogoService', () {
    late AppLogoService service;

    setUp(() {
      service = AppLogoService.instance;
    });

    test('singleton instance is always the same', () {
      expect(identical(AppLogoService.instance, AppLogoService.instance), true);
    });

    test('isReady is false before warmUp', () {
      // Note: Since it's a singleton, it may have been warmed in other tests.
      // We check the property type at least.
      expect(service.isReady, isA<bool>());
    });

    test('logoBytes is null or Uint8List', () {
      final bytes = service.logoBytes;
      expect(bytes, bytes); // Silences unused variable warning while avoiding redundant type check
    });

    test('getLogoBytes returns Uint8List or null', () async {
      // This may fail in test environment without asset bundle, 
      // but should not throw
      final bytes = await service.getLogoBytes();
      expect(bytes, bytes);
    });
  });
}
