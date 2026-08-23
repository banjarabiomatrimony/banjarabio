import 'package:intl/intl.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/sibling_model.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/services/app_logger.dart';

/// Data utility for mapping between form data and database profile schema.
/// Extracted from BiodataCreationScreen._populateFormFromMap,
/// _buildSparseProfileData, and _initializeForm.
class CreationFormDataMapper {
  CreationFormDataMapper._();

  /// Returns a fresh, empty form data map.
  static Map<String, dynamic> createEmptyFormData() {
    return {
      'name': '',
      'phone_number': '',
      'surname': '',
      'gotra': '',
      'profileCreatedBy': '',
      'age': '',
      'dateOfBirth': null as DateTime?,
      'gender': '',
      'height': "5'5\"",
      'complexion': '',
      'bloodGroup': '',
      'maritalStatus': 'Never Married',
      'education': '',
      'profession': '',
      'annualIncome': '',
      'state': '',
      'district': '',
      'taluka': '',
      'village': '',
      'location': '',
      'nativePlace': '',
      'fatherName': '',
      'fatherOccupation': '',
      'motherName': '',
      'motherOccupation': '',
      'jobDetails': '',
      'company': '',
      'siblingsCount': '0',
      'sisterCount': '0',
      'brotherCount': '0',
      'siblings': <SiblingModel>[],
      'birthPlace': '',
      'birthTime': '',
      'educationDetails': '',
      'familyType': '',
      'familyStatus': '',
      'marriageReadiness': true,
      'isDisabled': false,
      'aboutSelf': '',
      'partnerExpectations': '',
      'expectation': '',
      'contactPerson': '',
      'contactRelation': '',
      'preferredContactTime': 'Any time',
      'photos': <String>[],
      'tempPhotos': <String>[],
    };
  }

