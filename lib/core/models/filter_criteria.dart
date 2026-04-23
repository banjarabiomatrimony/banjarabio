import 'package:meta/meta.dart';

@immutable
class FilterCriteria {
  final int? minAge;
  final int? maxAge;
  final String? gender;
  final List<String>? education;
  final List<String>? profession;
  final String? state;
  final String? district;
  final String? taluka;
  final bool? hasPhoto;
  final String? maritalStatus;
  final String? searchQuery;

  const FilterCriteria({
    this.minAge,
    this.maxAge,
    this.gender,
    this.education,
    this.profession,
    this.state,
    this.district,
    this.taluka,
    this.hasPhoto,
    this.maritalStatus,
    this.searchQuery,
  });

  FilterCriteria copyWith({
    int? minAge,
    int? maxAge,
    String? gender,
    List<String>? education,
    List<String>? profession,
    String? state,
    String? district,
    String? taluka,
    bool? hasPhoto,
    String? maritalStatus,
    String? searchQuery,
  }) {
    return FilterCriteria(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      gender: gender ?? this.gender,
      education: education ?? this.education,
      profession: profession ?? this.profession,
      state: state ?? this.state,
      district: district ?? this.district,
      taluka: taluka ?? this.taluka,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get isEmpty =>
      minAge == null &&
      maxAge == null &&
      gender == null &&
      (education == null || education!.isEmpty) &&
      (profession == null || profession!.isEmpty) &&
      state == null &&
      district == null &&
      taluka == null &&
      hasPhoto == null &&
      maritalStatus == null &&
      (searchQuery == null || searchQuery!.isEmpty);
}
