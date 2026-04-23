import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/static_pages/faq_screen.dart';
import '../helpers/golden_test_helpers.dart';

void main() {
  group('FAQScreen Golden', () {
    testWidgets('light mode', (tester) async {
      setupGoldenViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(goldenLightApp(const FAQScreen()));
      await tester.pump();
      await tester.pump();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/faq_screen_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      setupGoldenViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(goldenDarkApp(const FAQScreen()));
      await tester.pump();
      await tester.pump();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/faq_screen_dark.png'),
      );
    });
  });
}
