import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/notification/core/notification_payload.dart';
import 'package:banjarabio/notification/features/local_notification_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Behavioral Nudge Engine.
///
/// Generates proactive, context-aware nudge notifications to drive
/// user engagement. Inspired by gamification psychology.
///
/// Nudge Types:
/// 1. **Profile Completion** — "Add a photo to get 3x more responses"
/// 2. **Inactivity Revival** — "5 new profiles match your preferences!"
/// 3. **Trust Score Boost** — "Verify your mobile to earn +20 Trust Score"
/// 4. **Engagement Streaks** — "You've been active 3 days straight! 🔥"
class NudgeEngine {
  static final NudgeEngine _instance = NudgeEngine._internal();
  factory NudgeEngine() => _instance;
  NudgeEngine._internal();

  final _random = Random();

  static const _prefKeyLastNudge = 'nudge_last_shown';
  static const _prefKeyNudgesShown = 'nudge_shown_ids';

  /// Minimum interval between nudges (4 hours).
  static const Duration _nudgeCooldown = Duration(hours: 4);

  /// Check if a nudge should be shown based on user context.
  /// Returns a nudge payload or null if no nudge is appropriate.
  Future<NotificationPayload?> evaluateNudges({
    required Map<String, dynamic> userProfile,
  }) async {
    // 1. Check cooldown
    if (await _isOnCooldown()) return null;

    // 2. Evaluate conditions in priority order
    final nudge = _evaluateProfileCompletion(userProfile) ??
        _evaluateTrustScore(userProfile) ??
        _evaluateInactivity(userProfile) ??
        _evaluateEngagement(userProfile);

    if (nudge != null) {
      await _recordNudge(nudge.id ?? 'unknown');
    }

    return nudge;
  }

  /// Profile completion nudges — highest priority.
  NotificationPayload? _evaluateProfileCompletion(
      Map<String, dynamic> profile) {
    final hasPhoto = profile['photo_url'] != null &&
        (profile['photo_url'] as String).isNotEmpty;
    final hasBio = profile['about'] != null &&
        (profile['about'] as String).isNotEmpty;
    final hasEducation = profile['education'] != null;
    final hasProfession = profile['profession'] != null;

    if (!hasPhoto) {
      return _nudge(
        id: 'profile_photo',
        title: '📸 Add a photo — get 3x more responses!',
        body: 'Profiles with photos are viewed 3x more than those without.',
        route: '/photo-management-screen',
      );
    }

    if (!hasBio) {
      final templates = [
        (
          '✍️ Tell your story!',
          'A short bio helps matches understand you better.'
        ),
        (
          '💬 Your profile needs a personal touch',
          'Add a bio to stand out from the crowd.'
        ),
      ];
      final t = templates[_random.nextInt(templates.length)];
      return _nudge(id: 'profile_bio', title: t.$1, body: t.$2, route: '/biodata-editor');
    }

    if (!hasEducation || !hasProfession) {
      return _nudge(
        id: 'profile_details',
        title: '🎓 Complete your profile',
        body: 'Adding education and profession info helps find better matches.',
        route: '/biodata-editor',
      );
    }

    return null; // Profile is complete!
  }

  /// Trust Score nudges — incentivize verification.
  NotificationPayload? _evaluateTrustScore(Map<String, dynamic> profile) {
    final trustScore = profile['trust_score'] as int? ?? 0;
    final isMobileVerified = profile['is_mobile_verified'] as bool? ?? false;
    final isEmailVerified = profile['is_email_verified'] as bool? ?? false;

    if (trustScore < 40 && !isMobileVerified) {
      return _nudge(
        id: 'trust_mobile',
        title: '🛡️ Verify your mobile — earn +20 Trust Score!',
        body: 'Verified profiles get 5x more interests. Just takes 30 seconds.',
        route: '/mobile-verification-screen',
      );
    }

    if (trustScore < 60 && !isEmailVerified) {
      return _nudge(
        id: 'trust_email',
        title: '📧 Verify your email for +15 Trust Score',
        body: 'Higher trust = higher visibility in search results.',
        route: '/email-verification-screen',
      );
    }

    return null;
  }

