import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:banjarabio/core/models/sibling_model.dart';

import 'package:banjarabio/core/models/subscription_model.dart';

/// Profile model representing user biodata
@immutable
class ProfileModel {
  final String id;
  final String userId;
  final String? email;

  // Personal Details
  final String fullName;
  final String surname;
  final String? gotra;
  final int age;
  final DateTime? dateOfBirth;
  final String gender;
  final String height;
  final String? complexion;
  final String? bloodGroup;
  final String maritalStatus;
  final String? phoneNumber; // New field and added here for parity with schema
  final PlanType planType; // Added for localized plans and targeted banners

  // Education & Profession
  final String education;
  final String profession;
  final String? annualIncome;

  // Location (structured)
  final String? state;
  final String? district;
  final String? taluka;
  final String? village;
  final String permanentLocation; // Renamed/Mapped from legacy currentLocation
  final String? nativePlace;

  /// Backward compatible getter for UI - returns formatted "Taluka, District, State"
  String get currentLocation => formattedLocation;

  // Family Details
  final String? fatherName;
  final String? fatherOccupation;
  final String? motherName;
  final String? motherOccupation;
  final int siblingsCount;
  final int sisterCount;
  final int brotherCount;
  final String? familyType;
  final String? familyStatus;

  // Birth Details
  final String? birthPlace;
  final String? birthTime;

  // Detailed Education & Job
  final String? educationDetails;
  final String? jobDetails;
  final String? company;

  // Preferences & Additional
  final String marriageReadiness;
  final String? aboutSelf;
  final String? partnerExpectations;
  final String? expectation; // New field for partner expectations
  final String? contactPerson; // Contact person name / role
  final String? contactRelation; // Relation with candidate (e.g. Self, Father, Brother)
  final String? preferredContactTime; // Preferred calling / contact time

  // Metadata
  final bool isPremium;
  final bool isAdmin;
  final bool isPdfUnlocked;
  final int profileCompletion;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int trustScore;
  final int vouchCount; // [NEW] Number of vouches received
  final bool isCommunityTrusted; // [NEW] Badge status
  final bool emailVerified; // Added
  final bool phoneVerified; // Added
  final bool hasFollowedInstagram; // Added for rewards 
  final String? profileCreatedBy; // New field: Created by Self, Parent, Sibling, etc.
  final int specialDiscount; // [NEW] Admin granted special discount (0-100)
  final DateTime? specialDiscountExpiresAt; // [NEW] Expiry for special discount

  // Staff Management
  final String role; // 'user', 'staff', 'admin'
  final String? department;
  final String? designation;
  final String? assignedTo; // Telecaller user_id
  final DateTime? lastCalledAt;
  final String callStatus; // 'not_called', 'connected', 'busy', 'follow_up', 'converted', 'not_interested'

  // Photos (loaded separately)
  final List<PhotoModel> photos;

  // Sibling Details (Dynamic List)
  final List<SiblingModel> siblings;

  final bool isBookmarked;
  final bool isMatched;
  final bool isDisabled; // New field for physical disability status
  final String? fcmToken; // [NEW] For push notifications
  final String? searchVector; // [NEW] For FTS (Postgres)

  /// Cache completion percentage for performance in lists
  final int completionPercentage;

  /// 🧬 EXTREME PERFORMANCE: Cache the display map to prevent re-computation in UI
  /// We use a final reference-holding map to satisfy @immutable lints.
  final Map<String, dynamic> _displayMapCache = {};

  /// Utility to check if metadata (photos) is loaded.
  /// Basic fetch only returns the profile record without enriching photos/matches.
  bool get isEnriched => photos.isNotEmpty || isMatched || isBookmarked;

  /// [NEW] Human-readable User ID for searching and identification
  /// Format: BBM-XXXXXXXX (Male) or BBF-XXXXXXXX (Female)
  String get displayId {
    final prefix = gender == 'Male' ? 'BBM' : (gender == 'Female' ? 'BBF' : 'BB');
    return '$prefix-${id.split('-').first.toUpperCase()}';
  }

