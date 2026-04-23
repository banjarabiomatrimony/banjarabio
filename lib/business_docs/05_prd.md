# Product Requirements Document (PRD) - BanjaraBio

## 1. Overview
BanjaraBio is a mobile platform designed for the Banjara community to find matrimonial matches and generate professional bio-data.

## 2. Features List
*   **User Profiles:** Detailed entry of personal, educational, and family information.
*   **Photo Management:** Upload, crop, and manage profile photos.
*   **Search & Filter:** Find matches based on age, height, location, and education.
*   **Bio-data PDF Generator:** Convert profile data into shareable PDF format.
*   **Trust Score:** Verification system for profiles using ID proofs.
*   **Subscription:** Premium access via Razorpay integration.
*   **Saved/Shared Profiles:** Bookmark interesting profiles and track shared ones.

## 3. Functional Requirements
*   **Authentication:** Phone number/OTP login (Supabase Auth).
*   **Form Validation:** Ensure mandatory fields (DOB, height, sub-caste) are filled.
*   **Offline Support:** Basic profile viewing using local storage (Shared Preferences).
*   **Concurrency:** Real-time updates for trust score and verification status.

## 4. User Stories
*   *As a user,* I want to create a professional bio-data in one click so I can share it on WhatsApp.
*   *As a parent,* I want to see verified profiles so I can trust the matches for my children.
*   *As a premium user,* I want to filter by specific sub-castes and education levels to find the perfect match.

## 5. Acceptance Criteria
*   PDF should be generated in under 3 seconds.
*   Razorpay transaction must update subscription status instantly.
*   Private photos should only be visible after user permission.

## 6. Success Metrics (KPIs)
*   User registration completion rate (>70%).
*   Number of bio-data PDFs generated per user per month.
*   Churn rate for premium subscribers.
