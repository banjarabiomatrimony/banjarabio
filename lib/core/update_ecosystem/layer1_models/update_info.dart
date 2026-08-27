import 'package:flutter/foundation.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/app_version.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_type.dart';

/// 📦 [UpdateInfo]
///
/// Standardized payload containing complete update metadata retrieved
/// from any remote source (Supabase, Firebase Remote Config, REST, or Mock).
@immutable
class UpdateInfo {
  final AppVersion currentVersion;
  final AppVersion latestVersion;
  final AppVersion minRequiredVersion;
  final UpdateType updateType;
  final String title;
  final String message;
  final List<String> releaseNotes;
  final String storeUrl;
  final Map<String, dynamic> rawPayload;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.minRequiredVersion,
    required this.updateType,
    required this.title,
    required this.message,
    this.releaseNotes = const [],
    required this.storeUrl,
    this.rawPayload = const {},
  });

  /// Factory constructor to evaluate version differences and create an [UpdateInfo] instance.
  factory UpdateInfo.evaluate({
    required AppVersion currentVersion,
    required AppVersion latestVersion,
    required AppVersion minRequiredVersion,
    bool forceFlagFromServer = false,
    String? title,
    String? message,
    List<String>? releaseNotes,
    required String storeUrl,
    Map<String, dynamic> rawPayload = const {},
  }) {
    UpdateType type = UpdateType.none;

    if (currentVersion < minRequiredVersion || forceFlagFromServer) {
      type = UpdateType.forceGate;
    } else if (currentVersion < latestVersion) {
      type = UpdateType.softNudge;
    }

    return UpdateInfo(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      minRequiredVersion: minRequiredVersion,
      updateType: type,
      title: title ?? (type == UpdateType.forceGate ? 'Critical Update Required' : 'New Update Available'),
      message: message ??
          (type == UpdateType.forceGate
              ? 'Please update to continue using the application securely.'
              : 'A new version is available with performance improvements and new features.'),
      releaseNotes: releaseNotes ?? const [],
      storeUrl: storeUrl,
      rawPayload: rawPayload,
    );
  }

  /// Whether an update is available (either soft or hard)
  bool get hasUpdate => updateType != UpdateType.none;

  /// Whether this update is a mandatory force gate
  bool get isForceUpdate => updateType == UpdateType.forceGate;

  /// Whether this update is a soft nudge
  bool get isSoftUpdate => updateType == UpdateType.softNudge;

  /// Creates a copy with modified fields
  UpdateInfo copyWith({
    AppVersion? currentVersion,
    AppVersion? latestVersion,
    AppVersion? minRequiredVersion,
    UpdateType? updateType,
    String? title,
    String? message,
    List<String>? releaseNotes,
    String? storeUrl,
    Map<String, dynamic>? rawPayload,
  }) {
    return UpdateInfo(
      currentVersion: currentVersion ?? this.currentVersion,
      latestVersion: latestVersion ?? this.latestVersion,
      minRequiredVersion: minRequiredVersion ?? this.minRequiredVersion,
      updateType: updateType ?? this.updateType,
      title: title ?? this.title,
      message: message ?? this.message,
      releaseNotes: releaseNotes ?? this.releaseNotes,
      storeUrl: storeUrl ?? this.storeUrl,
      rawPayload: rawPayload ?? this.rawPayload,
    );
  }
}
