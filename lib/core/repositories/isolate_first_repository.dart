import 'package:banjarabio/core/services/isolate_manager.dart';

/// Base repository class that enforces "Isolate-First" data mapping.
/// It automatically offloads the conversion of Supabase JSON lists
/// to background isolates, preventing main-thread ANRs (Signal 3).
abstract class IsolateFirstRepository {
  /// Offloads the mapping of a list of raw JSON objects to typed model objects.
  /// 
  /// ⚠️ IMPORTANT: [fromJson] MUST be a static or top-level function.
  /// Passing a closure (e.g., `(x) => User.fromJson(x)`) will crash the isolate.
  Future<List<T>> mapListInBackground<T>(
    List<dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    return IsolateManager.instance.mapListInstance<T>(data, fromJson);
  }
}
