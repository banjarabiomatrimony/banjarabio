import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/theme/app_color_scheme.dart';

void main() {
  group('AppColorScheme Extension & Factory Tests', () {
    test('light scheme contains expected surfaces and brand colors', () {
      final light = AppColorScheme.light();
      expect(light.canvas, isNotNull);
      expect(light.surface, isNotNull);
      expect(light.primary, isNotNull);
      expect(light.secondary, isNotNull);
      expect(light.success, isNotNull);
      expect(light.warning, isNotNull);
      expect(light.error, isNotNull);
    });

    test('dark scheme contains high contrast dark variants', () {
      final dark = AppColorScheme.dark();
      expect(dark.canvas, isNotNull);
      expect(dark.surface, isNotNull);
      expect(dark.primary, isNotNull);
      expect(dark.secondary, isNotNull);
    });

    test('copyWith creates modified scheme copy', () {
      final light = AppColorScheme.light();
      final copied = light.copyWith(canvas: Colors.red);
      expect(copied.canvas, equals(Colors.red));
      expect(copied.surface, equals(light.surface));
    });

    test('lerp interpolates between light and dark schemes', () {
      final light = AppColorScheme.light();
      final dark = AppColorScheme.dark();
      final lerped = light.lerp(dark, 0.5);

      expect(lerped.canvas, isNotNull);
      expect(lerped.primary, isNotNull);
    });

    testWidgets('context.colors extension resolves correctly in Widget tree', (tester) async {
      late AppColorScheme resolvedColors;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            extensions: [AppColorScheme.light()],
          ),
          home: Builder(
            builder: (context) {
              resolvedColors = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolvedColors, isNotNull);
      expect(resolvedColors.primary, equals(AppColorScheme.light().primary));
    });
  });
}
