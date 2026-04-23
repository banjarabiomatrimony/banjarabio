# DevOps & Deployment Plan - BanjaraBio

## 1. Environment Setup
*   **Development:** Local machines using Flutter SDK + staging Supabase project.
*   **Staging:** Shared test build (Firebase App Distribution or TestFlight).
*   **Production:** Main Supabase environment + Live App/Play Stores.

## 2. CI/CD Pipeline (Recommended)
*   **GitHub Actions:**
    *   *Linting:* Run `flutter analyze` on every PR.
    *   *Testing:* Run `flutter test` for core logic.
    *   *Build:* Automatically build APK/IPA when merging to `production` branch.
*   **Deployment:** 
    *   Android: Fastlane to Google Play Console.
    *   iOS: Fastlane to App Store Connect.

## 3. Branching Strategy (GitFlow)
*   `main`: Production-ready code.
*   `develop`: Integration branch for features.
*   `feature/*`: Individual feature branches.
*   `hotfix/*`: Quick fixes for production bugs.

## 4. Monitoring & Error Tracking
*   **Sentry:** For tracking client-side crashes and exceptions.
*   **Log Analytics:** Supabase logs for backend edge functions and database queries.
*   **Firebase Analytics:** For user behavior tracking (Events: PDF_GENERATE, SUBSCRIPTION_BUY).

## 5. Deployment Checklist
*   [ ] Bump version in `pubspec.yaml`.
*   [ ] Run `flutter build clean`.
*   [ ] Update ProGuard/R8 rules for Android.
*   [ ] Verify Razorpay API keys (Live mode).
*   [ ] Check App Store privacy labels (Privacy Policy).
