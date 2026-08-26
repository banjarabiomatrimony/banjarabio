import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/home_screen/widgets/guest_restricted_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp(Widget child) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: child,
          ),
        );
      },
    );
  }

  group('GuestRestrictedDialog & RelativeBrowsePromptDialog Tests', () {
    testWidgets('renders animated emblem, title, content, feature pills, and action buttons', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  GuestRestrictedDialog.showRelativeBrowseDialog(context);
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      );

      // Tap button to open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      // Verify dialog components
      expect(find.byType(RelativeBrowsePromptDialog), findsOneWidget);
      expect(find.byIcon(Icons.assignment_ind_rounded), findsOneWidget);
      expect(find.text('Full Details'), findsOneWidget);
      expect(find.text('Save Matches'), findsOneWidget);
      expect(find.text('Direct Chat'), findsOneWidget);

      // Verify CTA buttons
      expect(find.text('Create Biodata ✨'), findsOneWidget);
      expect(find.text('Change Options ✏️'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel to dismiss
      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(RelativeBrowsePromptDialog), findsNothing);
    });
  });
}
