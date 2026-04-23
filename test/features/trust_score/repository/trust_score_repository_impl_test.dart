import 'package:flutter_test/flutter_test.dart';

import 'package:banjarabio/features/trust_score/repository/trust_score_repository.dart';

void main() {
  group('TrustScoreRepository (interface)', () {
    test('exposes status constants', () {
      expect(TrustScoreRepository.statusNotStarted, 'not_started');
      expect(TrustScoreRepository.statusVerified, 'verified');
      expect(TrustScoreRepository.statusPendingReview, 'pending_review');
      expect(TrustScoreRepository.statusRejected, 'rejected');
    });
  });
}
