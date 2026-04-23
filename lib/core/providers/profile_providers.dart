import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:banjarabio/core/repositories/profile_repository.dart';

/// Provider for [ProfileRepository]. Override in tests with mock to avoid Supabase.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});
