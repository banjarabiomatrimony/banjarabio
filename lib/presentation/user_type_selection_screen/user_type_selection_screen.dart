import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/presentation/authentication_screen/authentication_screen.dart';
import 'package:banjarabio/core/session_manager.dart';
import 'package:banjarabio/core/providers/locale_provider.dart';

/// 🌟 Billion-Dollar Global Standard 2-Tab Entry Gateway Screen
/// Features:
/// - Floating Ambient Gold & Crimson Constellation Particles
/// - Floating Multi-Ring Luminous Halo for Brand Emblem
/// - Spring-animated Liquid Pill Tab Switcher with Dynamic Gradient & Shadows
/// - Continuous 60FPS Diagonal Sweep Glint on Primary Action Cards
/// - Frosted Glassmorphic Containers with Subtle Specular Edge Lighting
/// - Direct modal language selector on launch & anytime top-bar trigger
class UserTypeSelectionScreen extends ConsumerStatefulWidget {
  /// Initial tab index (0 = Existing Member, 1 = New Member, null = Auto Detect based on session history)
  final int? initialTabIndex;

  const UserTypeSelectionScreen({
    super.key,
    this.initialTabIndex,
  });

  @override
  ConsumerState<UserTypeSelectionScreen> createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends ConsumerState<UserTypeSelectionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _glintController;
  late AnimationController _particleController;
  Timer? _langPromptTimer;

  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  // Staggered Entrance Animations
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _tabsFade;
  late Animation<Offset> _tabsSlide;
  late Animation<double> _bodyFade;
  late Animation<Offset> _bodySlide;
  late Animation<double> _footerFade;

  final List<_FloatingParticle> _particles = List.generate(
    14,
    (index) => _FloatingParticle(
      x: (index * 0.07 + 0.05) % 1.0,
      y: (index * 0.08 + 0.1) % 1.0,
      radius: 1.5 + (index % 4) * 1.2,
      speed: 0.2 + (index % 5) * 0.15,
      isGold: index % 2 == 0,
    ),
  );

