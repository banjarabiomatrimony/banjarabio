import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:banjarabio/core/services/ad_reward_service.dart';
import 'package:banjarabio/core/supabase_client.dart' as app_supabase;
import 'package:banjarabio/core/repositories/subscription_repository.dart';

/// Repository for tracking user activity and enforcing limits
class UsageRepository {
  /// Visible for testing - allows injection of mock Supabase client
  @visibleForTesting
  SupabaseClient? testClient;

  /// Visible for testing - allows injection of mock SubscriptionRepository
  @visibleForTesting
  SubscriptionRepository? testSubscriptionRepository;

  SupabaseClient get _supabase => testClient ?? app_supabase.AppSupabaseClient.client;
  SubscriptionRepository get _subscriptionRepository => 
      testSubscriptionRepository ?? SubscriptionRepository();

  /// Get or create today's usage record
  Future<Map<String, dynamic>> _getTodayUsage() async {
    final userId = app_supabase.AppSupabaseClient.currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final today = DateTime.now().toIso8601String().substring(0, 10);

    // Try to get existing record
    final existing = await _supabase
        .from('usage_tracking')
        .select()
        .eq('user_id', userId)
        .eq('date', today)
        .maybeSingle();

    if (existing != null) return existing;

    // Create new record explicitly
    try {
      final newRecord = {
        'user_id': userId,
        'date': today,
        'profile_views': 0,
        'shares_count': 0,
        'bookmarks_count': 0,
      };

      final response = await _supabase
          .from('usage_tracking')
          .insert(newRecord)
          .select()
          .single();

      return response;
    } catch (e) {
      // Handle race condition if created concurrently
      final retry = await _supabase
          .from('usage_tracking')
          .select()
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();

      if (retry != null) return retry;
      rethrow;
    }
  }

  /// Increment profile views and check limit
  Future<BackendResponse<bool>> canViewProfile() async {
    try {
      final planRes = await _subscriptionRepository.getPlanType();

      return await planRes.fold(
        onSuccess: (planType) async {
          final features = SubscriptionConfig.getFeatures(planType);

          // Premium users have unlimited views
          if (features.profileViewsPerDay >= 999) {
            return BackendResponse.success(true);
          }

          final usage = await _getTodayUsage();
          final currentViews = usage['profile_views'] as int? ?? 0;
          final bonusViews = usage['bonus_views_today'] as int? ?? 0;

          return BackendResponse.success(
            currentViews < (features.profileViewsPerDay + bonusViews),
          );
        },
        onFailure: (error) =>
            BackendResponse.failure('Failed to get plan info: $error'),
      );
    } catch (e, stack) {
      debugPrint('UsageRepository.canViewProfile: Error = $e');
      return BackendResponse.failure(
        e.toString(),
        stackTrace: stack,
        onRetry: () => canViewProfile(),
      );
    }
  }

  /// Increment profile view count
  /// Migrated to Use RPC: fn_track_usage
  Future<BackendResponse<void>> incrementProfileView() async {
    try {
      final response = await _supabase.rpc(
        'fn_track_usage',
        params: {'metric': 'profile_views', 'increment': 1},
      );
      return BackendResponse.fromRpc(
        response,
        onRetry: () => incrementProfileView(),
      );
    } catch (e) {
      debugPrint('UsageRepository.incrementProfileView via RPC error: $e');
      // 🚨 CRITICAL: Do NOT block navigation if tracking fails
      // Just return success so the user can see the profile
      return BackendResponse.success(null);
    }
  }

