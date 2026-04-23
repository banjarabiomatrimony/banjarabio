import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:banjarabio/presentation/photo_management_screen/widgets/widgets/cultural_guidelines_widget.dart';
import 'package:banjarabio/presentation/photo_management_screen/widgets/widgets/photo_grid_widget.dart';

Widget wrapWithSizer(Widget child) => Sizer(
  builder: (context, orientation, deviceType) => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  group('CulturalGuidelinesWidget', () {
    testWidgets('renders cultural photo guidelines', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const CulturalGuidelinesWidget(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CulturalGuidelinesWidget), findsOneWidget);
    });
  });

  group('PhotoGridWidget', () {
    testWidgets('renders empty grid', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        PhotoGridWidget(
          photos: const [],
          isSelectionMode: false,
          isPremium: false,
          onPhotoTap: (index) {},
          onPhotoLongPress: (index) {},
          onAddPhoto: () {},
          maxPhotos: 6,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(PhotoGridWidget), findsOneWidget);
    });
  });
}
