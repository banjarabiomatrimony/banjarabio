import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/models/profile_model.dart';

void main() {
  group('ProfileModel Completion Scoring Tests', () {
    test('Empty map results in 0% score', () {
      final score = ProfileModel.calculateScore({});
      expect(score, equals(0));
    });

    test('Basic details (Identity + Career) contribute significantly (34%)', () {
      final data = {
        'name': 'Rahul Rathod',
        'surname': 'Rathod',
        'age': '25',
        'gender': 'Male',
        'education': 'BE',
        'profession': 'Engineer',
      };
      
      final score = ProfileModel.calculateScore(data);
      // Identity: 4(name)+4(surname)+3(male)+3(age) = 14
      // Career: 10(edu)+10(prof) = 20
      // Total = 34
      expect(score, equals(34));
    });

    test('Full profile reaches 100% completion', () {
      final data = {
        'name': 'Rahul Rathod',
        'surname': 'Rathod',
        'age': '25',
        'gender': 'Male',
        'height': "5'10\"",
        'maritalStatus': 'Never Married',
        'fatherName': 'Vikram Rathod',
        'motherName': 'Sunita Rathod',
        'siblingsCount': 2,
        'siblings': ['One brother', 'One sister'], // Added siblings data to get +5
        'education': 'Bachelor of Engineering',
        'profession': 'Software Engineer',
        'annualIncome': '10L-15L',
        'photos': ['photo1.jpg', 'photo2.jpg'],
        'state': 'Maharashtra',
        'district': 'Nagpur',
        'village': 'Umred',
        'nativePlace': 'Pusad',
        'aboutSelf': 'I am a software engineer.',
        'partnerExpectations': 'Looking for a compatible partner.',
      };
      
      final score = ProfileModel.calculateScore(data);
      // Identity: 4+4+3+3+3+3 = 20
      // Family: 5(father)+5(mother)+5(sibs data) = 15
      // Career: 10+10+5 = 25
      // Visual: 15+5 = 20
      // Preferences: 5(state)+5(dist)+2(native)+4(about)+4(expect) = 20
      // Total = 20 + 15 + 25 + 20 + 20 = 100
      expect(score, equals(100));
    });

    test('Mission-critical fields (Native Place, Village) correctly add weight', () {
      final baseData = {
        'name': 'Rahul Rathod',
        'surname': 'Rathod',
        'age': '25',
      };
      
      final scoreWithoutNative = ProfileModel.calculateScore(baseData);
      
      final dataWithNative = {
        ...baseData,
        'village': 'Umred',
        'nativePlace': 'Pusad',
      };
      
      final scoreWithNative = ProfileModel.calculateScore(dataWithNative);
      
      expect(scoreWithNative, equals(scoreWithoutNative + 2));
    });
    
    test('Staff editing (isAdminEdit) consistency', () {
      final data = {
        'name': 'Staff Added Lead',
        'phone_number': '9999999999',
        'age': '30',
        'gender': 'Female',
      };
      
      final score = ProfileModel.calculateScore(data);
      
      final json = {
        'id': 'lead-id',
        'user_id': 'lead-user-uuid',
        'full_name': 'Staff Added Lead',
        'phone_number': '9999999999',
        'age': 30,
        'gender': 'Female',
        'profile_completion': score,
      };
      
      final profile = ProfileModel.fromJson(json);
      expect(profile.profileCompletion, equals(score));
    });
  });
}
