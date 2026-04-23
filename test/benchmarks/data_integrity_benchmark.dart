import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/sibling_model.dart';
import 'dart:convert';

void main() {
  group('SessionManager Data Integrity & Serialization', () {
    test('Verify SiblingModel Serialization survives Json cycle', () {
      final siblings = [
        const SiblingModel(position: 1, relation: 'Brother', isMarried: true),
        const SiblingModel(position: 2, relation: 'Sister', isMarried: false),
      ];

      final formData = {
        'name': 'Rahul',
        'siblings': siblings,
        'dateOfBirth': DateTime(1995, 5, 20),
      };

      // Simulate IsolateManager._encodeJsonSafe logic
      final processedData = <String, dynamic>{};
      formData.forEach((key, value) {
        if (value is DateTime) {
          processedData[key] = value.toIso8601String();
        } else {
          processedData[key] = value;
        }
      });

      // jsonEncode should call toJson() on SiblingModel objects
      final jsonString = jsonEncode(processedData);
      
      // Decode
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      
      // Verify data survives
      expect(decoded['name'], 'Rahul');
      expect(decoded['dateOfBirth'], '1995-05-20T00:00:00.000');
      
      final rawSiblings = decoded['siblings'] as List;
      expect(rawSiblings.length, 2);
      expect(rawSiblings[0]['relation'], 'Brother');
      expect(rawSiblings[1]['is_married'], false);

      // Verify restoration logic (simulating BiodataCreationScreen._populateFormFromMap)
      final List restoredSiblings = (rawSiblings)
          .map((s) => SiblingModel.fromJson(s as Map<String, dynamic>))
          .toList();
      
      expect(restoredSiblings[0].relation, 'Brother');
      expect(restoredSiblings[1].position, 2);
    });

    test('Benchmark: Large Form Serialization (1000 fields)', () {
      // Create a massive form data map
      final largeData = <String, dynamic>{
        'name': 'Test User',
        'bio': 'A very long biography' * 100,
        'metadata': List.generate(1000, (i) => 'Meta data point $i'),
        'siblings': List.generate(50, (i) => SiblingModel(position: i, relation: 'Sibling $i', isMarried: i % 2 == 0)),
      };

      final stopwatch = Stopwatch()..start();
      
      final processedData = <String, dynamic>{};
      largeData.forEach((key, value) {
        if (value is DateTime) {
          processedData[key] = value.toIso8601String();
        } else {
          processedData[key] = value;
        }
      });
      
      final jsonString = jsonEncode(processedData);
      stopwatch.stop();
      
      debugPrint('Large Form Serialization Time: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('JSON String Size: ${jsonString.length / 1024} KB');
      
      expect(stopwatch.elapsedMilliseconds, lessThan(50), reason: 'Serialization too slow');
    });
  });
}
