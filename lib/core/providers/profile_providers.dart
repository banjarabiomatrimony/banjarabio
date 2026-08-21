import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/features/bookmarks/repository/bookmark_repository_impl.dart';

/// Provider for [ProfileRepository]. Override in tests with mock to avoid Supabase.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// FutureProvider for the current user's own profile.
final ownProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final response = await repository.getOwnProfile();
  return response.fold(
    onSuccess: (profile) => profile,
    onFailure: (_) => null,
  );
});

/// FutureProvider for the current user's active subscription.
final ownSubscriptionProvider = FutureProvider<SubscriptionModel?>((ref) async {
  final repository = SubscriptionRepository();
  final response = await repository.getCurrentSubscription();
  return response.fold(
    onSuccess: (subscription) => subscription,
    onFailure: (_) => null,
  );
});

/// FutureProvider for the current user's profile view count (Who Viewed Me).
final whoViewedMeCountProvider = FutureProvider<int>((ref) async {
  final repository = ChatRepository();
  final response = await repository.getWhoViewedMe();
  return response.fold(
    onSuccess: (views) => views.length,
    onFailure: (_) => 0,
  );
});

/// FutureProvider for the current user's Trust Score.
final trustScoreProvider = FutureProvider<int>((ref) async {
  final profile = await ref.watch(ownProfileProvider.future);
  final repository = SubscriptionRepository();
  final response = await repository.getTrustScore(profile: profile);
  return response.fold(
    onSuccess: (score) => score,
    onFailure: (_) => 0,
  );
});

/// FutureProvider for the bookmarked/saved profiles count.
final savedProfilesCountProvider = FutureProvider<int>((ref) async {
  final repository = BookmarkRepositoryImpl();
  final response = await repository.getBookmarkedProfileIds();
  return response.fold(
    onSuccess: (ids) => ids.length,
    onFailure: (_) => 0,
  );
});

/// FutureProvider for the received connection shares count.
final receivedSharesCountProvider = FutureProvider<int>((ref) async {
  final repository = ShareRepository();
  final response = await repository.getSharesWithMe();
  return response.fold(
    onSuccess: (shares) => shares.length,
    onFailure: (_) => 0,
  );
});

/// FutureProvider for the mutual matched profiles count.
final matchedSharesCountProvider = FutureProvider<int>((ref) async {
  final repository = ShareRepository();
  final response = await repository.getMatchedProfiles();
  return response.fold(
    onSuccess: (matches) => matches.length,
    onFailure: (_) => 0,
  );
});

