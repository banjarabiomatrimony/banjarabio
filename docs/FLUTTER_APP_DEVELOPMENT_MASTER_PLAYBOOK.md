# 📱 Universal Flutter & Mobile App Development Master Playbook
> **Permanent Memory & Architectural Standard for all Flutter Projects**  
> *Targeting Modern Android (API 31–36+ / Android 15 & 16+) and iOS Production Deployments*

---

## 1. 🖼️ Modern Edge-to-Edge & System UI Standards (Android 15+ / API 35+)

### ❌ Strictly Deprecated & Forbidden
Never pass explicit background colors to system bars in Flutter or Android native code:
* `statusBarColor` ➔ **DEPRECATED** (Android 15+ enforces transparent window insets natively)
* `systemNavigationBarColor` ➔ **DEPRECATED**
* `systemNavigationBarDividerColor` ➔ **DEPRECATED**
* `android.view.Window.setStatusBarColor()` / `setNavigationBarColor()` ➔ **DEPRECATED**

### 🔍 How Edge-to-Edge is Fully Coordinated Across 3 Layers

1. **Native Android Layer (`MainActivity.kt`)**:
   - Calls AndroidX Jetpack `enableEdgeToEdge()` in `onCreate()` before superclass initialization.
   - **On Android 10–14 (API 29–34)**: Automatically sets `decorFitsSystemWindows(false)` and ensures backward-compatible system insets.
   - **On Android 15+ (API 35+)**: Works natively with the operating system's default edge-to-edge window rules.
   ```kotlin
   package com.example.app

   import android.os.Bundle
   import androidx.activity.enableEdgeToEdge
   import io.flutter.embedding.android.FlutterFragmentActivity

   class MainActivity : FlutterFragmentActivity() {
       override fun onCreate(savedInstanceState: Bundle?) {
           enableEdgeToEdge() // Backward-compatible AndroidX edge-to-edge
           super.onCreate(savedInstanceState)
       }
   }
   ```

2. **Window Launch Themes (`styles.xml` & `values-night/styles.xml`)**:
   - Set static `android:statusBarColor` and `android:navigationBarColor` to `@android:color/transparent` for `LaunchTheme` and `NormalTheme`.
   - **Benefit**: Eliminates any black/white flash on cold boot on Android 10–14 devices while the Flutter engine is loading.
   ```xml
   <style name="LaunchTheme" parent="Theme.MaterialComponents.Light.NoActionBar">
       <item name="android:windowBackground">@drawable/launch_background</item>
       <item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
       <item name="android:statusBarColor">@android:color/transparent</item>
       <item name="android:navigationBarColor">@android:color/transparent</item>
   </style>
   <style name="NormalTheme" parent="Theme.MaterialComponents.Light.NoActionBar">
       <item name="android:windowBackground">?android:colorBackground</item>
       <item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
       <item name="android:statusBarColor">@android:color/transparent</item>
       <item name="android:navigationBarColor">@android:color/transparent</item>
   </style>
   ```

3. **Flutter UI Layer (`SystemChromeConfig.dart` & Custom AppBars)**:
   - Activates `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`.
   - Controls status bar and navigation bar icon contrast dynamically without calling deprecated color setter methods.
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter/services.dart';

   class SystemChromeConfig {
     static void configure() {
       // Enable Edge-to-Edge window mode
       SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

       // ONLY configure icon/text brightness for contrast — NEVER pass color parameters!
       SystemChrome.setSystemUIOverlayStyle(
         const SystemUiOverlayStyle(
           statusBarIconBrightness: Brightness.dark,
           statusBarBrightness: Brightness.light,
           systemNavigationBarIconBrightness: Brightness.dark,
         ),
       );
     }
   }
   ```

4. **In `CustomAppBar` / Widgets**:
   ```dart
   // When customizing AppBar system overlay, NEVER pass statusBarColor:
   systemOverlayStyle: SystemUiOverlayStyle(
     statusBarIconBrightness: theme.brightness == Brightness.light
         ? Brightness.dark
         : Brightness.light,
     statusBarBrightness: theme.brightness,
   )
   ```

---

## 2. 📐 Large Screen, Foldable & Tablet Orientation Rules (Android 16+)

Starting in **Android 16**, Google ignores fixed portrait orientation locks on large-screen devices (tablets, Chromebooks, foldables).

### ✅ The Standard Adaptive Orientation Pattern
* 📱 **Smartphones (`shortestSide < 600dp`)**: Strictly locked to **Portrait Only** (`DeviceOrientation.portraitUp`) to prevent accidental rotation.
* 💻 **Tablets / Large Screens / Foldables (`shortestSide >= 600dp`)**: **Full rotation enabled** (`portraitUp`, `portraitDown`, `landscapeLeft`, `landscapeRight`).

```dart
// In SystemChromeConfig.dart
static void adaptOrientationForScreen(BuildContext context) {
  final double shortestSide = MediaQuery.of(context).size.shortestSide;
  if (shortestSide >= 600) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
}
```

* **In `AndroidManifest.xml`**:
  Ensure all activities maintain:
  ```xml
  android:resizeableActivity="true"
  ```

---

## 3. 🔗 Android 12+ App Links & Deep Linking Domain Architecture

### ❌ The Common Pitfall (Grouped Intent Filters)
In Android 12+ (API 31+), if multiple domains are grouped inside a single `<intent-filter android:autoVerify="true">`, **failure of even ONE domain fails verification for ALL domains**.

### ✅ The Standard Multi-Domain Manifest Pattern
1. **Always Isolate Each Verified Domain into its own Intent Filter**:
   ```xml
   <!-- Domain 1: Staging / Vercel Domain -->
   <intent-filter android:autoVerify="true">
       <action android:name="android.intent.action.VIEW" />
       <category android:name="android.intent.category.DEFAULT" />
       <category android:name="android.intent.category.BROWSABLE" />
       <data android:scheme="https" android:host="app.vercel.app" />
   </intent-filter>

   <!-- Domain 2: Primary Production Domain (www) -->
   <intent-filter android:autoVerify="true">
       <action android:name="android.intent.action.VIEW" />
       <category android:name="android.intent.category.DEFAULT" />
       <category android:name="android.intent.category.BROWSABLE" />
       <data android:scheme="https" android:host="www.yourdomain.com" />
   </intent-filter>

   <!-- Domain 3: Apex Domain -->
   <intent-filter android:autoVerify="true">
       <action android:name="android.intent.action.VIEW" />
       <category android:name="android.intent.category.DEFAULT" />
       <category android:name="android.intent.category.BROWSABLE" />
       <data android:scheme="https" android:host="yourdomain.com" />
   </intent-filter>
   ```

2. **Move Unhosted / Future Domains to Fallback Filter (No `autoVerify`)**:
   Never put unconfigured or unpurchased domains in `autoVerify="true"`.

3. **Web Server / Vercel AssetLinks Requirements**:
   * Must serve `https://<domain>/.well-known/assetlinks.json` directly with `HTTP 200 OK` (Google bot **does NOT follow 301/308 redirects**).
   * Headers in `vercel.json`:
     ```json
     {
       "source": "/.well-known/assetlinks.json",
       "headers": [
         { "key": "Content-Type", "value": "application/json" },
         { "key": "Access-Control-Allow-Origin", "value": "*" },
         { "key": "Cache-Control", "value": "public, max-age=86400" }
       ]
     }
     ```
   * Include **both** the Google Play App Signing key fingerprint and the local upload keystore fingerprint in `sha256_cert_fingerprints`.

