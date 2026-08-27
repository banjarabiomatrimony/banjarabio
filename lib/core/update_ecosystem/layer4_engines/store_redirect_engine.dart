import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_info.dart';
import 'package:banjarabio/core/update_ecosystem/layer2_contracts/update_engine.dart';

/// 🌐 [StoreRedirectEngine]
///
/// Universal update engine that deep-links directly to the Google Play Store
/// or Apple App Store with graceful browser fallback.
class StoreRedirectEngine implements UpdateEngine {
  const StoreRedirectEngine();

  @override
  Future<bool> executeUpdate(BuildContext context, UpdateInfo info) async {
    final rawUrl = info.storeUrl.trim();
    if (rawUrl.isEmpty) {
      AppLogger.error('StoreRedirectEngine', 'Store URL is empty. Cannot redirect.');
      return false;
    }

    try {
      final uri = Uri.parse(rawUrl);

      // 1. Attempt native market app launch (e.g. market://details?id=...)
      if (await canLaunchUrl(uri)) {
        final success = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (success) return true;
      }

      // 2. Fallback: If market:// failed, try standard web URL
      if (rawUrl.startsWith('market://details?id=')) {
        final pkgName = rawUrl.replaceFirst('market://details?id=', '');
        final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$pkgName');
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }

      return false;
    } catch (e) {
      AppLogger.error('StoreRedirectEngine', 'Failed to launch store URL ($rawUrl): $e');
      return false;
    }
  }
}
