import 'package:banjarabio/core/models/profile_model.dart';

/// Class encapsulating profile feed fetch results along with location fallback metadata.
class ProfileFeedResult {
  final List<ProfileModel> profiles;
  final bool isDistrictFallback;
  final String? requestedDistrict;
  final String? selectedState;

  const ProfileFeedResult({
    required this.profiles,
    this.isDistrictFallback = false,
    this.requestedDistrict,
    this.selectedState,
  });

  factory ProfileFeedResult.fromProfiles(List<ProfileModel> profiles) {
    return ProfileFeedResult(profiles: profiles);
  }
}
