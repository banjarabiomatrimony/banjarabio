import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';
import '../helpers/golden_test_helpers.dart';

void main() {
  group('GlassmorphismContainer Golden', () {
    testWidgets('light mode', (tester) async {
      setupGoldenViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(goldenLightApp(
        const Scaffold(
          body: Center(
            child: GlassmorphismContainer(
              width: 300,
              height: 200,
              child: Center(
                child: Text('Hello Glass', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/glassmorphism_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      setupGoldenViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(goldenDarkApp(
        const Scaffold(
          body: Center(
            child: GlassmorphismContainer(
              width: 300,
              height: 200,
              child: Center(
                child: Text('Hello Glass', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/glassmorphism_dark.png'),
      );
    });
  });
}
