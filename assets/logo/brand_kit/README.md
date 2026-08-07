# BanjaraBio Brand Assets Usage Guide

This directory contains the finalized, high-end corporate brand assets for **BanjaraBio**. Below is the specification of each asset and where they must be integrated to maintain a premium, consistent visual identity across all platforms.

---

## 📁 Core Assets Overview

Inside this directory, you will find three master assets:
1. **`primary.png`** (Combination Logo: Icon + Wordmark)
2. **`icon.png`** (Standalone Cultural Icon)
3. **`wordmark.png`** (Standalone Typographic Wordmark)

---

## 🎨 Asset Usage Specifications

### 1. Primary Logo (`primary.png`)
* **What it is**: The combination of the stylized cultural icon (Banjara couple) and the geometric typographic wordmark.
* **Where to use it**:
  * **App Splash / Launch Screen**: The very first screen users see when the application loads.
  * **Onboarding & Authentication Screens**: Login, Sign Up, and initial registration screens where brand recognition is established.
  * **App Store & Google Play Store Banner / Feature Graphic**: High-visibility store listings.
  * **Official Website & Landing Page**: In the main hero section of the landing page.
  * **Marketing & Advertising**: Social media posts, banners, brochures, and print materials.

### 2. Standalone Icon (`icon.png`)
* **What it is**: The clean Banjara symbol (bride & groom icon) without any text.
* **Where to use it**:
  * **Android & iOS App Launcher**: The icon that sits on the user's home screen or app drawer.
  * **Push Notification Large Icon**: Displayed in mobile notifications.
  * **Web Favicon**: The tiny 16x16 or 32x32 icon in the web browser tab.
  * **Social Media Profile Pictures**: Instagram, Facebook, LinkedIn, and Twitter/X profiles.
  * **App Navigation Footer/Tab Bar**: As the "Home" or "Dashboard" tab indicator.

### 3. Standalone Wordmark (`wordmark.png`)
* **What it is**: The typographic name "BanjaraBio" with the refined Avenir Next lowercase aesthetic and the custom cultural bindi accent dot on the "i".
* **Where to use it**:
  * **App Header Navigation Bar (AppBar)**: Placed in the center or left-aligned of the navigation bar at the top of active app screens.
  * **Invoices, PDF Biodatas, & Receipts**: Headers for generated PDF documents and billing invoices.
  * **Email Headers**: In the header banner of transactional or promotional emails.
  * **Footer Panels**: In the bottom footer of websites or settings pages where a clean, horizontal name is required.

---

## 🔧 Technical Integration Guide for Flutter

* **App Launcher Icon Setup**: Run `flutter_launcher_icons` configured with `icon.png` to generate adaptive and round icons.
* **App Bar Header Integration**:
  ```dart
  AppBar(
    title: Image.asset(
      'assets/logo/brand_kit/wordmark.png',
      height: 32, // Recommended height for AppBar text
      fit: BoxFit.contain,
    ),
    backgroundColor: Colors.white,
    elevation: 0,
  )
  ```
* **Splash Screen Layout**:
  ```dart
  Center(
    child: Image.asset(
      'assets/logo/brand_kit/primary.png',
      width: 250, // Recommended display width
      fit: BoxFit.contain,
    ),
  )
  ```
