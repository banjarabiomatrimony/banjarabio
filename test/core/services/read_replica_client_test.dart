import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/read_replica_client.dart';

void main() {
  group('ReadReplicaClient', () {
    test('enableEmergencyReadOnlyMode does not throw', () {
      expect(() => ReadReplicaClient.enableEmergencyReadOnlyMode(), returnsNormally);
    });

    // Note: getClient and initialize depend on Supabase.instance and
    // rootBundle which require full app bootstrap. Those are covered
    // by integration/contract tests. Here we verify the static API surface.

    test('static methods are accessible', () {
      // Verify the class API is available without runtime errors
      expect(ReadReplicaClient.getClient, isA<Function>());
      expect(ReadReplicaClient.initialize, isA<Function>());
      expect(ReadReplicaClient.enableEmergencyReadOnlyMode, isA<Function>());
    });
  });
}
