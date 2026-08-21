import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/repositories/auth_repository.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/utils/startup_workflow.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';

/// 10+ Year Senior Product Designer Level Onboarding Selection Screen
/// High conversion, zero text overlap, luxury typography, multi-layered depth.
class OnboardingSelectionScreen extends StatefulWidget {
  const OnboardingSelectionScreen({super.key});

  @override
  State<OnboardingSelectionScreen> createState() =>
      _OnboardingSelectionScreenState();
}

class _OnboardingSelectionScreenState extends State<OnboardingSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Navigation & Support Launchers ──

  Future<void> _launchWhatsApp() async {
    final lang = Localizations.localeOf(context).languageCode;
    final msgs = {
      'mr': 'नमस्कार बंजाराबायो सपोर्ट, मला बायोडेटा तयार करण्यासाठी मदत हवी आहे.',
      'hi': 'नमस्ते बंजाराबायो सपोर्ट, मुझे अपना बायोडेटा बनाने में मदद चाहिए।',
      'te': 'నమస్కారం బంజారాబయో సపోర్ట్, నా బయోడేటాను సృష్టించడంలో నాకు సహాయం కావాలి.',
      'kn': 'ನಮಸ್ಕಾರ ಬಂಜಾರಬಯೋ ಸಪೋರ್ಟ್, ನನ್ನ ಬಯೋಡೇಟಾವನ್ನು ರಚಿಸಲು ನನಗೆ ಸಹಾಯ ಬೇಕು.',
    };
    final msg = msgs[lang] ?? 'Hello BanjaraBio Support, I need help creating my biodata.';
    final url = Uri.parse('https://wa.me/918186050406?text=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)?.couldNotLaunchWhatsApp ?? 'Could not launch WhatsApp'),
      ));
    }
  }

  Future<void> _launchDialer() async {
    final url = Uri.parse('tel:+918186050406');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)?.couldNotLaunchDialer ?? 'Could not launch Phone Dialer'),
      ));
    }
  }

  bool get _isAuthenticated => AppSupabaseClient.isAuthenticated;

  void _browseMatches() => Navigator.of(context).pushNamed(AppRoutes.relativeIntake);

  void _createBiodata() {
    AppLogger.debug('OnboardingSelectionScreen', '_createBiodata called. isAuthenticated: $_isAuthenticated');
    if (_isAuthenticated) {
      Navigator.of(context).pushNamed(AppRoutes.biodataCreation);
    } else {
      Navigator.of(context).pushNamed(AppRoutes.authentication);
    }
  }

  Future<void> _handleLogout() async {
    final response = await AuthRepository().signOut();
    await response.fold(
      onSuccess: (_) async {
        await LocalCacheService().setGuestMode(false);
        await LocalCacheService().clearRelativeBrowseSession();
        if (mounted) {
          // Rebuild to show unauthenticated state
          setState(() {});
        }
      },
      onFailure: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.failedToLogout(error) ?? 'Logout failed: $error',
              ),
            ),
          );
        }
      },
    );
  }

  void _goToLogin() {
    if (_isAuthenticated) {
      StartupWorkflow.navigateBasedOnStatus(context);
    } else {
      Navigator.of(context).pushNamed(AppRoutes.authentication);
    }
  }

  // ── Staggered Entrance Animation Helper ──
  Widget _staggered({required double start, required double end, required Widget child}) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _entranceController, curve: Interval(start, end)),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final primary = theme.colorScheme.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            // Layer 0: Multi-Tone Ambient Gradient Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [AppColors.crimsonBlack, AppColors.crimsonBlack, AppColors.canvasDark]
                        : [AppColors.roseBlush, AppColors.rosePinkLight, AppColors.rosePinkLight],
                  ),
                ),
              ),
            ),

            // Layer 1: Ambient Glow Aurora Orbs
            Positioned(
              top: -12.h, right: -15.w,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: _auroraOrb(55.w, primary.withValues(alpha: isDark ? 0.18 : 0.10)),
              ),
            ),
            Positioned(
              bottom: -10.h, left: -15.w,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: _auroraOrb(50.w, AppColors.categoryAstroDark.withValues(alpha: isDark ? 0.14 : 0.08)),
              ),
            ),

            // Layer 2: Main Layout Surface
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                          child: Column(
                            children: [
                              _buildTopBar(theme, isDark, l10n, primary),
                              SizedBox(height: 1.0.h),
                              _buildHero(theme, isDark, l10n, primary),
                              SizedBox(height: 1.2.h),
                              _buildCards(theme, isDark, l10n, primary),
                              const Spacer(),
                              SizedBox(height: 0.8.h),
                              _buildAccountActionStrip(theme, isDark, l10n, primary),
                              SizedBox(height: 0.6.h),
                              _buildSupportStrip(theme, isDark, l10n, primary),
                              SizedBox(height: 0.4.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _auroraOrb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 1. TOP BAR — Live Trust Badge & Lang Switcher
  // ══════════════════════════════════════════════
  Widget _buildTopBar(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    return _staggered(
      start: 0.0, end: 0.25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button to User Type Selection
          _TactileCardWrapper(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed(AppRoutes.userTypeSelection);
              }
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: AppColors.opacity12)
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.22)
                      : primary.withValues(alpha: AppColors.opacity25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : primary).withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_rounded, size: 16.sp, color: theme.colorScheme.onSurface),
            ),
          ),

          SizedBox(width: 1.5.w),

          // Live Activity Pill
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.7.h),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: AppColors.opacity8) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: AppColors.opacity12) : Colors.black.withValues(alpha: AppColors.opacity8),
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _livePulseDot(),
                  SizedBox(width: 1.5.w),
                  Flexible(
                    child: Text(
                      '2,400+ Active',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.bodyMedium,
                        color: isDark ? AppTheme.secondaryDark : AppTheme.secondaryVariantLight,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 1.5.w),

          // Language Switcher Button
          _TactileCardWrapper(
            onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.initialLanguageSelection),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.7.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary.withValues(alpha: AppColors.opacity12), primary.withValues(alpha: 0.06)],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: primary.withValues(alpha: AppColors.opacity25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language_rounded, size: 15.sp, color: primary),
                  SizedBox(width: 1.5.w),
                  Text(
                    l10n?.changeLanguage ?? 'भाषा',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: AppTypography.extraBold,
                      fontSize: AppTypography.bodyLarge,
                      color: primary,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 14.sp, color: primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _livePulseDot() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.whatsapp,
          boxShadow: [
            BoxShadow(color: AppColors.whatsapp.withValues(alpha: AppColors.opacity60), blurRadius: 8, spreadRadius: 1),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 2. HERO — Brand Emblem & Headlines
  // ══════════════════════════════════════════════
  Widget _buildHero(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    final welcome = l10n?.welcomeToBanjaraBio ?? 'Welcome to BanjaraBio!';
    final subtitle = l10n?.chooseHowToStart ?? 'Find your perfect match within the Banjara community';

    return _staggered(
      start: 0.1, end: 0.4,
      child: Column(
        children: [
          // Logo Emblem with Glowing Halo
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 32.w, height: 32.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface,
                border: Border.all(color: primary.withValues(alpha: AppColors.opacity40), width: 3.5),
                boxShadow: [
                  BoxShadow(color: primary.withValues(alpha: 0.32), blurRadius: 28, spreadRadius: 4),
                ],
              ),
              child: const ClipOval(child: AppLogoImage()),
            ),
          ),
          SizedBox(height: 1.0.h),

          // Community Trust Tagline Pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 0.6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.bloodRedBg, AppColors.crimsonBlack]
                    : [AppColors.primaryLight, AppColors.rose100],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: primary.withValues(alpha: AppColors.opacity25), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🚩', style: TextStyle(fontSize: AppTypography.bodyMedium)),
                SizedBox(width: 1.5.w),
                Text(
                  'बंजारा समाजाचे #1 बायोडेटा प्लॅटफॉर्म',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: AppTypography.black,
                    fontSize: AppTypography.bodyMedium,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 0.8.h),

          // Main Headline
          Text(
            welcome,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: AppTypography.headingFontFamily,
              fontWeight: AppTypography.black,
              fontSize: AppTypography.headingSmall,
              color: theme.colorScheme.onSurface,
              height: 1.15,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 0.3.h),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: AppTypography.bodyFontFamily,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: AppTypography.medium,
              fontSize: AppTypography.bodySmall,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 3. PATHWAY CARDS — 10-Year Craft Masterpieces
  // ══════════════════════════════════════════════
  Widget _buildCards(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    return Column(
      children: [
        // Card 1: Search Matches (Instant Discovery)
        _buildSearchMatchesCard(theme, isDark, l10n, primary),
        SizedBox(height: 1.0.h),

        // Card 2: Create Biodata (Recommended Primary Conversion Pathway)
        _buildCreateBiodataCard(theme, isDark, l10n, primary),
      ],
    );
  }

  /// CARD 1: Search Matches (Instant Discovery / Relative Search Card)
  Widget _buildSearchMatchesCard(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    final badgeText = l10n?.option1Badge ?? 'OPTION 1 • NO LOGIN NEEDED';
    final cardTitle = l10n?.searchMatchesForRelativesTitle ?? 'Find Matches for Relatives';
    final cardSub = l10n?.searchMatchesForRelativesSubtitle ??
        'Search thousands of verified profiles for son, daughter, brother or sister directly without creating a profile.';
    final ctaText = l10n?.searchMatchesForRelativesCta ?? 'Find Matches for Relatives 👉';

    return _staggered(
      start: 0.2,
      end: 0.5,
      child: _TactileCardWrapper(
        onTap: _browseMatches,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.canvasDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.sapphireBlue.withValues(alpha: AppColors.opacity40) : AppColors.sapphireBlue.withValues(alpha: AppColors.opacity30),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.sapphireBlue.withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row: Option 1 Badge & Circular Icon Avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Option 1 Badge Pill
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.0.w, vertical: 0.4.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.oceanBlueDark.withValues(alpha: AppColors.opacity30) : AppColors.infoLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.sapphireBlue.withValues(alpha: AppColors.opacity50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, size: 13.sp, color: AppColors.sapphireBlue),
                        SizedBox(width: 1.w),
                        Text(
                          badgeText,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: AppTypography.black,
                            fontSize: AppTypography.bodyMedium,
                            color: AppColors.sapphireBlue,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Circular Icon Container
                  Container(
                    width: 9.5.w, height: 9.5.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.sapphireBlue.withValues(alpha: AppColors.opacity20), AppColors.sapphireBlue.withValues(alpha: AppColors.opacity8)],
                      ),
                      border: Border.all(color: AppColors.sapphireBlue.withValues(alpha: AppColors.opacity30)),
                    ),
                    child: Icon(Icons.person_search_rounded, size: 17.sp, color: AppColors.sapphireBlue),
                  ),
                ],
              ),
              SizedBox(height: 0.8.h),

              // Title
              Text(
                cardTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppTypography.headingFontFamily,
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.headingSmall,
                  color: theme.colorScheme.onSurface,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 0.4.h),

              // Subtitle Explanation
              Text(
                cardSub,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: AppTypography.medium,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 0.8.h),

              // Feature Micro-Chips Grid
              Wrap(
                spacing: 1.8.w,
                runSpacing: 0.5.h,
                children: [
                  _featureChip(theme, l10n?.chipNoAccount ?? '⚡ No Account Needed', isDark),
                  _featureChip(theme, l10n?.chipQuickFilter ?? '🔍 1-Min Search', isDark),
                  _featureChip(theme, l10n?.chipFreeAccess ?? '⭐ 100% Free Access', isDark),
                ],
              ),
              SizedBox(height: 1.2.h),

              // Elevated CTA Action Button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 0.9.h),
                decoration: BoxDecoration(
                  color: AppColors.sapphireBlue.withValues(alpha: AppColors.opacity10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.sapphireBlue.withValues(alpha: AppColors.opacity35), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_rounded, size: 15.sp, color: AppColors.sapphireBlue),
                    SizedBox(width: 1.5.w),
                    Text(
                      ctaText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: AppTypography.black,
                        fontSize: AppTypography.bodyLarge,
                        color: AppColors.sapphireBlue,
                      ),
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

  /// CARD 2: Create My Biodata (Luxurious Primary Hero Card)
  Widget _buildCreateBiodataCard(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    final badgeText = l10n?.option2Badge ?? 'OPTION 2 • MOST POPULAR • 100% FREE';
    final cardTitle = l10n?.createBiodataForSelfOrCandidateTitle ?? (l10n?.createMyBiodata ?? 'Create My Biodata');
    final cardSub = l10n?.createBiodataForSelfOrCandidateSubtitle ??
        'Create official biodata to view photos, mobile numbers & download PDF.';
    final ctaText = l10n?.loginAndCreateBiodataCta ?? 'Login & Create Biodata ✨';

    return _staggered(
      start: 0.35,
      end: 0.65,
      child: _TactileCardWrapper(
        onTap: _createBiodata,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.crimsonMaroon, // Deep Rose/Crimson
                AppColors.wineRed,
                AppColors.wineDark,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.categoryAstro, width: 1.8), // Gold Glowing Accent Border
            boxShadow: [
              BoxShadow(
                color: AppColors.crimsonDeep.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Row: Recommended Badge & Glowing Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge Pill
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.0.w, vertical: 0.4.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldTint100, AppColors.goldTint200],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity35),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('⭐', style: TextStyle(fontSize: AppTypography.bodySmall)),
                        SizedBox(width: 1.w),
                        Text(
                          badgeText,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: AppTypography.black,
                            fontSize: AppTypography.bodyMedium,
                            color: AppColors.amberDarkestText,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Glowing Icon Container
                  Container(
                    width: 9.5.w, height: 9.5.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.22),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
                    ),
                    child: Icon(Icons.person_add_alt_1_rounded, size: 17.sp, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 0.8.h),

              // Title
              Text(
                cardTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppTypography.headingFontFamily,
                  fontWeight: AppTypography.black,
                  fontSize: AppTypography.headingSmall,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 0.4.h),

              // Subtitle Explanation
              Text(
                cardSub,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: AppTypography.medium,
                  color: Colors.white.withValues(alpha: AppColors.opacity90),
                  height: 1.25,
                ),
              ),
              SizedBox(height: 0.8.h),

              // Benefit List Bullets
              _heroBenefitRow(
                theme,
                '✨',
                l10n?.benefitPdfBiodata ?? 'Create Beautiful PDF Biodata in 2 Mins',
              ),
              SizedBox(height: 0.4.h),
              _heroBenefitRow(
                theme,
                '📱',
                l10n?.benefitShareWhatsApp ?? 'Share Directly on WhatsApp with Families',
              ),
              SizedBox(height: 0.4.h),
              _heroBenefitRow(
                theme,
                '🛡️',
                l10n?.benefitVerifiedProfiles ?? '100% Verified Community Profiles',
              ),
              SizedBox(height: 1.2.h),

              // High Impact Golden CTA Button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.0.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.goldSoft, AppColors.categoryAstro],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.categoryAstro.withValues(alpha: AppColors.opacity40),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.amberBgDark),
                    SizedBox(width: 1.5.w),
                    Text(
                      ctaText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: AppTypography.black,
                        fontSize: AppTypography.bodyLarge,
                        color: AppColors.amberBgDark,
                      ),
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

  Widget _featureChip(ThemeData theme, String text, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.35.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.07) : AppColors.slate100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.slate200),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: AppTypography.bodyMedium,
          fontWeight: AppTypography.semiBold,
          color: isDark ? Colors.white70 : AppColors.slate700,
        ),
      ),
    );
  }

  Widget _heroBenefitRow(ThemeData theme, String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: AppTypography.bodyMedium)),
        SizedBox(width: 1.5.w),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: AppTypography.bodyMedium,
              fontWeight: AppTypography.semiBold,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 3.5 ACCOUNT ACTION STRIP (Login / Logout)
  // ══════════════════════════════════════════════
  Widget _buildAccountActionStrip(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    return _staggered(
      start: 0.55, end: 0.8,
      child: Column(
        children: [
          if (_isAuthenticated)
            // Logged-in user: show subtle logout option
            _TactileCardWrapper(
              onTap: _handleLogout,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.7.h),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: AppColors.opacity5) : Colors.grey.withValues(alpha: AppColors.opacity8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded, size: 14.sp, color: theme.colorScheme.onSurfaceVariant),
                    SizedBox(width: 1.5.w),
                    Text(
                      l10n?.logout ?? 'Logout',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: AppTypography.bold,
                        fontSize: AppTypography.bodyMedium,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Not logged-in: show 'Already have a profile? Login' link
            _TactileCardWrapper(
              onTap: _goToLogin,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.7.h),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: isDark ? 0.10 : 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primary.withValues(alpha: AppColors.opacity25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login_rounded, size: 14.sp, color: primary),
                    SizedBox(width: 1.5.w),
                    Text(
                      l10n?.alreadyHaveProfileLogin ?? 'Already have a profile? Login',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.bodyMedium,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 4. SUPPORT STRIP (WhatsApp & Call)
  // ══════════════════════════════════════════════
  Widget _buildSupportStrip(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    final lang = Localizations.localeOf(context).languageCode;
    final helpTitles = {
      'mr': 'काही अडचण आहे? सपोर्टशी संपर्क साधा',
      'hi': 'क्या आपको सहायता चाहिए? सहायता टीम से संपर्क करें',
      'te': 'సహాయం కావాలా? సపోర్ట్‌ను సంప్రదించండి',
      'kn': 'ಸಹಾಯ ಬೇಕೇ? ಬೆಂಬಲವನ್ನು ಸಂಪರ್ಕಿಸಿ',
    };
    final needHelp = helpTitles[lang] ?? 'Need help? Contact BanjaraBio Support';

    return _staggered(
      start: 0.6, end: 0.9,
      child: Column(
        children: [
          Text(
            needHelp,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: AppTypography.semiBold,
              fontSize: AppTypography.bodyMedium,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // WhatsApp Support Action Pill
              _TactileCardWrapper(
                onTap: _launchWhatsApp,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: AppColors.whatsapp.withValues(alpha: AppColors.opacity12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.whatsapp.withValues(alpha: AppColors.opacity30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_rounded, size: 15.sp, color: AppColors.whatsapp),
                      SizedBox(width: 1.8.w),
                      Text(
                        'WhatsApp',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: AppTypography.extraBold,
                          fontSize: AppTypography.bodyLarge,
                          color: AppColors.whatsapp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 3.w),

              // Phone Call Action Pill
              _TactileCardWrapper(
                onTap: _launchDialer,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: AppColors.opacity10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primary.withValues(alpha: AppColors.opacity25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call_rounded, size: 15.sp, color: primary),
                      SizedBox(width: 1.8.w),
                      Text(
                        'Call Us',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: AppTypography.extraBold,
                          fontSize: AppTypography.bodyLarge,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tactile press animation wrapper
class _TactileCardWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TactileCardWrapper({required this.child, required this.onTap});

  @override
  State<_TactileCardWrapper> createState() => _TactileCardWrapperState();
}

class _TactileCardWrapperState extends State<_TactileCardWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
