import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/routes/app_routes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppRoutes Structure & Resolution Tests', () {
    test('routes map contains all core paths', () {
      final routes = AppRoutes.routes;
      expect(routes.containsKey(AppRoutes.splash), isTrue);
      expect(routes.containsKey(AppRoutes.home), isTrue);
      expect(routes.containsKey(AppRoutes.authentication), isTrue);
      expect(routes.containsKey(AppRoutes.biodataCreation), isTrue);
      expect(routes.containsKey(AppRoutes.filter), isTrue);
      expect(routes.containsKey(AppRoutes.subscription), isTrue);
      expect(routes.containsKey(AppRoutes.savedProfiles), isTrue);
      expect(routes.containsKey(AppRoutes.contactUs), isTrue);
      expect(routes.containsKey(AppRoutes.termsConditions), isTrue);
      expect(routes.containsKey(AppRoutes.privacyPolicy), isTrue);
      expect(routes.containsKey(AppRoutes.accountDeletion), isTrue);
      expect(routes.containsKey(AppRoutes.faq), isTrue);
      expect(routes.containsKey(AppRoutes.trustScore), isTrue);
      expect(routes.containsKey(AppRoutes.adminDashboard), isTrue);
      expect(routes.containsKey(AppRoutes.staffDashboard), isTrue);
      expect(routes.containsKey(AppRoutes.servicesHub), isTrue);
      expect(routes.containsKey(AppRoutes.bvsGateway), isTrue);
      expect(routes.containsKey(AppRoutes.connect), isTrue);
    });

    test('onGenerateRoute resolves valid named routes to PageRoutes', () {
      final splashRoute = AppRoutes.onGenerateRoute(const RouteSettings(name: AppRoutes.splash));
      expect(splashRoute, isNotNull);
      expect(splashRoute, isA<PageRoute>());

      final homeRoute = AppRoutes.onGenerateRoute(const RouteSettings(name: AppRoutes.home));
      expect(homeRoute, isNotNull);

      final filterRoute = AppRoutes.onGenerateRoute(const RouteSettings(name: AppRoutes.filter));
      expect(filterRoute, isNotNull);
    });

    test('onGenerateRoute handles path aliases and fallbacks', () {
      final profileDetailAlias = AppRoutes.onGenerateRoute(const RouteSettings(name: '/profile-detail'));
      expect(profileDetailAlias, isNotNull);

      final myProfileAlias = AppRoutes.onGenerateRoute(const RouteSettings(name: '/my-profile'));
      expect(myProfileAlias, isNotNull);

      final unknownRoute = AppRoutes.onGenerateRoute(const RouteSettings(name: '/unknown-nonexistent-path'));
      expect(unknownRoute, isNull);
    });
  });
}
