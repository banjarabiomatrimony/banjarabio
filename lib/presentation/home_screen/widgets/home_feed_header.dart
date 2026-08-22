import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';
import 'package:banjarabio/core/models/daily_reward_model.dart';
import 'package:banjarabio/widgets/daily_reward_dialog.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/guest_guided_tour_service.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// The gradient AppBar header containing:
/// 1. Top row: Logo, Location, Daily Reward, Notification.
/// 2. Collapsible Search Bar (expands smoothly when Search is tapped).
/// 3. Animated Line 2 Horizontal Category & Discovery Hub:
///    [ 0: ⚡ Filter (N) ] -> [ 1: ✨ All Matches ] -> [ 2: 🌟 Daily Picks (10) ] -> [ 3: 📍 Near Me ] -> [ 4: 👑 VIP Verified ] -> [ 5: 🔍 Search ]
///    (With dynamic light sheen, micro-animations, breathing aura glows, and tactile physics).
class HomeFeedHeader extends StatefulWidget {
  final String locationLabel;
  final VoidCallback onLocationTap;
  final VoidCallback onFilterTap;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final int activeFilterCount;
  final DailyRewardModel? dailyRewardStatus;
  final ValueChanged<DailyRewardModel?> onRewardUpdated;
  final int selectedTab;
  final bool isSwipeMode; // Preserved for backwards compatibility
  final ValueChanged<int> onTabChanged;
  final ValueChanged<bool>? onViewModeChanged; // Preserved for backwards compatibility

  const HomeFeedHeader({
    super.key,
    required this.locationLabel,
    required this.onLocationTap,
    required this.onFilterTap,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.activeFilterCount,
    this.dailyRewardStatus,
    required this.onRewardUpdated,
    required this.selectedTab,
    this.isSwipeMode = false,
    required this.onTabChanged,
    this.onViewModeChanged,
  });

  @override
  State<HomeFeedHeader> createState() => _HomeFeedHeaderState();
}

class _HomeFeedHeaderState extends State<HomeFeedHeader> with TickerProviderStateMixin {
  bool _isSearchExpanded = false;
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _stripScrollController = ScrollController();

  // ─── Continuous Micro-Animations ───
  AnimationController? _sheenController;
  AnimationController? _pulseController;
  AnimationController? _iconFloatController;

  @override
  void initState() {
    super.initState();
    if (widget.searchController.text.isNotEmpty) {
      _isSearchExpanded = true;
    }
    _initAnimations();
  }

