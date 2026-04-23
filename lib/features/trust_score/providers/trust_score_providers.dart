import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:banjarabio/features/trust_score/repository/trust_score_repository_impl.dart';
import 'package:banjarabio/features/trust_score/repository/trust_score_repository.dart';

/// Provider for [TrustScoreRepository]. Override in tests with mock.
final trustScoreRepositoryProvider =
    Provider<TrustScoreRepository>((ref) => TrustScoreRepositoryImpl());
