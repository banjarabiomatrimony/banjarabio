import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/app_version.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_config.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_info.dart';
import 'package:banjarabio/core/update_ecosystem/layer2_contracts/update_engine.dart';
import 'package:banjarabio/core/update_ecosystem/layer4_engines/store_redirect_engine.dart';
import 'package:banjarabio/core/update_ecosystem/layer5_storage/update_cooldown_manager.dart';
import 'package:banjarabio/core/update_ecosystem/layer6_ui/force_update_dialog.dart';
import 'package:banjarabio/core/update_ecosystem/layer6_ui/soft_update_sheet.dart';

/// 🚀 [AppUpdateManager]
///
/// Master Facade / Orchestrator for the entire In-App Update Ecosystem.
/// Provides a single-point, thread-safe, 0-crash API for version checking,
/// cooldown management, and UI presentation.
class AppUpdateManager {
  static final AppUpdateManager _instance = AppUpdateManager._internal();
  factory AppUpdateManager() => _instance;
  static AppUpdateManager get instance => _instance;
  AppUpdateManager._internal();

  AppUpdateConfig? _config;
  UpdateCooldownManager _cooldownManager = const UpdateCooldownManager();
  UpdateEngine _engine = const StoreRedirectEngine();
  AppVersion? _cachedCurrentVersion;
  bool _isChecking = false;

  /// Synchronous live version string resolved directly from the operating system build.
  static String get currentVersionString =>
      _instance._cachedCurrentVersion?.toString() ?? '1.3.3+41';

  /// Synchronous live [AppVersion] model resolved from the operating system build.
  static AppVersion get currentAppVersion =>
      _instance._cachedCurrentVersion ??
      const AppVersion(major: 1, minor: 3, patch: 3, buildNumber: 41, rawVersion: '1.3.3+41');

  /// Sets or overrides the cached version (useful for tests and previews).
  static void setCachedVersionForTesting(AppVersion version) {
    _instance._cachedCurrentVersion = version;
  }

  /// Initializes the update manager with configuration options.
  Future<void> initialize({
    required AppUpdateConfig config,
    UpdateCooldownManager? cooldownManager,
  }) async {
    _config = config;
    _cooldownManager = cooldownManager ?? const UpdateCooldownManager();
    _engine = config.engine ?? const StoreRedirectEngine();

    // Eagerly resolve live version from OS binary during startup
    await getCurrentVersion();
    AppLogger.debug('AppUpdateManager', 'Initialized successfully for version: $_cachedCurrentVersion');
  }

  /// Resolves current installed application version
  Future<AppVersion> getCurrentVersion() async {
    if (_cachedCurrentVersion != null) return _cachedCurrentVersion!;

    try {
      if (_config?.currentVersionLoader != null) {
        final versionStr = await _config!.currentVersionLoader!();
        _cachedCurrentVersion = AppVersion.parse(versionStr);
        return _cachedCurrentVersion!;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final fullVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      _cachedCurrentVersion = AppVersion.parse(fullVersion);
      return _cachedCurrentVersion!;
    } catch (e) {
      AppLogger.error('AppUpdateManager', 'Failed to resolve current version: $e');
      return const AppVersion(major: 1, rawVersion: '1.0.0');
    }
  }

  /// Evaluates remote configuration against current version without showing UI.
  Future<UpdateInfo?> checkForUpdate() async {
    if (_config == null) {
      AppLogger.error('AppUpdateManager', 'Not initialized. Call initialize() first.');
      return null;
    }

    try {
      final current = await getCurrentVersion();
      final info = await _config!.source.fetchUpdateInfo(current);
      return info;
    } catch (e) {
      AppLogger.error('AppUpdateManager', 'Error checking for update: $e');
      return null;
    }
  }

  /// Checks for available updates and automatically displays the appropriate UI.
  ///
  /// - If [forceShow] is `true`, bypasses soft update cooldown (e.g. user tapped "Check for Updates" in Settings).
  /// - Returns `true` if an update modal/sheet was displayed to the user.
  Future<bool> checkAndPrompt(
    BuildContext context, {
    bool forceShow = false,
  }) async {
    if (_isChecking || _config == null) return false;
    _isChecking = true;

    try {
      final info = await checkForUpdate();
      if (info == null || !info.hasUpdate) {
        AppLogger.debug('AppUpdateManager', 'App is up to date.');
        return false;
      }

      if (!context.mounted) return false;

      // 1. Mandatory Force Gate (Critical update)
      if (info.isForceUpdate) {
        AppLogger.debug('AppUpdateManager', 'Displaying ForceUpdateDialog');
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => ForceUpdateDialog(
            info: info,
            theme: _config!.theme,
            onUpdate: () => _engine.executeUpdate(dialogContext, info),
          ),
        );
        return true;
      }

      // 2. Soft Nudge (Optional update with cooldown)
      if (info.isSoftUpdate) {
        if (!forceShow) {
          final shouldPrompt = await _cooldownManager.shouldPromptSoftUpdate(
            _config!.softUpdateCooldown,
          );
          if (!shouldPrompt) {
            AppLogger.debug('AppUpdateManager', 'Soft update skipped due to active cooldown.');
            return false;
          }
        }

        if (!context.mounted) return false;

        AppLogger.debug('AppUpdateManager', 'Displaying SoftUpdateSheet');
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) => SoftUpdateSheet(
            info: info,
            theme: _config!.theme,
            onUpdate: () {
              Navigator.of(sheetContext).pop();
              if (context.mounted) {
                _engine.executeUpdate(context, info);
              }
            },
            onDismiss: () {
              _cooldownManager.recordSoftUpdateDismissed();
              Navigator.of(sheetContext).pop();
            },
          ),
        );
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.error('AppUpdateManager', 'Failed during checkAndPrompt: $e');
      return false;
    } finally {
      _isChecking = false;
    }
  }

  /// Manually triggers the update engine with the provided [UpdateInfo].
  Future<bool> executeUpdate(BuildContext context, UpdateInfo info) async {
    return await _engine.executeUpdate(context, info);
  }
}
