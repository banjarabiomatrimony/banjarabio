import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/config/share_config.dart';

void main() {
  group('ShareConfig - statusValues', () {
    test('contains all expected statuses', () {
      expect(ShareConfig.statusValues, containsAll([
        'pending', 'viewed', 'interested', 'rejected', 'new', 'matched',
      ]));
    });

    test('has exactly 6 status values', () {
      expect(ShareConfig.statusValues.length, 6);
    });
  });

  group('ShareConfig - sharingMethods', () {
    test('contains all expected methods', () {
      expect(ShareConfig.sharingMethods, containsAll([
        'whatsapp', 'in_app', 'link',
      ]));
    });

    test('has exactly 3 sharing methods', () {
      expect(ShareConfig.sharingMethods.length, 3);
    });
  });

  group('ShareConfig - matchedStatus', () {
    test('matchedStatus is "matched"', () {
      expect(ShareConfig.matchedStatus, 'matched');
    });
  });

  group('ShareConfig - isValidStatus', () {
    test('returns true for all valid statuses', () {
      for (final status in ShareConfig.statusValues) {
        expect(ShareConfig.isValidStatus(status), true, reason: '$status should be valid');
      }
    });

    test('returns false for invalid status', () {
      expect(ShareConfig.isValidStatus('expired'), false);
      expect(ShareConfig.isValidStatus('blocked'), false);
    });

    test('is case-sensitive (lowercases input)', () {
      expect(ShareConfig.isValidStatus('Pending'), true);
      expect(ShareConfig.isValidStatus('MATCHED'), true);
    });
  });

  group('ShareConfig - isValidSharingMethod', () {
    test('returns true for all valid methods', () {
      for (final method in ShareConfig.sharingMethods) {
        expect(ShareConfig.isValidSharingMethod(method), true, reason: '$method should be valid');
      }
    });

    test('returns false for invalid method', () {
      expect(ShareConfig.isValidSharingMethod('email'), false);
      expect(ShareConfig.isValidSharingMethod('sms'), false);
    });

    test('is case-sensitive (lowercases input)', () {
      expect(ShareConfig.isValidSharingMethod('WhatsApp'), true);
      expect(ShareConfig.isValidSharingMethod('IN_APP'), true);
    });
  });
}
