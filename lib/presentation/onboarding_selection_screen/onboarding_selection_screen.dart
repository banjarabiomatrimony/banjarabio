import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';

class OnboardingSelectionScreen extends StatefulWidget {
  const OnboardingSelectionScreen({super.key});

  @override
  State<OnboardingSelectionScreen> createState() => _OnboardingSelectionScreenState();
}

class _OnboardingSelectionScreenState extends State<OnboardingSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp() async {
    final currentLocale = Localizations.localeOf(context).languageCode;
    String message = 'Hello BanjaraBio Support, I need help creating my biodata.';

    final Map<String, String> localizedMessages = {
      'mr': 'Marathi: नमस्कार बंजाराबायो सपोर्ट, मला माझा बायोडेटा तयार करण्यासाठी मदत हवी आहे.',
      'hi': 'Hindi: नमस्ते बंजाराबायो सपोर्ट, मुझे अपना बायोडेटा बनाने में मदद चाहिए।',
      'te': 'Telugu: నమస్కారం బంజారాబయో సపోర్ట్, నా బయోడేటాను సృష్టించడంలో నాకు సహాయం కావాలి.',
      'kn': 'Kannada: ನಮಸ್ಕಾರ ಬಂಜಾರಬಯೋ ಸಪೋರ್ಟ್, ನನ್ನ ಬಯೋಡೇಟಾವನ್ನು ರಚಿಸಲು ನನಗೆ ಸಹಾಯ ಬೇಕು.',
    };

    if (currentLocale != 'en' && localizedMessages.containsKey(currentLocale)) {
      message += '\n\n${localizedMessages[currentLocale]}';
    }

    final encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappUrl = Uri.parse('https://wa.me/918186050406?text=$encodedMessage');
    
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.couldNotLaunchWhatsApp ?? 'Could not launch WhatsApp')),
        );
      }
    }
  }

  Future<void> _launchDialer() async {
    final Uri phoneUrl = Uri.parse('tel:+918186050406'); // Needs actual company phone
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.couldNotLaunchDialer ?? 'Could not launch Phone Dialer')),
        );
      }
    }
  }

  void _continueAsGuest() {
    // 🚨 CRITICAL FIX: Set guest mode flag BEFORE navigating.
    // Without this, isGuestMode() returns false which causes:
    // 1. PopScope canPop=false → back button freezes the app
    // 2. MatchmakingService initializes websockets unnecessarily
    // 3. _onWillPop never returns true → app stuck on back press
    LocalCacheService().setGuestMode(true);
    
    // Navigate to Home screen. Guest logic handles restrictions.
    // Use pushNamed instead of pushReplacementNamed to allow back navigation to onboarding
    Navigator.of(context).pushNamed(AppRoutes.home);
  }

  void _createBiodata() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.biodataCreation);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Provide default fallbacks for missing translations
    final String welcomeText = l10n?.welcomeToBanjaraBio ?? 'Welcome to BanjaraBio!';
    final String subtitleText = l10n?.chooseHowToStart ?? 'Choose how you want to start';
    final String guestModeText = l10n?.exploreAsGuest ?? 'Explore as Guest';
    final String guestDescText = l10n?.guestModeDesc ?? 'Take a guided tour of the app before creating your profile.';
    final String createModeText = l10n?.createMyBiodata ?? 'Create My Biodata';
    final String createDescText = l10n?.createBiodataDesc ?? 'Fill out your profile and start connecting instantly.';
    final String supportText = l10n?.needHelpContactAdmin ?? 'Need help? Contact Admin';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Language change button at the top
                Align(
                  alignment: Alignment.topRight,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(AppRoutes.initialLanguageSelection);
                      },
                      icon: Icon(Icons.language_rounded, size: 20, color: theme.colorScheme.primary),
                      label: Text(
                        AppLocalizations.of(context)?.changeLanguage ?? 'Language',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ),
                
                const Spacer(flex: 2),

                // Welcome Graphic
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic))),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0)
                        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4))),
                    child: Center(
                      child: Container(
                        width: 35.w,
                        height: 35.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: const AppLogoImage(),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // Title Area
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic))),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0)
                        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6))),
                    child: Column(
                      children: [
                        Text(
                          welcomeText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          subtitleText,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 6.h),

                // Options
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic))),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0)
                        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8))),
                    child: Column(
                      children: [
                        // Guest Option
                        _buildOptionCard(
                          theme: theme,
                          title: guestModeText,
                          description: guestDescText,
                          icon: Icons.explore_rounded,
                          onTap: _continueAsGuest,
                          isPrimary: false,
                        ),
                        
                        SizedBox(height: 2.5.h),
                        
                        // Create Profile Option
                        _buildOptionCard(
                          theme: theme,
                          title: createModeText,
                          description: createDescText,
                          icon: Icons.person_add_rounded,
                          onTap: _createBiodata,
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Support Section
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic))),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0)
                        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0))),
                    child: Column(
                      children: [
                        Text(
                          supportText,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // WhatsApp Button
                            ElevatedButton.icon(
                              onPressed: _launchWhatsApp,
                              icon: const Icon(Icons.chat_rounded, color: Colors.white, size: 18),
                              label: Text(l10n?.whatsApp ?? 'WhatsApp', style: const TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            // Call Button
                            ElevatedButton.icon(
                              onPressed: _launchDialer,
                              icon: Icon(Icons.call_rounded, color: theme.colorScheme.onSurface, size: 18),
                              label: Text(l10n?.callAdmin ?? 'Call Admin', style: TextStyle(color: theme.colorScheme.onSurface)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.surface,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: theme.dividerColor),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required ThemeData theme,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isPrimary ? theme.colorScheme.primary : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPrimary ? Colors.transparent : theme.dividerColor.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              if (isPrimary)
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary ? Colors.white.withValues(alpha: 0.2) : theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : theme.colorScheme.primary,
                  size: 26,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isPrimary ? Colors.white : theme.colorScheme.onSurface,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPrimary ? Colors.white.withValues(alpha: 0.9) : theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isPrimary ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
