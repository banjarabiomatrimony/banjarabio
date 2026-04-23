import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/routes/app_routes.dart';

void main() {
  group('AppRoutes', () {
    test('initial route is /', () {
      expect(AppRoutes.initial, '/');
    });

    test('splash route is /', () {
      expect(AppRoutes.splash, '/');
    });

    test('all routes are non-empty strings', () {
      final routes = [
        AppRoutes.initial,
        AppRoutes.splash,
        AppRoutes.authentication,
        AppRoutes.home,
        AppRoutes.profileDetail,
        AppRoutes.settings,
      ];
      for (final route in routes) {
        expect(route.isNotEmpty, true);
      }
    });

    test('authentication route is defined', () {
      expect(AppRoutes.authentication, isNotEmpty);
    });

    test('settings route is defined', () {
      expect(AppRoutes.settings, isNotEmpty);
    });
  });
}