  /// Populates a form data map from raw profile/draft data.
  /// Returns a new map with all fields populated.
  static Map<String, dynamic> populateFromMap(
    Map<String, dynamic> existingFormData,
    Map<String, dynamic> data,
  ) {
    AppLogger.debug('CreationFormDataMapper', 'Populating form from map data');

    final List<String> photoUrls = [];

    // Extract photo URLs
    if (data.containsKey('photos') && data['photos'] is List) {
      final List<dynamic> photoData = data['photos'] as List<dynamic>;
      for (final p in photoData) {
        if (p is PhotoModel) {
          if (p.publicUrl.isNotEmpty) photoUrls.add(p.publicUrl);
        } else if (p is Map) {
          final url = p['url'] ?? p['public_url'] ?? p['image_url'];
          if (url != null && url.toString().isNotEmpty) {
            photoUrls.add(url.toString());
          }
        } else if (p is String && p.isNotEmpty) {
          photoUrls.add(p);
        }
      }
    }

    final Map<String, dynamic> newData = Map<String, dynamic>.from(existingFormData);

    newData['name'] = data['name']?.toString() ?? data['fullName']?.toString() ?? data['full_name']?.toString() ?? '';
    newData['phone_number'] = data['phone_number']?.toString() ?? data['phoneNumber']?.toString() ?? '';
    newData['age'] = data['age']?.toString() ?? '';
    newData['height'] = data['height']?.toString() ?? '';
    newData['surname'] = data['surname']?.toString() ?? '';
    newData['gotra'] = data['gotra']?.toString() ?? '';
    final createdByRaw = (data['profileCreatedBy'] ?? data['profile_created_by'])?.toString();
    newData['profileCreatedBy'] = (createdByRaw != null && createdByRaw.trim().isNotEmpty) ? createdByRaw : 'Self';
    newData['gender'] = data['gender']?.toString() ?? '';
    newData['education'] = data['education']?.toString() ?? '';
    newData['profession'] = data['profession']?.toString() ?? '';
    newData['location'] = (data['location'] ?? data['current_location'] ?? data['permanent_location'])?.toString() ?? '';
    newData['aboutSelf'] = (data['aboutSelf'] ?? data['about'] ?? data['about_self'] ?? data['about_yourself'])?.toString() ?? '';
    newData['marriageReadiness'] = data['marriageReadiness'] == 'Ready for marriage' || data['marriageReadiness'] == true;
    newData['isDisabled'] = data['isDisabled'] == true || data['is_disabled'] == true;

    final dynamic dobData = data['rawDateOfBirth'] ?? data['dateOfBirth'] ?? data['date_of_birth'] ?? data['dob'];
    if (dobData != null) {
      DateTime? parsedDob;
      if (dobData is DateTime) {
        parsedDob = dobData;
      } else {
        final str = dobData.toString().trim();
        parsedDob = DateTime.tryParse(str);
        if (parsedDob == null && str.isNotEmpty && str != 'Not Entered') {
          try {
            parsedDob = DateFormat('dd MMM yyyy').parse(str);
          } catch (_) {
            try {
              parsedDob = DateFormat('yyyy-MM-dd').parse(str);
            } catch (_) {}
          }
        }
      }
      if (parsedDob != null) {
        newData['dateOfBirth'] = parsedDob;
        if (newData['age'] == null || newData['age'] == '' || newData['age'] == '0') {
          final now = DateTime.now();
          int derivedAge = now.year - parsedDob.year;
          if (now.month < parsedDob.month || (now.month == parsedDob.month && now.day < parsedDob.day)) {
            derivedAge--;
          }
          if (derivedAge >= 18) {
            newData['age'] = derivedAge.toString();
          }
        }
      }
    }

    newData['complexion'] = data['complexion']?.toString() ?? '';
    newData['bloodGroup'] = (data['bloodGroup'] ?? data['blood_group'])?.toString() ?? '';
    newData['maritalStatus'] = (data['maritalStatus'] ?? data['marital_status'])?.toString() ?? 'Never Married';
    newData['annualIncome'] = (data['annualIncome'] ?? data['annual_income'])?.toString() ?? '';
    newData['nativePlace'] = (data['nativePlace'] ?? data['native_place'])?.toString() ?? '';
    newData['state'] = data['state']?.toString() ?? '';
    newData['district'] = data['district']?.toString() ?? '';
    newData['taluka'] = data['taluka']?.toString() ?? '';
    newData['village'] = data['village']?.toString() ?? '';
    newData['fatherName'] = (data['fatherName'] ?? data['father_name'])?.toString() ?? '';
    newData['fatherOccupation'] = (data['fatherOccupation'] ?? data['father_occupation'])?.toString() ?? '';
    newData['motherName'] = (data['motherName'] ?? data['mother_name'])?.toString() ?? '';
    newData['motherOccupation'] = (data['motherOccupation'] ?? data['mother_occupation'])?.toString() ?? '';

    final dynamic sCount = data['siblingsCount'] ?? data['siblings_count'];
    if (sCount != null) {
      newData['siblingsCount'] = sCount.toString();
    } else if (data['siblings'] is List) {
      newData['siblingsCount'] = (data['siblings'] as List).length.toString();
    } else {
      newData['siblingsCount'] = data['siblings']?.toString() ?? '0';
    }

    newData['sisterCount'] = (data['sisterCount'] ?? data['sister_count'])?.toString() ?? '0';
    newData['brotherCount'] = (data['brotherCount'] ?? data['brother_count'])?.toString() ?? '0';

    newData['familyType'] = (data['familyType'] ?? data['family_type'])?.toString() ?? '';
    newData['familyStatus'] = (data['familyStatus'] ?? data['family_status'])?.toString() ?? '';
    newData['partnerExpectations'] = (data['partnerExpectations'] ?? data['partner_expectations'])?.toString() ?? '';
    newData['expectation'] = data['expectation']?.toString() ?? '';
    newData['birthPlace'] = (data['birthPlace'] ?? data['birth_place'])?.toString() ?? '';
    newData['birthTime'] = (data['birthTime'] ?? data['birth_time'])?.toString() ?? '';
    newData['educationDetails'] = (data['educationDetails'] ?? data['education_details'])?.toString() ?? '';

    final dynamic rawData = data['siblingsData'] ?? data['siblings_data'] ?? data['siblings'];
    final List rawSiblings = (rawData is List) ? rawData : [];
    newData['siblings'] = rawSiblings
        .map((s) {
          if (s is SiblingModel) return s;
          if (s is Map<String, dynamic>) return SiblingModel.fromJson(s);
          if (s is Map) return SiblingModel.fromJson(Map<String, dynamic>.from(s));
          return null;
        })
        .whereType<SiblingModel>()
        .toList();

    newData['jobDetails'] = (data['jobDetails'] ?? data['job_details'])?.toString() ?? '';
    newData['company'] = data['company']?.toString() ?? '';
    newData['photos'] = photoUrls;
    newData['tempPhotos'] = <String>[];

    return newData;
  }

