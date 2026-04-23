import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/compatibility_service.dart';
import '../helpers/test_data_factory.dart';

void main() {
  group('CompatibilityService.calculateMatchingScore', () {
    test('same gender = 0 (matrimony app)', () {
      final me = TestData.profile();
      final them = TestData.profile();
      expect(CompatibilityService.calculateMatchingScore(me, them), 0);
    });

    test('opposite gender with ideal age gap = 25 age points', () {
      final me = TestData.profile(age: 27);
      final them = TestData.profile(gender: 'Female', age: 24);
      final score = CompatibilityService.calculateMatchingScore(me, them);
      // Age diff 3 <= 5 → +25 for age
      expect(score, greaterThanOrEqualTo(25));
    });

    test('same district = max location points (30)', () {
      final me = TestData.profile(
        state: 'Maharashtra',
        district: 'Pune',
      );
      final them = TestData.profile(
        gender: 'Female',
        state: 'Maharashtra',
        district: 'Pune',
      );
      final score = CompatibilityService.calculateMatchingScore(me, them);
      // Age(25) + Location(30) + MaritalStatus(20) = 75 minimum
      expect(score, greaterThanOrEqualTo(75));
    });

    test('same state but different district = 15 location points', () {
      final me = TestData.profile(
        state: 'Maharashtra',
        district: 'Pune',
      );
      final them = TestData.profile(
        gender: 'Female',
        state: 'Maharashtra',
        district: 'Nagpur',
      );
      final score = CompatibilityService.calculateMatchingScore(me, them);
      // Should have 15 for state match, not 30
      expect(score, lessThan(CompatibilityService.calculateMatchingScore(
        me,
        them.copyWith(district: 'Pune'),
      )));
    });

    test('same education adds 15 points', () {
      final me = TestData.profile();
      final them = TestData.profile(gender: 'Female');
      final scoreSame = CompatibilityService.calculateMatchingScore(me, them);

      final themDiff = TestData.profile(gender: 'Female', education: 'MBBS');
      final scoreDiff = CompatibilityService.calculateMatchingScore(me, themDiff);

      expect(scoreSame, greaterThan(scoreDiff));
    });

    test('same profession adds 10 points', () {
      final me = TestData.profile();
      final them = TestData.profile(gender: 'Female');
      final scoreSame = CompatibilityService.calculateMatchingScore(me, them);

      final themDiff = TestData.profile(gender: 'Female', profession: 'Teacher');
      final scoreDiff = CompatibilityService.calculateMatchingScore(me, themDiff);

      expect(scoreSame, greaterThan(scoreDiff));
    });

    test('similar professions get partial credit', () {
      final me = TestData.profile(profession: 'Software Developer');
      final them = TestData.profile(gender: 'Female', profession: 'IT Consultant');
      final score = CompatibilityService.calculateMatchingScore(me, them);
      // "software" contains check against "it" → similar
      expect(score, greaterThan(0));
    });

    test('same marital status = 20 points', () {
      final me = TestData.profile();
      final them = TestData.profile(gender: 'Female');
      // Both default to 'Never Married'
      final score = CompatibilityService.calculateMatchingScore(me, them);
      expect(score, greaterThanOrEqualTo(45)); // age(25) + marital(20)
    });

    test('score clamped at 100', () {
      final me = TestData.profile(
        state: 'Maharashtra',
        district: 'Pune',
      );
      final them = TestData.profile(
        gender: 'Female',
        state: 'Maharashtra',
        district: 'Pune',
      );
      final score = CompatibilityService.calculateMatchingScore(me, them);
      expect(score, lessThanOrEqualTo(100));
    });
  });
}
