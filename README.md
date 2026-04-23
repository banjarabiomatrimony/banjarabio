# 🌾 BanjaraMatch

**BanjaraMatch** is a premium, high-performance matrimony application tailored specifically for the Banjara community. Built with a focus on speed, reliability, and "Audio-First" accessibility, it provides a seamless matchmaking experience even in low-connectivity areas.

---

## 🚀 Key Features

### 💎 Gamified Retention
- **Daily Login Rewards**: A 7-day streak-based reward system offering bonus profile views, bookmarks, and a weekly "Jackpot" (Free Message Unlock).
- **Matchmaking Engine**: Advanced filtering by state, district, taluka, and age.
- **Instant Messaging**: Real-time chat powered by Supabase Realtime, with smart daily limits for free users.

### 🛡️ App Stability & Performance
- **Proactive ANR Prevention**: A custom `GlobalWatchdog` monitors main-thread health with dual-clock verification to prevent "Input Dispatching Timed Out" errors on Android 15/16.
- **Intelligent Image Caching**: Automated image cache management that balances memory footprint with scrolling smoothness.
- **Safe Native Interop**: Production-hardened image processing with concurrency guards for native activities (e.g., Image Cropper).

---

## 🏗️ Technical Architecture

BanjaraMatch is built on a 10/10 architecture designed to scale to millions of users:

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Frontend** | **Flutter** | Cross-platform UI with "Audio-First" accessibility support. |
| **Backend** | **Supabase** | Auth, Postgres (DB), Realtime, and Edge Functions. |
| **State** | **Riverpod** | Reactive, testable, and robust state management. |
| **Caching** | **Hive + In-Memory** | Triple-layer caching strategy: Memory -> Disk -> Network. |

### 🛠️ Performance Highlights
1. **N+1 Optimization**: Parallelized network requests using `Future.wait` for batch enrichment of profile data (photos, bookmarks, matches).
2. **Isolate Offloading**: Heavy JSON parsing and data transformation performed in background isolates to keep the UI thread buttery smooth (60+ FPS).
3. **Read Replication**: Leverages Read Replicas for discovery feed lookups to ensure O(1) performance scaling.

---

## 📂 Project Structure

```text
lib/
├── core/                # Core business logic, services, and models
│   ├── repositories/    # SWR (Stale-While-Revalidate) data layers
│   ├── services/        # Watchdog, Local Cache, Deep Link routing
│   └── models/          # Type-safe data structures
├── presentation/        # UI Layer (Screens & ViewModels)
│   ├── home_screen/     # High-performance discovery feed
│   ├── chat/            # Real-time messaging
│   └── photo_management/ # Native-guarded image workflows
├── widgets/             # Specialized UI components (Rewards Dialog, etc.)
└── main.dart            # Multi-environment entry point
```

---

## 🛠️ Setup & Development

### Prerequisites
- **Flutter SDK**: `^3.38.4`
- **Supabase Account**: Required for backend services.
- **Android SDK**: API 35+ recommended (Android 15 support).

### Getting Started
1. **Clone & Install**:
   ```bash
   git clone https://github.com/banjarabiomatrimony/banjarabio.git
   cd banjarabio
   flutter pub get
   ```

2. **Environment Configuration**:
   Create an `env.json` file in the root directory:
   ```json
   {
     "SUPABASE_URL": "your_url",
     "SUPABASE_ANON_KEY": "your_key"
   }
   ```

3. **Run**:
   ```bash
   flutter run
   ```

---

## 📈 Roadmap & Strategy
- [x] **7-Day Reward Ladder**: Boosting DAU via gamification.
- [x] **Visual-First UI**: Reducing churn by optimizing for high-impact visual identification.
- [ ] **Audio-First Overhaul**: Implementation of voice-guided onboarding for better accessibility.
- [ ] **App Link Verification**: Finalizing `banjarabio.com` deep-link support.

---

Built with ❤️ for the Banjara Community.
