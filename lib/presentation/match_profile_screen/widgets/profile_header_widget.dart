import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/widgets/upgrade_dialog.dart';

/// 🌟 Elevated Profile Header Widget with Parallax Photo Carousel,
/// Plan-Aware Top/Center Overlays (Trust Score, Completion, Plan Badge, Photo Counter, ID),
/// and Frosted Glassmorphic Compact Identity Card with 3 Mini-Pills.
class ProfileHeaderWidget extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final bool isPremium;
  final VoidCallback? onOptionsTap;

  const ProfileHeaderWidget({
    super.key,
    required this.profileData,
    required this.isPremium,
    this.onOptionsTap,
  });

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget>
    with SingleTickerProviderStateMixin {
  int _currentPhotoIndex = 0;
  final PageController _pageController = PageController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Detect plan tier from profile data & premium status
    final tier = (widget.profileData['membership_tier'] ??
            widget.profileData['subscription_tier'] ??
            widget.profileData['plan_type'] ??
            '')
        .toString()
        .toLowerCase();
    final isVip = widget.profileData['isVip'] == true ||
        tier.contains('vip') ||
        tier.contains('elite') ||
        tier.contains('royal');
    final isBvs = widget.profileData['isBvsVerified'] == true ||
        widget.profileData['isCommunityTrusted'] == true ||
        tier.contains('bvs') ||
        tier.contains('community');
    final isSelfService = !isVip && !isBvs && (widget.isPremium || tier.contains('gold') || tier.contains('platinum') || tier.contains('silver') || tier.contains('standard') || tier.contains('eternal'));
    final isFree = !isVip && !isBvs && !isSelfService;

    // Photos list
    final rawPhotos = (widget.profileData['photos'] as List<dynamic>? ?? []);
    final hasPhotos = rawPhotos.isNotEmpty;
    final totalPhotosCount = hasPhotos ? rawPhotos.length : 1;

    // In Free tier: show 1 photo freely; remaining photos locked
    final displayPhotos = (isFree && !widget.isPremium)
        ? rawPhotos.take(1).toList()
        : (hasPhotos ? rawPhotos : ['']);

    final effectivePhotos = displayPhotos.isEmpty ? [''] : displayPhotos;

    // Candidate details
    final name = widget.profileData['name']?.toString() ??
        widget.profileData['fullName']?.toString() ??
        (AppLocalizations.of(context)?.banjaraMember ?? 'Banjara Member');
    final age = widget.profileData['age']?.toString() ?? '';
    final height = widget.profileData['height']?.toString() ?? "5'6\"";
    final isVerified = widget.profileData['isVerified'] as bool? ?? false;
    final displayId = widget.profileData['displayId']?.toString() ??
        widget.profileData['id']?.toString() ??
        'BB-1024';
    final trustScore = (widget.profileData['trust_score'] as num?)?.toInt() ??
        (widget.profileData['trustScore'] as num?)?.toInt() ??
        92;
    final completion = (widget.profileData['profileCompletion'] as num?)?.toInt() ??
        (widget.profileData['completionPercentage'] as num?)?.toInt() ??
        90;
    final compatibility = (widget.profileData['compatibility'] as num?)?.toInt() ??
        (widget.profileData['compatibilityScore'] as num?)?.toInt() ??
        92;

    final gotra = widget.profileData['gotra']?.toString() ?? '';
    final profession = widget.profileData['profession']?.toString() ??
        widget.profileData['occupation']?.toString() ??
        '';
    final workingStatus = (widget.profileData['working_status']?.toString().isNotEmpty == true)
        ? widget.profileData['working_status'].toString()
        : (profession.isNotEmpty
            ? (AppLocalizations.of(context)?.working ?? 'Working')
            : (AppLocalizations.of(context)?.notWorking ?? 'Not Working'));
    final location = widget.profileData['location']?.toString() ??
        widget.profileData['city']?.toString() ??
        widget.profileData['district']?.toString() ??
        'Pune, Maharashtra';
    final tanda = widget.profileData['tanda']?.toString() ??
        widget.profileData['nativeTanda']?.toString() ??
        '';
    final income = widget.profileData['annual_income']?.toString() ?? '';
    final education = widget.profileData['education']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      width: 94.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 📸 1. Multi-Photo Slider
            PageView.builder(
              controller: _pageController,
              itemCount: effectivePhotos.length,
              onPageChanged: (index) {
                setState(() => _currentPhotoIndex = index);
              },
              itemBuilder: (context, index) {
                final photoData = effectivePhotos[index];
                final imageUrl = photoData is Map
                    ? photoData['url']?.toString() ?? ''
                    : photoData?.toString() ?? '';
                final semanticLabel = photoData is Map
                    ? photoData['semanticLabel']?.toString() ?? 'Photo'
                    : 'Profile photo';

                return GestureDetector(
                  onTap: () =>
                      _showFullScreenPhoto(context, imageUrl, semanticLabel),
                  child: Hero(
                    tag: 'profile_${widget.profileData['id']}_$index',
                    child: CustomImageWidget(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      semanticLabel: semanticLabel,
                      isHighQuality: true,
                    ),
                  ),
                );
              },
            ),

            // 🌓 2. Multi-Stop Cinematic Shadow Gradient
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.48),
                        Colors.transparent,
                        Colors.black.withValues(alpha: AppColors.opacity20),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.0, 0.18, 0.50, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // 🌟 3. TOP BAR: [← Back] [🆔 Profile ID] <── spaceBetween ──> [📸 Photo Counter] [⋮ More]
            Positioned(
              top: MediaQuery.paddingOf(context).top + 10,
              left: 56,
              right: 56,
              child: _buildTopBar(
                context,
                isDark: isDark,
                currentIndex: _currentPhotoIndex + 1,
                totalPhotos: totalPhotosCount,
                displayId: displayId,
                isFree: isFree,
                isBvs: isBvs,
                isVip: isVip,
              ),
            ),

            // 💎 4. BOTTOM COMPACT GLASS CARD (Row 1 + Row 2 Direct Text + Row 3 Badges)
            Positioned(
              bottom: 1.2.h,
              left: 2.8.w,
              right: 2.8.w,
              child: _buildCompactGlassCard(
                context,
                name: name,
                age: age,
                height: height,
                gotra: gotra,
                workingStatus: workingStatus,
                profession: profession,
                location: location,
                tanda: tanda,
                income: income,
                education: education,
                isVerified: isVerified,
                trustScore: trustScore,
                completion: completion,
                compatibility: compatibility,
                isFree: isFree,
                isBvs: isBvs,
                isSelfService: isSelfService,
                isVip: isVip,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TOP BAR (Top Left: Profile ID, Top Right: Photo Counter)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTopBar(
    BuildContext context, {
    required bool isDark,
    required int currentIndex,
    required int totalPhotos,
    required String displayId,
    required bool isFree,
    required bool isBvs,
    required bool isVip,
  }) {
    final idPrefix = isVip
        ? '👑 VIP'
        : isBvs
            ? '🏛️ BVS'
            : 'ID';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top Left: Profile ID Badge
        _buildFrostedPill(
          icon: Icons.badge_rounded,
          iconColor: Colors.white,
          text: '$idPrefix: $displayId',
          gradient: [
            Colors.black.withValues(alpha: 0.45),
            Colors.black.withValues(alpha: 0.45),
          ],
        ),

        // Top Right: Photo Counter or Teaser Lock
        if (isFree && totalPhotos > 1)
          TactilePressable(
            onTap: () => UpgradeDialog.showPhotoLimit(context, 0, 1),
            child: _buildFrostedPill(
              icon: Icons.lock_rounded,
              iconColor: AppColors.categoryAstro,
              text: AppLocalizations.of(context)?.onePhotoLockedTeaser(totalPhotos - 1) ??
                  '📸 1 Photo (🔒 +${totalPhotos - 1})',
              gradient: [
                AppColors.categoryAstro.withValues(alpha: AppColors.opacity25),
                Colors.black.withValues(alpha: AppColors.opacity50),
              ],
            ),
          )
        else
          _buildFrostedPill(
            icon: Icons.photo_camera_rounded,
            iconColor: Colors.white,
            text: '📸 $currentIndex/$totalPhotos',
            gradient: [
              Colors.black.withValues(alpha: 0.45),
              Colors.black.withValues(alpha: 0.45),
            ],
          ),
      ],
    );
  }

  Widget _buildPlanJewelBadge({
    required bool isFree,
    required bool isBvs,
    required bool isSelfService,
    required bool isVip,
  }) {
    if (isVip) {
      return _buildFrostedPill(
        icon: Icons.workspace_premium_rounded,
        iconColor: AppColors.goldTint200,
        text: AppLocalizations.of(context)?.vipRoyal ?? '👑 VIP Royal',
        gradient: const [
          AppColors.categoryAstro,
          AppColors.categoryAstroDark,
        ],
        borderHighlight: AppColors.goldTint200,
      );
    } else if (isBvs) {
      return _buildFrostedPill(
        icon: Icons.account_balance_rounded,
        iconColor: AppColors.goldTint200,
        text: AppLocalizations.of(context)?.bvsMember ?? '🏛️ BVS Member',
        gradient: const [
          AppColors.crimsonDeep, // BVS Crimson
          AppColors.crimsonDarkBg,
        ],
        borderHighlight: AppColors.goldTint200,
      );
    } else if (isSelfService) {
      return _buildFrostedPill(
        icon: Icons.star_rounded,
        iconColor: AppColors.goldTint200,
        text: AppLocalizations.of(context)?.goldMember ?? '⭐ Gold Member',
        gradient: const [
          AppColors.categoryLocationDark,
          AppColors.emerald,
        ],
      );
    }

    // Free Plan Badge
    return _buildFrostedPill(
      icon: Icons.person_rounded,
      iconColor: Colors.white70,
      text: AppLocalizations.of(context)?.freePlan ?? 'Free Plan',
      gradient: [
        Colors.black.withValues(alpha: 0.45),
        Colors.black.withValues(alpha: 0.45),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOTTOM COMPACT GLASS CARD (Row 1 + Row 2 Mini-Pills + Matrimonial Subtitle)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCompactGlassCard(
    BuildContext context, {
    required String name,
    required String age,
    required String height,
    required String gotra,
    required String workingStatus,
    required String profession,
    required String location,
    required String tanda,
    required String income,
    required String education,
    required bool isVerified,
    required int trustScore,
    required int completion,
    required int compatibility,
    required bool isFree,
    required bool isBvs,
    required bool isSelfService,
    required bool isVip,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 1.2.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.46),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Row 1: Candidate Name, Age + Verified Shield (Start) <---> Match Pill (End) ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            age.isNotEmpty ? '$name, $age' : name,
                            style:                             AppTypography.displayStyle(
                              color: isVip ? AppColors.goldTint200 : Colors.white,
                              fontSize: AppTypography.headingSmall,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          SizedBox(width: 1.5.w),
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                color: AppColors.categoryLocation.withValues(alpha: AppColors.opacity25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_rounded,
                                color: AppColors.categoryLocation,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                        if (isVip) ...[
                          SizedBox(width: 1.0.w),
                          Text(
                            '👑',
                            style: TextStyle(fontSize: AppTypography.bodyMedium),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  // Floating Luxury Match Pill (Gold/Rose gradient - End position)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.6.w, vertical: 0.35.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.categoryAstro, AppColors.categoryPersonal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.flash_on_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        SizedBox(width: 0.8.w),
                        Text(
                          AppLocalizations.of(context)?.percentMatchBadge(compatibility) ??
                              '$compatibility% Match',
                          style:                           AppTypography.bodyStyle(
                            color: Colors.white,
                            fontWeight: AppTypography.black,
                            fontSize: AppTypography.labelSmall,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.7.h),

              // ─── Row 2: Direct Demographics Text (Full Width Continuous Flow) ───
              Text.rich(
                TextSpan(
                  children: [
                    if (height.isNotEmpty) ...[
                      TextSpan(
                        text: height,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: AppTypography.bodyMedium,
                          fontWeight: AppTypography.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' • ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: AppTypography.bodyMedium,
                          fontWeight: AppTypography.black,
                        ),
                      ),
                    ],
                    TextSpan(
                      text: (workingStatus == 'Working' && profession.isNotEmpty)
                          ? profession
                          : workingStatus,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.semiBold,
                      ),
                    ),
                    if (location.isNotEmpty) ...[
                      TextSpan(
                        text: ' • ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: AppTypography.bodyMedium,
                          fontWeight: AppTypography.black,
                        ),
                      ),
                      TextSpan(
                        text: location,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: AppTypography.bodyMedium,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                    ],
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.8.h),

              // ─── Row 3: 3 Badges (Trust Score • Profile Completion • Plan Jewel) ───
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // 1. Trust Score Badge
                    _buildFrostedPill(
                      icon: Icons.verified_user_rounded,
                      iconColor: AppColors.categoryLocation,
                      text: AppLocalizations.of(context)?.percentTrustBadge(trustScore) ??
                          '$trustScore% Trust',
                      gradient: [
                        AppColors.categoryLocation.withValues(alpha: AppColors.opacity35),
                        AppColors.emerald.withValues(alpha: 0.45),
                      ],
                    ),
                    SizedBox(width: 1.8.w),

                    // 2. Profile Completion Badge
                    _buildFrostedPill(
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: AppColors.skyBlueBright,
                      text: AppLocalizations.of(context)?.percentCompleteBadge(completion) ??
                          '$completion% Complete',
                      gradient: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                    SizedBox(width: 1.8.w),

                    // 3. Subscription Plan Badge
                    _buildPlanJewelBadge(
                      isFree: isFree,
                      isBvs: isBvs,
                      isSelfService: isSelfService,
                      isVip: isVip,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER FROSTED PILL
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildFrostedPill({
    required IconData icon,
    required Color iconColor,
    required String text,
    required List<Color> gradient,
    Color? borderHighlight,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.6.w, vertical: 0.4.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderHighlight ?? Colors.white.withValues(alpha: AppColors.opacity25),
              width: borderHighlight != null ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: iconColor),
              SizedBox(width: 1.0.w),
              Text(
                text,
                style:                 AppTypography.buttonStyle(
                  fontSize: AppTypography.labelSmall,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenPhoto(
    BuildContext context,
    String imageUrl,
    String semanticLabel,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CustomImageWidget(
                    imageUrl: imageUrl,
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.contain,
                    semanticLabel: semanticLabel,
                  ),
                ),
              ),
              Positioned(
                top: 5.h,
                left: 3.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: AppColors.opacity60),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
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