---

## 4. ⚡ R8 Full Mode & Performance Shrinking

1. **In `android/gradle.properties`**:
   ```properties
   # Enable R8 Full Mode optimization
   android.enableR8.fullMode=true
   android.useAndroidX=true
   android.enableJetifier=false
   ```

2. **In `android/app/build.gradle.kts`**:
   ```kotlin
   buildTypes {
       release {
           isMinifyEnabled = true
           isShrinkResources = true
           proguardFiles(
               getDefaultProguardFile("proguard-android-optimize.txt"),
               "proguard-rules.pro"
           )
       }
   }
   ```

---

## 5. 🗄️ Database Partitioning & Resilient Triggers (PostgreSQL / Supabase)

### ❌ The Partition Crash (SQLSTATE `23514`)
Partitioned tables by `created_at` or `date` will crash `INSERT` operations with `code 23514 (no partition found for row)` whenever a timestamp exceeds existing partition ranges.

### ✅ The 2 Golden Rules for Partitioned Tables:
1. **Always Create a Catch-All `DEFAULT` Partition**:
   ```sql
   CREATE TABLE IF NOT EXISTS public.notification_queue_default 
       PARTITION OF public.notification_queue DEFAULT;
   ```
   *(A `DEFAULT` partition makes partition routing errors mathematically impossible for any future timestamp).*

2. **Always Protect Background Notification Triggers with Sub-Transactions**:
   ```sql
   BEGIN
       -- Auxiliary background task
       INSERT INTO public.notification_queue (...) VALUES (...);
   EXCEPTION WHEN OTHERS THEN
       -- Log warning, but NEVER crash or abort primary user profile/message transaction!
       RAISE WARNING 'Background task warning (non-fatal): %', SQLERRM;
   END;
   ```

---

## 6. 🚀 Frictionless Onboarding & Cold-Launch State Restoration

* **Scenario 1 — In-App Active Flow**: When a user taps *"Create Account / Create Biodata"* and completes Google/Email Sign-In, route them **directly forward** to the target creation screen with their OAuth metadata pre-filled (no going backwards or re-selecting options).
* **Scenario 2 — App Killed & Reopened (Cold Launch)**:
  * **Completed Profile**: Active session + Profile exists ➔ Open `HomeScreen` directly.
  * **Incomplete Profile / Draft Saved**: Active session + No profile ➔ Open Selection Gateway with a **`📝 Resume Saved Draft`** banner and one-tap restore without re-login.
  * **Guest / Unauthenticated**: Open Selection Gateway cleanly.

---

## 7. 🛡️ Text Scaling & Accessibility Guardrails

Always clamp text scaling in `MaterialApp.builder` to prevent layout overflows on devices with 200%+ large system accessibility fonts:
```dart
builder: (context, child) {
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaleConfig.getClampedTextScaler(context), // e.g. clamped between 0.85x and 1.25x
    ),
    child: child!,
  );
}
```

---

## 8. 📢 AdMob & Native Lifecycle Timing

* **AppOpen Ads**: Never trigger AppOpen ads on cold launch (causes WebView race conditions with native embedding). Only show on `AppLifecycleState.resumed` when `_hasBeenResumed == true`.
* **ANR Prevention**: Defer heavy SDK initialization (Crashlytics, FCM background message channels, Analytics) to post-first-frame or phased idle orchestrators.
