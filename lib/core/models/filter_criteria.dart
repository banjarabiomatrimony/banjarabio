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

  // New Banjara & Expanded Matrimonial Filters
  final List<String>? gotra;
  final String? minHeight;
  final String? maxHeight;
  final List<String>? annualIncome;
  final List<String>? familyType;
  final List<String>? familyStatus;
  final List<String>? profileCreatedBy;
  final bool? isVerified;
  final bool? isCommunityTrusted;
  final bool? isDisabled;

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
    this.gotra,
    this.minHeight,
    this.maxHeight,
    this.annualIncome,
    this.familyType,
    this.familyStatus,
    this.profileCreatedBy,
    this.isVerified,
    this.isCommunityTrusted,
    this.isDisabled,
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
    List<String>? gotra,
    String? minHeight,
    String? maxHeight,
    List<String>? annualIncome,
    List<String>? familyType,
    List<String>? familyStatus,
    List<String>? profileCreatedBy,
    bool? isVerified,
    bool? isCommunityTrusted,
    bool? isDisabled,
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
      gotra: gotra ?? this.gotra,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      annualIncome: annualIncome ?? this.annualIncome,
      familyType: familyType ?? this.familyType,
      familyStatus: familyStatus ?? this.familyStatus,
      profileCreatedBy: profileCreatedBy ?? this.profileCreatedBy,
      isVerified: isVerified ?? this.isVerified,
      isCommunityTrusted: isCommunityTrusted ?? this.isCommunityTrusted,
      isDisabled: isDisabled ?? this.isDisabled,
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
      (searchQuery == null || searchQuery!.isEmpty) &&
      (gotra == null || gotra!.isEmpty) &&
      minHeight == null &&
      maxHeight == null &&
      (annualIncome == null || annualIncome!.isEmpty) &&
      (familyType == null || familyType!.isEmpty) &&
      (familyStatus == null || familyStatus!.isEmpty) &&
      (profileCreatedBy == null || profileCreatedBy!.isEmpty) &&
      isVerified == null &&
      isCommunityTrusted == null &&
      isDisabled == null;
}
