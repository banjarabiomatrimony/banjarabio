import 'package:flutter/material.dart';
import 'package:banjarabio/theme/app_colors.dart';

/// 🎨 Category enum for all profile, menu, and service domains
enum CategoryType {
  personal,
  career,
  location,
  family,
  astro,
  allDetails,
  vip,
  trustScore,
  verification,
  security,
}

/// 💎 Design token encapsulating category-specific visual styling
class CategoryThemeToken {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final List<Color> gradient;
  final Color iconBg;
  final Color border;
  final Color glowShadow;
  final Color darkTextColor;
  final Color subtitleColor;

  const CategoryThemeToken({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.gradient,
    required this.iconBg,
    required this.border,
    required this.glowShadow,
    required this.darkTextColor,
    required this.subtitleColor,
  });

  CategoryThemeToken copyWith({
    Color? primary,
    Color? secondary,
    Color? tertiary,
    List<Color>? gradient,
    Color? iconBg,
    Color? border,
    Color? glowShadow,
    Color? darkTextColor,
    Color? subtitleColor,
  }) {
    return CategoryThemeToken(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      gradient: gradient ?? this.gradient,
      iconBg: iconBg ?? this.iconBg,
      border: border ?? this.border,
      glowShadow: glowShadow ?? this.glowShadow,
      darkTextColor: darkTextColor ?? this.darkTextColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
    );
  }
}

/// 🌟 Dynamic Theme Extension for Category Palettes and Field Resolvers
class AppCategoryTheme extends ThemeExtension<AppCategoryTheme> {
  final CategoryThemeToken personal;
  final CategoryThemeToken career;
  final CategoryThemeToken location;
  final CategoryThemeToken family;
  final CategoryThemeToken astro;
  final CategoryThemeToken allDetails;
  final CategoryThemeToken vip;
  final CategoryThemeToken trustScore;
  final CategoryThemeToken verification;
  final CategoryThemeToken security;

  const AppCategoryTheme({
    required this.personal,
    required this.career,
    required this.location,
    required this.family,
    required this.astro,
    required this.allDetails,
    required this.vip,
    required this.trustScore,
    required this.verification,
    required this.security,
  });

  /// Quick accessor from BuildContext
  static AppCategoryTheme of(BuildContext context) {
    final extension = Theme.of(context).extension<AppCategoryTheme>();
    if (extension != null) return extension;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppCategoryTheme.dark() : AppCategoryTheme.light();
  }

  /// Resolve token by CategoryType enum
  CategoryThemeToken forType(CategoryType type) {
    switch (type) {
      case CategoryType.personal:
        return personal;
      case CategoryType.career:
        return career;
      case CategoryType.location:
        return location;
      case CategoryType.family:
        return family;
      case CategoryType.astro:
        return astro;
      case CategoryType.allDetails:
        return allDetails;
      case CategoryType.vip:
        return vip;
      case CategoryType.trustScore:
        return trustScore;
      case CategoryType.verification:
        return verification;
      case CategoryType.security:
        return security;
    }
  }

