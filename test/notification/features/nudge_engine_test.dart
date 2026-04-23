import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/notification/features/nudge_engine.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NudgeEngine profile completion nudges', () {
    test('returns photo nudge when no photo', () async {
      final nudge = await NudgeEngine().evaluateNudges(userProfile: {
        'photo_url': '',
        'about': 'hi',
        'education': 'B.Tech',
        'profession': 'Engineer',
      });
      expect(nudge, isNotNull);
      expect(nudge!.id, 'nudge_profile_photo');
      expect(nudge.category, NotificationCategory.nudge);
    });

    test('returns bio nudge when photo exists but no bio', () async {
      final nudge = await NudgeEngine().evaluateNudges(userProfile: {
        'photo_url': 'https://cdn/img.jpg',
        'about': '',
        'education': 'B.Tech',
        'profession': 'Engineer',
      });
      expect(nudge, isNotNull);
      expect(nudge!.id, 'nudge_profile_bio');
    });

    test('returns details nudge when missing education', () async {
      final nudge = await NudgeEngine().evaluateNudges(userProfile: {
        'photo_url': 'https://cdn/img.jpg',
        'about': 'hi',
        'education': null,
        'profession': 'Engineer',
      });
      expect(nudge, isNotNull);
      expect(nudge!.id, 'nudge_profile_details');
    });

    test('returns null when profile is complete and no other nudges apply', () async {
      final nudge = await NudgeEngine().evaluateNudges(userProfile: {
        'photo_url': 'https://cdn/img.jpg',
        'about': 'great person',
        'education': 'B.Tech',
        'profession': 'Engineer',
        'trust_score': 80,
        'is_mobile_verified': true,
        'is_email_verified': true,
        'login_streak': 0,
      });
      expect(nudge, isNull);
    });
  });

  group('NudgeEngine trust score nudges', () {
    test('returns mobile verification nudge when trust < 40 and not verified', () async {
      final nudge = await NudgeEngine().evaluateNudges(userProfile: {
        'photo_url': 'https://cdn/img.jpg',
        'about': 'hi',
        'education': 'B.Tech',
        'profession': 'Engineer',
        'trust_score': 30,
        'is_mobile_verified': false,
        'is_email_verified': false,
      });
      expect(nudge, isNotNull);
      expect(nudge!.id, 'nudge_trust_mobile');
    });

    test('returns email verification nudge when trust < 60 and mobile verified', () async {
      final nudge = await NudgeEngine().evaluateNudges(userProfile: {
        'photo_url': 'https://cdn/img.jpg',
        'about': 'hi',
        'education': 'B.Tech',
        'profession': 'Engineer',
        'trust_score': 50,
        'is_mobile_verified': true,
        'is_email_verified': false,
      });
      expect(nudge, isNotNull);
      expect(nudge!.id, 'nudge_trust_email');
    });
  });

  group('NudgeEngine inactivity nudges', () {
    test('returns inactivity nudge for 7+ days inactive', () async {
      final lastActive = DateTime.now().subtract(const Duration(days: 8));
      final nudge = await NudgeEngine().evaluateNudges(userProfile: {
        'photo_url': 'https://cdn/img.jpg',
        'about': 'hi',
        'education': 'B.Tech',
        'profession': 'Engineer',
        'trust_score': 80,
        'is_mobile_verified': true,
        'is_email_verified': true,
        'last_active_at': lastActive.toIso8601String(),
      });
      expect(nudge, isNotNull);
      expect(nudge!.id, contains('inactivity'));
    });

    test('returns 14d nudge for 14+ days inactive', () async {
      final lastActive = DateTime.now().subtract(const Duration(days: 15));
      final nudge = await NudgeEngine().evaluateNudges(userProfile: {
        'photo_url': 'https://cdn/img.jpg',
        'about': 'hi',
        'education': 'B.Tech',
        'profession': 'Engineer',
        'trust_score': 80,
        'is_mobile_verified': true,
        'is_email_verified': true,
        'last_active_at': lastActive.toIso8601String(),
      });
      expect(nudge, isNotNull);
      expect(nudge!.id, 'nudge_inactivity_14d');
    });
  });

  group('NudgeEngine engagement streaks', () {
    test('returns streak-3 nudge', () async {
      final nudge = await NudgeEngine().evaluateNudges(userProfile: {
        'photo_url': 'https://cdn/img.jpg',
        'about': 'hi',
        'education': 'B.Tech',
        'profession': 'Engineer',
        'trust_score': 80,
        'is_mobile_verified': true,
        'is_email_verified': true,
        'login_streak': 3,
      });
      expect(nudge, isNotNull);
      expect(nudge!.id, 'nudge_streak_3');
    });

    test('returns streak-7 nudge', () async {
      final nudge = await NudgeEngine().evaluateNudges(userProfile: {
        'photo_url': 'https://cdn/img.jpg',
        'about': 'hi',
        'education': 'B.Tech',
        'profession': 'Engineer',
        'trust_score': 80,
        'is_mobile_verified': true,
        'is_email_verified': true,
        'login_streak': 7,
      });
      expect(nudge, isNotNull);
      expect(nudge!.id, 'nudge_streak_7');
    });
  });

  group('NudgeEngine cooldown', () {
    test('returns null when on cooldown', () async {
      // First call records a nudge
      SharedPreferences.setMockInitialValues({
        'nudge_last_shown': DateTime.now().toIso8601String(),
      });
      final nudge = await NudgeEngine().evaluateNudges(userProfile: {
        'photo_url': '',
      });
      expect(nudge, isNull);
    });
  });
}