  /// Get remaining profile views for today
  Future<BackendResponse<int>> getRemainingProfileViews() async {
    try {
      final planRes = await _subscriptionRepository.getPlanType();

      return await planRes.fold(
        onSuccess: (planType) async {
          final features = SubscriptionConfig.getFeatures(planType);

          if (features.profileViewsPerDay >= 999) {
            return BackendResponse.success(999);
          }

          final usage = await _getTodayUsage();
          final currentViews = usage['profile_views'] as int? ?? 0;
          final bonusViews = usage['bonus_views_today'] as int? ?? 0;

          return BackendResponse.success(
            ((features.profileViewsPerDay + bonusViews) - currentViews).clamp(0, 999),
          );
        },
        onFailure: (error) =>
            BackendResponse.failure('Plan fetch failed: $error'),
      );
    } catch (e) {
      debugPrint('UsageRepository.getRemainingProfileViews: Error = $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Check if user can share more profiles this month
  Future<BackendResponse<bool>> canShareProfile() async {
    try {
      final planRes = await _subscriptionRepository.getPlanType();

      return await planRes.fold(
        onSuccess: (planType) async {
          final features = SubscriptionConfig.getFeatures(planType);

          // Premium users have unlimited shares
          if (features.sharesPerMonth >= 999) {
            return BackendResponse.success(true);
          }

          final userId = app_supabase.AppSupabaseClient.currentUserId;
          if (userId == null) {
            return BackendResponse.failure('User not authenticated');
          }

          // Get user's profile ID
          final profile = await _supabase
              .from('profiles')
              .select('id')
              .eq('user_id', userId)
              .maybeSingle();

          if (profile == null) {
            return BackendResponse.failure('Profile not found');
          }
          final profileId = profile['id'];

          final now = DateTime.now();
          final monthStart = DateTime(now.year, now.month).toIso8601String();

          // Count shares this month using .count() for efficiency
          final response = await _supabase
              .from('profile_shares')
              .select()
              .eq('sharer_id', profileId)
              .gte('created_at', monthStart)
              .count();

          final count = response.count;
          return BackendResponse.success(count < features.sharesPerMonth);
        },
        onFailure: (error) => BackendResponse.failure(error),
      );
    } catch (e) {
      debugPrint('UsageRepository.canShareProfile: Error = $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Get remaining shares for this month
  Future<BackendResponse<int>> getRemainingShares() async {
    try {
      final planRes = await _subscriptionRepository.getPlanType();

      return await planRes.fold(
        onSuccess: (planType) async {
          final features = SubscriptionConfig.getFeatures(planType);

          if (features.sharesPerMonth >= 999) {
            return BackendResponse.success(999);
          }

          final userId = app_supabase.AppSupabaseClient.currentUserId;
          if (userId == null) {
            return BackendResponse.failure('User not authenticated');
          }

          // Get user's profile ID
          final profile = await _supabase
              .from('profiles')
              .select('id')
              .eq('user_id', userId)
              .maybeSingle();

          if (profile == null) {
            return BackendResponse.failure('Profile not found');
          }
          final profileId = profile['id'];

          final now = DateTime.now();
          final monthStart = DateTime(now.year, now.month).toIso8601String();

          final response = await _supabase
              .from('profile_shares')
              .select()
              .eq('sharer_id', profileId)
              .gte('created_at', monthStart)
              .count();

          final count = response.count;
          return BackendResponse.success(
            (features.sharesPerMonth - count).clamp(0, 999),
          );
        },
        onFailure: (error) => BackendResponse.failure(error),
      );
    } catch (e) {
      debugPrint('UsageRepository.getRemainingShares: Error = $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Check if user can add more bookmarks
  Future<BackendResponse<bool>> canAddBookmark() async {
    try {
      final planRes = await _subscriptionRepository.getPlanType();

      return await planRes.fold(
        onSuccess: (planType) async {
          final features = SubscriptionConfig.getFeatures(planType);

          // Premium users have unlimited bookmarks
          if (features.bookmarksLimit >= 999) {
            return BackendResponse.success(true);
          }

          final userId = app_supabase.AppSupabaseClient.currentUserId;
          if (userId == null) {
            return BackendResponse.failure('User not authenticated');
          }

          final usage = await _getTodayUsage();
          final bonusBookmarks = usage['bonus_bookmarks_today'] as int? ?? 0;

          final response = await _supabase
              .from('bookmarks')
              .select()
              .eq('user_id', userId)
              .count();

          final count = response.count;
          return BackendResponse.success(count < (features.bookmarksLimit + bonusBookmarks));
        },
        onFailure: (error) => BackendResponse.failure(error),
      );
    } catch (e) {
      debugPrint('UsageRepository.canAddBookmark: Error = $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Get remaining bookmark slots
  Future<BackendResponse<int>> getRemainingBookmarks() async {
    try {
      final planRes = await _subscriptionRepository.getPlanType();

      return await planRes.fold(
        onSuccess: (planType) async {
          final features = SubscriptionConfig.getFeatures(planType);

          if (features.bookmarksLimit >= 999) {
            return BackendResponse.success(999);
          }

          final userId = app_supabase.AppSupabaseClient.currentUserId;
          if (userId == null) {
            return BackendResponse.failure('User not authenticated');
          }

          final usage = await _getTodayUsage();
          final bonusBookmarks = usage['bonus_bookmarks_today'] as int? ?? 0;

          final response = await _supabase
              .from('bookmarks')
              .select()
              .eq('user_id', userId)
              .count();

          final count = response.count;
          return BackendResponse.success(
            ((features.bookmarksLimit + bonusBookmarks) - count).clamp(0, 999),
          );
        },
        onFailure: (error) => BackendResponse.failure(error),
      );
    } catch (e) {
      debugPrint('UsageRepository.getRemainingBookmarks: Error = $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Check if user can upload more photos
  Future<BackendResponse<bool>> canUploadPhoto() async {
    try {
      final planRes = await _subscriptionRepository.getPlanType();

      return await planRes.fold(
        onSuccess: (planType) async {
          final features = SubscriptionConfig.getFeatures(planType);

          final userId = app_supabase.AppSupabaseClient.currentUserId;
          if (userId == null) {
            return BackendResponse.failure('User not authenticated');
          }

          // Get user's profile ID
          final profile = await _supabase
              .from('profiles')
              .select('id')
              .eq('user_id', userId)
              .maybeSingle();

          if (profile == null) {
            return BackendResponse.failure('Profile not found');
          }

          final response = await _supabase
              .from('photos')
              .select()
              .eq('profile_id', profile['id'])
              .count();

          final count = response.count;
          return BackendResponse.success(count < features.photosLimit);
        },
        onFailure: (error) => BackendResponse.failure(error),
      );
    } catch (e) {
      debugPrint('UsageRepository.canUploadPhoto: Error = $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Get remaining photo slots
  Future<BackendResponse<int>> getRemainingPhotos() async {
    try {
      final planRes = await _subscriptionRepository.getPlanType();

      return await planRes.fold(
        onSuccess: (planType) async {
          final features = SubscriptionConfig.getFeatures(planType);

          final userId = app_supabase.AppSupabaseClient.currentUserId;
          if (userId == null) {
            return BackendResponse.failure('User not authenticated');
          }

          final profile = await _supabase
              .from('profiles')
              .select('id')
              .eq('user_id', userId)
              .maybeSingle();

          if (profile == null) {
            return BackendResponse.failure('Profile not found');
          }

          final response = await _supabase
              .from('photos')
              .select()
              .eq('profile_id', profile['id'])
              .count();

          final count = response.count;
          return BackendResponse.success(
            (features.photosLimit - count).clamp(0, 999),
          );
        },
        onFailure: (error) => BackendResponse.failure(error),
      );
    } catch (e) {
      debugPrint('UsageRepository.getRemainingPhotos: Error = $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Increment share count
  /// Migrated to Use RPC: fn_track_usage
  Future<BackendResponse<void>> incrementShareCount() async {
    try {
      final response = await _supabase.rpc(
        'fn_track_usage',
        params: {'metric': 'shares_count', 'increment': 1},
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      debugPrint('UsageRepository.incrementShareCount via RPC error: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Get remaining bonus messages (from daily rewards)
  Future<BackendResponse<int>> getRemainingBonusMessages() async {
    try {
      final usage = await _getTodayUsage();
      final bonusMsgs = usage['bonus_messages_today'] as int? ?? 0;
      return BackendResponse.success(bonusMsgs);
    } catch (e) {
      debugPrint('UsageRepository.getRemainingBonusMessages error: $e');
      return BackendResponse.failure(e.toString());
    }
  }

  /// Grant reward after watching an ad
  Future<BackendResponse<void>> grantAdReward(AdRewardType type) async {
    /*
    try {
      final metric = type == AdRewardType.profileViews 
          ? 'bonus_views_today' 
          : 'bonus_messages_today';
      final increment = type == AdRewardType.profileViews ? 5 : 1;

      final response = await _supabase.rpc(
        'fn_track_usage',
        params: {'metric': metric, 'increment': increment},
      );
      return BackendResponse.fromRpc(response);
    } catch (e) {
      debugPrint('UsageRepository.grantAdReward via RPC error: $e');
      return BackendResponse.failure(e.toString());
    }
    */
    return BackendResponse.success(null);
  }
}
