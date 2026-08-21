import 'package:meta/meta.dart';

@immutable
class FilterCriteria {
  // ===========================================================================
  // 🟢 TIER 1: FREE / STANDARD (Basic Discovery)
  // ===========================================================================
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

  // ===========================================================================
  // 🌟 TIER 2: BVS / COMMUNITY (Customary, Lineage & Socioeconomic)
  // ===========================================================================
  final List<String>? gotra;
  final List<String>? maternalGotra;
  final List<String>? subCaste;
  final List<String>? originType;
  final String? minHeight;
  final String? maxHeight;
  final List<String>? annualIncome;
  final List<String>? educationField;
  final List<String>? familyType;
  final List<String>? familyStatus;
  final List<String>? familyValues;
  final List<String>? profileCreatedBy;
  final bool? isDisabled;

  // ===========================================================================
  // ⚡ TIER 3: SELF-SERVICE / PREMIUM (Trust, Lifestyle & Astrological)
  // ===========================================================================
  final bool? isVerified;
  final bool? isCommunityTrusted;
  final bool? isIncomeVerified;
  final List<String>? manglikStatus;
  final List<String>? rashi;
  final List<String>? nakshatra;
  final bool? hasHoroscope;
  final List<String>? employmentSector;
  final List<String>? diet;
  final List<String>? smokingHabits;
  final List<String>? drinkingHabits;
  final List<String>? relocationPreference;
  final bool? isRecentlyActive;
  final bool? isHighResponse;
  final bool? hasMultiplePhotos;

  // ===========================================================================
  // 👑 TIER 4: VIP / MATCHMAKER (Assisted, Curated & Exclusive)
  // ===========================================================================
  final bool? isDirectContactUnlocked;
  final bool? isRmHandpicked;
  final int? minGunaScore;
  final bool? isVipSpotlight;
  final List<String>? ancestralLandAcres;
  final bool? isHouseOwner;
  final bool? isFamilyVetted;
  final bool? isConfidentialMode;

  const FilterCriteria({
    // Tier 1
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

    // Tier 2
    this.gotra,
    this.maternalGotra,
    this.subCaste,
    this.originType,
    this.minHeight,
    this.maxHeight,
    this.annualIncome,
    this.educationField,
    this.familyType,
    this.familyStatus,
    this.familyValues,
    this.profileCreatedBy,
    this.isDisabled,

    // Tier 3
    this.isVerified,
    this.isCommunityTrusted,
    this.isIncomeVerified,
    this.manglikStatus,
    this.rashi,
    this.nakshatra,
    this.hasHoroscope,
    this.employmentSector,
    this.diet,
    this.smokingHabits,
    this.drinkingHabits,
    this.relocationPreference,
    this.isRecentlyActive,
    this.isHighResponse,
    this.hasMultiplePhotos,

    // Tier 4
    this.isDirectContactUnlocked,
    this.isRmHandpicked,
    this.minGunaScore,
    this.isVipSpotlight,
    this.ancestralLandAcres,
    this.isHouseOwner,
    this.isFamilyVetted,
    this.isConfidentialMode,
  });

