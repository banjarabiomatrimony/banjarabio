# Universal Flutter & Mobile Development Standards

This rule establishes mandatory standards for Flutter & Mobile App development across all projects:

1. **Android 15+ Edge-to-Edge (3-Layer Coordination)**:
   - **Layer 1 (Native Kotlin)**: Call `androidx.activity.enableEdgeToEdge()` in `MainActivity.kt` `onCreate()`.
   - **Layer 2 (Launch Themes)**: Set static `android:statusBarColor` & `android:navigationBarColor` to `@android:color/transparent` in `styles.xml` and `values-night/styles.xml` to eliminate cold-start black/white bar flash on Android 10–14.
   - **Layer 3 (Flutter UI)**: Call `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` and only configure icon brightness (`statusBarIconBrightness`, `systemNavigationBarIconBrightness`). Never pass deprecated `statusBarColor` or `systemNavigationBarColor`.

2. **Android 16+ Large Screen & Adaptive Orientation**:
   - Never globally lock `DeviceOrientation.portraitUp` for all screens.
   - For smartphones (`shortestSide < 600dp`): strictly lock to portraitUp.
   - For tablets / foldables (`shortestSide >= 600dp`): enable rotation.
   - Always declare `android:resizeableActivity="true"` in AndroidManifest.xml.

3. **Android 12+ App Links & Deep Linking**:
   - Always isolate each verified domain in its own `<intent-filter android:autoVerify="true">`.
   - Do NOT include unverified/unhosted domains in `autoVerify="true"` filters.
   - Ensure `/.well-known/assetlinks.json` returns HTTP 200 directly without 301/308 redirects, with application/json and CORS headers.

4. **R8 Full Optimization Mode**:
   - Always set `android.enableR8.fullMode=true` in `android/gradle.properties`.

5. **PostgreSQL / Supabase Partitioning & Resilience**:
   - Always add a catch-all `DEFAULT` partition on partitioned tables to prevent error 23514.
   - Always wrap background notification inserts in `EXCEPTION WHEN OTHERS THEN` blocks to protect core user data transactions.

6. **Onboarding & Draft Resumption**:
   - Active in-app sign-in routes directly forward with pre-filled metadata.
   - Cold starts with incomplete profiles display a one-tap resume banner.
