import 'package:banjarabio/core/models/profile_model.dart';

import 'package:meta/meta.dart';

@immutable
class BiodataContent {
  final Map<String, String> personalDetails;
  final Map<String, String> educationProfession;
  final Map<String, String> familyDetails;
  final Map<String, String> locationContact;
  final String partnerExpectations;
  final String aboutMe;

  const BiodataContent({
    required this.personalDetails,
    required this.educationProfession,
    required this.familyDetails,
    required this.locationContact,
    required this.partnerExpectations,
    required this.aboutMe,
  });

  factory BiodataContent.fromProfile(
    ProfileModel profile, {
    String language = 'English',
    bool showAnnualIncome = true,
    bool showBirthTime = true,
    bool showPhoneNumber = true,
    String? alternatePhoneNumber,
  }) {
    final personalDetails = <String, String>{
      'Full Name': profile.fullName,
      'Surname': profile.surname,
      'Age': profile.age.toString(),
      'Height': profile.height,
      'Gender': profile.gender,
      'Date of Birth': profile.formattedDOB,
    };
    if (showBirthTime) {
      personalDetails['Birth Time'] = profile.birthTime ?? '-';
      personalDetails['Birth Place'] = profile.birthPlace ?? '-';
    }
    personalDetails['Marital Status'] = profile.maritalStatus;
    personalDetails['Complexion'] = profile.complexion ?? '-';
    personalDetails['Blood Group'] = profile.bloodGroup ?? '-';

    final educationProfession = <String, String>{
      'Education': profile.education,
      'Edu. Details': profile.educationDetails ?? '-',
      'Occupation': profile.profession,
      'Job Details': profile.jobDetails ?? '-',
      'Company': profile.company ?? '-',
    };
    if (showAnnualIncome) {
      educationProfession['Annual Income'] =
          profile.formattedAnnualIncome.isNotEmpty &&
                  profile.formattedAnnualIncome != 'Not Entered'
              ? profile.formattedAnnualIncome
              : (profile.annualIncome ?? '-');
    }

    final familyDetails = <String, String>{
      'Father Name': profile.fatherName ?? '-',
      'Father Occup.': profile.fatherOccupation ?? '-',
      'Mother Name': profile.motherName ?? '-',
      'Mother Occup.': profile.motherOccupation ?? '-',
      'Family Type': profile.familyType ?? '-',
      'Family Status': profile.familyStatus ?? '-',
      'Total Siblings': profile.siblingsCount.toString(),
      'Brothers': profile.brotherCount.toString(),
      'Sisters': profile.sisterCount.toString(),
    };

    final locationContact = <String, String>{
      'Native Place': profile.nativePlace ?? '-',
      'Current Location': profile.formattedLocation,
    };
    if (showPhoneNumber) {
      locationContact['Contact No.'] = profile.phoneNumber ?? '-';
    }
    if (alternatePhoneNumber != null && alternatePhoneNumber.trim().isNotEmpty) {
      locationContact['Alt. Contact'] = alternatePhoneNumber.trim();
    }

    final partnerExp = (profile.partnerExpectations != null && profile.partnerExpectations!.trim().isNotEmpty)
        ? profile.partnerExpectations!.trim()
        : (profile.expectation != null && profile.expectation!.trim().isNotEmpty
            ? profile.expectation!.trim()
            : '');

    final aboutSelf = (profile.aboutSelf != null && profile.aboutSelf!.trim().isNotEmpty)
        ? profile.aboutSelf!.trim()
        : '';

    return BiodataContent(
      personalDetails: personalDetails,
      educationProfession: educationProfession,
      familyDetails: familyDetails,
      locationContact: locationContact,
      partnerExpectations: partnerExp,
      aboutMe: aboutSelf,
    );
  }

  BiodataContent copyWith({
    Map<String, String>? personalDetails,
    Map<String, String>? educationProfession,
    Map<String, String>? familyDetails,
    Map<String, String>? locationContact,
    String? partnerExpectations,
    String? aboutMe,
  }) {
    return BiodataContent(
      personalDetails: personalDetails ?? this.personalDetails,
      educationProfession: educationProfession ?? this.educationProfession,
      familyDetails: familyDetails ?? this.familyDetails,
      locationContact: locationContact ?? this.locationContact,
      partnerExpectations: partnerExpectations ?? this.partnerExpectations,
      aboutMe: aboutMe ?? this.aboutMe,
    );
  }
}
