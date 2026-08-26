import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/media_pipeline/layer2_display_decoding/display_cache_policy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DisplayCachePolicy Unit & Calculation Tests', () {
    test('default constants are configured correctly', () {
      expect(DisplayCachePolicy.defaultCardWidth, equals(720));
      expect(DisplayCachePolicy.defaultThumbnailWidth, equals(320));
      expect(DisplayCachePolicy.defaultAvatarWidth, equals(160));
    });

    test('getDevicePixelRatio returns valid ratio without context', () {
      final dpr = DisplayCachePolicy.getDevicePixelRatio();
      expect(dpr, greaterThan(0.0));
    });

    test('isLandscape returns valid boolean without context', () {
      final landscape = DisplayCachePolicy.isLandscape();
      expect(landscape, isA<bool>());
    });

    test('isTabletOrDesktop returns valid boolean without context', () {
      final tablet = DisplayCachePolicy.isTabletOrDesktop();
      expect(tablet, isA<bool>());
    });

    test('getCardCacheWidth returns clamped value without context', () {
      final width = DisplayCachePolicy.getCardCacheWidth();
      expect(width, equals(DisplayCachePolicy.defaultCardWidth));
    });

    test('getThumbnailCacheWidth returns clamped value without context', () {
      final width = DisplayCachePolicy.getThumbnailCacheWidth();
      expect(width, equals(DisplayCachePolicy.defaultThumbnailWidth));
    });

    test('getDualPaneCacheWidth returns expected baseline without context', () {
      final width = DisplayCachePolicy.getDualPaneCacheWidth();
      expect(width, equals(DisplayCachePolicy.defaultCardWidth));
    });

    test('getAvatarCacheWidth calculates avatar pixel density within clamps', () {
      final avatarWidth = DisplayCachePolicy.getAvatarCacheWidth();
      expect(avatarWidth, inInclusiveRange(96, 256));
    });

    test('computeCustomCacheWidth bounds within [64, 1440]', () {
      expect(DisplayCachePolicy.computeCustomCacheWidth(10.0), equals(64));
      expect(DisplayCachePolicy.computeCustomCacheWidth(5000.0), equals(1440));
      expect(DisplayCachePolicy.computeCustomCacheWidth(200.0), inInclusiveRange(64, 1440));
    });

    test('computeCustomCacheHeight bounds within [64, 2560]', () {
      expect(DisplayCachePolicy.computeCustomCacheHeight(10.0), equals(64));
      expect(DisplayCachePolicy.computeCustomCacheHeight(5000.0), equals(2560));
      expect(DisplayCachePolicy.computeCustomCacheHeight(300.0), inInclusiveRange(64, 2560));
    });
  });

  group('DisplayCachePolicy Context-Aware Tests', () {
    testWidgets('calculates portrait card width with MediaQuery context', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late int calculatedCardWidth;
      late int calculatedThumbWidth;
      late int calculatedDualPaneWidth;
      late bool isLand;
      late bool isTab;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              calculatedCardWidth = DisplayCachePolicy.getCardCacheWidth(context);
              calculatedThumbWidth = DisplayCachePolicy.getThumbnailCacheWidth(context);
              calculatedDualPaneWidth = DisplayCachePolicy.getDualPaneCacheWidth(context, 0.4);
              isLand = DisplayCachePolicy.isLandscape(context);
              isTab = DisplayCachePolicy.isTabletOrDesktop(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(calculatedCardWidth, inInclusiveRange(480, 1080));
      expect(calculatedThumbWidth, inInclusiveRange(240, 540));
      expect(calculatedDualPaneWidth, inInclusiveRange(360, 960));
      expect(isLand, isFalse);
      expect(isTab, isFalse);
    });

    testWidgets('calculates landscape / tablet widths correctly', (tester) async {
      tester.view.physicalSize = const Size(2400, 1600);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late int calculatedCardWidth;
      late bool isLand;
      late bool isTab;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              calculatedCardWidth = DisplayCachePolicy.getCardCacheWidth(context);
              isLand = DisplayCachePolicy.isLandscape(context);
              isTab = DisplayCachePolicy.isTabletOrDesktop(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(calculatedCardWidth, inInclusiveRange(480, 1080));
      expect(isLand, isTrue);
      expect(isTab, isTrue);
    });
  });
}
