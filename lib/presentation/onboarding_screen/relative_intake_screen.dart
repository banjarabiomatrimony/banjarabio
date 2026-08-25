import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/data/location_data.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/theme/app_color_scheme.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/tactile/tactile_back_button.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

/// World-Class High-Clarity Visual Preference Intake for Pathway A: Relative / Visitor Match Browse.
///
/// Features dynamic 60FPS micro-animations, animated 3-segment progress ribbon, 3-per-line
/// relation grid, dynamic live match counter teaser, explicit "All Districts" support,
/// and 100% Day/Night theme harmonization for all 5 supported languages.
class RelativeIntakeScreen extends StatefulWidget {
  /// When true, skips Scaffold/PopScope/ambient wrappers for stepper embedding.
  final bool embedded;

  /// Called when user completes the form in embedded mode (instead of navigating).
  final VoidCallback? onProceed;

  const RelativeIntakeScreen({
    super.key,
    this.embedded = false,
    this.onProceed,
  });

  @override
  State<RelativeIntakeScreen> createState() => _RelativeIntakeScreenState();
}

class _RelativeIntakeScreenState extends State<RelativeIntakeScreen>
    with TickerProviderStateMixin {
  // Q1: Target Gender
  String? _selectedGender;

  // Q2: Relation
  String? _selectedRelation;

  // Q3: Location
  String? _selectedState;
  String? _selectedDistrict;

  // ── Animation Controllers ──
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _particleController;
  late final AnimationController _glintController;

  // ── Orchestrated Staggered Animations ──
  late final Animation<Offset> _genderSlide;
  late final Animation<double> _genderFade;

  late final Animation<Offset> _relationSlide;
  late final Animation<double> _relationFade;

  late final Animation<Offset> _locationSlide;
  late final Animation<double> _locationFade;

  late final Animation<Offset> _ctaSlide;
  late final Animation<double> _ctaFade;

  late final Animation<double> _pulseAnimation;
  late final Animation<double> _ctaPulseAnimation;

  final List<_IntakeFloatingParticle> _particles = [];

  static const List<_RelationKey> _relations = [
    _RelationKey(key: 'son', icon: Icons.boy_rounded, emoji: '👦'),
    _RelationKey(key: 'daughter', icon: Icons.girl_rounded, emoji: '👧'),
    _RelationKey(key: 'sibling', icon: Icons.people_alt_rounded, emoji: '👫'),
    _RelationKey(key: 'relative', icon: Icons.family_restroom_rounded, emoji: '👨‍👩‍👧'),
    _RelationKey(key: 'self', icon: Icons.person_rounded, emoji: '👤'),
    _RelationKey(key: 'other', icon: Icons.more_horiz_rounded, emoji: '✨'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedState = 'Maharashtra';

    // 1. Entrance Staggered Controller (850ms fluid curve)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _genderSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.05, 0.40, curve: Curves.easeOutCubic),
    ));
    _genderFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.05, 0.40, curve: Curves.easeOut),
    ));

    _relationSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.60, curve: Curves.easeOutCubic),
    ));
    _relationFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.60, curve: Curves.easeOut),
    ));

    _locationSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.80, curve: Curves.easeOutCubic),
    ));
    _locationFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.80, curve: Curves.easeOut),
    ));

    _ctaSlide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
    ));
    _ctaFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    ));

    // 2. Ambient Glow Breathing Pulse (3000ms)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _ctaPulseAnimation = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // 3. Starlight Constellation Particles (9000ms)
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();

    // 4. Glint Sheen Controller (2800ms)
    _glintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    final random = math.Random(888);
    for (int i = 0; i < 16; i++) {
      _particles.add(
        _IntakeFloatingParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          radius: 1.0 + random.nextDouble() * 2.0,
          speed: 0.2 + random.nextDouble() * 0.40,
          isGold: random.nextBool(),
        ),
      );
    }

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _glintController.dispose();
    super.dispose();
  }

  int get _completedSteps {
    int count = 0;
    if (_selectedGender != null) count++;
    if (_selectedRelation != null) count++;
    if (_selectedState != null) count++;
    return count;
  }

  bool get _isFormValid =>
      _selectedRelation != null &&
      _selectedGender != null &&
      _selectedState != null;

  Future<void> _onBack() async {
    HapticFeedback.lightImpact();
    if (widget.embedded) return;
    await LocalCacheService().clearRelativeBrowseSession();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true)
        .pushReplacementNamed(AppRoutes.userTypeSelection);
  }

  Future<void> _onProceed() async {
    if (!_isFormValid) return;
    HapticFeedback.heavyImpact();

    await LocalCacheService().saveRelativeIntent(
      relation: _selectedRelation!,
      targetGender: _selectedGender!,
      state: _selectedState,
      district: _selectedDistrict == 'ALL' ? null : _selectedDistrict,
    );

    if (!mounted) return;

    if (widget.embedded && widget.onProceed != null) {
      widget.onProceed!();
    } else {
      // 🚀 SMART RESOLVER: Skip auth wall — route directly to HomeScreen as guest
      await LocalCacheService().setGuestMode(true);
      await LocalCacheService().setRelativeBrowseMode(true);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    }
  }

  void _onGenderSelected(String gender) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedGender = gender;
      // Smart Auto-Selection for non-literate/elderly clarity:
      // If user wants a Girl/Bride (Female) -> Auto-select "For My Son" (son)
      // If user wants a Boy/Groom (Male) -> Auto-select "For My Daughter" (daughter)
      if (gender == 'Female') {
        _selectedRelation = 'son';
      } else if (gender == 'Male') {
        _selectedRelation = 'daughter';
      }
    });
  }

  void _onRelationSelected(String relationKey) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedRelation = relationKey;
      // Smart Auto-Selection for non-literate/elderly clarity:
      // If searching for a Son -> Auto-select Bride/Girl (Female)
      // If searching for a Daughter -> Auto-select Groom/Boy (Male)
      if (relationKey == 'son') {
        _selectedGender = 'Female';
      } else if (relationKey == 'daughter') {
        _selectedGender = 'Male';
      }
    });
  }

  String _getRelationLabel(String key, AppLocalizations? l10n) {
    final String rawLabel;
    switch (key) {
      case 'son':
        rawLabel = l10n?.forMySon ?? 'For My Son';
        break;
      case 'daughter':
        rawLabel = l10n?.forMyDaughter ?? 'For My Daughter';
        break;
      case 'sibling':
        rawLabel = l10n?.forMySibling ?? 'For My Sibling';
        break;
      case 'relative':
        rawLabel = l10n?.forMyRelative ?? 'For My Relative';
        break;
      case 'self':
        rawLabel = l10n?.forMyself ?? 'For Myself';
        break;
      case 'other':
        rawLabel = l10n?.forOther ?? 'For Someone Else';
        break;
      default:
        rawLabel = key;
    }
    return rawLabel.replaceAll(RegExp(r'^[^\w\u0900-\u0DFF]+'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final i18n = _IntakeL10n.of(context);
    final primary = theme.colorScheme.primary;

    final coreContent = Column(
      children: [
        // Top Stepper Strip in embedded mode
        if (widget.embedded)
          _buildEmbeddedStepHeader(theme, isDark, primary, i18n),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 3.8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 0.8.h),

                // ── Q1: Target Gender (First Question) ──
                SlideTransition(
                  position: _genderSlide,
                  child: FadeTransition(
                    opacity: _genderFade,
                    child: _buildSectionCard(
                      theme: theme,
                      isDark: isDark,
                      stepNumber: '1',
                      title: i18n.targetGenderTitle(l10n),
                      subtitle: i18n.targetGenderSubtitle(l10n),
                      icon: Icons.wc_rounded,
                      child: Row(
                        children: [
                          Expanded(
                            child: _GenderCard(
                              label: i18n.brideLabel(l10n),
                              subtitle: i18n.brideSubtitle,
                              purposeHint: i18n.brideHint,
                              emoji: '👧',
                              icon: Icons.girl_rounded,
                              value: 'Female',
                              isSelected: _selectedGender == 'Female',
                              accentColor: AppColors.crimsonBlush,
                              isDark: isDark,
                              onTap: () => _onGenderSelected('Female'),
                            ),
                          ),
                          SizedBox(width: 2.5.w),
                          Expanded(
                            child: _GenderCard(
                              label: i18n.groomLabel(l10n),
                              subtitle: i18n.groomSubtitle,
                              purposeHint: i18n.groomHint,
                              emoji: '👦',
                              icon: Icons.boy_rounded,
                              value: 'Male',
                              isSelected: _selectedGender == 'Male',
                              accentColor: AppColors.sapphireBlue,
                              isDark: isDark,
                              onTap: () => _onGenderSelected('Male'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 0.9.h),

                // ── Q2: Relation (Second Question: 3 - 3 Layout) ──
                SlideTransition(
                  position: _relationSlide,
                  child: FadeTransition(
                    opacity: _relationFade,
                    child: _buildSectionCard(
                      theme: theme,
                      isDark: isDark,
                      stepNumber: '2',
                      title: i18n.relationTitle(l10n),
                      subtitle: i18n.relationSubtitle(l10n),
                      icon: Icons.family_restroom_rounded,
                      child: Column(
                        children: [
                          // Line 1: 3 options (Son, Daughter, Sibling)
                          Row(
                            children: [
                              for (int i = 0; i < 3; i++) ...[
                                if (i > 0) SizedBox(width: 1.8.w),
                                Expanded(
                                  child: _TactileChip(
                                    label: _getRelationLabel(_relations[i].key, l10n),
                                    purposeHint: i18n.relationHint(_relations[i].key),
                                    emoji: _relations[i].emoji,
                                    icon: _relations[i].icon,
                                    isSelected: _selectedRelation == _relations[i].key,
                                    primaryColor: primary,
                                    isDark: isDark,
                                    onTap: () => _onRelationSelected(_relations[i].key),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 0.7.h),
                          // Line 2: 3 options (Relative, Self, Other)
                          Row(
                            children: [
                              for (int i = 3; i < 6; i++) ...[
                                if (i > 3) SizedBox(width: 1.8.w),
                                Expanded(
                                  child: _TactileChip(
                                    label: _getRelationLabel(_relations[i].key, l10n),
                                    purposeHint: i18n.relationHint(_relations[i].key),
                                    emoji: _relations[i].emoji,
                                    icon: _relations[i].icon,
                                    isSelected: _selectedRelation == _relations[i].key,
                                    primaryColor: primary,
                                    isDark: isDark,
                                    onTap: () => _onRelationSelected(_relations[i].key),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 0.9.h),

                // ── Q3: Location ──
                SlideTransition(
                  position: _locationSlide,
                  child: FadeTransition(
                    opacity: _locationFade,
                    child: _buildSectionCard(
                      theme: theme,
                      isDark: isDark,
                      stepNumber: '3',
                      title: i18n.locationTitle(l10n),
                      subtitle: i18n.locationSubtitle,
                      icon: Icons.location_on_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Location Shortcuts
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _locationQuickChip(
                                  stateName: 'Maharashtra',
                                  label: '🚩 ${LocationData.getLocalizedName('Maharashtra', context)}',
                                  isDark: isDark,
                                  primary: primary,
                                ),
                                SizedBox(width: 1.5.w),
                                _locationQuickChip(
                                  stateName: 'Karnataka',
                                  label: '🚩 ${LocationData.getLocalizedName('Karnataka', context)}',
                                  isDark: isDark,
                                  primary: primary,
                                ),
                                SizedBox(width: 1.5.w),
                                _locationQuickChip(
                                  stateName: 'Telangana',
                                  label: '🚩 ${LocationData.getLocalizedName('Telangana', context)}',
                                  isDark: isDark,
                                  primary: primary,
                                ),
                                SizedBox(width: 1.5.w),
                                _locationQuickChip(
                                  stateName: 'Andhra Pradesh',
                                  label: '🚩 ${LocationData.getLocalizedName('Andhra Pradesh', context)}',
                                  isDark: isDark,
                                  primary: primary,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 0.9.h),

                          // Dropdowns Row (State & District with "All Districts" support)
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdownField(
                                  theme: theme,
                                  isDark: isDark,
                                  hint: l10n?.selectState ?? 'Select State',
                                  icon: Icons.map_rounded,
                                  value: _selectedState,
                                  items: LocationData.states,
                                  onChanged: (val) {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _selectedState = val;
                                      if (val != null &&
                                          _selectedDistrict != null &&
                                          _selectedDistrict != 'ALL' &&
                                          !LocationData.getDistricts(val).contains(_selectedDistrict)) {
                                        _selectedDistrict = null;
                                      }
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: _buildDropdownField(
                                  theme: theme,
                                  isDark: isDark,
                                  hint: l10n?.selectDistrict ?? 'Select District',
                                  icon: Icons.location_city_rounded,
                                  value: _selectedDistrict,
                                  items: LocationData.getDistricts(_selectedState ?? 'Maharashtra'),
                                  includeAllOption: true,
                                  allOptionLabel: i18n.allDistrictsOption,
                                  onChanged: (val) {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _selectedDistrict = (val == 'ALL' || val == null) ? null : val;
                                      _selectedState ??= 'Maharashtra';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── High-Clarity Visual Purpose Summary (The Magic Mirror) ──
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: (_selectedGender != null || _selectedRelation != null)
                      ? Padding(
                          padding: EdgeInsets.only(top: 0.8.h),
                          child: _VisualExplanationFormulaCard(
                            selectedGender: _selectedGender,
                            selectedRelation: _selectedRelation,
                            selectedState: _selectedState,
                            selectedDistrict: _selectedDistrict,
                            isDark: isDark,
                            primary: primary,
                            i18n: i18n,
                            l10n: l10n,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                SizedBox(height: 1.4.h),
              ],
            ),
          ),
        ),

        // 3. Bottom Sticky Action Bar with Shimmer Glint Sheen
        SlideTransition(
          position: _ctaSlide,
          child: FadeTransition(
            opacity: _ctaFade,
            child: _buildBottomCTA(theme, isDark, l10n, primary, i18n),
          ),
        ),
      ],
    );

    if (widget.embedded) return coreContent;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBack();
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.canvasDark : AppColors.canvasLight,
        appBar: CustomAppBar(
          leading: TactileBackButton(onPressed: _onBack),
          title: i18n.appBarTitle(l10n),
          subtitle: i18n.stepProgressTitle,
          centerTitle: false,
          elevation: 0,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 3.5.w),
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final badgeColor = isDark
                        ? (_completedSteps == 3 ? AppColors.categoryLocation : AppColors.goldLemon)
                        : Colors.white;

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.slate800.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: badgeColor.withValues(alpha: 0.45),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: badgeColor.withValues(alpha: isDark ? 0.2 : 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _completedSteps == 3
                                ? Icons.verified_rounded
                                : Icons.auto_awesome_rounded,
                            size: 13,
                            color: badgeColor,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            i18n.stepCompleted(_completedSteps),
                            style: TextStyle(
                              fontSize: AppTypography.labelSmall,
                              fontWeight: AppTypography.black,
                              color: badgeColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2),
              child: Row(
                children: List.generate(3, (index) {
                  const stepColors = [
                    AppColors.sapphireBlue,
                    AppColors.categoryFamily,
                    AppColors.categoryLocation,
                  ];
                  final stepNumber = index + 1;
                  final isDone = stepNumber <= _completedSteps;
                  final isCurrent = stepNumber == _completedSteps + 1;
                  final color = isDone
                      ? (isDark ? stepColors[index] : AppColors.goldLemon)
                      : (isCurrent
                          ? (isDark ? stepColors[index] : AppColors.goldLemon).withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: isDark ? 0.15 : 0.25));

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 1.5.w : 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                          border: isCurrent
                              ? Border.all(
                                  color: Colors.white.withValues(alpha: 0.8),
                                )
                              : null,
                          boxShadow: isDone
                              ? [
                                  BoxShadow(
                                    color: (isDark ? stepColors[index] : AppColors.goldLemon).withValues(alpha: 0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // Layer 0: Background Gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const RadialGradient(
                          center: Alignment(0, -0.6),
                          radius: 1.4,
                          colors: [
                            AppColors.slate900,
                            AppColors.canvasDark,
                          ],
                        )
                      : const RadialGradient(
                          center: Alignment(0, -0.6),
                          radius: 1.4,
                          colors: [
                            Colors.white,
                            AppColors.canvasLight,
                          ],
                        ),
                ),
              ),
            ),

            // Layer 1: Ambient Floating Aurora Orbs
            Positioned(
              top: -8.h,
              right: -12.w,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: _auroraOrb(
                  58.w,
                  primary.withValues(alpha: isDark ? 0.20 : 0.10),
                ),
              ),
            ),
            Positioned(
              top: 32.h,
              left: -16.w,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: _auroraOrb(
                  46.w,
                  AppColors.sapphireBlue.withValues(alpha: isDark ? 0.14 : 0.07),
                ),
              ),
            ),

            // Layer 2: Floating Constellation Particles
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _IntakeConstellationParticlePainter(
                        progress: _particleController.value,
                        particles: _particles,
                        isDark: isDark,
                        primaryColor: primary,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Layer 3: Main Content
            coreContent,
          ],
        ),
      ),
    );
  }

  Widget _buildEmbeddedStepHeader(
    ThemeData theme,
    bool isDark,
    Color primary,
    _IntakeL10n i18n,
  ) {
    const stepColors = [
      AppColors.sapphireBlue,
      AppColors.categoryFamily,
      AppColors.categoryLocation,
    ];

    final currentStepColor = _completedSteps > 0
        ? stepColors[(_completedSteps - 1).clamp(0, 2)]
        : primary;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 0.6.h),
      padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.slate800 : AppColors.slate200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 15, color: currentStepColor),
              SizedBox(width: 1.5.w),
              Text(
                i18n.stepProgressTitle,
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontWeight: AppTypography.extraBold,
                  color: theme.colorScheme.onSurface,
                  fontSize: AppTypography.labelMedium,
                ),
              ),
            ],
          ),
          Text(
            i18n.stepCompleted(_completedSteps),
            style: TextStyle(
              fontSize: AppTypography.labelSmall,
              fontWeight: AppTypography.black,
              color: currentStepColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationQuickChip({
    required String stateName,
    required String label,
    required bool isDark,
    required Color primary,
  }) {
    final isSelected = _selectedState == stateName;
    return TactilePressable(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedState = stateName;
          if (_selectedDistrict != null &&
              _selectedDistrict != 'ALL' &&
              !LocationData.getDistricts(stateName).contains(_selectedDistrict)) {
            _selectedDistrict = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark ? AppColors.slate900 : AppColors.slate100),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? primary : (isDark ? AppColors.slate700 : AppColors.slate300),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.labelSmall,
            fontWeight: isSelected ? AppTypography.extraBold : AppTypography.bold,
            color: isSelected ? primary : (isDark ? Colors.white70 : AppColors.slate700),
          ),
        ),
      ),
    );
  }

  Widget _auroraOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // UI COMPONENTS
  // ══════════════════════════════════════════════

  Widget _buildSectionCard({
    required ThemeData theme,
    required bool isDark,
    required String stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    final primary = theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.9.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.slate800 : context.colors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5.6.w,
                height: 5.6.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: AppColors.opacity85)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: AppColors.opacity25),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.black,
                      fontSize: AppTypography.labelSmall,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.2.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFontFamily,
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.bodyMedium,
                        color: isDark ? Colors.white : theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? AppColors.slate400 : theme.colorScheme.onSurfaceVariant,
                        fontSize: AppTypography.labelSmall,
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 0.8.h),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required ThemeData theme,
    required bool isDark,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool includeAllOption = false,
    String? allOptionLabel,
  }) {
    final primary = theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.2.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null
              ? primary
              : (isDark ? AppColors.slate700 : AppColors.slate300),
          width: value != null ? 1.4 : 1.0,
        ),
        boxShadow: value != null
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: AppColors.opacity15),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: value != null ? primary : (isDark ? AppColors.slate400 : theme.colorScheme.onSurfaceVariant),
          ),
          SizedBox(width: 1.8.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  hint,
                  style: TextStyle(
                    color: isDark ? AppColors.slate400 : theme.colorScheme.onSurfaceVariant,
                    fontSize: AppTypography.labelMedium,
                  ),
                ),
                isExpanded: true,
                dropdownColor: isDark ? AppColors.slate800 : Colors.white,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: value != null ? primary : (isDark ? AppColors.slate400 : theme.colorScheme.onSurfaceVariant),
                  size: 18,
                ),
                items: [
                  if (includeAllOption && allOptionLabel != null)
                    DropdownMenuItem<String>(
                      value: 'ALL',
                      child: Text(
                        '🌟 $allOptionLabel',
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontWeight: AppTypography.extraBold,
                          fontSize: AppTypography.bodySmall,
                          color: isDark ? AppColors.goldLemon : primary,
                        ),
                      ),
                    ),
                  ...items.map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          LocationData.getLocalizedName(item, context),
                          style: TextStyle(
                            fontFamily: AppTypography.headingFontFamily,
                            fontWeight: AppTypography.bold,
                            fontSize: AppTypography.bodySmall,
                            color: isDark ? Colors.white : theme.colorScheme.onSurface,
                          ),
                        ),
                      )),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
    Color primary,
    _IntakeL10n i18n,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.0.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _isFormValid ? _ctaPulseAnimation : const AlwaysStoppedAnimation(1.0),
          builder: (context, child) {
            return Transform.scale(
              scale: _isFormValid ? _ctaPulseAnimation.value : 1.0,
              child: child,
            );
          },
          child: TactilePressable(
            onTap: _isFormValid ? _onProceed : null,
            child: Container(
              width: double.infinity,
              height: 5.2.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: _isFormValid
                    ? const LinearGradient(
                        colors: [
                          AppColors.gold,
                          AppColors.goldLemon,
                          AppColors.gold,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          isDark ? AppColors.slate700 : AppColors.slate300,
                          isDark ? AppColors.slate800 : AppColors.slate400,
                        ],
                      ),
                boxShadow: _isFormValid
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: isDark ? 0.30 : 0.20),
                          blurRadius: 14,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    if (_isFormValid)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _glintController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _IntakeSheenGlintPainter(
                                percent: _glintController.value,
                              ),
                            );
                          },
                        ),
                      ),

                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                _isFormValid
                                    ? (l10n?.proceedToLogin ?? 'View Matches 👉')
                                    : i18n.ctaIncomplete,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTypography.headingFontFamily,
                                  fontWeight: AppTypography.black,
                                  color: _isFormValid ? AppColors.maroonDarkest : Colors.white70,
                                  fontSize: AppTypography.bodyMedium,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            if (_isFormValid) ...[
                              SizedBox(width: 2.w),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: AppColors.maroonDarkest,
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
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// HELPER WIDGETS & VISUAL FORMULA PAINTERS
// ══════════════════════════════════════════════

class _RelationKey {
  final String key;
  final IconData icon;
  final String emoji;

  const _RelationKey({
    required this.key,
    required this.icon,
    required this.emoji,
  });
}

class _TactileChip extends StatelessWidget {
  final String label;
  final String purposeHint;
  final String emoji;
  final IconData icon;
  final bool isSelected;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _TactileChip({
    required this.label,
    required this.purposeHint,
    required this.emoji,
    required this.icon,
    required this.isSelected,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TactilePressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.12)
              : (isDark ? AppColors.slate900 : AppColors.slate50),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected ? primaryColor : (isDark ? AppColors.slate800 : context.colors.border),
            width: isSelected ? 1.8 : 1.1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.22),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                if (isSelected) ...[
                  SizedBox(width: 1.w),
                  Icon(Icons.check_circle_rounded, size: 13, color: primaryColor),
                ],
              ],
            ),
            SizedBox(height: 0.25.h),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.headingFontFamily,
                fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                color: isSelected ? primaryColor : (isDark ? Colors.white : theme.colorScheme.onSurface),
                fontSize: 8.5.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final String purposeHint;
  final String emoji;
  final IconData icon;
  final String value;
  final bool isSelected;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.subtitle,
    required this.purposeHint,
    required this.emoji,
    required this.icon,
    required this.value,
    required this.isSelected,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TactilePressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: isDark ? 0.20 : 0.10)
              : (isDark ? AppColors.slate900 : AppColors.slate50),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accentColor : (isDark ? AppColors.slate800 : context.colors.border),
            width: isSelected ? 2.0 : 1.1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: isDark ? 0.28 : 0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(width: 1.2.w),
                  Icon(Icons.check_circle_rounded, size: 16, color: accentColor),
                ],
              ],
            ),
            SizedBox(height: 0.3.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.headingFontFamily,
                fontWeight: AppTypography.extraBold,
                color: isSelected ? accentColor : (isDark ? Colors.white : theme.colorScheme.onSurface),
                fontSize: AppTypography.bodySmall,
              ),
            ),
            SizedBox(height: 0.1.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? AppColors.slate400 : theme.colorScheme.onSurfaceVariant,
                fontSize: AppTypography.labelSmall,
                fontWeight: AppTypography.bold,
              ),
            ),
            SizedBox(height: 0.3.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: isDark ? 0.30 : 0.15)
                    : (isDark ? AppColors.slate800 : AppColors.slate200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                purposeHint,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? accentColor : (isDark ? AppColors.slate400 : theme.colorScheme.onSurfaceVariant),
                  fontSize: 7.5.sp,
                  fontWeight: AppTypography.extraBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🌟 Visual Formula Explanation Card (The Magic Mirror with Live Teaser)
class _VisualExplanationFormulaCard extends StatelessWidget {
  final String? selectedGender;
  final String? selectedRelation;
  final String? selectedState;
  final String? selectedDistrict;
  final bool isDark;
  final Color primary;
  final _IntakeL10n i18n;
  final AppLocalizations? l10n;

  const _VisualExplanationFormulaCard({
    required this.selectedGender,
    required this.selectedRelation,
    required this.selectedState,
    required this.selectedDistrict,
    required this.isDark,
    required this.primary,
    required this.i18n,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final relationEmoji = switch (selectedRelation) {
      'son' => '👦',
      'daughter' => '👧',
      'sibling' => '👫',
      'relative' => '👨‍👩‍👧',
      'self' => '👤',
      _ => '✨',
    };

    final rawRelation = switch (selectedRelation) {
      'son' => l10n?.forMySon ?? 'For Son',
      'daughter' => l10n?.forMyDaughter ?? 'For Daughter',
      'sibling' => l10n?.forMySibling ?? 'For Sibling',
      'relative' => l10n?.forMyRelative ?? 'For Relative',
      'self' => l10n?.forMyself ?? 'For Myself',
      _ => l10n?.forOther ?? 'Other',
    };
    final relationText = rawRelation.replaceAll(RegExp(r'^[^\w\u0900-\u0DFF]+'), '').trim();

    final targetEmoji = selectedGender == 'Female' ? '👧' : '👦';
    final targetText = i18n.targetProfileName(selectedGender ?? 'Female');
    final targetColor = selectedGender == 'Female' ? AppColors.crimsonBlush : AppColors.sapphireBlue;

    final locText = (selectedDistrict != null && selectedDistrict != 'ALL')
        ? '${LocationData.getLocalizedName(selectedDistrict!, context)}, ${LocationData.getLocalizedName(selectedState ?? '', context)}'
        : (selectedState != null ? LocationData.getLocalizedName(selectedState!, context) : i18n.allLocationsText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 🔥 Live Match Counter Teaser Pill
        Container(
          margin: EdgeInsets.only(bottom: 0.6.h),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withValues(alpha: isDark ? 0.30 : 0.14),
                AppColors.gold.withValues(alpha: isDark ? 0.22 : 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: isDark ? 0.50 : 0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.whatshot_rounded,
                size: 15,
                color: AppColors.goldLemon,
              ),
              SizedBox(width: 1.5.w),
              Flexible(
                child: Text(
                  i18n.liveMatchCountPreview(selectedGender, locText),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: 8.8.sp,
                    fontWeight: AppTypography.extraBold,
                    color: isDark ? AppColors.goldLemon : primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 🌟 Magic Mirror Equation Card
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.9.h),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: isDark ? 0.20 : 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primary.withValues(alpha: 0.35),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 1.8.w),
                      Text(
                        i18n.yourSelectionHeader,
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontWeight: AppTypography.extraBold,
                          fontSize: AppTypography.labelMedium,
                          color: isDark ? AppColors.goldLemon : primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
                    decoration: BoxDecoration(
                      color: AppColors.categoryLocation.withValues(alpha: isDark ? 0.25 : 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.categoryLocation.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '🔒 ${i18n.noProfileTitle}',
                      style: TextStyle(
                        fontSize: 7.5.sp,
                        fontWeight: AppTypography.extraBold,
                        color: isDark ? Colors.white : AppColors.categoryLocation,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.6.h),

              // Visual Equation Flow: [Left Card] ➔ [Arrow] ➔ [Right Card]
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.slate900 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.20),
                  ),
                ),
                child: Row(
                  children: [
                    // Left: Who are you searching for
                    Expanded(
                      child: Column(
                        children: [
                          Text(relationEmoji, style: const TextStyle(fontSize: 18)),
                          SizedBox(height: 0.2.h),
                          Text(
                            relationText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              fontWeight: AppTypography.extraBold,
                              color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center: Arrow
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: primary,
                      ),
                    ),

                    // Right: What profiles will be shown
                    Expanded(
                      child: Column(
                        children: [
                          Text(targetEmoji, style: const TextStyle(fontSize: 18)),
                          SizedBox(height: 0.2.h),
                          Text(
                            targetText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              fontWeight: AppTypography.extraBold,
                              color: targetColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 0.5.h),
              Center(
                child: Text(
                  '📍 ${i18n.locationPrefix}: $locText',
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: AppTypography.bold,
                    color: isDark ? AppColors.slate400 : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 🌟 Model for Ambient Constellation Particles
class _IntakeFloatingParticle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final bool isGold;

  _IntakeFloatingParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.isGold,
  });
}

/// 🌟 Custom Painter for Floating Ambient Constellation Particles
class _IntakeConstellationParticlePainter extends CustomPainter {
  final double progress;
  final List<_IntakeFloatingParticle> particles;
  final bool isDark;
  final Color primaryColor;

  _IntakeConstellationParticlePainter({
    required this.progress,
    required this.particles,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final currentY = ((p.y - (progress * p.speed)) % 1.0) * size.height;
      final currentX = ((p.x + math.sin(progress * 2 * math.pi + i) * 0.04) % 1.0) * size.width;

      final color = p.isGold
          ? AppColors.categoryAstro.withValues(alpha: isDark ? 0.35 : 0.22)
          : primaryColor.withValues(alpha: isDark ? 0.30 : 0.18);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(currentX, currentY), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _IntakeConstellationParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 🌟 Shimmering Diagonal Light-Sweep Glint Painter for CTA
class _IntakeSheenGlintPainter extends CustomPainter {
  final double percent;

  _IntakeSheenGlintPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final double glintWidth = size.width * 0.45;
    final double totalDistance = size.width + glintWidth * 2;
    final double currentX = -glintWidth + (totalDistance * percent);

    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.30),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(currentX, 0, glintWidth, size.height));

    final Path path = Path()
      ..moveTo(currentX, 0)
      ..lineTo(currentX + glintWidth, 0)
      ..lineTo(currentX + glintWidth - (size.height * math.tan(0.35)), size.height)
      ..lineTo(currentX - (size.height * math.tan(0.35)), size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IntakeSheenGlintPainter oldDelegate) =>
      oldDelegate.percent != percent;
}

/// 🌐 Localization Helper for RelativeIntakeScreen
/// Provides complete native support for en, mr, hi, te, kn.
class _IntakeL10n {
  final String lang;

  _IntakeL10n(this.lang);

  factory _IntakeL10n.of(BuildContext context) {
    return _IntakeL10n(Localizations.localeOf(context).languageCode);
  }

  String appBarTitle(AppLocalizations? l10n) {
    if (l10n?.browseMatchesTitle != null) {
      return l10n!.browseMatchesTitle
          .replaceAll(RegExp(r'^[^\w\u0900-\u0DFF]+'), '')
          .replaceAll(RegExp(r'\(.*?\)'), '')
          .trim();
    }
    return switch (lang) {
      'mr' => 'स्थळ शोधा',
      'hi' => 'रिश्ता खोजें',
      'te' => 'సంబంధం వెతకండి',
      'kn' => 'ಸಂಬಂಧ ಹುಡುಕಿ',
      _ => 'Browse Matches',
    };
  }

  String get stepProgressTitle => switch (lang) {
        'mr' => '३ सोप्या पायऱ्या',
        'hi' => '३ आसान चरण',
        'te' => '3 సులభమైన దశలు',
        'kn' => '3 ಸರಳ ಹಂತಗಳು',
        _ => '3 Quick Steps',
      };

  String stepCompleted(int count) => switch (lang) {
        'mr' => '$count / ३ पूर्ण',
        'hi' => '$count / ३ पूर्ण',
        'te' => '$count / 3 పూర్తి',
        'kn' => '$count / 3 ಪೂರ್ಣ',
        _ => '$count / 3 Done',
      };

  String get noProfileTitle => switch (lang) {
        'mr' => 'बायोडेटा गरज नाही',
        'hi' => 'बायोडाटा की जरूरत नहीं',
        'te' => 'ప్రొఫైల్ అవసరం లేదు',
        'kn' => 'ಪ್ರೊಫೈಲ್ ಅಗತ್ಯವಿಲ್ಲ',
        _ => 'No Profile Required',
      };

  // Questions
  String targetGenderTitle(AppLocalizations? l10n) =>
      l10n?.targetBiodataQuestion ??
      switch (lang) {
        'mr' => 'कोणाचे स्थळ शोधत आहात?',
        'hi' => 'किसके लिए रिश्ता देख रहे हैं?',
        'te' => 'ఎవరి కోసం సంబంధాలు చూస్తున్నారు?',
        'kn' => 'ಯಾರಿಗಾಗಿ ಸಂಬಂಧಗಳನ್ನು ನೋಡುತ್ತಿದ್ದೀರಿ?',
        _ => 'Which biodata are you looking for?',
      };

  String targetGenderSubtitle(AppLocalizations? l10n) =>
      l10n?.targetGenderSubtitle ??
      switch (lang) {
        'mr' => 'लिंग निवडा (वधू / वर)',
        'hi' => 'लिंग चुनें (वधू / वर)',
        'te' => 'ఎంచుకోండి (వధువు / వరుడు)',
        'kn' => 'ಆಯ್ಕೆಮಾಡಿ (ವಧು / ವರ)',
        _ => 'Select Gender (Bride / Groom)',
      };

  String brideLabel(AppLocalizations? l10n) {
    if (l10n?.brideOption != null) {
      return l10n!.brideOption.replaceAll(RegExp(r'^[^\w\u0900-\u0DFF]+'), '').trim();
    }
    return switch (lang) {
      'mr' => 'वधू (मुलगी)',
      'hi' => 'वधू (लड़की)',
      'te' => 'వధువు (అమ్మాయి)',
      'kn' => 'ವಧು (ಹುಡುಗಿ)',
      _ => 'Bride (Girl)',
    };
  }

  String get brideSubtitle => switch (lang) {
        'mr' => 'वधू शोधत आहे',
        'hi' => 'वधू देख रहे हैं',
        'te' => 'వధువు కోసం',
        'kn' => 'ವಧುಗಾಗಿ',
        _ => 'Searching for Bride',
      };

  String get brideHint => switch (lang) {
        'mr' => 'मुलींचे बायोडेटा दिसतील',
        'hi' => 'लड़कियों के बायोडाटा दिखेंगे',
        'te' => 'వధువుల ప్రొఫైల్స్ కనిపిస్తాయి',
        'kn' => 'ವಧುಗಳ ಪ್ರೊಫೈಲ್‌ಗಳು ಕಾಣಿಸುತ್ತವೆ',
        _ => 'Shows Bride Profiles',
      };

  String groomLabel(AppLocalizations? l10n) {
    if (l10n?.groomOption != null) {
      return l10n!.groomOption.replaceAll(RegExp(r'^[^\w\u0900-\u0DFF]+'), '').trim();
    }
    return switch (lang) {
      'mr' => 'वर (मुलगा)',
      'hi' => 'वर (लड़का)',
      'te' => 'వరుడు (అబ్బాయి)',
      'kn' => 'ವರ (ಹುಡುಗ)',
      _ => 'Groom (Boy)',
    };
  }

  String get groomSubtitle => switch (lang) {
        'mr' => 'वर शोधत आहे',
        'hi' => 'वर देख रहे हैं',
        'te' => 'వరుడి కోసం',
        'kn' => 'ವರನಿಗಾಗಿ',
        _ => 'Searching for Groom',
      };

  String get groomHint => switch (lang) {
        'mr' => 'मुलांचे बायोडेटा दिसतील',
        'hi' => 'लड़कों के बायोडाटा दिखेंगे',
        'te' => 'వరుల ప్రొఫైల్స్ కనిపిస్తాయి',
        'kn' => 'ವರಗಳ ಪ್ರೊಫೈಲ್‌ಗಳು ಕಾಣಿಸುತ್ತವೆ',
        _ => 'Shows Groom Profiles',
      };

  String relationTitle(AppLocalizations? l10n) =>
      l10n?.whoIsThisForQuestion ??
      switch (lang) {
        'mr' => 'हे स्थळ कोणासाठी हवे आहे?',
        'hi' => 'यह रिश्ता किसके लिए चाहिए?',
        'te' => 'ఈ సంబంధం ఎవరి కోసం కావాలి?',
        'kn' => 'ಈ ಸಂಬಂಧ ಯಾರಿಗಾಗಿ ಬೇಕು?',
        _ => 'Who are you searching for?',
      };

  String relationSubtitle(AppLocalizations? l10n) =>
      l10n?.relationSubtitle ??
      switch (lang) {
        'mr' => 'नाते निवडा (Select Relationship)',
        'hi' => 'रिश्ता चुनें (Select Relationship)',
        'te' => 'సంబంధాన్ని ఎంచుకోండి',
        'kn' => 'ಸಂಬಂಧವನ್ನು ಆಯ್ಕೆಮಾಡಿ',
        _ => 'Select Relationship',
      };

  String relationHint(String key) => switch (key) {
        'son' => switch (lang) {
            'mr' => 'मुलाचे पालक',
            'hi' => 'लड़के के माता-पिता',
            'te' => 'అబ్బాయి తల్లిదండ్రులు',
            'kn' => 'ಹುಡುಗನ ಪೋಷಕರು',
            _ => 'Parent of Boy',
          },
        'daughter' => switch (lang) {
            'mr' => 'मुलीचे पालक',
            'hi' => 'लड़की के माता-पिता',
            'te' => 'అమ్మాయి తల్లిదండ్రులు',
            'kn' => 'ಹುಡುಗಿಯ ಪೋಷಕರು',
            _ => 'Parent of Girl',
          },
        'sibling' => switch (lang) {
            'mr' => 'भाऊ किंवा बहीण',
            'hi' => 'भाई या बहन',
            'te' => 'సోదరుడు లేదా సోదరి',
            'kn' => 'ಸಹೋದರ ಅಥವಾ ಸಹೋದರಿ',
            _ => 'Brother / Sister',
          },
        'relative' => switch (lang) {
            'mr' => 'काका, मामा किंवा नातेवाईक',
            'hi' => 'रिश्तेदार',
            'te' => 'బంధువులు',
            'kn' => 'ಸಂಬಂಧಿಕರು',
            _ => 'Relative / Family',
          },
        'self' => switch (lang) {
            'mr' => 'मी स्वतः उमेदवार आहे',
            'hi' => 'मैं स्वयं उम्मीदवार हूँ',
            'te' => 'నేను అభ్యర్థిని',
            'kn' => 'ನಾನು ಅಭ್ಯರ್ಥಿ',
            _ => 'I am the Candidate',
          },
        _ => switch (lang) {
            'mr' => 'मित्र किंवा इतर',
            'hi' => 'मित्र या अन्य',
            'te' => 'స్నేహితుడు లేదా ఇతర',
            'kn' => 'ಸ್ನೇಹಿತ ಅಥವಾ ಇತರ',
            _ => 'Friend / Other',
          },
      };

  String locationTitle(AppLocalizations? l10n) =>
      l10n?.selectLocation ??
      switch (lang) {
        'mr' => 'कोणत्या ठिकाणचे स्थळ हवे आहे?',
        'hi' => 'किस स्थान का रिश्ता चाहिए?',
        'te' => 'ఏ ప్రాంతం సంబంధాలు కావాలి?',
        'kn' => 'ಯಾವ ಸ್ಥಳದ ಸಂಬಂಧಗಳು ಬೇಕು?',
        _ => 'Select Preferred Location',
      };

  String get locationSubtitle => switch (lang) {
        'mr' => 'पसंतीचे राज्य व जिल्हा निवडा',
        'hi' => 'पसंदीदा राज्य और जिला चुनें',
        'te' => 'ప్రాధాన్య రాష్ట్రం మరియు జిల్లా',
        'kn' => 'ಆದ್ಯತೆಯ ರಾಜ್ಯ ಮತ್ತು ಜಿಲ್ಲೆ',
        _ => 'Select Preferred State & District',
      };

  String get allDistrictsOption => switch (lang) {
        'mr' => 'सर्व जिल्हे (संपूर्ण राज्य)',
        'hi' => 'सभी जिले (संपूर्ण राज्य)',
        'te' => 'అన్ని జిల్లాలు (మొత్తం రాష్ట్రం)',
        'kn' => 'ಎಲ್ಲಾ ಜಿಲ್ಲೆಗಳು (ಸಂಪೂರ್ಣ ರಾಜ್ಯ)',
        _ => 'All Districts (Entire State)',
      };

  String get yourSelectionHeader => switch (lang) {
        'mr' => 'तुमची निवड:',
        'hi' => 'आपकी पसंद:',
        'te' => 'మీ ఎంపిక:',
        'kn' => 'ನಿಮ್ಮ ಆಯ್ಕೆ:',
        _ => 'Your Selection:',
      };

  String get locationPrefix => switch (lang) {
        'mr' => 'ठिकाण',
        'hi' => 'स्थान',
        'te' => 'ప్రాంతం',
        'kn' => 'ಸ್ಥಳ',
        _ => 'Location',
      };

  String get allLocationsText => switch (lang) {
        'mr' => 'सर्व ठिकाण',
        'hi' => 'सभी स्थान',
        'te' => 'అన్ని ప్రాంతాలు',
        'kn' => 'ಎಲ್ಲಾ ಸ್ಥಳಗಳು',
        _ => 'All Locations',
      };

  String targetProfileName(String gender) => gender == 'Female'
      ? switch (lang) {
          'mr' => 'वधू / मुलींची स्थळे',
          'hi' => 'वधू / लड़की के बायोडाटा',
          'te' => 'వధువుల ప్రొఫైల్స్',
          'kn' => 'ವಧುಗಳ ಪ್ರೊಫೈಲ್‌ಗಳು',
          _ => 'Bride Profiles',
        }
      : switch (lang) {
          'mr' => 'वर / मुलांची स्थळे',
          'hi' => 'वर / लड़के के बायोडाटा',
          'te' => 'వరుల ప్రొఫైల్స్',
          'kn' => 'ವರಗಳ ಪ್ರೊಫೈಲ್‌ಗಳು',
          _ => 'Groom Profiles',
        };

  String liveMatchCountPreview(String? gender, String location) {
    final count = '1,420+';
    if (gender == 'Female') {
      return switch (lang) {
        'mr' => '✨ $count पडताळणी झालेले वधूंचे बायोडेटा उपलब्ध',
        'hi' => '✨ $count सत्यापित वधू उपलब्ध',
        'te' => '✨ $count ధృవీకరించబడిన వధువుల సంబంధాలు అందుబాటులో ఉన్నాయి',
        'kn' => '✨ $count ಪರಿಶೀಲಿಸಿದ ವಧುಗಳ ಪ್ರೊಫೈಲ್‌ಗಳು ಲಭ್ಯವಿದೆ',
        _ => '✨ $count Verified Bride Profiles Ready in $location',
      };
    } else {
      return switch (lang) {
        'mr' => '✨ $count पडताळणी झालेले वरांचे बायोडेटा उपलब्ध',
        'hi' => '✨ $count सत्यापित वर उपलब्ध',
        'te' => '✨ $count ధృవీకరించబడిన వరుల సంబంధాలు అందుబాటులో ఉన్నాయి',
        'kn' => '✨ $count ಪರಿಶೀಲಿಸಿದ ವರಗಳ ಪ್ರೊಫೈಲ್‌ಗಳು ಲಭ್ಯವಿದೆ',
        _ => '✨ $count Verified Groom Profiles Ready in $location',
      };
    }
  }

  String get ctaIncomplete => switch (lang) {
        'mr' => '३ पायऱ्या पूर्ण करा',
        'hi' => '३ चरण पूर्ण करें',
        'te' => '3 దశలు పూర్తి చేయండి',
        'kn' => '3 ಹಂತಗಳನ್ನು ಪೂರ್ಣಗೊಳಿಸಿ',
        _ => 'Complete 3 Steps',
      };
}
