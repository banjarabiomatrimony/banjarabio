import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/widgets/trust_score_badge.dart';
import '../helpers/golden_test_helpers.dart';

void main() {
  group('TrustScoreBadge Golden', () {
    testWidgets('light — score 0 (hidden)', (tester) async {
      setupGoldenViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(goldenLightApp(
        const Center(child: TrustScoreBadge(score: 0)),
      ));
      await tester.pump();
      await tester.pump();

      await expectLater(
        find.byType(TrustScoreBadge),
        matchesGoldenFile('goldens/trust_badge_0_light.png'),
      );
    });

    testWidgets('light — score 50 (standard)', (tester) async {
      setupGoldenViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(goldenLightApp(
        const Center(child: TrustScoreBadge(score: 50)),
      ));
      await tester.pump();
      await tester.pump();

      await expectLater(
        find.byType(TrustScoreBadge),
        matchesGoldenFile('goldens/trust_badge_50_light.png'),
      );
    });

    testWidgets('light — score 80 (verified)', (tester) async {
      setupGoldenViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(goldenLightApp(
        const Center(child: TrustScoreBadge(score: 80)),
      ));
      await tester.pump();
      await tester.pump();

      await expectLater(
        find.byType(TrustScoreBadge),
        matchesGoldenFile('goldens/trust_badge_80_light.png'),
      );
    });

    testWidgets('light — score 100 (max)', (tester) async {
      setupGoldenViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(goldenLightApp(
        const Center(child: TrustScoreBadge(score: 100)),
      ));
      await tester.pump();
      await tester.pump();

      await expectLater(
        find.byType(TrustScoreBadge),
        matchesGoldenFile('goldens/trust_badge_100_light.png'),
      );
    });

    testWidgets('dark — score 80 (verified)', (tester) async {
      setupGoldenViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(goldenDarkApp(
        const Center(child: TrustScoreBadge(score: 80)),
      ));
      await tester.pump();
      await tester.pump();

      await expectLater(
        find.byType(TrustScoreBadge),
        matchesGoldenFile('goldens/trust_badge_80_dark.png'),
      );
    });
  });
}
