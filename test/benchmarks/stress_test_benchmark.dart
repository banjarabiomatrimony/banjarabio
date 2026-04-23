import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/profile_model.dart';

void main() {
  group('Stress Test: High-Scale Profile Enrichment', () {
    test('Benchmark: Map 1,000 Photos to 1,000 Profiles', () {
      final now = DateTime.now();
      
      // 1. Generate 1,000 Profiles
      final profiles = List.generate(1000, (i) => ProfileModel(
        id: 'p_$i',
        userId: 'u_$i',
        fullName: 'User $i',
        surname: 'Surname $i',
        gender: i % 2 == 0 ? 'Male' : 'Female',
        age: 20 + (i % 30),
        height: "5'8\"",
        education: 'BE',
        profession: 'Engineer',
        createdAt: now,
        updatedAt: now,
      ));

      // 2. Generate 1,000 Photo objects
      final photoMap = {
        for (var i = 0; i < 1000; i++)
          'p_$i': PhotoModel(
            id: 'photo_$i',
            profileId: 'p_$i',
            storagePath: 'path/$i.jpg',
            publicUrl: 'https://example.com/$i.jpg',
            uploadedAt: now,
          )
      };

      final stopwatch = Stopwatch()..start();

      // 3. Simulate ProfileRepository.getProfiles enrichment logic
      final enrichedProfiles = profiles.map((p) {
        final photo = photoMap[p.id];
        return photo != null ? p.copyWith(photos: [photo]) : p;
      }).toList();

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMicroseconds / 1000;

      debugPrint('Enrichment Time (1,000 items): ${elapsed}ms');
      
      // Expect sub-10ms for simple mapping (Dart is fast)
      expect(elapsed, lessThan(10));
      expect(enrichedProfiles.first.photos.length, 1);
    });

    test('Benchmark: Isolate Parsing simulation (10,000 profiles)', () {
      final now = DateTime.now();
      
      // Simulate large JSON payload
      final rawData = List.generate(10000, (i) => {
        'id': 'p_$i',
        'user_id': 'u_$i',
        'full_name': 'First Last $i',
        'surname': 'Surname $i',
        'gender': 'Female',
        'age': 25,
        'height': "5'5\"",
        'education': 'PhD',
        'profession': 'Scientist',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      final stopwatch = Stopwatch()..start();

      // Simulating mapListInBackground on main thread for baseline
      final profiles = rawData.map((json) => ProfileModel.fromJson(json)).toList();

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;

      debugPrint('Parse Time (10,000 profiles on Main Thread): ${elapsed}ms');
      
      // On main thread 10,000 complex objects might take 50-200ms
      // This proves why we MUST use isolates above 1,000 items.
      if (elapsed > 16) {
        debugPrint('⚠️ Warning: Main thread parsing exceeded 1 frame (16ms). Isolates ARE MANDATORY at this scale.');
      }
      
      expect(profiles.length, 10000);
    });
  });
}
