import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/media_pipeline/layer5_progressive_placeholders/progressive_placeholder_builder.dart';

void main() {
  group('ProgressivePlaceholderBuilder Widget Tests', () {
    testWidgets('buildAdaptivePlaceholder renders pulsing shimmer when blurHash is null or empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgressivePlaceholderBuilder.buildAdaptivePlaceholder(
              width: 100,
              height: 100,
            ),
          ),
        ),
      );

      // Verify Container is rendered and animated
      expect(find.byType(Container), findsWidgets);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('buildAdaptivePlaceholder renders BlurHash widget when blurHash is valid length', (tester) async {
      // Valid short test blurhash string (6+ characters)
      const testBlurHash = 'LEHV6nWB2yk8pyo0adR*.7kCMdnj';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgressivePlaceholderBuilder.buildAdaptivePlaceholder(
              blurHash: testBlurHash,
              width: 200,
              height: 200,
            ),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('buildShimmerPlaceholder renders custom base and highlight color containers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgressivePlaceholderBuilder.buildShimmerPlaceholder(
              width: 150,
              height: 150,
              baseColor: Colors.blueGrey,
              highlightColor: Colors.amber,
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('buildErrorFallback renders icon and optional fallback label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgressivePlaceholderBuilder.buildErrorFallback(
              width: 120,
              height: 120,
              errorIcon: Icons.image_not_supported_rounded,
              fallbackLabel: 'Failed to load',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_not_supported_rounded), findsOneWidget);
      expect(find.text('Failed to load'), findsOneWidget);
    });

    testWidgets('placeholderCallback and errorCallback generate functional widgets', (tester) async {
      final placeholderGen = ProgressivePlaceholderBuilder.placeholderCallback(width: 80, height: 80);
      final errorGen = ProgressivePlaceholderBuilder.errorCallback(width: 80, height: 80);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Column(
                children: [
                  placeholderGen(context, 'https://example.com/photo.jpg'),
                  errorGen(context, 'https://example.com/photo.jpg', Exception('Network error')),
                ],
              );
            },
          ),
        ),
      );

      expect(find.byType(Column), findsNWidgets(2));
      expect(find.byIcon(Icons.broken_image_rounded), findsOneWidget);
    });
  });
}
