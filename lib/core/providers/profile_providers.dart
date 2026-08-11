import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/models/profile_model.dart';

/// Provider for [ProfileRepository]. Override in tests with mock to avoid Supabase.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// FutureProvider for the current user's own profile.
final ownProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final response = await repository.getOwnProfile();
  return response.data;
});
