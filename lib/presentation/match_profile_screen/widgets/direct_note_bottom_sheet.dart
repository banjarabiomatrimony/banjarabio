import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/repositories/usage_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 💌 Direct Note Bottom Sheet
/// Ultra-Luxury Matrimonial Royal Letter & Direct Intro Experience.
/// Educates the sender on how direct intro delivery works, provides categorized
/// icebreakers, interactive live envelope preview, and 1-tap priority dispatch.
class DirectNoteBottomSheet extends StatefulWidget {
  final Map<String, dynamic> profile;
  final VoidCallback? onSuccess;

  const DirectNoteBottomSheet({
    super.key,
    required this.profile,
    this.onSuccess,
  });

  static Future<void> show({
    required BuildContext context,
    required Map<String, dynamic> profile,
    VoidCallback? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) =>
          DirectNoteBottomSheet(profile: profile, onSuccess: onSuccess),
    );
  }

  @override
  State<DirectNoteBottomSheet> createState() => _DirectNoteBottomSheetState();
}

class _DirectNoteBottomSheetState extends State<DirectNoteBottomSheet>
    with TickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // ─── Matrimonial Template Categories ──────────────────────────────────────
  final Map<String, _CategoryData> _templateCategories = const {
    '🌟 Family & Values': _CategoryData(
      subtitle: 'Best for parent-led & family-aligned introductions',
      templates: [
        '✨ Liked your profile & Gotra alignment. Our family would love to connect!',
        '🙏 Namaste, our families share similar traditions, values & cultural background.',
        '👨‍👩‍👧‍👦 Our parents reviewed your biodata and are very keen to take this forward.',
      ],
    ),
    '💼 Career & Ambition': _CategoryData(
      subtitle: 'Best for modern working professionals',
      templates: [
        '💼 Impressed by your profession and educational achievements. Would love to connect!',
        '🎯 Great match in lifestyle, career goals, and future aspirations.',
        '🌟 Hello! I find our professional backgrounds and life perspectives very compatible.',
      ],
    ),
    '🚩 Banjara Culture': _CategoryData(
      subtitle: 'Honor Gor-Banjara pride, language & traditions',
      templates: [
        '🚩 बंजारा संस्कृती व कौटुंबिक मूल्यांचा मनापासून आदर. बोलणे पुढे नेण्यास उत्सुक!',
        '✨ जय सेवालाल! Liked your profile and would love to initiate family dialogue.',
        '🌾 Proud of our Banjara heritage. Looking for an aligned life partner.',
      ],
    ),
    '💍 Marriage Intent': _CategoryData(
      subtitle: 'Direct, clear & respectful matrimonial proposals',
      templates: [
        '💍 Serious marriage prospect seeking mutual alignment. Let’s connect!',
        '🌟 Looking for a meaningful life partnership. Would love to discuss further.',
        '🕊️ Looking forward to a respectful conversation to explore prospective marriage.',
      ],
    ),
  };

  String _selectedCategory = '🌟 Family & Values';
  int _selectedChipIndex = 0;
  int _bonusCredits = 0;
  bool _isVip = false;
  bool _isSending = false;
  int _charCount = 0;

  // ─── Animations (Hot-Reload Resilient) ────────────────────────────────────
  AnimationController? _entryController;
  AnimationController? _pulseController;

  Animation<double>? _headerAnim;
  Animation<double>? _templatesAnim;
  Animation<double>? _inputAnim;
  Animation<double>? _buttonAnim;

  @override
  void initState() {
    super.initState();
    final initialTemplates = _templateCategories[_selectedCategory]!.templates;
    _noteController.text = initialTemplates.first;
    _charCount = _noteController.text.length;
    _noteController.addListener(_onTextChanged);

    _initAnimations();
    _entryController?.forward();
    _checkCredits();
  }

  void _initAnimations() {
    _entryController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _pulseController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _headerAnim = CurvedAnimation(
      parent: _entryController!,
      curve: const Interval(0.00, 0.40, curve: Curves.easeOutCubic),
    );
    _templatesAnim = CurvedAnimation(
      parent: _entryController!,
      curve: const Interval(0.20, 0.65, curve: Curves.easeOutCubic),
    );
    _inputAnim = CurvedAnimation(
      parent: _entryController!,
      curve: const Interval(0.40, 0.85, curve: Curves.easeOutCubic),
    );
    _buttonAnim = CurvedAnimation(
      parent: _entryController!,
      curve: const Interval(0.60, 1.00, curve: Curves.easeOutBack),
    );
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {
        _charCount = _noteController.text.length;
      });
    }
  }

  Future<void> _checkCredits() async {
    try {
      final usageRes = await UsageRepository().getRemainingBonusMessages();
      final planRes = await SubscriptionRepository().getPlanType();

      if (mounted) {
        setState(() {
          _bonusCredits = usageRes.fold(
            onSuccess: (val) => val,
            onFailure: (_) => 0,
          );
          final plan = planRes.fold(
            onSuccess: (p) => p.name.toLowerCase(),
            onFailure: (_) => '',
          );
          _isVip = plan.contains('vip') || plan.contains('matchmaker');
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _noteController.removeListener(_onTextChanged);
    _noteController.dispose();
    _focusNode.dispose();
    _entryController?.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  String get _targetName {
    final raw =
        widget.profile['name'] ??
        widget.profile['fullName'] ??
        widget.profile['full_name'] ??
        widget.profile['displayName'] ??
        'Match';
    return raw.toString().trim().isNotEmpty ? raw.toString().trim() : 'Match';
  }

  String get _targetId {
    return widget.profile['id']?.toString() ??
        widget.profile['profile_id']?.toString() ??
        '';
  }

  Future<void> _sendDirectNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) {
      Fluttertoast.showToast(
        msg:
            AppLocalizations.of(context)?.pleaseSelectOrWriteShortNote ??
            'Please select or write a short intro note',
      );
      return;
    }

    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();

    try {
      final myProfileId = await ShareRepository().getMyProfileId();

      if (myProfileId == null) {
        Fluttertoast.showToast(
          msg: 'You need a completed profile to send an intro note.',
        );
        setState(() => _isSending = false);
        return;
      }

      final shareRes = await ShareRepository().shareProfile(
        sharedProfileId: myProfileId,
        sharingMethod: 'in_app',
        recipientId: _targetId,
        recipientName: _targetName,
        recipientRelation: 'Prospect',
        profileName: 'Your',
      );

      if (shareRes.isSuccess) {
        if (!_isVip && _bonusCredits > 0) {
          await UsageRepository().consumeBonusMessage();
        }

        if (mounted) {
          HapticFeedback.heavyImpact();
          Fluttertoast.showToast(
            msg: '💌 Direct Intro Note delivered to $_targetName!',
            backgroundColor: AppColors.categoryLocation,
            textColor: Colors.white,
          );
          widget.onSuccess?.call();
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          Fluttertoast.showToast(
            msg: shareRes.errorMessage,
            backgroundColor: Colors.red.shade700,
          );
          setState(() => _isSending = false);
        }
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg:
              AppLocalizations.of(context)?.failedToSendNote(e.toString()) ??
              'Failed to send note: $e',
        );
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_entryController == null || _headerAnim == null) {
      _initAnimations();
      _entryController?.forward();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final targetName = _targetName;
    final hasCredits = _isVip || _bonusCredits > 0;
    final screenHeight = MediaQuery.of(context).size.height;

    final availableHeight = (screenHeight - bottomInset).clamp(
      300.0,
      screenHeight,
    );

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(maxHeight: availableHeight * 0.88),
          margin: EdgeInsets.fromLTRB(3.w, 0, 3.w, 0.5.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.slate900.withValues(alpha: 0.98)
                : Colors.white.withValues(alpha: 0.99),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(
                0xFFF59E0B,
              ).withValues(alpha: isDark ? 0.50 : 0.40),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFF59E0B,
                ).withValues(alpha: isDark ? 0.30 : 0.18),
                blurRadius: 36,
                spreadRadius: 2,
                offset: const Offset(0, -6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.70 : 0.20),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── 1. Fixed Top Header Bar ───
                  Container(
                    padding: EdgeInsets.fromLTRB(4.2.w, 1.4.h, 4.2.w, 1.2.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.slate900.withValues(alpha: AppColors.opacity70)
                          : AppColors.warningLight.withValues(alpha: AppColors.opacity60),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity20),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Golden Drag Handle
                        Center(
                          child: Container(
                            width: 12.w,
                            height: 4.5,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: AppColors.opacity40),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 1.2.h),

                        // Header Row with Wax Seal Icon
                        _buildAnimatedSection(
                          animation: _headerAnim,
                          child: _buildRoyalHeader(theme, isDark, targetName),
                        ),
                      ],
                    ),
                  ),

                  // ─── 2. Scrollable Body Content ───
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(3.8.w, 0.6.h, 3.8.w, 0.6.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // A. Categorized Matrimonial Icebreaker Templates
                          _buildAnimatedSection(
                            animation: _templatesAnim,
                            child: _buildCategorizedTemplates(theme, isDark),
                          ),
                          SizedBox(height: 0.7.h),

                          // B. Spacious Personalized Note Slate
                          _buildAnimatedSection(
                            animation: _inputAnim,
                            child: _buildPersonalizedNoteInput(
                              theme,
                              isDark,
                              targetName,
                            ),
                          ),
                          SizedBox(height: 0.6.h),

                          // C. Trust, Verification & Privacy Badges
                          _buildTrustBadgeRow(isDark),
                          SizedBox(height: 0.4.h),
                        ],
                      ),
                    ),
                  ),

                  // ─── 3. Sticky Glowing Send Action Dock ───
                  Container(
                    padding: EdgeInsets.fromLTRB(3.8.w, 0.8.h, 3.8.w, 1.0.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.slate900.withValues(alpha: 0.95)
                          : Colors.white.withValues(alpha: 0.98),
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? Colors.white12
                              : AppColors.slate200,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.40 : 0.08,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: _buildAnimatedSection(
                      animation: _buttonAnim,
                      child: _buildSendCtaButton(hasCredits, targetName),
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

  // ══════════════════════════════════════════════════════════════════════════
  // ANIMATED SECTION HELPER
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildAnimatedSection({
    required Animation<double>? animation,
    required Widget child,
    double slideOffset = 16.0,
  }) {
    if (animation == null) return child;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = animation.value;
        return Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1.0 - progress) * slideOffset),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECTION 1: ROYAL HEADER (WITH 3-STEP STEPPER & RECIPIENT ICON BADGE)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildRoyalHeader(ThemeData theme, bool isDark, String targetName) {
    return Row(
      children: [
        // 1. 3-Step Connected Process Stepper
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.45.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: AppColors.opacity5)
                  : AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : AppColors.slate200,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildHeaderStep(
                    icon: Icons.edit_note_rounded,
                    label:
                        AppLocalizations.of(context)?.pickNote ?? 'Pick Note',
                    isDark: isDark,
                  ),
                ),
                _buildHeaderStepArrow(isDark),
                Expanded(
                  child: _buildHeaderStep(
                    icon: Icons.mark_email_unread_rounded,
                    label:
                        AppLocalizations.of(context)?.topDelivery ??
                        'Top Delivery',
                    isDark: isDark,
                  ),
                ),
                _buildHeaderStepArrow(isDark),
                Expanded(
                  child: _buildHeaderStep(
                    icon: Icons.forum_rounded,
                    label:
                        AppLocalizations.of(context)?.threeXReplies ??
                        '3x Replies',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 2.2.w),

        // 3. Dismiss Button
        TactilePressable(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: AppColors.opacity8)
                  : Colors.black.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderStep({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(3.5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity30),
                blurRadius: 4,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 11),
        ),
        SizedBox(width: 1.0.w),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontWeight: AppTypography.extraBold,
              fontSize: AppTypography.labelSmall,
              color: isDark ? Colors.white : AppColors.slate800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderStepArrow(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.8.w),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 13,
        color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity80),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECTION 2: CATEGORIZED MATRIMONIAL TEMPLATES
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCategorizedTemplates(ThemeData theme, bool isDark) {
    final activeCategoryData = _templateCategories[_selectedCategory]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: AppColors.categoryAstro,
                  ),
                  SizedBox(width: 1.5.w),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)?.chooseQuickIntroTemplate ??
                          'CHOOSE A QUICK INTRO TEMPLATE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        color: isDark ? Colors.white : AppColors.slate800,
                        fontWeight: AppTypography.black,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              AppLocalizations.of(context)?.oneTapSelect ?? '1-Tap Select',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontWeight: AppTypography.bold,
                color: isDark ? Colors.white54 : Colors.black45,
                fontSize: AppTypography.labelSmall,
              ),
            ),
          ],
        ),

        // ─── Horizontal Category Tabs ───
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _templateCategories.keys.map((category) {
              final isCatSelected = _selectedCategory == category;
              return Padding(
                padding: EdgeInsets.only(right: 1.8.w),
                child: TactilePressable(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedCategory = category;
                      _selectedChipIndex = 0;
                      _noteController.text =
                          _templateCategories[category]!.templates.first;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.2.w,
                      vertical: 0.6.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: isCatSelected
                          ? const LinearGradient(
                              colors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isCatSelected
                          ? null
                          : (isDark
                                ? AppColors.slate800
                                : AppColors.slate100),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCatSelected
                            ? AppColors.categoryAstro
                            : (isDark
                                  ? Colors.white12
                                  : AppColors.slate300),
                        width: isCatSelected ? 1.4 : 1.0,
                      ),
                      boxShadow: isCatSelected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFFF59E0B,
                                ).withValues(alpha: AppColors.opacity35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: AppTypography.labelMedium,
                        fontWeight: isCatSelected
                            ? AppTypography.black
                            : AppTypography.bold,
                        color: isCatSelected
                            ? Colors.white
                            : (isDark
                                  ? Colors.white70
                                  : AppColors.slate600),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 0.5.h),

        // Subtitle of active category
        Text(
          activeCategoryData.subtitle,
          style: TextStyle(
            fontSize: AppTypography.bodySmall,
            fontStyle: FontStyle.italic,
            fontWeight: AppTypography.semiBold,
            color: isDark ? AppColors.slate400 : AppColors.slate500,
          ),
        ),

        // ─── Templates List in Active Category ───
        Column(
          children: List.generate(activeCategoryData.templates.length, (index) {
            final template = activeCategoryData.templates[index];
            final isSelected = _selectedChipIndex == index;

            return Padding(
              padding: EdgeInsets.only(bottom: 0.6.h),
              child: TactilePressable(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedChipIndex = index;
                    _noteController.text = template;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.2.w,
                    vertical: 0.9.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(
                            0xFFF59E0B,
                          ).withValues(alpha: isDark ? 0.22 : 0.14)
                        : (isDark
                              ? AppColors.surfaceDarkNavy
                              : AppColors.slate50),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.categoryAstro
                          : (isDark ? Colors.white10 : AppColors.slate200),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFF59E0B,
                              ).withValues(alpha: AppColors.opacity15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.categoryAstro
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.categoryAstro
                                : (isDark ? Colors.white30 : Colors.black26),
                            width: 1.4,
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: isSelected ? Colors.white : Colors.transparent,
                          size: 13,
                        ),
                      ),
                      SizedBox(width: 2.5.w),
                      Expanded(
                        child: Text(
                          template,
                          style: TextStyle(
                            fontSize: AppTypography.labelSmall,
                            fontWeight: isSelected
                                ? AppTypography.extraBold
                                : AppTypography.semiBold,
                            height: 1.35,
                            color: isSelected
                                ? (isDark
                                      ? Colors.white
                                      : AppColors.slate900)
                                : (isDark
                                      ? Colors.white70
                                      : AppColors.slate700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECTION 5: PERSONALIZED NOTE INPUT SLATE
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildPersonalizedNoteInput(
    ThemeData theme,
    bool isDark,
    String targetName,
  ) {
    Color charCounterColor;
    if (_charCount > 180) {
      charCounterColor = AppColors.trustLow;
    } else if (_charCount > 140) {
      charCounterColor = AppColors.categoryAstro;
    } else {
      charCounterColor = isDark ? Colors.white60 : AppColors.slate500;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.2.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDarkNavy : AppColors.slate50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(
            0xFFF59E0B,
          ).withValues(alpha: isDark ? 0.45 : 0.35),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFFF59E0B,
            ).withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slate Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.categoryAstro, AppColors.categoryAstroDark],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 1.8.w),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)?.orCustomizeYourNote ??
                            'OR CUSTOMIZE YOUR NOTE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          color: isDark
                              ? Colors.white
                              : AppColors.slate900,
                          fontWeight: AppTypography.black,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_noteController.text.isNotEmpty) ...[
                SizedBox(width: 1.5.w),
                TactilePressable(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _noteController.clear();
                    setState(() => _selectedChipIndex = -1);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.6.w,
                      vertical: 0.3.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity30),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)?.clearText ?? 'Clear text',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.labelSmall,
                        color: AppColors.categoryAstro,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 0.4.h),
          Text(
            AppLocalizations.of(context)?.writeYourOwnGenuineMessage ??
                'Write your own genuine message or edit the selected template above:',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              color: isDark ? Colors.white60 : AppColors.slate500,
              fontWeight: AppTypography.semiBold,
              fontSize: AppTypography.bodySmall,
            ),
          ),

          // Big Spacious TextField
          TextField(
            controller: _noteController,
            focusNode: _focusNode,
            minLines: 3,
            maxLines: 5,
            maxLength: 200,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              color: isDark ? Colors.white : AppColors.slate900,
              fontWeight: AppTypography.semiBold,
              fontSize: AppTypography.bodySmall,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText:
                  AppLocalizations.of(context)?.typeCustomIntroNoteHint ??
                  'Type your custom matrimonial intro note here...\n(e.g., family background, career aspirations, shared values)',
              hintStyle: TextStyle(
                fontSize: AppTypography.bodySmall,
                height: 1.35,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.slate900.withValues(alpha: AppColors.opacity80)
                  : Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 3.5.w,
                vertical: 1.1.h,
              ),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : AppColors.slate200,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : AppColors.slate200,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.categoryAstro,
                  width: 1.6,
                ),
              ),
            ),
          ),
          SizedBox(height: 0.6.h),

          // Bottom Helper Strip inside Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 14,
                      color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity90),
                    ),
                    SizedBox(width: 1.2.w),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)?.tipPersonalizedNotes ??
                            'Tip: Personalized notes get 3x replies',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.bodySmall,
                          color: isDark
                              ? Colors.white70
                              : AppColors.slate500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.2.w,
                  vertical: 0.2.h,
                ),
                decoration: BoxDecoration(
                  color: charCounterColor.withValues(
                    alpha: isDark ? 0.20 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: charCounterColor.withValues(alpha: AppColors.opacity35),
                  ),
                ),
                child: Text(
                  '$_charCount / 200',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontWeight: AppTypography.extraBold,
                    color: charCounterColor,
                    fontSize: AppTypography.labelSmall,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECTION 6: TRUST & PRIVACY BADGE ROW
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildTrustBadgeRow(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.0.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.slate100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.slate200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTrustItem(
              Icons.lock_rounded,
              AppLocalizations.of(context)?.oneHundredPercentPrivate ??
                  '100% Private',
              isDark,
            ),
          ),
          Expanded(
            child: _buildTrustItem(
              Icons.verified_user_rounded,
              AppLocalizations.of(context)?.verifiedBiodata ??
                  'Verified Biodata',
              isDark,
            ),
          ),
          Expanded(
            child: _buildTrustItem(
              Icons.flash_on_rounded,
              AppLocalizations.of(context)?.instantAlert ?? 'Instant Alert',
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 13, color: AppColors.categoryLocation),
        SizedBox(width: 1.0.w),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontWeight: AppTypography.extraBold,
              fontSize: AppTypography.labelSmall,
              color: isDark ? Colors.white70 : AppColors.slate600,
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECTION 7: STICKY GLOWING SEND CTA
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSendCtaButton(bool hasCredits, [String? targetName]) {
    final pulse = _pulseController;
    if (pulse == null) {
      return _buildStaticSendButton(hasCredits, 0.25, 1.0, targetName);
    }

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final glowAlpha = 0.25 + (pulse.value * 0.25);
        final glowSpread = 1.0 + (pulse.value * 2.5);

        return _buildStaticSendButton(
          hasCredits,
          glowAlpha,
          glowSpread,
          targetName,
        );
      },
    );
  }

  Widget _buildStaticSendButton(
    bool hasCredits, [
    double glowAlpha = 0.25,
    double glowSpread = 1.0,
    String? targetName,
  ]) {
    final name = targetName ?? _targetName;
    return TactilePressable(
      onTap: _isSending ? null : _sendDirectNote,
      child: Container(
        width: double.infinity,
        height: 5.6.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasCredits
                ? [AppColors.categoryAstro, AppColors.categoryAstroDark]
                : [AppColors.categoryAstro, AppColors.amberDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.categoryAstro.withValues(alpha: glowAlpha),
              blurRadius: 18,
              spreadRadius: glowSpread,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _isSending
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 2.w),
                  Flexible(
                    child: Text(
                      _isVip
                          ? 'SEND VIP INTRO NOTE TO $name 👑'
                          : _bonusCredits > 0
                          ? 'SEND INTRO NOTE (🔥 1 Credit) 💌'
                          : 'SEND 1 FREE INTRO NOTE TO $name 💌',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        color: Colors.white,
                        fontWeight: AppTypography.black,
                        fontSize: AppTypography.labelMedium,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CategoryData {
  final String subtitle;
  final List<String> templates;

  const _CategoryData({required this.subtitle, required this.templates});
}
