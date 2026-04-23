import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart' as core;

import 'package:banjarabio/features/trust_score/repository/trust_score_repository.dart';

/// Implementation that delegates to core [core.TrustScoreRepository].
class TrustScoreRepositoryImpl implements TrustScoreRepository {
  final core.TrustScoreRepository _delegate = core.TrustScoreRepository();

  @override
  Future<BackendResponse<int>> calculateTrustScore({
    ProfileModel? profile,
  }) =>
      _delegate.calculateTrustScore(profile: profile);

  @override
  Future<BackendResponse<Map<String, String>>> getVerificationStatus({
    ProfileModel? profile,
  }) =>
      _delegate.getVerificationStatus(profile: profile);
}