  /// ☀️ Light Mode Category Palette
  factory AppCategoryTheme.light() {
    return AppCategoryTheme(
      personal: CategoryThemeToken(
        primary: AppColors.categorySecurity, // Vibrant Indigo
        secondary: AppColors.categoryPersonal, // Rose
        tertiary: AppColors.categoryFamily, // Violet
        gradient: const [AppColors.categorySecurity, AppColors.categorySecurityDark],
        iconBg: AppColors.categorySecurity.withValues(alpha: AppColors.opacity12),
        border: AppColors.categorySecurity.withValues(alpha: 0.22),
        glowShadow: AppColors.categorySecurity.withValues(alpha: AppColors.opacity8),
        darkTextColor: AppColors.categorySecurity,
        subtitleColor: AppColors.categorySecurityDark,
      ),
      career: CategoryThemeToken(
        primary: AppColors.sapphireBlue, // Sapphire Ocean Blue
        secondary: AppColors.skyBlue, // Sky Blue
        tertiary: AppColors.teal, // Teal
        gradient: const [AppColors.sapphireBlue, AppColors.oceanBlueDark],
        iconBg: AppColors.sapphireBlue.withValues(alpha: AppColors.opacity12),
        border: AppColors.sapphireBlue.withValues(alpha: 0.22),
        glowShadow: AppColors.sapphireBlue.withValues(alpha: AppColors.opacity8),
        darkTextColor: AppColors.sapphireBlue,
        subtitleColor: AppColors.oceanBlueDark,
      ),
      location: CategoryThemeToken(
        primary: AppColors.sunsetOrange, // Sunset Amber Coral
        secondary: AppColors.warning, // Warm Orange
        tertiary: AppColors.categoryAstroDark, // Amber
        gradient: const [AppColors.sunsetOrange, AppColors.deepOrange],
        iconBg: AppColors.sunsetOrange.withValues(alpha: AppColors.opacity12),
        border: AppColors.sunsetOrange.withValues(alpha: 0.22),
        glowShadow: AppColors.sunsetOrange.withValues(alpha: AppColors.opacity8),
        darkTextColor: AppColors.deepOrange,
        subtitleColor: AppColors.deepOrange,
      ),
      family: CategoryThemeToken(
        primary: AppColors.categoryFamilyDark, // Imperial Purple
        secondary: AppColors.categoryFamily, // Royal Violet
        tertiary: AppColors.categorySecurity, // Indigo
        gradient: const [AppColors.categoryFamilyDark, AppColors.violetDeep],
        iconBg: AppColors.categoryFamilyDark.withValues(alpha: AppColors.opacity12),
        border: AppColors.categoryFamilyDark.withValues(alpha: 0.22),
        glowShadow: AppColors.categoryFamilyDark.withValues(alpha: AppColors.opacity8),
        darkTextColor: AppColors.deepIndigo,
        subtitleColor: AppColors.violetDeep,
      ),
      astro: CategoryThemeToken(
        primary: AppColors.categoryFamily, // Celestial Violet / Amethyst
        secondary: AppColors.categoryAstro, // Golden Sun
        tertiary: AppColors.categoryPersonal, // Rose Venus
        gradient: const [AppColors.categoryFamily, AppColors.violetDeep],
        iconBg: AppColors.categoryFamily.withValues(alpha: AppColors.opacity12),
        border: AppColors.categoryFamily.withValues(alpha: 0.22),
        glowShadow: AppColors.categoryFamily.withValues(alpha: AppColors.opacity8),
        darkTextColor: AppColors.deepIndigo,
        subtitleColor: AppColors.violetDeep,
      ),
      allDetails: CategoryThemeToken(
        primary: AppColors.categoryAstroDark, // Royal Amber Gold
        secondary: AppColors.categoryAstro,
        tertiary: AppColors.amberDark,
        gradient: const [AppColors.categoryAstro, AppColors.categoryAstroDark],
        iconBg: AppColors.categoryAstroDark.withValues(alpha: AppColors.opacity12),
        border: AppColors.categoryAstroDark.withValues(alpha: 0.22),
        glowShadow: AppColors.categoryAstroDark.withValues(alpha: AppColors.opacity8),
        darkTextColor: AppColors.amberDeepText,
        subtitleColor: AppColors.amberDark,
      ),
      vip: CategoryThemeToken(
        primary: AppColors.gold, // Champagne Gold
        secondary: AppColors.categoryVip,
        tertiary: AppColors.darkGoldenrod,
        gradient: const [AppColors.categoryVip, AppColors.gold],
        iconBg: AppColors.gold.withValues(alpha: 0.14),
        border: AppColors.gold.withValues(alpha: AppColors.opacity30),
        glowShadow: AppColors.gold.withValues(alpha: AppColors.opacity12),
        darkTextColor: AppColors.amberDark,
        subtitleColor: AppColors.amberDark,
      ),
      trustScore: CategoryThemeToken(
        primary: AppColors.success, // Emerald Green
        secondary: AppColors.successDark,
        tertiary: AppColors.success,
        gradient: const [AppColors.successDark, AppColors.success],
        iconBg: AppColors.success.withValues(alpha: AppColors.opacity12),
        border: AppColors.success.withValues(alpha: 0.22),
        glowShadow: AppColors.success.withValues(alpha: AppColors.opacity8),
        darkTextColor: AppColors.success,
        subtitleColor: AppColors.success,
      ),
      verification: CategoryThemeToken(
        primary: AppColors.sapphireBlue,
        secondary: AppColors.skyBlue,
        tertiary: AppColors.oceanBlueDark,
        gradient: const [AppColors.skyBlue, AppColors.sapphireBlue],
        iconBg: AppColors.sapphireBlue.withValues(alpha: AppColors.opacity12),
        border: AppColors.sapphireBlue.withValues(alpha: 0.22),
        glowShadow: AppColors.sapphireBlue.withValues(alpha: AppColors.opacity8),
        darkTextColor: AppColors.sapphireBlue,
        subtitleColor: AppColors.oceanBlueDark,
      ),
      security: CategoryThemeToken(
        primary: AppColors.trustLow, // Crimson Shield
        secondary: AppColors.trustLow,
        tertiary: AppColors.error,
        gradient: const [AppColors.trustLow, AppColors.trustLow],
        iconBg: AppColors.trustLow.withValues(alpha: AppColors.opacity12),
        border: AppColors.trustLow.withValues(alpha: 0.22),
        glowShadow: AppColors.trustLow.withValues(alpha: AppColors.opacity8),
        darkTextColor: AppColors.error,
        subtitleColor: AppColors.error,
      ),
    );
  }

