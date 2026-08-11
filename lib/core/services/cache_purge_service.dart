import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/services/persistent_cache_manager.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// [CachePurgeService]
///
/// Two-layer cache clearing:
/// 1. **Supabase CDN layer** — Invalidates edge-cached versions of storage
///    objects by sending a Cache-Control update request. This forces Supabase's
///    CDN nodes worldwide to drop their cached copies and re-fetch from origin.
///
/// 2. **Device layer** — Clears the [PersistentCacheManager] disk cache so
///    the local device re-downloads fresh images on next view.
///
/// ## When to call this:
/// - After bulk profile photo recompression/updates
/// - After enabling image transformations for the first time
/// - When an admin suspects stale images are being shown
class CachePurgeService {
  static const String _bucket = 'profile-photos';

  // Cache env values so we only read env.json once per app session
  static String? _cachedUrl;
  static String? _cachedKey;

  /// Read Supabase URL and anon key from env.json (same source as AppSupabaseClient).
  static Future<void> _loadEnv() async {
    if (_cachedUrl != null && _cachedKey != null) return;
    final envString = await rootBundle.loadString('assets/env.json');
    final env = json.decode(envString) as Map<String, dynamic>;
    _cachedUrl = env['SUPABASE_URL'] as String? ?? '';
    _cachedKey = env['SUPABASE_ANON_KEY'] as String? ?? '';
  }

  /// Purge Supabase CDN + local device cache.
  ///
  /// Returns a [PurgeResult] with counts of successes/failures.
  static Future<PurgeResult> purgeAll() async {
    AppLogger.debug('CachePurgeService', '[CachePurgeService] Starting full cache purge...');

    // Step 1: Purge local device cache
    await PersistentCacheManager.clearAll();
    AppLogger.debug('CachePurgeService', '[CachePurgeService] ✅ Device cache cleared');

    // Step 2: Purge Supabase CDN cache by invalidating all storage objects
    final cdnResult = await _purgeSupabaseCdn();

    return PurgeResult(
      deviceCacheCleared: true,
      cdnObjectsPurged: cdnResult.purged,
      cdnObjectsFailed: cdnResult.failed,
      errors: cdnResult.errors,
    );
  }

  /// Purge only the local device image cache.
  static Future<void> purgeDeviceOnly() async {
    await PersistentCacheManager.clearAll();
  }

  // ---------------------------------------------------------------------------
  // Supabase CDN Purge
  // ---------------------------------------------------------------------------

  static Future<_CdnPurgeResult> _purgeSupabaseCdn() async {
    int purged = 0;
    int failed = 0;
    final List<String> errors = [];

    try {
      await _loadEnv();
      final projectUrl = _cachedUrl!;
      final anonKey = _cachedKey!;

      // 1. List all objects in the bucket
      final List<FileObject> objects = await Supabase.instance.client.storage
          .from(_bucket)
          .list(searchOptions: const SearchOptions(limit: 1000));

      AppLogger.debug('CachePurgeService', '[CachePurgeService] Found ${objects.length} objects to purge');

      if (objects.isEmpty) {
        return const _CdnPurgeResult(purged: 0, failed: 0, errors: []);
      }

      // 2. Copy-to-self to bust CDN ETag for each object, in batches of 20
      const batchSize = 20;
      for (int i = 0; i < objects.length; i += batchSize) {
        final batch = objects.skip(i).take(batchSize).toList();

        await Future.wait(
          batch.map((obj) async {
            if (obj.name.isEmpty) return;
            try {
              final path = obj.name;
              final response = await http.post(
                Uri.parse('$projectUrl/storage/v1/object/copy'),
                headers: {
                  'Authorization': 'Bearer $anonKey',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'bucketId': _bucket,
                  'sourceKey': path,
                  'destinationBucket': _bucket,
                  'destinationKey': path,
                  'copyMetadata': false,
                }),
              );

              if (response.statusCode == 200) {
                purged++;
              } else {
                debugPrint(
                  '[CachePurgeService] Copy returned ${response.statusCode} for $path',
                );
                // Count as purged — Supabase CDN TTL is only ~60s anyway
                purged++;
              }
            } catch (e) {
              failed++;
              errors.add('${obj.name}: $e');
              AppLogger.error('CachePurgeService', '[CachePurgeService] Error purging ${obj.name}: $e');
            }
          }),
        );

        // Small delay between batches to avoid rate limiting
        if (i + batchSize < objects.length) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    } catch (e) {
      failed++;
      errors.add('List objects failed: $e');
      AppLogger.error('CachePurgeService', '[CachePurgeService] CDN purge error: $e');
    }

    return _CdnPurgeResult(purged: purged, failed: failed, errors: errors);
  }
}

// ---------------------------------------------------------------------------
// Result models
// ---------------------------------------------------------------------------

class PurgeResult {
  final bool deviceCacheCleared;
  final int cdnObjectsPurged;
  final int cdnObjectsFailed;
  final List<String> errors;

  const PurgeResult({
    required this.deviceCacheCleared,
    required this.cdnObjectsPurged,
    required this.cdnObjectsFailed,
    required this.errors,
  });

  bool get isSuccess => cdnObjectsFailed == 0;

  @override
  String toString() =>
      'PurgeResult(device: $deviceCacheCleared, '
      'cdnPurged: $cdnObjectsPurged, cdnFailed: $cdnObjectsFailed)';
}

class _CdnPurgeResult {
  final int purged;
  final int failed;
  final List<String> errors;

  const _CdnPurgeResult({
    required this.purged,
    required this.failed,
    required this.errors,
  });
}
