import 'package:flutter/material.dart';

/// Premium page transitions that give the app a polished, high-end feel.
/// Replaces the default MaterialPageRoute slide with:
///   • Fade-through for standard navigations
///   • Slide-up for bottom sheets / detail screens
///   • Scale-fade for dialogs and overlays

// ─────────────────────────────────────────────────────────────
// 1.  Fade-through transition  (default for all routes)
// ─────────────────────────────────────────────────────────────
class FadeThroughPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadeThroughPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 250),
    super.settings,
  }) : super(
         transitionDuration: duration,
         reverseTransitionDuration: const Duration(milliseconds: 200),
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // 🚀 10M DAU: Pure fade — no ScaleTransition.
           // Scale forces a full layout pass on the incoming widget tree
           // during its very first frame, causing janky transitions on
           // mid-range devices. Simple fade is GPU-composited and free.
           final fadeIn = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOut,
           );

           final fadeOut = CurvedAnimation(
             parent: secondaryAnimation,
             curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
           );

           return FadeTransition(
             opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fadeIn),
             child: FadeTransition(
               opacity: Tween<double>(begin: 1.0, end: 0.7).animate(fadeOut),
               child: child,
             ),
           );
         },
       );
}


// ─────────────────────────────────────────────────────────────
// 2.  Slide-up transition  (for detail / full-screen pages)
// ─────────────────────────────────────────────────────────────
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpPageRoute({required this.page, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );

          final fade = CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          );

          return SlideTransition(
            position: slide,
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(fade),
              child: child,
            ),
          );
        },
      );
}

// ─────────────────────────────────────────────────────────────
// 3.  Scale-fade transition  (for dialogs and overlays)
// ─────────────────────────────────────────────────────────────
class ScaleFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScaleFadePageRoute({required this.page, super.settings})
    : super(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        opaque: false,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          );
          return ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curved),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      );
}

// ─────────────────────────────────────────────────────────────
// 4.  Helper to build routes from the named-route map
// ─────────────────────────────────────────────────────────────

/// Detail-screen routes that should use slide-up transition.
const _slideUpRoutes = <String>{
  '/profile-detail-screen',
  '/subscription',
  '/filter-screen',
  '/biodata-creation-screen',
  '/biodata-editor',
  '/biodata-pdf-screen',
  '/biodata-pdf-screen-riverpod',
  '/photo-management-screen',
  '/chat-screen',
};

/// Build a premium route from a [WidgetBuilder] and [RouteSettings].
Route<dynamic> buildPremiumRoute(
  WidgetBuilder builder,
  RouteSettings settings,
) {
  final page = Builder(builder: builder);

  if (_slideUpRoutes.contains(settings.name)) {
    return SlideUpPageRoute(page: page, settings: settings);
  }
  return FadeThroughPageRoute(page: page, settings: settings);
}
