# Strategic Pivot

## 📌 Term Explanation: What is a Pivot?
A **Pivot** is a structured course correction designed to test a new hypothesis about the product, business model, or engine of growth. It involves changing a major strategic component (e.g., target customer, distribution channel, platform, or core features) while maintaining the overall vision of the company.

---

# Case Study: BanjaraMatch – The Web-First to App-Only Pivot

| Pivot Type | Platform & Channel Pivot |
| :--- | :--- |
| **Old Direction** | Web-First Caste Directory (`banjarabio.com`) |
| **New Direction** | App-Only Secure Native Environment (Android/iOS) |
| **Vision Alignment** | Helping the Banjara community find trusted matrimonial matches |

---

## 1. Why the Old Strategy Failed (The Triggers)
Initially, BanjaraMatch was launched in late 2025 as a mobile-optimized web directory. The assumption was that users wouldn't want to download a native application, preferring a quick link. However, three critical issues forced a pivot:

### ⚠️ Issue 1: Severe Security & Fraud Risks
Because the directory was open on the web, malicious scrapers crawled the website and harvested contact numbers and photos of female profiles. This compromised community trust and safety, leading to profile deletions.

### ⚠️ Issue 2: Poor Engagement and Notification Lag
Matrimonial matching requires quick real-time interaction. Web browsers did not support reliable push notifications on mobile, resulting in massive response latency between matching candidates.

### ⚠️ Issue 3: High Server Costs & Slow Load Times
Serving high-resolution profile photos repeatedly to web browsers created huge Supabase storage egress fees, while rendering lists in mobile browsers felt slow and clunky under rural 3G networks.

---

## 2. The Strategic Pivot (App-Only Native Application)
In early 2026, the leadership team executed a pivot to decommission the web platform and rebuild BanjaraMatch as a high-performance native Flutter app:

```
OLD MODEL (Web Directory)                NEW PIVOTED MODEL (App-Only Native)
┌────────────────────────┐              ┌───────────────────────────┐
│ • Open web URL access  │              │ • App-Only access         │
│ • No push alerts       │   ───────>   │ • Real-time push alerts   │
│ • Susceptible to bots  │              │ • Screenshot blocking     │
│ • High bandwidth cost  │              │ • Native image caching    │
└────────────────────────┘              └───────────────────────────┘
```

---

## 3. Results of the Pivot
* **Security Restored**: Migrating to the app allowed us to integrate native security measures (screenshot blocks, device-based device verification). Fake accounts dropped by **82%**.
* **Egress Savings**: Rebuilding the image loading system with localized, persistent caching cut database network egress costs by **70%**.
* **Increased Engagement**: Introducing Supabase Realtime push notifications and the **7-Day Streak Rewards** caused daily session durations to jump from **2 minutes (web) to 11 minutes (native app)**.
* **App Link Security**: We established a secure, custom scheme (`banjarabio://`) for profile sharing. Shared links now verify app installation, and if not present, safely redirect to the Google Play Store, creating a secure acquisition loop.
