import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/isolate_manager.dart';

void main() {
  group('IsolateManager', () {
    test('instance is a singleton', () {
      final a = IsolateManager.instance;
      final b = IsolateManager.instance;
      expect(identical(a, b), true);
    });

    group('mapListInstance — small list optimization', () {
      test('processes lists with fewer than 10 items on main thread', () async {
        final data = List.generate(5, (i) => {'id': i, 'name': 'Item $i'});
        final result = await IsolateManager.instance.mapListInstance<Map<String, dynamic>>(
          data,
          (json) => {'mapped_id': json['id'], 'mapped_name': json['name']},
        );
        expect(result.length, 5);
        expect(result[0]['mapped_id'], 0);
        expect(result[4]['mapped_name'], 'Item 4');
      });

      test('handles empty list gracefully', () async {
        final result = await IsolateManager.instance.mapListInstance<String>(
          [],
          (json) => json['value'] as String,
        );
        expect(result, isEmpty);
      });

      test('correctly types output list', () async {
        final data = [
          {'value': 'hello'},
          {'value': 'world'},
        ];
        final result = await IsolateManager.instance.mapListInstance<String>(
          data,
          (json) => json['value'] as String,
        );
        expect(result, isA<List<String>>());
        expect(result, ['hello', 'world']);
      });
    });

    group('mapList static helper', () {
      test('delegates to mapListInstance', () async {
        final data = [
          {'n': 1},
          {'n': 2},
          {'n': 3},
        ];
        final result = await IsolateManager.mapList<int>(
          data,
          (json) => (json['n'] as num).toInt(),
        );
        expect(result, [1, 2, 3]);
      });
    });

    group('dispose', () {
      test('dispose does not crash when called before init', () {
        // Should be safe to call dispose without prior initialization
        final manager = IsolateManager.instance;
        expect(() => manager.dispose(), returnsNormally);
      });
    });
  });
}
