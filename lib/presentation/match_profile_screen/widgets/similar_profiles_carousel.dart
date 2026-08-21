import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/filter_criteria.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/widgets/custom_image_widget.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

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
        height: 24.h,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_similarProfiles.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)?.similarMatches ?? 'Similar Matches (समान रिश्ते)',
                style:                 AppTypography.bodyStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.bodyLarge,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  AppLocalizations.of(context)?.verifiedCountBadge(_similarProfiles.length) ??
                      '${_similarProfiles.length} verified',
                  style:                   AppTypography.buttonStyle(
                    color: theme.colorScheme.primary,
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 25.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            itemCount: _similarProfiles.length,
            itemBuilder: (context, index) {
              final profile = _similarProfiles[index];
              return _SimilarProfileCard(profile: profile, isDark: isDark);
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
  final bool isDark;

  const _SimilarProfileCard({
    required this.profile,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = profile.photos.isNotEmpty ? profile.photos.first.publicUrl : '';

    return Container(
      width: 40.w,
      margin: EdgeInsets.only(right: 3.w, bottom: 0.5.h),
      child: TactilePressable(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.profileDetail,
            arguments: profile.toDisplayMap(),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate800 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: AppColors.opacity10)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Header
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: AppColors.categoryLocation,
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
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        profile.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:                         AppTypography.bodyStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: AppTypography.black,
                          fontSize: AppTypography.labelMedium,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)?.ageAndSurnameSubtitle(
                              profile.age.toString(),
                              profile.surname,
                            ) ??
                            '${profile.age} Yrs • ${profile.surname}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppTypography.labelSmall,
                          color: AppColors.slate500,
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 11,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              (profile.state?.isNotEmpty == true)
                                  ? profile.state!
                                  : (AppLocalizations.of(context)?.india ?? 'India'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:                               AppTypography.buttonStyle(
                                color: theme.colorScheme.primary,
                                fontSize: AppTypography.labelTiny,
                              ),
                            ),
                          ),
                        ],
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
