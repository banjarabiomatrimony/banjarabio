import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/filter_criteria.dart';

void main() {
  group('FilterCriteria - Constructor', () {
    test('default constructor creates instance with all null fields', () {
      const criteria = FilterCriteria();

      expect(criteria.minAge, isNull);
      expect(criteria.maxAge, isNull);
      expect(criteria.gender, isNull);
      expect(criteria.education, isNull);
      expect(criteria.profession, isNull);
      expect(criteria.state, isNull);
      expect(criteria.district, isNull);
      expect(criteria.taluka, isNull);
      expect(criteria.hasPhoto, isNull);
      expect(criteria.maritalStatus, isNull);
      expect(criteria.searchQuery, isNull);
    });

    test('constructor with all fields set', () {
      const criteria = FilterCriteria(
        minAge: 18,
        maxAge: 30,
        gender: 'Female',
        education: ['B.E.', 'M.B.B.S'],
        profession: ['Engineer'],
        state: 'Maharashtra',
        district: 'Pune',
        taluka: 'Haveli',
        hasPhoto: true,
        maritalStatus: 'Never Married',
        searchQuery: 'Rathod',
      );

      expect(criteria.minAge, 18);
      expect(criteria.maxAge, 30);
      expect(criteria.gender, 'Female');
      expect(criteria.education, ['B.E.', 'M.B.B.S']);
      expect(criteria.profession, ['Engineer']);
      expect(criteria.state, 'Maharashtra');
      expect(criteria.district, 'Pune');
      expect(criteria.taluka, 'Haveli');
      expect(criteria.hasPhoto, true);
      expect(criteria.maritalStatus, 'Never Married');
      expect(criteria.searchQuery, 'Rathod');
    });
  });

  group('FilterCriteria - copyWith', () {
    test('copyWith with no args returns identical values', () {
      const original = FilterCriteria(minAge: 20, gender: 'Male');
      final copy = original.copyWith();

      expect(copy.minAge, 20);
      expect(copy.gender, 'Male');
      expect(copy.maxAge, isNull);
    });

    test('copyWith overrides specified fields and keeps others', () {
      const original = FilterCriteria(
        minAge: 20,
        maxAge: 30,
        gender: 'Male',
        state: 'Maharashtra',
      );
      final copy = original.copyWith(minAge: 25, state: 'Karnataka');

      expect(copy.minAge, 25);
      expect(copy.maxAge, 30);
      expect(copy.gender, 'Male');
      expect(copy.state, 'Karnataka');
    });
  });

  group('FilterCriteria - isEmpty', () {
    test('isEmpty returns true when all fields are null', () {
      const criteria = FilterCriteria();

      expect(criteria.isEmpty, true);
    });

    test('isEmpty returns false when minAge is set', () {
      const criteria = FilterCriteria(minAge: 18);

      expect(criteria.isEmpty, false);
    });

    test('isEmpty returns false when gender is set', () {
      const criteria = FilterCriteria(gender: 'Male');

      expect(criteria.isEmpty, false);
    });

    test('isEmpty returns true when education is empty list', () {
      const criteria = FilterCriteria(education: []);

      expect(criteria.isEmpty, true);
    });

    test('isEmpty returns false when education has items', () {
      const criteria = FilterCriteria(education: ['B.E.']);

      expect(criteria.isEmpty, false);
    });

    test('isEmpty returns true when profession is empty list', () {
      const criteria = FilterCriteria(profession: []);

      expect(criteria.isEmpty, true);
    });

    test('isEmpty returns true when searchQuery is empty string', () {
      const criteria = FilterCriteria(searchQuery: '');

      expect(criteria.isEmpty, true);
    });

    test('isEmpty returns false when searchQuery is non-empty', () {
      const criteria = FilterCriteria(searchQuery: 'test');

      expect(criteria.isEmpty, false);
    });

    test('isEmpty returns false when hasPhoto is set', () {
      const criteria = FilterCriteria(hasPhoto: true);

      expect(criteria.isEmpty, false);
    });

    test('isEmpty returns false when district is set', () {
      const criteria = FilterCriteria(district: 'Pune');

      expect(criteria.isEmpty, false);
    });
  });
}
