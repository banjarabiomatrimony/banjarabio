import 'package:flutter/widgets.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_info.dart';

/// ⚙️ [UpdateEngine]
///
/// Strategy interface for executing the actual app update.
/// Allows swapping between Google Play In-App Updates, Store Deep-links, or Custom APK downloads.
abstract class UpdateEngine {
  /// Executes the update procedure.
  /// Returns `true` if the update was launched or triggered successfully.
  Future<bool> executeUpdate(BuildContext context, UpdateInfo info);
}