  /// Builds a sparse map of profile data for database updates.
  /// Only includes fields present in formData.
  static Map<String, dynamic> buildSparseProfileData({
    required Map<String, dynamic> formData,
    required bool isAdminEdit,
    required String? existingProfileUserId,
  }) {
    final userId = isAdminEdit && existingProfileUserId != null
        ? existingProfileUserId
        : AppSupabaseClient.currentUserId;

    final data = <String, dynamic>{
      'user_id': userId,
    };

    if (isAdminEdit) {
      data['target_user_id'] = userId;
    }

    void addIfPresent(String formKey, String dbKey, {dynamic Function(dynamic)? transform}) {
      if (formData.containsKey(formKey)) {
        final val = formData[formKey];
        data[dbKey] = transform != null ? transform(val) : val;
      }
    }

    if (formData.containsKey('profileCreatedBy') &&
        formData['profileCreatedBy'] != null &&
        formData['profileCreatedBy'].toString().trim().isNotEmpty) {
      data['profile_created_by'] = formData['profileCreatedBy'];
    } else if (formData.containsKey('profile_created_by') &&
        formData['profile_created_by'] != null &&
        formData['profile_created_by'].toString().trim().isNotEmpty) {
      data['profile_created_by'] = formData['profile_created_by'];
    }
    addIfPresent('name', 'full_name');
    addIfPresent('phone_number', 'phone_number');
    addIfPresent('phoneNumber', 'phone_number');
    addIfPresent('surname', 'surname', transform: (v) {
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.toLowerCase() == 'chauhan') return 'Chavhan';
      return s;
    });
    addIfPresent('gotra', 'gotra');
    addIfPresent('age', 'age', transform: (v) => int.tryParse(v.toString()));
    addIfPresent('dateOfBirth', 'date_of_birth', transform: (v) {
      if (v == null) return null;
      if (v is DateTime) return v.toIso8601String();
      if (v is String && v.isNotEmpty) {
        final parsed = DateTime.tryParse(v);
        return parsed?.toIso8601String() ?? v;
      }
      return null;
    });
    addIfPresent('gender', 'gender', transform: (v) {
      if (v == null) return null;
      final str = v.toString().trim();
      if (str.toLowerCase() == 'male' || str.toLowerCase() == 'men' || str.toLowerCase() == 'groom' || str.toLowerCase() == 'm') {
        return 'Male';
      } else if (str.toLowerCase() == 'female' || str.toLowerCase() == 'women' || str.toLowerCase() == 'bride' || str.toLowerCase() == 'f') {
        return 'Female';
      }
      return str.isNotEmpty ? str : null;
    });
    addIfPresent('height', 'height');
    addIfPresent('complexion', 'complexion');
    addIfPresent('bloodGroup', 'blood_group');
    addIfPresent('maritalStatus', 'marital_status');
    addIfPresent('education', 'education');
    addIfPresent('profession', 'profession');
    addIfPresent('annualIncome', 'annual_income');
    addIfPresent('state', 'state');
    addIfPresent('district', 'district');
    addIfPresent('taluka', 'taluka');
    addIfPresent('village', 'village');
    addIfPresent('permanent_location', 'permanent_location');
    addIfPresent('permanent_location', 'current_location');
    addIfPresent('nativePlace', 'native_place');
    addIfPresent('birthPlace', 'birth_place');
    addIfPresent('birthTime', 'birth_time');
    addIfPresent('educationDetails', 'education_details');
    addIfPresent('jobDetails', 'job_details');
    addIfPresent('company', 'company');
    addIfPresent('fatherName', 'father_name');
    addIfPresent('fatherOccupation', 'father_occupation');
    addIfPresent('motherName', 'mother_name');
    addIfPresent('motherOccupation', 'mother_occupation');
    addIfPresent('siblingsCount', 'siblings_count', transform: (v) => int.tryParse(v.toString()));
    addIfPresent('sisterCount', 'sister_count', transform: (v) => int.tryParse(v.toString()));
    addIfPresent('brotherCount', 'brother_count', transform: (v) => int.tryParse(v.toString()));

    if (formData.containsKey('siblings')) {
      data['siblings_data'] = ((formData['siblings'] ?? []) as List).map((s) {
        if (s is SiblingModel) return s.toJson();
        if (s is Map<String, dynamic>) return s;
        if (s is Map) return Map<String, dynamic>.from(s);
        return {};
      }).toList();
    }

    addIfPresent('familyType', 'family_type');
    addIfPresent('familyStatus', 'family_status');

    if (formData.containsKey('marriageReadiness')) {
      final isMarriageReady = formData['marriageReadiness'] == true;
      data['marriage_readiness'] = isMarriageReady ? 'Ready for marriage' : 'Not ready yet';
    }

    if (formData.containsKey('isDisabled')) {
      data['is_disabled'] = formData['isDisabled'] == true;
    }

    addIfPresent('aboutSelf', 'about_self');
    addIfPresent('partnerExpectations', 'partner_expectations');
    // Derive age from date_of_birth if missing, null, or zero
    if ((data['age'] == null || (data['age'] is int && (data['age'] as int) <= 0)) && data['date_of_birth'] != null) {
      final dob = DateTime.tryParse(data['date_of_birth'].toString());
      if (dob != null) {
        final now = DateTime.now();
        int calculated = now.year - dob.year;
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
          calculated--;
        }
        if (calculated >= 18) {
          data['age'] = calculated;
        }
      }
    }

    data['updated_at'] = DateTime.now().toIso8601String();

    return data;
  }
}
