import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/success_story_model.dart';

void main() {
  group('SuccessStoryModel Tests', () {
    test('calculateRefundAmount returns correct 25% for digital25', () {
      final story = SuccessStoryModel(
        id: '1',
        userId: 'user1',
        weddingDate: DateTime.now(),
        subscriptionAmount: 10000.0,
        type: MarriageRewardType.digital25,
        createdAt: DateTime.now(),
      );

      expect(story.calculateRefundAmount(), 2500.0);
    });

    test('calculateRefundAmount returns correct 35% for fullInvitation35', () {
      final story = SuccessStoryModel(
        id: '1',
        userId: 'user1',
        weddingDate: DateTime.now(),
        subscriptionAmount: 10000.0,
        type: MarriageRewardType.fullInvitation35,
        createdAt: DateTime.now(),
      );

      expect(story.calculateRefundAmount(), 3500.0);
    });

    test('fromJson and toJson are consistent', () {
      final now = DateTime.now().toUtc();
      final story = SuccessStoryModel(
        id: '1',
        userId: 'user1',
        partnerName: 'Partner',
        storyText: 'Our story',
        instagramLink: 'https://instagr.am/reel',
        invitationCardUrl: 'https://image.com/card.jpg',
        weddingDate: now,
        subscriptionAmount: 15000.0,
        type: MarriageRewardType.fullInvitation35,
        createdAt: now,
      );

      final json = story.toJson();
      // Add id which is not in toJson usually for inserts but let's check parsing
      json['id'] = '1';
      json['created_at'] = now.toIso8601String();

      final parsed = SuccessStoryModel.fromJson(json);

      expect(parsed.id, story.id);
      expect(parsed.subscriptionAmount, story.subscriptionAmount);
      expect(parsed.type, story.type);
      expect(parsed.weddingDate.toIso8601String(), story.weddingDate.toIso8601String());
    });
  });
}
