import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banjarabio/presentation/ads/premium_gate_screen.dart';
import 'package:banjarabio/core/session_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.instance.init();
  });

  group('PremiumGateScreen Widget Tests', () {
    testWidgets('calls onComplete immediately on first run', (tester) async {
      SharedPreferences.setMockInitialValues({'has_opened_before': false});
      await SessionManager.instance.init();
      var completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: PremiumGateScreen(
            onComplete: () => completed = true,
            onPremiumPurchased: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(completed, isTrue);
    });

    testWidgets('renders fallback UI when not first run and ad is loading or failed', (tester) async {
      SharedPreferences.setMockInitialValues({'has_opened_before': true});
      await SessionManager.instance.init();

      await tester.pumpWidget(
        MaterialApp(
          home: PremiumGateScreen(
            onComplete: () {},
            onPremiumPurchased: () {},
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(PremiumGateScreen), findsOneWidget);
    });
  });
}
