import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/app_version.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_info.dart';
import 'package:banjarabio/core/update_ecosystem/layer2_contracts/update_config_source.dart';

/// 🐘 [SupabaseUpdateSource]
///
/// Production-grade remote version source powered by Supabase.
/// Reads version policies from the `app_config` table or fallback configuration.
class SupabaseUpdateSource implements UpdateConfigSource {
  final String tableName;
  final String configId;
  final SupabaseClient? client;
  final String fallbackStoreUrl;

  const SupabaseUpdateSource({
    this.tableName = 'app_config',
    this.configId = 'global',
    this.client,
    this.fallbackStoreUrl = 'market://details?id=com.avishio.banjarabio',
  });

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  @override
  Future<UpdateInfo?> fetchUpdateInfo(AppVersion currentVersion) async {
    try {
      // 1. Query Supabase table for version configuration
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('id', configId)
          .maybeSingle();

      if (response == null) {
        AppLogger.debug('SupabaseUpdateSource', 'No record found in $tableName for id=$configId');
        return null;
      }

      final data = Map<String, dynamic>.from(response);

      // 2. Parse version strings
      final latestStr = (data['latest_version'] ?? data['latest'] ?? currentVersion.toString()).toString();
      final minRequiredStr = (data['min_version'] ?? data['min_required_version'] ?? '0.0.0').toString();
      final forceFlag = (data['force_update'] ?? data['is_force_update'] ?? false) as bool;

      final latestVersion = AppVersion.parse(latestStr);
      final minRequiredVersion = AppVersion.parse(minRequiredStr);

      // Auto-Heartbeat: If this client runs a newer version (e.g. fresh Play Store release),
      // auto-sync to backend so older installs immediately discover this update without manual DB work.
      if (currentVersion > latestVersion) {
        _autoSyncNewVersionToBackend(currentVersion.semVer);
      }

      // 3. Parse release notes (List or newline-delimited text)
      List<String> releaseNotes = [];
      final rawNotes = data['release_notes'] ?? data['notes'] ?? data['changelog'];
      if (rawNotes is List) {
        releaseNotes = rawNotes.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      } else if (rawNotes is String && rawNotes.isNotEmpty) {
        releaseNotes = rawNotes
            .split('\n')
            .map((s) => s.replaceAll(RegExp(r'^[•\-\*]\s*'), '').trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }

      final storeUrl = (data['play_store_url'] ?? data['store_url'] ?? fallbackStoreUrl).toString();
      final title = data['title'] as String?;
      final message = data['message'] ?? data['description'] as String?;

      // 4. Construct and evaluate UpdateInfo
      return UpdateInfo.evaluate(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        minRequiredVersion: minRequiredVersion,
        forceFlagFromServer: forceFlag,
        title: title,
        message: message,
        releaseNotes: releaseNotes,
        storeUrl: storeUrl,
        rawPayload: data,
      );
    } catch (e) {
      // Safe Fail-Open: Network failure or missing table must never block app launch
      AppLogger.debug('SupabaseUpdateSource', 'Error fetching remote update config: $e');
      return null;
    }
  }

  /// Silently notifies the server of a newly published build to auto-advance latest_version.
  void _autoSyncNewVersionToBackend(String semVer) {
    _supabase.rpc('fn_sync_app_version', params: {'p_current_version': semVer}).then((res) {
      AppLogger.debug('SupabaseUpdateSource', 'Auto-synced app version $semVer to backend: $res');
    }).catchError((err) {
      AppLogger.debug('SupabaseUpdateSource', 'Silent auto-sync skipped: $err');
    });
  }
}
