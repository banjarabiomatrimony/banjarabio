import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:banjarabio/presentation/splash_screen/splash_screen.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockGoTrueClient mockAuth;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({'selected_locale': 'en'});
    mockAuth = MockGoTrueClient();
    AppSupabaseClient.testAuth = mockAuth;
    // Ensure we don't trigger real secure storage or other plugins
  });

  group('SplashScreen', () {
    testWidgets('renders splash screen elements', (WidgetTester tester) async {
      await tester.runAsync(() async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const SplashScreen(),
            // Provide a stub route generator to prevent "onUnknownRoute" errors
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => Scaffold(body: Text('Target: ${settings.name}')),
            ),
          ),
        ));
        
        await tester.pump();
        expect(find.byType(SplashScreen), findsOneWidget);
        
        // Let animations start
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('BanjaraBio'), findsOneWidget);
        
        // Let any pending microtasks and timers run to avoid leaks
        await tester.pumpAndSettle(const Duration(seconds: 1));
      });
    });

    test('SplashScreen can be constructed', () {
      const screen = SplashScreen();
      expect(screen, isA<StatefulWidget>());
    });
  });
}
