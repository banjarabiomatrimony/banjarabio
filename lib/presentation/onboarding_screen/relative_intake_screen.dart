import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/data/location_data.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/routes/app_routes.dart';

/// World-Class Single-Page Preference Intake for Pathway A: Relative / Visitor Match Browse.
///
/// Collects 3 key answers BEFORE login:
/// 1. Relation (Son / Daughter / Sibling / Relative / Self / Other)
/// 2. Target gender (Groom / Bride)
/// 3. State + District
///
/// Navigates to [AuthenticationScreen] upon completion.
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

class _RelativeIntakeScreenState extends State<RelativeIntakeScreen> {
  // Q1: Relation
  String? _selectedRelation;

  // Q2: Target Gender
  String? _selectedGender;

  // Q3: Location
  String? _selectedState;
  String? _selectedDistrict;

  static const List<_RelationOption> _relations = [
    _RelationOption(key: 'son', icon: Icons.boy_rounded, emoji: '👦'),
    _RelationOption(key: 'daughter', icon: Icons.girl_rounded, emoji: '👧'),
    _RelationOption(key: 'sibling', icon: Icons.people_alt_rounded, emoji: '👫'),
    _RelationOption(key: 'relative', icon: Icons.family_restroom_rounded, emoji: '👨‍👩‍👧'),
    _RelationOption(key: 'self', icon: Icons.person_rounded, emoji: '👤'),
    _RelationOption(key: 'other', icon: Icons.more_horiz_rounded, emoji: '✨'),
  ];

  int get _completedSteps {
    int count = 0;
    if (_selectedRelation != null) count++;
    if (_selectedGender != null) count++;
    if (_selectedState != null) count++;
    return count;
  }

  bool get _isFormValid =>
      _selectedRelation != null &&
      _selectedGender != null &&
      _selectedState != null;