  /// Inactivity nudges — re-engage dormant users.
  NotificationPayload? _evaluateInactivity(Map<String, dynamic> profile) {
    final lastActiveStr = profile['last_active_at'] as String?;
    if (lastActiveStr == null) return null;

    final lastActive = DateTime.tryParse(lastActiveStr);
    if (lastActive == null) return null;

    final daysSinceActive = DateTime.now().difference(lastActive).inDays;

    if (daysSinceActive >= 7 && daysSinceActive < 14) {
      final templates = [
        (
          '💕 We miss you! 5 new matches are waiting',
          'Someone compatible joined while you were away.'
        ),
        (
          '🌟 Your profile got ${_random.nextInt(8) + 3} views this week!',
          'Come back and see who\'s interested.'
        ),
      ];
      final t = templates[_random.nextInt(templates.length)];
      return _nudge(id: 'inactivity_7d', title: t.$1, body: t.$2);
    }

    if (daysSinceActive >= 14) {
      return _nudge(
        id: 'inactivity_14d',
        title: '🔔 ${_random.nextInt(12) + 5} people match your preferences!',
        body: 'Your perfect match could be one tap away. Come back!',
      );
    }

    return null;
  }

  /// Engagement streak nudges — gamification.
  NotificationPayload? _evaluateEngagement(Map<String, dynamic> profile) {
    final loginStreak = profile['login_streak'] as int? ?? 0;

    if (loginStreak == 3) {
      return _nudge(
        id: 'streak_3',
        title: '🔥 3-day streak!',
        body: 'Keep it going! Active users find matches 2x faster.',
      );
    }

    if (loginStreak == 7) {
      return _nudge(
        id: 'streak_7',
        title: '🏆 7-day streak! You\'re on fire!',
        body: 'You\'re in the top 10% of active users this week.',
      );
    }

    return null;
  }

  NotificationPayload _nudge({
    required String id,
    required String title,
    required String body,
    String? route,
  }) {
    return NotificationPayload(
      id: 'nudge_$id',
      title: title,
      body: body,
      route: route,
      category: NotificationCategory.nudge,
      data: {'nudge_type': id},
    );
  }

  Future<bool> _isOnCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_prefKeyLastNudge);
    if (lastStr == null) return false;

    final lastNudge = DateTime.tryParse(lastStr);
    if (lastNudge == null) return false;

    return DateTime.now().difference(lastNudge) < _nudgeCooldown;
  }

  Future<void> _recordNudge(String nudgeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyLastNudge, DateTime.now().toIso8601String());

    final shown = prefs.getStringList(_prefKeyNudgesShown) ?? [];
    if (!shown.contains(nudgeId)) {
      shown.add(nudgeId);
      await prefs.setStringList(_prefKeyNudgesShown, shown);
    }
  }

  /// Schedules or cancels the daily Mass-Market subscription nudge.
  Future<void> scheduleDailyMassMarketNudge({required bool isPremium}) async {
    final prefs = await SharedPreferences.getInstance();

    if (isPremium) {
      // User is premium, cancel any scheduled nudge
      await LocalNotificationService().cancel(202020);
      AppLogger.debug('NudgeEngine', 'Daily Mass-Market nudge cancelled because user is premium');
      return;
    }

    // List of high-conversion nudge messages targeting free/non-paying users
    final messages = [
      (
        'Unlock Unlimited Replies! 🔓',
        'Get unlimited replies and 10 daily profile views for just ₹20/month. Upgrade to Mass-Market now!'
      ),
      (
        'Connect for just ₹20/month! 💖',
        'Start chatting with your compatible matches immediately. Upgrade to Mass-Market today!'
      ),
      (
        'Find Your Life Partner for ₹20 💍',
        'Unlock daily profile views & unlimited messaging. Upgrade to Mass-Market now!'
      ),
    ];

    // Pick a message randomly or based on a counter to rotate them
    final index = prefs.getInt('mass_market_nudge_index') ?? 0;
    final nextIndex = (index + 1) % messages.length;
    await prefs.setInt('mass_market_nudge_index', nextIndex);

    final selected = messages[index];
    final payload = NotificationPayload(
      id: 'nudge_mass_market_daily',
      title: selected.$1,
      body: selected.$2,
      route: '/subscription',
      category: NotificationCategory.nudge,
      data: {'nudge_type': 'mass_market_daily'},
    );

    // Schedule daily notification via LocalNotificationService
    try {
      await LocalNotificationService().scheduleDaily(
        id: 202020,
        title: selected.$1,
        body: selected.$2,
        payload: payload,
      );

      AppLogger.debug(
        'NudgeEngine',
        'Scheduled daily Mass-Market nudge: "${selected.$1}" (Index: $index)',
      );
    } catch (e) {
      AppLogger.error(
        'NudgeEngine',
        'Failed to schedule Mass-Market nudge safely: $e',
      );
    }
  }
}
