import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/providers/profile_providers.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/backend_response.dart';

class MockProfileRepository extends ProfileRepository {
  MockProfileRepository() : super.internal();

  @override
  Future<BackendResponse<ProfileModel?>> getOwnProfile({bool forceRefresh = false}) async {
    return BackendResponse.success(
      ProfileModel(
        id: 'mock_own_id',
        userId: 'auth_mock_id',
        fullName: 'Test User',
        surname: 'Rathod',
        gender: 'Male',
        age: 26,
        height: "5'8\"",
        education: 'B.Tech',
        profession: 'Engineer',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  }
}

void main() {
  group('ProfileProviders Tests', () {
    test('ownProfileProvider returns mock profile when overridden', () async {
      final container = ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(MockProfileRepository()),
        ],
      );
      addTearDown(container.dispose);

      final profile = await container.read(ownProfileProvider.future);
      expect(profile, isNotNull);
      expect(profile?.fullName, equals('Test User'));
      expect(profile?.id, equals('mock_own_id'));
    });
  });
}
