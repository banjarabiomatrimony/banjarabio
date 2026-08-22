import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:banjarabio/presentation/profile_detail_screen/widgets/action_buttons_widget.dart';
import '../../../helpers/widget_test_helpers.dart';

/// Wraps widget with Sizer and Localization
Widget wrapWithSizer(Widget child) {
  return Sizer(
    builder: (context, orientation, screenType) => MaterialApp(
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
}

void main() {
  group('ActionButtonsWidget', () {
    setUp(() {
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.physicalSize = const Size(1080, 1920);
      binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
      setupWidgetTestMocks();
    });

    tearDown(() {
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.views.first.resetPhysicalSize();
      binding.platformDispatcher.views.first.resetDevicePixelRatio();
      tearDownWidgetTestMocks();
    });

    testWidgets('displays SAVE when not bookmarked', (tester) async {
      await tester.pumpWidget(
        wrapWithSizer(
          ActionButtonsWidget(
            profileData: {
              'id': 'profile-1',
              'name': 'Test',
              'isBookmarked': false,
            },
            onShare: (_) {},
            onInterest: (_) {},
            onMessage: (_) {},
            onBookmark: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining(RegExp('Save', caseSensitive: false)), findsOneWidget);
    });

    testWidgets('displays SAVED when bookmarked', (tester) async {
      await tester.pumpWidget(
        wrapWithSizer(
          ActionButtonsWidget(
            profileData: {
              'id': 'profile-1',
              'name': 'Test',
              'isBookmarked': true,
            },
            onShare: (_) {},
            onInterest: (_) {},
            onMessage: (_) {},
            onBookmark: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining(RegExp('Saved', caseSensitive: false)), findsOneWidget);
    });

    testWidgets('calls onBookmark when SAVE button tapped', (tester) async {
      Map<String, dynamic>? capturedProfile;
      await tester.pumpWidget(
        wrapWithSizer(
          ActionButtonsWidget(
            profileData: {
              'id': 'profile-1',
              'name': 'Test',
              'isBookmarked': false,
            },
            onShare: (_) {},
            onInterest: (_) {},
            onMessage: (_) {},
            onBookmark: (profile) => capturedProfile = profile,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.textContaining(RegExp('Save', caseSensitive: false)));
      await tester.pump();

      expect(capturedProfile, isNotNull);
      expect(capturedProfile!['id'], 'profile-1');
      expect(capturedProfile!['isBookmarked'], false);
    });

    testWidgets('syncs _isBookmarked when profileData changes via didUpdateWidget',
        (tester) async {
      var isBookmarked = false;
      await tester.pumpWidget(
        wrapWithSizer(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      isBookmarked = true;
                      setState(() {});
                    },
                    child: const Text('SimulateRiverpodUpdate'),
                  ),
                  ActionButtonsWidget(
                    profileData: {
                      'id': 'profile-1',
                      'name': 'Test',
                      'isBookmarked': isBookmarked,
                    },
                    onShare: (_) {},
                    onInterest: (_) {},
                    onMessage: (_) {},
                    onBookmark: (_) {},
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining(RegExp('Save', caseSensitive: false)), findsOneWidget);

      await tester.tap(find.text('SimulateRiverpodUpdate'));
      await tester.pump();

      expect(find.textContaining(RegExp('Saved', caseSensitive: false)), findsOneWidget);
    });
  });
}