  /// 🌙 Dark Mode Category Palette (High Contrast & Ambient Glows)
  factory AppCategoryTheme.dark() {
    return AppCategoryTheme(
      personal: CategoryThemeToken(
        primary: AppColors.indigoSoft, // Soft Indigo
        secondary: AppColors.warmPink,
        tertiary: AppColors.violetSoft,
        gradient: const [AppColors.indigoSoft, AppColors.categorySecurity],
        iconBg: AppColors.indigoSoft.withValues(alpha: AppColors.opacity20),
        border: AppColors.indigoSoft.withValues(alpha: AppColors.opacity35),
        glowShadow: AppColors.indigoSoft.withValues(alpha: AppColors.opacity15),
        darkTextColor: AppColors.infoLight,
        subtitleColor: AppColors.categorySecurity,
      ),
      career: CategoryThemeToken(
        primary: AppColors.skyBlueBright, // Soft Sky Blue
        secondary: AppColors.skyBlue,
        tertiary: AppColors.teal,
        gradient: const [AppColors.skyBlueBright, AppColors.sapphireBlue],
        iconBg: AppColors.skyBlueBright.withValues(alpha: AppColors.opacity20),
        border: AppColors.skyBlueBright.withValues(alpha: AppColors.opacity35),
        glowShadow: AppColors.skyBlueBright.withValues(alpha: AppColors.opacity15),
        darkTextColor: AppColors.infoLight,
        subtitleColor: AppColors.infoDark,
      ),
      location: CategoryThemeToken(
        primary: AppColors.warning, // Soft Sunset Coral
        secondary: AppColors.warning,
        tertiary: AppColors.goldSoft,
        gradient: const [AppColors.warning, AppColors.sunsetOrange],
        iconBg: AppColors.warning.withValues(alpha: AppColors.opacity20),
        border: AppColors.warning.withValues(alpha: AppColors.opacity35),
        glowShadow: AppColors.warning.withValues(alpha: AppColors.opacity15),
        darkTextColor: AppColors.orangePeachBg,
        subtitleColor: AppColors.errorDark,
      ),
      family: CategoryThemeToken(
        primary: AppColors.violetSoft, // Soft Imperial Purple
        secondary: AppColors.violetSoft,
        tertiary: AppColors.indigoSoft,
        gradient: const [AppColors.violetSoft, AppColors.categoryFamilyDark],
        iconBg: AppColors.violetSoft.withValues(alpha: AppColors.opacity20),
        border: AppColors.violetSoft.withValues(alpha: AppColors.opacity35),
        glowShadow: AppColors.violetSoft.withValues(alpha: AppColors.opacity15),
        darkTextColor: AppColors.violetBg,
        subtitleColor: AppColors.categoryFamily,
      ),
      astro: CategoryThemeToken(
        primary: AppColors.violetSoft, // Soft Celestial Violet
        secondary: AppColors.goldSoft, // Soft Gold
        tertiary: AppColors.warmPink, // Soft Pink
        gradient: const [AppColors.violetSoft, AppColors.categoryFamilyDark],
        iconBg: AppColors.violetSoft.withValues(alpha: AppColors.opacity20),
        border: AppColors.violetSoft.withValues(alpha: AppColors.opacity35),
        glowShadow: AppColors.violetSoft.withValues(alpha: AppColors.opacity15),
        darkTextColor: AppColors.violetBg,
        subtitleColor: AppColors.categoryFamily,
      ),
      allDetails: CategoryThemeToken(
        primary: AppColors.goldSoft, // Soft Gold
        secondary: AppColors.categoryAstro,
        tertiary: AppColors.categoryAstroDark,
        gradient: const [AppColors.goldSoft, AppColors.categoryAstroDark],
        iconBg: AppColors.goldSoft.withValues(alpha: AppColors.opacity20),
        border: AppColors.goldSoft.withValues(alpha: AppColors.opacity35),
        glowShadow: AppColors.goldSoft.withValues(alpha: AppColors.opacity15),
        darkTextColor: AppColors.goldTint100,
        subtitleColor: AppColors.goldTint200,
      ),
      vip: CategoryThemeToken(
        primary: AppColors.goldGlow, // Soft Champagne Gold
        secondary: AppColors.categoryVip,
        tertiary: AppColors.categoryVipDark,
        gradient: const [AppColors.goldGlow, AppColors.amber600],
        iconBg: AppColors.goldGlow.withValues(alpha: AppColors.opacity20),
        border: AppColors.goldGlow.withValues(alpha: AppColors.opacity35),
        glowShadow: AppColors.goldGlow.withValues(alpha: 0.18),
        darkTextColor: AppColors.goldLight,
        subtitleColor: AppColors.goldTint200,
      ),
      trustScore: CategoryThemeToken(
        primary: AppColors.successDark, // Soft Emerald
        secondary: AppColors.green500,
        tertiary: AppColors.success,
        gradient: const [AppColors.successDark, AppColors.success],
        iconBg: AppColors.successDark.withValues(alpha: AppColors.opacity20),
        border: AppColors.successDark.withValues(alpha: AppColors.opacity35),
        glowShadow: AppColors.successDark.withValues(alpha: AppColors.opacity15),
        darkTextColor: AppColors.greenLightBg,
        subtitleColor: AppColors.greenLightBg,
      ),
      verification: CategoryThemeToken(
        primary: AppColors.skyBlueBright,
        secondary: AppColors.skyBlue,
        tertiary: AppColors.sapphireBlue,
        gradient: const [AppColors.skyBlueBright, AppColors.sapphireBlue],
        iconBg: AppColors.skyBlueBright.withValues(alpha: AppColors.opacity20),
        border: AppColors.skyBlueBright.withValues(alpha: AppColors.opacity35),
        glowShadow: AppColors.skyBlueBright.withValues(alpha: AppColors.opacity15),
        darkTextColor: AppColors.infoLight,
        subtitleColor: AppColors.infoDark,
      ),
      security: CategoryThemeToken(
        primary: AppColors.coralRed, // Soft Red
        secondary: AppColors.trustLow,
        tertiary: AppColors.trustLow,
        gradient: const [AppColors.coralRed, AppColors.trustLow],
        iconBg: AppColors.coralRed.withValues(alpha: AppColors.opacity20),
        border: AppColors.coralRed.withValues(alpha: AppColors.opacity35),
        glowShadow: AppColors.coralRed.withValues(alpha: AppColors.opacity15),
        darkTextColor: AppColors.primaryLight,
        subtitleColor: AppColors.primaryLight,
      ),
    );
  }

