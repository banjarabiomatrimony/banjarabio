# Technical Requirements Document (TRD) - BanjaraBio

## 1. Architecture Overview
*   **Pattern:** Clean Architecture with Repository Pattern.
*   **State Management:** BloC or Provider (implied by file structure/services).
*   **Folder Structure:** 
    *   `core/`: Models, Repositories, Services.
    *   `presentation/`: UI screens and widgets.
    *   `widgets/`: Global reusable UI components.

## 2. Tech Stack
*   **Frontend:** Flutter (Cross-platform iOS/Android/Web).
*   **Backend:** Supabase (PostgreSQL, Auth, Storage, Edge Functions).
*   **Language:** Dart 3.x.
*   **UI Components:** Google Fonts, Flutter SVG, Sizer (Responsive).

## 3. Third-party Integrations
*   **Database & Auth:** Supabase.
*   **Payments:** Razorpay.
*   **Image Processing:** Image Picker, Image Cropper, Flutter Image Compress.
*   **Document Generation:** `pdf` and `printing` packages.
*   **Communication:** WhatsApp (via `url_launcher`), `share_plus`.

## 4. Key Security Requirements
*   **Data Encryption:** Use SSL for all API calls.
*   **Privacy:** Secure storage of user session tokens in `shared_preferences`.
*   **Permissions:** Request runtime permissions for Camera, Storage, and Location.

## 5. Performance Goals
*   **Load Time:** Splash screen to Home in < 2 seconds.
*   **Offline Mode:** Cache profile listings for instant viewing.
*   **Media Optimization:** Compress images before uploading to Supabase Storage to save bandwidth.
