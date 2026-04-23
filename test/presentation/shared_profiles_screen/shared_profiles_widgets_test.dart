import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:banjarabio/presentation/shared_profiles_screen/widgets/empty_state_widget.dart' as shared;

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
  group('SharedProfilesEmptyState', () {
    testWidgets('renders for shared by me', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        shared.EmptyStateWidget(isSharedByMe: true, onStartSharing: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(shared.EmptyStateWidget), findsOneWidget);
    });

    testWidgets('renders for shared with me', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        shared.EmptyStateWidget(isSharedByMe: false, onStartSharing: () {}),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(shared.EmptyStateWidget), findsOneWidget);
    });
  });
}
