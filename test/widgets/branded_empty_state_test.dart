import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/widgets/branded_empty_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BrandedEmptyState Widget Tests', () {
    testWidgets('renders title, description, icon and handles CTA tap', (tester) async {
      var ctaClicked = false;

      await tester.pumpWidget(
        ProviderScope(
          child: Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp(
                home: Scaffold(
                  body: BrandedEmptyState(
                    icon: Icons.favorite_border,
                    title: 'No Matches Yet',
                    description: 'Explore new verified profiles today.',
                    ctaText: 'Discover Profiles',
                    onCtaPressed: () => ctaClicked = true,
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('No Matches Yet'), findsOneWidget);
      expect(find.text('Explore new verified profiles today.'), findsOneWidget);
      expect(find.text('Discover Profiles'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await tester.tap(find.text('Discover Profiles'));
      await tester.pumpAndSettle();
      expect(ctaClicked, isTrue);
    });
  });
}
