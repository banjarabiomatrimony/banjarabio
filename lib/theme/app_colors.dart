import 'package:flutter/material.dart';

/// 🎨 CENTRALIZED DESIGN TOKEN PALETTE FOR BANJARABIO
///
/// Single source of truth for all color tokens, semantic palettes, category tokens,
/// neutral ramps, and external service colors across the entire application.
///
/// Organized into distinct semantic domains:
/// 1. 👑 Brand & Core Cultural Palette
/// 2. 🌙 Dark Mode Core Palette
/// 3. 🚦 Semantic Status & System Feedback
/// 4. 🏷️ Domain Category Tokens (Personal, Career, Family, Astro, VIP, etc.)
/// 5. 🛡️ Trust, Vouch & Identity Verification (BVS, KYC)
/// 6. 🌫️ Neutral & Surface Scale (50–900)
/// 7. 🌐 Social & Third-Party Integration
/// 8. 🌈 Central Brand Gradients
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ===========================================================================
  // 1. 👑 BRAND & CORE CULTURAL PALETTE (Light)
  // ===========================================================================
  /// Royal Crimson — Sacred identity, love, commitment & primary CTAs
  static const Color primary = Color(0xFF961B33);

  /// Deep Crimson / Sacred Maroon — Pressed states & gradient endpoints
  static const Color primaryDark = Color(0xFF731224);

  /// Soft Crimson Tint — Subtle card fills & accent chips (5–10% opacity equiv)
  static const Color primaryLight = Color(0xFFFFF1F2);

  /// Champagne Gold — Traditional warmth, auspiciousness, badges & VIP accents
  static const Color gold = Color(0xFFD4AF37);

  /// Antique / Darker Gold — High-contrast borders & text on gold surfaces
  static const Color goldDark = Color(0xFFB8922A);

  /// Soft Gold Tint — Badge backgrounds & premium highlights
  static const Color goldLight = Color(0xFFFFF8E1);

  /// Soft Warm Ivory — Default scaffold background (Light Mode canvas)
  static const Color canvasLight = Color(0xFFFAF8F5);

  /// Pure White — Card surfaces, bottom sheets & dialog backgrounds
  static const Color surfaceLight = Color(0xFFFFFFFF);


  // ===========================================================================
  // 2. 🌙 DARK MODE CORE PALETTE
  // ===========================================================================
  /// Deep Warm Charcoal / Dark Mahogany — Dark Mode scaffold background
  static const Color canvasDark = Color(0xFF1A1616);

  /// Elevated Warm Dark Surface — Cards, modal sheets & AppBars in Dark Mode
  static const Color surfaceDark = Color(0xFF262121);

  /// Elevated Card Dark — Higher elevation cards & floating controls
  static const Color cardDark = Color(0xFF2C2C2C);

  /// Soft Rose Crimson — High-contrast primary text & accents on dark backgrounds
  static const Color primaryDarkContrast = Color(0xFFFFB3B4);

  /// Soft Champagne Gold — High-contrast secondary accents in Dark Mode
  static const Color goldDarkContrast = Color(0xFFE5C158);


  // ===========================================================================
  // 3. 🚦 SEMANTIC STATUS & SYSTEM FEEDBACK
  // ===========================================================================
  // --- Success / Verified ---
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color successDark = Color(0xFF81C784);

  // --- Warning / Pending / Attention ---
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color warningDark = Color(0xFFFFB74D);

  // --- Error / Danger / Blocked ---
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorDark = Color(0xFFF2B8B5);

  // --- Info / System Guidance ---
  static const Color infoLight = Color(0xFFEFF6FF);
  static const Color infoDark = Color(0xFF81D4FA);

  // ===========================================================================
  // 4. 🏷️ DOMAIN CATEGORY TOKENS
  // ===========================================================================
  // --- Personal / Bio Details (Rose Pink) ---
  static const Color categoryPersonal = Color(0xFFEC4899);
  static const Color categoryPersonalDark = Color(0xFFDB2777);
  static const Color categoryPersonalBg = Color(0xFFFDF2F8);

  // --- Career / Education / Profession (Royal Blue) ---
  static const Color categoryCareer = Color(0xFF3B82F6);
  static const Color categoryCareerDark = Color(0xFF2563EB);

  // --- Location / Native Origin (Emerald Green) ---
  static const Color categoryLocation = Color(0xFF10B981);
  static const Color categoryLocationDark = Color(0xFF059669);

  // --- Family & Cultural Roots (Royal Purple) ---
  static const Color categoryFamily = Color(0xFF8B5CF6);
  static const Color categoryFamilyDark = Color(0xFF7C3AED);
  static const Color categoryFamilyBg = Color(0xFFF5F3FF);

  // --- Horoscope / Astrology / Kundali (Warm Amber) ---
  static const Color categoryAstro = Color(0xFFF59E0B);
  static const Color categoryAstroDark = Color(0xFFD97706);

  // --- VIP & Premium Elite (Radiant Gold) ---
  static const Color categoryVip = Color(0xFFFFD700);
  static const Color categoryVipDark = Color(0xFFFFA000);

  // --- Verification / KYC (Vibrant Cyan) ---
  static const Color categoryVerification = Color(0xFF06B6D4);
  static const Color categoryVerificationDark = Color(0xFF0891B2);

  // --- Privacy & Account Security (Deep Indigo) ---
  static const Color categorySecurity = Color(0xFF6366F1);
  static const Color categorySecurityDark = Color(0xFF4F46E5);

  // ===========================================================================
  // 5. 🛡️ TRUST, VOUCH & IDENTITY VERIFICATION
  // ===========================================================================
  /// Trust High (Score 70–100) — Highly trusted community member

  /// Trust Medium (Score 40–69) — Moderate trust, partial verification

  /// Trust Low (Score 0–39) — Unverified, needs profile completion
  static const Color trustLow = Color(0xFFEF4444);

  /// BVS (Banjara Verification Service) / DigiLocker Identity Blue
  static const Color bvsBrandBlue = Color(0xFF1E88E5);

  /// Vouch Shield Gold & Amber Glow
  static const Color vouchGoldSoft = Color(0xFFFFDF73);

  // ===========================================================================
  // 6. 🌫️ STANDARDIZED NEUTRAL & GREYSCALE RAMP
  // ===========================================================================
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);

  // --- Semantic Typography Text Colors ---
  static const Color textSecondary = Color(0xFF666666);

  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // --- Dividers & Outlines ---

  // --- Standard Shading & Shadow ---
  static const Color shadowLight = Color(0x14000000); // 8% Black
  static const Color shadowDark = Color(0x1FFFFFFF);  // 12% White Glow

  // ===========================================================================
  // 7. 🌐 SOCIAL & THIRD-PARTY INTEGRATION
  // ===========================================================================
  static const Color whatsapp = Color(0xFF25D366);
  static const Color whatsappDark = Color(0xFF128C7E);

  static const Color instagramPurple = Color(0xFF833AB4);


  // ===========================================================================
  // 8. 🌈 CENTRAL BRAND GRADIENTS
  // ===========================================================================
  /// Royal Crimson Brand Gradient (Primary CTAs & AppBars)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Romance & Connection Gradient (Heart action & Melava highlights)
  static const LinearGradient romanceGradient = LinearGradient(
    colors: [Color(0xFF880E4F), primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Champagne Gold Gradient (VIP Badges, Membership banners)
  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, Color(0xFFB8941F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Verified Trust Gradient
  static const LinearGradient trustGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Bottom Bar Navigation Gradients
  static const LinearGradient navHomeGradient = LinearGradient(
    colors: [Color(0xFF880E4F), Color(0xFF961B33)],
  );
  static const LinearGradient navMatchesGradient = LinearGradient(
    colors: [Color(0xFFFFA726), Color(0xFFFF6F00)],
  );
  static const LinearGradient navMelavasGradient = LinearGradient(
    colors: [Color(0xFF8E24AA), Color(0xFF5E35B1)],
  );
  static const LinearGradient navProfileGradient = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)],
  );
  static const LinearGradient navMenuGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
  );

  // ===========================================================================
  // 9. 🔴 EXTENDED CRIMSON / MAROON PALETTE
  // ===========================================================================
  /// Crimson Rose — Primary CTA variant & hover states (169 usages)
  static const Color crimsonRose = Color(0xFFBE123C);
  /// Deep Blood Crimson — Card header emphasis
  static const Color crimsonDeep = Color(0xFF8B1A2E);
  /// Crimson Blush — Soft accent variant
  static const Color crimsonBlush = Color(0xFFE11D48);
  /// Wine Red — Deep accent text
  static const Color wineRed = Color(0xFF9F1239);
  /// Dark Crimson Maroon — Darkest crimson shade
  static const Color crimsonMaroon = Color(0xFF881337);
  /// Material Pink (E91E63)
  static const Color materialPink = Color(0xFFE91E63);
  /// Coral Red — Danger/alert accent
  static const Color coralRed = Color(0xFFF43F5E);
  /// Soft Error Red
  static const Color softRed = Color(0xFFC94B4B);

  // ===========================================================================
  // 10. 🌑 SLATE & GRAY UI RAMP (Tailwind-inspired)
  // ===========================================================================
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // ===========================================================================
  // 11. 🌌 EXTENDED DARK CANVAS VARIANTS
  // ===========================================================================
  /// Deep Indigo-Black — Premium dark overlays
  static const Color canvasDeepDark = Color(0xFF161424);
  /// Deep Purple-Black — Subscription/Premium surfaces
  static const Color canvasRichDark = Color(0xFF1E1B2E);
  /// Midnight Indigo — Ultra-deep dark
  static const Color canvasMidnight = Color(0xFF1E1B4B);
  /// Dark Charcoal Blue — Staff/Admin surfaces
  static const Color canvasCharcoal = Color(0xFF0F0F1A);
  /// Near-Black Charcoal — Settings & dialog overlays
  static const Color canvasNearBlack = Color(0xFF1B1B24);
  /// Dark Surface 28 — Slightly lighter dark surface
  static const Color surfaceDark28 = Color(0xFF1E1E28);

  // ===========================================================================
  // 12. 🔵 EXTENDED BLUE / SKY / OCEAN
  // ===========================================================================
  /// Sapphire Blue — Career, verification & info contexts
  static const Color sapphireBlue = Color(0xFF0284C7);
  /// Sky Blue — Light accent & links
  static const Color skyBlue = Color(0xFF0EA5E9);
  /// Light Sky Blue — Dark-mode high-contrast accent
  static const Color skyBlueBright = Color(0xFF38BDF8);
  /// Material Blue 500
  static const Color materialBlue = Color(0xFF2196F3);
  /// Material Blue 700
  static const Color materialBlueDark = Color(0xFF1976D2);
  /// Darker Ocean Blue
  static const Color oceanBlueDark = Color(0xFF0369A1);

  // ===========================================================================
  // 13. 💜 EXTENDED PURPLE / VIOLET
  // ===========================================================================
  /// Deep Violet — Family & cultural gradient endpoints
  static const Color violetDeep = Color(0xFF6D28D9);
  /// Soft Violet — Dark mode accent
  static const Color violetSoft = Color(0xFFA78BFA);
  /// Indigo Soft — Dark mode category accent
  static const Color indigoSoft = Color(0xFF818CF8);
  /// Material Purple 600
  static const Color materialPurple = Color(0xFF8E24AA);
  /// Material Purple 800
  static const Color materialPurpleDark = Color(0xFF6A1B9A);
  /// Purple 700 (Material)
  static const Color materialPurple700 = Color(0xFF9C27B0);
  /// Electric Purple — Premium & subscription emphasis
  static const Color electricPurple = Color(0xFF9333EA);
  /// Deep Indigo — Ultra-premium gradient endpoint
  static const Color deepIndigo = Color(0xFF2E1065);
  /// Pale Violet Bg — Light purple background tint
  static const Color violetBg = Color(0xFFF3E8FF);
  /// Softest Violet Bg
  static const Color violetBgSoft = Color(0xFFFAF5FF);

  // ===========================================================================
  // 14. 🟢 EXTENDED GREEN / EMERALD / TEAL
  // ===========================================================================
  /// Emerald — Verified/Success primary
  static const Color emerald = Color(0xFF047857);
  /// Green Light Bg — Success background tint
  static const Color greenLightBg = Color(0xFFE8F5E9);
  /// Bright Green — Online/Active indicator
  static const Color greenBright = Color(0xFF00E676);
  /// Green 500 — Standard success
  static const Color green500 = Color(0xFF22C55E);
  /// Deep Forest — Dark green text
  static const Color greenDeepForest = Color(0xFF065F46);
  /// Teal — Secondary accent
  static const Color teal = Color(0xFF0D9488);

  // ===========================================================================
  // 15. 🟠 EXTENDED ORANGE / AMBER
  // ===========================================================================
  /// Deep Orange — Urgent/attention actions
  static const Color deepOrange = Color(0xFFE65100);
  /// Sunset Orange — Location category accent
  static const Color sunsetOrange = Color(0xFFEA580C);
  /// Amber Dark — All-details domain
  static const Color amberDark = Color(0xFFB45309);
  /// Dark Amber — Text on amber backgrounds
  static const Color amberDeepText = Color(0xFF78350F);
  /// Deep Amber Text — Darkest amber text
  static const Color amberDarkestText = Color(0xFF92400E);
  /// Material Orange 500
  static const Color materialOrange = Color(0xFFFF9800);
  /// Amber 600 — Border & accent
  static const Color amber600 = Color(0xFFFFB300);
  /// Warm Gold Soft — Badge & ribbon backgrounds
  static const Color goldSoft = Color(0xFFFBBF24);
  /// Gold Tint 200 — Light gold surface
  static const Color goldTint200 = Color(0xFFFDE68A);
  /// Gold Tint 100 — Lightest gold surface
  static const Color goldTint100 = Color(0xFFFEF3C7);
  /// Soft Gold Glow — Warm golden glow
  static const Color goldGlow = Color(0xFFFFE082);

  // ===========================================================================
  // 16. 🌸 EXTENDED PINK / ROSE TINTS
  // ===========================================================================
  /// Rose 100 — Light pink surface
  static const Color rose100 = Color(0xFFFFE4E6);
  /// Rose Pink Light — Soft pink tint
  static const Color rosePinkLight = Color(0xFFFFF4EE);
  /// Rose Blush — Ultra-soft pink bg
  static const Color roseBlush = Color(0xFFFFFBF9);

  // ===========================================================================
  // 17. 🧩 MISCELLANEOUS
  // ===========================================================================
  /// Material Deep Orange 600
  static const Color deepOrange600 = Color(0xFFFF3D00);
  /// Warm Pink — Female gender accent
  static const Color warmPink = Color(0xFFF472B6);
  /// Hot Pink — Match/Heart action
  static const Color hotPink = Color(0xFFFF416C);
  /// Sunset Blush — Gradient endpoint
  static const Color sunsetBlush = Color(0xFFFF4B2B);
  /// Material Orange 400
  static const Color orange400 = Color(0xFFFFA726);
  /// Orange Dark 900
  static const Color orangeDark900 = Color(0xFFFF6F00);
  /// Orange Amber 700
  static const Color orangeAmber700 = Color(0xFFFF8F00);
  /// Material Deep Orange 400
  static const Color deepOrange400 = Color(0xFFFF7043);

  // ===========================================================================
  // 18. 🎭 DARK CRIMSON / MAROON BG TINTS
  // ===========================================================================
  /// Deep Crimson-Black — Vouch card dark bg
  static const Color crimsonBlack = Color(0xFF1E0A12);
  /// Wine Dark — Deep maroon text/bg
  static const Color wineDark = Color(0xFF6B0E1E);
  /// Darkest Maroon — Ultra-deep surface
  static const Color maroonDarkest = Color(0xFF4A000C);
  /// Deep Crimson bg
  static const Color crimsonDarkBg = Color(0xFF4C0519);
  /// Dark Maroon accent
  static const Color maroonAccent = Color(0xFF5A000F);
  /// Blood Red bg
  static const Color bloodRedBg = Color(0xFF2C1018);
  /// Burgundy — Classic red-brown
  static const Color burgundy = Color(0xFF800020);
  /// Crimson 700 — Darker variant
  static const Color crimson700 = Color(0xFF7A1020);
  /// Material Pink 700
  static const Color materialPink700 = Color(0xFFC2185B);
  /// Rose Blush accent
  static const Color roseBlushAccent = Color(0xFFE1306C);
  /// Material Red 600
  static const Color materialRed600 = Color(0xFFE53935);

  // ===========================================================================
  // 19. 🌃 ADDITIONAL DARK SURFACE VARIANTS
  // ===========================================================================
  /// Dark Surface 30
  static const Color surfaceDark30 = Color(0xFF242430);
  /// Dark Blue-Purple
  static const Color surfaceDarkBluePurple = Color(0xFF1E1528);
  /// Dark Navy
  static const Color surfaceDarkNavy = Color(0xFF131C2E);

  // ===========================================================================
  // 20. 💎 ADDITIONAL BLUE / PURPLE ACCENTS
  // ===========================================================================
  /// Blue 300 — Soft blue accent
  static const Color blue300 = Color(0xFF93C5FD);
  /// Blue 400
  static const Color blue400 = Color(0xFF60A5FA);
  /// Blue 600
  static const Color blue600 = Color(0xFF1D4ED8);
  /// Blue 900
  static const Color blue900 = Color(0xFF172554);
  /// Blue 100 — Light blue bg
  static const Color blue100 = Color(0xFFDBEAFE);
  /// Blue 800
  static const Color blue800 = Color(0xFF1E3A8A);
  /// Light Blue 400
  static const Color lightBlue400 = Color(0xFF42A5F5);
  /// Purple 400
  static const Color purple400 = Color(0xFFA855F7);
  /// Purple Electric
  static const Color purpleElectric = Color(0xFF8E2DE2);
  /// Purple 300
  static const Color purple300 = Color(0xFFAB47BC);
  /// Purple 50
  static const Color purple50 = Color(0xFFF3E5F5);
  /// Lavender — Purple 200
  static const Color lavender = Color(0xFFD8B4FE);
  /// Violet Digital — Stack/code accent
  static const Color violetDigital = Color(0xFF6C63FF);

  // ===========================================================================
  // 21. 🟢 ADDITIONAL GREEN / NATURE TINTS
  // ===========================================================================
  /// Green 300
  static const Color green300 = Color(0xFF4ADE80);
  /// Green 400
  static const Color green400 = Color(0xFF34D399);
  /// Green 200
  static const Color green200 = Color(0xFFA5D6A7);
  /// Green 100 alt
  static const Color green100alt = Color(0xFFD1FAE5);
  /// Mint Green bg
  static const Color mintGreenBg = Color(0xFFF4FAF5);
  /// Sage Green border
  static const Color sageGreenBorder = Color(0xFFDCEDDC);
  /// Dark Forest 1
  static const Color darkForest1 = Color(0xFF142E1F);
  /// Dark Forest 2
  static const Color darkForest2 = Color(0xFF1B3D2B);
  /// Cyan A200 — Accent bright cyan
  static const Color cyanAccent = Color(0xFF64FFDA);

  // ===========================================================================
  // 22. 🟡 ADDITIONAL GOLD / AMBER VARIANTS
  // ===========================================================================
  /// Dark Gold — DarkGoldenrod
  static const Color darkGoldenrod = Color(0xFFB8860B);
  /// Bronze — Referral tier
  static const Color bronze = Color(0xFFCD7F32);
  /// Deep Amber bg dark
  static const Color amberBgDark = Color(0xFF451A03);
  /// Gold Lemon
  static const Color goldLemon = Color(0xFFFDE047);
  /// Gold Lemon Light
  static const Color goldLemonLight = Color(0xFFFCD34D);
  /// Deep Amber-Brown bg
  static const Color amberBrownBg = Color(0xFF1E1002);

  // ===========================================================================
  // 23. 🌹 ADDITIONAL ROSE / PINK
  // ===========================================================================
  /// Rose 200
  static const Color rose200 = Color(0xFFFDA4AF);
  /// Rose 400
  static const Color rose400 = Color(0xFFFB7185);

  // ===========================================================================
  // 24. 🔘 ADDITIONAL MISC
  // ===========================================================================
  /// Blue-Gray 500
  static const Color blueGray500 = Color(0xFF607D8B);
  /// Warm Dark Text
  static const Color warmDarkText = Color(0xFF2C2523);
  /// Orange Peach Bg
  static const Color orangePeachBg = Color(0xFFFFEDD5);

  // ===========================================================================
  // 🔲 STANDARD OPACITY SCALE
  // ===========================================================================
  // Named opacity constants to replace magic numbers throughout the app.
  // Usage: color.withValues(alpha: AppColors.opacity10)

  /// Ultra-subtle tint (background wash, barely visible)
  static const double opacity5 = 0.05;

  /// Hover highlight, ultra-light card shadow
  static const double opacity8 = 0.08;

  /// Background tint, soft container fill
  static const double opacity10 = 0.10;

  /// Card shadow, subtle border
  static const double opacity12 = 0.12;

  /// Soft highlight, light gradient stop
  static const double opacity15 = 0.15;

  /// Light overlay, border emphasis
  static const double opacity20 = 0.20;

  /// Medium-light overlay
  static const double opacity25 = 0.25;

  /// Subtle overlay, disabled state
  static const double opacity30 = 0.30;

  /// Medium overlay
  static const double opacity35 = 0.35;

  /// Medium-strong overlay
  static const double opacity40 = 0.40;

  /// Half-visible, balanced overlay
  static const double opacity50 = 0.50;

  /// Strong overlay
  static const double opacity60 = 0.60;

  /// Near-opaque overlay
  static const double opacity70 = 0.70;

  /// Heavy overlay
  static const double opacity80 = 0.80;

  /// Near-solid, tooltip background
  static const double opacity85 = 0.85;

  /// Almost fully opaque
  static const double opacity90 = 0.90;
}
