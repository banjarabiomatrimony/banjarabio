import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:banjarabio/presentation/home_screen/widgets/empty_state_widget.dart';
import 'package:banjarabio/presentation/home_screen/widgets/filter_chip_widget.dart';

Widget wrapWithSizer(Widget child) => Sizer(
  builder: (context, orientation, deviceType) => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  ),
);

void main() {
  group('EmptyStateWidget', () {
    testWidgets('renders with message', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const EmptyStateWidget(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });
  });

  group('FilterChipWidget', () {
    testWidgets('renders with label and remove callback', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        FilterChipWidget(
          label: 'Age: 25-30',
          onRemove: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Age: 25-30'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });
  });
}
