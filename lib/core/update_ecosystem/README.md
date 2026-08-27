# 🚀 Universal In-App Update Ecosystem

An enterprise-grade, modular, plug-and-play In-App Update and Version Enforcement System for Flutter applications.

---

## 🏛️ Layered Architecture

```
lib/core/update_ecosystem/
├── update_ecosystem.dart               # Public API barrel export
│
├── layer1_models/                      # Pure data contracts & SemVer engine
│   ├── app_version.dart               # Semantic Versioning parser (1.3.3+41 vs 1.3.0+38)
│   ├── update_type.dart               # Enum: none, softNudge, flexible, forceGate
│   ├── update_info.dart               # Standardized payload (notes, URLs, requirements)
│   └── update_config.dart             # Configuration options (cooldown, branding, sources)
│
├── layer2_contracts/                   # Abstract strategy interfaces
│   ├── update_config_source.dart      # Interface for remote version checking
│   └── update_engine.dart             # Interface for executing updates
│
├── layer3_sources/                     # Pluggable backend sources
│   ├── supabase_update_source.dart    # Production: Remote config via Supabase table
│   └── mock_update_source.dart        # QA / Testing: Deterministic mock source
│
├── layer4_engines/                     # Pluggable execution engines
│   ├── store_redirect_engine.dart     # Deep-link to Play Store / App Store
│   └── composite_update_engine.dart   # Primary engine + Fallback engine
│
├── layer5_storage/                     # Persistence & Cooldown Management
│   └── update_cooldown_manager.dart   # Prevents prompt fatigue (24h soft-nudge throttle)
│
├── layer6_ui/                          # Presentation & Theme-Adaptive Dialogs
│   ├── update_modal_theme.dart        # Customizable branding tokens
│   ├── force_update_dialog.dart       # Non-dismissible full-screen lock
│   └── soft_update_sheet.dart         # Bottom sheet with "What's New" & "Later"
│
└── layer7_orchestrator/                # Master Facade
    └── app_update_manager.dart        # Single-line API for app startup & background checks
```

---

## 🐘 Supabase Database Schema

To enable remote version control in Supabase, create the `app_config` table:

```sql
create table if not exists public.app_config (
  id text primary key default 'global',
  min_version text not null default '1.3.0',
  latest_version text not null default '1.3.3',
  force_update boolean not null default false,
  title text default 'New Update Available',
  message text default 'Please update to the latest version for the best experience.',
  release_notes jsonb default '["⚡ 3x Faster Biodata Generation", "🎨 Premium Themes Added", "🔒 Security Enhancements"]'::jsonb,
  play_store_url text default 'market://details?id=com.avishio.banjarabio',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable Read-Only Public Access
alter table public.app_config enable row level security;

create policy "Allow public read access to app_config"
on public.app_config for select
to anon, authenticated
using (true);

-- Insert Initial Seed
insert into public.app_config (id, min_version, latest_version, force_update)
values ('global', '1.3.0', '1.3.3', false)
on conflict (id) do nothing;
```

---

## 💻 Quick Start Integration

### 1. Initialize on App Startup (e.g. `main.dart` or Splash)

```dart
import 'package:banjarabio/core/update_ecosystem/update_ecosystem.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppUpdateManager.instance.initialize(
    config: AppUpdateConfig(
      source: const SupabaseUpdateSource(
        tableName: 'app_config',
        configId: 'global',
      ),
      theme: UpdateModalTheme(
        primaryColor: AppColors.primary,
        customLogo: const AppLogoImage(width: 48, height: 48),
      ),
      softUpdateCooldown: const Duration(hours: 24),
    ),
  );

  runApp(const MyApp());
}
```

### 2. Check for Updates on Screen Entry (e.g. `HomeScreen` or `SplashScreen`)

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Automatically evaluates version and presents the correct dialog if needed
    AppUpdateManager.instance.checkAndPrompt(context);
  });
}
```

---

## 🧪 Testing with Mock Source

```dart
await AppUpdateManager.instance.initialize(
  config: AppUpdateConfig(
    source: const MockUpdateSource(
      latestVersion: AppVersion(major: 2, rawVersion: '2.0.0'),
      minRequiredVersion: AppVersion(major: 1, minor: 0, rawVersion: '1.0.0'),
      forceUpdate: false,
    ),
  ),
);

// Triggers soft update bottom sheet
await AppUpdateManager.instance.checkAndPrompt(context, forceShow: true);
```