  @override
  ThemeExtension<AppCategoryTheme> copyWith({
    CategoryThemeToken? personal,
    CategoryThemeToken? career,
    CategoryThemeToken? location,
    CategoryThemeToken? family,
    CategoryThemeToken? astro,
    CategoryThemeToken? allDetails,
    CategoryThemeToken? vip,
    CategoryThemeToken? trustScore,
    CategoryThemeToken? verification,
    CategoryThemeToken? security,
  }) {
    return AppCategoryTheme(
      personal: personal ?? this.personal,
      career: career ?? this.career,
      location: location ?? this.location,
      family: family ?? this.family,
      astro: astro ?? this.astro,
      allDetails: allDetails ?? this.allDetails,
      vip: vip ?? this.vip,
      trustScore: trustScore ?? this.trustScore,
      verification: verification ?? this.verification,
      security: security ?? this.security,
    );
  }

  @override
  ThemeExtension<AppCategoryTheme> lerp(
    covariant ThemeExtension<AppCategoryTheme>? other,
    double t,
  ) {
    if (other is! AppCategoryTheme) return this;
    return this; // Continuous discrete step on theme switches
  }
}

/// ⚡ Dynamic Field-Level Palette Resolver
/// Resolves colors dynamically based on field semantics, value state, and theme.
class FieldColorResolver {
  FieldColorResolver._();

