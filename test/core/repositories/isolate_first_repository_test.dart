import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/repositories/isolate_first_repository.dart';

/// Concrete test implementation of the abstract IsolateFirstRepository
class TestIsolateFirstRepository extends IsolateFirstRepository {}

void main() {
  late TestIsolateFirstRepository repo;

  setUp(() {
    repo = TestIsolateFirstRepository();
  });

  group('IsolateFirstRepository', () {
    test('mapListInBackground processes small lists on main thread', () async {
      final data = [
        {'id': 1, 'name': 'Alice'},
        {'id': 2, 'name': 'Bob'},
      ];
      final result = await repo.mapListInBackground<Map<String, dynamic>>(
        data,
        (json) => {'mapped_id': json['id'], 'mapped_name': json['name']},
      );
      expect(result.length, 2);
      expect(result[0]['mapped_id'], 1);
      expect(result[1]['mapped_name'], 'Bob');
    });

    test('mapListInBackground handles empty list', () async {
      final result = await repo.mapListInBackground<String>(
        [],
        (json) => json['value'] as String,
      );
      expect(result, isEmpty);
    });

    test('mapListInBackground preserves type safety', () async {
      final data = [
        {'value': 'x'},
        {'value': 'y'},
      ];
      final result = await repo.mapListInBackground<String>(
        data,
        (json) => json['value'] as String,
      );
      expect(result, isA<List<String>>());
      expect(result, ['x', 'y']);
    });
  });
}
