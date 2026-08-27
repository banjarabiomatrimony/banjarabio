import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/app_version.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_info.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_type.dart';

void main() {
  group('AppVersion SemVer Parsing & Comparison', () {
    test('parses standard major.minor.patch versions correctly', () {
      final v = AppVersion.parse('1.3.3');
      expect(v.major, equals(1));
      expect(v.minor, equals(3));
      expect(v.patch, equals(3));
      expect(v.buildNumber, equals(0));
    });

    test('parses version with build number correctly', () {
      final v = AppVersion.parse('1.3.3+41');
      expect(v.major, equals(1));
      expect(v.minor, equals(3));
      expect(v.patch, equals(3));
      expect(v.buildNumber, equals(41));
    });

    test('handles single digit and two digit versions gracefully', () {
      final v1 = AppVersion.parse('2');
      expect(v1.major, equals(2));
      expect(v1.minor, equals(0));

      final v2 = AppVersion.parse('1.4');
      expect(v2.major, equals(1));
      expect(v2.minor, equals(4));
    });

    test('handles empty and malformed strings safely without throwing', () {
      final vEmpty = AppVersion.parse('');
      expect(vEmpty.major, equals(0));

      final vInvalid = AppVersion.parse('invalid_string');
      expect(vInvalid.major, equals(0));
    });

    test('correctly evaluates version comparisons (<, <=, >, >=, ==)', () {
      final v100 = AppVersion.parse('1.0.0');
      final v120 = AppVersion.parse('1.2.0');
      final v133 = AppVersion.parse('1.3.3');
      final v133b41 = AppVersion.parse('1.3.3+41');
      final v133b42 = AppVersion.parse('1.3.3+42');
      final v200 = AppVersion.parse('2.0.0');

      expect(v100 < v120, isTrue);
      expect(v120 < v133, isTrue);
      expect(v133 < v133b41, isTrue);
      expect(v133b41 < v133b42, isTrue);
      expect(v133b42 < v200, isTrue);

      expect(v200 > v133b42, isTrue);
      expect(v100 <= AppVersion.parse('1.0.0'), isTrue);
      expect(v100 == AppVersion.parse('1.0.0'), isTrue);
    });
  });

  group('UpdateInfo Evaluation Logic', () {
    test('returns UpdateType.none when current version is >= latest', () {
      final info = UpdateInfo.evaluate(
        currentVersion: AppVersion.parse('1.3.3+41'),
        latestVersion: AppVersion.parse('1.3.3+41'),
        minRequiredVersion: AppVersion.parse('1.0.0'),
        storeUrl: 'https://example.com',
      );

      expect(info.updateType, equals(UpdateType.none));
      expect(info.hasUpdate, isFalse);
      expect(info.isForceUpdate, isFalse);
    });

    test('returns UpdateType.softNudge when current version is less than latest but >= minRequired', () {
      final info = UpdateInfo.evaluate(
        currentVersion: AppVersion.parse('1.3.0'),
        latestVersion: AppVersion.parse('1.3.3'),
        minRequiredVersion: AppVersion.parse('1.2.0'),
        storeUrl: 'https://example.com',
      );

      expect(info.updateType, equals(UpdateType.softNudge));
      expect(info.hasUpdate, isTrue);
      expect(info.isForceUpdate, isFalse);
      expect(info.isSoftUpdate, isTrue);
    });

    test('returns UpdateType.forceGate when current version is below minRequiredVersion', () {
      final info = UpdateInfo.evaluate(
        currentVersion: AppVersion.parse('1.1.0'),
        latestVersion: AppVersion.parse('1.3.3'),
        minRequiredVersion: AppVersion.parse('1.3.0'),
        storeUrl: 'https://example.com',
      );

      expect(info.updateType, equals(UpdateType.forceGate));
      expect(info.hasUpdate, isTrue);
      expect(info.isForceUpdate, isTrue);
    });

    test('returns UpdateType.forceGate when forceFlagFromServer is true', () {
      final info = UpdateInfo.evaluate(
        currentVersion: AppVersion.parse('1.3.2'),
        latestVersion: AppVersion.parse('1.3.3'),
        minRequiredVersion: AppVersion.parse('1.0.0'),
        forceFlagFromServer: true,
        storeUrl: 'https://example.com',
      );

      expect(info.updateType, equals(UpdateType.forceGate));
      expect(info.isForceUpdate, isTrue);
    });
  });
}
