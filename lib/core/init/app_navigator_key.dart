import 'package:flutter/material.dart';

/// Global navigator key for context access and navigation from services.
///
/// Extracted from main.dart to break the coupling between services
/// (e.g. NotificationBridge, DeepLinkService, MatchmakingService)
/// and the app entry point.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
