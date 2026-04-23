import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:banjarabio/presentation/shared_profiles_screen/widgets/shared_profile_card_widget.dart';

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
  group('SharedProfileCardWidget', () {
    testWidgets('renders with shared profile data', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        SharedProfileCardWidget(
          profile: const {
            'full_name': 'John Doe',
            'age': 28,
            'surname': 'Doe',
            'profession': 'Engineer',
          },
          isSharedByMe: true,
          isSelected: false,
          isSelectionMode: false,
          onTap: () {},
          onLongPress: () {},
          onReshare: () {},
          onRemove: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SharedProfileCardWidget), findsOneWidget);
    });

    testWidgets('renders shared with me variant', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        SharedProfileCardWidget(
          profile: const {
            'full_name': 'Jane Smith',
            'age': 25,
            'surname': 'Smith',
            'profession': 'Doctor',
          },
          isSharedByMe: false,
          isSelected: false,
          isSelectionMode: false,
          onTap: () {},
          onLongPress: () {},
          onReshare: () {},
          onRemove: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SharedProfileCardWidget), findsOneWidget);
    });
  });
}
