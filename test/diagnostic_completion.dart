
import 'package:flutter/foundation.dart';
// Simplified version of ProfileModel.calculateScore for testing
int calculateScore(Map<String, dynamic> data) {
  double score = 0;

  // Helper to check both snake_case and camelCase
  dynamic val(String snake, String camel) => data[snake] ?? data[camel];
  bool isSet(String snake, String camel) {
    final v = val(snake, camel);
    if (v == null) return false;
    return v.toString().trim().isNotEmpty;
  }

  // 1. Identity (20%)
  if (isSet('full_name', 'name')) {
    score += 4;
    debugPrint('full_name: +4');
  }
  if (isSet('surname', 'surname')) {
    score += 4;
    debugPrint('surname: +4');
  }
  if (isSet('gender', 'gender')) {
     final g = val('gender', 'gender').toString();
     if (g != 'Female') {
       score += 3;
       debugPrint('gender (non-default): +3');
     } else {
       score += 1;
       debugPrint('gender (default): +1');
     }
  }
  
  final age = int.tryParse(val('age', 'age')?.toString() ?? '18') ?? 18;
  if (age > 18) {
    score += 3;
    debugPrint('age (>18): +3');
  }

  final height = val('height', 'height')?.toString() ?? "5'5\"";
  if (height.isNotEmpty && height != "5'5\"") {
    score += 3;
    debugPrint('height (non-default): +3');
  }

  if (isSet('marital_status', 'maritalStatus')) {
    final m = val('marital_status', 'maritalStatus').toString();
    if (m != 'Never Married') {
      score += 3;
      debugPrint('marital_status (non-default): +3');
    } else {
      score += 1;
      debugPrint('marital_status (default): +1');
    }
  }

  // 2. Family (15%)
  bool hasParent = false;
  if (isSet('father_name', 'fatherName')) { score += 5; hasParent = true; debugPrint('father_name: +5'); }
  if (isSet('mother_name', 'motherName')) { score += 5; hasParent = true; debugPrint('mother_name: +5'); }
  
  final sibsCount = int.tryParse(val('siblings_count', 'siblingsCount')?.toString() ?? '0') ?? 0;
  final hasSibsData = (val('siblings_data', 'siblings') as List?)?.isNotEmpty ?? false;
  if (hasSibsData || (sibsCount == 0 && hasParent)) {
    score += 5;
    debugPrint('siblings info: +5');
  }

  // 3. Career (25%)
  if (isSet('education', 'education')) { score += 10; debugPrint('education: +10'); }
  if (isSet('profession', 'profession')) { score += 10; debugPrint('profession: +10'); }
  if (isSet('annual_income', 'annualIncome')) { score += 5; debugPrint('annual_income: +5'); }

  // 4. Visual (20%)
  final photos = val('photos', 'photos') as List?;
  if (photos != null && photos.isNotEmpty) {
    score += 15;
    debugPrint('photos: +15');
    if (photos.length > 1) { score += 5; debugPrint('extra photos: +5'); }
  }

  // 5. Preferences (20%)
  if (isSet('state', 'state')) { score += 5; debugPrint('state: +5'); }
  if (isSet('district', 'district')) { score += 5; debugPrint('district: +5'); }
  if (isSet('taluka', 'taluka') || isSet('native_place', 'nativePlace')) { score += 2; debugPrint('location details: +2'); }
  if (isSet('about_self', 'aboutSelf')) { score += 4; debugPrint('about_self: +4'); }
  if (isSet('expectation', 'expectation') || isSet('partner_expectations', 'partnerExpectations')) { score += 4; debugPrint('expectation: +4'); }

  debugPrint('TOTAL: $score');
  return score.round().clamp(0, 100);
}

void main() {
  debugPrint('--- SCENARIO 1: Basic Male Lead (No location) ---');
  calculateScore({
    'full_name': 'Suresh',
    'surname': 'Jadhav',
    'age': 25,
    'gender': 'Male',
    'height': "5'8\"",
    'marital_status': 'Never Married', // Added now that constructor is fixed
  });

  debugPrint('\n--- SCENARIO 4: The 34% Mystery Search ---');
  // Let's try to hit 34
  calculateScore({
    'name': 'Test',
    'surname': 'User',
    'gender': 'Male', // +3
    'age': 25, // +3
    'height': "5'8\"", // +3
    'marital_status': 'Never Married', // +1
    'state': 'Maharashtra', // +5
    'district': 'Pune', // +5
    'father_name': 'Father', // +5
    // No mother name
  });
  
  debugPrint('\n--- SCENARIO 5: Full Basic Lead (+ Parents) ---');
  calculateScore({
    'name': 'Test',
    'surname': 'User',
    'gender': 'Male', // +3
    'age': 25, // +3
    'height': "5'8\"", // +3
    'marital_status': 'Never Married', // +1
    'father_name': 'Father', // +5
    'mother_name': 'Mother', // +5
    'siblings_count': 0, // +5 (because parents are set)
    'state': 'Maharashtra', // +5
  });
}
