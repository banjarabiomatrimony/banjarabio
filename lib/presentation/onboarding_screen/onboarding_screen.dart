import 'package:banjarabio/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/core/constants/app_typography.dart';

import 'package:banjarabio/routes/app_routes.dart';

/// Premium onboarding flow shown only on first app launch.
/// 3 steps with animated illustrations, smooth page indicators,
/// and a "Get Started" CTA that navigates to authentication.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String _onboardingKey = 'onboarding_completed';

  /// Check if onboarding has been completed before.
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _iconBounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _iconBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconBounceController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeController.forward();
    _iconBounceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _iconBounceController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _fadeController.reset();
    _iconBounceController.reset();
    _fadeController.forward();
    _iconBounceController.forward();
    HapticFeedback.selectionClick();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.mediumImpact();
    // 🧬 PERFORMANCE: Use microtask to ensure haptic feedback is felt
    // before the heavy storage/navigation context change occurs.
    Future.microtask(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(OnboardingScreen._onboardingKey, true);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboardingSelection);
      }
    });
  }

  /// onboarding completion check is now in OnboardingScreen (widget class)

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<_OnboardingPage> pages = [
      _OnboardingPage(
        imagePath: 'assets/images/onboarding/matchmaking.png',
        title: l10n?.findYourPerfectMatch ?? 'Find Your Perfect Match',
        subtitle: l10n?.discoverProfilesFromYourCommunityNsmartM ?? 'Discover profiles from your community.\nSmart matchmaking powered by compatibility scores.',
        bgGradient: const [AppTheme.primaryLight, AppTheme.primaryVariantLight],
      ),
      _OnboardingPage(
        imagePath: 'assets/images/onboarding/verified.png',
        title: l10n?.verifiedTrusted ?? 'Verified & Trusted',
        subtitle: l10n?.everyProfileIsVerifiedWithIdSelfieRefere ?? 'Every profile is verified with ID, selfie & references.\nTrust Score ensures genuine connections.',
        bgGradient: const [AppTheme.successLight, AppTheme.successVariantLight],
      ),
      _OnboardingPage(
        imagePath: 'assets/images/onboarding/family.png',
        title: l10n?.familyFirstValues ?? 'Family-First Values',
        subtitle: l10n?.shareProfilesWithYourFamilyInstantlyNbui ?? 'Share profiles with your family instantly.\nBuilt for the way Indian families make decisions.',
        bgGradient: [AppTheme.secondaryVariantLight, AppTheme.secondaryVariantLight.withValues(alpha: 0.85)],
      ),
    ];

    final page = pages[_currentPage];
    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: page.bgGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 4.w, top: 1.h),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(AppLocalizations.of(context)?.skip ?? 'Skip',
                      style: AppTypography.headingStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: AppTypography.bodyMedium,
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final p = pages[index];
                    return _buildPage(p);
                  },
                ),
              ),

              // Bottom section: dots + button
              Padding(
                padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 4.h),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (index) => _buildDotIndicator(index),
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      height: 7.h,
                      child: ElevatedButton(
                        onPressed: isLastPage
                            ? _completeOnboarding
                            : () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOutCubic,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: page.bgGradient.first,
                          elevation: 8,
                          shadowColor: Colors.black.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLastPage 
                                  ? (AppLocalizations.of(context)?.getStartedLabel ?? 'Get Started')
                                  : (AppLocalizations.of(context)?.nextLabel ?? 'Next'),
                              style: AppTypography.headingStyle(
                                fontSize: AppTypography.bodyLarge,
                                fontWeight: AppTypography.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(
                              isLastPage
                                  ? Icons.arrow_forward_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              size: 20,
                            ),
                          ],
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
  }

  Widget _buildPage(_OnboardingPage page) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🎨 Custom illustration with bounce animation
            ScaleTransition(
              scale: _bounceAnimation,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    page.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.favorite_rounded,
                      size: 15.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 6.h),

            // Title
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: AppTypography.headingStyle(
                color: Colors.white,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),

            SizedBox(height: 2.h),

            // Subtitle
            Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.headingStyle(
                fontSize: AppTypography.bodyMedium,
                fontWeight: AppTypography.regular,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      width: isActive ? 8.w : 2.5.w,
      height: 1.h,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white
            : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

/// Data model for each onboarding step.
class _OnboardingPage {
  final String imagePath;
  final String title;
  final String subtitle;
  final List<Color> bgGradient;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.bgGradient,
  });
}
