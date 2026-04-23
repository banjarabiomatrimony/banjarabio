import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';

void main() {
  group('GlassmorphismContainer', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassmorphismContainer(
              child: Text('Hello Glass'),
            ),
          ),
        ),
      );

      expect(find.text('Hello Glass'), findsOneWidget);
    });

    testWidgets('applies BackdropFilter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassmorphismContainer(
              blur: 20.0,
              child: Text('Blur Test'),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('applies ClipRRect', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassmorphismContainer(
              borderRadius: BorderRadius.circular(16),
              child: const Text('Rounded'),
            ),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('respects width and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: GlassmorphismContainer(
                width: 200,
                height: 100,
                child: Text('Sized'),
              ),
            ),
          ),
        ),
      );

      final outerContainer = tester.widgetList<Container>(
        find.byType(Container),
      ).first;
      expect(outerContainer.constraints?.maxWidth, 200);
      expect(outerContainer.constraints?.maxHeight, 100);
    });

    testWidgets('adapts border to dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: GlassmorphismContainer(
              child: Text('Dark'),
            ),
          ),
        ),
      );

      // Should render without error in dark mode
      expect(find.text('Dark'), findsOneWidget);
    });
  });
}
