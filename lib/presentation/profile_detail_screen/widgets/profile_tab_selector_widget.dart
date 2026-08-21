import 'package:banjarabio/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// Tab Item Model for Profile Tabs with Dynamic Category Theming
class ProfileTabItem {
  final int index;
  final String key;
  final IconData icon;
  final String Function(BuildContext) getTitle;
  final CategoryType categoryType;

  const ProfileTabItem({
    required this.index,
    required this.key,
    required this.icon,
    required this.getTitle,
    required this.categoryType,
  });
}

/// 🌟 Dynamic Segmented Tab Selector with Category Palettes & Tactile Spring Physics
class ProfileTabSelectorWidget extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final EdgeInsets? margin;

  const ProfileTabSelectorWidget({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.margin,
  });

  static List<ProfileTabItem> get defaultTabs => const [
        ProfileTabItem(
          index: 0,
          key: 'all',
          icon: Icons.auto_awesome_rounded,
          getTitle: _getAllTitle,
          categoryType: CategoryType.allDetails,
        ),
        ProfileTabItem(
          index: 1,
          key: 'personal',
          icon: Icons.person_rounded,
          getTitle: _getPersonalTitle,
          categoryType: CategoryType.personal,
        ),
        ProfileTabItem(
          index: 2,
          key: 'career',
          icon: Icons.work_rounded,
          getTitle: _getCareerTitle,
          categoryType: CategoryType.career,
        ),
        ProfileTabItem(
          index: 3,
          key: 'location',
          icon: Icons.location_on_rounded,
          getTitle: _getLocationTitle,
          categoryType: CategoryType.location,
        ),
        ProfileTabItem(
          index: 4,
          key: 'family',
          icon: Icons.family_restroom_rounded,
          getTitle: _getFamilyTitle,
          categoryType: CategoryType.family,
        ),
      ];

  static String _getAllTitle(BuildContext context) =>
      AppLocalizations.of(context)?.viewAll ?? 'All Details';
  static String _getPersonalTitle(BuildContext context) =>
      AppLocalizations.of(context)?.personalDetails ?? 'Personal';
  static String _getCareerTitle(BuildContext context) =>
      AppLocalizations.of(context)?.educationProfession ?? 'Career';
  static String _getLocationTitle(BuildContext context) =>
      AppLocalizations.of(context)?.locationDetails ?? 'Location';
  static String _getFamilyTitle(BuildContext context) =>
      AppLocalizations.of(context)?.familyBackground ?? 'Family';

  @override
  State<ProfileTabSelectorWidget> createState() =>
      _ProfileTabSelectorWidgetState();
}

class _ProfileTabSelectorWidgetState extends State<ProfileTabSelectorWidget> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _tabKeys = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < ProfileTabSelectorWidget.defaultTabs.length; i++) {
      _tabKeys.add(GlobalKey());
    }
  }

  @override
  void didUpdateWidget(covariant ProfileTabSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _scrollToSelectedTab();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedTab() {
    if (widget.selectedIndex >= _tabKeys.length) return;
    final currentKey = _tabKeys[widget.selectedIndex];
    final context = currentKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ProfileTabSelectorWidget.defaultTabs;

    return Container(
      margin: widget.margin ?? EdgeInsets.symmetric(vertical: 0.8.h),
      height: 5.6.h,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = widget.selectedIndex == index;

          return Padding(
            key: _tabKeys[index],
            padding: EdgeInsets.only(right: 2.5.w),
            child: _AnimatedTabPill(
              tab: tab,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onTabSelected(index);
              },
            ),
          );
        },
      ),
    );
  }
}

/// ⚡ Tactile Interactive Tab Pill with Dynamic Category Identity & Glow Shadows
class _AnimatedTabPill extends StatelessWidget {
  final ProfileTabItem tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedTabPill({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final token = AppCategoryTheme.of(context).forType(tab.categoryType);

    return TactilePressable(
      onTap: onTap,
      pressedScale: 0.92,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 0.85.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: token.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark
                  ? AppColors.surfaceDark28.withValues(alpha: AppColors.opacity90)
                  : theme.cardColor),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: AppColors.opacity35)
                : token.border,
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: token.glowShadow.withValues(alpha: isDark ? 0.45 : 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: AppColors.opacity12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🌟 Circular Icon Emblem
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.24)
                    : token.iconBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withValues(alpha: AppColors.opacity40)
                      : token.border,
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Icon(
                  tab.icon,
                  size: 13,
                  color: isSelected ? Colors.white : token.primary,
                ),
              ),
            ),
            SizedBox(width: 2.2.w),

            // Tab Text Label
            Text(
              tab.getTitle(context),
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.88)
                        : theme.colorScheme.onSurface),
                fontWeight: isSelected ? AppTypography.black : AppTypography.bold,
                fontSize: AppTypography.labelMedium,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
