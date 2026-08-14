import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/app_export.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/presentation/authentication_screen/authentication_screen.dart';
import 'package:banjarabio/presentation/onboarding_screen/relative_intake_screen.dart';

/// 10/10 UX User Type Gateway Screen
/// Offers 2 primary pathways:
/// 1. Existing User (Direct Login)
/// 2. New User (Onboarding Selection Dual Gateway)
class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  State<UserTypeSelectionScreen> createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _currentStep = 0;
  String _selectedPath = ''; // '', 'existing', or 'new'
  String _selectedPurpose = ''; // '', 'biodata', 'relative'

  bool _hasDraft = false;
  bool _isDraftDismissed = false;
  Map<String, dynamic>? _draftData;

  /// Computes the total page count for the current navigation state.
  int get _pageCount {
    if (_selectedPath == 'existing') return 2; // Gateway + Auth
    if (_selectedPath == 'new' && _selectedPurpose == 'relative') return 4; // Gateway + Purpose + RelativeIntake + Auth
    if (_selectedPath == 'new') return 3; // Gateway + Purpose + Auth(biodata)
    return 1; // Gateway only (no path selected yet)
  }

  /// Unique key for the PageView — forces Flutter to reconstruct the
  /// PageView (and rebind the controller's ScrollPosition) whenever the
  /// page structure changes, without disposing the controller itself.
  Key get _pageViewKey => ValueKey('pv_${_selectedPath}_$_selectedPurpose');

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _checkSavedDraft();
  }

  Future<void> _checkSavedDraft() async {
    try {
      final draft = await SessionManager.instance.getBiodataDraft();
      if (draft != null && draft.isNotEmpty) {
        final name = draft['name']?.toString() ?? '';
        final surname = draft['surname']?.toString() ?? '';
        final phone = draft['phone_number']?.toString() ?? '';
        if (name.isNotEmpty || surname.isNotEmpty || phone.isNotEmpty) {
          if (mounted) {
            setState(() {
              _hasDraft = true;
              _draftData = draft;
            });
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _animateToStep(int step) {
    if (step < 0 || step >= _pageCount) return; // Bounds guard
    setState(() {
      _currentStep = step;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients && _pageController.page?.round() != step) {
        _pageController.animateToPage(
          step,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  /// Navigates to a target step by first updating state (which triggers
  /// a PageView rebuild via _pageViewKey change) and then jumping to
  /// the target page in the next frame.
  void _jumpToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(step);
      }
    });
  }

  void _goBackStep() {
    if (_currentStep <= 0) return;
    final targetStep = _currentStep - 1;
    if (targetStep == 0) {
      // Returning to Step 0 (Gateway): Full state reset.
      // The _pageViewKey change reconstructs the PageView cleanly.
      setState(() {
        _currentStep = 0;
        _selectedPath = '';
        _selectedPurpose = '';
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    } else {
      _animateToStep(targetStep);
    }
  }

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
    }
  }

  Future<void> _launchDialer() async {
    final url = Uri.parse('tel:+918186050406');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Widget _staggered({required double start, required double end, required Widget child}) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
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

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep > 0) _goBackStep();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
        body: Stack(
          children: [
            // Layer 0: Gradient Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [const Color(0xFF140A0D), const Color(0xFF1F0D13), const Color(0xFF0F0709)]
                        : [const Color(0xFFFFFBF9), const Color(0xFFFFF4EE), const Color(0xFFFDF0E9)],
                  ),
                ),
              ),
            ),

            // Layer 1: Ambient Glow Orbs
            Positioned(
              top: -10.h, right: -15.w,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: _auroraOrb(55.w, primary.withValues(alpha: isDark ? 0.18 : 0.10)),
              ),
            ),
            Positioned(
              bottom: -10.h, left: -15.w,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: _auroraOrb(50.w, const Color(0xFFD97706).withValues(alpha: isDark ? 0.14 : 0.08)),
              ),
            ),

            // Layer 2: Main Layout
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                child: Column(
                  children: [
                    _buildTopHeaderBar(theme, isDark, l10n, primary),
                    SizedBox(height: 1.5.h),
                    _buildProgressIndicator(theme, isDark, primary),
                    SizedBox(height: 1.5.h),
                    Expanded(
                      child: PageView.builder(
                        key: _pageViewKey,
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _pageCount,
                        onPageChanged: (index) {
                          setState(() {
                            _currentStep = index;
                          });
                        },
                        itemBuilder: (context, index) =>
                            _buildPageAtIndex(index, theme, isDark, l10n, primary),
                      ),
                    ),
                    _buildSupportFooter(theme, isDark, l10n, primary),
                    SizedBox(height: 0.5.h),
                  ],
                ),
              ),
            ),
          ],
        ),
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
  // PAGE ROUTER — maps index to widget per path
  // ══════════════════════════════════════════════
  Widget _buildPageAtIndex(int index, ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    // Page 0 is always the Gateway
    if (index == 0) return _buildStep1PathGateway(theme, isDark, l10n, primary);

    if (_selectedPath == 'existing') {
      // Existing User: page 1 = Auth
      if (index == 1) {
        return const AuthenticationScreen(
          key: ValueKey('existing_user_auth'),
          embedded: true,
        );
      }
    }

    if (_selectedPath == 'new') {
      // New User: page 1 = Purpose Selection
      if (index == 1) return _buildStep2PurposeSelection(theme, isDark, l10n, primary);

      if (_selectedPurpose == 'relative') {
        // Relative path: page 2 = RelativeIntake, page 3 = Auth
        if (index == 2) {
          return RelativeIntakeScreen(
            key: const ValueKey('relative_intake_step'),
            embedded: true,
            onProceed: () => _animateToStep(3),
          );
        }
        if (index == 3) {
          return const AuthenticationScreen(
            key: ValueKey('relative_user_auth'),
            embedded: true,
          );
        }
      } else {
        // Biodata path: page 2 = Auth
        if (index == 2) {
          return const AuthenticationScreen(
            key: ValueKey('biodata_user_auth'),
            embedded: true,
            targetRouteOnNewProfile: AppRoutes.biodataCreation,
          );
        }
      }
    }

    // Unreachable fallback
    return const SizedBox.shrink();
  }

  // ══════════════════════════════════════════════
  // HEADER BAR (Trust Badge / Back Button & Lang)
  // ══════════════════════════════════════════════
  Widget _buildTopHeaderBar(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    final onSurface = theme.colorScheme.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          _TactileWrapper(
            onTap: _goBackStep,
            child: Container(
              padding: EdgeInsets.all(2.2.w),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.22)
                      : primary.withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : primary).withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 18.sp,
                color: onSurface,
              ),
            ),
          )
        else
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 0.7.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : primary.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '100% Trusted Community',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    color: isDark ? AppTheme.secondaryDark : primary,
                  ),
                ),
              ],
            ),
          ),

        // Language Switcher
        _TactileWrapper(
          onTap: () => Navigator.of(context).pushReplacementNamed(AppRoutes.initialLanguageSelection),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
            decoration: BoxDecoration(
              color: isDark
                  ? primary.withValues(alpha: 0.18)
                  : primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withValues(alpha: isDark ? 0.40 : 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.language_rounded, size: 14.sp, color: primary),
                SizedBox(width: 1.w),
                Text(
                  'भाषा / Lang',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5.sp,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // STEPPER PROGRESS INDICATOR BAR
  // ══════════════════════════════════════════════
  Widget _buildProgressIndicator(ThemeData theme, bool isDark, Color primary) {
    final lang = Localizations.localeOf(context).languageCode;
    final isMarathi = lang == 'mr';
    final secondary = theme.colorScheme.secondary;
    final List<String> stepLabels;
    if (_selectedPath == 'existing') {
      stepLabels = [
        isMarathi ? 'प्रकार' : 'Type',
        isMarathi ? 'साइन इन' : 'Sign In',
      ];
    } else if (_selectedPath == 'new' && _selectedPurpose == 'relative') {
      stepLabels = [
        isMarathi ? 'प्रकार' : 'Type',
        isMarathi ? 'उद्देश' : 'Goal',
        isMarathi ? 'माहिती' : 'Details',
        isMarathi ? 'साइन इन' : 'Sign In',
      ];
    } else if (_selectedPath == 'new') {
      stepLabels = [
        isMarathi ? 'प्रकार' : 'Type',
        isMarathi ? 'उद्देश' : 'Goal',
        isMarathi ? 'साइन इन' : 'Sign In',
      ];
    } else {
      // No path selected yet — Gateway step
      stepLabels = [
        isMarathi ? 'स्वागत' : 'Welcome',
      ];
    }

    final totalSteps = stepLabels.length;
    final displayStepIndex = _currentStep.clamp(0, totalSteps - 1);
    final maxStep = totalSteps > 1 ? totalSteps - 1 : 1;
    final progressFraction = totalSteps == 1 ? 0.25 : ((displayStepIndex / maxStep).clamp(0.0, 1.0));
    final percentText = '${(progressFraction * 100).round()}%';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1F181B).withValues(alpha: 0.90)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : primary.withValues(alpha: 0.18),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step Counter Header Row
          if (totalSteps > 1) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(1.2.w),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: isDark ? 0.20 : 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.route_rounded,
                        size: 11.sp,
                        color: isDark ? AppTheme.secondaryDark : primary,
                      ),
                    ),
                    SizedBox(width: 1.8.w),
                    Text(
                      isMarathi
                          ? 'टप्पा ${displayStepIndex + 1} पैकी $totalSteps'
                          : 'Step ${displayStepIndex + 1} of $totalSteps',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.sp,
                        color: isDark
                            ? AppTheme.secondaryDark
                            : primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary.withValues(alpha: isDark ? 0.25 : 0.12),
                        secondary.withValues(alpha: isDark ? 0.20 : 0.10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primary.withValues(alpha: isDark ? 0.35 : 0.20),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    percentText,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 9.8.sp,
                      color: primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.2.h),
          ],

          // Stepper Node Flow Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < displayStepIndex;
              final isCurrent = index == displayStepIndex;
              final isActive = index <= displayStepIndex;

              final Widget nodeWidget = Row(
                children: [
                  // Node Badge Icon / Number
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    width: isCurrent ? 28 : 22,
                    height: isCurrent ? 28 : 22,
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isCompleted
                                  ? [primary, primary.withValues(alpha: 0.85)]
                                  : [primary, isDark ? AppTheme.primaryDark : AppTheme.primaryVariantLight],
                            )
                          : null,
                      color: isActive
                          ? null
                          : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(
                              color: isDark ? AppTheme.secondaryDark : Colors.white,
                              width: 2.2,
                            )
                          : null,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.50),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : (isCompleted
                              ? [
                                  BoxShadow(
                                    color: primary.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              size: 12.5.sp,
                              color: Colors.white,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : (isDark ? Colors.white54 : Colors.black45),
                                fontWeight: FontWeight.w900,
                                fontSize: isCurrent ? 11.sp : 9.5.sp,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 1.2.w),

                  // Label Text
                  Flexible(
                    child: Text(
                      stepLabels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isCurrent
                            ? FontWeight.w800
                            : (isCompleted ? FontWeight.w700 : FontWeight.w500),
                        color: isCurrent
                            ? primary
                            : (isCompleted
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                        fontSize: isCurrent ? 11.sp : 9.5.sp,
                      ),
                    ),
                  ),

                  // Connector Line
                  if (index < totalSteps - 1)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: index < displayStepIndex ? 3.5 : 2.0,
                        margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                        decoration: BoxDecoration(
                          gradient: index < displayStepIndex
                              ? LinearGradient(
                                  colors: [primary, primary.withValues(alpha: 0.7)],
                                )
                              : null,
                          color: index < displayStepIndex
                              ? null
                              : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              );

              // Allow tapping previous completed nodes to jump back cleanly
              if (index < displayStepIndex) {
                return Expanded(
                  child: _TactileWrapper(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _jumpToStep(index);
                    },
                    child: nodeWidget,
                  ),
                );
              }

              return Expanded(child: nodeWidget);
            }),
          ),

          // Bottom Smooth Dual-Tone Gradient Progress Track
          SizedBox(height: 1.2.h),
          Stack(
            children: [
              // Track Background
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              // Animated Gradient Progress Bar
              LayoutBuilder(
                builder: (context, constraints) {
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    tween: Tween<double>(begin: 0.0, end: progressFraction),
                    builder: (context, value, child) {
                      return Container(
                        height: 5,
                        width: constraints.maxWidth * value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary,
                              isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDraftResumeCard(ThemeData theme, bool isDark, Color primary) {
    final lang = Localizations.localeOf(context).languageCode;
    final isMarathi = lang == 'mr';
    final candidateName = _draftData?['name']?.toString().trim();
    final nameDisplay = candidateName != null && candidateName.isNotEmpty ? candidateName : null;

    final title = isMarathi
        ? '📝 अपूर्ण बायोडेटा सेव्ह आहे!'
        : '📝 Unsaved Biodata Draft Found!';
    final body = nameDisplay != null
        ? (isMarathi
            ? '$nameDisplay चा बायोडेटा मसुदा सुरक्षित आहे. तिथून पुढे सुरू करा.'
            : '$nameDisplay\'s biodata draft is saved. Resume from where you left.')
        : (isMarathi
            ? 'तुम्ही भरलेली माहिती सुरक्षित आहे. तिथून पुढे सुरू करा.'
            : 'Your entered information is saved safely. Tap to resume.');
    final btnText = isMarathi ? 'ड्राफ्ट पूर्ण करा (पुढे सुरू ठेवा) 👉' : 'Resume Draft Now 👉';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF381E05), const Color(0xFF231002)]
              : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF59E0B),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.30 : 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with badge title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(1.5.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        size: 15.sp,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isDraftDismissed = true);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 13.5.sp,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.8.h),
          Text(
            body,
            style: TextStyle(
              fontSize: 10.5.sp,
              height: 1.25,
              color: isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF78350F),
            ),
          ),
          SizedBox(height: 1.2.h),

          // CTA Button
          _TactileWrapper(
            onTap: () {
              HapticFeedback.mediumImpact();
              if (AppSupabaseClient.isAuthenticated) {
                Navigator.of(context).pushNamed(AppRoutes.biodataCreation);
              } else {
                setState(() {
                  _selectedPath = 'new';
                  _selectedPurpose = 'biodata';
                });
                _jumpToStep(2);
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.0.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  btnText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // STEP 1: PATH SELECTION (Existing vs New User)
  // ══════════════════════════════════════════════
  Widget _buildStep1PathGateway(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = lang == 'mr' ? 'बंजाराबायो मध्ये आपले स्वागत आहे' : 'Welcome to BanjaraBio';
    final subtitle = lang == 'mr' ? 'कृपया पुढे जाण्यासाठी पर्याय निवडा' : 'Select an option to continue';

    final existingTitle = lang == 'mr' ? 'माझे खाते आहे (लॉगिन करा)' : 'Existing User (Sign In)';
    final existingSub = lang == 'mr'
        ? 'तुम्ही आधीच नोंदणी केली असल्यास, इथे लॉगिन करून तुमचे प्रोफाईल व स्थळे पहा.'
        : 'Sign in to access your saved profile and matches.';

    final newTitle = lang == 'mr' ? 'मी नवीन सदस्य आहे (नवीन सुरू करा)' : 'New User (Get Started)';
    final newSub = lang == 'mr'
        ? 'नवीन बायोडेटा तयार करण्यासाठी किंवा नातेवाईकांसाठी मोफत स्थळे शोधण्यासाठी.'
        : 'Create a new profile or browse matches for relatives.';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 1.h),
          const AppLogoImage(width: 80, height: 80),
          SizedBox(height: 1.5.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 18.sp,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),

          // ── Dismissible Smart Resume Draft Card ──
          if (_hasDraft && !_isDraftDismissed) ...[
            _buildDraftResumeCard(theme, isDark, primary),
            SizedBox(height: 1.h),
          ],

          // Option 1: Existing User
          _TactileWrapper(
            onTap: () {
              setState(() {
                _selectedPath = 'existing';
                _selectedPurpose = '';
              });
              _jumpToStep(1);
            },
            child: Container(
              padding: EdgeInsets.all(4.5.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2A151D), const Color(0xFF1F0D15)]
                      : [Colors.white, const Color(0xFFFFF7F5)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 12.w, height: 12.w,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.login_rounded, size: 22.sp, color: primary),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          existingTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          existingSub,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: primary),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Option 2: New User
          _TactileWrapper(
            onTap: () {
              setState(() {
                _selectedPath = 'new';
                _selectedPurpose = '';
              });
              _jumpToStep(1);
            },
            child: Container(
              padding: EdgeInsets.all(4.5.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1E2C), const Color(0xFF141420)]
                      : [Colors.white, const Color(0xFFF8FAF9)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.35), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF25D366).withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 12.w, height: 12.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_add_rounded, size: 22.sp, color: const Color(0xFF25D366)),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          newTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 0.4.h),
                        Text(
                          newSub,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: const Color(0xFF25D366)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2PurposeSelection(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    final lang = Localizations.localeOf(context).languageCode;
    final isMarathi = lang == 'mr';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 0.5.h),

          // ── Dismissible Smart Resume Draft Card (in Purpose Selection) ──
          if (_hasDraft && !_isDraftDismissed) ...[
            _buildDraftResumeCard(theme, isDark, primary),
            SizedBox(height: 0.5.h),
          ],

          // ── Card 1: Search Matches (Instant Discovery) ──
          _buildSearchMatchesCard(theme, isDark, l10n, primary, isMarathi),
          SizedBox(height: 1.0.h),

          // ── Card 2: Create Biodata (Hero Conversion Card) ──
          _buildCreateBiodataCard(theme, isDark, l10n, primary, isMarathi),
          SizedBox(height: 1.0.h),

          // ── Card 3: Guest Mode ──
          _buildGuestModeCard(theme, isDark, l10n, primary, isMarathi),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  /// CARD 1: Search Matches — Same-to-same from OnboardingSelectionScreen
  Widget _buildSearchMatchesCard(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary, bool isMarathi) {
    final badgeText = isMarathi ? 'पर्याय १ • लॉगिन न करता' : 'OPTION 1 • NO LOGIN NEEDED';
    final cardTitle = isMarathi ? 'नातेवाईकांसाठी स्थळ शोधा' : (l10n?.browseMatchesTitle ?? 'Search Matches Directly').replaceAll('🔍', '').trim();
    final cardSub = isMarathi
        ? 'अकाऊंट न बनवता मुलासाठी, मुलीसाठी किंवा नातेवाईकांसाठी लगेच स्थळे पहा'
        : 'Search matches instantly for son, daughter, or relative without creating an account.';
    final ctaText = isMarathi ? 'नातेवाईकांसाठी स्थळ शोधा 👉' : 'Search Matches Directly 👉';

    return _TactileWrapper(
      onTap: () {
        setState(() {
          _selectedPurpose = 'relative';
        });
        _jumpToStep(2);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1418) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF0284C7).withValues(alpha: 0.4) : const Color(0xFF0284C7).withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7).withValues(alpha: isDark ? 0.25 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Row: Badge & Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.0.w, vertical: 0.4.h),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0369A1).withValues(alpha: 0.3) : const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, size: 13.sp, color: const Color(0xFF0284C7)),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            badgeText,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5.sp,
                              color: const Color(0xFF0284C7),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  width: 9.5.w, height: 9.5.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [const Color(0xFF0284C7).withValues(alpha: 0.2), const Color(0xFF0284C7).withValues(alpha: 0.08)],
                    ),
                    border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                  ),
                  child: Icon(Icons.person_search_rounded, size: 17.sp, color: const Color(0xFF0284C7)),
                ),
              ],
            ),
            SizedBox(height: 0.8.h),

            // Title
            Text(
              cardTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: AppTheme.headingFontFamily,
                fontWeight: FontWeight.w900,
                fontSize: 16.sp,
                color: theme.colorScheme.onSurface,
                height: 1.15,
              ),
            ),
            SizedBox(height: 0.4.h),

            // Subtitle
            Text(
              cardSub,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: AppTheme.bodyFontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.25,
              ),
            ),
            SizedBox(height: 0.8.h),

            // Feature Chips
            Wrap(
              spacing: 1.8.w,
              runSpacing: 0.5.h,
              children: [
                _stepperFeatureChip(theme, isMarathi ? '⚡ विना अकाउंट' : '⚡ No Account Needed', isDark),
                _stepperFeatureChip(theme, isMarathi ? '🔍 १ मिनिटात फिल्टर' : '🔍 1-Min Search', isDark),
                _stepperFeatureChip(theme, isMarathi ? '⭐ १००% मोफत' : '⭐ Free Access', isDark),
              ],
            ),
            SizedBox(height: 1.2.h),

            // CTA Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 0.9.h),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.35), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, size: 15.sp, color: const Color(0xFF0284C7)),
                  SizedBox(width: 1.5.w),
                  Text(
                    ctaText,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5.sp,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CARD 2: Create Biodata — Same-to-same hero card from OnboardingSelectionScreen
  Widget _buildCreateBiodataCard(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary, bool isMarathi) {
    final badgeText = isMarathi ? 'पर्याय २ • मोफत नोंदणी' : 'OPTION 2 • MOST POPULAR • 100% FREE';
    final cardTitle = isMarathi ? 'स्वतःचा / उमेदवाराचा बायोडेटा बनवा' : (l10n?.createMyBiodata ?? 'Create My Biodata');
    final cardSub = isMarathi
        ? 'पूर्ण विवाह बायोडेटा बनवून फोटो, मोबाईल नंबर आणि PDF डाउनलोड करा'
        : 'Create official biodata to view photos, mobile numbers & download PDF.';
    final ctaText = isMarathi ? 'लॉगिन करा आणि बायोडेटा बनवा ✨' : 'Login & Create Biodata ✨';

    return _TactileWrapper(
      onTap: () {
        if (AppSupabaseClient.isAuthenticated) {
          Navigator.of(context).pushNamed(AppRoutes.biodataCreation);
          return;
        }
        setState(() {
          _selectedPurpose = 'biodata';
        });
        _jumpToStep(2);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF881337), Color(0xFF9F1239), Color(0xFF700B1A)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF59E0B), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF991B1B).withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge & Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.0.w, vertical: 0.4.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.35), blurRadius: 6),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 11)),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            badgeText,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5.sp,
                              color: const Color(0xFF92400E),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
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
                fontFamily: AppTheme.headingFontFamily,
                fontWeight: FontWeight.w900,
                fontSize: 16.5.sp,
                color: Colors.white,
                height: 1.15,
              ),
            ),
            SizedBox(height: 0.4.h),

            // Subtitle
            Text(
              cardSub,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: AppTheme.bodyFontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.25,
              ),
            ),
            SizedBox(height: 0.8.h),

            // Benefit Rows
            _stepperBenefitRow(theme, '✨', isMarathi ? '२ मिनिटांत सुंदर PDF बायोडेटा बनवा' : 'Create Beautiful PDF Biodata in 2 Mins'),
            SizedBox(height: 0.4.h),
            _stepperBenefitRow(theme, '📱', isMarathi ? 'WhatsApp वर थेट शेअर करा' : 'Share Directly on WhatsApp'),
            SizedBox(height: 0.4.h),
            _stepperBenefitRow(theme, '🛡️', isMarathi ? '१००% पडताळणी केलेले प्रोफाईल्स' : '100% Verified Community Profiles'),
            SizedBox(height: 1.2.h),

            // Golden CTA Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.0.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.40), blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFF451A03)),
                  SizedBox(width: 1.5.w),
                  Text(
                    ctaText,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5.sp,
                      color: const Color(0xFF451A03),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CARD 3: Guest Mode — Matching design language
  Widget _buildGuestModeCard(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary, bool isMarathi) {
    final badgeText = isMarathi ? 'पर्याय ३ • गेस्ट मोड' : 'OPTION 3 • GUEST MODE';
    final cardTitle = isMarathi ? 'गेस्ट सर्च (खात्याशिवाय पहा)' : 'Guest Mode (Instant Browse)';
    final cardSub = isMarathi
        ? 'कोणत्याही नोंदणीशिवाय थेट सर्व स्थळे पहा'
        : 'Explore community matches without sign up';
    final ctaText = isMarathi ? 'गेस्ट म्हणून सुरू करा 🚀' : 'Continue as Guest 🚀';

    return _TactileWrapper(
      onTap: () async {
        await LocalCacheService().setGuestMode(true);
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1A14) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.4 : 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.20 : 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge & Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.0.w, vertical: 0.4.h),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF10B981).withValues(alpha: 0.2) : const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.explore_rounded, size: 13.sp, color: const Color(0xFF10B981)),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            badgeText,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5.sp,
                              color: const Color(0xFF059669),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  width: 9.5.w, height: 9.5.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [const Color(0xFF10B981).withValues(alpha: 0.2), const Color(0xFF10B981).withValues(alpha: 0.08)],
                    ),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: Icon(Icons.travel_explore_rounded, size: 17.sp, color: const Color(0xFF10B981)),
                ),
              ],
            ),
            SizedBox(height: 0.8.h),

            // Title
            Text(
              cardTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: AppTheme.headingFontFamily,
                fontWeight: FontWeight.w900,
                fontSize: 16.sp,
                color: theme.colorScheme.onSurface,
                height: 1.15,
              ),
            ),
            SizedBox(height: 0.4.h),

            // Subtitle
            Text(
              cardSub,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: AppTheme.bodyFontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.25,
              ),
            ),
            SizedBox(height: 1.0.h),

            // CTA Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 0.9.h),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.travel_explore_rounded, size: 15.sp, color: const Color(0xFF10B981)),
                  SizedBox(width: 1.5.w),
                  Text(
                    ctaText,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5.sp,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperFeatureChip(ThemeData theme, String text, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.2.w, vertical: 0.35.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _stepperBenefitRow(ThemeData theme, String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: 11.5.sp)),
        SizedBox(width: 1.5.w),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // FOOTER (Support Strip)
  // ══════════════════════════════════════════════
  Widget _buildSupportFooter(ThemeData theme, bool isDark, AppLocalizations? l10n, Color primary) {
    return _staggered(
      start: 0.6, end: 0.9,
      child: Column(
        children: [
          Text(
            'काही अडचण आहे? मदत हवी असल्यास संपर्क साधा',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 10.5.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TactileWrapper(
                onTap: _launchWhatsApp,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.7.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat_rounded, size: 13.sp, color: const Color(0xFF25D366)),
                      SizedBox(width: 1.5.w),
                      Text(
                        'WhatsApp Support',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.sp,
                          color: const Color(0xFF25D366),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              _TactileWrapper(
                onTap: _launchDialer,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.7.h),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.call_rounded, size: 13.sp, color: primary),
                      SizedBox(width: 1.5.w),
                      Text(
                        'Call Us',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.sp,
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

class _TactileWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TactileWrapper({required this.child, required this.onTap});

  @override
  State<_TactileWrapper> createState() => _TactileWrapperState();
}

class _TactileWrapperState extends State<_TactileWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
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
