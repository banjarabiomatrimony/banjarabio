import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/constants/app_version.dart';

void main() {
  group('AppVersion Constants Tests', () {
    test('kAppVersion is formatted as semantic version with build number', () {
      expect(kAppVersion, isNotEmpty);
      expect(kAppVersion, contains('+'));
      expect(kAppVersion, matches(r'^\d+\.\d+\.\d+\+\d+$'));
    });
  });
}
