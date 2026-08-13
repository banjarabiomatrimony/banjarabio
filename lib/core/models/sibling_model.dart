import 'package:meta/meta.dart';

/// Model for individual sibling details
@immutable
class SiblingModel {
  final int position;
  final String relation;
  final bool isMarried;

  const SiblingModel({
    required this.position,
    required this.relation,
    required this.isMarried,
  });

  factory SiblingModel.fromJson(Map<String, dynamic> json) {
    return SiblingModel(
      position: (json['position'] as num?)?.toInt() ?? 1,
      relation: json['relation']?.toString() ?? 'Self',
      isMarried: json['is_married'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'relation': relation,
      'is_married': isMarried,
    };
  }
}
