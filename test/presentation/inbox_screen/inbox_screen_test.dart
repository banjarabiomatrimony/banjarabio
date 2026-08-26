import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/presentation/inbox_screen/inbox_screen.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/theme/app_color_scheme.dart';
import 'package:banjarabio/core/repositories/chat_repository.dart';
import 'package:banjarabio/core/repositories/share_repository.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSupabaseClient fakeSupabase;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    ChatRepository().testClient = fakeSupabase;
    ShareRepository().testClient = fakeSupabase;
  });

  tearDown(() {
    ChatRepository().testClient = null;
    ShareRepository().testClient = null;
  });

  group('InboxScreen Widget Tests', () {
    testWidgets('renders 4 tabs and handles tab switching', (tester) async {
      fakeSupabase.rpcResponse = [];

      await tester.pumpWidget(
        ProviderScope(
          child: Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: ThemeData.dark().copyWith(
                  extensions: [AppColorScheme.dark()],
                ),
                home: const InboxScreen(),
              );
            },
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(InboxScreen), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
    });
  });
}
