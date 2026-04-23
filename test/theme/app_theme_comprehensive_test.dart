import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/theme/app_theme.dart';

/// These tests exercise the actual ThemeData instances (lightTheme, darkTheme)
/// which require Sizer initialization for `.sp` extension usage.
void main() {
  // ─── Light Theme Instance ──────────────────────────────────────────
  group('AppTheme.lightTheme (instance)', () {
    testWidgets('creates valid light theme with correct color scheme', (tester) async {
      await tester.pumpWidget(
        Sizer(builder: (ctx, orientation, type) {
          final theme = AppTheme.lightTheme;
          return MaterialApp(
            theme: theme,
            home: Builder(builder: (context) {
              final t = Theme.of(context);
              expect(t.brightness, Brightness.light);
              expect(t.colorScheme.primary, AppTheme.primaryLight);
              expect(t.colorScheme.onPrimary, AppTheme.onPrimaryLight);
              expect(t.colorScheme.secondary, AppTheme.secondaryLight);
              expect(t.colorScheme.error, AppTheme.errorLight);
              expect(t.colorScheme.surface, AppTheme.surfaceLight);
              expect(t.scaffoldBackgroundColor, AppTheme.backgroundLight);
              expect(t.cardColor, AppTheme.cardLight);
              expect(t.dividerColor, AppTheme.dividerLight);
              return const SizedBox();
            }),
          );
        }),
      );
    });

    testWidgets('light appBar theme', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (ctx) {
          final ab = Theme.of(ctx).appBarTheme;
          expect(ab.backgroundColor, AppTheme.primaryLight);
          expect(ab.foregroundColor, AppTheme.onPrimaryLight);
          expect(ab.elevation, 0);
          expect(ab.centerTitle, true);
          return const SizedBox();
        }),
      )));
    });

    testWidgets('light card theme', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (ctx) {
          final ct = Theme.of(ctx).cardTheme;
          expect(ct.color, AppTheme.cardLight);
          expect(ct.elevation, 12);
          expect(ct.shape, isA<RoundedRectangleBorder>());
          return const SizedBox();
        }),
      )));
    });

    testWidgets('light bottomNav theme', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (ctx) {
          final nav = Theme.of(ctx).bottomNavigationBarTheme;
          expect(nav.selectedItemColor, AppTheme.primaryLight);
          expect(nav.unselectedItemColor, AppTheme.textSecondaryLight);
          expect(nav.type, BottomNavigationBarType.fixed);
          expect(nav.elevation, 0);
          return const SizedBox();
        }),
      )));
    });

    testWidgets('light FAB theme', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (ctx) {
          final fab = Theme.of(ctx).floatingActionButtonTheme;
          expect(fab.backgroundColor, AppTheme.secondaryLight);
          expect(fab.foregroundColor, AppTheme.onSecondaryLight);
          return const SizedBox();
        }),
      )));
    });

    testWidgets('light button themes exist', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (ctx) {
          final t = Theme.of(ctx);
          expect(t.elevatedButtonTheme.style, isNotNull);
          expect(t.outlinedButtonTheme.style, isNotNull);
          expect(t.textButtonTheme.style, isNotNull);
          return const SizedBox();
        }),
      )));
    });

    testWidgets('light input decoration', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (ctx) {
          final inp = Theme.of(ctx).inputDecorationTheme;
          expect(inp.filled, true);
          expect(inp.border, isA<OutlineInputBorder>());
          return const SizedBox();
        }),
      )));
    });

    testWidgets('light textTheme', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (ctx) {
          final tt = Theme.of(ctx).textTheme;
          expect(tt.displayLarge, isNotNull);
          expect(tt.displayMedium, isNotNull);
          expect(tt.displaySmall, isNotNull);
          expect(tt.headlineLarge, isNotNull);
          expect(tt.headlineMedium, isNotNull);
          expect(tt.headlineSmall, isNotNull);
          expect(tt.titleLarge, isNotNull);
          expect(tt.titleMedium, isNotNull);
          expect(tt.titleSmall, isNotNull);
          expect(tt.bodyLarge, isNotNull);
          expect(tt.bodyMedium, isNotNull);
          expect(tt.bodySmall, isNotNull);
          expect(tt.labelLarge, isNotNull);
          expect(tt.labelMedium, isNotNull);
          expect(tt.labelSmall, isNotNull);
          return const SizedBox();
        }),
      )));
    });

    testWidgets('light switch/checkbox/radio/slider/progress', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (ctx) {
          final t = Theme.of(ctx);
          expect(t.switchTheme.thumbColor, isNotNull);
          expect(t.switchTheme.trackColor, isNotNull);
          expect(t.checkboxTheme.fillColor, isNotNull);
          expect(t.radioTheme.fillColor, isNotNull);
          expect(t.sliderTheme.activeTrackColor, AppTheme.primaryLight);
          expect(t.progressIndicatorTheme.color, AppTheme.primaryLight);
          return const SizedBox();
        }),
      )));
    });

    testWidgets('light tabBar/tooltip/snackBar/bottomSheet/dialog/chip', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (ctx) {
          final t = Theme.of(ctx);
          expect(t.tabBarTheme.labelColor, AppTheme.primaryLight);
          expect(t.tabBarTheme.indicatorColor, AppTheme.primaryLight);
          expect(t.tooltipTheme.padding, isNotNull);
          expect(t.snackBarTheme.behavior, SnackBarBehavior.floating);
          expect(t.snackBarTheme.actionTextColor, AppTheme.secondaryLight);
          expect(t.bottomSheetTheme.backgroundColor, AppTheme.surfaceLight);
          expect(t.dialogTheme.backgroundColor, AppTheme.dialogLight);
          expect(t.chipTheme.backgroundColor, AppTheme.surfaceLight);
          return const SizedBox();
        }),
      )));
    });
  });

  // ─── Dark Theme Instance ───────────────────────────────────────────
  group('AppTheme.darkTheme (instance)', () {
    testWidgets('creates valid dark theme with correct color scheme', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(builder: (ctx) {
          final t = Theme.of(ctx);
          expect(t.brightness, Brightness.dark);
          expect(t.colorScheme.primary, AppTheme.primaryDark);
          expect(t.colorScheme.secondary, AppTheme.secondaryDark);
          expect(t.colorScheme.error, AppTheme.errorDark);
          expect(t.scaffoldBackgroundColor, AppTheme.backgroundDark);
          expect(t.cardColor, AppTheme.cardDark);
          return const SizedBox();
        }),
      )));
    });

    testWidgets('dark appBar/card/nav themes', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(builder: (ctx) {
          final t = Theme.of(ctx);
          expect(t.appBarTheme.backgroundColor, AppTheme.surfaceDark);
          expect(t.cardTheme.color, AppTheme.cardDark);
          expect(t.bottomNavigationBarTheme.selectedItemColor, AppTheme.primaryDark);
          expect(t.floatingActionButtonTheme.backgroundColor, AppTheme.secondaryDark);
          return const SizedBox();
        }),
      )));
    });

    testWidgets('dark button/input/text themes', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(builder: (ctx) {
          final t = Theme.of(ctx);
          expect(t.elevatedButtonTheme.style, isNotNull);
          expect(t.outlinedButtonTheme.style, isNotNull);
          expect(t.textButtonTheme.style, isNotNull);
          expect(t.inputDecorationTheme.filled, true);
          expect(t.textTheme.displayLarge, isNotNull);
          expect(t.textTheme.bodyLarge, isNotNull);
          return const SizedBox();
        }),
      )));
    });

    testWidgets('dark switch/checkbox/radio/slider/progress/tab/snack/dialog/chip', (tester) async {
      await tester.pumpWidget(Sizer(builder: (c, o, d) => MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(builder: (ctx) {
          final t = Theme.of(ctx);
          expect(t.switchTheme.thumbColor, isNotNull);
          expect(t.checkboxTheme.fillColor, isNotNull);
          expect(t.radioTheme.fillColor, isNotNull);
          expect(t.sliderTheme.activeTrackColor, AppTheme.primaryDark);
          expect(t.progressIndicatorTheme.color, AppTheme.primaryDark);
          expect(t.tabBarTheme.labelColor, AppTheme.primaryDark);
          expect(t.snackBarTheme.actionTextColor, AppTheme.secondaryDark);
          expect(t.dialogTheme.backgroundColor, AppTheme.dialogDark);
          expect(t.chipTheme.backgroundColor, AppTheme.surfaceDark);
          expect(t.bottomSheetTheme.backgroundColor, AppTheme.surfaceDark);
          expect(t.tooltipTheme.padding, isNotNull);
          return const SizedBox();
        }),
      )));
    });
  });
}
