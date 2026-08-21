import 'package:banjarabio/core/constants/app_typography.dart';
import 'dart:math' as math;
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/constants/biodata_templates.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/razorpay_repository.dart';
import 'package:banjarabio/core/services/pdf_assets_service.dart';
import 'package:banjarabio/core/services/pdf/biodata_translations.dart';
import 'package:banjarabio/core/services/pdf_service.dart';
import 'package:banjarabio/core/providers/profile_providers.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/routes/app_routes.dart';
import 'package:banjarabio/core/models/subscription_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/core/services/biodata_preload_service.dart';
import 'package:banjarabio/core/services/app_logger.dart';
import 'package:banjarabio/core/services/analytics_service.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/presentation/biodata_pdf_screen/widgets/zepto_biodata_loader.dart';

/// 🌟 WORLD-CLASS ANIMATED BIODATA STUDIO SCREEN
///
/// Features:
/// 1. 4 Auto-Fitting Tabs Pinned Under AppBar (Preview • Themes(10) • Customize • Lang)
/// 2. Live Zoomable 2-Page A4 PDF Canvas with Floating Actions (WhatsApp Share, Print, Download)
/// 3. Interactive Banjara Royal Templates Studio (10 Handcrafted Cultural Themes)
/// 4. PDF Customizer & Privacy Toggles (Blessing Mantra Presets, Income/Kundali/Phone Switches, Alt Phone)
/// 5. Multi-Language Real-Time Translation Switcher (English, Marathi, Hindi, Telugu, Kannada)
class BiodataPdfScreen extends ConsumerStatefulWidget {
  const BiodataPdfScreen({super.key});

  @override
  ConsumerState<BiodataPdfScreen> createState() => _BiodataPdfScreenState();
}

