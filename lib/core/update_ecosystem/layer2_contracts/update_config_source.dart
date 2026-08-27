import 'package:banjarabio/core/update_ecosystem/layer1_models/app_version.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_info.dart';

/// 🔌 [UpdateConfigSource]
///
/// Strategy interface for retrieving remote version and update metadata.
/// Can be implemented by Supabase, Firebase Remote Config, AWS, or custom REST APIs.
abstract class UpdateConfigSource {
  /// Fetches the latest version requirements and metadata from the backend.
  /// Returns null if the backend is unreachable or offline (fails open safely).
  Future<UpdateInfo?> fetchUpdateInfo(AppVersion currentVersion);
}
