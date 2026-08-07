# 🏗️ BanjaraBio System Architecture & Stack Overview

This document serves as the official reference guide for the backend, cloud services, web infrastructure, and mobile app integration architecture of **BanjaraBio Matrimony**.

---

## 1. 🗄️ Supabase — Primary Database & Backend Core
> **Role**: Main database, user authentication, media storage, and backend business logic.

* **User Data & Profiles**: Stores all matrimony profiles, bio-data details, Gotra, village, preferences, bookmarks, and staff call logs.
* **Authentication (Auth / GoTrue)**: Manages Phone OTP login, user sessions, and security JWT tokens.
* **Photo & File Storage**: Stores profile photos, government ID verification documents, and generated PDF bio-data files.
* **Staff & Admin RPCs**: Runs automated server logic (e.g., `fn_staff_actions`, `fn_manage_bookmarks`, `fn_manage_safety`, search-match triggers, and lead management).

---

## 2. 🔥 Firebase — Notifications, Analytics & App Health
> **Role**: Push notifications, crash monitoring, real-time analytics, and app integrity.

* **Firebase Cloud Messaging (FCM)**: Sends instant push notifications to Android & iOS devices (e.g., *"New match found!"*, *"Someone viewed your profile"*).
* **Firebase Crashlytics**: Tracks real-time app crashes, exceptions, and performance metrics on users' devices for fast bug remediation.
* **Firebase Analytics**: Tracks user engagement, daily active users, screen navigation metrics, and onboarding conversion funnels.
* **Firebase App Check**: Protects mobile app APIs from automated bot attacks and unauthorized backend requests.

---

## 3. 🌐 Vercel — Web Hosting & Universal Deep-Linking Bridge
> **Role**: Custom domain web hosting (`banjarabio.com`), static assets, and app deep-link routing.

* **Custom Domain Hosting**: Hosts the web landing page on **`https://banjarabio.com`** and **`https://www.banjarabio.com`**.
* **Android/iOS Deep Linking**: Serves `/.well-known/assetlinks.json` so when someone clicks a shared profile link (`banjarabio.com/profile/...`) in WhatsApp, Android automatically opens the native BanjaraBio App.
* **Play Store Smart Redirect**: If a user does NOT have the BanjaraBio app installed when clicking a profile link, Vercel automatically redirects them to the Google Play Store with candidate information intact in the referrer payload.

---

## 📊 Summary Stack Matrix

| Service | Category | Core Responsibilities | Key Components |
| :--- | :--- | :--- | :--- |
| **Supabase** | Backend & Database | Profiles, Auth, Photos, Database RPCs | PostgreSQL, Supabase Storage, Auth |
| **Firebase** | Infrastructure & Monitoring | Push Notifications, Analytics, Crash Reports | FCM, Crashlytics, Analytics |
| **Vercel** | Web & Deep Linking | Web Landing Page, Custom Domain, Deep Links | `banjarabio.com`, `assetlinks.json` |

---

*Last Updated: August 2026*
