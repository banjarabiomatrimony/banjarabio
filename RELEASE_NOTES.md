# Release Notes - v1.3.0+38

## 🚀 What's New & Enhancements
- **Seamless New User Onboarding & Biodata Creation Flow**:
    - Resolved post-authentication navigation loop — new users signing in via Google/Email immediately advance forward to `BiodataCreationScreen` (Step 1 Personal Details) with Google metadata pre-filled.
    - Preserved smart draft resumption on app cold starts with the *"📝 Unsaved Biodata Draft Found!"* banner and one-tap resume.
- **BVS VIP Gateway & Deep Link Growth Engine**:
    - Integrated smart deep link handling for `/bvs`, custom schemes (`banjarabio://bvs`), and Play Store referrer attribution (`bvs_ref_7020797849`).
    - Upgraded WhatsApp & copy invite templates across all 5 regional languages (`mr`, `hi`, `te`, `kn`, `en`) showcasing BVS Digital Registration, Free PDF Bio-Data Generator, Privacy Shield, Melava Directory, and Multi-language support.
- **Quality & Stability**:
    - 100% static analysis pass rate (`0 issues found`).
    - Full suite of deep link and service unit tests verified.

---

# Release Notes - v1.2.9+37

## 🚩 What's New — Banjara Virasat Sangh (BVS) VIP Integration
- **BVS VIP Gateway & In-App Portal**:
    - Dedicated In-App Web Portal with SSL indicator, custom progress bar, and instant card upload dock.
    - Full-screen animated BVS Gateway with motion effects, dual emblems, and 1-tap WhatsApp automation.
    - Shining circular running-colors hero card with light sheen animation.
- **₹200/Year Subsidized Matrimony Plans**:
    - Subsidized ₹200/annual and ₹20/monthly VIP subscription pricing for verified BVS community members.
- **BVS Card Trust Score Verification**:
    - Community ID verification flow with auto-prefilled Gotra, Village, and Taluka/District.
- **Full Multi-Language Support**:
    - Complete localization in 5 languages: Marathi (मराठी), Hindi (हिंदी), Telugu (తెలుగు), Kannada (ಕನ್ನಡ), and English.
- **UI/UX Polish**:
    - Symmetrical icon-only social pill on the home AppBar.

---

# Release Notes - v1.2.11+39

## What's New & Stability Enhancements
- **Core Stability & SWR Caching Optimization**:
    - Implemented test-aware recursion guards in `ProfileRepository` background fetch triggers, eliminating race conditions and redundant network egress.
    - Hardened in-memory cache validation to deliver instant, smooth feed browsing on re-entry.
- **Backend Schema & Database Hardening**:
    - Optimized Row-Level Security (RLS) policies across `user_browse_intents`, `user_devices`, `bookmarks`, `photos`, and `messages` to use query-level InitPlan caching (`(select auth.uid())`).
    - Added covering indexes on `search_match_notifications` and `whatsapp_notification_logs` for high-throughput messaging.
    - Secured `SECURITY DEFINER` routines with explicit `search_path = public, pg_temp;` and revoked unauthenticated execution on internal database procedures.
- **Defensive Type-Safety & Crash Prevention**:
    - Hardened `PhotoModel`, `SiblingModel`, and `SubscriptionModel` JSON parsers with strict boolean equality checks, eliminating null-casting runtime errors on partial payloads.
- **Quality Assurance & Verification**:
    - 100% test pass rate across all repository unit, widget, onboarding integration, golden visual regression, and accessibility compliance suites.
    - Zero lint warnings in static analysis.

---

# Release Notes - v1.2.1+29

## What's New
- **Zero-Drop 2-Option Onboarding Flow**:
    - **Existing Users**: Seamlessly routed to direct Sign-In screen on launch.
    - **New Users Dual Gateway**: Presented with a 2-option selection gateway on initial app launch:
        - **Guest Search**: Select gender (Groom/Bride), State, and District to immediately browse community profiles as a guest without mandatory auth.
        - **Create Biodata Profile**: Direct pathway for users ready to construct their complete matrimonial profile.
    - **Conversion Hooks**: Tapping "Express Interest" or "Contact Details" triggers a non-intrusive auth modal.
    - **Clean Re-entry**: Back navigation allows exiting guest search back to the gateway selection screen.
- **Zombie Screen & Routing Cleanup**:
    - **Navigation Stack Sanitization**: Refactored the central routing hub (`StartupWorkflow.navigateBasedOnStatus`) to use `pushNamedAndRemoveUntil`, guaranteeing that previous unauthenticated onboarding or auth screens are purged from memory once a user logs in or enters guest search.
- **Auth Safety Net & Concurrency Locks**:
    - **12-Second Timeout**: Protected auth operations with a 12-second safety timeout guard to eliminate infinite loading spinners under poor network/SDK latency.
    - **Race Condition Prevention**: Enforced `_isHandlingAuth` locks on auth submission buttons.
- **Google Native OAuth Integration**:
    - Registered both Debug (`25:16...`) and Release (`0F:7C...`) SHA-1 fingerprints in Firebase Console and configured Supabase Auth Google Provider with matching Web Client ID for zero-popup native Google sign-in.

---

# Release Notes - v1.1.8+24

## What's New
- **Clean Typography Design Token System**:
    - Expanded typography from a 6-tier to a strict 9-tier design token scale (`displayLarge`, `headingLarge`, `headingMedium`, `headingSmall`, `bodyLarge`, `bodyMedium`, `bodySmall`, `labelMedium`, `labelSmall`) mapped directly to Material Design 3 guidelines.
    - Completely eliminated all arbitrary font size multipliers (`* 0.95`, `* 0.76`, etc.) across **62 files** in the codebase. Every single screen and widget now strictly references named tokens, preserving pure design consistency.
