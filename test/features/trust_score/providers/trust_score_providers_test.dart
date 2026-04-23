import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/features/trust_score/providers/trust_score_providers.dart';
import 'package:banjarabio/features/trust_score/repository/trust_score_repository.dart';

class MockTrustScoreRepository extends Mock implements TrustScoreRepository {}

void main() {
  group('trustScoreRepositoryProvider', () {
    test('provides TrustScoreRepository when overridden with mock', () {
      final mockRepo = MockTrustScoreRepository();
      final container = ProviderContainer(
        overrides: [trustScoreRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final repo = container.read(trustScoreRepositoryProvider);

      expect(repo, isNotNull);
      expect(repo, isA<TrustScoreRepository>());
      expect(repo, same(mockRepo));
    });

    test('calculateTrustScore delegates to repository', () async {
      final mockRepo = MockTrustScoreRepository();
      when(() => mockRepo.calculateTrustScore(profile: any(named: 'profile')))
          .thenAnswer((_) async => BackendResponse.success(75));

      final container = ProviderContainer(
        overrides: [
          trustScoreRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(trustScoreRepositoryProvider);
      final result = await repo.calculateTrustScore();

      expect(result.isSuccess, true);
      expect(result.data, 75);
      verify(() => mockRepo.calculateTrustScore(profile: any(named: 'profile')))
          .called(1);
    });

    test('getVerificationStatus delegates to repository', () async {
      final mockRepo = MockTrustScoreRepository();
      when(() => mockRepo.getVerificationStatus(profile: any(named: 'profile')))
          .thenAnswer((_) async => BackendResponse.success({'mobile': 'verified'}));

      final container = ProviderContainer(
        overrides: [
          trustScoreRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(trustScoreRepositoryProvider);
      final result = await repo.getVerificationStatus();

      expect(result.isSuccess, true);
      expect(result.data, {'mobile': 'verified'});
    });
  });
}
