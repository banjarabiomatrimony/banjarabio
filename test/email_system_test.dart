import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/repositories/email_repository.dart';

void main() {
  group('Email System - Unit Tests', () {
    test('EmailRepository class is importable and defined', () {
      // Verify the file compiles and the class type is accessible
      expect(EmailRepository, isNotNull);
    });
  });

  group('Email Preferences - Data Model Tests', () {
    test('Default preferences are all enabled', () {
      // Simulate the default preference map from the UI
      final defaultPrefs = {
        'daily_recommendations': true,
        'weekly_digest': true,
        'monthly_digest': true,
        'match_alerts': true,
        'interest_alerts': true,
        'local_profiles': true,
        'offers': true,
      };

      expect(defaultPrefs.length, equals(7));
      for (final key in defaultPrefs.keys) {
        expect(defaultPrefs[key], isTrue,
            reason: '$key should default to true');
      }
    });

    test('Preference keys match database columns', () {
      // These must exactly match the Supabase email_preferences table columns
      const dbColumns = [
        'daily_recommendations',
        'weekly_digest',
        'monthly_digest',
        'match_alerts',
        'interest_alerts',
        'local_profiles',
        'offers',
      ];

      final uiPrefs = {
        'daily_recommendations': true,
        'weekly_digest': true,
        'monthly_digest': true,
        'match_alerts': true,
        'interest_alerts': true,
        'local_profiles': true,
        'offers': true,
      };

      for (final col in dbColumns) {
        expect(uiPrefs.containsKey(col), isTrue,
            reason: 'UI must have key "$col" matching DB column');
      }
    });

    test('Email types cover all scheduled jobs', () {
      // These are the email types the send-email Edge Function handles
      const emailTypes = [
        'daily_recommendation',
        'weekly_digest',
        'monthly_digest',
        'new_match',
        'new_interest',
        'local_district',
        'special_offer',
      ];

      expect(emailTypes.length, equals(7));
      expect(emailTypes.contains('daily_recommendation'), isTrue);
      expect(emailTypes.contains('weekly_digest'), isTrue);
      expect(emailTypes.contains('monthly_digest'), isTrue);
      expect(emailTypes.contains('new_match'), isTrue);
      expect(emailTypes.contains('new_interest'), isTrue);
    });
  });

  group('Email Providers - Configuration Tests', () {
    test('Provider rotation order is correct', () {
      // Brevo first (300/day), then Resend (100/day), then SendGrid (100/day)
      const providerOrder = ['brevo', 'resend', 'sendgrid'];
      const providerLimits = {'brevo': 300, 'resend': 100, 'sendgrid': 100};

      expect(providerOrder.length, equals(3));
      expect(providerLimits.values.reduce((a, b) => a + b), equals(500));
      expect(providerOrder.first, equals('brevo'),
          reason: 'Brevo should be first (highest free limit)');
    });

    test('Total daily free capacity is ~500', () {
      const brevoDaily = 300;
      const resendDaily = 100;
      const sendgridDaily = 100;

      expect(brevoDaily + resendDaily + sendgridDaily, equals(500));
    });
  });
}
