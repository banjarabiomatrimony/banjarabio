import 'dart:math';

/// Service responsible for synthesizing user bios based on profile data.
class BioSynthesisService {
  final Random _random;

  BioSynthesisService({Random? random}) : _random = random ?? Random();

  /// Generates a bio based on user data and subscription status.
  String generateBio({
    required Map<String, dynamic> data,
    required bool isPremium,
  }) {
    if (isPremium) {
      return _buildPremiumAIBio(data);
    } else {
      return _buildFreeTemplateBio(data);
    }
  }

  String _buildFreeTemplateBio(Map<String, dynamic> data) {
    final name = data['name'] ?? 'User';
    final profession = data['profession']?.toString().isNotEmpty == true ? data['profession'] : 'Professional';
    final education = data['education']?.toString().isNotEmpty == true ? data['education'] : 'Qualified';
    final state = data['state']?.toString().isNotEmpty == true ? data['state'] : 'City';
    final district = data['district']?.toString().isNotEmpty == true ? data['district'] : '';
    final gender = data['gender']?.toString().toLowerCase() == 'male' ? 'man' : 'woman';

    final intros = [
      'I am $name, a $education currently working as a $profession.',
      'Professional $profession $name with a $education degree.',
      'Currently working as a $profession, I am $name from $district.',
    ];

    final middles = [
      'I am based in $district, $state.',
      'I reside in $district, $state.',
      'I belong to $state.',
    ];

    final concludes = [
      'As a $gender seeking a compatible life partner, I am looking for someone who shares similar values.',
      'I am a simple and career-oriented $gender seeking a compatible life partner.',
      'I value family traditions and am looking for a partner to build a future with as a $gender.',
    ];

    return '${_getRandom(intros)} ${_getRandom(middles)} ${_getRandom(concludes)}';
  }

  String _buildPremiumAIBio(Map<String, dynamic> data) {
    final name = data['name'] ?? '';
    final age = data['age'] ?? '';
    final profession = data['profession']?.toString().isNotEmpty == true ? data['profession'] : 'Professional';
    final education = data['education']?.toString().isNotEmpty == true ? data['education'] : 'Qualified';
    final state = data['state']?.toString().isNotEmpty == true ? data['state'] : 'City';
    final district = data['district']?.toString().isNotEmpty == true ? data['district'] : '';
    final familyType = data['familyType']?.toString().isNotEmpty == true ? data['familyType'] : 'Close-knit';
    final maritalStatus = data['maritalStatus']?.toString().toLowerCase() ?? 'never married';
    final isMale = data['gender']?.toString().toLowerCase() == 'male';
    
    final personNoun = isMale ? 'gentleman' : 'lady';
    final pronoun = isMale ? 'He' : 'She';
    final possessive = isMale ? 'his' : 'her';

    final intros = [
      'I am $name, a driven $education professional currently shaping a career as a $profession in $district.',
      'Blending professional ambition with deep-rooted values, I am $name, a $profession with a background in $education.',
      'As a $age-year-old $profession based in $state, I ($name) believe in leading a life of purpose and kindness.',
      'My journey as a $profession has been shaped by my $education and a commitment to excellence, I am $name.',
    ];

    final familyLine = [
      'Coming from a $familyType family, I value the balance between modern growth and traditional roots, especially in $district.',
      'Raised with strong $familyType family values in $state, I appreciate intellectual depth and meaningful connections.',
      'My $familyType family in $district has instilled in me a respect for our community and culture.',
      '$pronoun comes from a $familyType background where family remains the cornerstone of $possessive life.',
    ];

    final personality = [
      'I identify as an ambitious yet grounded $maritalStatus $personNoun who enjoys exploring new perspectives.',
      "Beyond my career as a $profession, I am a $maritalStatus $personNoun who finds joy in life's simple adventures.",
      'I am a $maritalStatus $personNoun looking for a companion to build a world of mutual respect.',
      'As a $maritalStatus $personNoun, I strive for a balance between career aspirations and personal well-being.',
    ];

    final closing = [
      "I'm searching for a partner who is ready to share the beautiful journey of life ahead.",
      'Seeking a life partner who values both professional excellence and family warmth.',
      'Looking forward to finding a compatible soul who believes in growth, trust, and companionship.',
      'I hope to meet someone who shares $possessive outlook on life and values family above all.',
    ];

    return '${_getRandom(intros)} ${_getRandom(familyLine)} ${_getRandom(personality)} ${_getRandom(closing)}';
  }

  String _getRandom(List<String> list) {
    return list[_random.nextInt(list.length)];
  }
}
