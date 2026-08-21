import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/filter_criteria.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/widgets/custom_image_widget.dart';

class SimilarProfilesCarousel extends StatefulWidget {
  final Map<String, dynamic> currentProfileData;

  const SimilarProfilesCarousel({
    super.key,
    required this.currentProfileData,
  });

  @override
  State<SimilarProfilesCarousel> createState() => _SimilarProfilesCarouselState();
}

class _SimilarProfilesCarouselState extends State<SimilarProfilesCarousel> {
  final ProfileRepository _profileRepository = ProfileRepository();
  List<ProfileModel> _similarProfiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSimilarProfiles();
  }

  Future<void> _fetchSimilarProfiles() async {
    final currentId = widget.currentProfileData['id']?.toString() ?? '';
    final gender = widget.currentProfileData['gender']?.toString();
    final state = widget.currentProfileData['state']?.toString();
    final currentAge = int.tryParse(widget.currentProfileData['age']?.toString() ?? '25') ?? 25;

    final filters = FilterCriteria(
      gender: gender,
      state: state,
      minAge: (currentAge - 5).clamp(18, 70),
      maxAge: (currentAge + 5).clamp(18, 70),
    );

    final res = await _profileRepository.getProfiles(
      limit: 10,
      filters: filters,
    );

    res.fold(
      onSuccess: (profiles) {
        if (mounted) {
          setState(() {
            // Exclude current profile
            _similarProfiles = profiles.where((p) => p.id != currentId).toList();
            _isLoading = false;
          });
        }
      },
      onFailure: (_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 22.h,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_similarProfiles.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              Text(
                '✨ Similar Profiles (समान रिश्ते)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.bodyLarge,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${_similarProfiles.length} profiles',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: AppTypography.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 24.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            itemCount: _similarProfiles.length,
            itemBuilder: (context, index) {
              final profile = _similarProfiles[index];
              return _SimilarProfileCard(profile: profile);
            },
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}

class _SimilarProfileCard extends StatelessWidget {
  final ProfileModel profile;

  const _SimilarProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = profile.photos.isNotEmpty ? profile.photos.first.publicUrl : '';

    return Container(
      width: 38.w,
      margin: EdgeInsets.only(right: 3.w),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.profileDetail,
              arguments: profile.toDisplayMap(),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Header
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    CustomImageWidget(
                      imageUrl: photoUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      semanticLabel: profile.fullName,
                    ),
                    if (profile.isVerified)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Content Body
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        profile.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.labelMedium,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${profile.age} Yrs • ${profile.surname}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.labelSmall,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (profile.state?.isNotEmpty == true)
                              ? profile.state!
                              : 'India',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: AppTypography.labelSmall - 1,
                            fontWeight: AppTypography.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
