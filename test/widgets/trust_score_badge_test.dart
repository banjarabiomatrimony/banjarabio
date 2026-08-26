import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/widgets/trust_score_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TrustScoreBadge Widget Tests', () {
    testWidgets('renders basic shield badge for lower scores', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return const MaterialApp(
              home: Scaffold(
                body: TrustScoreBadge(
                  score: 30,
                  showLabel: true,
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(TrustScoreBadge), findsOneWidget);
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('renders verified badge with sparkles for high score', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return const MaterialApp(
              home: Scaffold(
                body: TrustScoreBadge(
                  score: 95,
                  showLabel: true,
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(TrustScoreBadge), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