  Future<void> _onBack() async {
    if (widget.embedded) return; // Stepper handles back navigation
    await LocalCacheService().clearRelativeBrowseSession();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true)
        .pushReplacementNamed(AppRoutes.onboardingSelection);
  }

  Future<void> _onProceed() async {
    if (!_isFormValid) return;

    // Save intent to Hive (persists across auth redirect)
    await LocalCacheService().saveRelativeIntent(
      relation: _selectedRelation!,
      targetGender: _selectedGender!,
      state: _selectedState,
      district: _selectedDistrict,
    );

    if (!mounted) return;

    if (widget.embedded && widget.onProceed != null) {
      widget.onProceed!();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.authentication);
    }
  }

  void _onGenderSelected(String gender) {
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

  String _getClearExplanationText(
    String relation,
    String gender,
    String? state,
    String? district,
    BuildContext context,
  ) {
    final distName = district != null ? LocationData.getLocalizedName(district, context) : null;
    final stateName = state != null ? LocationData.getLocalizedName(state, context) : null;

    final String locPhrase;
    if (distName != null && stateName != null) {
      locPhrase = 'आम्ही (स्थान: $distName, $stateName) येथील';
    } else if (stateName != null) {
      locPhrase = 'आम्ही (स्थान: $stateName) येथील';
    } else {
      locPhrase = 'आम्ही';
    }

    if (relation == 'son') {
      if (gender == 'Female') {
        return 'तुमच्या मुलासाठी (Son) $locPhrase मुलींची (Girl/Bride) स्थळे दाखवणार.';
      } else {
        return '(टीप: तुम्ही मुलासाठी मुलगा निवडला आहे).';
      }
    } else if (relation == 'daughter') {
      if (gender == 'Male') {
        return 'तुमच्या मुलीसाठी (Daughter) $locPhrase मुलांची (Boy/Groom) स्थळे दाखवणार.';
      } else {
        return '(टीप: तुम्ही मुलीसाठी मुलगी निवडली आहे).';
      }
    } else {
      if (gender == 'Female') {
        return 'तुमच्यासाठी $locPhrase मुलींची / वधूंची (Girl/Bride) स्थळे दाखवणार.';
      } else {
        return 'तुमच्यासाठी $locPhrase मुलांची / वरांची (Boy/Groom) स्थळे दाखवणार.';
      }
    }
  }

  String _getRelationLabel(String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'son':
        return l10n?.forMySon ?? '👦 For My Son';
      case 'daughter':
        return l10n?.forMyDaughter ?? '👧 For My Daughter';
      case 'sibling':
        return l10n?.forMySibling ?? '👫 For My Sibling';
      case 'relative':
        return l10n?.forMyRelative ?? '👨‍👩‍👧 For My Relative';
      case 'self':
        return l10n?.forMyself ?? '👤 For Myself';
      case 'other':
        return l10n?.forOther ?? '✨ For Someone Else';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    // Core content: the Column with topBar, content, bottomCTA
    final coreContent = Column(
      children: [
        // Top Custom Navigation Bar with Progress Indicator
        if (!widget.embedded) _buildTopBar(theme, isDark, primary),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 3.5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 1.2.h),

                // Header Hero Section
                _buildHeroHeader(theme, isDark, l10n, primary),

                SizedBox(height: 1.2.h),

                // ── Q1: Target Gender (First Question) ──
                _buildSectionCard(
                  theme: theme,
                  isDark: isDark,
                  stepNumber: '1',
                  title: l10n?.targetBiodataQuestion ?? 'Which biodata are you looking for?',
                  subtitle: l10n?.targetGenderSubtitle ?? 'Select Gender (Bride / Groom)',
                  icon: Icons.wc_rounded,
                  child: Row(
                    children: [
                      Expanded(
                        child: _GenderCard(
                          label: l10n?.brideOption ?? '👧 Bride (Girl)',
                          subtitle: l10n?.bride ?? 'Bride',
                          emoji: '👧',
                          icon: Icons.girl_rounded,
                          value: 'Female',
                          isSelected: _selectedGender == 'Female',
                          accentColor: const Color(0xFFE11D48),
                          isDark: isDark,
                          onTap: () => _onGenderSelected('Female'),
                        ),
                      ),
                      SizedBox(width: 2.5.w),
                      Expanded(
                        child: _GenderCard(
                          label: l10n?.groomOption ?? '👦 Groom (Boy)',
                          subtitle: l10n?.groom ?? 'Groom',
                          emoji: '👦',
                          icon: Icons.boy_rounded,
                          value: 'Male',
                          isSelected: _selectedGender == 'Male',
                          accentColor: const Color(0xFF2563EB),
                          isDark: isDark,
                          onTap: () => _onGenderSelected('Male'),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 0.8.h),

                // ── Q2: Relation (Second Question) ──
                _buildSectionCard(
                  theme: theme,
                  isDark: isDark,
                  stepNumber: '2',
                  title: l10n?.whoIsThisForQuestion ?? 'Who are you searching for?',
                  subtitle: l10n?.relationSubtitle ?? 'Select Relationship',
                  icon: Icons.family_restroom_rounded,
                  child: Wrap(
                    spacing: 2.w,
                    runSpacing: 0.8.h,
                    children: _relations.map((r) {
                      final isSelected = _selectedRelation == r.key;
                      return _TactileChip(
                        label: _getRelationLabel(r.key),
                        emoji: r.emoji,
                        icon: r.icon,
                        isSelected: isSelected,
                        primaryColor: primary,
                        isDark: isDark,
                        onTap: () => _onRelationSelected(r.key),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 0.8.h),

                // ── Q3: Location ──
                _buildSectionCard(
                  theme: theme,
                  isDark: isDark,
                  stepNumber: '3',
                  title: l10n?.selectLocation ?? 'राज्य व जिल्हा निवडा',
                  subtitle: 'पसंतीचे ठिकाण (Select Preferred Location)',
                  icon: Icons.location_on_rounded,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          theme: theme,
                          isDark: isDark,
                          hint: l10n?.selectState ?? 'राज्य निवडा',
                          icon: Icons.map_rounded,
                          value: _selectedState,
                          items: LocationData.states,
                          onChanged: (val) {
                            setState(() {
                              _selectedState = val;
                              _selectedDistrict = null;
                            });
                          },
                        ),
                      ),
                      if (_selectedState != null) ...[
                        SizedBox(width: 2.w),
                        Expanded(
                          child: _buildDropdownField(
                            theme: theme,
                            isDark: isDark,
                            hint: l10n?.selectDistrict ?? 'जिल्हा निवडा',
                            icon: Icons.location_city_rounded,
                            value: _selectedDistrict,
                            items: LocationData.getDistricts(_selectedState!),
                            onChanged: (val) => setState(() => _selectedDistrict = val),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Selection Explanation Summary Card ──
                if (_selectedRelation != null &&
                    _selectedGender != null &&
                    _selectedState != null) ...[
                  SizedBox(height: 1.2.h),
                  _AnimatedExplanationSummaryCard(
                    text: _getClearExplanationText(
                      _selectedRelation!,
                      _selectedGender!,
                      _selectedState,
                      _selectedDistrict,
                      context,
                    ),
                    isDark: isDark,
                    primary: primary,
                  ),
                ],
                SizedBox(height: 1.2.h),
              ],
            ),
          ),
        ),

        // Bottom Sticky Floating Action Bar
        _buildBottomCTA(theme, isDark, l10n, primary),
      ],
    );

    // Embedded mode: skip Scaffold/PopScope/ambient wrappers
    if (widget.embedded) return coreContent;

    // Standalone mode: full screen with ambient glows
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBack();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
        children: [
          // Ambient Background Glows
          Positioned(
            top: -10.h,
            right: -15.w,
            child: Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: isDark ? 0.15 : 0.08),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 5.h,
            left: -10.w,
            child: Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? const Color(0xFFD4AF37) : secondary)
                        .withValues(alpha: isDark ? 0.12 : 0.06),
                    blurRadius: 70,
                    spreadRadius: 15,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(child: coreContent),
        ],
      ),
    ),
    );
  }

  // ══════════════════════════════════════════════
  // UI COMPONENTS
  // ══════════════════════════════════════════════

  Widget _buildTopBar(ThemeData theme, bool isDark, Color primary) {
    // 3 distinct step colors for vibrant UX progression
    const stepColors = [
      Color(0xFF3B82F6), // Step 1: Electric Blue
      Color(0xFF8B5CF6), // Step 2: Royal Purple
      Color(0xFF10B981), // Step 3: Emerald Green
    ];

    // Current accent color based on highest step reached
    final currentStepColor = _completedSteps > 0
        ? stepColors[(_completedSteps - 1).clamp(0, 2)]
        : primary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.6.h),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: _onBack,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(width: 3.w),

          // 3-Step Segmented Animated Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          child: Icon(
                            _completedSteps == 3
                                ? Icons.verified_rounded
                                : Icons.trending_up_rounded,
                            size: 17,
                            color: currentStepColor,
                          ),
                        ),
                        SizedBox(width: 1.5.w),
                        Text(
                          'प्रगती (Progress)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: AppTypography.extraBold,
                            color: theme.colorScheme.onSurface,
                            fontSize: AppTypography.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                    // Step Pill Counter
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.3.h),
                      decoration: BoxDecoration(
                        color: currentStepColor.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: currentStepColor.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                        boxShadow: [
                          if (_completedSteps > 0)
                            BoxShadow(
                              color: currentStepColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                            ),
                        ],
                      ),
                      child: Text(
                        '$_completedSteps / 3 पूर्ण',
                        style: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          fontWeight: AppTypography.black,
                          color: currentStepColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.8.h),

                // 3 Segmented Bars Row
                Row(
                  children: List.generate(3, (index) {
                    final stepNumber = index + 1;
                    final isDone = stepNumber <= _completedSteps;
                    final isCurrent = stepNumber == _completedSteps + 1;
                    final color = stepColors[index];

                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index < 2 ? 1.8.w : 0),
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              height: 9.0,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? color
                                    : (isCurrent
                                        ? color.withValues(alpha: isDark ? 0.35 : 0.25)
                                        : (isDark
                                            ? const Color(0xFF334155).withValues(alpha: 0.6)
                                            : const Color(0xFFE2E8F0))),
                                borderRadius: BorderRadius.circular(10),
                                border: isCurrent
                                    ? Border.all(color: color.withValues(alpha: 0.7), width: 1.2)
                                    : null,
                                boxShadow: isDone
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.45),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    return Column(
      children: [
        // Title (Line 1)
        Text(
          l10n?.browseMatchesTitle ?? 'स्थळ शोधा',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: AppTypography.black,
            fontSize: AppTypography.headingLarge,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 0.5.h),

        // Subtitle (Line 2)
        Text(
          l10n?.browseMatchesSubtitle ?? 'काही प्रश्नांची उत्तरे द्या आणि योग्य स्थळे पहा',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: AppTypography.bodyLarge,
            fontWeight: AppTypography.bold,
            height: 1.3,
          ),
        ),
        SizedBox(height: 1.0.h),

        // Trust Pill (Line 3)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primary.withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '⚡ 1-Min Quick Filter',
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  fontWeight: AppTypography.extraBold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 2.w),
              Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: primary)),
              SizedBox(width: 2.w),
              Text(
                '🔒 No Login Required',
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  fontWeight: AppTypography.extraBold,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.0.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.85) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Step Badge
              Container(
                width: 6.5.w,
                height: 6.5.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.85)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: AppTypography.black,
                      fontSize: AppTypography.bodySmall,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.5.w),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.bodyLarge,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: AppTypography.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 0.8.h),

          // Content
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
  }) {
    final primary = theme.colorScheme.primary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.2.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value != null
              ? primary
              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          width: value != null ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: value != null ? primary : theme.colorScheme.onSurfaceVariant),
          SizedBox(width: 2.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  hint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: AppTypography.bodyMedium,
                  ),
                ),
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: primary, size: 20),
                items: items
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            LocationData.getLocalizedName(item, context),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: AppTypography.semiBold,
                              fontSize: AppTypography.bodyMedium,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.0.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedOpacity(
            opacity: _isFormValid ? 1.0 : 0.65,
            duration: const Duration(milliseconds: 250),
            child: SizedBox(
              width: double.infinity,
              height: 5.2.h,
              child: ElevatedButton(
                onPressed: _isFormValid ? _onProceed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primary.withValues(alpha: 0.4),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: _isFormValid ? 4 : 0,
                  shadowColor: primary.withValues(alpha: 0.45),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n?.proceedToLogin ?? 'पुढे जा → स्थळे पहा',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppTypography.black,
                        color: Colors.white,
                        fontSize: AppTypography.bodyLarge,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// HELPER WIDGETS
// ══════════════════════════════════════════════

class _RelationOption {
  final String key;
  final IconData icon;
  final String emoji;

  const _RelationOption({
    required this.key,
    required this.icon,
    required this.emoji,
  });
}

class _TactileChip extends StatelessWidget {
  final String label;
  final String emoji;
  final IconData icon;
  final bool isSelected;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _TactileChip({
    required this.label,
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.12)
                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: AppTypography.bodyMedium)),
              SizedBox(width: 1.5.w),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                  color: isSelected ? primaryColor : theme.colorScheme.onSurface,
                  fontSize: AppTypography.bodySmall,
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: 1.2.w),
                Icon(Icons.check_circle_rounded, size: 14, color: primaryColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final String subtitle;
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.0.h),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: isDark ? 0.20 : 0.10)
                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? accentColor
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: TextStyle(fontSize: AppTypography.headingMedium)),
                  SizedBox(width: 1.5.w),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, size: 16, color: accentColor),
                ],
              ),
              SizedBox(height: 0.4.h),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.black,
                  color: isSelected ? accentColor : theme.colorScheme.onSurface,
                  fontSize: AppTypography.bodyMedium,
                ),
              ),
              SizedBox(height: 0.2.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: AppTypography.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated Explanation Summary Card with smooth entrance scaling, border glow,
/// and pulsing lightbulb icon for an engaging pre-login review experience.
class _AnimatedExplanationSummaryCard extends StatefulWidget {
  final String text;
  final bool isDark;
  final Color primary;

  const _AnimatedExplanationSummaryCard({
    required this.text,
    required this.isDark,
    required this.primary,
  });

  @override
  State<_AnimatedExplanationSummaryCard> createState() =>
      __AnimatedExplanationSummaryCardState();
}

class __AnimatedExplanationSummaryCardState
    extends State<_AnimatedExplanationSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.15, end: 0.38).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      tween: Tween<double>(begin: 0.82, end: 1.0),
      builder: (context, scaleVal, child) {
        return Transform.scale(
          scale: scaleVal,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                decoration: BoxDecoration(
                  color: widget.primary.withValues(
                    alpha: widget.isDark ? 0.25 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.primary.withValues(
                      alpha: 0.40 + (_glowAnimation.value * 0.5),
                    ),
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primary.withValues(
                        alpha: _glowAnimation.value,
                      ),
                      blurRadius: 14 + (_glowAnimation.value * 10),
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _iconScaleAnimation,
                      child: Text(
                        '💡',
                        style: TextStyle(fontSize: AppTypography.headingLarge),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        widget.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: AppTypography.black,
                              fontSize: AppTypography.headingSmall,
                              color: widget.isDark
                                  ? const Color(0xFFFDE047)
                                  : widget.primary,
                              height: 1.35,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