  ProfileModel({
    required this.id,
    required this.userId,
    this.email,
    required this.fullName,
    required this.surname,
    this.gotra,
    required this.age,
    this.dateOfBirth,
    required this.gender,
    required this.height,
    this.complexion,
    this.bloodGroup,
    this.maritalStatus = 'Never Married',
    required this.education,
    required this.profession,
    this.annualIncome,
    this.state,
    this.district,
    this.taluka,
    this.village,
    this.phoneNumber, // Added to constructor
    this.planType = PlanType.free,
    this.permanentLocation = '',
    this.nativePlace,
    this.fatherName,
    this.fatherOccupation,
    this.motherName,
    this.motherOccupation,
    this.siblingsCount = 0,
    this.sisterCount = 0,
    this.brotherCount = 0,
    this.siblings = const [],
    this.familyType,
    this.familyStatus,
    this.birthPlace,
    this.birthTime,
    this.educationDetails,
    this.jobDetails,
    this.company,
    this.marriageReadiness = 'Ready for marriage',
    this.aboutSelf,
    this.partnerExpectations,
    this.expectation,
    this.contactPerson,
    this.contactRelation,
    this.preferredContactTime,
    this.isPremium = false,
    this.isAdmin = false,
    this.profileCompletion = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.trustScore = 0,
    this.vouchCount = 0,
    this.isCommunityTrusted = false,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.isPdfUnlocked = false,
    this.photos = const [],
    this.isBookmarked = false,
    this.isMatched = false,
    this.hasFollowedInstagram = false,
    this.profileCreatedBy,
    this.isDisabled = false,
    this.fcmToken,
    this.searchVector,
    this.specialDiscount = 0,
    this.specialDiscountExpiresAt,
    this.role = 'user',
    this.department,
    this.designation,
    this.assignedTo,
    this.lastCalledAt,
    this.callStatus = 'not_called',
   }) : completionPercentage = calculateScore({
          'full_name': fullName,
          'surname': surname,
          'age': age,
          'gender': gender,
          'height': height,
          'marital_status': maritalStatus,
          'education': education,
          'profession': profession,
          'state': state,
          'district': district,
          'taluka': taluka,
          'native_place': nativePlace,
          'village': village,
          'complexion': complexion,
          'blood_group': bloodGroup,
          'annual_income': annualIncome,
          'father_name': fatherName,
          'mother_name': motherName,
          'about_self': aboutSelf,
          'expectation': expectation,
          'partner_expectations': partnerExpectations,
          'photos': photos,
          'siblings_count': siblingsCount,
          'siblings_data': siblings,
          'has_followed_instagram': hasFollowedInstagram,
        });