  void _initAnimations() {
    _sheenController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _pulseController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _iconFloatController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(HomeFeedHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initAnimations();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _stripScrollController.dispose();
    _sheenController?.dispose();
    _pulseController?.dispose();
    _iconFloatController?.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    HapticFeedback.selectionClick();
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _searchFocusNode.requestFocus();
      } else {
        _searchFocusNode.unfocus();
        if (widget.searchController.text.isNotEmpty) {
          widget.onSearchClear();
        }
      }
    });
  }

  void _scrollToChip(int index) {
    if (!_stripScrollController.hasClients) return;
    const double approxItemWidth = 110.0;
    final double targetOffset = math.max(0.0, (index * approxItemWidth) - 60.0);
    _stripScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  bool get _isHomeTourActive {
    final cache = LocalCacheService();
    return cache.isGuestMode() && !cache.isTourStageCompleted(TourStage.homeScreen.name);
  }

  @override
  Widget build(BuildContext context) {
    _initAnimations();
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    final double headerHeight = _isSearchExpanded
        ? (11.5.h + topPadding)
        : (6.6.h + topPadding);

    return SliverAppBar(
      floating: true,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: theme.appBarTheme.backgroundColor,
      expandedHeight: headerHeight,
      toolbarHeight: headerHeight,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: AppColors.opacity85),
              ],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: AppColors.opacity25),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(3.5.w, topPadding + 0.15.h, 3.5.w, 0.15.h),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── ROW 1: BRANDING, LOCATION PILL & REWARD STREAK (OPTION B) ───
                _buildLocationRow(context, theme),

                // ─── ROW 1.5: ON-DEMAND EXPANDABLE SEARCH BAR ───
                if (_isSearchExpanded) ...[
                  SizedBox(height: 0.5.h),
                  _buildSearchRow(context, theme),
                ],

                SizedBox(height: 0.75.h),

                // ─── ROW 2: ANIMATED HORIZONTAL DISCOVERY STRIP ───
                // [ 0: ⚡ Filter ] -> [ 1: ✨ All Matches ] -> [ 2: 🌟 Daily (10) ] -> [ 3: 📍 Near Me ] -> [ 4: 👑 VIP Verified ] -> [ 5: 🔍 Search ]
                _buildUnifiedControlRow(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ─── 1. Left: Brand Identity (Logo + Wordmark) ───
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: const AppLogoImage(
                  width: 26,
                  height: 26,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Image.asset(
              'assets/logo/brand_kit/wordmark.png',
              height: 22,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Text(
                'BanjaraBio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.headingSmall,
                  fontWeight: AppTypography.black,
                  letterSpacing: 0.6,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: AppColors.opacity25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ─── 2. Center: Compact Frosted Location Pill ───
        TactilePressable(
          key: _isHomeTourActive ? TourKeys.locationKey : null,
          onTap: widget.onLocationTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.45.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: AppColors.opacity15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: AppColors.opacity20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.goldSoft, size: 12),
                SizedBox(width: 1.w),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 26.w),
                  child: Text(
                    widget.locationLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.bold,
                      fontSize: AppTypography.labelSmall,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 0.5.w),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 13),
              ],
            ),
          ),
        ),

        // ─── 3. Right: Daily Reward Gamification Streak Badge ───
        if (widget.dailyRewardStatus != null)
          TactilePressable(
            onTap: () async {
              final updatedStatus = await DailyRewardDialog.show(context, widget.dailyRewardStatus!);
              widget.onRewardUpdated(updatedStatus);
            },
            child: AnimatedBuilder(
              animation: _pulseController ?? const AlwaysStoppedAnimation(0.0),
              builder: (context, child) {
                final isClaimed = widget.dailyRewardStatus!.isClaimedToday;
                final streak = widget.dailyRewardStatus!.streakCount;
                final pulse = _pulseController?.value ?? 0.0;

                if (isClaimed) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.card_giftcard_rounded, color: AppColors.goldTint200, size: 13),
                        SizedBox(width: 1.w),
                        Text(
                          streak > 0 ? 'Day $streak' : 'Claimed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTypography.labelSmall,
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.categoryAstro.withValues(alpha: 0.35 + (pulse * 0.25)),
                        blurRadius: 8 + (pulse * 4),
                        spreadRadius: pulse * 1.2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 13),
                      SizedBox(width: 1.w),
                      Text(
                        'Claim',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTypography.labelSmall,
                          fontWeight: AppTypography.extraBold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildSearchRow(BuildContext context, ThemeData theme) {
    return Container(
      height: 3.8.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: AppColors.opacity25),
        ),
      ),
      child: TextField(
        controller: widget.searchController,
        focusNode: _searchFocusNode,
        onChanged: widget.onSearchChanged,
        textAlignVertical: TextAlignVertical.center,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: AppTypography.semiBold,
          color: Colors.white,
          fontSize: AppTypography.bodySmall,
        ),
        cursorColor: Colors.amberAccent,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)?.searchProfiles ?? 'Search by Name, Gotra or ID...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: AppTypography.labelMedium,
            fontWeight: AppTypography.medium,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 10, right: 6),
            child: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: AppColors.opacity85), size: 18),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 20,
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: AppColors.opacity85), size: 16),
                  onPressed: widget.onSearchClear,
                )
              : null,
        ),
      ),
    );
  }

  /// ─── ROW 2: ANIMATED HORIZONTAL DISCOVERY & CATEGORY STRIP ───
  /// [ 0: ⚡ Filter (N) ] -> [ 1: ✨ All Matches ] -> [ 2: 🌟 Daily Picks (10) ] -> [ 3: 📍 Near Me ] -> [ 4: 👑 VIP Verified ] -> [ 5: 🔍 Search ]
  Widget _buildUnifiedControlRow(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      controller: _stripScrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── 0. ⚡ Filter (N) (Radar Ripple Indicator & Amber Glow) ───
          _buildAnimatedFilterChip(
            label: 'Filter',
            count: widget.activeFilterCount,
            onTap: () {
              _scrollToChip(0);
              widget.onFilterTap();
            },
          ),
          const SizedBox(width: 6),

          // ─── 1. ✨ All Matches (Pure White Gloss, Shimmer Light Sheen & Royal Purple) ───
          _buildAnimatedCategoryChip(
            index: 1,
            icon: Icons.auto_awesome_rounded,
            label: 'All Matches',
            isActive: widget.selectedTab == 0,
            activeGradient: const LinearGradient(
              colors: [AppColors.surfaceLight, AppColors.violetBg],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            activeTextColor: AppColors.deepIndigo,
            activeGlowColor: Colors.white.withValues(alpha: AppColors.opacity40),
            iconAnimationType: _IconAnimType.twinkle,
            onTap: () {
              _scrollToChip(1);
              if (widget.selectedTab == 0) return;
              HapticFeedback.selectionClick();
              widget.onTabChanged(0);
            },
          ),
          const SizedBox(width: 6),

          // ─── 2. 🌟 Daily Picks (10) (Solar Gold Glow & Floating Star) ───
          _buildAnimatedCategoryChip(
            index: 2,
            icon: Icons.star_rounded,
            label: 'Daily Picks',
            badgeText: '10',
            isActive: widget.selectedTab == 1,
            activeGradient: const LinearGradient(
              colors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            activeTextColor: Colors.white,
            activeGlowColor: Colors.amberAccent.withValues(alpha: AppColors.opacity50),
            iconAnimationType: _IconAnimType.pulse,
            onTap: () {
              _scrollToChip(2);
              if (widget.selectedTab == 1) return;
              HapticFeedback.selectionClick();
              widget.onTabChanged(1);
            },
          ),
          const SizedBox(width: 6),

          // ─── 3. 📍 Near Me (Emerald Teal Pulse & Floating Pin) ───
          _buildAnimatedCategoryChip(
            index: 3,
            icon: Icons.location_on_rounded,
            label: 'Near Me',
            isActive: widget.selectedTab == 2,
            activeGradient: const LinearGradient(
              colors: [AppColors.categoryLocation, AppColors.categoryLocationDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            activeTextColor: Colors.white,
            activeGlowColor: AppColors.categoryLocation.withValues(alpha: AppColors.opacity50),
            iconAnimationType: _IconAnimType.float,
            onTap: () {
              _scrollToChip(3);
              if (widget.selectedTab == 2) return;
              HapticFeedback.selectionClick();
              widget.onTabChanged(2);
            },
          ),
          const SizedBox(width: 6),

          // ─── 4. 👑 VIP Verified (Royal Violet & Solar Crown Shimmer) ───
          _buildAnimatedCategoryChip(
            index: 4,
            icon: Icons.workspace_premium_rounded,
            label: 'VIP Verified',
            isActive: widget.selectedTab == 3,
            activeGradient: const LinearGradient(
              colors: [AppColors.categoryFamily, AppColors.violetDeep],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            activeTextColor: Colors.white,
            activeGlowColor: AppColors.categoryFamily.withValues(alpha: AppColors.opacity50),
            iconAnimationType: _IconAnimType.pulse,
            onTap: () {
              _scrollToChip(4);
              if (widget.selectedTab == 3) return;
              HapticFeedback.selectionClick();
              widget.onTabChanged(3);
            },
          ),
          const SizedBox(width: 6),

          // ─── 5. 🔍 Search (Electric Indigo Active State) ───
          _buildAnimatedCategoryChip(
            index: 5,
            icon: _isSearchExpanded ? Icons.search_off_rounded : Icons.search_rounded,
            label: 'Search',
            isActive: _isSearchExpanded,
            activeGradient: const LinearGradient(
              colors: [AppColors.categoryCareer, AppColors.categoryCareerDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            activeTextColor: Colors.white,
            activeGlowColor: AppColors.categoryCareer.withValues(alpha: AppColors.opacity50),
            iconAnimationType: _IconAnimType.none,
            onTap: () {
              _scrollToChip(5);
              _toggleSearch();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCategoryChip({
    required int index,
    required IconData icon,
    required String label,
    String? badgeText,
    required bool isActive,
    required LinearGradient activeGradient,
    required Color activeTextColor,
    required Color activeGlowColor,
    required _IconAnimType iconAnimationType,
    required VoidCallback onTap,
  }) {
    return TactilePressable(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          if (_pulseController != null) _pulseController!,
          if (_sheenController != null) _sheenController!,
          if (_iconFloatController != null) _iconFloatController!,
        ]),
        builder: (context, child) {
          final pulseVal = _pulseController?.value ?? 0.0;
          final sheenVal = _sheenController?.value ?? 0.0;
          final floatVal = _iconFloatController?.value ?? 0.0;

          final double scale = isActive ? (1.0 + (pulseVal * 0.025)) : 1.0;
          final double glowSpread = isActive ? (4.0 + (pulseVal * 4.0)) : 0.0;

          return Transform.scale(
            scale: scale,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 5.5, horizontal: 9.5),
                  decoration: BoxDecoration(
                    gradient: isActive ? activeGradient : null,
                    color: isActive ? null : Colors.black.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive
                          ? Colors.white.withValues(alpha: AppColors.opacity85)
                          : Colors.white.withValues(alpha: 0.22),
                      width: isActive ? 1.4 : 1.0,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: activeGlowColor,
                              blurRadius: glowSpread,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ─── Micro-Animated Icon ───
                      _buildAnimatedIcon(
                        icon: icon,
                        isActive: isActive,
                        activeColor: activeTextColor,
                        type: iconAnimationType,
                        floatVal: floatVal,
                        pulseVal: pulseVal,
                      ),
                      const SizedBox(width: 4.5),
                      Text(
                        label,
                        style: TextStyle(
                          color: isActive ? activeTextColor : Colors.white,
                          fontWeight: isActive ? AppTypography.black : AppTypography.semiBold,
                          fontSize: AppTypography.labelMedium,
                          letterSpacing: 0.1,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white.withValues(alpha: 0.32)
                                : Colors.amberAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: isActive ? Colors.white : AppColors.amberDeepText,
                              fontWeight: AppTypography.black,
                              fontSize: AppTypography.labelTiny,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ─── Continuous Ambient Light Sheen Glint on Active Capsule ───
                if (isActive)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _PillSheenPainter(progress: sheenVal),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedIcon({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required _IconAnimType type,
    required double floatVal,
    required double pulseVal,
  }) {
    final Widget iconWidget = Icon(
      icon,
      size: 13.5,
      color: isActive ? activeColor : Colors.white,
    );

    if (!isActive || type == _IconAnimType.none) {
      return iconWidget;
    }

    switch (type) {
      case _IconAnimType.twinkle:
        // Rotate ±12 degrees and subtle scale
        final angle = (floatVal - 0.5) * 0.45;
        return Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: 1.0 + (pulseVal * 0.15),
            child: iconWidget,
          ),
        );
      case _IconAnimType.float:
        // Float up/down 2.5 dp
        return Transform.translate(
          offset: Offset(0, -2.5 * floatVal),
          child: iconWidget,
        );
      case _IconAnimType.pulse:
        // Breathe scale
        return Transform.scale(
          scale: 1.0 + (pulseVal * 0.18),
          child: iconWidget,
        );
      case _IconAnimType.none:
        return iconWidget;
    }
  }

  Widget _buildAnimatedFilterChip({
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    final bool hasActiveFilters = count > 0;

    return TactilePressable(
      key: _isHomeTourActive ? TourKeys.filterKey : null,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          if (_pulseController != null) _pulseController!,
          if (_sheenController != null) _sheenController!,
        ]),
        builder: (context, child) {
          final pulseVal = _pulseController?.value ?? 0.0;
          final sheenVal = _sheenController?.value ?? 0.0;
          final double glowSpread = hasActiveFilters ? (4.0 + (pulseVal * 4.5)) : 0.0;

          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 5.5, horizontal: 9.5),
                decoration: BoxDecoration(
                  gradient: hasActiveFilters
                      ? const LinearGradient(
                          colors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: hasActiveFilters ? null : Colors.black.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasActiveFilters
                        ? Colors.amberAccent
                        : Colors.white.withValues(alpha: AppColors.opacity35),
                    width: hasActiveFilters ? 1.4 : 1.0,
                  ),
                  boxShadow: hasActiveFilters
                      ? [
                          BoxShadow(
                            color: Colors.amberAccent.withValues(alpha: AppColors.opacity50),
                            blurRadius: glowSpread,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Filter icon with subtle pulse when active
                    Transform.rotate(
                      angle: hasActiveFilters ? ((pulseVal - 0.5) * 0.18) : 0.0,
                      child: Icon(
                        Icons.tune_rounded,
                        size: 13.5,
                        color: hasActiveFilters ? Colors.white : Colors.amberAccent,
                      ),
                    ),
                    const SizedBox(width: 4.5),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: hasActiveFilters ? AppTypography.black : AppTypography.bold,
                        fontSize: AppTypography.labelMedium,
                      ),
                    ),
                    if (hasActiveFilters) ...[
                      const SizedBox(width: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: Container(
                          key: ValueKey('filter_count_$count'),
                          padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.32),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            count.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: AppTypography.black,
                              fontSize: AppTypography.labelTiny,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Light Sheen for Active Filter
              if (hasActiveFilters)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _PillSheenPainter(progress: sheenVal),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

enum _IconAnimType {
  none,
  twinkle,
  float,
  pulse,
}

/// Custom painter that sweeps a diagonal light sheen across the active chip.
class _PillSheenPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  _PillSheenPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.05 || progress >= 0.95) return;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.38),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(
        (size.width * 2.2 * progress) - (size.width * 0.6),
        0,
        size.width * 0.5,
        size.height,
      ));

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );

    canvas.clipRRect(rrect);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_PillSheenPainter oldDelegate) => oldDelegate.progress != progress;
}