  FilterCriteria copyWith({
    // Tier 1
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

    // Tier 2
    List<String>? gotra,
    List<String>? maternalGotra,
    List<String>? subCaste,
    List<String>? originType,
    String? minHeight,
    String? maxHeight,
    List<String>? annualIncome,
    List<String>? educationField,
    List<String>? familyType,
    List<String>? familyStatus,
    List<String>? familyValues,
    List<String>? profileCreatedBy,
    bool? isDisabled,

    // Tier 3
    bool? isVerified,
    bool? isCommunityTrusted,
    bool? isIncomeVerified,
    List<String>? manglikStatus,
    List<String>? rashi,
    List<String>? nakshatra,
    bool? hasHoroscope,
    List<String>? employmentSector,
    List<String>? diet,
    List<String>? smokingHabits,
    List<String>? drinkingHabits,
    List<String>? relocationPreference,
    bool? isRecentlyActive,
    bool? isHighResponse,
    bool? hasMultiplePhotos,

    // Tier 4
    bool? isDirectContactUnlocked,
    bool? isRmHandpicked,
    int? minGunaScore,
    bool? isVipSpotlight,
    List<String>? ancestralLandAcres,
    bool? isHouseOwner,
    bool? isFamilyVetted,
    bool? isConfidentialMode,
  }) {
    return FilterCriteria(
      // Tier 1
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

      // Tier 2
      gotra: gotra ?? this.gotra,
      maternalGotra: maternalGotra ?? this.maternalGotra,
      subCaste: subCaste ?? this.subCaste,
      originType: originType ?? this.originType,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      annualIncome: annualIncome ?? this.annualIncome,
      educationField: educationField ?? this.educationField,
      familyType: familyType ?? this.familyType,
      familyStatus: familyStatus ?? this.familyStatus,
      familyValues: familyValues ?? this.familyValues,
      profileCreatedBy: profileCreatedBy ?? this.profileCreatedBy,
      isDisabled: isDisabled ?? this.isDisabled,

      // Tier 3
      isVerified: isVerified ?? this.isVerified,
      isCommunityTrusted: isCommunityTrusted ?? this.isCommunityTrusted,
      isIncomeVerified: isIncomeVerified ?? this.isIncomeVerified,
      manglikStatus: manglikStatus ?? this.manglikStatus,
      rashi: rashi ?? this.rashi,
      nakshatra: nakshatra ?? this.nakshatra,
      hasHoroscope: hasHoroscope ?? this.hasHoroscope,
      employmentSector: employmentSector ?? this.employmentSector,
      diet: diet ?? this.diet,
      smokingHabits: smokingHabits ?? this.smokingHabits,
      drinkingHabits: drinkingHabits ?? this.drinkingHabits,
      relocationPreference: relocationPreference ?? this.relocationPreference,
      isRecentlyActive: isRecentlyActive ?? this.isRecentlyActive,
      isHighResponse: isHighResponse ?? this.isHighResponse,
      hasMultiplePhotos: hasMultiplePhotos ?? this.hasMultiplePhotos,

      // Tier 4
      isDirectContactUnlocked: isDirectContactUnlocked ?? this.isDirectContactUnlocked,
      isRmHandpicked: isRmHandpicked ?? this.isRmHandpicked,
      minGunaScore: minGunaScore ?? this.minGunaScore,
      isVipSpotlight: isVipSpotlight ?? this.isVipSpotlight,
      ancestralLandAcres: ancestralLandAcres ?? this.ancestralLandAcres,
      isHouseOwner: isHouseOwner ?? this.isHouseOwner,
      isFamilyVetted: isFamilyVetted ?? this.isFamilyVetted,
      isConfidentialMode: isConfidentialMode ?? this.isConfidentialMode,
    );
  }

  bool get isEmpty =>
      // Tier 1
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

      // Tier 2
      (gotra == null || gotra!.isEmpty) &&
      (maternalGotra == null || maternalGotra!.isEmpty) &&
      (subCaste == null || subCaste!.isEmpty) &&
      (originType == null || originType!.isEmpty) &&
      minHeight == null &&
      maxHeight == null &&
      (annualIncome == null || annualIncome!.isEmpty) &&
      (educationField == null || educationField!.isEmpty) &&
      (familyType == null || familyType!.isEmpty) &&
      (familyStatus == null || familyStatus!.isEmpty) &&
      (familyValues == null || familyValues!.isEmpty) &&
      (profileCreatedBy == null || profileCreatedBy!.isEmpty) &&
      isDisabled == null &&

      // Tier 3
      isVerified == null &&
      isCommunityTrusted == null &&
      isIncomeVerified == null &&
      (manglikStatus == null || manglikStatus!.isEmpty) &&
      (rashi == null || rashi!.isEmpty) &&
      (nakshatra == null || nakshatra!.isEmpty) &&
      hasHoroscope == null &&
      (employmentSector == null || employmentSector!.isEmpty) &&
      (diet == null || diet!.isEmpty) &&
      (smokingHabits == null || smokingHabits!.isEmpty) &&
      (drinkingHabits == null || drinkingHabits!.isEmpty) &&
      (relocationPreference == null || relocationPreference!.isEmpty) &&
      isRecentlyActive == null &&
      isHighResponse == null &&
      hasMultiplePhotos == null &&

      // Tier 4
      isDirectContactUnlocked == null &&
      isRmHandpicked == null &&
      minGunaScore == null &&
      isVipSpotlight == null &&
      (ancestralLandAcres == null || ancestralLandAcres!.isEmpty) &&
      isHouseOwner == null &&
      isFamilyVetted == null &&
      isConfidentialMode == null;
}
