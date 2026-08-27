import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/app_version.dart';
import 'package:banjarabio/core/update_ecosystem/layer1_models/update_info.dart';
import 'package:banjarabio/core/update_ecosystem/layer6_ui/force_update_dialog.dart';
import 'package:banjarabio/core/update_ecosystem/layer6_ui/soft_update_sheet.dart';
import 'package:banjarabio/core/update_ecosystem/layer6_ui/update_modal_theme.dart';

void main() {
  group('Update UI Components', () {
    testWidgets('ForceUpdateDialog renders critical badge and release notes', (tester) async {
      bool updateClicked = false;

      final info = UpdateInfo.evaluate(
        currentVersion: const AppVersion(major: 1, rawVersion: '1.0.0'),
        latestVersion: const AppVersion(major: 1, minor: 4, rawVersion: '1.4.0'),
        minRequiredVersion: const AppVersion(major: 1, minor: 2, rawVersion: '1.2.0'),
        title: 'Mandatory Update',
        message: 'You must update now.',
        releaseNotes: ['Important security patch', 'New design'],
        storeUrl: 'https://example.com',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForceUpdateDialog(
              info: info,
              theme: const UpdateModalTheme(),
              onUpdate: () => updateClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('CRITICAL UPDATE'), findsOneWidget);
      expect(find.text('Mandatory Update'), findsOneWidget);
      expect(find.text('Important security patch'), findsOneWidget);
      expect(find.text('Update Now'), findsOneWidget);

      await tester.tap(find.text('Update Now'));
      await tester.pump();

      expect(updateClicked, isTrue);
    });

    testWidgets('SoftUpdateSheet renders version badge, later, and update buttons', (tester) async {
      bool updateClicked = false;
      bool dismissClicked = false;

      final info = UpdateInfo.evaluate(
        currentVersion: const AppVersion(major: 1, minor: 3, rawVersion: '1.3.0'),
        latestVersion: const AppVersion(major: 1, minor: 4, rawVersion: '1.4.0'),
        minRequiredVersion: const AppVersion(major: 1, rawVersion: '1.0.0'),
        title: 'New Features Available',
        message: 'Enjoy the new experience.',
        releaseNotes: ['Speed boosts'],
        storeUrl: 'https://example.com',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SoftUpdateSheet(
              info: info,
              theme: const UpdateModalTheme(),
              onUpdate: () => updateClicked = true,
              onDismiss: () => dismissClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('v1.4.0'), findsOneWidget);
      expect(find.text('New Features Available'), findsOneWidget);
      expect(find.text('Speed boosts'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
      expect(find.text('Update Now'), findsOneWidget);

      await tester.tap(find.text('Later'));
      await tester.pump();
      expect(dismissClicked, isTrue);

      await tester.tap(find.text('Update Now'));
      await tester.pump();
      expect(updateClicked, isTrue);
    });
  });
}
