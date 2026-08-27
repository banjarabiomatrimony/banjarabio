/// 🎯 [UpdateType]
///
/// Declares the enforcement level of an application update.
enum UpdateType {
  /// The app is currently up to date; no action needed.
  none,

  /// Soft nudge: Minor improvements, bug fixes, or enhancements.
  /// Dismissible by the user with anti-fatigue cooldown.
  softNudge,

  /// Flexible update: Downloaded in the background while the user continues app usage.
  flexible,

  /// Hard gate (Force Update): Critical security patch, breaking API change,
  /// or schema deprecation. Un-dismissible full-screen barrier.
  forceGate,
}
