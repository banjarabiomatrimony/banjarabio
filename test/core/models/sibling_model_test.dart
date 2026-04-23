import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/sibling_model.dart';

void main() {
  group('SiblingModel', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'position': 2,
        'relation': 'Elder Brother',
        'is_married': true,
      };
      final sibling = SiblingModel.fromJson(json);
      expect(sibling.position, 2);
      expect(sibling.relation, 'Elder Brother');
      expect(sibling.isMarried, true);
    });

    test('fromJson handles null/missing fields with defaults', () {
      final json = <String, dynamic>{};
      final sibling = SiblingModel.fromJson(json);
      expect(sibling.position, 1);
      expect(sibling.relation, 'Self');
      expect(sibling.isMarried, false);
    });

    test('fromJson handles partial data', () {
      final json = {'position': 3};
      final sibling = SiblingModel.fromJson(json);
      expect(sibling.position, 3);
      expect(sibling.relation, 'Self');
      expect(sibling.isMarried, false);
    });

    test('toJson produces correct map', () {
      const sibling = SiblingModel(
        position: 1,
        relation: 'Younger Sister',
        isMarried: false,
      );
      final json = sibling.toJson();
      expect(json['position'], 1);
      expect(json['relation'], 'Younger Sister');
      expect(json['is_married'], false);
    });

    test('roundtrip fromJson -> toJson preserves data', () {
      const original = SiblingModel(
        position: 4,
        relation: 'Elder Sister',
        isMarried: true,
      );
      final recreated = SiblingModel.fromJson(original.toJson());
      expect(recreated.position, original.position);
      expect(recreated.relation, original.relation);
      expect(recreated.isMarried, original.isMarried);
    });
  });
}
