import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/services/profile_display_policy.dart';
import 'package:banjarabio/core/services/share_service.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/theme/app_gradients.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

import 'package:banjarabio/presentation/match_profile_screen/widgets/direct_note_bottom_sheet.dart';

class ProfileCardWidget extends StatefulWidget {
  final ProfileModel profile;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final Function(ProfileModel) onShare;
  final Function(ProfileModel) onInterest;
  final Function(ProfileModel)? onMessage;
  final bool useHero;
  final PlanType? viewerPlan;
  final bool showActionButtons;

  const ProfileCardWidget({
    super.key,
    required this.profile,
    required this.onTap,
    required this.onBookmark,
    required this.onShare,
    required this.onInterest,
    this.onMessage,
    this.useHero = false,
    this.viewerPlan,
    this.showActionButtons = true,
  });

  @override
  State<ProfileCardWidget> createState() => _ProfileCardWidgetState();
}

class _ProfileCardWidgetState extends State<ProfileCardWidget>
    with TickerProviderStateMixin {
  late bool _isBookmarked;
  int _currentPhotoIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  late PageController _pageController;
  double _bookmarkScale = 1.0;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.profile.isBookmarked;
    _pageController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProfileCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.isBookmarked != oldWidget.profile.isBookmarked) {
      _isBookmarked = widget.profile.isBookmarked;
    }
  }

  void _handleBookmark() async {
    if (kDebugMode) {
      AppLogger.debug('ProfileCardWidget', '[BOOKMARK] Tapped bookmark for ${widget.profile.id}');
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _bookmarkScale = 1.35;
      _isBookmarked = !_isBookmarked;
    });
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      setState(() {
        _bookmarkScale = 1.0;
      });
    }
    Future.microtask(() => widget.onBookmark());
  }

  List<Color> _getBorderColors(bool isDark, bool isMatched, int trustScore, int gunMilan) {
    if (isMatched || gunMilan >= 28) {
      // 💍 Sacred Romance & High Astrological Match: Ruby & Crimson Rose Gradient
      return const [
        Color(0xFFE11D48),
        Color(0xFFFF4D8D),
        Color(0xFFBE123C),
        Color(0xFFFF2A6D),
        Color(0xFFE11D48),
      ];
    } else if (widget.profile.isPremium) {
      // 👑 VIP / Gold / Platinum: 24K Sacred Gold Shimmer Gradient
      return const [
        Color(0xFFFFD700),
        Color(0xFFF59E0B),
        Color(0xFFFBBF24),
        Color(0xFFD97706),
        Color(0xFFFFD700),
      ];
    } else if (widget.profile.isVerified || trustScore >= 80) {
      // 🛡️ ID Verified & High Trust: Electric Sapphire & Sky Blue Gradient
      return const [
        Color(0xFF2563EB),
        Color(0xFF38BDF8),
        Color(0xFF1D4ED8),
        Color(0xFF60A5FA),
        Color(0xFF2563EB),
      ];
    } else if (_isBookmarked) {
      // 🔖 Shortlisted / Saved: Royal Amethyst Purple Gradient
      return const [
        Color(0xFF7C3AED),
        Color(0xFFA855F7),
        Color(0xFF6D28D9),
        Color(0xFFC084FC),
        Color(0xFF7C3AED),
      ];
    } else {
      // ✨ Standard Candidate: Vibrant Rose-Gold Matrimonial Gradient Outline
      return isDark
          ? [
              const Color(0xFFBE123C).withValues(alpha: 0.85),
              const Color(0xFFF59E0B).withValues(alpha: 0.75),
              const Color(0xFF6366F1).withValues(alpha: 0.60),
              const Color(0xFFBE123C).withValues(alpha: 0.85),
            ]
          : [
              const Color(0xFFE11D48).withValues(alpha: 0.90),
              const Color(0xFFD97706).withValues(alpha: 0.80),
              const Color(0xFF4F46E5).withValues(alpha: 0.70),
              const Color(0xFFE11D48).withValues(alpha: 0.90),
            ];
    }
  }

  Color _getShadowGlowColor(bool isDark, bool isMatched, int trustScore, int gunMilan) {
    if (isMatched || gunMilan >= 28) {
      return const Color(0xFFE11D48).withValues(alpha: isDark ? 0.38 : 0.22);
    } else if (widget.profile.isPremium) {
      return const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.40 : 0.25);
    } else if (widget.profile.isVerified || trustScore >= 80) {
      return const Color(0xFF2563EB).withValues(alpha: isDark ? 0.35 : 0.20);
    } else if (_isBookmarked) {
      return const Color(0xFF7C3AED).withValues(alpha: isDark ? 0.35 : 0.20);
    } else {
      return const Color(0xFFE11D48).withValues(alpha: isDark ? 0.25 : 0.12);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 🛡️ Resolve viewer's plan from widget or global session
    bool isPremiumViewer = false;
    ProfileModel? viewerProfile;
    try {
      isPremiumViewer = SessionManager.instance.isPremium;
      viewerProfile = SessionManager.instance.currentProfile;
    } catch (_) {}

    final viewerPlan = widget.viewerPlan ??
        (isPremiumViewer ? PlanType.premium : PlanType.free);

    // 👑 Centralized Policy Data Extractions
    final displayName = ProfileDisplayPolicy.getDisplayName(widget.profile);
    final gotraInfo = ProfileDisplayPolicy.getGotraInfo(widget.profile, viewerPlan: viewerPlan);
    final formattedEducation = ProfileDisplayPolicy.getFormattedEducation(widget.profile);
    final kundaliInfo = ProfileDisplayPolicy.getKundaliInfo(
      widget.profile,
      viewerPlan: viewerPlan,
      viewerProfile: viewerProfile,
    );
    final candidateSubBadge = ProfileDisplayPolicy.getCandidateSubscriptionBadge(widget.profile);
    final completionLabel = ProfileDisplayPolicy.getProfileCompletionLabel(widget.profile);
    final trustScore = ProfileDisplayPolicy.getDynamicTrustScore(widget.profile);
    final gunMilan = kundaliInfo.gunMilanMatched;

    final displayMap = widget.profile.toDisplayMap();
    final photos = displayMap['photos'] as List? ?? [];
    final primaryPhoto = photos.isNotEmpty ? photos[0] as Map<String, dynamic> : null;
    final location = widget.profile.locationExcludingVillage;
    final isMatched = widget.profile.isMatched;

    final borderColors = _getBorderColors(isDark, isMatched, trustScore, gunMilan);
    final glowColor = _getShadowGlowColor(isDark, isMatched, trustScore, gunMilan);

    return RepaintBoundary(
      child: Semantics(
        label: 'Profile card of $displayName, age ${widget.profile.age}, from $location.',
        hint: 'Double tap to view full profile details.',
        child: TactilePressable(
          onTap: () {
            HapticFeedback.selectionClick();
            Future.microtask(() => widget.onTap());
          },
          pressedScale: 0.985,
          child: AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, _) {
              return Container(
                margin: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: SweepGradient(
                    colors: borderColors,
                    stops: borderColors.length == 5
                        ? const [0.0, 0.25, 0.5, 0.75, 1.0]
                        : const [0.0, 0.35, 0.7, 1.0],
                    transform: GradientRotation(_shimmerAnimation.value * 2 * math.pi),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor,
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(1.8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22.2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF191924) : theme.colorScheme.surface,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                  // ──────────────────────────────────────────
                  // 1. 📸 Full-Bleed Hero Portrait / Gallery
                  // ──────────────────────────────────────────
                  photos.length <= 1
                      ? CustomImageWidget(
                          imageUrl: primaryPhoto?['url'] as String?,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          semanticLabel: primaryPhoto?['semanticLabel'] as String?,
                        )
                      : PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentPhotoIndex = index);
                          },
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            final photo = photos[index] as Map<String, dynamic>;
                            final child = CustomImageWidget(
                              imageUrl: photo['url'] as String?,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              isHighQuality: true,
                              semanticLabel: photo['semanticLabel'] as String?,
                            );
                            if (!widget.useHero) return child;
                            return Hero(
                              tag: 'profile_${widget.profile.id}_$index',
                              child: child,
                            );
                          },
                        ),

                  // 📸 Touch Navigation Zones (Left/Right to cycle photos)
                  if (photos.length > 1)
                    Positioned.fill(
                      bottom: 30.h,
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (_currentPhotoIndex > 0) {
                                  HapticFeedback.selectionClick();
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 260),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                if (_currentPhotoIndex < photos.length - 1) {
                                  HapticFeedback.selectionClick();
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 260),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ──────────────────────────────────────────
                  // 2. 🌓 Deep Dramatic Gradient Overlay
                  // ──────────────────────────────────────────
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black45,
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black54,
                              Colors.black87,
                              Colors.black,
                            ],
                            stops: [0.0, 0.15, 0.40, 0.65, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ──────────────────────────────────────────
                  // 3. 🔵 Photo Dot Indicators (Centered Top)
                  // ──────────────────────────────────────────
                  if (photos.length > 1)
                    Positioned(
                      top: 1.2.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          photos.length,
                          (index) {
                            final isActive = index == _currentPhotoIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                              width: isActive ? 18 : 6,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // ──────────────────────────────────────────
                  // 4. 🌟 TOP-LEFT OVERLAY BADGES
                  // ──────────────────────────────────────────
                  Positioned(
                    top: 2.2.h,
                    left: 3.5.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Gotra / Sub-caste Pill
                        _buildGotraBadge(context, gotraInfo, isDark),
                        if (isMatched) ...[
                          SizedBox(height: 0.6.h),
                          _buildGradientBadge(
                            context,
                            AppLocalizations.of(context)?.matched ?? 'MATCHED 💍',
                            AppGradients.romance.colors,
                            Icons.favorite_rounded,
                          ),
                        ],
                        if (widget.profile.isDisabled) ...[
                          SizedBox(height: 0.6.h),
                          _buildGradientBadge(
                            context,
                            AppLocalizations.of(context)?.disabledTagLabel ?? 'SPECIAL CARE',
                            [Colors.indigo.shade600, Colors.deepPurpleAccent],
                            Icons.accessible_forward_rounded,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ──────────────────────────────────────────
                  // 5. 🛡️ TOP-RIGHT OVERLAY BADGES
                  // ──────────────────────────────────────────
                  Positioned(
                    top: 2.2.h,
                    right: 3.5.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Subscription Plan Jewel Badge (VIP/Gold/Platinum - Omitted for Free/BVS)
                        if (candidateSubBadge != null) ...[
                          _buildSubscriptionJewelBadge(context, candidateSubBadge),
                          SizedBox(height: 0.6.h),
                        ],
                        // Compulsory Badges Row: [ 🛡️ score% ] [ 👥 count ]
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTrustScorePill(
                              context,
                              ProfileDisplayPolicy.getDynamicTrustScore(widget.profile),
                            ),
                            SizedBox(width: 1.5.w),
                            _buildVouchesBadge(context, widget.profile.vouchCount),
                          ],
                        ),
                        SizedBox(height: 0.6.h),
                        // 📊 % Bio Complete Card (Right Top, exactly below Trust Score & Vouches)
                        _buildCompletionPill(context, completionLabel),
                      ],
                    ),
                  ),

                  // ──────────────────────────────────────────
                  // 6. 📄 BOTTOM MATRIMONIAL DECISION PANE
                  // ──────────────────────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        3.5.w,
                        widget.showActionButtons ? 1.3.h : 0.8.h,
                        3.5.w,
                        widget.showActionButtons ? 1.0.h : 0.6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.98),
                            Colors.black.withValues(alpha: 0.85),
                            Colors.black.withValues(alpha: 0.40),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 0.85, 1.0],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Row 1: Name, Age, Height & Verified ───
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '$displayName, ${widget.profile.age}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: AppTypography.black,
                                    fontSize: AppTypography.headingMedium,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black87,
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.profile.height.isNotEmpty) ...[
                                Text(
                                  ' • ${widget.profile.height}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: AppTypography.bold,
                                    fontSize: AppTypography.bodyLarge,
                                  ),
                                ),
                              ],
                              if (widget.profile.isVerified) ...[
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF3B82F6),
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 0.4.h),

                          // ─── Row 2: Education Bracket & Marital Status ───
                          Row(
                            children: [
                              const Icon(
                                Icons.school_rounded,
                                size: 14,
                                color: Color(0xFF93C5FD),
                              ),
                              SizedBox(width: 1.5.w),
                              Expanded(
                                child: Text(
                                  '$formattedEducation • ${widget.profile.maritalStatus}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    fontSize: AppTypography.bodySmall,
                                    fontWeight: AppTypography.semiBold,
                                    shadows: const [Shadow(color: Colors.black87, blurRadius: 2)],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.3.h),

                          // ─── Row 3: Location & District ───
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Color(0xFFFDA4AF),
                              ),
                              SizedBox(width: 1.5.w),
                              Expanded(
                                child: Text(
                                  location,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: AppTypography.bodySmall,
                                    fontWeight: AppTypography.medium,
                                    shadows: const [Shadow(color: Colors.black87, blurRadius: 2)],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.6.h),

                          // ─── Row 4: Compatibility / Kundali Teaser Bar ───
                          _buildKundaliTeaserBar(context, kundaliInfo),
                          if (widget.showActionButtons) ...[
                            SizedBox(height: 0.8.h),

                            // ─── Row 5: 1-Tap Quick Action Row ───
                            if (widget.profile.isMatched)
                              Row(
                                children: [
                                  // 1. 🔖 Bookmark / Shortlist Button with Spring Scale
                                  _buildQuickActionButton(
                                    context: context,
                                    icon: _isBookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: _isBookmarked
                                        ? const Color(0xFFF59E0B)
                                        : Colors.white.withValues(alpha: 0.18),
                                    iconColor: _isBookmarked ? Colors.black : Colors.white,
                                    onTap: _handleBookmark,
                                    scale: _bookmarkScale,
                                    semanticsLabel: _isBookmarked
                                        ? 'Remove bookmark for $displayName'
                                        : 'Bookmark $displayName',
                                  ),
                                  SizedBox(width: 2.w),

                                  // 2. 💬 Primary Matched Chat Button (Center with Pulse Animation)
                                  Expanded(
                                    child: _buildChatHeroButton(
                                      context: context,
                                      displayName: displayName,
                                      onTap: () {
                                        if (widget.onMessage != null) {
                                          widget.onMessage!(widget.profile);
                                        } else {
                                          widget.onTap();
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 2.w),

                                  // 3. 📤 Share Profile Button
                                  _buildQuickActionButton(
                                    context: context,
                                    icon: Icons.share_rounded,
                                    color: Colors.white.withValues(alpha: 0.18),
                                    iconColor: const Color(0xFF4ADE80),
                                    onTap: () {
                                      if (LocalCacheService().isRelativeBrowseMode()) {
                                        ShareService().shareProfileToCandidateWhatsApp(
                                          context,
                                          widget.profile,
                                        );
                                      } else {
                                        widget.onShare(widget.profile);
                                      }
                                    },
                                    semanticsLabel: 'Share profile for $displayName',
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  // 1. 🔖 Bookmark / Shortlist Button
                                  _buildQuickActionButton(
                                    context: context,
                                    icon: _isBookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: _isBookmarked
                                        ? const Color(0xFFF59E0B)
                                        : Colors.white.withValues(alpha: 0.18),
                                    iconColor: _isBookmarked ? Colors.black : Colors.white,
                                    onTap: _handleBookmark,
                                    scale: _bookmarkScale,
                                    semanticsLabel: _isBookmarked
                                        ? 'Remove bookmark for $displayName'
                                        : 'Bookmark $displayName',
                                    size: 40,
                                  ),
                                  SizedBox(width: 1.5.w),

                                  // 2. 💖 Primary Express Interest / Connect Button
                                  Expanded(
                                    child: _buildPrimaryInterestButton(
                                      context: context,
                                      displayName: displayName,
                                      onTap: () => widget.onInterest(widget.profile),
                                    ),
                                  ),
                                  SizedBox(width: 1.5.w),

                                  // 3. 💌 1 Free Message / Intro Note Button
                                  _buildQuickActionButton(
                                    context: context,
                                    icon: Icons.mark_email_unread_rounded,
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.28),
                                    iconColor: const Color(0xFFFCD34D),
                                    borderColor: const Color(0xFFF59E0B).withValues(alpha: 0.85),
                                    onTap: () {
                                      if (widget.onMessage != null) {
                                        widget.onMessage!(widget.profile);
                                      } else {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (ctx) => DirectNoteBottomSheet(
                                            profile: widget.profile.toDisplayMap(),
                                            onSuccess: () => widget.onInterest(widget.profile),
                                          ),
                                        );
                                      }
                                    },
                                    semanticsLabel: 'Send 1 free direct message to $displayName',
                                    size: 40,
                                  ),
                                  SizedBox(width: 1.5.w),

                                  // 4. 📤 Share Profile Button
                                  _buildQuickActionButton(
                                    context: context,
                                    icon: Icons.share_rounded,
                                    color: Colors.white.withValues(alpha: 0.18),
                                    iconColor: const Color(0xFF4ADE80),
                                    onTap: () {
                                      if (LocalCacheService().isRelativeBrowseMode()) {
                                        ShareService().shareProfileToCandidateWhatsApp(
                                          context,
                                          widget.profile,
                                        );
                                      } else {
                                        widget.onShare(widget.profile);
                                      }
                                    },
                                    semanticsLabel: 'Share profile for $displayName',
                                    size: 40,
                                  ),
                                ],
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  ),
),
);
}

  // ─────────────────────────────────────────────────────────────
  //  UI Helper Widgets & Badges (with Glassmorphism & Animations)
  // ─────────────────────────────────────────────────────────────

  Widget _buildGotraBadge(BuildContext context, GotraDisplayInfo info, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.55.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1002).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: info.isLocked
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                  : const Color(0xFFF59E0B).withValues(alpha: 0.85),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                info.isLocked ? Icons.lock_outline_rounded : Icons.shield_rounded,
                color: const Color(0xFFF59E0B),
                size: 13,
              ),
              SizedBox(width: 1.2.w),
              Text(
                info.formattedText,
                style: TextStyle(
                  color: const Color(0xFFFEF3C7),
                  fontWeight: AppTypography.extraBold,
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

  Widget _buildSubscriptionJewelBadge(BuildContext context, SubscriptionBadgeInfo badge) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.45.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: badge.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: badge.borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: badge.gradientColors.first.withValues(alpha: 0.40),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(badge.icon, color: badge.textColor, size: 13),
              SizedBox(width: 1.2.w),
              Text(
                badge.label,
                style: TextStyle(
                  color: badge.textColor,
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.labelSmall,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustScorePill(BuildContext context, int score) {
    final bool isHigh = score >= 75;
    final bool isMedium = score >= 40;

    final Color bgColor = isHigh
        ? const Color(0xFF064E3B).withValues(alpha: 0.75)
        : isMedium
            ? const Color(0xFF78350F).withValues(alpha: 0.75)
            : const Color(0xFF1E293B).withValues(alpha: 0.75);

    final Color borderColor = isHigh
        ? const Color(0xFF10B981).withValues(alpha: 0.7)
        : isMedium
            ? const Color(0xFFF59E0B).withValues(alpha: 0.7)
            : const Color(0xFF64748B).withValues(alpha: 0.6);

    final Color iconColor = isHigh
        ? const Color(0xFF34D399)
        : isMedium
            ? const Color(0xFFFBBF24)
            : const Color(0xFF94A3B8);

    final Color textColor = isHigh
        ? const Color(0xFFD1FAE5)
        : isMedium
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFE2E8F0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.45.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded, color: iconColor, size: 12),
              SizedBox(width: 1.w),
              Text(
                '$score%',
                style: TextStyle(
                  color: textColor,
                  fontWeight: AppTypography.extraBold,
                  fontSize: AppTypography.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVouchesBadge(BuildContext context, int count) {
    final bool hasVouches = count > 0;
    final Color bgColor = hasVouches
        ? const Color(0xFF1E1B4B).withValues(alpha: 0.75)
        : const Color(0xFF1E293B).withValues(alpha: 0.75);
    final Color borderColor = hasVouches
        ? const Color(0xFFA855F7).withValues(alpha: 0.7)
        : const Color(0xFF64748B).withValues(alpha: 0.6);
    final Color iconColor = hasVouches
        ? const Color(0xFFC084FC)
        : const Color(0xFF94A3B8);
    final Color textColor = hasVouches
        ? const Color(0xFFF3E8FF)
        : const Color(0xFFE2E8F0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.45.h),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_alt_rounded, color: iconColor, size: 12),
              SizedBox(width: 1.w),
              Text(
                '$count',
                style: TextStyle(
                  color: textColor,
                  fontWeight: AppTypography.extraBold,
                  fontSize: AppTypography.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionPill(BuildContext context, String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.45.h),
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B).withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.65),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_user_rounded, color: Color(0xFF34D399), size: 11),
              SizedBox(width: 1.w),
              Text(
                text,
                style: TextStyle(
                  color: const Color(0xFFD1FAE5),
                  fontWeight: AppTypography.extraBold,
                  fontSize: AppTypography.labelSmall,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKundaliTeaserBar(BuildContext context, KundaliDisplayInfo info) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, AppRoutes.subscription);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.7.h),
            decoration: BoxDecoration(
              color: const Color(0xFF4C0519).withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF43F5E).withValues(alpha: 0.65),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFFB7185),
                      size: 13,
                    ),
                    SizedBox(width: 1.5.w),
                    Text(
                      info.displayBadgeText,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.labelSmall,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      info.displaySubtext,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.labelSmall,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFFFDA4AF),
                      size: 9.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    Color iconColor = Colors.white,
    Color? borderColor,
    required VoidCallback onTap,
    String? semanticsLabel,
    double scale = 1.0,
    double size = 44,
  }) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor ?? Colors.white.withValues(alpha: 0.30),
                      width: borderColor != null ? 1.4 : 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: size > 40 ? 20 : 18),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatHeroButton({
    required BuildContext context,
    required String displayName,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: 'Chat with $displayName',
      button: true,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4F46E5), // Indigo 600
                    Color(0xFF7C3AED), // Violet 600
                    Color(0xFFDB2777), // Pink 600
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.60),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.55),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 2.w),
                  Text(
                    'START CHATTING',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.black,
                      fontSize: AppTypography.bodySmall,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryInterestButton({
    required BuildContext context,
    required String displayName,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: 'Send interest to $displayName',
      button: true,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.mediumImpact();
              onTap();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: AppGradients.love,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.50),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBE123C).withValues(alpha: 0.55),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 2.w),
                  Text(
                    AppLocalizations.of(context)?.interest ?? 'SEND INTEREST',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.black,
                      fontSize: AppTypography.bodySmall,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBadge(
    BuildContext context,
    String text,
    List<Color> colors,
    IconData icon,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 13),
              SizedBox(width: 1.w),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: AppTypography.black,
                  letterSpacing: 0.4,
                  fontSize: AppTypography.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
