import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/config/admin_config.dart';

void main() {
  group('AdminConfig - isAdminEmail', () {
    test('returns true for exact admin email', () {
      expect(AdminConfig.isAdminEmail('admin@banjarabio.com'), true);
    });

    test('returns true for case-insensitive match', () {
      expect(AdminConfig.isAdminEmail('ADMIN@BANJARABIO.COM'), true);
      expect(AdminConfig.isAdminEmail('Admin@BanjaraBio.Com'), true);
    });

    test('returns true for email with leading/trailing whitespace', () {
      expect(AdminConfig.isAdminEmail('  admin@banjarabio.com  '), true);
    });

    test('returns false for null', () {
      expect(AdminConfig.isAdminEmail(null), false);
    });

    test('returns false for empty string', () {
      expect(AdminConfig.isAdminEmail(''), false);
    });

    test('returns false for different email', () {
      expect(AdminConfig.isAdminEmail('user@banjarabio.com'), false);
    });

    test('returns false for partial match', () {
      expect(AdminConfig.isAdminEmail('admin@banjara'), false);
    });
  });

  group('AdminConfig - constants', () {
    test('adminEmail is admin@banjarabio.com', () {
      expect(AdminConfig.adminEmail, 'admin@banjarabio.com');
    });
  });
}
