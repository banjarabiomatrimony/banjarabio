import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:banjarabio/core/models/referral_stats_model.dart';
import 'package:banjarabio/core/repositories/referral_repository.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Data returned by [referralInviteProvider].
/// Keeps stats, code, and derived link in one place.
class ReferralInviteData {
  const ReferralInviteData({
    required this.stats,
    required this.code,
    required this.link,
  });

  final ReferralStatsModel? stats;
  final String? code;
  final String? link;

  static const _baseLink =
      'https://play.google.com/store/apps/details?id=com.avishio.banjarabio&referrer=invite/';

  static String linkFromCode(String code) => '$_baseLink$code';
}

/// Provider for [ReferralRepository]. Override in tests with mock.
final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  return ReferralRepository();
});

/// Async state for Referral Invite screen.
/// Loads stats + code on first access; UI watches [AsyncValue].
final referralInviteProvider =
    AsyncNotifierProvider<ReferralInviteNotifier, ReferralInviteData>(
  ReferralInviteNotifier.new,
);

class ReferralInviteNotifier extends AsyncNotifier<ReferralInviteData> {
  @override
  Future<ReferralInviteData> build() async {
    final repo = ref.read(referralRepositoryProvider);

    final statsRes = await repo.getReferralStats();
    final codeRes = await repo.getMyReferralCode();

    ReferralStatsModel? stats;
    String? code;
    String? link;

    statsRes.fold(
      onSuccess: (s) => stats = s,
      onFailure: (_) {},
    );

    codeRes.fold(
      onSuccess: (c) {
        code = c;
        link = ReferralInviteData.linkFromCode(c);
      },
      onFailure: (_) {},
    );

    return ReferralInviteData(stats: stats, code: code, link: link);
  }

  /// Call to refresh stats and code (e.g. pull-to-refresh).
  Future<void> refresh() async {
    if (kDebugMode) {
      AppLogger.debug('ReferralInviteNotifier', '[REFERRAL] ReferralInviteNotifier > refresh > Invalidating');
    }
    ref.invalidateSelf();
  }
}
