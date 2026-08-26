import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/utils/error_message_mapper.dart';

void main() {
  group('ErrorMessageMapper Translation Tests', () {
    test('handles null error with default fallback', () {
      final msg = ErrorMessageMapper.getFriendlyMessageFromL10n(null, null);
      expect(msg, equals('Something went wrong. Please try again.'));

      final customFallback = ErrorMessageMapper.getFriendlyMessageFromL10n(
        null,
        null,
        fallbackMessage: 'Custom fallback',
      );
      expect(customFallback, equals('Custom fallback'));
    });

    test('maps Postgrest duplicate key / 23505 errors', () {
      const phoneError = PostgrestException(
        message: 'duplicate key value violates unique constraint "idx_profiles_normalized_phone"',
        code: '23505',
      );
      final msg = ErrorMessageMapper.getFriendlyMessageFromL10n(null, phoneError);
      expect(msg, equals('This mobile number is already registered with another account.'));

      const duplicateGeneric = PostgrestException(
        message: 'duplicate key value',
        code: '23505',
      );
      final genericMsg = ErrorMessageMapper.getFriendlyMessageFromL10n(null, duplicateGeneric);
      expect(genericMsg, equals('This record already exists.'));
    });

    test('maps Postgrest permission denied / 42501 and session expired', () {
      const permError = PostgrestException(
        message: 'new row violates row-level security policy for table "profiles"',
        code: '42501',
      );
      final permMsg = ErrorMessageMapper.getFriendlyMessageFromL10n(null, permError);
      expect(permMsg, equals('You do not have permission to perform this action.'));

      const sessionError = PostgrestException(
        message: 'JWT expired',
        code: 'PGRST301',
      );
      final sessionMsg = ErrorMessageMapper.getFriendlyMessageFromL10n(null, sessionError);
      expect(sessionMsg, equals('Your session has expired. Please log in again.'));
    });

    test('maps AuthException cases', () {
      const userExistsError = AuthException('User already registered', code: 'user_already_exists');
      final msg1 = ErrorMessageMapper.getFriendlyMessageFromL10n(null, userExistsError);
      expect(msg1, equals('An account with this information already exists.'));

      const invalidCreds = AuthException('Invalid login credentials', code: 'invalid_grant');
      final msg2 = ErrorMessageMapper.getFriendlyMessageFromL10n(null, invalidCreds);
      expect(msg2, equals('Invalid login credentials. Please try again.'));
    });

    test('maps SocketException and Network failures', () {
      const socketError = SocketException('Failed host lookup: api.supabase.co');
      final msg = ErrorMessageMapper.getFriendlyMessageFromL10n(null, socketError);
      expect(msg, equals('Please check your internet connection and try again.'));
    });

    test('maps clean string errors and prevents internal leaks', () {
      final cleanString = ErrorMessageMapper.getFriendlyMessageFromL10n(null, 'Custom business error');
      expect(cleanString, equals('Custom business error'));

      final leakedString = ErrorMessageMapper.getFriendlyMessageFromL10n(null, 'PostgrestException: column id does not exist in table');
      expect(leakedString, equals('Something went wrong. Please try again.'));
    });
  });
}
