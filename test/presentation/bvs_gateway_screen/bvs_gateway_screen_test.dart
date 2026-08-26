import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/presentation/bvs_gateway_screen/bvs_gateway_screen.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/repositories/trust_score_repository.dart';
import 'package:banjarabio/theme/app_color_scheme.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSupabaseClient fakeSupabase;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    TrustScoreRepository().testClient = fakeSupabase;
  });

  tearDown(() {
    TrustScoreRepository().testClient = null;
  });

  group('BvsGatewayScreen Widget Tests', () {
    testWidgets('renders BvsGatewayScreen structure and elements without crashing', (tester) async {
      fakeSupabase.rpcResponse = {'is_verified': false, 'bvs_status': 'none'};

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData.dark().copyWith(
                extensions: [AppColorScheme.dark()],
              ),
              home: const BvsGatewayScreen(),
            );
          },
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(BvsGatewayScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
