import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/providers/locale_provider.dart';
import 'package:banjarabio/core/utils/startup_workflow.dart';
import 'package:banjarabio/core/constants/app_typography.dart';


class InitialLanguageScreen extends ConsumerStatefulWidget {
  const InitialLanguageScreen({super.key});

  @override
  ConsumerState<InitialLanguageScreen> createState() => _InitialLanguageScreenState();
}

class _InitialLanguageScreenState extends ConsumerState<InitialLanguageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const _languages = [
    {'code': 'en', 'label': 'English', 'native': 'English'},
    {'code': 'mr', 'label': 'Marathi', 'native': 'मराठी'},
    {'code': 'hi', 'label': 'Hindi', 'native': 'हिंदी'},
    {'code': 'te', 'label': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'kn', 'label': 'Kannada', 'native': 'ಕನ್ನಡ'},
  ];

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

  void _selectLanguage(String code) {
    ref.read(localeProvider.notifier).setLocale(Locale(code));
    
    // Give time for localization to apply before navigating
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (mounted) {
        await StartupWorkflow.navigateBasedOnStatus(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider);
    final activeCode = currentLocale?.languageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 8.h),
              
              // App logo or icon
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
                    .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic))),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0)
                      .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5))),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(Icons.language_rounded, size: 40, color: theme.colorScheme.primary),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Title
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
                    .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic))),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0)
                      .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6))),
                  child: Text(
                    'Select App Language\nतुमची भाषा निवडा',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: AppTypography.extraBold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 5.h),

              // Language Cards
              Expanded(
                flex: 6,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  itemCount: _languages.length,
                  separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = lang['code'] == activeCode;
                    
                    return SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
                          .animate(CurvedAnimation(
                            parent: _controller, 
                          curve: Interval(
                            0.4 + (index * 0.1), 
                            (0.8 + (index * 0.1)).clamp(0.0, 1.0), 
                            curve: Curves.easeOutCubic
                          ),
                          )),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0)
                            .animate(CurvedAnimation(
                              parent: _controller, 
                              curve: Interval(
                                0.4 + (index * 0.1), 
                                (0.8 + (index * 0.1)).clamp(0.0, 1.0)
                              ),
                            )),
                        child: _buildLanguageCard(theme, lang, isSelected),
                      ),
                    );
                  },
                ),
              ),

              // Continue Button
              Padding(
                padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 4.h),
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                      .animate(CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
                      )),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0)
                        .animate(CurvedAnimation(
                          parent: _controller,
                          curve: const Interval(0.8, 1.0),
                        )),
                    child: ElevatedButton(
                      onPressed: () => _selectLanguage(activeCode),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: Size(double.infinity, 7.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                      ),
                      child: Text(
                        _getContinueText(activeCode),
                        style: TextStyle(
                          fontSize: AppTypography.headingSmall,
                          fontWeight: AppTypography.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getContinueText(String code) {
    switch (code) {
      case 'mr': return 'पुढे चालू ठेवा (Continue)';
      case 'hi': return 'आगे बढ़ें (Continue)';
      case 'te': return 'కొనసాగించు (Continue)';
      case 'kn': return 'ಮುಂದುವರಿಸಿ (Continue)';
      default: return 'Continue in English';
    }
  }

  Widget _buildLanguageCard(ThemeData theme, Map<String, String> lang, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectLanguage(lang['code']!),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${lang['native']} (${lang['label']})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? AppTypography.extraBold : AppTypography.semiBold,
                  fontSize: AppTypography.bodyLarge,
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: theme.colorScheme.onPrimary, size: 24)
              else
                Icon(Icons.circle_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.3), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
