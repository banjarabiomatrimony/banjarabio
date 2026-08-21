import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/core/models/filter_criteria.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/core/services/app_logger.dart';

class FilterScreen extends StatefulWidget {
  final FilterCriteria? initialFilters;
  const FilterScreen({super.key, this.initialFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen>
    with SingleTickerProviderStateMixin {
  final ProfileRepository _profileRepository = ProfileRepository();
  final SubscriptionRepository _subscriptionRepository = SubscriptionRepository();

  bool _isPremium = false;
  PlanType _planType = PlanType.free;
  late FilterCriteria _currentFilters;

  final TextEditingController _districtController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tabScrollController = ScrollController();

  // Navigation & Scroll-Spy Keys
  final GlobalKey _stickyNavKey = GlobalKey();
  final GlobalKey _standardTierKey = GlobalKey();
  final GlobalKey _communityTierKey = GlobalKey();
  final GlobalKey _premiumTierKey = GlobalKey();
  final GlobalKey _matchmakerTierKey = GlobalKey();

  int _selectedCategoryIndex = 0; // 0: Standard, 1: Community, 2: Premium, 3: Matchmaker
  int? _hoveredCategoryIndex;
  bool _isAutoScrolling = false;

  // Default age bounds for dual range slider
  static const double _minAgeLimit = 18;
  static const double _maxAgeLimit = 70;

  AnimationController? _animController;
  Animation<double>? _fadeAnimation;

  void _initAnimations() {
    _animController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();

    _fadeAnimation ??= CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters ?? const FilterCriteria();
    _districtController.text = _currentFilters.district ?? '';
    _initAnimations();
    _loadUserStatus();
    _scrollController.addListener(_onScrollSpy);
  }

  void _onScrollSpy() {
    if (_isAutoScrolling) return;
    if (!_scrollController.hasClients) return;

    // Check if scrolled near the bottom of the list -> highlight last tier (Matchmaker)
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 80) {
      if (_selectedCategoryIndex != 3) {
        setState(() => _selectedCategoryIndex = 3);
        _ensureActiveTabVisible(3);
      }
      return;
    }

    // Measure threshold relative to the sticky navigator bar bottom
    double cutoffY = 170.0;
    final navCtx = _stickyNavKey.currentContext;
    if (navCtx != null) {
      final navBox = navCtx.findRenderObject() as RenderBox?;
      if (navBox != null && navBox.attached) {
        cutoffY = navBox.localToGlobal(Offset.zero).dy + navBox.size.height + 30.0;
      }
    }

    int activeIndex = 0;

    // 1. Check Matchmaker Tier position
    final matchmakerCtx = _matchmakerTierKey.currentContext;
    if (matchmakerCtx != null) {
      final box = matchmakerCtx.findRenderObject() as RenderBox?;
      if (box != null && box.attached) {
        final dy = box.localToGlobal(Offset.zero).dy;
        if (dy <= cutoffY) {
          activeIndex = 3;
        }
      }
    }

    // 2. Check Premium Tier position
    if (activeIndex == 0) {
      final premiumCtx = _premiumTierKey.currentContext;
      if (premiumCtx != null) {
        final box = premiumCtx.findRenderObject() as RenderBox?;
        if (box != null && box.attached) {
          final dy = box.localToGlobal(Offset.zero).dy;
          if (dy <= cutoffY) {
            activeIndex = 2;
          }
        }
      }
    }

    // 3. Check Community Tier position
    if (activeIndex == 0) {
      final communityCtx = _communityTierKey.currentContext;
      if (communityCtx != null) {
        final box = communityCtx.findRenderObject() as RenderBox?;
        if (box != null && box.attached) {
          final dy = box.localToGlobal(Offset.zero).dy;
          if (dy <= cutoffY) {
            activeIndex = 1;
          }
        }
      }
    }

    // Update state if changed
    if (activeIndex != _selectedCategoryIndex) {
      setState(() {
        _selectedCategoryIndex = activeIndex;
      });
      _ensureActiveTabVisible(activeIndex);
    }
  }

  void _ensureActiveTabVisible(int index) {
    if (!_tabScrollController.hasClients) return;
    final double targetOffset = (index * 88.0).clamp(
      0.0,
      _tabScrollController.position.maxScrollExtent,
    );
    _tabScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _loadUserStatus() async {
    try {
      final profileRes = await _profileRepository.getOwnProfile();
      profileRes.fold(
        onSuccess: (profile) {
          if (mounted && profile != null) {
            setState(() {
              _isPremium = profile.isPremium;
            });
          }
        },
        onFailure: (error) {
          AppLogger.error('FilterScreen', 'Error fetching profile: $error');
        },
      );

      final planRes = await _subscriptionRepository.getPlanType();
      planRes.fold(
        onSuccess: (plan) {
          if (mounted) {
            setState(() {
              _planType = plan;
            });
          }
        },
        onFailure: (error) {
          AppLogger.error('FilterScreen', 'Error fetching plan type: $error');
        },
      );
    } catch (e) {
      AppLogger.error('FilterScreen', 'Exception in _loadUserStatus: $e');
    }
  }

  bool get _hasCommunityAccess {
    if (_isPremium) return true;
    if (_planType.isPaidPlan) return true;
    return false;
  }

  bool get _hasPremiumAccess {
    if (_isPremium && _planType != PlanType.mass_market && _planType != PlanType.mass_market_annual) {
      return true;
    }
    return _planType.isSelfServicePlan &&
        _planType != PlanType.mass_market &&
        _planType != PlanType.mass_market_annual;
  }

  bool get _hasMatchmakerAccess {
    return _planType.isVipPlan;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScrollSpy);
    _animController?.dispose();
    _scrollController.dispose();
    _tabScrollController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    int count = 0;
    // Tier 1
    if (_currentFilters.minAge != null || _currentFilters.maxAge != null) count++;
    if (_currentFilters.gender != null && _currentFilters.gender!.isNotEmpty) count++;
    if (_currentFilters.hasPhoto == true) count++;
    if (_currentFilters.maritalStatus != null && _currentFilters.maritalStatus!.isNotEmpty) count++;
    if (_currentFilters.state != null && _currentFilters.state!.isNotEmpty) count++;
    if (_districtController.text.trim().isNotEmpty) count++;
    if (_currentFilters.education != null && _currentFilters.education!.isNotEmpty) {
      count += _currentFilters.education!.length;
    }

    // Tier 2
    if (_currentFilters.gotra != null && _currentFilters.gotra!.isNotEmpty) {
      count += _currentFilters.gotra!.length;
    }
    if (_currentFilters.maternalGotra != null && _currentFilters.maternalGotra!.isNotEmpty) {
      count += _currentFilters.maternalGotra!.length;
    }
    if (_currentFilters.subCaste != null && _currentFilters.subCaste!.isNotEmpty) {
      count += _currentFilters.subCaste!.length;
    }
    if (_currentFilters.originType != null && _currentFilters.originType!.isNotEmpty) {
      count += _currentFilters.originType!.length;
    }
    if (_currentFilters.minHeight != null && _currentFilters.minHeight!.isNotEmpty) count++;
    if (_currentFilters.annualIncome != null && _currentFilters.annualIncome!.isNotEmpty) {
      count += _currentFilters.annualIncome!.length;
    }
    if (_currentFilters.educationField != null && _currentFilters.educationField!.isNotEmpty) {
      count += _currentFilters.educationField!.length;
    }
    if (_currentFilters.profession != null && _currentFilters.profession!.isNotEmpty) {
      count += _currentFilters.profession!.length;
    }
    if (_currentFilters.familyType != null && _currentFilters.familyType!.isNotEmpty) {
      count += _currentFilters.familyType!.length;
    }
    if (_currentFilters.familyStatus != null && _currentFilters.familyStatus!.isNotEmpty) {
      count += _currentFilters.familyStatus!.length;
    }
    if (_currentFilters.familyValues != null && _currentFilters.familyValues!.isNotEmpty) {
      count += _currentFilters.familyValues!.length;
    }
    if (_currentFilters.profileCreatedBy != null && _currentFilters.profileCreatedBy!.isNotEmpty) {
      count += _currentFilters.profileCreatedBy!.length;
    }
    if (_currentFilters.isDisabled != null) count++;

    // Tier 3
    if (_currentFilters.isVerified == true) count++;
    if (_currentFilters.isCommunityTrusted == true) count++;
    if (_currentFilters.isIncomeVerified == true) count++;
    if (_currentFilters.manglikStatus != null && _currentFilters.manglikStatus!.isNotEmpty) {
      count += _currentFilters.manglikStatus!.length;
    }
    if (_currentFilters.rashi != null && _currentFilters.rashi!.isNotEmpty) {
      count += _currentFilters.rashi!.length;
    }
    if (_currentFilters.hasHoroscope == true) count++;
    if (_currentFilters.employmentSector != null && _currentFilters.employmentSector!.isNotEmpty) {
      count += _currentFilters.employmentSector!.length;
    }
    if (_currentFilters.diet != null && _currentFilters.diet!.isNotEmpty) {
      count += _currentFilters.diet!.length;
    }
    if (_currentFilters.smokingHabits != null && _currentFilters.smokingHabits!.isNotEmpty) {
      count += _currentFilters.smokingHabits!.length;
    }
    if (_currentFilters.drinkingHabits != null && _currentFilters.drinkingHabits!.isNotEmpty) {
      count += _currentFilters.drinkingHabits!.length;
    }
    if (_currentFilters.relocationPreference != null && _currentFilters.relocationPreference!.isNotEmpty) {
      count += _currentFilters.relocationPreference!.length;
    }
    if (_currentFilters.isRecentlyActive == true) count++;
    if (_currentFilters.isHighResponse == true) count++;
    if (_currentFilters.hasMultiplePhotos == true) count++;

    // Tier 4
    if (_currentFilters.isDirectContactUnlocked == true) count++;
    if (_currentFilters.isRmHandpicked == true) count++;
    if (_currentFilters.minGunaScore != null) count++;
    if (_currentFilters.isVipSpotlight == true) count++;
    if (_currentFilters.ancestralLandAcres != null && _currentFilters.ancestralLandAcres!.isNotEmpty) {
      count += _currentFilters.ancestralLandAcres!.length;
    }
    if (_currentFilters.isHouseOwner == true) count++;
    if (_currentFilters.isFamilyVetted == true) count++;
    if (_currentFilters.isConfidentialMode == true) count++;

    return count;
  }

  void _applyFilters() {
    HapticFeedback.mediumImpact();
    final district = _districtController.text.trim();
    _currentFilters = _currentFilters.copyWith(
      district: district.isNotEmpty ? district : '',
    );
    if (!mounted) return;
    Navigator.pop(context, _currentFilters);
  }

  void _resetFilters() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentFilters = const FilterCriteria();
      _districtController.clear();
    });
  }

  void _scrollToTier(int index, GlobalKey key) async {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCategoryIndex = index;
      _isAutoScrolling = true;
    });
    _ensureActiveTabVisible(index);

    final context = key.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _isAutoScrolling = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _initAnimations();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = theme.appBarTheme.foregroundColor ?? Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0E17) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 175,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TactilePressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: foreground,
                    size: 16,
                  ),
                ),
              ),
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
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        titleWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)?.filters ?? 'Filters',
              style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
                fontSize: AppTypography.headingSmall,
                fontWeight: AppTypography.bold,
                color: foreground,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.tune_rounded,
              size: 16,
              color: Color(0xFFFBBF24),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: TactilePressable(
                onTap: _resetFilters,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    color: _activeFilterCount > 0
                        ? const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.25 : 0.20)
                        : foreground.withValues(alpha: isDark ? 0.12 : 0.16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _activeFilterCount > 0
                          ? const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.6 : 0.4)
                          : foreground.withValues(alpha: isDark ? 0.20 : 0.25),
                      width: 1.1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 13,
                        color: _activeFilterCount > 0
                            ? const Color(0xFFF59E0B)
                            : foreground.withValues(alpha: isDark ? 0.85 : 0.9),
                      ),
                      const SizedBox(width: 3.5),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Text(
                          _activeFilterCount > 0
                              ? '$_activeFilterCount ${AppLocalizations.of(context)?.reset ?? "Reset"}'
                              : (AppLocalizations.of(context)?.reset ?? 'Reset'),
                          key: ValueKey<int>(_activeFilterCount),
                          style: TextStyle(
                            fontSize: AppTypography.labelSmall,
                            fontWeight: AppTypography.bold,
                            color: _activeFilterCount > 0
                                ? const Color(0xFFF59E0B)
                                : foreground.withValues(alpha: isDark ? 0.85 : 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: _buildAppBarCategoryTabs(theme, isDark),
      ),
      body: Stack(
        children: [
          // Ambient background glow bubbles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFBE123C).withValues(alpha: isDark ? 0.08 : 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.06 : 0.03),
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(4.w, 1.4.h, 4.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =============================================================
                  // 🟢 1. STANDARD (Available to All Registered Members)
                  // =============================================================
                  Container(
                    key: _standardTierKey,
                    child: _buildTierHeader(
                      theme: theme,
                      title: AppLocalizations.of(context)?.standardFilters ?? 'Standard Filters',
                      subtitle: AppLocalizations.of(context)?.standardFiltersSubtitle ?? 'Basic demographic criteria for all registered members',
                      badgeText: 'STANDARD',
                      badgeColor: const Color(0xFF10B981),
                      icon: Icons.check_circle_outline_rounded,
                      isDark: isDark,
                    ),
                  ),
                  SizedBox(height: 1.6.h),
                  _buildGenderSection(theme, isDark),
                  SizedBox(height: 1.8.h),
                  _buildAgeSection(theme, isDark),
                  SizedBox(height: 1.8.h),
                  _buildPhotoOnlySection(theme, isDark),
                  SizedBox(height: 1.8.h),
                  _buildMaritalStatusSection(theme, isDark),
                  SizedBox(height: 1.8.h),
                  _buildLocationSection(theme, isDark),
                  SizedBox(height: 1.8.h),
                  _buildBasicEducationSection(theme, isDark),
                  SizedBox(height: 3.2.h),

                  // =============================================================
                  // 🌟 2. COMMUNITY / BVS (₹20/mo or ₹200/yr Subsidized)
                  // =============================================================
                  Container(
                    key: _communityTierKey,
                    child: _buildTierHeader(
                      theme: theme,
                      title: AppLocalizations.of(context)?.communityFiltersTitle ?? 'Community Filters (BVS)',
                      subtitle: AppLocalizations.of(context)?.communityFiltersSubtitle ?? 'Gotra, Mamakul, Origin, Height, Income & Lineage',
                      badgeText: AppLocalizations.of(context)?.subsidizedPricePill ?? '₹20/mo or ₹200/yr',
                      badgeColor: const Color(0xFFF59E0B),
                      icon: _hasCommunityAccess ? Icons.stars_rounded : Icons.lock_outline_rounded,
                      isDark: isDark,
                    ),
                  ),
                  SizedBox(height: 1.6.h),
                  _buildCommunityContainer(theme, isDark),
                  SizedBox(height: 3.2.h),

                  // =============================================================
                  // ⚡ 3. PREMIUM (Self-Service Plans)
                  // =============================================================
                  Container(
                    key: _premiumTierKey,
                    child: _buildTierHeader(
                      theme: theme,
                      title: AppLocalizations.of(context)?.premiumFiltersTitle ?? 'Premium Filters',
                      subtitle: AppLocalizations.of(context)?.premiumFiltersSubtitle ?? 'ID Verification, Trust Score, Horoscope, Lifestyle & Activity',
                      badgeText: 'PREMIUM',
                      badgeColor: const Color(0xFF8B5CF6),
                      icon: _hasPremiumAccess ? Icons.verified_rounded : Icons.lock_outline_rounded,
                      isDark: isDark,
                    ),
                  ),
                  SizedBox(height: 1.6.h),
                  _buildPremiumContainer(theme, isDark),
                  SizedBox(height: 3.2.h),

                  // =============================================================
                  // 👑 4. MATCHMAKER (VIP Assisted Plans)
                  // =============================================================
                  Container(
                    key: _matchmakerTierKey,
                    child: _buildTierHeader(
                      theme: theme,
                      title: AppLocalizations.of(context)?.matchmakerFiltersTitle ?? 'Matchmaker Filters',
                      subtitle: AppLocalizations.of(context)?.matchmakerFiltersSubtitle ?? 'Direct Contact, RM Handpicked, 36 Guna Score & Land Holdings',
                      badgeText: 'MATCHMAKER',
                      badgeColor: const Color(0xFFBE123C),
                      icon: _hasMatchmakerAccess ? Icons.workspace_premium_rounded : Icons.lock_clock_rounded,
                      isDark: isDark,
                    ),
                  ),
                  SizedBox(height: 1.6.h),
                  _buildMatchmakerContainer(theme, isDark),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),

          // Floating Apply CTA Bar
          _buildFloatingApplyBar(theme, isDark),
        ],
      ),
    );
  }

  /// Compact Category Segment Navigation Bar integrated directly under AppBar
  PreferredSizeWidget _buildAppBarCategoryTabs(ThemeData theme, bool isDark) {
    return PreferredSize(
      preferredSize: Size.fromHeight(5.2.h),
      child: Container(
        key: _stickyNavKey,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(2.5.w, 0.2.h, 2.5.w, 0.8.h),
        decoration: BoxDecoration(
          color: theme.appBarTheme.backgroundColor ?? (isDark ? const Color(0xFF0F0E17) : Colors.white),
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
            ),
          ),
        ),
        child: SingleChildScrollView(
          controller: _tabScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildStickyTabButton(
                index: 0,
                label: 'Standard',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF10B981),
                onTap: () => _scrollToTier(0, _standardTierKey),
                isDark: isDark,
              ),
              SizedBox(width: 1.6.w),
              _buildStickyTabButton(
                index: 1,
                label: 'Community',
                icon: _hasCommunityAccess ? Icons.stars_rounded : Icons.lock_outline_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () => _scrollToTier(1, _communityTierKey),
                isDark: isDark,
              ),
              SizedBox(width: 1.6.w),
              _buildStickyTabButton(
                index: 2,
                label: 'Premium',
                icon: _hasPremiumAccess ? Icons.verified_rounded : Icons.lock_outline_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () => _scrollToTier(2, _premiumTierKey),
                isDark: isDark,
              ),
              SizedBox(width: 1.6.w),
              _buildStickyTabButton(
                index: 3,
                label: 'Matchmaker',
                icon: _hasMatchmakerAccess ? Icons.workspace_premium_rounded : Icons.lock_clock_rounded,
                color: const Color(0xFFBE123C),
                onTap: () => _scrollToTier(3, _matchmakerTierKey),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStickyTabButton({
    required int index,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final bool isSelected = _selectedCategoryIndex == index;
    final bool isHovered = _hoveredCategoryIndex == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCategoryIndex = index),
      onExit: (_) => setState(() => _hoveredCategoryIndex = null),
      child: TactilePressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.65.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withValues(alpha: 0.88)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : (isHovered
                    ? LinearGradient(
                        colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.12)],
                      )
                    : null),
            color: isSelected
                ? null
                : (isHovered
                    ? null
                    : (isDark ? const Color(0xFF1B182B) : const Color(0xFFF1F5F9))),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.95)
                  : (isHovered
                      ? color.withValues(alpha: 0.65)
                      : (isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFCBD5E1))),
              width: isSelected ? 1.6 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.50),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : (isHovered
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.20),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : (isHovered ? color.withValues(alpha: 0.18) : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 13,
                  color: isSelected ? Colors.white : (isHovered ? color : (isDark ? Colors.white70 : const Color(0xFF475569))),
                ),
              ),
              SizedBox(width: 1.4.w),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isHovered ? color : (isDark ? Colors.white70 : const Color(0xFF334155))),
                  fontWeight: isSelected ? AppTypography.black : (isHovered ? AppTypography.extraBold : AppTypography.semiBold),
                  fontSize: AppTypography.labelMedium,
                  letterSpacing: isSelected ? 0.2 : 0.05,
                ),
                softWrap: false,
              ),
              if (isSelected) ...[
                SizedBox(width: 1.2.w),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierHeader({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badgeColor.withValues(alpha: isDark ? 0.16 : 0.10),
            badgeColor.withValues(alpha: isDark ? 0.05 : 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withValues(alpha: isDark ? 0.40 : 0.32),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: isDark ? 0.12 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  badgeColor.withValues(alpha: 0.28),
                  badgeColor.withValues(alpha: 0.15),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: badgeColor.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: Icon(icon, color: badgeColor, size: 19),
          ),
          SizedBox(width: 3.2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: AppTypography.black,
                    fontSize: AppTypography.bodyMedium,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2.5),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                    fontSize: AppTypography.labelSmall,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.45.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [badgeColor, badgeColor.withValues(alpha: 0.85)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: badgeColor.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: AppTypography.black,
                fontSize: AppTypography.labelTiny,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required ThemeData theme,
    required IconData icon,
    required String title,
    String? subtitle,
    int? selectedCount,
    Color? iconAccent,
  }) {
    final accent = iconAccent ?? theme.colorScheme.primary;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8.5),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accent.withValues(alpha: 0.25),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: accent,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.headingSmall,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (selectedCount != null && selectedCount > 0) ...[
                    SizedBox(width: 2.w),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Container(
                        key: ValueKey<int>(selectedCount),
                        padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accent, accent.withValues(alpha: 0.85)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$selectedCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTypography.labelTiny,
                            fontWeight: AppTypography.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 🟢 1. STANDARD FILTERS SECTION BUILDERS
  // ===========================================================================

  Widget _buildGenderSection(ThemeData theme, bool isDark) {
    final selectedGender = _currentFilters.gender ?? '';

    Widget buildGenderPill(String label, String value, IconData icon, Color color) {
      final isSelected = selectedGender.toLowerCase() == value.toLowerCase();
      return Expanded(
        child: TactilePressable(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _currentFilters = _currentFilters.copyWith(
                gender: isSelected ? '' : value,
              );
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(vertical: 1.3.h),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [color, color.withValues(alpha: 0.85)],
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                width: isSelected ? 1.6 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.38),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                    fontSize: AppTypography.bodySmall,
                    color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161424) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.wc_rounded,
            iconAccent: const Color(0xFFEC4899),
            title: AppLocalizations.of(context)?.lookingForGender ?? 'Looking For (Gender)',
            subtitle: AppLocalizations.of(context)?.selectMatchPreference ?? 'Select match preference for groom or bride search',
          ),
          SizedBox(height: 1.6.h),
          Row(
            children: [
              buildGenderPill(AppLocalizations.of(context)?.all ?? 'All', '', Icons.people_outline_rounded, const Color(0xFF6366F1)),
              SizedBox(width: 2.w),
              buildGenderPill(AppLocalizations.of(context)?.bride ?? 'Bride', 'female', Icons.female_rounded, const Color(0xFFEC4899)),
              SizedBox(width: 2.w),
              buildGenderPill(AppLocalizations.of(context)?.groom ?? 'Groom', 'male', Icons.male_rounded, const Color(0xFF0EA5E9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSection(ThemeData theme, bool isDark) {
    final double minAge = (_currentFilters.minAge ?? 18).toDouble().clamp(_minAgeLimit, _maxAgeLimit);
    final double maxAge = (_currentFilters.maxAge ?? 60).toDouble().clamp(minAge, _maxAgeLimit);

    final RangeValues currentRange = RangeValues(minAge, maxAge);

    Widget buildPresetPill(String label, int min, int max) {
      final isSelected = _currentFilters.minAge == min && _currentFilters.maxAge == max;
      return TactilePressable(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _currentFilters = _currentFilters.copyWith(minAge: min, maxAge: max);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.20)
                : (isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF8B5CF6)
                  : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? AppTypography.bold : AppTypography.medium,
              fontSize: AppTypography.labelSmall,
              color: isSelected
                  ? const Color(0xFF8B5CF6)
                  : (isDark ? Colors.white70 : const Color(0xFF475569)),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161424) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildSectionHeader(
                  theme: theme,
                  icon: Icons.cake_rounded,
                  iconAccent: const Color(0xFF8B5CF6),
                  title: AppLocalizations.of(context)?.ageRange ?? 'Age Range',
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.30),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  AppLocalizations.of(context)?.ageRangeYears(minAge.toInt(), maxAge.toInt()) ?? '${minAge.toInt()} - ${maxAge.toInt()} yrs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: AppTypography.extraBold,
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF8B5CF6),
              inactiveTrackColor: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
              thumbColor: const Color(0xFF8B5CF6),
              overlayColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 8.5,
                elevation: 3,
              ),
              trackHeight: 3.5,
            ),
            child: RangeSlider(
              values: currentRange,
              min: _minAgeLimit,
              max: _maxAgeLimit,
              divisions: (_maxAgeLimit - _minAgeLimit).toInt(),
              labels: RangeLabels(
                '${currentRange.start.toInt()} yrs',
                '${currentRange.end.toInt()} yrs',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentFilters = _currentFilters.copyWith(
                    minAge: values.start.round(),
                    maxAge: values.end.round(),
                  );
                });
              },
            ),
          ),

          const SizedBox(height: 2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                buildPresetPill('18-25', 18, 25),
                const SizedBox(width: 6),
                buildPresetPill('22-28', 22, 28),
                const SizedBox(width: 6),
                buildPresetPill('25-32', 25, 32),
                const SizedBox(width: 6),
                buildPresetPill('28-35', 28, 35),
                const SizedBox(width: 6),
                buildPresetPill('35-45', 35, 45),
                const SizedBox(width: 6),
                buildPresetPill('Any Age', 18, 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoOnlySection(ThemeData theme, bool isDark) {
    final hasPhoto = _currentFilters.hasPhoto ?? false;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161424) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hasPhoto
              ? const Color(0xFF0EA5E9).withValues(alpha: 0.65)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
          width: hasPhoto ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasPhoto
                ? const Color(0xFF0EA5E9).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(9.5),
            decoration: BoxDecoration(
              color: hasPhoto
                  ? const Color(0xFF0EA5E9)
                  : const Color(0xFF0EA5E9).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              boxShadow: hasPhoto
                  ? [
                      BoxShadow(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.photo_camera_rounded,
              size: 20,
              color: hasPhoto ? Colors.white : const Color(0xFF0EA5E9),
            ),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.mustHavePhoto ?? 'Must Have Photo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: AppTypography.extraBold,
                    fontSize: AppTypography.bodyMedium,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context)?.onlyShowProfilesWithPhoto ?? 'Only show profiles with verified photo albums',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: hasPhoto,
            activeTrackColor: const Color(0xFF0EA5E9),
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() {
                _currentFilters = _currentFilters.copyWith(hasPhoto: val);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaritalStatusSection(ThemeData theme, bool isDark) {
    final options = [
      AppLocalizations.of(context)?.neverMarried ?? 'Never Married',
      AppLocalizations.of(context)?.divorced ?? 'Divorced',
      AppLocalizations.of(context)?.widowed ?? 'Widowed',
      AppLocalizations.of(context)?.awaitingDivorce ?? 'Awaiting Divorce',
    ];
    final selectedStatus = _currentFilters.maritalStatus ?? '';

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.favorite_rounded,
      iconAccent: const Color(0xFFBE123C),
      title: AppLocalizations.of(context)?.maritalStatusLabel ?? 'Marital Status',
      subtitle: AppLocalizations.of(context)?.selectMaritalStatus ?? 'Select marital status requirement',
      options: options,
      selectedItems: selectedStatus.isNotEmpty ? [selectedStatus] : [],
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        setState(() {
          _currentFilters = _currentFilters.copyWith(
            maritalStatus: selectedStatus == opt ? '' : opt,
          );
        });
      },
    );
  }

  Widget _buildLocationSection(ThemeData theme, bool isDark) {
    final states = [
      'Maharashtra',
      'Telangana',
      'Karnataka',
      'Andhra Pradesh',
      'Madhya Pradesh',
      'Gujarat',
      'Rajasthan',
      'Other States',
    ];
    final selectedState = _currentFilters.state ?? '';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161424) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.location_on_rounded,
            iconAccent: const Color(0xFF0EA5E9),
            title: AppLocalizations.of(context)?.locationAndState ?? 'Location & Native State',
            subtitle: AppLocalizations.of(context)?.filterCandidateHomeState ?? 'Filter candidate home state or current residing district',
          ),
          SizedBox(height: 1.6.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.0.h,
            children: states.map((st) {
              final isSelected = selectedState.toLowerCase() == st.toLowerCase();
              return TactilePressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(
                      state: isSelected ? '' : st,
                    );
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.9.h),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0EA5E9)
                          : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0EA5E9).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    st,
                    style: TextStyle(
                      fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                      fontSize: AppTypography.labelSmall,
                      color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 1.6.h),
          TextField(
            controller: _districtController,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: AppTypography.semiBold),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.enterDistrictExample ?? 'Enter District (e.g. Nanded, Yavatmal, Nizamabad)',
              prefixIcon: const Icon(
                Icons.map_rounded,
                color: Color(0xFF0EA5E9),
                size: 20,
              ),
              suffixIcon: _districtController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.cancel_rounded, size: 18),
                      onPressed: () {
                        _districtController.clear();
                        setState(() {
                          _currentFilters = _currentFilters.copyWith(district: '');
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? const Color(0xFF0F0D1A) : const Color(0xFFF8FAFC),
              contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.3.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF0EA5E9),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (val) {
              _currentFilters = _currentFilters.copyWith(district: val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBasicEducationSection(ThemeData theme, bool isDark) {
    final options = [
      'High School / Below',
      AppLocalizations.of(context)?.graduate ?? 'Graduate',
      AppLocalizations.of(context)?.postGraduate ?? 'Post Graduate',
      AppLocalizations.of(context)?.doctorate ?? 'Doctorate',
    ];
    final selectedList = _currentFilters.education ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.school_rounded,
      iconAccent: const Color(0xFF10B981),
      title: 'Basic Education Level',
      subtitle: 'Filter by primary academic attainment',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(education: list);
        });
      },
    );
  }

  // ===========================================================================
  // 🌟 2. COMMUNITY / BVS FILTERS CONTAINER (₹20/mo or ₹200/yr)
  // ===========================================================================

  Widget _buildCommunityContainer(ThemeData theme, bool isDark) {
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGotraSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildMaternalGotraSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildSubCasteSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildOriginTypeSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildHeightSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildEducationFieldSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildProfessionSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildAnnualIncomeSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildFamilyTypeSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildFamilyValuesSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildFamilyStatusSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildProfileCreatedBySection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildPhysicalStatusSection(theme, isDark),
      ],
    );

    if (_hasCommunityAccess) {
      return child;
    }

    return Stack(
      children: [
        IgnorePointer(
          child: Opacity(
            opacity: 0.38,
            child: child,
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _showCommunityUpgradeSheet(context, theme, isDark),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 1.5.h),
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF12101C) : Colors.white).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.65),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      size: 32,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  SizedBox(height: 1.4.h),
                  Text(
                    AppLocalizations.of(context)?.unlockCommunityFiltersTitle ?? 'Unlock Community Filters (BVS)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTypography.black,
                      fontSize: AppTypography.headingSmall,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 0.6.h),
                  Text(
                    AppLocalizations.of(context)?.unlockCommunityFiltersDesc ?? 'Filter Gotra, Maternal Gotra (मोसळ), Sub-Caste, Tanda/Origin, Height, Income & Lineage for just ₹20/mo or ₹200/yr.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: AppTypography.labelSmall,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 1.0.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBE123C), Color(0xFF881337)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBE123C).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.unlockForPriceButton ?? 'Unlock for ₹20/mo or ₹200/yr ➔',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGotraSection(ThemeData theme, bool isDark) {
    final gotraOptions = [
      'Pawar / Pramara',
      'Rathod',
      'Chauhan / Chawan',
      'Jadhav',
      'Vaditya',
      'Naik',
      'Bhukya',
      'Khamawat',
      'Puri',
      'Other Gotra',
    ];
    final selectedList = _currentFilters.gotra ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.auto_awesome_rounded,
      iconAccent: const Color(0xFFF59E0B),
      title: AppLocalizations.of(context)?.banjaraGotraSelfClan ?? 'Banjara Gotra (Self Clan)',
      subtitle: AppLocalizations.of(context)?.selectPaternalGotra ?? 'Select candidate paternal Gotra customary clan',
      options: gotraOptions,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(gotra: list);
        });
      },
    );
  }

  Widget _buildMaternalGotraSection(ThemeData theme, bool isDark) {
    final gotraOptions = [
      'Pawar / Pramara',
      'Rathod',
      'Chauhan / Chawan',
      'Jadhav',
      'Vaditya',
      'Naik',
      'Bhukya',
      'Khamawat',
      'Puri',
      'Other Gotra',
    ];
    final selectedList = _currentFilters.maternalGotra ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.family_restroom_rounded,
      iconAccent: const Color(0xFFF59E0B),
      title: AppLocalizations.of(context)?.maternalGotraMamakul ?? 'Maternal Gotra (Mamakul / मोसळ)',
      subtitle: AppLocalizations.of(context)?.maternalGotraSubtitle ?? 'Exclude or specify maternal lineage to avoid customary gotra clash',
      options: gotraOptions,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(maternalGotra: list);
        });
      },
    );
  }

  Widget _buildSubCasteSection(ThemeData theme, bool isDark) {
    final options = [
      'Gor / Lambadi',
      'Sugali',
      'Banjara',
      'Mathura Banjara',
      'Labana',
      'Other Sub-Caste',
    ];
    final selectedList = _currentFilters.subCaste ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.diversity_3_rounded,
      iconAccent: const Color(0xFFF59E0B),
      title: AppLocalizations.of(context)?.subCasteJatiVariant ?? 'Sub-Caste / Jati Variant',
      subtitle: AppLocalizations.of(context)?.subCasteSubtitle ?? 'Filter by regional Banjara cultural designation',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(subCaste: list);
        });
      },
    );
  }

  Widget _buildOriginTypeSection(ThemeData theme, bool isDark) {
    final options = [
      'Native Tanda (तांडा)',
      'Taluka Town',
      'Tier 1/2 City',
      'Metro City',
    ];
    final selectedList = _currentFilters.originType ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.holiday_village_rounded,
      iconAccent: const Color(0xFFF59E0B),
      title: AppLocalizations.of(context)?.habitatNativeOrigin ?? 'Habitat / Native Origin',
      subtitle: AppLocalizations.of(context)?.habitatSubtitle ?? 'Filter candidate living environment & origin type',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(originType: list);
        });
      },
    );
  }

  Widget _buildHeightSection(ThemeData theme, bool isDark) {
    final heightOptions = [
      'Any Height',
      '5\'0"+',
      '5\'3"+',
      '5\'5"+',
      '5\'8"+',
      '6\'0"+',
    ];
    final selectedMin = _currentFilters.minHeight ?? 'Any Height';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161424) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.height_rounded,
            iconAccent: const Color(0xFF10B981),
            title: AppLocalizations.of(context)?.minimumHeight ?? 'Minimum Height',
            subtitle: AppLocalizations.of(context)?.minimumHeightSubtitle ?? 'Select minimum height requirement for matches',
          ),
          SizedBox(height: 1.6.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.0.h,
            children: heightOptions.map((h) {
              final isSelected = (selectedMin == h) || (h == 'Any Height' && (selectedMin.isEmpty || selectedMin == 'Any Height'));
              return TactilePressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(
                      minHeight: h == 'Any Height' ? '' : h,
                    );
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.0.h),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF10B981)
                          : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    h,
                    style: TextStyle(
                      fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                      fontSize: AppTypography.bodySmall,
                      color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationFieldSection(ThemeData theme, bool isDark) {
    final options = [
      'Engineering / IT',
      'Medical / Healthcare',
      'CA / Finance / Accounts',
      'Law / Judiciary',
      'Govt Administration',
      'Arts / Science / Commerce',
      'Business / Management (MBA)',
      'Diploma / Technical',
    ];
    final selectedList = _currentFilters.educationField ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.school_rounded,
      iconAccent: const Color(0xFF6366F1),
      title: AppLocalizations.of(context)?.educationFieldStream ?? 'Education Field / Stream',
      subtitle: AppLocalizations.of(context)?.educationFieldSubtitle ?? 'Filter by specialized degree stream & career path',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(educationField: list);
        });
      },
    );
  }

  Widget _buildProfessionSection(ThemeData theme, bool isDark) {
    final options = [
      AppLocalizations.of(context)?.governmentJob ?? 'Government Job',
      AppLocalizations.of(context)?.privateJob ?? 'Private Job',
      AppLocalizations.of(context)?.business ?? 'Business',
      AppLocalizations.of(context)?.selfEmployed ?? 'Self Employed',
      'Software / IT',
      'Doctor / Healthcare',
      'Banking / Finance',
      'Teaching / Education',
      'Civil Services / Police',
      'Defense / Armed Forces',
    ];
    final selectedList = _currentFilters.profession ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.work_rounded,
      iconAccent: const Color(0xFF14B8A6),
      title: AppLocalizations.of(context)?.professionLabel ?? 'Profession',
      subtitle: 'Select candidate career and occupation categories',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(profession: list);
        });
      },
    );
  }

  Widget _buildAnnualIncomeSection(ThemeData theme, bool isDark) {
    final options = [
      'Below ₹3 Lakhs',
      '₹3L - ₹6L',
      '₹6L - ₹10L',
      '₹10L - ₹15L',
      '₹15L - ₹25L',
      '₹25L+',
    ];
    final selectedList = _currentFilters.annualIncome ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.payments_rounded,
      iconAccent: const Color(0xFF22C55E),
      title: AppLocalizations.of(context)?.annualIncome ?? 'Annual Income',
      subtitle: AppLocalizations.of(context)?.annualIncomeSubtitle ?? 'Select candidate yearly income expectations',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(annualIncome: list);
        });
      },
    );
  }

  Widget _buildFamilyTypeSection(ThemeData theme, bool isDark) {
    final options = ['Nuclear Family', 'Joint Family'];
    final selectedList = _currentFilters.familyType ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.groups_rounded,
      iconAccent: const Color(0xFFA855F7),
      title: AppLocalizations.of(context)?.familyStructure ?? 'Family Structure',
      subtitle: AppLocalizations.of(context)?.familyStructureSubtitle ?? 'Select nuclear or joint family preferences',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(familyType: list);
        });
      },
    );
  }

  Widget _buildFamilyValuesSection(ThemeData theme, bool isDark) {
    final options = ['Traditional', 'Moderate', 'Liberal'];
    final selectedList = _currentFilters.familyValues ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.favorite_outline_rounded,
      iconAccent: const Color(0xFFF59E0B),
      title: AppLocalizations.of(context)?.familyValues ?? 'Family Values',
      subtitle: AppLocalizations.of(context)?.familyValuesSubtitle ?? 'Filter by cultural and social outlook',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(familyValues: list);
        });
      },
    );
  }

  Widget _buildFamilyStatusSection(ThemeData theme, bool isDark) {
    final options = ['Middle Class', 'Upper Middle Class', 'Rich / Affluent'];
    final selectedList = _currentFilters.familyStatus ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.villa_rounded,
      iconAccent: const Color(0xFFD946EF),
      title: AppLocalizations.of(context)?.familyStatus ?? 'Family Status',
      subtitle: AppLocalizations.of(context)?.familyStatusSubtitle ?? 'Select socioeconomic family status requirement',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(familyStatus: list);
        });
      },
    );
  }

  Widget _buildProfileCreatedBySection(ThemeData theme, bool isDark) {
    final options = ['Self', 'Parent', 'Sibling', 'Relative / Guardian', 'Friend'];
    final selectedList = _currentFilters.profileCreatedBy ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.person_pin_rounded,
      iconAccent: const Color(0xFF0284C7),
      title: AppLocalizations.of(context)?.profileManagedBy ?? 'Profile Managed By',
      subtitle: AppLocalizations.of(context)?.profileManagedBySubtitle ?? 'Select who created and manages the candidate biodata',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(profileCreatedBy: list);
        });
      },
    );
  }

  Widget _buildPhysicalStatusSection(ThemeData theme, bool isDark) {
    final bool? isDisabled = _currentFilters.isDisabled;

    Widget buildOptionPill(String label, bool? value) {
      final isSelected = isDisabled == value;
      return Expanded(
        child: TactilePressable(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _currentFilters = _currentFilters.copyWith(isDisabled: value);
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(vertical: 1.2.h),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    )
                  : null,
              color: isSelected
                  ? null
                  : (isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? const Color(0xFF6366F1) : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                fontSize: AppTypography.labelSmall,
                color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161424) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.accessible_rounded,
            iconAccent: const Color(0xFF6366F1),
            title: AppLocalizations.of(context)?.physicalHealthStatus ?? 'Physical Health Status',
            subtitle: AppLocalizations.of(context)?.physicalHealthStatusSubtitle ?? 'Select physical disability match preferences',
          ),
          SizedBox(height: 1.6.h),
          Row(
            children: [
              buildOptionPill(AppLocalizations.of(context)?.allProfiles ?? 'All Profiles', null),
              SizedBox(width: 2.w),
              buildOptionPill(AppLocalizations.of(context)?.ableBodied ?? 'Able-Bodied', false),
              SizedBox(width: 2.w),
              buildOptionPill(AppLocalizations.of(context)?.differentlyAbled ?? 'Diff. Abled', true),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ⚡ 3. PREMIUM FILTERS CONTAINER (Self Service)
  // ===========================================================================

  Widget _buildPremiumContainer(ThemeData theme, bool isDark) {
    final isVerified = _currentFilters.isVerified ?? false;
    final isTrusted = _currentFilters.isCommunityTrusted ?? false;
    final isIncomeVer = _currentFilters.isIncomeVerified ?? false;
    final hasHoro = _currentFilters.hasHoroscope ?? false;
    final isRecent = _currentFilters.isRecentlyActive ?? false;
    final isHighResp = _currentFilters.isHighResponse ?? false;
    final hasMultiPics = _currentFilters.hasMultiplePhotos ?? false;

    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Trust & Verification
        _buildToggleTile(
          title: AppLocalizations.of(context)?.govtIdVerified ?? 'Govt ID / Aadhaar Verified',
          subtitle: AppLocalizations.of(context)?.govtIdVerifiedSubtitle ?? 'Only show candidates with 100% verified Govt ID badge',
          icon: Icons.verified_user_rounded,
          value: isVerified,
          activeColor: const Color(0xFF10B981),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isVerified: val);
            });
          },
          isDark: isDark,
        ),
        SizedBox(height: 1.2.h),
        _buildToggleTile(
          title: AppLocalizations.of(context)?.communityTrustedProfiles ?? 'Community Trusted Profiles',
          subtitle: AppLocalizations.of(context)?.communityTrustedProfilesSubtitle ?? 'Vouched Banjara profiles with Community Trust Score > 75%',
          icon: Icons.shield_rounded,
          value: isTrusted,
          activeColor: const Color(0xFF8B5CF6),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isCommunityTrusted: val);
            });
          },
          isDark: isDark,
        ),
        SizedBox(height: 1.2.h),
        _buildToggleTile(
          title: AppLocalizations.of(context)?.incomeSalaryVerified ?? 'Income / Salary Verified',
          subtitle: AppLocalizations.of(context)?.incomeSalaryVerifiedSubtitle ?? 'Candidates with verified salary slip or ITR documentation',
          icon: Icons.request_quote_rounded,
          value: isIncomeVer,
          activeColor: const Color(0xFF22C55E),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isIncomeVerified: val);
            });
          },
          isDark: isDark,
        ),
        SizedBox(height: 1.8.h),

        // 2. Astrological / Kundali Section
        _buildManglikSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildRashiSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildToggleTile(
          title: AppLocalizations.of(context)?.kundaliHoroscopeAttached ?? 'Kundali / Horoscope Attached',
          subtitle: AppLocalizations.of(context)?.kundaliHoroscopeAttachedSubtitle ?? 'Only show profiles with uploaded Janam Kundali chart',
          icon: Icons.auto_awesome_rounded,
          value: hasHoro,
          activeColor: Colors.amber,
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(hasHoroscope: val);
            });
          },
          isDark: isDark,
        ),
        SizedBox(height: 1.8.h),

        // 3. Employment Sector
        _buildEmploymentSectorSection(theme, isDark),
        SizedBox(height: 1.8.h),

        // 4. Dietary & Habits
        _buildDietSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildHabitsSection(theme, isDark),
        SizedBox(height: 1.8.h),

        // 5. Relocation & Activity
        _buildRelocationSection(theme, isDark),
        SizedBox(height: 1.8.h),
        _buildToggleTile(
          title: 'Recently Active Profiles',
          subtitle: 'Candidates active within the last 24 hours or 7 days',
          icon: Icons.bolt_rounded,
          value: isRecent,
          activeColor: const Color(0xFF0EA5E9),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isRecentlyActive: val);
            });
          },
          isDark: isDark,
        ),
        SizedBox(height: 1.2.h),
        _buildToggleTile(
          title: 'High Response Rate (>80%)',
          subtitle: 'Profiles with proven track record of replying to interest messages',
          icon: Icons.chat_bubble_outline_rounded,
          value: isHighResp,
          activeColor: const Color(0xFFEC4899),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isHighResponse: val);
            });
          },
          isDark: isDark,
        ),
        SizedBox(height: 1.2.h),
        _buildToggleTile(
          title: 'Multiple Photos Album (3+ Photos)',
          subtitle: 'Profiles with complete verified photo albums',
          icon: Icons.photo_library_rounded,
          value: hasMultiPics,
          activeColor: const Color(0xFF8B5CF6),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(hasMultiplePhotos: val);
            });
          },
          isDark: isDark,
        ),
      ],
    );

    if (_hasPremiumAccess) {
      return child;
    }

    return Stack(
      children: [
        IgnorePointer(
          child: Opacity(
            opacity: 0.38,
            child: child,
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _showPremiumUpgradeSheet(context, theme, isDark),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 1.5.h),
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF141022) : Colors.white).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.65),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      border: Border.all(color: const Color(0xFF8B5CF6), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      size: 32,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  SizedBox(height: 1.4.h),
                  Text(
                    AppLocalizations.of(context)?.unlockPremiumFiltersTitle ?? 'Unlock Premium Filters',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTypography.black,
                      fontSize: AppTypography.headingSmall,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 0.6.h),
                  Text(
                    AppLocalizations.of(context)?.unlockPremiumFiltersDesc ?? 'Access Govt ID Verified, Kundali Dosha, Diet, Sector, and Active Responder filters with Premium self-service plans.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: AppTypography.labelSmall,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 1.0.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.viewPremiumPlansButton ?? 'View Premium Plans ➔',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManglikSection(ThemeData theme, bool isDark) {
    final options = ['Non-Manglik', 'Manglik', 'Anshik (Mild)', 'Doesn\'t Matter'];
    final selectedList = _currentFilters.manglikStatus ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.wb_sunny_rounded,
      iconAccent: Colors.amber,
      title: AppLocalizations.of(context)?.manglikDosha ?? 'Manglik / Kuja Dosha',
      subtitle: AppLocalizations.of(context)?.filterAstrologicalCompatibility ?? 'Filter candidate astrological horoscope compatibility',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(manglikStatus: list);
        });
      },
    );
  }

  Widget _buildRashiSection(ThemeData theme, bool isDark) {
    final options = [
      'Mesha (मेष)',
      'Vrishabha (वृषभ)',
      'Mithuna (मिथुन)',
      'Karka (कर्क)',
      'Simha (सिंह)',
      'Kanya (कन्या)',
      'Tula (तूळ)',
      'Vrishchika (वृश्चिक)',
      'Dhanu (धनु)',
      'Makara (मकर)',
      'Kumbha (कुंभ)',
      'Meena (मीन)',
    ];
    final selectedList = _currentFilters.rashi ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.brightness_2_rounded,
      iconAccent: const Color(0xFF8B5CF6),
      title: 'Rashi (Moon Sign / रास)',
      subtitle: 'Select one or more compatible zodiac signs',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(rashi: list);
        });
      },
    );
  }

  Widget _buildEmploymentSectorSection(ThemeData theme, bool isDark) {
    final options = [
      'Central / State Govt (Class 1/2/3)',
      'Public Sector Unit (PSU)',
      'MNC / Private Corporate',
      'Business / Startup Founder',
      'Self-Employed Professional',
    ];
    final selectedList = _currentFilters.employmentSector ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.domain_rounded,
      iconAccent: const Color(0xFF0EA5E9),
      title: 'Employment Sector',
      subtitle: 'Filter by organization and employer category',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(employmentSector: list);
        });
      },
    );
  }

  Widget _buildDietSection(ThemeData theme, bool isDark) {
    final options = ['Pure Vegetarian', 'Eggetarian', 'Non-Vegetarian'];
    final selectedList = _currentFilters.diet ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.restaurant_rounded,
      iconAccent: const Color(0xFF10B981),
      title: 'Dietary Preference',
      subtitle: 'Filter candidate food habits',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(diet: list);
        });
      },
    );
  }

  Widget _buildHabitsSection(ThemeData theme, bool isDark) {
    final smokeOpts = ['Non-Smoker', 'Occasional Smoker'];
    final drinkOpts = ['Non-Drinker', 'Social Drinker', 'Regular Drinker'];
    final selectedSmoke = _currentFilters.smokingHabits ?? [];
    final selectedDrink = _currentFilters.drinkingHabits ?? [];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161424) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.smoke_free_rounded,
            iconAccent: const Color(0xFFF43F5E),
            title: 'Lifestyle & Habits',
            subtitle: 'Smoking and drinking preferences',
          ),
          SizedBox(height: 1.6.h),
          Text(
            'Smoking Habits',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: AppTypography.bold,
              fontSize: AppTypography.labelSmall,
            ),
          ),
          SizedBox(height: 0.8.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 0.8.h,
            children: smokeOpts.map((opt) {
              final isSelected = selectedSmoke.contains(opt);
              return TactilePressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  final list = List<String>.from(selectedSmoke);
                  if (list.contains(opt)) {
                    list.remove(opt);
                  } else {
                    list.add(opt);
                  }
                  setState(() => _currentFilters = _currentFilters.copyWith(smokingHabits: list));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(horizontal: 3.4.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF43F5E).withValues(alpha: 0.20)
                        : (isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFF43F5E) : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                      fontSize: AppTypography.labelSmall,
                      color: isSelected ? const Color(0xFFF43F5E) : (isDark ? Colors.white70 : const Color(0xFF475569)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 1.4.h),
          Text(
            'Drinking Habits',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: AppTypography.bold,
              fontSize: AppTypography.labelSmall,
            ),
          ),
          SizedBox(height: 0.8.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 0.8.h,
            children: drinkOpts.map((opt) {
              final isSelected = selectedDrink.contains(opt);
              return TactilePressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  final list = List<String>.from(selectedDrink);
                  if (list.contains(opt)) {
                    list.remove(opt);
                  } else {
                    list.add(opt);
                  }
                  setState(() => _currentFilters = _currentFilters.copyWith(drinkingHabits: list));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(horizontal: 3.4.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.20)
                        : (isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                      fontSize: AppTypography.labelSmall,
                      color: isSelected ? const Color(0xFF8B5CF6) : (isDark ? Colors.white70 : const Color(0xFF475569)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRelocationSection(ThemeData theme, bool isDark) {
    final options = [
      'Willing to Relocate in India',
      'Willing to Relocate Abroad',
      'NRI / Currently Living Abroad',
    ];
    final selectedList = _currentFilters.relocationPreference ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.flight_takeoff_rounded,
      iconAccent: const Color(0xFF0EA5E9),
      title: 'Relocation & Geographic Flexibility',
      subtitle: 'Filter candidate mobility and NRI status',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(relocationPreference: list);
        });
      },
    );
  }

  // ===========================================================================
  // 👑 4. MATCHMAKER FILTERS CONTAINER (VIP Assisted)
  // ===========================================================================

  Widget _buildMatchmakerContainer(ThemeData theme, bool isDark) {
    final isDirectUnlocked = _currentFilters.isDirectContactUnlocked ?? false;
    final isHandpicked = _currentFilters.isRmHandpicked ?? false;
    final isSpotlight = _currentFilters.isVipSpotlight ?? false;
    final isHouse = _currentFilters.isHouseOwner ?? false;
    final isFamilyOk = _currentFilters.isFamilyVetted ?? false;
    final isConfidential = _currentFilters.isConfidentialMode ?? false;

    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToggleTile(
          title: AppLocalizations.of(context)?.directContactUnlocked ?? 'Direct Contact Unlocked Profiles',
          subtitle: AppLocalizations.of(context)?.directContactUnlockedSubtitle ?? 'Direct Phone Number & WhatsApp verified access',
          icon: Icons.contact_phone_rounded,
          value: isDirectUnlocked,
          activeColor: const Color(0xFFBE123C),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isDirectContactUnlocked: val);
            });
          },
          isDark: isDark,
        ),
        SizedBox(height: 1.2.h),
        _buildToggleTile(
          title: AppLocalizations.of(context)?.rmHandpickedMatches ?? 'RM Handpicked Matches',
          subtitle: AppLocalizations.of(context)?.rmHandpickedMatchesSubtitle ?? 'Profiles curated and vetted by your Personal Relationship Manager',
          icon: Icons.star_rounded,
          value: isHandpicked,
          activeColor: const Color(0xFFF59E0B),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isRmHandpicked: val);
            });
          },
          isDark: isDark,
        ),
        SizedBox(height: 1.8.h),

        // 36 Guna Matchmaker Score
        _build36GunaScoreSection(theme, isDark),
        SizedBox(height: 1.8.h),

        _buildToggleTile(
          title: AppLocalizations.of(context)?.vipSpotlightElitePool ?? 'VIP Spotlight & Elite Pool',
          subtitle: AppLocalizations.of(context)?.vipSpotlightElitePoolSubtitle ?? 'Top-tier prominent Banjara families with premium background checks',
          icon: Icons.military_tech_rounded,
          value: isSpotlight,
          activeColor: const Color(0xFFE11D48),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isVipSpotlight: val);
            });
          },
          isDark: isDark,
        ),
        SizedBox(height: 1.8.h),

        // Ancestral Land Holding (VIP Exclusive)
        _buildAncestralLandSection(theme, isDark),
        SizedBox(height: 1.8.h),

        _buildToggleTile(
          title: AppLocalizations.of(context)?.ownResidentialHouseVilla ?? 'Own Residential House / Villa',
          subtitle: AppLocalizations.of(context)?.ownResidentialHouseVillaSubtitle ?? 'Family owns self-acquired or independent residential house',
          icon: Icons.home_work_rounded,
          value: isHouse,
          activeColor: const Color(0xFF10B981),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isHouseOwner: val);
            });
          },
          isDark: isDark,
        ),
        SizedBox(height: 1.2.h),
        _buildToggleTile(
          title: AppLocalizations.of(context)?.familyReputationVetted ?? 'Family Background & Reputation Vetted',
          subtitle: AppLocalizations.of(context)?.familyReputationVettedSubtitle ?? 'Clean background check conducted by field relationship managers',
          icon: Icons.verified_user_rounded,
          value: isFamilyOk,
          activeColor: const Color(0xFFBE123C),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isFamilyVetted: val);
            });
          },
          isDark: isDark,
        ),
        SizedBox(height: 1.2.h),
        _buildToggleTile(
          title: AppLocalizations.of(context)?.confidentialMatchmaking ?? 'Confidential & Private Matchmaking',
          subtitle: AppLocalizations.of(context)?.confidentialMatchmakingSubtitle ?? 'High-profile biodatas viewable exclusively with mutual RM consent',
          icon: Icons.lock_person_rounded,
          value: isConfidential,
          activeColor: const Color(0xFF8B5CF6),
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isConfidentialMode: val);
            });
          },
          isDark: isDark,
        ),
      ],
    );

    if (_hasMatchmakerAccess) {
      return child;
    }

    return Stack(
      children: [
        IgnorePointer(
          child: Opacity(
            opacity: 0.35,
            child: child,
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _showMatchmakerUpgradeSheet(context, theme, isDark),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 1.5.h),
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF1E101A) : Colors.white).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xFFBE123C).withValues(alpha: 0.65),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBE123C).withValues(alpha: 0.20),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFBE123C).withValues(alpha: 0.15),
                      border: Border.all(color: const Color(0xFFBE123C), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      size: 32,
                      color: Color(0xFFBE123C),
                    ),
                  ),
                  SizedBox(height: 1.4.h),
                  Text(
                    AppLocalizations.of(context)?.unlockMatchmakerFiltersTitle ?? 'Unlock Matchmaker Filters',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTypography.black,
                      fontSize: AppTypography.headingSmall,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 0.6.h),
                  Text(
                    AppLocalizations.of(context)?.unlockMatchmakerFiltersDesc ?? 'Direct contact numbers, 36 Guna Score, Ancestral Land Holdings & RM Curation available on VIP Matchmaker plans.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: AppTypography.labelSmall,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 1.0.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBE123C), Color(0xFF881337)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBE123C).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.exploreMatchmakerPlansButton ?? 'Explore Matchmaker Plans ➔',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _build36GunaScoreSection(ThemeData theme, bool isDark) {
    final options = [
      {'label': '18+ Gunas (Average)', 'val': 18},
      {'label': '21+ Gunas (Good)', 'val': 21},
      {'label': '24+ Gunas (Excellent)', 'val': 24},
      {'label': '28+ Gunas (Utam Match)', 'val': 28},
      {'label': '32+ Gunas (Perfect)', 'val': 32},
    ];
    final selectedVal = _currentFilters.minGunaScore;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161424) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: Icons.auto_awesome_rounded,
            iconAccent: const Color(0xFFF59E0B),
            title: AppLocalizations.of(context)?.astro36GunaMilanScore ?? 'Astro 36 Guna Milan Score',
            subtitle: AppLocalizations.of(context)?.astro36GunaSubtitle ?? 'Filter matches by minimum astrological compatibility threshold',
          ),
          SizedBox(height: 1.6.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.0.h,
            children: options.map((item) {
              final val = item['val'] as int;
              final label = item['label'] as String;
              final isSelected = selectedVal == val;
              return TactilePressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(
                      minGunaScore: isSelected ? null : val,
                    );
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 0.9.h),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                      fontSize: AppTypography.labelSmall,
                      color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAncestralLandSection(ThemeData theme, bool isDark) {
    final options = [
      '5+ Acres Land',
      '10+ Acres Land',
      '20+ Acres Land',
      '50+ Acres Land',
    ];
    final selectedList = _currentFilters.ancestralLandAcres ?? [];

    return _buildGlassMultiChipGroup(
      theme: theme,
      isDark: isDark,
      icon: Icons.agriculture_rounded,
      iconAccent: const Color(0xFF10B981),
      title: AppLocalizations.of(context)?.ancestralLandHoldingsAcres ?? 'Ancestral Land Holdings (Acres)',
      subtitle: AppLocalizations.of(context)?.ancestralLandSubtitle ?? 'Filter candidates by family agricultural land ownership',
      options: options,
      selectedItems: selectedList,
      onToggle: (opt) {
        HapticFeedback.selectionClick();
        final list = List<String>.from(selectedList);
        if (list.contains(opt)) {
          list.remove(opt);
        } else {
          list.add(opt);
        }
        setState(() {
          _currentFilters = _currentFilters.copyWith(ancestralLandAcres: list);
        });
      },
    );
  }

  // ===========================================================================
  // 🧩 REUSABLE WIDGET HELPERS
  // ===========================================================================

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Color activeColor,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161424) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value ? activeColor.withValues(alpha: 0.65) : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          width: value ? 1.6 : 1,
        ),
        boxShadow: value
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(9.5),
            decoration: BoxDecoration(
              color: value ? activeColor : activeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              boxShadow: value
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 18,
              color: value ? Colors.white : activeColor,
            ),
          ),
          SizedBox(width: 3.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: AppTypography.extraBold,
                    fontSize: AppTypography.bodySmall,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: activeColor,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onChanged(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlassMultiChipGroup({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> options,
    required List<String> selectedItems,
    required Function(String) onToggle,
    Color? iconAccent,
  }) {
    final accent = iconAccent ?? theme.colorScheme.primary;
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161424) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            theme: theme,
            icon: icon,
            iconAccent: accent,
            title: title,
            subtitle: subtitle,
            selectedCount: selectedItems.length,
          ),
          SizedBox(height: 1.6.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.0.h,
            children: options.map((opt) {
              final isSelected = selectedItems.contains(opt);
              return TactilePressable(
                onTap: () => onToggle(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 0.9.h),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [accent, accent.withValues(alpha: 0.85)],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? accent
                          : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                      width: isSelected ? 1.4 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: isSelected
                            ? const Row(
                                key: ValueKey('selected'),
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_rounded, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                ],
                              )
                            : const SizedBox.shrink(key: ValueKey('unselected')),
                      ),
                      Text(
                        opt,
                        style: TextStyle(
                          fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                          fontSize: AppTypography.labelSmall,
                          color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingApplyBar(ThemeData theme, bool isDark) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 2.5.h),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF0F0E17) : Colors.white).withValues(alpha: 0.88),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 22,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  TactilePressable(
                    onTap: _resetFilters,
                    child: Container(
                      height: 5.4.h,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161424) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)?.reset ?? 'Reset',
                              style: TextStyle(
                                fontSize: AppTypography.bodySmall,
                                fontWeight: AppTypography.bold,
                                color: isDark ? Colors.white70 : const Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  Expanded(
                    child: TactilePressable(
                      onTap: _applyFilters,
                      child: Container(
                        height: 5.4.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFBE123C), Color(0xFF881337)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFBE123C).withValues(alpha: 0.38),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.tune_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Text(
                                _activeFilterCount > 0
                                    ? (AppLocalizations.of(context)?.applyFiltersCount(_activeFilterCount) ?? 'Apply Filters ($_activeFilterCount Active)')
                                    : (AppLocalizations.of(context)?.applyAllFilters ?? 'Apply All Filters'),
                                key: ValueKey<int>(_activeFilterCount),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: AppTypography.extraBold,
                                  fontSize: AppTypography.bodyMedium,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildPerkRow(ThemeData theme, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 11,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: AppTypography.semiBold,
              fontSize: AppTypography.bodySmall,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 🛍️ UPGRADE MODALS (Community, Premium, Matchmaker)
  // ===========================================================================

  void _showCommunityUpgradeSheet(BuildContext context, ThemeData theme, bool isDark) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.2.h),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  size: 34,
                  color: Color(0xFFF59E0B),
                ),
              ),
              SizedBox(height: 1.6.h),
              Text(
                AppLocalizations.of(context)?.unlockCommunityFiltersTitle ?? 'Unlock Community Filters (BVS)',
                style: TextStyle(
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.headingMedium,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 0.8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)?.subsidizedPricePill ?? 'Subsidized: ₹20 / month  •  ₹200 / year',
                  style: TextStyle(
                    color: const Color(0xFFF59E0B),
                    fontWeight: AppTypography.black,
                    fontSize: AppTypography.bodySmall,
                  ),
                ),
              ),
              SizedBox(height: 2.0.h),
              _buildPerkRow(theme, 'Banjara Gotra & Maternal Gotra (मोसळ) filters', const Color(0xFFF59E0B)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, 'Sub-caste / Jati & Native Tanda origin filters', const Color(0xFFF59E0B)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, 'Height & Physical health status filters', const Color(0xFFF59E0B)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, 'Annual Income & Specialized education streams', const Color(0xFFF59E0B)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, 'Family Structure, Values & Socioeconomic status', const Color(0xFFF59E0B)),
              SizedBox(height: 2.5.h),
              SizedBox(
                width: double.infinity,
                height: 5.5.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE123C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.upgradeToCommunityButton ?? 'Upgrade to Community (₹20/mo or ₹200/yr)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.extraBold,
                      fontSize: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.2.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)?.continueWithStandardFilters ?? 'Continue with Standard Filters',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: AppTypography.semiBold,
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPremiumUpgradeSheet(BuildContext context, ThemeData theme, bool isDark) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.2.h),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFF8B5CF6)),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 34,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              SizedBox(height: 1.6.h),
              Text(
                AppLocalizations.of(context)?.unlockPremiumFiltersTitle ?? 'Unlock Premium Filters',
                style: TextStyle(
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.headingMedium,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 0.8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)?.premiumPlansSubtitle ?? 'Standard • Silver • Gold • Platinum • Eternal',
                  style: TextStyle(
                    color: const Color(0xFF8B5CF6),
                    fontWeight: AppTypography.black,
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ),
              SizedBox(height: 2.0.h),
              _buildPerkRow(theme, 'Govt ID & Income verified profile filters', const Color(0xFF8B5CF6)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, 'Community Trust Score > 75% filter', const Color(0xFF8B5CF6)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, 'Manglik Dosha & Rashi (Horoscope) compatibility', const Color(0xFF8B5CF6)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, 'Diet, Habits, Relocation & Employment Sector', const Color(0xFF8B5CF6)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, 'Recently Active & High Responder filters', const Color(0xFF8B5CF6)),
              SizedBox(height: 2.5.h),
              SizedBox(
                width: double.infinity,
                height: 5.5.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.explorePremiumPlans ?? 'Explore Premium Plans',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.extraBold,
                      fontSize: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.2.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)?.cancel ?? 'Cancel',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: AppTypography.semiBold,
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMatchmakerUpgradeSheet(BuildContext context, ThemeData theme, bool isDark) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E101A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: const Color(0xFFBE123C).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.2.h),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFBE123C).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFBE123C)),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 34,
                  color: Color(0xFFBE123C),
                ),
              ),
              SizedBox(height: 1.6.h),
              Text(
                AppLocalizations.of(context)?.unlockMatchmakerFiltersTitle ?? 'Unlock Matchmaker Filters',
                style: TextStyle(
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.headingMedium,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 0.8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFBE123C).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)?.matchmakerPlansSubtitle ?? 'Elite • Royal • Eternal Elite',
                  style: TextStyle(
                    color: const Color(0xFFBE123C),
                    fontWeight: AppTypography.black,
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ),
              SizedBox(height: 2.0.h),
              _buildPerkRow(theme, 'Direct Phone Number & WhatsApp Unlocks', const Color(0xFFBE123C)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, 'Dedicated Relationship Manager Handpicked Matches', const Color(0xFFBE123C)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, '36 Guna Score & High Compatibility Matching (≥24 Gunas)', const Color(0xFFBE123C)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, 'Ancestral Land Holdings (5+ to 50+ Acres) filter', const Color(0xFFBE123C)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, 'Own Residential House & Vetted Family Background', const Color(0xFFBE123C)),
              SizedBox(height: 0.8.h),
              _buildPerkRow(theme, 'VIP Spotlight & Confidential Matchmaking', const Color(0xFFBE123C)),
              SizedBox(height: 2.5.h),
              SizedBox(
                width: double.infinity,
                height: 5.5.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE123C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.exploreMatchmakerPlans ?? 'Explore Matchmaker Plans',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.extraBold,
                      fontSize: AppTypography.bodyMedium,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.2.h),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)?.cancel ?? 'Cancel',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: AppTypography.semiBold,
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