  /// Resolve gender color dynamically
  static Color resolveGender(BuildContext context, dynamic genderValue) {
    final str = genderValue?.toString().toLowerCase();
    if (str == 'female') {
      return AppColors.categoryPersonal; // Rose
    }
    return AppCategoryTheme.of(context).personal.primary; // Brand Indigo / Primary
  }

  /// Resolve income color dynamically
  static Color resolveIncome(BuildContext context) {
    return AppCategoryTheme.of(context).allDetails.primary; // Amber Gold
  }

  /// Resolve blood group color dynamically
  static Color resolveBloodGroup(BuildContext context) {
    return AppColors.trustLow; // Crimson
  }

  /// Resolve category by field key
  static CategoryThemeToken resolveFieldToken(
    BuildContext context,
    String fieldKey,
  ) {
    final theme = AppCategoryTheme.of(context);
    switch (fieldKey.toLowerCase()) {
      case 'education':
      case 'degree':
      case 'college':
      case 'profession':
      case 'occupation':
      case 'company':
      case 'employedin':
      case 'income':
        return theme.career;

      case 'city':
      case 'state':
      case 'country':
      case 'pincode':
      case 'nativeplace':
      case 'nativedistrict':
      case 'nativetaluka':
      case 'address':
        return theme.location;

      case 'fathername':
      case 'fatheroccupation':
      case 'mothername':
      case 'motheroccupation':
      case 'gotra':
      case 'maternalgotra':
      case 'mosamgotra':
      case 'brothers':
      case 'sisters':
      case 'familytype':
      case 'familyvalues':
      case 'aboutfamily':
        return theme.family;

      case 'rashi':
      case 'nakshatra':
      case 'manglik':
      case 'manglikstatus':
      case 'kundali':
      case 'gunascore':
      case 'horoscope':
        return theme.astro;

      case 'landholdings':
      case 'ancestralland':
      case 'ancestral_land':
      case 'houseownership':
      case 'isvipspotlight':
        return theme.vip;

      default:
        return theme.personal;
    }
  }
}
