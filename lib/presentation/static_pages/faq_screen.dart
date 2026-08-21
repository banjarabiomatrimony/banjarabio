import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:banjarabio/theme/app_colors.dart';
import 'package:banjarabio/widgets/custom_app_bar.dart';
import 'package:banjarabio/widgets/app_logo_image.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';

/// ❓ FAQ & Knowledge Base Screen — Ultra-Premium Edition
/// Features search query filtering, category pills, staggered cascade physics, and smooth animated expandable cards.
class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final Set<int> _expandedIndices = {0}; // First card expanded by default

  AnimationController get _animController {
    _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
    return _controller!;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    final start = (index * 0.08).clamp(0.0, 1.0);
    final end = (0.5 + (index * 0.08)).clamp(0.0, 1.0);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
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

    final rawFaqs = [
      _FaqItemData(
        id: 0,
        category: 'Biodata',
        question: l10n?.faqQ1 ?? 'How do I create and publish my biodata?',
        answer: l10n?.faqA1 ??
            'Go to the Profile tab and click on "Create Biodata" or edit your existing profile. Complete the 5-step guided form with your personal details, education, family background, and horoscope details. Once saved, your biodata goes live instantly.',
        icon: Icons.edit_note_rounded,
        iconColor: const Color(0xFF1E88E5),
      ),
      _FaqItemData(
        id: 1,
        category: 'Security',
        question: l10n?.faqQ2 ?? 'Is my personal data and contact number secure?',
        answer: l10n?.faqA2 ??
            'Yes, data privacy and community safety are our top priorities. Your direct phone number and WhatsApp details are encrypted and only accessible to verified community members who have explicit contact permissions.',
        icon: Icons.shield_rounded,
        iconColor: const Color(0xFF43A047),
      ),
      _FaqItemData(
        id: 2,
        category: 'Matching',
        question: l10n?.faqQ3 ?? 'How do search filters and community matching work?',
        answer: l10n?.faqA3 ??
            'Use the Filters button on the Home or Search screen to narrow down profiles by age, height, gotra / pada, native district, education, and occupation. Matches update in real time based on your selected criteria.',
        icon: Icons.filter_alt_rounded,
        iconColor: const Color(0xFFFB8C00),
      ),
      _FaqItemData(
        id: 3,
        category: 'Membership',
        question: l10n?.faqQ4 ?? 'What are the benefits of BanjaraBio Premium?',
        answer: l10n?.faqA4 ??
            'Premium members enjoy unlimited profile views, direct contact unlocks, enhanced spotlight visibility in search results, WhatsApp alerts for mutual matches, and access to the Marriage Reward program.',
        icon: Icons.workspace_premium_rounded,
        iconColor: const Color(0xFFE5A93C),
      ),
      _FaqItemData(
        id: 4,
        category: 'Security',
        question: l10n?.faqQ5 ?? 'How can I permanently delete or hide my account?',
        answer: l10n?.faqA5 ??
            'You can manage profile visibility or permanently delete your account anytime by navigating to Account > Legal & Privacy > Account Deletion. Deletion permanently purges all uploaded photos and personal biodata.',
        icon: Icons.delete_outline_rounded,
        iconColor: const Color(0xFFE53935),
      ),
      const _FaqItemData(
        id: 5,
        category: 'Membership',
        question: 'What is the BanjaraBio Marriage Reward Program?',
        answer:
            'If you find your life partner through BanjaraBio, you can apply for the Marriage Reward by submitting your marriage card and photo. Our community foundation presents certified couples with an exclusive gift reward.',
        icon: Icons.card_giftcard_rounded,
        iconColor: Color(0xFF8E24AA),
      ),
      const _FaqItemData(
        id: 6,
        category: 'Matching',
        question: 'How do Community Melava events work?',
        answer:
            'Melavas are offline and hybrid Banjara community gathering events. You can browse upcoming city melavas under the Melava tab, view attendee counts, and register directly via WhatsApp or the contact organizer button.',
        icon: Icons.celebration_rounded,
        iconColor: Color(0xFF00ACC1),
      ),
    ];

    // 🔍 Filter FAQs based on category pill & search text
    final filteredFaqs = rawFaqs.where((faq) {
      final matchesCategory = _selectedCategory == 'All' || faq.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final categories = ['All', 'Biodata', 'Matching', 'Membership', 'Security'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 155,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ⬅️ Tactile Back Button
              TactilePressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.maybePop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (theme.appBarTheme.foregroundColor ?? Colors.white)
                        .withValues(alpha: isDark ? AppColors.opacity12 : AppColors.opacity15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.appBarTheme.foregroundColor ?? Colors.white,
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 👑 App Logo
              ClipOval(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const AppLogoImage(
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 5),

              // 🏷️ Wordmark
              Image.asset(
                'assets/logo/brand_kit/wordmark.png',
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        titleWidget: Text(
          l10n?.faqs ?? 'Help & FAQs',
          style: (theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleMedium)?.copyWith(
            fontSize: AppTypography.headingMedium,
            fontWeight: AppTypography.semiBold,
            color: theme.appBarTheme.foregroundColor ?? Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ❓ Top Header Hero Card
            _buildAnimatedItem(
              index: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(
                        alpha: isDark ? AppColors.opacity20 : AppColors.opacity10,
                      ),
                      theme.colorScheme.surface,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(
                      alpha: isDark ? AppColors.opacity30 : AppColors.opacity20,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : theme.colorScheme.primary.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: AppColors.opacity40,
                            ),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Knowledge Base & FAQs',
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.bodyLarge,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Find instant answers to common questions about profiles, privacy, matching and plans.',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: AppTypography.labelSmall,
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

            // 🔍 Search Bar
            _buildAnimatedItem(
              index: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity20)
                        : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  style: TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search questions, keywords or topics...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: AppTypography.bodySmall,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.4.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.8.h),

            // 🏷️ Category Filter Chips
            _buildAnimatedItem(
              index: 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: TactilePressable(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 0.8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : isDark
                                      ? theme.colorScheme.outlineVariant
                                          .withValues(alpha: AppColors.opacity20)
                                      : theme.colorScheme.outlineVariant
                                          .withValues(alpha: AppColors.opacity40),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withValues(
                                        alpha: AppColors.opacity30,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontSize: AppTypography.labelSmall,
                              fontWeight: isSelected
                                  ? AppTypography.bold
                                  : AppTypography.semiBold,
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 2.5.h),

            // 📜 FAQ Accordion List
            if (filteredFaqs.isEmpty)
              _buildAnimatedItem(
                index: 3,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity20)
                          : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 40,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'No matching questions found',
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontWeight: AppTypography.bold,
                          color: theme.colorScheme.onSurface,
                          fontSize: AppTypography.bodyMedium,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Try searching with different keywords or switch categories.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: AppTypography.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              for (int i = 0; i < filteredFaqs.length; i++)
                _buildAnimatedItem(
                  index: 3 + i,
                  child: _buildFaqCard(
                    theme: theme,
                    isDark: isDark,
                    faq: filteredFaqs[i],
                  ),
                ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCard({
    required ThemeData theme,
    required bool isDark,
    required _FaqItemData faq,
  }) {
    final isExpanded = _expandedIndices.contains(faq.id);

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? theme.colorScheme.primary.withValues(
                  alpha: isDark ? AppColors.opacity50 : AppColors.opacity60,
                )
              : isDark
                  ? theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity20)
                  : theme.colorScheme.outlineVariant.withValues(alpha: AppColors.opacity40),
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(
                    alpha: isDark ? AppColors.opacity20 : AppColors.opacity10,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // 🏷️ Header Row (Tap to expand/collapse)
            TactilePressable(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (isExpanded) {
                    _expandedIndices.remove(faq.id);
                  } else {
                    _expandedIndices.add(faq.id);
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Badge
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: faq.iconColor.withValues(
                          alpha: isDark ? AppColors.opacity20 : AppColors.opacity10,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        faq.icon,
                        color: faq.iconColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.5.w),

                    // Question Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.2.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: isDark ? AppColors.opacity8 : AppColors.opacity5,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              faq.category,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: AppTypography.labelSmall,
                                fontWeight: AppTypography.semiBold,
                              ),
                            ),
                          ),
                          SizedBox(height: 0.6.h),
                          Text(
                            faq.question,
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontWeight: AppTypography.bold,
                              fontSize: AppTypography.bodyMedium,
                              color: isExpanded
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 2.w),

                    // Animated Chevron
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isExpanded
                              ? theme.colorScheme.primary.withValues(
                                  alpha: isDark ? AppColors.opacity20 : AppColors.opacity10,
                                )
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isExpanded
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 📖 Expanded Answer Section
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      height: 1,
                      color: isDark
                          ? theme.dividerColor.withValues(alpha: AppColors.opacity20)
                          : theme.dividerColor.withValues(alpha: AppColors.opacity50),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      faq.answer,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: isDark ? AppColors.opacity90 : AppColors.opacity80,
                        ),
                        fontSize: AppTypography.bodySmall,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 240),
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItemData {
  final int id;
  final String category;
  final String question;
  final String answer;
  final IconData icon;
  final Color iconColor;

  const _FaqItemData({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.icon,
    required this.iconColor,
  });
}

