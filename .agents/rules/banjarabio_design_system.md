# BanjaraBio Design System & UI Invariants

This rule governs all UI styling, color tokens, theming, opacity, and typography across the BanjaraBio application. All agents and developers must strictly adhere to these standards for any new or modified UI components.

---

## 1. Color System & Theming Standards

- **Zero Raw Hex in UI**: Never use raw `Color(0x...)` or generic `Colors.*` directly in UI widgets or screen files.
- **Theme-Aware Roles (`AppColorScheme`)**:
  - Prefer auto-resolving semantic tokens via `context.colors.<role>` over manual `isDark ? AppColors.X : AppColors.Y` checks.
  - Available roles: `canvas`, `surface`, `surfaceElevated`, `inputFill`, `textPrimary`, `textSecondary`, `textDisabled`, `textOnPrimary`, `textOnSecondary`, `primary`, `primaryDeep`, `secondary`, `secondaryDeep`, `success`, `successBg`, `warning`, `warningBg`, `error`, `errorBg`, `divider`, `border`, `shadow`, `shimmerBase`, `shimmerHighlight`, `crimsonAccent`, `crimsonBg`, `goldAccent`, `goldBg`.
- **Direct Color Tokens (`AppColors`)**:
  - When referencing explicit cultural or brand tokens, use `AppColors.<token>` from `lib/theme/app_colors.dart`.
- **Zero Magic Opacity Numbers**:
  - Always use `color.withValues(alpha: AppColors.opacityXX)` where `XX` is one of the standardized steps:
    `opacity5` (0.05), `opacity8` (0.08), `opacity10` (0.10), `opacity12` (0.12), `opacity15` (0.15), `opacity20` (0.20), `opacity25` (0.25), `opacity30` (0.30), `opacity35` (0.35), `opacity40` (0.40), `opacity50` (0.50), `opacity60` (0.60), `opacity70` (0.70), `opacity80` (0.80), `opacity85` (0.85), `opacity90` (0.90).
  - Never use deprecated `.withOpacity()`.
- **Category & Domain Theming (`AppCategoryTheme`)**:
  - Consume `Theme.of(context).extension<AppCategoryTheme>()!` for category-specific colors and gradients across Personal, Career, Location, Family, Astro, VIP, Trust, Verification, and Security sections.

---

## 2. Typography & Font Sizing Standards

- **Font Families**:
  - **Headings & Display**: `Outfit` (`AppTypography.headingFontFamily`)
  - **Body, Captions, Labels & Buttons**: `PlusJakartaSans` (`AppTypography.bodyFontFamily`)
- **Zero Raw Font Sizes**:
  - Never specify arbitrary numeric font sizes (e.g. `fontSize: 16.0` or `14.sp` inline) in TextStyles.
  - Always reference `AppTypography.<scale>`:
    - **Display**: `displayLarge` (32sp), `displayMedium` (28sp), `displaySmall` (26sp)
    - **Headings**: `headingLarge` (24sp), `headingMedium` (18sp), `headingSmall` (16sp)
    - **Titles**: `titleLarge` (20sp), `titleMedium` (16sp), `titleSmall` (14sp)
    - **Body**: `bodyLarge` (16sp), `bodyMedium` (14sp), `bodySmall` (12sp), `bodyExtraSmall` (11sp)
    - **Labels & Badges**: `labelLarge` (14sp), `labelMedium` (12sp), `labelSmall` (11sp), `labelTiny` (10sp)
  - For PDF generators, custom painters, or non-widget contexts where Sizer is unavailable, use `AppTypography.*Fixed` constants (e.g., `headingLargeFixed`, `bodyMediumFixed`).
- **Minimum Legible Baseline**:
  - Never use body text font sizes smaller than `AppTypography.bodyExtraSmall` (11sp) or badges smaller than `AppTypography.labelTiny` (10sp).
- **Text Style Generators**:
  - Prefer using centralized builders: `AppTypography.headingStyle()`, `AppTypography.titleStyle()`, `AppTypography.bodyStyle()`, `AppTypography.labelStyle()`, `AppTypography.captionStyle()`, and `AppTypography.buttonStyle()`.
