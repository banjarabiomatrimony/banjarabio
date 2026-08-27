import 'package:banjarabio/core/update_ecosystem/update_ecosystem.dart';

/// Central app version accessor.
/// 🚀 100% Automated — Reads live compiled version directly from the OS binary
/// via the Universal [AppUpdateManager].
///
/// Used by: Razorpay metadata, analytics, support screens.
String get kAppVersion => AppUpdateManager.currentVersionString;

/// Live structured [AppVersion] model.
AppVersion get kAppVersionModel => AppUpdateManager.currentAppVersion;

