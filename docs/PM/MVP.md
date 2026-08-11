# Minimum Viable Product (MVP)

## 📌 Term Explanation: What is an MVP?
A **Minimum Viable Product (MVP)** is the simplest, most basic version of a product that can be released to early adopters. The primary objective of an MVP is to test core hypotheses, collect user feedback, and validate market demand with the minimum amount of time, cost, and engineering effort.

---

# Case Study: BanjaraMatch Core Matrimony Launch (MVP)

| Status | Completed (Baseline) |
| :--- | :--- |
| **Release Date** | Early 2026 |
| **Development Lifecycle** | 6 Weeks |
| **Backend Infrastructure** | Supabase (Database, Auth, Storage) |

---

## 1. Core Hypothesis to Validate
1. Will rural and semi-urban Banjara families trust a digital platform over traditional offline matchmakers?
2. Can users successfully navigate a mobile app to find matches matching their specific sub-clans (Gothras) and sub-regions (Talukas)?

---

## 2. MVP Feature Scope: What was Built vs. Cut

To launch in 6 weeks, the team strictly prioritized features that directly solved the matching problem while delaying advanced systems:

```
┌──────────────────────────────────────────────────────────────┐
│                  BANJARAMATCH MVP CORE SCOPE                 │
├──────────────────────────────┬───────────────────────────────┤
│ IN SCOPE (Must-Have)         │ OUT OF SCOPE (Deferred)       │
├──────────────────────────────┼───────────────────────────────┤
│ • Secure Phone Sign-in       │ • Social Sign-ins             │
│ • Profile: Name, Gothra,     │ • Voice Greeting & Onboarding │
│   Photo, Taluka/Location     │                               │
│ • Basic search filtering     │ • Advanced AI compatibility   │
│ • One-to-one text messaging  │ • Real-time Video calling     │
│ • Simple Admin verification  │ • Automated Trust Scoring     │
│ • Manual Profile Approval    │ • Razorpay Premium Billing    │
└──────────────────────────────┴───────────────────────────────┘
```

---

## 3. High-Yield Validation Loops in the MVP
* **Phone Auth Hook**: Rural users rarely use email. SMS auth was prioritized because it matches the standard mental model of digital tools (e.g., WhatsApp, PhonePe).
* **The Gothra Constraint**: A free-form text input for "Gothra" failed because of spelling discrepancies. We pivoted within the first week to a searchable dropdown of 45+ standard Banjara Gothras.
* **Manual Verification Screen**: Instead of building automated document readers, profiles were manually reviewed by a central admin via a simple Retool/Supabase dashboard. Profiles were marked as verified within 12 hours.

---

## 4. Key Learnings from the MVP Phase
* **Result**: BanjaraMatch MVP saw a **62% Week-2 retention rate** among early adopters.
* **Friction point**: High dropout rate on profile photo uploads because users had slow upload connections. This prompted our **Intelligent Image Caching** and image compression initiatives to ensure reliability on slow networks.
* **Conclusion**: The MVP confirmed high demand. Users wanted more engagement hooks, which led to the development of the **Minimum Lovable Product (MLP)**.
