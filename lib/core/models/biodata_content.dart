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
  }) {
    // Initial content based on profile data
    // Language specific labels will be handled by a mapper/translator service or the editor
    return BiodataContent(
      personalDetails: {
        'Full Name': profile.fullName,
        'Surname': profile.surname,
        'Age': profile.age.toString(),
        'Height': profile.height,
        'Gender': profile.gender,
        'Date of Birth': profile.formattedDOB,
        'Birth Time': profile.birthTime ?? '-',
        'Birth Place': profile.birthPlace ?? '-',
        'Marital Status': profile.maritalStatus,
        'Complexion': profile.complexion ?? '-',
        'Blood Group': profile.bloodGroup ?? '-',
      },
      educationProfession: {
        'Education': profile.education,
        'Edu. Details': profile.educationDetails ?? '-',
        'Occupation': profile.profession,
        'Job Details': profile.jobDetails ?? '-',
        'Annual Income': profile.annualIncome ?? '-',
        'Company': profile.company ?? '-',
      },
      familyDetails: {
        'Father Name': profile.fatherName ?? '-',
        'Father Occup.': profile.fatherOccupation ?? '-',
        'Mother Name': profile.motherName ?? '-',
        'Mother Occup.': profile.motherOccupation ?? '-',
        'Family Type': profile.familyType ?? '-',
        'Family Status': profile.familyStatus ?? '-',
        'Total Siblings': profile.siblingsCount.toString(),
        'Brothers': profile.brotherCount.toString(),
        'Sisters': profile.sisterCount.toString(),
      },
      locationContact: {
        'Native Place': profile.nativePlace ?? '-',
        'Current Location': profile.formattedLocation,
        'Contact No.': profile.phoneNumber ?? '-',
      },
      partnerExpectations: profile.partnerExpectations ?? '',
      aboutMe: profile.aboutSelf ?? '',
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
