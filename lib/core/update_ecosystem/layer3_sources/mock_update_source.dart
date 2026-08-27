import 'package:banjarabio/core/update_ecosystem/layer1_models/app_version.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_info.dart';
import 'package:banjarabio/core/update_ecosystem/layer2_contracts/update_config_source.dart';

/// 🧪 [MockUpdateSource]
///
/// Deterministic update source for automated testing, widget previews,
/// and local developer verification.
class MockUpdateSource implements UpdateConfigSource {
  final AppVersion latestVersion;
  final AppVersion minRequiredVersion;
  final bool forceUpdate;
  final String title;
  final String message;
  final List<String> releaseNotes;
  final String storeUrl;
  final bool shouldSimulateError;

  const MockUpdateSource({
    this.latestVersion = const AppVersion(major: 1, minor: 4, rawVersion: '1.4.0'),
    this.minRequiredVersion = const AppVersion(major: 1, rawVersion: '1.0.0'),
    this.forceUpdate = false,
    this.title = 'Exciting New Update Available',
    this.message = 'We have introduced major performance enhancements and new biodata templates.',
    this.releaseNotes = const [
      '⚡ 3x Faster Biodata PDF Generation',
      '🎨 10 Brand New Premium Biodata Themes',
      '🔒 Enhanced Privacy Controls & Vouch Security',
    ],
    this.storeUrl = 'https://play.google.com/store/apps/details?id=com.avishio.banjarabio',
    this.shouldSimulateError = false,
  });

  @override
  Future<UpdateInfo?> fetchUpdateInfo(AppVersion currentVersion) async {
    if (shouldSimulateError) return null;

    return UpdateInfo.evaluate(
      currentVersion: currentVersion,
      latestVersion: latestVersion,
      minRequiredVersion: minRequiredVersion,
      forceFlagFromServer: forceUpdate,
      title: title,
      message: message,
      releaseNotes: releaseNotes,
      storeUrl: storeUrl,
    );
  }
}
