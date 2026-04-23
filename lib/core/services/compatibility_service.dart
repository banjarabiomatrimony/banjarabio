import 'package:banjarabio/core/models/profile_model.dart';

/// Service to calculate compatibility scores between profiles
class CompatibilityService {
  /// Calculate compatibility percentage (0-100) between two profiles
  static int calculateMatchingScore(ProfileModel me, ProfileModel them) {
    double score = 0;

    // 1. Gender check (0% if same gender, as this is a traditional matrimony app)
    if (me.gender == them.gender) return 0;

    // 2. Age Compatibility (Max 25 points)
    // Ideal range: them is within +/- 5 years of me
    final ageDiff = (me.age - them.age).abs();
    if (ageDiff <= 5) {
      score += 25;
    } else if (ageDiff <= 10) {
      score += 15;
    } else {
      score += 5;
    }

    // 3. Location Proximity (Max 30 points)
    if (me.district == them.district && me.district != null) {
      score += 30;
    } else if (me.state == them.state && me.state != null) {
      score += 15;
    }

    // 4. Education & Profession (Max 25 points)
    if (me.education == them.education) {
      score += 15;
    }
    if (me.profession == them.profession) {
      score += 10;
    } else if (_isSimilarProfession(me.profession, them.profession)) {
      score += 5;
    }

    // 5. Marital Status (Max 20 points)
    if (me.maritalStatus == them.maritalStatus) {
      score += 20;
    } else if (me.maritalStatus == 'Never Married' && them.maritalStatus == 'Never Married') {
       score += 20; // Redundant but safe
    }

    return score.round().clamp(0, 100);
  }

  static bool _isSimilarProfession(String p1, String p2) {
    final s1 = p1.toLowerCase();
    final s2 = p2.toLowerCase();
    
    // Simple similarity check
    if (s1.contains('software') && s2.contains('it')) return true;
    if (s1.contains('doctor') && s2.contains('medical')) return true;
    if (s1.contains('engineer') && s2.contains('tech')) return true;
    if (s1.contains('teacher') && s2.contains('education')) return true;
    
    return false;
  }
}
