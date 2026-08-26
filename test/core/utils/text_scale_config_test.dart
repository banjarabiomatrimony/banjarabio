import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/utils/text_scale_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TextScaleConfig Clamping Tests', () {
    test('constants bounds are valid', () {
      expect(TextScaleConfig.minScaleFactor, equals(0.8));
      expect(TextScaleConfig.maxScaleFactor, equals(1.3));
      expect(TextScaleConfig.minScaleFactor, lessThan(TextScaleConfig.maxScaleFactor));
    });

    testWidgets('getClampedTextScaler bounds extreme scale factor', (tester) async {
      late TextScaler resolvedScaler;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.5)),
          child: Builder(
            builder: (context) {
              resolvedScaler = TextScaleConfig.getClampedTextScaler(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Clamped to max 1.3
      expect(resolvedScaler.scale(10.0), closeTo(13.0, 0.01));
    });

    testWidgets('getClampedTextScaler bounds tiny scale factor', (tester) async {
      late TextScaler resolvedScaler;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(0.2)),
          child: Builder(
            builder: (context) {
              resolvedScaler = TextScaleConfig.getClampedTextScaler(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Clamped to min 0.8
      expect(resolvedScaler.scale(10.0), closeTo(8.0, 0.01));
    });
  });
}
