import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/services/compatibility_service.dart';

void main() {
  group('Matchmaking Performance Benchmarks', () {
    test('Benchmark: 10,000 Profile Comparisons', () {
      final now = DateTime.now();
      final me = ProfileModel(
        id: 'me',
        userId: 'u1',
        fullName: 'Rahul Rathod',
        surname: 'Rathod',
        gender: 'Male',
        age: 28,
        height: "5'8\"",
        district: 'Pune',
        state: 'Maharashtra',
        education: 'BE',
        profession: 'Software Engineer',
        createdAt: now,
        updatedAt: now,
      );

      // Generate 10,000 unique profiles
      final List<ProfileModel> others = List.generate(10000, (i) {
        return ProfileModel(
          id: 'them_$i',
          userId: 'user_$i',
          fullName: 'Profile $i',
          surname: 'Surname $i',
          gender: i % 2 == 0 ? 'Female' : 'Male',
          age: 20 + (i % 30),
          height: "5'${5 + (i % 5)}\"",
          district: i % 10 == 0 ? 'Pune' : 'Mumbai',
          state: 'Maharashtra',
          education: i % 5 == 0 ? 'BE' : 'MBA',
          profession: i % 4 == 0 ? 'Software Engineer' : 'Doctor',
          createdAt: now,
          updatedAt: now,
        );
      });

      final Stopwatch stopwatch = Stopwatch()..start();

      int matchCount = 0;
      for (final them in others) {
        final score = CompatibilityService.calculateMatchingScore(me, them);
        if (score > 70) {
          matchCount++;
        }
      }

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;
      
      debugPrint('--- Performance Report ---');
      debugPrint('Total Profiles Compared: ${others.length}');
      debugPrint('Total High-Quality Matches (>70%): $matchCount');
      debugPrint('Total Time: ${elapsedMs}ms');
      debugPrint('Avg Time per Match: ${elapsedMs / others.length}ms');
      debugPrint('Extrapolated 1 Million matches: ${elapsedMs * 100}ms (${(elapsedMs * 100) / 1000}s)');
      debugPrint('--------------------------');

      // Assert that it's reasonably fast (less than 100ms for 10k matches)
      expect(elapsedMs, lessThan(100), reason: 'Performance regressed!');
    });

    test('Benchmark: Matrix Matching (100x100)', () {
      final now = DateTime.now();
      final groupA = List.generate(100, (i) => ProfileModel(
        id: 'a_$i',
        userId: 'ua_$i',
        fullName: 'User A$i',
        surname: 'Surname A$i',
        gender: 'Male',
        age: 25,
        height: "5'8\"",
        education: 'BE',
        profession: 'Engineer',
        createdAt: now,
        updatedAt: now,
      ));

      final groupB = List.generate(100, (i) => ProfileModel(
        id: 'b_$i',
        userId: 'ub_$i',
        fullName: 'User B$i',
        surname: 'Surname B$i',
        gender: 'Female',
        age: 25,
        height: "5'8\"",
        education: 'BE',
        profession: 'Engineer',
        createdAt: now,
        updatedAt: now,
      ));

      final stopwatch = Stopwatch()..start();

      for (var a in groupA) {
        for (var b in groupB) {
          CompatibilityService.calculateMatchingScore(a, b);
        }
      }

      stopwatch.stop();
      debugPrint('Matrix (100x100) Time: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });
}
