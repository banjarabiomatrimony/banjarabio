import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/profile_model.dart';

/// Abstract interface for Trust Score operations.
/// Implementations can delegate to core or use own logic.
abstract class TrustScoreRepository {
  static const String statusNotStarted = 'not_started';
  static const String statusInProgress = 'in_progress';
  static const String statusPendingReview = 'pending_review';
  static const String statusVerified = 'verified';
  static const String statusRejected = 'rejected';

  Future<BackendResponse<int>> calculateTrustScore({
    ProfileModel? profile,
  });

  Future<BackendResponse<Map<String, String>>> getVerificationStatus({
    ProfileModel? profile,
  });
}
