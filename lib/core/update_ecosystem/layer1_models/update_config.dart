import 'package:banjarabio/core/update_ecosystem/layer2_contracts/update_config_source.dart';
import 'package:banjarabio/core/update_ecosystem/layer2_contracts/update_engine.dart';
import 'package:banjarabio/core/update_ecosystem/layer6_ui/update_modal_theme.dart';

/// ⚙️ [AppUpdateConfig]
///
/// Master configuration object for initializing the update ecosystem.
class AppUpdateConfig {
  /// The remote source to fetch version requirements from (e.g. Supabase, Firebase, Mock)
  final UpdateConfigSource source;

  /// The engine used to execute the update (e.g. Google Play In-App Update or Store URL Redirect)
  final UpdateEngine? engine;

  /// Custom branding and design tokens for update modals
  final UpdateModalTheme theme;

  /// Cooldown duration between soft update prompts (Default: 24 hours).
  /// Hard / Force updates ignore this cooldown.
  final Duration softUpdateCooldown;

  /// Custom function to supply current version (e.g. from package_info_plus).
  /// If null, AppUpdateManager uses default PackageInfo resolver.
  final Future<String> Function()? currentVersionLoader;

  /// Default fallback store URL for Android
  final String defaultAndroidStoreUrl;

  /// Default fallback store URL for iOS
  final String defaultIosStoreUrl;

  const AppUpdateConfig({
    required this.source,
    this.engine,
    this.theme = const UpdateModalTheme(),
    this.softUpdateCooldown = const Duration(hours: 24),
    this.currentVersionLoader,
    this.defaultAndroidStoreUrl = 'market://details?id=com.avishio.banjarabio',
    this.defaultIosStoreUrl = '',
  });
}
