import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/models/success_story_model.dart';
import 'package:banjarabio/core/repositories/success_story_repository.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  late FakeSupabaseClient fakeSupabase;
  late SuccessStoryRepository successStoryRepository;

  const testUser = User(
    id: 'user_xyz',
    appMetadata: {},
    userMetadata: {},
    aud: '',
    createdAt: '',
  );

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    SuccessStoryRepository.testClient = fakeSupabase;
    successStoryRepository = SuccessStoryRepository();
  });

  tearDown(() {
    SuccessStoryRepository.testClient = null;
  });

  group('SuccessStoryRepository Tests', () {
    test('submitSuccessStory inserts story into database table', () async {
      final story = SuccessStoryModel(
        id: 'story_1',
        userId: 'user_xyz',
        partnerName: 'Pooja',
        weddingDate: DateTime(2025, 5, 15),
        storyText: 'We met on BanjaraBio!',
        photoUrls: const ['https://example.com/photo.jpg'],
        subscriptionAmount: 499.0,
        type: MarriageRewardType.digital25,
        createdAt: DateTime.now(),
      );

      final result = await successStoryRepository.submitSuccessStory(story);
      expect(result.isSuccess, isTrue);
    });

    test('getMySubmissions returns failure when unauthenticated', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;

      final result = await successStoryRepository.getMySubmissions();
      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, equals('Not authenticated'));
    });

    test('getMySubmissions returns list of stories for authenticated user', () async {
      (fakeSupabase.auth as dynamic).mockUser = testUser;
      fakeSupabase.setTableData('success_stories', [
        {
          'id': 'story_123',
          'user_id': 'user_xyz',
          'partner_name': 'Sunita',
          'wedding_date': '2025-06-10T00:00:00.000',
          'story_text': 'Wonderful journey',
          'photo_urls': ['https://example.com/pic.jpg'],
          'subscription_amount': 999.0,
          'reward_type': 'digital25',
          'status': 'approved',
          'created_at': DateTime.now().toIso8601String(),
        }
      ]);

      final result = await successStoryRepository.getMySubmissions();
      expect(result.isSuccess, isTrue);
      expect(result.data.first.partnerName, equals('Sunita'));
    });
  });
}
