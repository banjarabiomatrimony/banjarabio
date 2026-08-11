# BanjaraBio "Zero-Drop" 10/10 Onboarding Architecture Specification

## 📌 Executive Summary
The **Zero-Drop Onboarding Architecture** is BanjaraBio's flagship user acquisition and retention framework. Designed to eliminate bounce rates on first launch, it provides a tailored dual-path gateway that separates passive discovery (Guest Search) from high-intent account creation (Biodata Profile), backed by robust navigation stack sanitization and authentication safety guards.

---

## 🎯 Core Product Objectives & KPIs
1. **Zero Bounce Rate:** Every visitor achieves immediate utility without forced registration barriers.
2. **Instant Gratification:** Guest users preview relevant community profiles in < 3 seconds based on location and gender filters.
3. **High-Intent Conversion:** Non-intrusive triggers prompt registration only when high-value actions (Expressing Interest, Contact Access, Chat) are initiated.
4. **Zero Zombie Screens:** Pure memory heap lifecycle—unauthenticated onboarding/auth screens are purged immediately upon login.

---

## 🔀 Gateway User Flow Architecture

```
                       ┌─────────────────────────┐
                       │     App Launch Boot     │
                       └────────────┬────────────┘
                                    │
                         Is Session Authenticated?
                                   / \
                             YES  /   \  NO
                                 /     \
    ┌───────────────────────────┐       ┌───────────────────────────────┐
    │  Direct Route to Dashboard│       │   User Type Selection Gateway │
    │   (Home / Admin / Staff)  │       │   (UserTypeSelectionScreen)   │
    └───────────────────────────┘       └───────────────┬───────────────┘
                                                        │
                                    ┌───────────────────┴───────────────────┐
                                    ▼                                       ▼
                       ┌────────────────────────┐              ┌────────────────────────┐
                       │   Option 1: Existing   │              │     Option 2: New      │
                       │   (Direct Login Auth)  │              │   (Onboarding Options) │
                       └───────────┬────────────┘              └───────────┬────────────┘
                                   │                                       │
                       Authenticate via OTP/Google             Redirect to Onboarding
                                   │                           Selection Dual-Gateway
                                   ▼                                       │
                       Identity Intelligence Check                         ▼
                       (Existing Profile Found ->              Search Matches OR Create
                       Welcome Back Toast -> Dashboard)        Profile (Gated Auth)
```

---

## 🚀 Key Functional Components

### 1. Zero-Drop Dual Gateway (`OnboardingSelectionScreen`)
- **Direct Login Link:** Existing users can jump straight to email/OTP/Google sign-in.
- **Option A — Guest Search:**
  - Fast selection: Groom/Bride, State, and District selectors.
  - Allows immediate read-only browsing of verified community profiles.
  - **Conversion Hooks:** Tapping "Express Interest" or "View Phone Number" opens an inline Auth Modal.
  - Clean back-navigation allows returning to the gateway selection screen smoothly.
- **Option B — Create Biodata Profile:**
  - Direct pathway for users ready to construct their complete matrimonial profile.

### 2. Native Google OAuth & Auth Safety Guards (`AuthRepository` & `AuthenticationScreen`)
- **Native Google ID Token Exchange:** Uses `google_sign_in` to fetch native `idToken` and pass to `Supabase.auth.signInWithIdToken` without external web view popups.
- **12-Second Safety Timeout Guard:** Prevents infinite loading spinners by auto-dismissing loading overlays on network or SDK timeout.
- **Concurrency Lock (`_isHandlingAuth`):** Guards interactive CTA buttons against duplicate taps during active requests.
- **Dev/QA Test Credential Switcher:** Enables instant switching between test roles (Admin, Staff, Volunteer, User).

### 3. Zombie Screen Elimination & Stack Sanitization (`StartupWorkflow`)
- **Problem Fixed:** Standard `pushReplacementNamed` leaves underlying routes in Flutter's `Navigator` stack, causing zombie screens to remain active in memory behind the main dashboard.
- **Implementation:** Centralized routing hub standardizes on `pushNamedAndRemoveUntil(context, route, (route) => false)`.
- **Memory Guarantee:** When transitioning from Onboarding/Auth to Dashboard (or vice versa on logout), the entire previous stack is purged and garbage collected.

---

## 🛠️ Configuration & Credentials Reference

| Parameter | Configuration Target | Description |
| :--- | :--- | :--- |
| **Android App ID** | `com.avishio.banjarabio` | Registered in Google Cloud & Firebase Console |
| **Debug SHA-1** | `25:16:8A:5A:41:75:EB:EB:D7:B6:E7:B3:47:B1:A3:31:A5:AF:D0:18` | Registered in Firebase (`banjarabio-8818a`) |
| **Release SHA-1** | `0F:7C:CD:EE:62:4D:44:E0:7B:B4:A1:38:32:6D:E2:77:B1:F9:D7:19` | Registered in Firebase (`upload-keystore.jks`) |
| **Google Web Client ID** | `1026269288051-nplp4gcf61h6e3gqq6e6ol5e015cpgcu.apps.googleusercontent.com` | Defined in `assets/env.json` & Supabase Auth Provider |

---

## 📂 Key Source Code Reference

- `lib/presentation/authentication_screen/authentication_screen.dart` — Auth UI state machine & timeout locks.
- `lib/core/repositories/auth_repository.dart` — Native Google Sign-In & Supabase session handling.
- `lib/core/utils/startup_workflow.dart` — `pushNamedAndRemoveUntil` route stack sanitization.
- `android/app/google-services.json` — Firebase Google client configuration.

---
*Document Version: 1.0 | App Build: v1.2.1+29 | Last Updated: 2026-08-10*
