import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to broadcast the currently active tab index to sub-widgets.
/// Used by BannerAdWidget to dispose its native WebView when the Home tab
/// is not visible, preventing resource ID crashes on memory-constrained devices.
final homeTabProvider = StateProvider<int>((ref) => 0);
