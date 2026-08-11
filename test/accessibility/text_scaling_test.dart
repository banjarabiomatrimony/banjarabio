import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/utils/text_scale_config.dart';

void main() {
  group('TextScaleConfig Clamping Tests', () {
    testWidgets('Should clamp text scale factors above 1.3x to exactly 1.3x', (WidgetTester tester) async {
      double? observedScaleFactor;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
          child: MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                final clampedScaler = TextScaleConfig.getClampedTextScaler(context);
                observedScaleFactor = clampedScaler.scale(10.0) / 10.0;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(observedScaleFactor, closeTo(1.3, 0.01));
    });

    testWidgets('Should clamp text scale factors below 0.8x to exactly 0.8x', (WidgetTester tester) async {
      double? observedScaleFactor;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(0.5)),
          child: MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                final clampedScaler = TextScaleConfig.getClampedTextScaler(context);
                observedScaleFactor = clampedScaler.scale(10.0) / 10.0;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(observedScaleFactor, closeTo(0.8, 0.01));
    });

    testWidgets('Should preserve text scale factors within the 0.8x to 1.3x range', (WidgetTester tester) async {
      double? observedScaleFactor;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.15)),
          child: MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                final clampedScaler = TextScaleConfig.getClampedTextScaler(context);
                observedScaleFactor = clampedScaler.scale(10.0) / 10.0;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(observedScaleFactor, closeTo(1.15, 0.01));
    });
  });
}
