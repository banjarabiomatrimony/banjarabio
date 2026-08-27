# App Version Management & Ecosystem Synchronization Rule

## Core Directives for Version Bumping

Whenever the application version is updated, the following steps MUST be executed atomically without leaving any discrepancies:

1. **`pubspec.yaml`**:
   - Update `version: x.y.z+build` (e.g., `1.3.4+42`).

2. **`lib/core/constants/app_version.dart`**:
   - Synchronize `kAppVersion` constant to match `pubspec.yaml` (e.g., `const String kAppVersion = '1.3.4+42';`).

3. **In-App Update Ecosystem (`lib/core/update_ecosystem/`)**:
   - The app's `SupabaseUpdateSource` automatically syncs the new version to Supabase `app_config.latest_version` on first boot via `fn_sync_app_version()`.
   - Never hardcode old version numbers in fallback configurations.

4. **Release Notes & Changelog**:
   - When introducing major new capabilities, verify or update the default release notes list in `app_config` migration or Supabase dashboard so users see relevant bullet points upon update prompt.

5. **Testing Verification**:
   - Run `flutter test test/core/update_ecosystem/` to ensure all SemVer parser rules and update evaluation logic remain 100% compliant.
