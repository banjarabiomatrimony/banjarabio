import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/filter_criteria.dart';

void main() {
  group('FilterCriteria.isEmpty', () {
    test('all null fields = empty', () {
      const filter = FilterCriteria();
      expect(filter.isEmpty, true);
    });

    test('single non-null field = not empty', () {
      const filter = FilterCriteria(minAge: 21);
      expect(filter.isEmpty, false);
    });

    test('empty lists count as empty', () {
      const filter = FilterCriteria(education: [], profession: []);
      expect(filter.isEmpty, true);
    });

    test('non-empty list = not empty', () {
      const filter = FilterCriteria(education: ['B.Tech']);
      expect(filter.isEmpty, false);
    });

    test('only searchQuery empty string = empty', () {
      const filter = FilterCriteria(searchQuery: '');
      expect(filter.isEmpty, true);
    });

    test('non-empty searchQuery = not empty', () {
      const filter = FilterCriteria(searchQuery: 'Rahul');
      expect(filter.isEmpty, false);
    });
  });

  group('FilterCriteria.copyWith', () {
    test('overrides specific fields', () {
      const original = FilterCriteria(minAge: 21, maxAge: 30, gender: 'Male');
      final modified = original.copyWith(minAge: 25);

      expect(modified.minAge, 25);
      expect(modified.maxAge, 30);
      expect(modified.gender, 'Male');
    });

    test('keeps all unchanged fields intact', () {
      const original = FilterCriteria(
        state: 'Maharashtra',
        district: 'Pune',
        hasPhoto: true,
      );
      final modified = original.copyWith(taluka: 'Haveli');

      expect(modified.state, 'Maharashtra');
      expect(modified.district, 'Pune');
      expect(modified.hasPhoto, true);
      expect(modified.taluka, 'Haveli');
    });
  });
}
