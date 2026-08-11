# Product Roadmap

## 📌 Term Explanation: What is a Product Roadmap?
A **Product Roadmap** is a strategic, high-level planning timeline that visualizes the evolution of a product over time. It communicates the *why*, *what*, and *when* of upcoming features, aligns development teams with business objectives, and sets clear expectations for stakeholders and users.

---

# Case Study: BanjaraMatch Product Roadmap (2026)

```
2026 ROADMAP TIMELINE
========================================================================
   Q1: Foundation       Q2: Engagement       Q3: Security        Q4: Accessibility
 ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
 │ • Supabase   │ ──> │ • 7-Day      │ ──> │ • App Link   │ ──> │ • Voice      │
 │   Auth       │     │   Streak     │     │   Verify     │     │   Onboard    │
 │ • Location   │     │   Rewards    │     │ • Web Domain │     │ • Dialect    │
 │   Filters    │     │ • Trust Score│     │   Exit       │     │   Support    │
 └──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
========================================================================
```

---

## 📅 Detailed Release Plan

### 🚀 Q1 2026: Foundation & Baseline (Completed)
* **Goal**: Establish a stable, high-performance matchmaking foundation.
* **Key Deliverables**:
  * Cross-platform registration via Flutter & Supabase.
  * Hyper-local location filters (State, District, Taluka).
  * Real-time chatting infrastructure powered by Supabase WebSockets.

### 🚀 Q2 2026: Gamification & Credibility (Completed)
* **Goal**: Maximize daily active retention and user trust.
* **Key Deliverables**:
  * **7-Day Streak Rewards**: Interactive daily ladder dialog rewarding active profile views.
  * **Trust Score Framework**: Modular Riverpod implementation evaluating profile accuracy and display badges.
  * **Micro-billing Setup**: Razorpay SDK integration enabling fast UPI-based mobile passes.

### 📅 Q3 2026: Security & Domain Consolidation (In-Progress)
* **Goal**: Lock down app security, block scrapers, and transition to a native-only ecosystem.
* **Key Deliverables**:
  * **App Link Verification**: Ensure all deep links (`banjarabio.com`) verify directly on Android/iOS natively.
  * **Web-to-App Transition**: Deprecate and remove web-reliant intent filters from `AndroidManifest.xml` to prevent security leakage.
  * **Image Caching Overhaul**: Move image downloads from ephemeral `/tmp` to persistent app documents directory to reduce Supabase egress fees.

### 📅 Q4 2026: Rural Accessibility & Dialects (Planned)
* **Goal**: Remove literacy barriers and scale registrations in rural Tandas.
* **Key Deliverables**:
  * **Audio-First Onboarding**: Voice-guided registration steps using interactive audio prompts.
  * **Bolo Lambadi (Voice Profiles)**: Integration of a profile voice player allowing candidates to introduce themselves in their native tongue.
  * **Ambassador Referral Portal**: Custom dashboard in-app for verified village matchmakers to manage offline registrations.
