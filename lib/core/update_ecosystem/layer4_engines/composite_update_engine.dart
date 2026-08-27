import 'package:flutter/widgets.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_info.dart';
import 'package:banjarabio/core/update_ecosystem/layer2_contracts/update_engine.dart';
import 'package:banjarabio/core/update_ecosystem/layer4_engines/store_redirect_engine.dart';

/// 🔀 [CompositeUpdateEngine]
///
/// Executes a primary update engine (such as Google Play In-App Updates)
/// and automatically falls back to store redirection if the primary engine fails.
class CompositeUpdateEngine implements UpdateEngine {
  final UpdateEngine? primaryEngine;
  final UpdateEngine fallbackEngine;

  const CompositeUpdateEngine({
    this.primaryEngine,
    this.fallbackEngine = const StoreRedirectEngine(),
  });

  @override
  Future<bool> executeUpdate(BuildContext context, UpdateInfo info) async {
    if (primaryEngine != null) {
      final success = await primaryEngine!.executeUpdate(context, info);
      if (success) return true;
    }
    if (!context.mounted) return false;
    return await fallbackEngine.executeUpdate(context, info);
  }
}
