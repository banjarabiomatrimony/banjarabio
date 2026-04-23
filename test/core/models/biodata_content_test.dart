import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/biodata_content.dart';
import 'package:banjarabio/core/models/profile_model.dart';

void main() {
  final now = DateTime(2025, 6, 15);

  ProfileModel makeProfile({
    String fullName = 'Rajesh',
    String surname = 'Rathod',
    int age = 28,
    String gender = 'Male',
    String height = "5'10\"",
    String? complexion = 'Fair',
    String? bloodGroup = 'O+',
    String maritalStatus = 'Never Married',
    String education = 'B.E.',
    String? educationDetails = 'Computer Science',
    String profession = 'Software Engineer',
    String? jobDetails = 'Senior Dev',
    String? annualIncome = '10 LPA',
    String? company = 'TCS',
    String? fatherName = 'Suresh',
    String? fatherOccupation = 'Farmer',
    String? motherName = 'Sunita',
    String? motherOccupation = 'Homemaker',
    String? familyType = 'Joint',
    String? familyStatus = 'Middle Class',
    int siblingsCount = 2,
    int brotherCount = 1,
    int sisterCount = 1,
    String? nativePlace = 'Aurangabad',
    String? state = 'Maharashtra',
    String? district = 'Pune',
    String? taluka = 'Haveli',
    String? phoneNumber = '9876543210',
    String? partnerExpectations = 'Looking for educated partner',
    String? aboutSelf = 'Ambitious and kind',
    String? birthPlace = 'Mumbai',
    String? birthTime = '10:30 AM',
    DateTime? dateOfBirth,
  }) {
    return ProfileModel(
      id: 'p1',
      userId: 'u1',
      fullName: fullName,
      surname: surname,
      age: age,
      gender: gender,
      height: height,
      complexion: complexion,
      bloodGroup: bloodGroup,
      maritalStatus: maritalStatus,
      education: education,
      educationDetails: educationDetails,
      profession: profession,
      jobDetails: jobDetails,
      annualIncome: annualIncome,
      company: company,
      fatherName: fatherName,
      fatherOccupation: fatherOccupation,
      motherName: motherName,
      motherOccupation: motherOccupation,
      familyType: familyType,
      familyStatus: familyStatus,
      siblingsCount: siblingsCount,
      brotherCount: brotherCount,
      sisterCount: sisterCount,
      nativePlace: nativePlace,
      state: state,
      district: district,
      taluka: taluka,
      phoneNumber: phoneNumber,
      partnerExpectations: partnerExpectations,
      aboutSelf: aboutSelf,
      birthPlace: birthPlace,
      birthTime: birthTime,
      dateOfBirth: dateOfBirth ?? now,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('BiodataContent - fromProfile', () {
    test('maps personal details correctly', () {
      final profile = makeProfile();
      final content = BiodataContent.fromProfile(profile);

      expect(content.personalDetails['Full Name'], 'Rajesh');
      expect(content.personalDetails['Surname'], 'Rathod');
      expect(content.personalDetails['Age'], '28');
      expect(content.personalDetails['Height'], "5'10\"");
      expect(content.personalDetails['Gender'], 'Male');
      expect(content.personalDetails['Marital Status'], 'Never Married');
      expect(content.personalDetails['Complexion'], 'Fair');
      expect(content.personalDetails['Blood Group'], 'O+');
      expect(content.personalDetails['Birth Time'], '10:30 AM');
      expect(content.personalDetails['Birth Place'], 'Mumbai');
    });

    test('maps education/profession details correctly', () {
      final profile = makeProfile();
      final content = BiodataContent.fromProfile(profile);

      expect(content.educationProfession['Education'], 'B.E.');
      expect(content.educationProfession['Edu. Details'], 'Computer Science');
      expect(content.educationProfession['Occupation'], 'Software Engineer');
      expect(content.educationProfession['Job Details'], 'Senior Dev');
      expect(content.educationProfession['Annual Income'], '10 LPA');
      expect(content.educationProfession['Company'], 'TCS');
    });

    test('maps family details correctly', () {
      final profile = makeProfile();
      final content = BiodataContent.fromProfile(profile);

      expect(content.familyDetails['Father Name'], 'Suresh');
      expect(content.familyDetails['Father Occup.'], 'Farmer');
      expect(content.familyDetails['Mother Name'], 'Sunita');
      expect(content.familyDetails['Mother Occup.'], 'Homemaker');
      expect(content.familyDetails['Family Type'], 'Joint');
      expect(content.familyDetails['Family Status'], 'Middle Class');
      expect(content.familyDetails['Total Siblings'], '2');
      expect(content.familyDetails['Brothers'], '1');
      expect(content.familyDetails['Sisters'], '1');
    });

    test('maps location/contact details correctly', () {
      final profile = makeProfile();
      final content = BiodataContent.fromProfile(profile);

      expect(content.locationContact['Native Place'], 'Aurangabad');
      expect(content.locationContact['Contact No.'], '9876543210');
    });

    test('maps partner expectations and about me', () {
      final profile = makeProfile();
      final content = BiodataContent.fromProfile(profile);

      expect(content.partnerExpectations, 'Looking for educated partner');
      expect(content.aboutMe, 'Ambitious and kind');
    });

    test('handles null optional fields with dashes', () {
      final profile = makeProfile(
        complexion: null,
        bloodGroup: null,
        birthTime: null,
        birthPlace: null,
        educationDetails: null,
        jobDetails: null,
        annualIncome: null,
        company: null,
        fatherName: null,
        fatherOccupation: null,
        motherName: null,
        motherOccupation: null,
        familyType: null,
        familyStatus: null,
        nativePlace: null,
        phoneNumber: null,
        partnerExpectations: null,
        aboutSelf: null,
      );
      final content = BiodataContent.fromProfile(profile);

      expect(content.personalDetails['Complexion'], '-');
      expect(content.personalDetails['Blood Group'], '-');
      expect(content.personalDetails['Birth Time'], '-');
      expect(content.personalDetails['Birth Place'], '-');
      expect(content.educationProfession['Edu. Details'], '-');
      expect(content.educationProfession['Company'], '-');
      expect(content.familyDetails['Father Name'], '-');
      expect(content.locationContact['Native Place'], '-');
      expect(content.locationContact['Contact No.'], '-');
      expect(content.partnerExpectations, '');
      expect(content.aboutMe, '');
    });
  });

  group('BiodataContent - copyWith', () {
    test('copyWith overrides specified sections', () {
      final profile = makeProfile();
      final content = BiodataContent.fromProfile(profile);
      final modified = content.copyWith(
        aboutMe: 'Updated about me',
        partnerExpectations: 'Updated expectations',
      );

      expect(modified.aboutMe, 'Updated about me');
      expect(modified.partnerExpectations, 'Updated expectations');
      // Unchanged sections should remain
      expect(modified.personalDetails, content.personalDetails);
      expect(modified.educationProfession, content.educationProfession);
    });

    test('copyWith with no args preserves all sections', () {
      final profile = makeProfile();
      final content = BiodataContent.fromProfile(profile);
      final copy = content.copyWith();

      expect(copy.personalDetails, content.personalDetails);
      expect(copy.educationProfession, content.educationProfession);
      expect(copy.familyDetails, content.familyDetails);
      expect(copy.locationContact, content.locationContact);
      expect(copy.partnerExpectations, content.partnerExpectations);
      expect(copy.aboutMe, content.aboutMe);
    });
  });
}
