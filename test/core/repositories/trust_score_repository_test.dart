import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import '../../helpers/supabase_fakes.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late FakeSupabaseClient fakeSupabase;
  late MockProfileRepository mockProfileRepository;
  late TrustScoreRepository trustScoreRepository;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    mockProfileRepository = MockProfileRepository();
    trustScoreRepository = TrustScoreRepository();
    trustScoreRepository.reset();
    trustScoreRepository.testClient = fakeSupabase;
    trustScoreRepository.testProfileRepository = mockProfileRepository;
  });

  group('TrustScoreRepository - Logic', () {
    test('calculateTrustScore return correct score based on status', () async {
      final userId = 'u1';
      final mockUser = User(
        id: userId,
        appMetadata: {},
        userMetadata: {},
        aud: '',
        createdAt: '',
      );
      (fakeSupabase.auth as dynamic).mockUser = mockUser;

      final mockProfile = ProfileModel(
        id: 'p1',
        userId: userId,
        fullName: 'Test User',
        surname: 'Surname',
        age: 25,
        gender: 'male',
        height: "5'5\"",
        education: 'Graduate',
        profession: 'Engineer',
        state: 'State',
        district: 'District',
        taluka: 'Taluka',
        profileCompletion: 100,
        phoneNumber: '1234567890',
        email: 'test@test.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockProfileRepository.getOwnProfile())
          .thenAnswer((_) async => BackendResponse.success(mockProfile));

      // Mock verification requests
      (fakeSupabase.from('verification_requests').select() as dynamic).responseData = [
        {'user_id': userId, 'verification_type': 'selfie', 'status': 'approved'},
        {'user_id': userId, 'verification_type': 'community_id', 'status': 'approved'},
        {'user_id': userId, 'verification_type': 'govt_id', 'status': 'approved'},
        {'user_id': userId, 'verification_type': 'video_bio', 'status': 'approved'},
      ];

      // Mock references
      (fakeSupabase.from('user_references').select() as dynamic).responseData = [
        {'user_id': userId, 'status': 'verified'}
      ];

      final result = await trustScoreRepository.calculateTrustScore();

      expect(result.isSuccess, true);
      // Based on TrustScoreConfig logic:
      // mobile (verified), email (verified), photo (verified), communityId (verified), govtId (verified), reference (verified)
      // videoBio (pending -> not verified), profileComplete (100 -> true)
      // Score should be high.
      expect(result.data, greaterThan(70));
    });
  });

  group('TrustScoreRepository - RPC', () {
    test('submitVerificationRequest calls correct RPC', () async {
      fakeSupabase.rpcResponse = {'status': 'success'};

      final result = await trustScoreRepository.submitVerificationRequest(
        type: 'photo',
        payload: {'image_url': 'test.png'},
      );

      expect(result.isSuccess, true);
      expect(fakeSupabase.rpcFunction, 'fn_manage_verification');
      expect(fakeSupabase.rpcParams?['action'], 'submit_request');
      expect(fakeSupabase.rpcParams?['p_payload']['type'], 'selfie');
      expect(fakeSupabase.rpcParams?['p_payload']['payload']['image_url'], 'test.png');
    });

    test('addReference calls correct RPC', () async {
       fakeSupabase.rpcResponse = {'status': 'success'};

       final result = await trustScoreRepository.addReference(
         name: 'Friend',
         phone: '9876543210',
       );

        expect(result.isSuccess, true);
        expect(fakeSupabase.rpcParams?['action'], 'add_reference');
        expect(fakeSupabase.rpcParams?['p_payload']['name'], 'Friend');
        expect(fakeSupabase.rpcParams?['p_payload']['phone'], '9876543210');
     });
  });
}