class _BiodataPdfScreenState extends ConsumerState<BiodataPdfScreen>
    with TickerProviderStateMixin {
  late final ProfileRepository _profileRepository;
  final RazorpayRepository _razorpayRepository = RazorpayRepository();

  TabController? _tabController;
  late final AnimationController _fabPulseController;
  late final AnimationController _fabShimmerController;

  ProfileModel? _profile;
  bool _isLoading = true;
  bool _isGeneratingPdf = false;
  bool _isPaid = true;
  bool _isPaymentInProgress = false;
  Uint8List? _pdfData;
  int _selectedTemplateIndex = 0;
  String _selectedLanguage = 'English';

  // ─── Customizer & Privacy State ───
  String _selectedMantra = '॥ जय सेवालाल ॥   ॥ श्री गणेशाय नमः ॥';
  final TextEditingController _customMantraController = TextEditingController();
  bool _isCustomMantra = false;
  bool _showAnnualIncome = true;
  bool _showBirthTime = true;
  bool _showPhoneNumber = true;
  final TextEditingController _alternatePhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView('biodata_studio_screen');
    _profileRepository = ref.read(profileRepositoryProvider);
    _initTabController();
    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _fabShimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    // ⚡ Instant Cache & Background Preload Hydration: Render UI & PDF in 0.00ms!
    final preloader = BiodataPreloadService.instance;
    if (preloader.cachedProfile != null) {
      _profile = preloader.cachedProfile;
      _isLoading = false;
    }
    if (preloader.cachedPdfData != null) {
      _pdfData = preloader.cachedPdfData;
      _isLoading = false;
    }

    if (_profile == null) {
      final cachedJson = LocalCacheService().getOwnProfile();
      if (cachedJson != null) {
        try {
          _profile = ProfileModel.fromJson(cachedJson);
          _isLoading = false;
        } catch (_) {}
      }
    }

    _loadData();
  }

  void _initTabController() {
    _tabController ??= TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _fabPulseController.dispose();
    _fabShimmerController.dispose();
    _tabController?.dispose();
    _customMantraController.dispose();
    _alternatePhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool forceRefreshProfile = false}) async {
    // Only show full screen loader if we don't even have a cached profile
    if (_profile == null) {
      setState(() => _isLoading = true);
    } else if (_pdfData == null && !_isGeneratingPdf) {
      _generatePdf();
    }

    try {
      final response = await _profileRepository.getOwnProfile(
        forceRefresh: forceRefreshProfile,
      );
      await response.fold(
        onSuccess: (profile) async {
          if (profile != null) {
            final isNewProfile = _profile == null || _profile!.id != profile.id || forceRefreshProfile;
            _profile = profile;
            _isPaid = true;
            
            // Set initial language from app locale if not explicitly picked
            final locale = Localizations.maybeLocaleOf(context);
            if (locale != null && _selectedLanguage.isEmpty) {
              _selectedLanguage = BiodataTranslations.fromLocale(locale.languageCode);
            }

            if (mounted && _isLoading) {
              setState(() => _isLoading = false);
            }

            if (_pdfData == null || isNewProfile) {
              _generatePdf();
            }
          }
        },
        onFailure: (_) {},
      );
    } catch (e) {
      AppLogger.error('BiodataPdfScreen', 'Error loading data: $e');
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generatePdf() async {
    if (_profile == null) return;
    if (_isGeneratingPdf) return;

    if (mounted) setState(() => _isGeneratingPdf = true);

    try {
      final assets = await PdfAssetsService.instance.getPdfAssets(_profile!);
      final template = kBiodataTemplates[_selectedTemplateIndex];

      // Load template background image via centralized preloader cache
      final templateImageBytes = await BiodataPreloadService.instance.loadTemplateImage(template.assetPath);

      final activeMantra = _isCustomMantra && _customMantraController.text.trim().isNotEmpty
          ? _customMantraController.text.trim()
          : _selectedMantra;

      final data = await PdfService.generateBiodataPdfIsolate(
        _profile!,
        isLocked: !_isPaid,
        logoBytes: assets.logoBytes,
        profilePhotoBytes: assets.profilePhotoBytes,
        templateImageBytes: templateImageBytes,
        accentColor: template.accentColor,
        language: _selectedLanguage,
        marginLeft: template.marginLeft,
        marginTop: template.marginTop,
        marginRight: template.marginRight,
        marginBottom: template.marginBottom,
        headerMantra: activeMantra,
        showAnnualIncome: _showAnnualIncome,
        showBirthTime: _showBirthTime,
        showPhoneNumber: _showPhoneNumber,
        alternatePhoneNumber: _alternatePhoneController.text.trim().isNotEmpty
            ? _alternatePhoneController.text.trim()
            : null,
      );

      if (mounted) {
        setState(() {
          _pdfData = data;
          _isGeneratingPdf = false;
        });
        if (_selectedTemplateIndex == 0 && _selectedLanguage == 'English') {
          BiodataPreloadService.instance.updateCachedPdf(data);
        }
      }
    } catch (e) {
      AppLogger.error('BiodataPdfScreen', 'Error generating PDF: $e');
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  Future<void> _onTemplateSelected(int index) async {
    if (index == _selectedTemplateIndex) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTemplateIndex = index;
      _pdfData = null; // Show smooth skeleton on canvas while generating
    });
    _generatePdf();
    Fluttertoast.showToast(
      msg: 'Applied ${kBiodataTemplates[index].name} Theme ✨',
      backgroundColor: const Color(0xFFBE123C),
      textColor: Colors.white,
    );
  }

  Future<void> _onLanguageSelected(String lang) async {
    if (lang == _selectedLanguage) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedLanguage = lang;
      _pdfData = null; // Show smooth skeleton on canvas while generating
    });
    _generatePdf();
    Fluttertoast.showToast(
      msg: 'Biodata Language: $lang 🚩',
      backgroundColor: const Color(0xFF10B981),
      textColor: Colors.white,
    );
  }

  Future<void> _startPayment() async {
    if (_isPaymentInProgress || _profile == null) return;
    setState(() => _isPaymentInProgress = true);

    final response = await _razorpayRepository.startPayment(
      planType: PlanType.biodata_unlock,
    );

    if (mounted) {
      setState(() => _isPaymentInProgress = false);
      if (response.isSuccess) {
        await _loadData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.paymentSuccessfulPdfUnlocked ?? 'Payment Successful! PDF Unlocked.'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (!response.errorMessage.toLowerCase().contains('cancelled')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.paymentFailedError(response.errorMessage) ?? 'Payment Failed: ${response.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tabController = _tabController ??= TabController(length: 3, vsync: this);

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
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
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        titleWidget: Text(
          AppLocalizations.of(context)?.biodata ?? 'Biodata',
          style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
            color: theme.appBarTheme.foregroundColor ?? Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: _buildLanguagePill(theme, isDark),
            ),
          ),
        ],
        bottom: _buildSlidingCapsuleTabBar(theme, isDark, tabController),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE123C)),
              ),
            )
          : _profile == null
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)?.profileNotFound ?? 'Profile not found',
                  ),
                )
              : Builder(
                  builder: (context) {
                    final double bottomInset = MediaQuery.paddingOf(context).bottom;
                    final double fabBottomPosition = 4.h + bottomInset;

                    return Stack(
                      children: [
                        TabBarView(
                          controller: tabController,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildPreviewTab(theme, isDark),
                            _buildTemplatesTab(theme, isDark),
                            _buildCustomizeTab(theme, isDark),
                          ],
                        ),

                        // ─── Floating Share Button (Elevated above CustomBottomBar) ───
                        Positioned(
                          right: 16,
                          bottom: fabBottomPosition,
                          child: _buildShareFab(theme, isDark),
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔘 1. TOP ANIMATED SLIDING CAPSULE TAB BAR (ATTACHED UNDER APPBAR)
  // ═══════════════════════════════════════════════════════════════════════════
  PreferredSizeWidget _buildSlidingCapsuleTabBar(
    ThemeData theme,
    bool isDark,
    TabController controller,
  ) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      {'icon': Icons.picture_as_pdf_rounded, 'label': l10n?.preview ?? 'Preview'},
      {'icon': Icons.palette_rounded, 'label': l10n?.themesCount('10') ?? 'Themes (10)'},
      {'icon': Icons.tune_rounded, 'label': l10n?.customize ?? 'Customize'},
    ];

    return PreferredSize(
      preferredSize: const Size.fromHeight(54),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        color: theme.appBarTheme.backgroundColor ??
            (isDark ? const Color(0xFF13131A) : Colors.white),
        child: Container(
          height: 44,
          padding: const EdgeInsets.all(3.5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A26) : const Color(0xFFE2E8F0).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: controller,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerHeight: 0,
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            splashBorderRadius: BorderRadius.circular(18),
            indicator: const _BillionDollarTabIndicator(),
            labelColor: Colors.white,
            unselectedLabelColor: isDark
                ? const Color(0xFFCBD5E1)
                : const Color(0xFF334155),
            labelStyle: TextStyle(
              fontSize: AppTypography.bodySmall,
              fontWeight: AppTypography.black,
              letterSpacing: 0.2,
              shadows: [
                const Shadow(
                  color: Colors.black45,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: AppTypography.bodySmall,
              fontWeight: AppTypography.bold,
              letterSpacing: 0.1,
            ),
            tabs: tabs.map((t) {
              return Tab(
                height: 37,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(t['icon'] as IconData, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      t['label'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📄 TAB 0: LIVE PDF PREVIEW CANVAS + FLOATING ACTION HUB
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPreviewTab(ThemeData theme, bool isDark) {
    final activeAccent = kBiodataTemplates[_selectedTemplateIndex].accentColor;

    return Stack(
      children: [
        // Royal Gallery Easel Canvas with Animated Running Aura Border
        Positioned.fill(
          child: _RoyalAuraBorderContainer(
            isDark: isDark,
            accentColor: activeAccent,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _pdfData != null
                  ? KeyedSubtree(
                      key: ValueKey('pdf_preview_${_selectedTemplateIndex}_$_selectedLanguage'),
                      child: PdfPreview(
                        build: (format) => _pdfData!,
                        useActions: false,
                        canChangePageFormat: false,
                        pdfFileName: '${_profile?.fullName ?? "Candidate"}_BanjaraBio_Biodata.pdf',
                      ),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('pdf_loading_skeleton'),
                      child: _buildPdfLoadingSkeleton(theme, isDark),
                    ),
            ),
          ),
        ),

        // Locked Guest Overlay
        if (!_isPaid) _buildLockedGuestOverlay(theme, isDark),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💎 ZEPTO/SWIGGY-GRADE ANIMATED MATRIMONIAL CRAFTING ENGINE LOADER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPdfLoadingSkeleton(ThemeData theme, bool isDark) {
    return ZeptoBiodataLoader(
      selectedTemplateIndex: _selectedTemplateIndex,
      selectedMantra: _selectedMantra,
      isDark: isDark,
    );
  }

  Widget _buildLockedGuestOverlay(ThemeData theme, bool isDark) {
    return Positioned.fill(
      child: Container(
        color: isDark ? Colors.black87 : Colors.white.withValues(alpha: 0.88),
        child: BackdropFilter(
          filter: ColorFilter.mode(Colors.black.withValues(alpha: 0.1), BlendMode.srcOver),
          child: Center(
            child: Container(
              margin: EdgeInsets.all(6.w),
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E28) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBE123C).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 32,
                      color: Color(0xFFBE123C),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    AppLocalizations.of(context)?.unlockPremiumBiodata ?? 'Unlock Premium Biodata',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: AppTypography.black,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    AppLocalizations.of(context)?.downloadWatermarkFreeBiodataDesc ?? 'Download watermark-free high definition 2-Page Biodata in all formats.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTypography.labelSmall,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.biodataCreation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBE123C),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)?.createFreeProfile100PercentFree ?? '✨ Create Free Profile (100% Free)'),
                  ),
                  SizedBox(height: 1.h),
                  OutlinedButton(
                    onPressed: _isPaymentInProgress ? null : _startPayment,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isPaymentInProgress
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            AppLocalizations.of(context)?.payInstantUnlock(SubscriptionConfig.biodataUnlock.price.toString()) ?? 'Pay ₹${SubscriptionConfig.biodataUnlock.price} Instant Unlock',
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 TAB 1: ROYAL THEMES STUDIO (10 TEMPLATES)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTemplatesTab(ThemeData theme, bool isDark) {
    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 12.h),
          children: [
            // Header Banner
            Container(
              padding: EdgeInsets.all(3.5.w),
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF2C1018), Color(0xFF1E0A12)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFBE123C).withValues(alpha: isDark ? 0.3 : 0.2),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFBE123C), Color(0xFF9F1239)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)?.royalBanjaraTemplatesWithCount('10') ?? '10 Royal Banjara Templates',
                          style: TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            fontWeight: AppTypography.black,
                            color: isDark ? Colors.white : const Color(0xFF881337),
                          ),
                        ),
                        SizedBox(height: 0.2.h),
                        Text(
                          AppLocalizations.of(context)?.tapAnyThemeToApply ?? 'Tap any theme to instantly apply it to your biodata.',
                          style: TextStyle(
                            fontSize: AppTypography.labelTiny,
                            color: isDark ? Colors.white70 : const Color(0xFF9F1239),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // Template Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: kBiodataTemplates.length,
              itemBuilder: (context, index) {
                final template = kBiodataTemplates[index];
                final isSelected = index == _selectedTemplateIndex;

                String badgeText;
                if (index == 0) {
                  badgeText = '👑 VIP Classic';
                } else if (index == 1) {
                  badgeText = '🚩 Gor Heritage';
                } else if (index == 2) {
                  badgeText = '🌿 Lotus Green';
                } else if (index == 3) {
                  badgeText = '🦚 Peacock Blue';
                } else if (index == 4) {
                  badgeText = '🌸 Mandala Rose';
                } else if (index == 5) {
                  badgeText = '🪔 Saffron Diya';
                } else if (index == 6) {
                  badgeText = '💜 Paisley Purple';
                } else if (index == 7) {
                  badgeText = '🏛️ Divine Teal';
                } else if (index == 8) {
                  badgeText = '🍷 Burgundy Lattice';
                } else {
                  badgeText = '✨ Ivory Classic';
                }

                return TactilePressable(
                  onTap: () => _onTemplateSelected(index),
                  pressedScale: 0.95,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B1B24) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF59E0B)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.18)
                                : const Color(0xFFCBD5E1)),
                        width: isSelected ? 2.5 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.45)
                              : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                          blurRadius: isSelected ? 14 : 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Thumbnail Image
                          Image.asset(
                            template.assetPath,
                            fit: BoxFit.cover,
                          ),

                          // Gradient Bottom Overlay for Text Legibility
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 70,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.88),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Badge (Top Left)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                                      : Colors.white24,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  color: const Color(0xFFFFD700),
                                  fontSize: AppTypography.labelTiny,
                                  fontWeight: AppTypography.extraBold,
                                ),
                              ),
                            ),
                          ),

                          // Selection Ring Indicator (Top Right)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: isSelected
                                ? Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFF59E0B), Color(0xFFBE123C)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: const Color(0xFFFFD700),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                                          blurRadius: 6,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 13,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(alpha: 0.35),
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFFCBD5E1),
                                        width: 1.8,
                                      ),
                                    ),
                                  ),
                          ),

                          // Bottom Info (Name & Accent Dot)
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: Row(
                              children: [
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: template.accentColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 1.2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    template.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppTypography.labelSmall,
                                      fontWeight: AppTypography.extraBold,
                                    ),
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
              },
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ⚙️ TAB 2: PDF CUSTOMIZER & PRIVACY TOGGLES (ANIMATED LUXURY EDITION)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCustomizeTab(ThemeData theme, bool isDark) {
    final mantraPresets = [
      {
        'mantra': '॥ जय सेवालाल ॥   ॥ श्री गणेशाय नमः ॥',
        'title': 'Sant Sevalal Maharaj & Lord Ganesha',
        'subtitle': 'Most auspicious & widely used traditional blessing',
        'icon': '🚩',
        'badge': '👑 Most Popular',
      },
      {
        'mantra': '॥ श्री सेवालाल महाराज प्रसन्न ॥',
        'title': 'Shree Sevalal Maharaj Prasanna',
        'subtitle': 'Solemn blessing of our supreme spiritual guide',
        'icon': '🪔',
        'badge': 'Heritage',
      },
      {
        'mantra': '॥ श्री जगदंबा प्रसन्न ॥',
        'title': 'Shree Jagadamba Prasanna',
        'subtitle': 'Divine blessing of Kuldevi Maa Jagadamba Bhavani',
        'icon': '🔱',
        'badge': 'Kuldevi Divine',
      },
      {
        'mantra': '॥ ॐ श्री गणेशाय नमः ॥',
        'title': 'Om Shree Ganeshaya Namah',
        'subtitle': 'Vedic invocation for auspicious new beginnings',
        'icon': '🌸',
        'badge': 'Vedic Classic',
      },
      {
        'mantra': '॥ श्री तिरुपती बालाजी प्रसन्न ॥',
        'title': 'Shree Tirupati Balaji Prasanna',
        'subtitle': 'Sacred blessing of Lord Venkateshwara Balaji',
        'icon': '✨',
        'badge': 'Govinda Divine',
      },
    ];

    final customMantraSuggestions = [
      '॥ जय सेवालाल ॥',
      '॥ श्री जगदंबा प्रसन्न ॥',
      '॥ श्री गणेशाय नमः ॥',
      '॥ ॐ नमः शिवाय ॥',
      '॥ श्री सामकी माता प्रसन्न ॥',
    ];

    return Stack(
      children: [
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(4.w, 1.8.h, 4.w, 13.h),
          children: [
            // 🌟 1. Holographic Feature Header Banner
            _buildAnimatedCustomizeItem(
              index: 0,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E1430), Color(0xFF120C1E)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
                        ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF9333EA).withValues(alpha: isDark ? 0.35 : 0.25),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9333EA).withValues(alpha: isDark ? 0.18 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9333EA).withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                    ),
                    SizedBox(width: 3.5.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)?.pdfDisplayStudio ?? 'PDF Display Studio',
                                style: TextStyle(
                                  fontSize: AppTypography.bodyMedium,
                                  fontWeight: AppTypography.black,
                                  color: isDark ? Colors.white : const Color(0xFF581C87),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.bolt_rounded, size: 10, color: Color(0xFF10B981)),
                                    Text(
                                      AppLocalizations.of(context)?.liveSync ?? 'LIVE SYNC',
                                      style: TextStyle(
                                        fontSize: AppTypography.labelTiny,
                                        fontWeight: AppTypography.black,
                                        color: const Color(0xFF10B981),
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.4.h),
                          Text(
                            AppLocalizations.of(context)?.pdfDisplayStudioDesc ?? 'Customize header deity blessings and toggle confidential fields on your shareable PDF.',
                            style: TextStyle(
                              fontSize: AppTypography.labelSmall,
                              color: isDark ? const Color(0xFFD8B4FE) : const Color(0xFF6B21A8),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // 🪔 2. Header Blessing / Deity Mantra Choice
            _buildAnimatedCustomizeItem(
              index: 1,
              child: _buildCustomizerCard(
                theme: theme,
                isDark: isDark,
                title: AppLocalizations.of(context)?.headerBlessingTitle ?? '🪔 Header Blessing / Deity Mantra',
                subtitle: AppLocalizations.of(context)?.headerBlessingSubtitle ?? 'Select which divine blessing is engraved at the top of your PDF',
                children: [
                  ...mantraPresets.map((preset) {
                    final mantra = preset['mantra']!;
                    final isSelected = !_isCustomMantra && _selectedMantra == mantra;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TactilePressable(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isCustomMantra = false;
                            _selectedMantra = mantra;
                          });
                          _generatePdf();
                        },
                        pressedScale: 0.98,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? (isDark
                                    ? const LinearGradient(
                                        colors: [Color(0xFF2C1018), Color(0xFF1A0A10)],
                                      )
                                    : const LinearGradient(
                                        colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                                      ))
                                : null,
                            color: isSelected
                                ? null
                                : (isDark ? const Color(0xFF14141E) : const Color(0xFFF9FAFB)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFBE123C)
                                  : (isDark ? Colors.white12 : Colors.black12),
                              width: isSelected ? 1.8 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: const Color(0xFFBE123C).withValues(alpha: isDark ? 0.3 : 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon Badge
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [Color(0xFFBE123C), Color(0xFF9F1239)],
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFBE123C).withValues(alpha: 0.35),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  preset['icon']!,
                                  style: TextStyle(fontSize: AppTypography.headingMedium),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Blessing text & subtitles
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            mantra,
                                            style: TextStyle(
                                              fontSize: AppTypography.bodyMedium,
                                              fontWeight: AppTypography.black,
                                              color: isSelected
                                                  ? const Color(0xFFBE123C)
                                                  : theme.colorScheme.onSurface,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFFBE123C)
                                                : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06)),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            preset['badge']!,
                                            style: TextStyle(
                                              fontSize: AppTypography.labelTiny,
                                              fontWeight: AppTypography.extraBold,
                                              color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      preset['subtitle']!,
                                      style: TextStyle(
                                        fontSize: AppTypography.labelTiny,
                                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Animated Radio Checkmark
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFBE123C) : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFBE123C)
                                        : (isDark ? Colors.white38 : Colors.black26),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.white, size: 13)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 2),

                  // ✍️ Custom Blessing Option Card
                  TactilePressable(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isCustomMantra = !_isCustomMantra;
                      });
                      _generatePdf();
                    },
                    pressedScale: 0.98,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: _isCustomMantra
                            ? (isDark
                                ? const LinearGradient(
                                    colors: [Color(0xFF2C1018), Color(0xFF1A0A10)],
                                  )
                                : const LinearGradient(
                                    colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                                  ))
                            : null,
                        color: _isCustomMantra
                            ? null
                            : (isDark ? const Color(0xFF14141E) : const Color(0xFFF9FAFB)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isCustomMantra
                              ? const Color(0xFFBE123C)
                              : (isDark ? Colors.white12 : Colors.black12),
                          width: _isCustomMantra ? 1.8 : 1,
                        ),
                        boxShadow: [
                          if (_isCustomMantra)
                            BoxShadow(
                              color: const Color(0xFFBE123C).withValues(alpha: isDark ? 0.3 : 0.15),
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
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: _isCustomMantra
                                      ? const LinearGradient(
                                          colors: [Color(0xFFBE123C), Color(0xFF9F1239)],
                                        )
                                      : null,
                                  color: _isCustomMantra
                                      ? null
                                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.edit_note_rounded,
                                  size: 22,
                                  color: _isCustomMantra ? Colors.white : const Color(0xFFBE123C),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)?.writeCustomBlessing ?? 'Write Custom Blessing / Deity Name',
                                      style: TextStyle(
                                        fontSize: AppTypography.bodyMedium,
                                        fontWeight: AppTypography.extraBold,
                                        color: _isCustomMantra
                                            ? const Color(0xFFBE123C)
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)?.writeCustomBlessingSubtitle ?? 'Type any family Kuldevi, Guru, or personalized deity mantra',
                                      style: TextStyle(
                                        fontSize: AppTypography.labelTiny,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _isCustomMantra ? const Color(0xFFBE123C) : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _isCustomMantra
                                        ? const Color(0xFFBE123C)
                                        : (isDark ? Colors.white38 : Colors.black26),
                                    width: 2,
                                  ),
                                ),
                                child: _isCustomMantra
                                    ? const Icon(Icons.check, color: Colors.white, size: 13)
                                    : null,
                              ),
                            ],
                          ),

                          // Animated Expandable Input & Suggestions
                          AnimatedSize(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeInOutCubic,
                            child: _isCustomMantra
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 14),
                                      TextField(
                                        controller: _customMantraController,
                                        style: TextStyle(
                                          fontSize: AppTypography.bodyMedium,
                                          fontWeight: AppTypography.extraBold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'e.g. ॥ श्री जगदंबा माता की जय ॥',
                                          isDense: true,
                                          prefixIcon: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFFBE123C)),
                                          prefixIconConstraints: const BoxConstraints(minWidth: 36),
                                          suffixIcon: _customMantraController.text.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear, size: 16),
                                                  onPressed: () {
                                                    _customMantraController.clear();
                                                    _generatePdf();
                                                  },
                                                )
                                              : null,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFBE123C),
                                              width: 1.5,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFBE123C),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        onChanged: (_) => _generatePdf(),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        AppLocalizations.of(context)?.quickOneTapSuggestions ?? 'Quick 1-Tap Suggestions:',
                                        style: TextStyle(
                                          fontSize: AppTypography.labelTiny,
                                          fontWeight: AppTypography.bold,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: customMantraSuggestions.map((suggestion) {
                                          return TactilePressable(
                                            onTap: () {
                                              HapticFeedback.selectionClick();
                                              _customMantraController.text = suggestion;
                                              _generatePdf();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: const Color(0xFFBE123C).withValues(alpha: 0.3),
                                                ),
                                              ),
                                              child: Text(
                                                suggestion,
                                                style: TextStyle(
                                                  fontSize: AppTypography.labelSmall,
                                                  fontWeight: AppTypography.bold,
                                                  color: isDark ? Colors.white : const Color(0xFF9F1239),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // 🔒 3. Privacy & Field Visibility Switches
            _buildAnimatedCustomizeItem(
              index: 2,
              child: _buildCustomizerCard(
                theme: theme,
                isDark: isDark,
                title: AppLocalizations.of(context)?.privacyAndContentSwitches ?? '🔒 Privacy & Content Switches',
                subtitle: AppLocalizations.of(context)?.privacyAndContentSwitchesSubtitle ?? 'Toggle visibility of sensitive fields on your shared PDF',
                children: [
                  _buildJewelSwitchTile(
                    title: AppLocalizations.of(context)?.annualIncomeSalary ?? 'Annual Income / Salary',
                    subtitle: _showAnnualIncome
                        ? (AppLocalizations.of(context)?.incomeVisibleOnPdf ?? 'Package & income details visible on PDF')
                        : (AppLocalizations.of(context)?.incomeHiddenFromPdf ?? 'Hidden from shared PDF for privacy'),
                    icon: Icons.currency_rupee_rounded,
                    jewelColor: const Color(0xFF059669),
                    value: _showAnnualIncome,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() => _showAnnualIncome = val);
                      _generatePdf();
                    },
                    isDark: isDark,
                  ),
                  const Divider(height: 20),
                  _buildJewelSwitchTile(
                    title: AppLocalizations.of(context)?.exactBirthTimeAndKundali ?? 'Exact Birth Time & Kundali',
                    subtitle: _showBirthTime
                        ? (AppLocalizations.of(context)?.birthTimeVisibleOnPdf ?? 'Birth time & birth place visible on PDF')
                        : (AppLocalizations.of(context)?.onlyDobShownOnPdf ?? 'Only Date of Birth shown on PDF'),
                    icon: Icons.access_time_filled_rounded,
                    jewelColor: const Color(0xFF4F46E5),
                    value: _showBirthTime,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() => _showBirthTime = val);
                      _generatePdf();
                    },
                    isDark: isDark,
                  ),
                  const Divider(height: 20),
                  _buildJewelSwitchTile(
                    title: AppLocalizations.of(context)?.primaryContactNumber ?? 'Primary Contact Number',
                    subtitle: _showPhoneNumber
                        ? (AppLocalizations.of(context)?.primaryContactVisibleOnPdf ?? 'Registered calling number visible on PDF')
                        : (AppLocalizations.of(context)?.primaryContactHiddenOnPdf ?? 'Hidden for privacy'),
                    icon: Icons.phone_rounded,
                    jewelColor: const Color(0xFF2563EB),
                    value: _showPhoneNumber,
                    onChanged: (val) {
                      HapticFeedback.lightImpact();
                      setState(() => _showPhoneNumber = val);
                      _generatePdf();
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Alternate Contact Number
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add_call, size: 16, color: Color(0xFFD97706)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)?.alternateRelativeContactNumberOptional ?? 'Alternate / Relative Contact Number (Optional)',
                                style: TextStyle(
                                  fontSize: AppTypography.labelSmall,
                                  fontWeight: AppTypography.extraBold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _alternatePhoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            fontSize: AppTypography.bodySmall,
                            fontWeight: AppTypography.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. 9876543210 (Father / Guardian)',
                            isDense: true,
                            prefixIcon: const Icon(Icons.phone_outlined, size: 16),
                            prefixIconConstraints: const BoxConstraints(minWidth: 34),
                            suffixIcon: _alternatePhoneController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      _alternatePhoneController.clear();
                                      _generatePdf();
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isDark ? Colors.white24 : Colors.black26,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFD97706),
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (_) => _generatePdf(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            // 👑 4. Master Profile Editor Shortcut Card
            _buildAnimatedCustomizeItem(
              index: 3,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2C1018), Color(0xFF1E0A12)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                        ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFBE123C).withValues(alpha: isDark ? 0.35 : 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBE123C).withValues(alpha: isDark ? 0.15 : 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFBE123C), Color(0xFF9F1239)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
                    ),
                    SizedBox(width: 3.5.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.editBiodataInfoPhotos ?? 'Edit Biodata Info & Photos',
                            style: TextStyle(
                              fontSize: AppTypography.bodyMedium,
                              fontWeight: AppTypography.black,
                              color: const Color(0xFFBE123C),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(context)?.editBiodataInfoPhotosDesc ?? 'Edit Education, Gotra, Family, Native Tanda & Photo in your master profile.',
                            style: TextStyle(
                              fontSize: AppTypography.labelTiny,
                              color: isDark ? Colors.white70 : const Color(0xFF9F1239),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        await Navigator.pushNamed(context, AppRoutes.selfProfile);
                        await _loadData(forceRefreshProfile: true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBE123C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.edit ?? 'Edit',
                            style: TextStyle(fontSize: AppTypography.labelSmall, fontWeight: AppTypography.extraBold),
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.edit, size: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // 🚀 5. Sticky Pinned Floating Action Bar
        Positioned(
          left: 4.w,
          right: 4.w,
          bottom: 2.h,
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161622) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.black.withValues(alpha: 0.08),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TactilePressable(
              onTap: () {
                HapticFeedback.lightImpact();
                _tabController?.animateTo(0);
              },
              pressedScale: 0.97,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBE123C), Color(0xFF9F1239)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBE123C).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.previewCustomizedBiodata ?? 'Preview Customized Biodata',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.black,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCustomizeItem({
    required int index,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 90)),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Transform.translate(
          offset: Offset(0, 22 * (1 - val)),
          child: Opacity(
            opacity: val.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildCustomizerCard({
    required ThemeData theme,
    required bool isDark,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1B24) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              fontWeight: AppTypography.black,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: AppTypography.labelTiny,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: 1.8.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildJewelSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color jewelColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Jewel Avatar
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: value
                ? jewelColor.withValues(alpha: isDark ? 0.25 : 0.15)
                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value
                  ? jewelColor.withValues(alpha: 0.5)
                  : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: value ? jewelColor : Colors.grey,
          ),
        ),
        const SizedBox(width: 12),

        // Text & Status Badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        fontWeight: AppTypography.extraBold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: value
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      value ? 'Visible' : 'Hidden',
                      style: TextStyle(
                        fontSize: AppTypography.labelTiny,
                        fontWeight: AppTypography.extraBold,
                        color: value
                            ? const Color(0xFF10B981)
                            : (isDark ? Colors.white54 : Colors.black45),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: AppTypography.labelTiny,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Switch
        Switch.adaptive(
          value: value,
          activeTrackColor: jewelColor,
          activeThumbColor: Colors.white,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌐 TOP APPBAR LANGUAGE PILL & MODAL PICKER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLanguagePill(ThemeData theme, bool isDark) {
    String getLanguageDisplayLabel(String lang) {
      switch (lang) {
        case 'Marathi':
          return 'मराठी';
        case 'Hindi':
          return 'हिंदी';
        case 'Telugu':
          return 'తెలుగు';
        case 'Kannada':
          return 'ಕನ್ನಡ';
        default:
          return 'English';
      }
    }

    final foreground = theme.appBarTheme.foregroundColor ?? Colors.white;
    final pillBg = foreground.withValues(alpha: isDark ? 0.12 : 0.16);
    final pillBorder = foreground.withValues(alpha: isDark ? 0.25 : 0.35);
    final pillTextColor = foreground;
    final pillIconColor = foreground;

    return TactilePressable(
      onTap: () {
        HapticFeedback.lightImpact();
        _showLanguagePickerModal(context, theme, isDark);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.4.w, vertical: 0.4.h),
        decoration: BoxDecoration(
          color: pillBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: pillBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.translate_rounded,
              color: pillIconColor,
              size: 13,
            ),
            const SizedBox(width: 4),
            Text(
              getLanguageDisplayLabel(_selectedLanguage),
              style: TextStyle(
                color: pillTextColor,
                fontWeight: AppTypography.bold,
                fontSize: AppTypography.labelSmall,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 1),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: pillIconColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePickerModal(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    final languages = [
      {
        'name': 'Marathi',
        'native': 'मराठी',
        'sub': 'अस्सल बंजारा पारंपरिक मराठी प्रारूप',
        'flag': '🚩',
        'color': const Color(0xFFBE123C),
      },
      {
        'name': 'Hindi',
        'native': 'हिंदी',
        'sub': 'प्रामाणिक पारंपरिक बंजारा बायोडाटा',
        'flag': '🇮🇳',
        'color': const Color(0xFFD97706),
      },
      {
        'name': 'Telugu',
        'native': 'తెలుగు',
        'sub': 'సంప్రదాయ బంజారా బయోడేటా',
        'flag': '🏛️',
        'color': const Color(0xFF059669),
      },
      {
        'name': 'Kannada',
        'native': 'ಕನ್ನಡ',
        'sub': 'ಸಾಂಪ್ರದಾಯಿಕ ಬಂಜಾರ ಬಯೋಡೇಟಾ',
        'flag': '🌾',
        'color': const Color(0xFF7C3AED),
      },
      {
        'name': 'English',
        'native': 'English',
        'sub': 'Global standard matrimony format',
        'flag': '🇬🇧',
        'color': const Color(0xFF2563EB),
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF161622) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBE123C).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.translate_rounded,
                            color: Color(0xFFBE123C),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)?.selectBiodataLanguage ?? 'Select Biodata Language',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: AppTypography.bold,
                                ),
                              ),
                              Text(
                                AppLocalizations.of(context)?.translatesWholePdfDesc ?? 'Translates whole PDF (keys & profile info)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: AppTypography.labelSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Language Cards List
                    ...languages.map((lang) {
                      final name = lang['name'] as String;
                      final isSelected = _selectedLanguage == name;
                      final color = lang['color'] as Color;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TactilePressable(
                          onTap: () async {
                            Navigator.pop(ctx);
                            await _onLanguageSelected(name);
                          },
                          pressedScale: 0.98,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: isDark ? 0.2 : 0.08)
                                  : (isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF9FAFB)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : (isDark ? Colors.white12 : Colors.black12),
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(lang['flag'] as String, style: TextStyle(fontSize: AppTypography.headingLarge)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            lang['native'] as String,
                                            style: TextStyle(
                                              fontSize: AppTypography.headingSmall,
                                              fontWeight: AppTypography.bold,
                                              color: isSelected ? color : null,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '(${lang['name']})',
                                            style: TextStyle(
                                              fontSize: AppTypography.labelSmall,
                                              fontWeight: AppTypography.semiBold,
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        lang['sub'] as String,
                                        style: TextStyle(
                                          fontSize: AppTypography.labelSmall,
                                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: isSelected ? color : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? color
                                          : (isDark ? Colors.white38 : Colors.black26),
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white, size: 13)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



  // ═══════════════════════════════════════════════════════════════════════════
  // 📤 LOADED ANIMATED FLOATING SHARE ACTION BUTTON (FAB)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildShareFab(ThemeData theme, bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fabPulseController, _fabShimmerController]),
      builder: (context, child) {
        final pulse = _fabPulseController.value;
        final shimmer = _fabShimmerController.value;

        // 🧬 Dynamic physics: floating levitation + breathing pulse + rotating border angle
        final floatY = -3.0 * math.sin(pulse * math.pi);
        final scale = 1.0 + (0.02 * pulse);
        final haloScale = 1.0 + (0.10 * pulse);
        final haloOpacity = (1.0 - pulse) * 0.35;
        final iconAngle = -0.05 + (0.10 * pulse);
        final rotateBorderAngle = shimmer * 2 * math.pi;

        return Transform.translate(
          offset: Offset(0, floatY),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Expanding Ambient Halo Ripple Ring (with Rotating Colors)
              Transform.scale(
                scale: haloScale,
                child: Container(
                  height: 40,
                  width: 124,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: SweepGradient(
                      colors: [
                        const Color(0xFFE11D48).withValues(alpha: haloOpacity),
                        const Color(0xFFF59E0B).withValues(alpha: haloOpacity),
                        const Color(0xFF10B981).withValues(alpha: haloOpacity),
                        const Color(0xFF06B6D4).withValues(alpha: haloOpacity),
                        const Color(0xFF8B5CF6).withValues(alpha: haloOpacity),
                        const Color(0xFFE11D48).withValues(alpha: haloOpacity),
                      ],
                      transform: GradientRotation(rotateBorderAngle),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFBE123C).withValues(alpha: haloOpacity * 0.5),
                        blurRadius: 14,
                        spreadRadius: 1.5,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Primary Interactive FAB with Circular Rotating Colors Border
              Transform.scale(
                scale: scale,
                child: TactilePressable(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    if (_pdfData != null) {
                      await Printing.sharePdf(
                        bytes: _pdfData!,
                        filename: '${_profile?.fullName ?? "Candidate"}_BanjaraBio_Biodata.pdf',
                        subject: '🚩 बंजाराबायो (BanjaraBio) मॅट्रीमोनी बायोडाटा',
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Generating PDF, please wait a moment...',
                        backgroundColor: const Color(0xFFBE123C),
                        textColor: Colors.white,
                      );
                    }
                  },
                  pressedScale: 0.92,
                  child: Container(
                    // 🌈 Circular Rotating Colors Border Layer
                    padding: const EdgeInsets.all(1.8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: SweepGradient(
                        colors: const [
                          Color(0xFFE11D48), // Crimson Rose
                          Color(0xFFF59E0B), // Radiant Amber
                          Color(0xFF10B981), // Emerald Green
                          Color(0xFF06B6D4), // Cyan Neon
                          Color(0xFF8B5CF6), // Royal Violet
                          Color(0xFFEC4899), // Hot Pink
                          Color(0xFFE11D48), // Loop back
                        ],
                        transform: GradientRotation(rotateBorderAngle),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBE123C).withValues(alpha: 0.40 + (0.25 * pulse)),
                          blurRadius: 12 + (6 * pulse),
                          spreadRadius: 0.5 + (1.2 * pulse),
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.2),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE11D48), // Royal Crimson Rose
                            Color(0xFFBE123C), // Core Rose
                            Color(0xFF881337), // Velvet Ruby
                          ],
                          stops: [0.0, 0.52, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22.2),
                        child: Stack(
                          children: [
                            // 3. Diagonal Specular Shimmer Sweep
                            Positioned.fill(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final shimmerOffset = (shimmer * (constraints.maxWidth * 2.5)) - constraints.maxWidth;
                                  return Transform.translate(
                                    offset: Offset(shimmerOffset, 0),
                                    child: Container(
                                      width: constraints.maxWidth * 0.5,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.0),
                                            Colors.white.withValues(alpha: 0.28),
                                            Colors.white.withValues(alpha: 0.0),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // 4. Content Row: [WhatsApp Icon] + [Share] + [Download Icon]
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8.5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // WhatsApp Icon (Left)
                                  Transform.rotate(
                                    angle: iconAngle,
                                    child: const Icon(
                                      FontAwesomeIcons.whatsapp,
                                      color: Colors.white,
                                      size: 15.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  // Share Text (Center)
                                  Text(
                                    AppLocalizations.of(context)?.share ?? 'Share',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: AppTypography.black,
                                      fontSize: AppTypography.bodyMedium,
                                      letterSpacing: 0.4,
                                      shadows: [
                                        const Shadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  // Download Icon (Right)
                                  Transform.translate(
                                    offset: Offset(0, 0.6 * math.sin(pulse * math.pi)),
                                    child: const Icon(
                                      Icons.file_download_outlined,
                                      color: Colors.white,
                                      size: 16.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
}

// ═══════════════════════════════════════════════════════════════════════════
// 💎 BILLION-DOLLAR LUXURY SLIDING TAB INDICATOR WITH GLOW & BOTTOM ACCENT LINE
// ═══════════════════════════════════════════════════════════════════════════
class _BillionDollarTabIndicator extends Decoration {
  const _BillionDollarTabIndicator();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _BillionDollarTabPainter(this, onChanged);
  }
}

class _BillionDollarTabPainter extends BoxPainter {
  final _BillionDollarTabIndicator decoration;

  _BillionDollarTabPainter(this.decoration, VoidCallback? onChanged)
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    if (configuration.size == null) return;

    final Rect rect = offset & configuration.size!;
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(17.0),
    );

    // 1. Ambient Glow Drop Shadow
    final Paint shadowPaint = Paint()
      ..color = const Color(0xFFE11D48).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawRRect(rrect.shift(const Offset(0, 2.5)), shadowPaint);

    // 2. Primary Gradient Fill (Banjara Crimson-Rose Spectrum)
    final Paint fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFE11D48),
          Color(0xFFBE123C),
          Color(0xFF9F1239),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    canvas.drawRRect(rrect, fillPaint);

    // 3. Top Glossy Specular Reflection Border
    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);

    // 4. Bottom Selection Accent Indicator Line (Gold Glow Bar)
    final double lineWidth = math.min(rect.width * 0.42, 38.0);
    final Rect lineRect = Rect.fromCenter(
      center: Offset(rect.center.dx, rect.bottom - 2.8),
      width: lineWidth,
      height: 2.6,
    );
    final RRect lineRRect = RRect.fromRectAndRadius(
      lineRect,
      const Radius.circular(2),
    );

    // Ambient halo behind the gold bar
    final Paint lineGlowPaint = Paint()
      ..color = const Color(0xFFFDE047).withValues(alpha: 0.7)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawRRect(lineRRect, lineGlowPaint);

    // Solid radiant gold indicator line
    final Paint linePaint = Paint()..color = const Color(0xFFFDE047);
    canvas.drawRRect(lineRRect, linePaint);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 👑 ROYAL ANIMATED ROTATING AURA RUNNING GRADIENT BORDER CONTAINER
// ═══════════════════════════════════════════════════════════════════════════
class _RoyalAuraBorderContainer extends StatefulWidget {
  final Widget child;
  final bool isDark;
  final Color accentColor;

  const _RoyalAuraBorderContainer({
    required this.child,
    required this.isDark,
    required this.accentColor,
  });

  @override
  State<_RoyalAuraBorderContainer> createState() => _RoyalAuraBorderContainerState();
}

class _RoyalAuraBorderContainerState extends State<_RoyalAuraBorderContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _auraController;

  @override
  void initState() {
    super.initState();
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..repeat();
  }

  @override
  void dispose() {
    _auraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24);

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: AnimatedBuilder(
        animation: _auraController,
        builder: (context, child) {
          final angle = _auraController.value * 2 * math.pi;

          return Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: SweepGradient(
                transform: GradientRotation(angle),
                colors: [
                  const Color(0xFFF59E0B), // Radiant Amber Gold
                  const Color(0xFFBE123C), // Banjara Ruby
                  const Color(0xFFE11D48), // Rose Crimson
                  widget.accentColor,      // Live Template Accent
                  const Color(0xFFFBBF24), // Saffron Gold
                  const Color(0xFFF59E0B), // Loop Closure
                ],
                stops: const [0.0, 0.22, 0.45, 0.68, 0.88, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(
                    alpha: widget.isDark ? 0.25 : 0.15,
                  ),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: widget.accentColor.withValues(
                    alpha: widget.isDark ? 0.20 : 0.12,
                  ),
                  blurRadius: 22,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF14141E) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}


