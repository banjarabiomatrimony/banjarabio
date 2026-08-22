import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/presentation/static_pages/account_deletion_screen.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget createWidget() => Sizer(
    builder: (context, orientation, deviceType) => const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en')],
      home: AccountDeletionScreen(),
    ),
  );

  group('AccountDeletionScreen', () {
    testWidgets('renders with warning and checkbox', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Delete'), findsWidgets);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.textContaining('Delete My Account'), findsOneWidget);
    });

    testWidgets('delete button is disabled initially', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final pressableFinder = find.ancestor(
        of: find.textContaining('Delete My Account'),
        matching: find.byType(TactilePressable),
      );
      expect(pressableFinder, findsOneWidget);
      final pressable = tester.widget<TactilePressable>(pressableFinder);
      expect(pressable.onTap, isNull);
    });

    testWidgets('checkbox enables delete button', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      final pressableFinder = find.ancestor(
        of: find.textContaining('Delete My Account'),
        matching: find.byType(TactilePressable),
      );
      final pressable = tester.widget<TactilePressable>(pressableFinder);
      expect(pressable.onTap, isNotNull);
    });

    testWidgets('shows warning items', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsWidgets);
    });
  });
}
