import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/widgets/custom_image_widget.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget wrapWithSizer(Widget child) => Sizer(
  builder: (context, orientation, deviceType) => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  group('CustomIconWidget', () {
    testWidgets('renders with icon name', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const CustomIconWidget(iconName: 'home'),
      ));
      await tester.pump();

      expect(find.byType(CustomIconWidget), findsOneWidget);
    });

    testWidgets('renders with custom color and size', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const CustomIconWidget(iconName: 'settings', size: 48, color: Colors.red),
      ));
      await tester.pump();

      expect(find.byType(CustomIconWidget), findsOneWidget);
    });
  });

  group('CustomImageWidget', () {
    testWidgets('renders with image URL', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const CustomImageWidget(
          imageUrl: 'https://example.com/image.jpg',
          width: 100,
          height: 100,
        ),
      ));
      await tester.pump();

      expect(find.byType(CustomImageWidget), findsOneWidget);
    });

    testWidgets('renders with null URL (placeholder)', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrapWithSizer(
        const CustomImageWidget(
          imageUrl: '',
          width: 100,
          height: 100,
        ),
      ));
      await tester.pump();

      expect(find.byType(CustomImageWidget), findsOneWidget);
    });
  });
}