  /// Centralized Profile Completion Logic (100% total)
  static int calculateScore(Map<String, dynamic> data) {
    double score = 0;

    // Helper to check both snake_case and camelCase
    dynamic val(String snake, String camel) => data[snake] ?? data[camel];
    bool isSet(String snake, String camel) {
      final v = val(snake, camel);
      if (v == null) return false;
      return v.toString().trim().isNotEmpty;
    }

    // 1. Identity (20%)
    if (isSet('full_name', 'name')) score += 4;
    if (isSet('surname', 'surname')) score += 4;
    if (isSet('gender', 'gender')) score += 3;
    
    final age = int.tryParse(val('age', 'age')?.toString() ?? '0') ?? 0;
    if (age >= 18 || age > 0) score += 3;

    if (isSet('height', 'height')) score += 3;

    if (isSet('marital_status', 'maritalStatus')) score += 3;

    // 2. Family (15%)
    bool hasParent = false;
    if (isSet('father_name', 'fatherName')) { score += 5; hasParent = true; }
    if (isSet('mother_name', 'motherName')) { score += 5; hasParent = true; }
    
    final hasSibsData = (val('siblings_data', 'siblings') as List?)?.isNotEmpty ?? false;
    if (hasSibsData || isSet('siblings_count', 'siblingsCount') || hasParent) score += 5;

    // 3. Career (25%)
    if (isSet('education', 'education')) score += 10;
    if (isSet('profession', 'profession')) score += 10;
    if (isSet('annual_income', 'annualIncome')) score += 5;

    // 4. Visual (20%)
    final photos = val('photos', 'photos') as List?;
    if (photos != null && photos.isNotEmpty) {
      score += 15;
      if (photos.length > 1) score += 5;
    }

    // 5. Preferences & Location (20%)
    if (isSet('state', 'state')) score += 5;
    if (isSet('district', 'district')) score += 5;
    if (isSet('taluka', 'taluka') || isSet('native_place', 'nativePlace') || isSet('village', 'village')) score += 2;
    if (isSet('about_self', 'aboutSelf')) score += 4;
    if (isSet('expectation', 'expectation') || isSet('partner_expectations', 'partnerExpectations')) score += 4;

    return score.round().clamp(0, 100);
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Safely parse dates with fallback to now
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        if (value is DateTime) return value;
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    final DateTime? parsedDob = (json['date_of_birth'] != null || json['dateOfBirth'] != null)
        ? parseDate(json['date_of_birth'] ?? json['dateOfBirth'])
        : null;

    int resolvedAge = (json['age'] as num?)?.toInt() ?? 0;
    if (parsedDob != null) {
      final now = DateTime.now();
      int ageFromDob = now.year - parsedDob.year;
      if (now.month < parsedDob.month || (now.month == parsedDob.month && now.day < parsedDob.day)) {
        ageFromDob--;
      }
      if (ageFromDob >= 18 && (resolvedAge <= 0 || resolvedAge == 18)) {
        resolvedAge = ageFromDob;
      }
    }
    if (resolvedAge <= 0) resolvedAge = 18;

    return ProfileModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      email: json['email']?.toString(),
      fullName: json['full_name']?.toString() ?? '',
      surname: json['surname']?.toString() ?? '',
      gotra: json['gotra']?.toString(),
      age: resolvedAge,
      dateOfBirth: parsedDob,
      gender: json['gender']?.toString() ?? 'Female',
      height: json['height']?.toString() ?? "5'5\"",
      complexion: json['complexion']?.toString(),
      bloodGroup: json['blood_group']?.toString(),
      maritalStatus: json['marital_status']?.toString() ?? 'Never Married',
      education: json['education']?.toString() ?? '',
      profession: json['profession']?.toString() ?? '',
      annualIncome: json['annual_income']?.toString(),
      state: json['state']?.toString(),
      district: json['district']?.toString(),
      taluka: json['taluka']?.toString(),
      village: json['village']?.toString(),
      phoneNumber: json['phone_number']?.toString(), // Map from phone_number
      permanentLocation:
          json['permanent_location']?.toString() ??
          json['current_location']?.toString() ??
          '',
      nativePlace: json['native_place']?.toString(),
      fatherName: json['father_name']?.toString(),
      fatherOccupation: json['father_occupation']?.toString(),
      motherName: json['mother_name']?.toString(),
      motherOccupation: json['mother_occupation']?.toString(),
      siblingsCount: (json['siblings_count'] as num?)?.toInt() ?? 0,
      sisterCount: (json['sister_count'] as num?)?.toInt() ?? 0,
      brotherCount: (json['brother_count'] as num?)?.toInt() ?? 0,
      familyType: json['family_type']?.toString(),
      familyStatus: json['family_status']?.toString(),
      birthPlace: json['birth_place']?.toString(),
      birthTime: json['birth_time']?.toString(),
      educationDetails: json['education_details']?.toString(),
      jobDetails: json['job_details']?.toString(),
      company: json['company']?.toString(),
      marriageReadiness:
          json['marriage_readiness']?.toString() ?? 'Ready for marriage',
      aboutSelf: json['about_self']?.toString(),
      partnerExpectations: json['partner_expectations']?.toString(),
      expectation: json['expectation']?.toString(),
      contactPerson: json['contact_person']?.toString() ??
          json['contactPerson']?.toString() ??
          json['profile_created_by']?.toString(),
      contactRelation: json['contact_relation']?.toString() ??
          json['contactRelation']?.toString() ??
          json['profile_created_by']?.toString(),
      preferredContactTime: json['preferred_contact_time']?.toString() ??
          json['preferredContactTime']?.toString(),
      isPremium: json['is_premium'] == true,
      isAdmin: json['is_admin'] == true,
      profileCompletion: (json['profile_completion'] as num?)?.toInt() ?? 0,
      isVerified: json['is_verified'] == true,
      isPdfUnlocked: json['is_pdf_unlocked'] == true,
      isActive: json['is_active'] == true,
      trustScore: (json['trust_score'] as num?)?.toInt() ?? 0,
      vouchCount: (json['vouch_count'] as num?)?.toInt() ?? 0,
      isCommunityTrusted: json['is_community_trusted'] == true,
      emailVerified: json['email_verified'] == true,
      phoneVerified: json['phone_verified'] == true,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((p) =>
                  PhotoModel.fromJson(Map<String, dynamic>.from(p as Map)))
              .toList() ??
          [],
      isBookmarked: json['is_bookmarked'] == true,
      isMatched: json['is_matched'] == true,
      siblings:
          (json['siblings_data'] as List<dynamic>?)
              ?.map((s) =>
                  SiblingModel.fromJson(Map<String, dynamic>.from(s as Map)))
              .toList() ??
          [],
      hasFollowedInstagram: json['has_followed_instagram'] == true,
      profileCreatedBy: json['profile_created_by']?.toString(),
      isDisabled: json['is_disabled'] == true,
      fcmToken: json['fcm_token']?.toString(),
      searchVector: json['search_vector']?.toString(),
      planType: _parsePlanType(json['plan_type']),
      specialDiscount: (json['special_discount'] as num?)?.toInt() ?? 0,
      specialDiscountExpiresAt: json['special_discount_expires_at'] != null
          ? parseDate(json['special_discount_expires_at'])
          : null,
      role: json['role']?.toString() ?? 'user',
      department: json['department']?.toString(),
      designation: json['designation']?.toString(),
      assignedTo: json['assigned_to']?.toString(),
      lastCalledAt: json['last_called_at'] != null
          ? parseDate(json['last_called_at'])
          : null,
      callStatus: json['call_status']?.toString() ?? 'not_called',
    )..precomputeDisplayData();
  }

  static PlanType _parsePlanType(dynamic value) {
    if (value == null) return PlanType.free;
    return PlanType.fromString(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'surname': surname,
      'gotra': gotra,
      'age': age,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'height': height,
      'complexion': complexion,
      'blood_group': bloodGroup,
      'marital_status': maritalStatus,
      'education': education,
      'profession': profession,
      'annual_income': annualIncome,
      'state': state,
      'district': district,
      'taluka': taluka,
      'village': village,
      'phone_number': phoneNumber,
      'permanent_location': permanentLocation,
      'current_location': permanentLocation, // Keep for backward compat
      'native_place': nativePlace,
      'father_name': fatherName,
      'father_occupation': fatherOccupation,
      'mother_name': motherName,
      'mother_occupation': motherOccupation,
      'siblings_count': siblingsCount,
      'sister_count': sisterCount,
      'brother_count': brotherCount,
      'family_type': familyType,
      'family_status': familyStatus,
      'birth_place': birthPlace,
      'birth_time': birthTime,
      'education_details': educationDetails,
      'job_details': jobDetails,
      'company': company,
      'marriage_readiness': marriageReadiness,
      'about_self': aboutSelf,
      'partner_expectations': partnerExpectations,
      'expectation': expectation,
      'is_premium': isPremium,
      'is_admin': isAdmin,
      'profile_completion': profileCompletion,
      'is_verified': isVerified,
      'is_pdf_unlocked': isPdfUnlocked,
      'is_active': isActive,
      'trust_score': trustScore,
      'vouch_count': vouchCount,
      'is_community_trusted': isCommunityTrusted,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'is_matched': isMatched,
      'has_followed_instagram': hasFollowedInstagram,
      'profile_created_by': profileCreatedBy,
      'is_disabled': isDisabled,
      'fcm_token': fcmToken,
      'photos': photos.map((p) => p.toJson()).toList(),
      'siblings_data': siblings.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'plan_type': planType.name,
      'special_discount': specialDiscount,
      'special_discount_expires_at': specialDiscountExpiresAt?.toIso8601String(),
      'role': role,
      'department': department,
      'designation': designation,
      'assigned_to': assignedTo,
      'last_called_at': lastCalledAt?.toIso8601String(),
      'call_status': callStatus,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? userId,
    String? email,
    String? fullName,
    String? surname,
    String? gotra,
    int? age,
    DateTime? dateOfBirth,
    String? gender,
    String? height,
    String? complexion,
    String? bloodGroup,
    String? maritalStatus,
    String? education,
    String? profession,
    String? annualIncome,
    String? state,
    String? district,
    String? taluka,
    String? village,
    String? phoneNumber,
    String? permanentLocation,
    String? nativePlace,
    String? fatherName,
    String? fatherOccupation,
    String? motherName,
    String? motherOccupation,
    int? siblingsCount,
    int? sisterCount,
    int? brotherCount,
    String? familyType,
    String? familyStatus,
    String? marriageReadiness,
    String? aboutSelf,
    String? partnerExpectations,
    String? expectation,
    String? contactPerson,
    String? contactRelation,
    String? preferredContactTime,
    String? birthPlace,
    String? birthTime,
    String? educationDetails,
    String? jobDetails,
    String? company,
    bool? isPremium,
    bool? isAdmin,
    int? profileCompletion,
    bool? isVerified,
    bool? isPdfUnlocked,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? trustScore,
    int? vouchCount,
    bool? isCommunityTrusted,
    bool? emailVerified,
    bool? phoneVerified,
    List<PhotoModel>? photos,
    List<SiblingModel>? siblings,
    bool? isBookmarked,
    bool? isMatched,
    bool? hasFollowedInstagram,
    String? profileCreatedBy,
    bool? isDisabled,
    String? fcmToken,
    String? searchVector,
    PlanType? planType,
    int? specialDiscount,
    DateTime? specialDiscountExpiresAt,
    String? role,
    String? department,
    String? designation,
    String? assignedTo,
    DateTime? lastCalledAt,
    String? callStatus,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      surname: surname ?? this.surname,
      gotra: gotra ?? this.gotra,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      complexion: complexion ?? this.complexion,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      education: education ?? this.education,
      profession: profession ?? this.profession,
      annualIncome: annualIncome ?? this.annualIncome,
      state: state ?? this.state,
      district: district ?? this.district,
      taluka: taluka ?? this.taluka,
      village: village ?? this.village,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      permanentLocation: permanentLocation ?? this.permanentLocation,
      nativePlace: nativePlace ?? this.nativePlace,
      fatherName: fatherName ?? this.fatherName,
      fatherOccupation: fatherOccupation ?? this.fatherOccupation,
      motherName: motherName ?? this.motherName,
      motherOccupation: motherOccupation ?? this.motherOccupation,
      siblingsCount: siblingsCount ?? this.siblingsCount,
      sisterCount: sisterCount ?? this.sisterCount,
      brotherCount: brotherCount ?? this.brotherCount,
      familyType: familyType ?? this.familyType,
      familyStatus: familyStatus ?? this.familyStatus,
      marriageReadiness: marriageReadiness ?? this.marriageReadiness,
      aboutSelf: aboutSelf ?? this.aboutSelf,
      partnerExpectations: partnerExpectations ?? this.partnerExpectations,
      expectation: expectation ?? this.expectation,
      contactPerson: contactPerson ?? this.contactPerson,
      contactRelation: contactRelation ?? this.contactRelation,
      preferredContactTime: preferredContactTime ?? this.preferredContactTime,
      birthPlace: birthPlace ?? this.birthPlace,
      birthTime: birthTime ?? this.birthTime,
      educationDetails: educationDetails ?? this.educationDetails,
      jobDetails: jobDetails ?? this.jobDetails,
      company: company ?? this.company,
      isPremium: isPremium ?? this.isPremium,
      isAdmin: isAdmin ?? this.isAdmin,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      isVerified: isVerified ?? this.isVerified,
      isPdfUnlocked: isPdfUnlocked ?? this.isPdfUnlocked,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trustScore: trustScore ?? this.trustScore,
      vouchCount: vouchCount ?? this.vouchCount,
      isCommunityTrusted: isCommunityTrusted ?? this.isCommunityTrusted,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      photos: photos ?? this.photos,
      siblings: siblings ?? this.siblings,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isMatched: isMatched ?? this.isMatched,
      hasFollowedInstagram: hasFollowedInstagram ?? this.hasFollowedInstagram,
      profileCreatedBy: profileCreatedBy ?? this.profileCreatedBy,
      isDisabled: isDisabled ?? this.isDisabled,
      fcmToken: fcmToken ?? this.fcmToken,
      searchVector: searchVector ?? this.searchVector,
      planType: planType ?? this.planType,
      specialDiscount: specialDiscount ?? this.specialDiscount,
      specialDiscountExpiresAt:
          specialDiscountExpiresAt ?? this.specialDiscountExpiresAt,
      role: role ?? this.role,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      assignedTo: assignedTo ?? this.assignedTo,
      lastCalledAt: lastCalledAt ?? this.lastCalledAt,
      callStatus: callStatus ?? this.callStatus,
    );
  }

  Map<String, dynamic> toDisplayMap() {
    if (_displayMapCache.isNotEmpty) return _displayMapCache;
    return precomputeDisplayData();
  }

  /// 🧬 EXTREME PERFORMANCE: Pre-calculate all UI strings and metrics.
  /// This MUST be called in a background isolate for maximum efficiency.
  Map<String, dynamic> precomputeDisplayData() {
    _displayMapCache.clear();
    _displayMapCache.addAll({
      'id': id,
      'userId': userId,
      'displayId': displayId,
      'name': fullName,
      'fullName': fullName, // Keep for compatibility during transition
      'surname': surname,
      'gotra': gotra,
      'email': email,
      'phoneNumber': phoneNumber,
      'phone_number': phoneNumber,
      'age': age,
      'dob': formattedDOB,
      'dateOfBirth': formattedDOB,
      'rawDateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'height': height,
      'complexion': complexion,
      'bloodGroup': bloodGroup,
      'maritalStatus': maritalStatus,
      'education': education,
      'profession': profession,
      'job': profession, // Standardized key
      'occupation': profession, // Standardized key
      'annualIncome': formatAnnualIncome(annualIncome),
      'rawAnnualIncome': annualIncome,
      'state': state,
      'district': district,
      'taluka': taluka,
      'village': village,
      'permanentLocation': permanentLocation,
      'currentLocation':
          currentLocation, // Uses the getter for formatted location
      'location':
          locationExcludingVillage, // Standardized formatted location (excl. village per OLX req)
      'nativePlace': nativePlace,
      'fatherName': fatherName,
      'fatherOccupation': fatherOccupation,
      'motherName': motherName,
      'motherOccupation': motherOccupation,
      'siblings': siblingsCount,
      'siblingsCount': siblingsCount,
      'sisterCount': sisterCount,
      'brotherCount': brotherCount,
      'familyType': familyType,
      'familyStatus': familyStatus,
      'marriageReadiness': marriageReadiness,
      'aboutSelf': aboutSelf,
      'about': aboutSelf, // Standardized key
      'expectation': expectation,
      'partnerExpectations': partnerExpectations,
      'partnerPreferences': partnerExpectations ?? expectation ?? '',
      'contactPerson': contactPerson ?? profileCreatedBy ?? 'Self',
      'contactRelation': contactRelation ?? profileCreatedBy ?? 'Self',
      'preferredContactTime': preferredContactTime ?? 'Any time',
      'birthPlace': birthPlace,
      'birthTime': birthTime,
      'educationDetails': educationDetails,
      'jobDetails': jobDetails,
      'company': company,
      'isPremium': isPremium,
      'isVerified': isVerified,
      'trustScore': trustScore,
      'vouchCount': vouchCount,
      'isCommunityTrusted': isCommunityTrusted,
      'isBookmarked': isBookmarked,
      'isMatched': isMatched,
      'hasFollowedInstagram': hasFollowedInstagram,
      'profileCreatedBy': profileCreatedBy,
      'isDisabled': isDisabled,
      'profileCompletion': calculateCompletionPercentage(),
      'photos': photos
          .map(
            (p) => {'url': p.publicUrl, 'semanticLabel': p.semanticLabel ?? ''},
          )
          .toList(),
      'siblingsData': siblings.map((s) => s.toJson()).toList(),
      // Removed phoneNumber and maskedPhoneNumber to protect privacy
    });
    return _displayMapCache;
  }

  /// Get masked phone number: "98765*****"
  String get maskedPhoneNumber {
    if (phoneNumber == null || phoneNumber!.length < 5) {
      return phoneNumber ?? '';
    }
    // Typically phone numbers are 10 digits or more with country code.
    // Masking the last 5 digits as requested.
    final p = phoneNumber!.trim();
    if (p.length <= 5) return p;
    return '${p.substring(0, p.length - 5)}*****';
  }

  /// Get formatted location string: "Village, Taluka, District, State"
  String get formattedLocation {
    final parts = <String>[];
    if (village != null && village!.isNotEmpty) parts.add(village!);
    if (taluka != null && taluka!.isNotEmpty) parts.add(taluka!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (parts.isEmpty && permanentLocation.isNotEmpty) {
      return permanentLocation; // Fallback to manual address
    }
    return parts.join(', ');
  }

  /// Get formatted DOB: "DD MMM YYYY"
  String get formattedDOB {
    if (dateOfBirth == null) return 'Not Entered';
    return DateFormat('dd MMM yyyy').format(dateOfBirth!);
  }

  /// Get formatted location without village for UI (Main Screen requirement)
  String get locationExcludingVillage {
    final parts = <String>[];
    if (taluka != null && taluka!.isNotEmpty) parts.add(taluka!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (parts.isEmpty && permanentLocation.isNotEmpty) {
      return permanentLocation;
    }
    return parts.join(', ');
  }

  /// DEPRECATED: Use [completionPercentage] field for better performance.
  int calculateCompletionPercentage() => completionPercentage;

  /// Returns numeric annual income formatted with rupee symbol: "₹2,00,000 - ₹5,00,000 / Year"
  String get formattedAnnualIncome => formatAnnualIncome(annualIncome);

  /// Formats raw annual income key or text into pure numeric rupee display string.
  static String formatAnnualIncome(dynamic value) {
    if (value == null) return 'Not Entered';
    final str = value.toString().trim();
    if (str.isEmpty || str == '-' || str == 'null') return 'Not Entered';

    switch (str) {
      case 'noIncome':
        return '₹0 (No Income)';
      case 'under2Lakh':
        return '₹0 - ₹2,00,000 / Year';
      case 'twoToFiveLakh':
        return '₹2,00,000 - ₹5,00,000 / Year';
      case 'fiveToSevenHalfLakh':
        return '₹5,00,000 - ₹7,50,000 / Year';
      case 'sevenHalfToTenLakh':
        return '₹7,50,000 - ₹10,00,000 / Year';
      case 'tenToFifteenLakh':
        return '₹10,00,000 - ₹15,00,000 / Year';
      case 'fifteenToTwentyLakh':
        return '₹15,00,000 - ₹20,00,000 / Year';
      case 'twentyLakhPlus':
        return '₹20,00,000+ / Year';
    }

    // Convert Indic/Marathi digits if present
    String formatted = str
        .replaceAll('०', '0')
        .replaceAll('१', '1')
        .replaceAll('२', '2')
        .replaceAll('३', '3')
        .replaceAll('४', '4')
        .replaceAll('५', '5')
        .replaceAll('६', '6')
        .replaceAll('७', '7')
        .replaceAll('८', '8')
        .replaceAll('९', '9');

    if (formatted.contains('2 Lakh') || formatted.contains('२ लाख')) {
      if (formatted.contains('5') || formatted.contains('५')) return '₹2,00,000 - ₹5,00,000 / Year';
    }
    if (formatted.contains('5 Lakh') || formatted.contains('५ लाख')) {
      if (formatted.contains('7.5') || formatted.contains('७.५')) return '₹5,00,000 - ₹7,50,000 / Year';
    }
    if (formatted.contains('7.5') || formatted.contains('७.५')) {
      if (formatted.contains('10') || formatted.contains('१०')) return '₹7,50,000 - ₹10,00,000 / Year';
    }
    if (formatted.contains('10') || formatted.contains('१०')) {
      if (formatted.contains('15') || formatted.contains('१५')) return '₹10,00,000 - ₹15,00,000 / Year';
    }
    if (formatted.contains('15') || formatted.contains('१५')) {
      if (formatted.contains('20') || formatted.contains('२०')) return '₹15,00,000 - ₹20,00,000 / Year';
    }
    if (formatted.contains('20+') || formatted.contains('२०+')) {
      return '₹20,00,000+ / Year';
    }

    if (!formatted.startsWith('₹') && !formatted.startsWith('Rs')) {
      formatted = '₹$formatted';
    }
    if (!formatted.contains('/ Year') && !formatted.contains('Year') && !formatted.contains('Lakh')) {
      formatted = '$formatted / Year';
    }

    return formatted;
  }
}

/// Photo model for profile images
@immutable
class PhotoModel {
  final String id;
  final String profileId;
  final String storagePath;
  final String publicUrl;
  final String? semanticLabel;
  final bool isPrimary;
  final bool isApproved;
  final DateTime uploadedAt;

  const PhotoModel({
    required this.id,
    required this.profileId,
    required this.storagePath,
    required this.publicUrl,
    this.semanticLabel,
    this.isPrimary = true,
    this.isApproved = true,
    required this.uploadedAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id']?.toString() ?? '',
      profileId: json['profile_id']?.toString() ?? '',
      storagePath: json['storage_path']?.toString() ?? '',
      publicUrl: json['public_url']?.toString() ?? '',
      semanticLabel: json['semantic_label']?.toString(),
      isPrimary: json['is_primary'] == true || json['is_primary'] == null,
      isApproved: json['is_approved'] != false,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'storage_path': storagePath,
      'public_url': publicUrl,
      'semantic_label': semanticLabel,
      'is_primary': isPrimary,
      'is_approved': isApproved,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
