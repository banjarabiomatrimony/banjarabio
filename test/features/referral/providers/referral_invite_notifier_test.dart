import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:banjarabio/features/referral/providers/referral_invite_notifier.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/referral_stats_model.dart';
import 'package:banjarabio/core/repositories/referral_repository.dart';

class MockReferralRepository extends Mock implements ReferralRepository {}

void main() {
  group('ReferralInviteNotifier', () {
    late MockReferralRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockReferralRepository();
      container = ProviderContainer(
        overrides: [
          referralRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('loads stats and code on first access', () async {
      final stats = ReferralStatsModel(
        userId: 'user-1',
        referralCount: 5,
        rewardsEarned: 1,
        updatedAt: DateTime.now(),
      );

      when(() => mockRepository.getReferralStats())
          .thenAnswer((_) async => BackendResponse.success(stats));
      when(() => mockRepository.getMyReferralCode())
          .thenAnswer((_) async => BackendResponse.success('BANJARA-7X29'));

      final data = await container.read(referralInviteProvider.future);

      expect(data.stats?.referralCount, 5);
      expect(data.stats?.rewardsEarned, 1);
      expect(data.code, 'BANJARA-7X29');
      expect(data.link, contains('invite/BANJARA-7X29'));
      verify(() => mockRepository.getReferralStats()).called(1);
      verify(() => mockRepository.getMyReferralCode()).called(1);
    });

    test('handles stats failure gracefully', () async {
      when(() => mockRepository.getReferralStats())
          .thenAnswer((_) async => BackendResponse.failure('Network error'));
      when(() => mockRepository.getMyReferralCode())
          .thenAnswer((_) async => BackendResponse.success('CODE-123'));

      final data = await container.read(referralInviteProvider.future);

      expect(data.stats, isNull);
      expect(data.code, 'CODE-123');
      expect(data.link, contains('invite/CODE-123'));
    });

    test('handles code failure gracefully', () async {
      final stats = ReferralStatsModel.empty('user-1');
      when(() => mockRepository.getReferralStats())
          .thenAnswer((_) async => BackendResponse.success(stats));
      when(() => mockRepository.getMyReferralCode())
          .thenAnswer((_) async => BackendResponse.failure('Not authenticated'));

      final data = await container.read(referralInviteProvider.future);

      expect(data.stats, isNotNull);
      expect(data.code, isNull);
      expect(data.link, isNull);
    });

    test('refresh invalidates and reloads', () async {
      when(() => mockRepository.getReferralStats()).thenAnswer((_) async =>
          BackendResponse.success(
              ReferralStatsModel.empty('user-1')));
      when(() => mockRepository.getMyReferralCode())
          .thenAnswer((_) async => BackendResponse.success('OLD-CODE'));

      final data1 = await container.read(referralInviteProvider.future);
      expect(data1.code, 'OLD-CODE');

      when(() => mockRepository.getMyReferralCode())
          .thenAnswer((_) async => BackendResponse.success('NEW-CODE'));

      await container.read(referralInviteProvider.notifier).refresh();

      final data2 = await container.read(referralInviteProvider.future);
      expect(data2.code, 'NEW-CODE');
    });
  });

  group('ReferralInviteData', () {
    test('linkFromCode builds correct Play Store link', () {
      final link = ReferralInviteData.linkFromCode('ABC123');
      expect(link, contains('play.google.com'));
      expect(link, contains('invite/ABC123'));
      expect(link, contains('com.avishio.banjarabio'));
    });
  });
}