  @override
  void initState() {
    super.initState();

    // 🎯 Smart Tab Resolution:
    // If no explicit tab index passed:
    // - If user has previously logged in or has active/past session -> Tab 0 (Existing Member)
    // - New install / first launch / no account ever -> Tab 1 (New Member)
    final resolvedTabIndex = widget.initialTabIndex ??
        (SessionManager.instance.hasPreviouslyLoggedIn || SessionManager.instance.isLoggedIn ? 0 : 1);

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: resolvedTabIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.mediumImpact();
        setState(() {});
      }
    });

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _glintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _glowAnimation = Tween<double>(begin: 0.20, end: 0.75).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Staggered curves
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.35, curve: Curves.easeOut)),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic)),
    );

    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.15, 0.50, curve: Curves.easeOut)),
    );
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.15, 0.50, curve: Curves.easeOutCubic)),
    );

    _tabsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.30, 0.65, curve: Curves.easeOut)),
    );
    _tabsSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.30, 0.65, curve: Curves.easeOutCubic)),
    );

    _bodyFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.45, 0.85, curve: Curves.easeOut)),
    );
    _bodySlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic)),
    );

    _footerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.65, 1.0, curve: Curves.easeOut)),
    );

    _entranceController.forward();
    _pulseController.repeat(reverse: true);
    _glintController.repeat();
    _particleController.repeat();

    // 🌐 Auto-prompt Language Selection on 1st Launch if no locale saved yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptLanguageOnLaunch();
    });
  }

  Future<void> _checkAndPromptLanguageOnLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString('selected_locale');
      if (savedLocale == null && mounted) {
        // Small delay to let screen entrance animation settle
        _langPromptTimer?.cancel();
        _langPromptTimer = Timer(const Duration(milliseconds: 300), () {
          if (mounted) {
            _showLanguageSelectionModal(context, isFirstTime: true);
          }
        });
      }
    } catch (e) {
      AppLogger.error('UserTypeSelectionScreen', 'Error checking saved locale: $e');
    }
  }

  void _showLanguageSelectionModal(BuildContext context, {bool isFirstTime = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentLocale = ref.read(localeProvider);
    final activeCode = currentLocale?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;

    final languages = [
      {'code': 'mr', 'label': 'Marathi', 'native': 'मराठी', 'sub': 'बंजारा समाजासाठी पहिली पसंती'},
      {'code': 'en', 'label': 'English', 'native': 'English', 'sub': 'Universal Language'},
      {'code': 'hi', 'label': 'Hindi', 'native': 'हिंदी', 'sub': 'राष्ट्रभाषा'},
      {'code': 'te', 'label': 'Telugu', 'native': 'తెలుగు', 'sub': 'తెలుగు మాట్లాడే వారి కోసం'},
      {'code': 'kn', 'label': 'Kannada', 'native': 'ಕನ್ನಡ', 'sub': 'ಕರ್ನಾಟಕದ ಬಂಜಾರ ಬಾಂಧವರಿಗಾಗಿ'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
          return Container(
            constraints: BoxConstraints(maxHeight: 85.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1114) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : AppColors.categoryAstro.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.60 : 0.20),
                  blurRadius: 30,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, 3.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Pill
                Center(
                  child: Container(
                    width: 42,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : AppColors.slate300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                SizedBox(height: 2.0.h),

                // Title & Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.categoryAstro.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.language_rounded, size: 22, color: AppColors.categoryAstroDark),
                    ),
                    SizedBox(width: 2.5.w),
                    Flexible(
                      child: Text(
                        'निवडा तुमची भाषा / Select Language',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontWeight: AppTypography.extraBold,
                          fontSize: AppTypography.bodyLarge,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.6.h),
                Text(
                  'तुम्हाला सोयीस्कर असलेली भाषा निवडा',
                  style: TextStyle(
                    fontSize: AppTypography.labelSmall,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.0.h),

                // Language List Cards (Scrollable for smaller screens)
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: languages.map((lang) {
                final isSelected = lang['code'] == activeCode;
                final primaryColor = isSelected ? AppColors.categoryAstroDark : theme.colorScheme.onSurface;

                return Padding(
                  padding: EdgeInsets.only(bottom: 1.0.h),
                  child: TactilePressable(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      final code = lang['code']!;
                      ref.read(localeProvider.notifier).setLocale(Locale(code));
                      Navigator.of(modalContext).pop();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  AppColors.goldTint100.withValues(alpha: isDark ? 0.35 : 0.65),
                                  AppColors.goldTint200.withValues(alpha: isDark ? 0.20 : 0.40),
                                ],
                              )
                            : null,
                        color: isSelected
                            ? null
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.slate50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.categoryAstro
                              : (isDark ? Colors.white12 : AppColors.slate200),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.categoryAstro.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.categoryAstroDark
                                  : (isDark ? Colors.white10 : AppColors.slate200),
                            ),
                            child: Center(
                              child: Text(
                                lang['native']!.substring(0, 1),
                                style: TextStyle(
                                  fontWeight: AppTypography.bold,
                                  fontSize: 16,
                                  color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.5.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        lang['native']!,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: AppTypography.headingFontFamily,
                                          fontWeight: AppTypography.bold,
                                          fontSize: AppTypography.bodyMedium,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Flexible(
                                      child: Text(
                                        '(${lang['label']})',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: AppTypography.labelSmall,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  lang['sub']!,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.categoryAstroDark,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    ),
  );
},
    );
  }

  @override
  void dispose() {
    _langPromptTimer?.cancel();
    _tabController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    _glintController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // ── Navigation Launchers ──

  Future<void> _launchWhatsApp() async {
    final lang = Localizations.localeOf(context).languageCode;
    final msgs = {
      'mr': 'नमस्कार बंजाराबायो सपोर्ट, मला लॉगिन किंवा नवीन खाते तयार करण्यासाठी मदत हवी आहे.',
      'hi': 'नमस्ते बंजाराबायो सपोर्ट, मुझे लॉगिन या नया खाता बनाने में मदद चाहिए।',
      'te': 'నమస్కారం బంజారాబయో సపోర్ట్, నాకు లాగిన్ లేదా కొత్త ఖాతా సృష్టించడంలో సహాయం కావాలి.',
      'kn': 'ನಮಸ್ಕಾರ ಬಂಜಾರಬಯೋ ಸಪೋರ್ಟ್, ನನಗೆ ಲಾಗಿನ್ ಅಥವಾ ಹೊಸ ಖಾತೆ ರಚಿಸಲು ಸಹಾಯ ಬೇಕು.',
    };
    final msg = msgs[lang] ?? 'Hello BanjaraBio Support, I need help with login or creating an account.';
    final url = Uri.parse('https://wa.me/918186050406?text=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)?.couldNotLaunchWhatsApp ?? 'Could not launch WhatsApp'),
      ));
    }
  }

  Future<void> _launchInstagram() async {
    final url = Uri.parse('https://www.instagram.com/banjarabio.matrimony/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not launch Instagram'),
      ));
    }
  }

  bool get _isAuthenticated => AppSupabaseClient.isAuthenticated;

  void _browseMatches() => Navigator.of(context).pushNamed(AppRoutes.relativeIntake);

  void _createBiodata() {
    AppLogger.debug('UserTypeSelectionScreen', '_createBiodata called. isAuthenticated: $_isAuthenticated');
    if (_isAuthenticated) {
      Navigator.of(context).pushNamed(AppRoutes.biodataCreation);
    } else {
      _tabController.animateTo(0);
    }
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
            // Layer 0: Multi-Tone Ultra-Rich Ambient Mesh Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.crimsonBlack,
                            const Color(0xFF14070A),
                            theme.scaffoldBackgroundColor,
                            const Color(0xFF0F0A0E),
                          ]
                        : [
                            AppColors.roseBlush,
                            const Color(0xFFFFF0F3),
                            AppColors.rosePinkLight,
                            theme.scaffoldBackgroundColor,
                          ],
                  ),
                ),
              ),
            ),

            // Layer 1: Ambient Floating Aurora Glow Orbs
            Positioned(
              top: -14.h,
              right: -18.w,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: _auroraOrb(65.w, primary.withValues(alpha: isDark ? 0.22 : 0.14)),
              ),
            ),
            Positioned(
              top: 25.h,
              left: -20.w,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: _auroraOrb(50.w, AppColors.categoryAstro.withValues(alpha: isDark ? 0.12 : 0.08)),
              ),
            ),
            Positioned(
              bottom: -12.h,
              left: -10.w,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: _auroraOrb(60.w, AppColors.categoryAstroDark.withValues(alpha: isDark ? 0.18 : 0.10)),
              ),
            ),

            // Layer 2: Floating Constellation Particles
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ConstellationParticlePainter(
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

            // Layer 3: Main Layout Surface
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(4.5.w, 1.2.h, 4.5.w, 0.6.h),
                child: Column(
                  children: [
                    // 1. Top Header (Trust Badge & Lang Switcher)
                    SlideTransition(
                      position: _headerSlide,
                      child: FadeTransition(
                        opacity: _headerFade,
                        child: _buildTopHeaderBar(theme, isDark, l10n, primary),
                      ),
                    ),
                    SizedBox(height: 1.4.h),

                    // 2. Hero Section (Pulsing Multi-Halo Brand Emblem & Global Headlines)
                    SlideTransition(
                      position: _heroSlide,
                      child: FadeTransition(
                        opacity: _heroFade,
                        child: _buildHero(theme, isDark, l10n, primary),
                      ),
                    ),

                    // Unified gap that shifts the entire tabs + screen section further down
                    SizedBox(height: 5.5.h),

                    // 3. Segmented 2-Tab Switcher (Connected Card Architecture)
                    SlideTransition(
                      position: _tabsSlide,
                      child: FadeTransition(
                        opacity: _tabsFade,
                        child: _buildSegmentedTabBar(theme, isDark, l10n, primary),
                      ),
                    ),
                    SizedBox(height: 1.4.h),

                    // 4. Tab View Contents (Card Body that seamlessly connects with selected tab)
                    Expanded(
                      child: SlideTransition(
                        position: _bodySlide,
                        child: FadeTransition(
                          opacity: _bodyFade,
                          child: TabBarView(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              // ── TAB 0: Existing Member (Direct Login) ──
                              _buildExistingMemberTab(theme, isDark, l10n, primary),

                              // ── TAB 1: New Member (Pathway Choices) ──
                              _buildNewMemberTab(theme, isDark, l10n, primary),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 0.8.h),

                    // 5. Support Footer Bar
                    FadeTransition(
                      opacity: _footerFade,
                      child: _buildSupportFooter(theme, isDark, l10n, primary),
                    ),
                    SizedBox(height: 0.4.h),
                  ],
                ),
              ),
            ),
          ],
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
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 1. TOP BAR — Language Switcher
  // ══════════════════════════════════════════════
  Widget _buildTopHeaderBar(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    return Align(
      alignment: Alignment.centerRight,
      child: TactilePressable(
        onTap: () {
          HapticFeedback.lightImpact();
          _showLanguageSelectionModal(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 0.8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withValues(alpha: isDark ? 0.25 : 0.14),
                primary.withValues(alpha: isDark ? 0.12 : 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: primary.withValues(alpha: isDark ? 0.40 : 0.25),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: isDark ? 0.20 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language_rounded, size: 16, color: primary),
              SizedBox(width: 1.5.w),
              Text(
                l10n?.changeLanguage ?? 'भाषा',
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontWeight: AppTypography.bold,
                  fontSize: AppTypography.labelSmall,
                  color: primary,
                ),
              ),
              const SizedBox(width: 3),
              Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: primary),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 2. HERO — Brand Emblem with Luminous Halo (Dynamic Tab Reactive)
  // ══════════════════════════════════════════════
  Widget _buildHero(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    final lang = Localizations.localeOf(context).languageCode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pulsing Dual Ring Halo Emblem (Enlarged for prominent brand presence)
        ScaleTransition(
          scale: _pulseAnimation,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow Halo
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: _glowAnimation.value * 0.55),
                          blurRadius: 26,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: AppColors.categoryAstro.withValues(alpha: _glowAnimation.value * 0.40),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  // Inner Emblem Container
                  Container(
                    width: 17.5.w,
                    height: 17.5.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface,
                      border: Border.all(
                        color: primary.withValues(alpha: 0.90),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const ClipOval(child: AppLogoImage()),
                  ),
                ],
              );
            },
          ),
        ),

        SizedBox(width: 3.5.w),

        // Brand Headlines & Community Badge (Dynamic tab reactive with overflow safety)
        Expanded(
          child: AnimatedBuilder(
            animation: _tabController.animation ?? _tabController,
            builder: (context, child) {
              final double animValue = _tabController.animation?.value ?? _tabController.index.toDouble();
              final isExistingTab = animValue < 0.5;

              final dynamicTitle = isExistingTab
                  ? (lang == 'mr' ? 'पुन्हा स्वागत आहे! 👋' : 'Welcome Back! 👋')
                  : (l10n?.welcomeToBanjaraBio ?? 'Welcome to BanjaraBio!');

              final dynamicSubtitle = isExistingTab
                  ? (lang == 'mr' ? 'आपल्या खात्यात प्रवेश करा' : 'Sign in to your account')
                  : 'बंजारा समाजाचे #1 बायोडेटा प्लॅटफॉर्म';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        dynamicTitle,
                        key: ValueKey<String>(dynamicTitle),
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontWeight: AppTypography.black,
                          fontSize: AppTypography.titleMedium + 2.0,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.3,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 0.4.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.35.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primary.withValues(alpha: isDark ? 0.25 : 0.12),
                            AppColors.categoryAstro.withValues(alpha: isDark ? 0.20 : 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(isExistingTab ? '🔐' : '🚩', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Text(
                            dynamicSubtitle,
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.bodySmall - 1.0,
                              color: primary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 3. SEGMENTED TAB SWITCHER (Billion-Dollar Animated Liquid Switcher with Notch)
  // ══════════════════════════════════════════════
  Widget _buildSegmentedTabBar(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    final lang = Localizations.localeOf(context).languageCode;
    final tab0Label = lang == 'mr' ? 'हयात सदस्य' : 'Existing Member';
    final tab1Label = lang == 'mr' ? 'नवीन सदस्य' : 'New Member';

    return AnimatedBuilder(
      animation: _tabController.animation ?? _tabController,
      builder: (context, child) {
        final double animValue = _tabController.animation?.value ?? _tabController.index.toDouble();

        return Container(
          height: 52,
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1B0F13).withValues(alpha: 0.90)
                : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : primary.withValues(alpha: 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : primary).withValues(alpha: isDark ? 0.40 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 2;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // 🌊 1. Smooth Animated Liquid Indicator Pill with Notch Pointer
                  Positioned(
                    left: animValue * tabWidth,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primary,
                            Color.lerp(primary, AppColors.crimsonMaroon, 0.40) ?? primary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: isDark ? 0.50 : 0.35),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🏷️ 2. Interactive Animated Tab Headers (Centered Vertically and Horizontally)
                  Row(
                    children: [
                      // ── Tab 0: Existing Member ──
                      Expanded(
                        child: TactilePressable(
                          onTap: () {
                            if (_tabController.index != 0) {
                              HapticFeedback.selectionClick();
                              _tabController.animateTo(0);
                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: _buildAnimatedTabItem(
                              icon: Icons.login_rounded,
                              label: tab0Label,
                              isSelected: animValue < 0.5,
                              selectedFraction: (1.0 - animValue).clamp(0.0, 1.0),
                              theme: theme,
                              isDark: isDark,
                              primary: primary,
                            ),
                          ),
                        ),
                      ),

                      // ── Tab 1: New Member ──
                      Expanded(
                        child: TactilePressable(
                          onTap: () {
                            if (_tabController.index != 1) {
                              HapticFeedback.selectionClick();
                              _tabController.animateTo(1);
                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: _buildAnimatedTabItem(
                              icon: Icons.person_add_alt_1_rounded,
                              label: tab1Label,
                              badge: 'FREE',
                              isSelected: animValue >= 0.5,
                              selectedFraction: animValue.clamp(0.0, 1.0),
                              theme: theme,
                              isDark: isDark,
                              primary: primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTabItem({
    required IconData icon,
    required String label,
    String? badge,
    required bool isSelected,
    required double selectedFraction,
    required ThemeData theme,
    required bool isDark,
    required Color primary,
  }) {
    final textColor = Color.lerp(
      theme.colorScheme.onSurfaceVariant,
      Colors.white,
      selectedFraction,
    );

    final scale = 0.94 + (selectedFraction * 0.08);

    return Transform.scale(
      scale: scale,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animated scale & glow
            Icon(
              icon,
              size: 18,
              color: textColor,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontWeight: isSelected ? AppTypography.extraBold : AppTypography.bold,
                  fontSize: AppTypography.bodySmall,
                  color: textColor,
                  letterSpacing: 0.2,
                  height: 1.0,
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.goldTint100
                      : AppColors.categoryAstro.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontWeight: AppTypography.black,
                    fontSize: 8.5,
                    color: isSelected ? AppColors.amberDarkestText : AppColors.categoryAstroDark,
                    letterSpacing: 0.4,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 4. TAB 0 VIEW: EXISTING MEMBER (Direct Auth with Animated Card Container)
  // ══════════════════════════════════════════════
  Widget _buildExistingMemberTab(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 0.6.h),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 1.8.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.canvasDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? primary.withValues(alpha: 0.30 + (_pulseAnimation.value - 1.0) * 0.3)
                        : primary.withValues(alpha: 0.20 + (_pulseAnimation.value - 1.0) * 0.2),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : primary).withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 18 + (_pulseAnimation.value - 1.0) * 8,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const AuthenticationScreen(
                  embedded: true,
                ),
              );
            },
          ),
          SizedBox(height: 1.0.h),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // 5. TAB 1 VIEW: NEW MEMBER (Pathway Choices)
  // ══════════════════════════════════════════════
  Widget _buildNewMemberTab(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 0.4.h),
          // Option 1: Search Matches for Relatives
          _buildSearchMatchesCard(theme, isDark, l10n, primary),
          SizedBox(height: 1.4.h),

          // Option 2: Create My Biodata (High Conversion Hero Card with Glint Sheen)
          _buildCreateBiodataCard(theme, isDark, l10n, primary),
        ],
      ),
    );
  }

  /// CARD 1: Search Matches (Instant Discovery / Relative Search Card)
  Widget _buildSearchMatchesCard(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    final cardTitle = l10n?.searchMatchesForRelativesTitle ?? 'Find Matches for Relatives';
    final cardSub = l10n?.searchMatchesForRelativesSubtitle ??
        'Search thousands of verified profiles for son, daughter, brother or sister directly without creating a profile.';
    final ctaText = l10n?.searchMatchesForRelativesCta ?? 'Find Matches for Relatives 👉';

    return TactilePressable(
      onTap: _browseMatches,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 1.8.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.canvasDark : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? AppColors.sapphireBlue.withValues(alpha: 0.40 + (_pulseAnimation.value - 1.0) * 0.4)
                    : AppColors.sapphireBlue.withValues(alpha: 0.30 + (_pulseAnimation.value - 1.0) * 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sapphireBlue.withValues(alpha: isDark ? 0.25 : 0.08),
                  blurRadius: 16 + (_pulseAnimation.value - 1.0) * 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        cardTitle,
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontWeight: AppTypography.extraBold,
                          fontSize: AppTypography.bodyLarge,
                          color: theme.colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.sapphireBlue.withValues(alpha: 0.22),
                            AppColors.sapphireBlue.withValues(alpha: 0.08),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.sapphireBlue.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.person_search_rounded,
                        size: 20,
                        color: AppColors.sapphireBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.4.h),
                Text(
                  cardSub,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    fontWeight: AppTypography.regular,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Wrap(
                  spacing: 2.0.w,
                  runSpacing: 0.5.h,
                  children: [
                    _featureChip(theme, l10n?.chipNoAccount ?? '⚡ No Account Needed', isDark),
                    _featureChip(theme, l10n?.chipQuickFilter ?? '🔍 1-Min Search', isDark),
                    _featureChip(theme, l10n?.chipFreeAccess ?? '⭐ 100% Free Access', isDark),
                  ],
                ),
                SizedBox(height: 1.2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 1.0.h),
                  decoration: BoxDecoration(
                    color: AppColors.sapphireBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.sapphireBlue.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_rounded, size: 16, color: AppColors.sapphireBlue),
                      SizedBox(width: 2.w),
                      Text(
                        ctaText,
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontWeight: AppTypography.bold,
                          fontSize: AppTypography.bodyMedium,
                          color: AppColors.sapphireBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// CARD 2: Create My Biodata (Luxurious Primary Hero Card with Animated Sheen)
  Widget _buildCreateBiodataCard(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    final cardTitle = l10n?.createBiodataForSelfOrCandidateTitle ?? (l10n?.createMyBiodata ?? 'Create My Biodata');
    final cardSub = l10n?.createBiodataForSelfOrCandidateSubtitle ??
        'Create official biodata to view photos, mobile numbers & download PDF.';
    final ctaText = l10n?.loginAndCreateBiodataCta ?? 'Login & Create Biodata ✨';

    return AnimatedBuilder(
      animation: _glintController,
      builder: (context, child) {
        final glintValue = _glintController.value;

        return TactilePressable(
          onTap: _createBiodata,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 1.8.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.crimsonMaroon,
                      AppColors.wineRed,
                      AppColors.wineDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.categoryAstro, width: 1.8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.crimsonDeep.withValues(alpha: 0.50),
                      blurRadius: 22,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            cardTitle,
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontWeight: AppTypography.extraBold,
                              fontSize: AppTypography.bodyLarge,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.22),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      cardSub,
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        fontWeight: AppTypography.regular,
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    _heroBenefitRow(theme, '✨', l10n?.benefitPdfBiodata ?? 'Create Beautiful PDF Biodata in 2 Mins'),
                    SizedBox(height: 0.4.h),
                    _heroBenefitRow(theme, '📱', l10n?.benefitShareWhatsApp ?? 'Share Directly on WhatsApp with Families'),
                    SizedBox(height: 0.4.h),
                    _heroBenefitRow(theme, '🛡️', l10n?.benefitVerifiedProfiles ?? '100% Verified Community Profiles'),
                    SizedBox(height: 1.2.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 1.2.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.goldSoft, AppColors.categoryAstro],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.categoryAstro.withValues(alpha: 0.45),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: const Icon(Icons.auto_awesome_rounded, size: 17, color: AppColors.amberBgDark),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            ctaText,
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontWeight: AppTypography.black,
                              fontSize: AppTypography.bodyMedium,
                              color: AppColors.amberBgDark,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: CustomPaint(
                      painter: _SheenGlintPainter(percent: glintValue),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        style: TextStyle(
          fontSize: AppTypography.labelSmall,
          fontWeight: AppTypography.semiBold,
          color: isDark ? Colors.white70 : AppColors.slate700,
        ),
      ),
    );
  }

  Widget _heroBenefitRow(ThemeData theme, String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppTypography.bodySmall,
              fontWeight: AppTypography.medium,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // 6. FOOTER (Balanced Equal Size WhatsApp & Instagram Support)
  // ══════════════════════════════════════════════
  Widget _buildSupportFooter(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    return Row(
      children: [
        // 💬 1. WhatsApp Support Action Pill (Expanded for equal 50/50 width)
        Expanded(
          child: TactilePressable(
            onTap: _launchWhatsApp,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.1.h),
              decoration: BoxDecoration(
                color: AppColors.whatsapp.withValues(alpha: isDark ? 0.16 : 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.whatsapp.withValues(alpha: isDark ? 0.45 : 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.whatsapp.withValues(alpha: isDark ? 0.20 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/whatsapp_icon.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 2.2.w),
                  Flexible(
                    child: Text(
                      'WhatsApp',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFontFamily,
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.bodyMedium,
                        color: AppColors.whatsapp,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(width: 3.0.w),

        // 📸 2. Instagram Official Page Pill (Expanded for equal 50/50 width)
        Expanded(
          child: TactilePressable(
            onTap: _launchInstagram,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.1.h),
              decoration: BoxDecoration(
                color: AppColors.instagramPurple.withValues(alpha: isDark ? 0.16 : 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.instagramPurple.withValues(alpha: isDark ? 0.45 : 0.30),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.instagramPurple.withValues(alpha: isDark ? 0.20 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/instagram_icon.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 2.2.w),
                  Flexible(
                    child: Text(
                      'Instagram',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFontFamily,
                        fontWeight: AppTypography.extraBold,
                        fontSize: AppTypography.bodyMedium,
                        color: AppColors.instagramPurple,
                        letterSpacing: 0.2,
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
}

/// 🌟 Model for Ambient Constellation Particles
class _FloatingParticle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final bool isGold;

  _FloatingParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.isGold,
  });
}

/// 🌟 Custom Painter for Floating Ambient Constellation Particles
class _ConstellationParticlePainter extends CustomPainter {
  final double progress;
  final List<_FloatingParticle> particles;
  final bool isDark;
  final Color primaryColor;

  _ConstellationParticlePainter({
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
  bool shouldRepaint(covariant _ConstellationParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 🌟 Shimmering Diagonal Light-Sweep Glint Painter
class _SheenGlintPainter extends CustomPainter {
  final double percent;

  _SheenGlintPainter({required this.percent});

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
          Colors.white.withValues(alpha: 0.25),
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
  bool shouldRepaint(covariant _SheenGlintPainter oldDelegate) =>
      oldDelegate.percent != percent;
}
