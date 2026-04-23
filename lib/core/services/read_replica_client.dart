import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🌐 PRO SCALE: Read-Replica Routing Utility
/// At 10M DAU, a single primary DB cannot handle all discovery reads.
/// This utility routes heavy SELECT queries to read replicas.
class ReadReplicaClient {
  static SupabaseClient? _readOnlyClient;
  static bool _useReplica = false;

  /// Initialize the Read-only client pool
  static Future<void> initialize() async {
    try {
      final String envString = await rootBundle.loadString('assets/env.json');
      final Map<String, dynamic> env = json.decode(envString);
      
      final String? replicaUrl = env['SUPABASE_REPLICA_URL']; // Optional replica URL
      final String anonKey = env['SUPABASE_ANON_KEY'] ?? '';

      if (replicaUrl != null && replicaUrl.isNotEmpty) {
        _readOnlyClient = SupabaseClient(replicaUrl, anonKey);
        _useReplica = true;
      }
    } catch (_) {
      // Fallback to primary if replica config is missing
      _useReplica = false;
    }
  }

  /// Get the appropriate client for the operation.
  /// [forcePrimary] ensures the query goes to the write-capable primary DB.
  static SupabaseClient getClient({bool forcePrimary = false}) {
    if (forcePrimary || !_useReplica || _readOnlyClient == null) {
      return Supabase.instance.client;
    }
    return _readOnlyClient!;
  }

  /// 🛡️ Circuit Breaker: If primary is failing, switch all reads to replicas
  static void enableEmergencyReadOnlyMode() {
    _useReplica = true;
  }
}
