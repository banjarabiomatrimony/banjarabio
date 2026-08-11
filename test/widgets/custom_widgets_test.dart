import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/widgets/custom_icon_widget.dart';
import 'package:banjarabio/widgets/custom_image_widget.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:banjarabio/core/config/storage_config.dart';
import 'package:banjarabio/core/repositories/photo_repository.dart';

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
      await tester.pump(const Duration(seconds: 10));

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

  group('PhotoRepository Resizing & Fallback tests', () {
    const testUrl = 'https://icvmuktbpxglsmyvebwf.supabase.co/storage/v1/object/public/profile-photos/user/image.jpg';

    test('getResizedUrl returns original URL when enableImageTransformations is false', () {
      StorageConfig.enableImageTransformations = false;
      final result = PhotoRepository().getResizedUrl(testUrl, width: 300);
      expect(result, testUrl);
    });

    test('getResizedUrl returns transformed URL when enableImageTransformations is true', () {
      StorageConfig.enableImageTransformations = true;
      final result = PhotoRepository().getResizedUrl(testUrl, width: 300);
      expect(result, contains('/render/image/public/'));
      expect(result, contains('width=300'));
      // Clean up after test
      StorageConfig.enableImageTransformations = false;
    });
  });
}
