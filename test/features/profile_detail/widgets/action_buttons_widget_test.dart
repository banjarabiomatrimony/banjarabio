import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/presentation/profile_detail_screen/widgets/action_buttons_widget.dart';

/// Wraps widget with Sizer (required for ActionButtonsWidget's 7.2.h, etc.)
Widget wrapWithSizer(Widget child) {
  return Sizer(
    builder: (context, orientation, screenType) => child,
  );
}

void main() {
  group('ActionButtonsWidget', () {
    testWidgets('displays SAVE when not bookmarked', (tester) async {
      await tester.pumpWidget(
        wrapWithSizer(
          MaterialApp(
            home: ActionButtonsWidget(
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
        ),
      );

      expect(find.text('SAVE'), findsOneWidget);
      expect(find.text('SAVED'), findsNothing);
    });

    testWidgets('displays SAVED when bookmarked', (tester) async {
      await tester.pumpWidget(
        wrapWithSizer(
          MaterialApp(
            home: ActionButtonsWidget(
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
        ),
      );

      expect(find.text('SAVED'), findsOneWidget);
      expect(find.text('SAVE'), findsNothing);
    });

    testWidgets('calls onBookmark when SAVE button tapped', (tester) async {
      Map<String, dynamic>? capturedProfile;
      await tester.pumpWidget(
        wrapWithSizer(
          MaterialApp(
            home: ActionButtonsWidget(
              profileData: {
                'id': 'profile-1',
                'name': 'Test',
                'isBookmarked': false,
              },
               onShare: (_) {},
               onInterest: (_) {}, // Added missing callback
               onMessage: (_) {},
               onBookmark: (profile) => capturedProfile = profile,
            ),
          ),
        ),
      );

      await tester.tap(find.text('SAVE'));
      await tester.pump();

      expect(capturedProfile, isNotNull);
      expect(capturedProfile!['id'], 'profile-1');
      expect(capturedProfile!['isBookmarked'], false);
    });

    testWidgets('syncs _isBookmarked when profileData changes via didUpdateWidget',
        (tester) async {
      // Parent state - simulates Riverpod ref.watch triggering rebuild with new data
      var isBookmarked = false;
      await tester.pumpWidget(
        wrapWithSizer(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
              return Column(
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
        ),
      );

      expect(find.text('SAVE'), findsOneWidget);

      // Tap to simulate parent receiving new profileData from Riverpod
      await tester.tap(find.text('SimulateRiverpodUpdate'));
      await tester.pump();

      // didUpdateWidget syncs _isBookmarked -> should display SAVED
      expect(find.text('SAVED'), findsOneWidget);
      expect(find.text('SAVE'), findsNothing);
    });
  });
}
