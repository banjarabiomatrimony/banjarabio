import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:banjarabio/presentation/account_screen/account_screen.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';

class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockBox extends Mock implements Box<dynamic> {}

void main() {
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late MockBox mockBox;

  setUp(() {
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();
    mockBox = MockBox();
    AppSupabaseClient.testAuth = mockAuth;
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user');
    when(() => mockUser.email).thenReturn('test@test.com');
    LocalCacheService().testBoxOpener = (name) => mockBox;
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.get(any(), defaultValue: any(named: 'defaultValue'))).thenReturn(null);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});
  });

  Widget createWidget() => Sizer(
    builder: (context, orientation, deviceType) => const ProviderScope(
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: AccountScreen(),
      ),
    ),
  );

  testWidgets('renders settings screen with scaffold', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