- **Matches Hub App Bar Cleanup**:
    - Removed the search bar, search query state, and search controller from the Second Tab (Matches/Share Hub) AppBar for a cleaner, more focused UI.
    - Removed the search bar guided tour target to keep onboarding flows in sync with the new layout.
- **Premium Subscription UI/UX Overhaul**:
    - **Tier-Specific Metallic Cards**: Implemented platform-specific metallic gradients and custom shadows based on the user's active membership tier (Bronze/Silver/Gold/Platinum/Eternal).
    - **Glassmorphic Navigation Tabs**: Upgraded the segmented plan tab bar to a modern glassmorphic controller with custom active-indicator gradients and slide transitions.
    - **Layered Pricing & Equated Monthly Pricing (EMP)**: Replaced flat lump-sum pricing with psychological billing breakouts showcasing equated monthly costs (e.g. `₹1,050 / month`), strike-through original MRP comparisons, and dynamic total savings banners.
    - **Gamified Trust Score Discounts**: Introduced a dynamic `TrustScoreDiscountWidget` that maps the user's profile verification points directly to active plan discounts (5% to 30%), prompting user steps to upgrade profile integrity.
    - **Single-Viewport Comparison Matrix**: Created a responsive `FeatureComparisonSheet` displaying plan comparisons side-by-side without horizontal scrolling.
    - **Clutter-Free Card Layouts**: Truncated card lists to show only top-tier benefits, linking naturally to the detailed comparison sheet.
    - **Secure Checkout Badging**: Integrated trust and 256-bit SSL secure payment indicators at the footer of each tab view.
    - **TabBar Overlap Resolution**: Hardened tab headers against label wrap collisions using flexible boundaries, unselected label scale matching, and single-line ellipsis truncation.
- **AdMob Environment Auto-Gating**:
    - Fixed a critical ad-serving bug where production AdUnit IDs were requested unconditionally on Android debug environments. The SDK now dynamically swaps to official Google Test AdUnit IDs (Banner, Rewarded, Interstitial, App Open, Native) in debug mode, preventing policy violations and ensuring test ads load successfully.
- **App-Only Deep Linking**:
    - Transitioned fully to secure app-based deep linking by removing all domain-reliant intent filters and website deep-linking configurations.
- **Enhanced Photo Cache Management**:
    - Drastically reduced bandwidth usage and backend egress. Profile photos are now stored permanently in the user's persistent local memory (disk cache) instead of being repeatedly downloaded from the server upon app restarts or view changes.
- **Premium Typographic Upgrade**:
    - Migrated the application's typographic system to a sleek and modern font pairing: **Outfit** (headings) and **Plus Jakarta Sans** (body/UI elements).
    - Bundled local `.ttf` font assets directly into the application package and removed the runtime `google_fonts` library, boosting offline rendering reliability and launch speed.
    - Centralized all typography overrides in `AppTheme`, systematically cleaning up legacy hardcoded styling across Splash, Onboarding, Trust Score Card, and Biodata editors.
- **Gender Selection & Matches Fix**:
    - Resolved a registration flow bug where newly created profiles could default to female. Users must now explicitly choose their gender, and matches correctly display opposite-gender profiles (Male to Female and Female to Male).
- **Sentry Telemetry Integration**:
    - Integrated Sentry SDK for production crash and error observability. Non-fatal errors, UI render failures, and breadcrumbs are now routed to Sentry alongside Firebase Crashlytics.
    - Switched to `SentryWidgetsFlutterBinding` to enable frame-level performance tracking (slow/frozen frame detection) from the earliest point of the application lifecycle.
    - Sentry DSN is now loaded dynamically from `env.json`. When no DSN is configured, the SDK runs in disabled (no-op) mode, eliminating previous 403 Forbidden / CSRF errors.
- **Startup Orchestration Hardening**:
    - Fixed a critical phase-advancement bug where unauthenticated/guest users were permanently stuck in the `critical` startup phase, preventing Firebase, Crashlytics, Sentry, AdMob, and background cleanup tasks from ever initialising.
    - Phase transitions (`interactive` → `background` → `idle`) now fire reliably for all users regardless of authentication state.
- **Premium Onboarding Illustrations**:
    - Replaced generic Material Design icons on the 3-page onboarding flow with custom-generated cultural illustrations: a matchmaking scene with traditional Indian attire, a trust/verification shield, and a joint-family portrait. These render in a 60% larger circular frame with bounce animation, dramatically improving first-impression conversion and brand recall.
- **Blurred Interest Preview Paywall ("Who Viewed Me")**:
    - Non-premium users now see the first 3 profile visitors clearly, followed by blurred tease cards with masked names (e.g., "Ra••••") and a lock badge overlay. Tapping a blurred card opens a bottom-sheet upgrade prompt.
  - A new premium CTA card displays the hidden count ("+N more people viewed your profile") with dual-action buttons: "Watch Ad" (rewarded unlock) and "Go Pro" (subscription). This tease-and-reveal pattern drives monetization via FOMO psychology without degrading the free-tier experience.
- **Premium Notification Permission Dialog**:
  - Completely redesigned the interstitial notification permission request popup from a plain Material dialog into a premium custom Dialog card.
  - Added a sleek brand gradient header (primary color scheme) with a floating, glowing notification bell icon inside an opacity-filled circular border.
  - Upgraded the bullet points section from plain emojis into structured `_PermissionBenefit` rows utilizing modern Material icons (`favorite_rounded`, `chat_bubble_rounded`, `star_rounded`) set inside soft, themed background circles.
  - Integrated a high-contrast premium primary CTA button wrapped in the `AppGradients.romance` Rose-to-Amethyst gradient with subtle drop shadow, paired with a clean neutral text button for "Maybe Later".

