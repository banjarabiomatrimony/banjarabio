import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/theme/app_category_theme.dart';
import 'package:banjarabio/widgets/tactile/tactile_pressable.dart';
import 'package:banjarabio/widgets/tactile/tactile_action_button.dart';
import 'package:banjarabio/widgets/tactile/tactile_back_button.dart';
import 'package:banjarabio/widgets/tactile/tactile_category_card.dart';
import 'package:banjarabio/widgets/tactile/tactile_detail_chip.dart';
import 'package:banjarabio/widgets/tactile/tactile_quote_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithSizer(Widget child) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          home: Scaffold(
            body: child,
          ),
        );
      },
    );
  }

  group('Tactile Widgets Tests', () {
    testWidgets('TactilePressable triggers onTap and animates scale', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithSizer(
          TactilePressable(
            onTap: () => tapped = true,
            child: const Text('Tap Me'),
          ),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('TactileActionButton renders icon and handles tap', (tester) async {
      var clicked = false;
      await tester.pumpWidget(
        wrapWithSizer(
          TactileActionButton(
            iconData: Icons.search,
            onPressed: () => clicked = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      await tester.tap(find.byType(TactileActionButton));
      await tester.pumpAndSettle();
      expect(clicked, isTrue);
    });

    testWidgets('TactileBackButton renders and pops navigator', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        wrapWithSizer(
          TactileBackButton(
            onPressed: () => pressed = true,
          ),
        ),
      );

      await tester.tap(find.byType(TactileBackButton));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('TactileCategoryCard renders header, emblem, and children', (tester) async {
      await tester.pumpWidget(
        wrapWithSizer(
          const TactileCategoryCard(
            categoryType: CategoryType.personal,
            title: 'Personal Details',
            icon: Icons.person,
            child: Text('Card Content'),
          ),
        ),
      );

      expect(find.text('Personal Details'), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('TactileDetailChip renders label and value with tactile interactions', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithSizer(
          TactileDetailChip(
            iconData: Icons.cake,
            label: 'Age',
            value: '26 yrs',
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('AGE'), findsOneWidget);
      expect(find.text('26 yrs'), findsOneWidget);
      await tester.tap(find.byType(TactileDetailChip));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('TactileQuoteCard renders title and quote content', (tester) async {
      await tester.pumpWidget(
        wrapWithSizer(
          const TactileQuoteCard(
            title: 'About Me',
            content: 'Software engineer from Pune.',
            color: Colors.blue,
            icon: Icons.format_quote,
          ),
        ),
      );

      expect(find.text('ABOUT ME'), findsOneWidget);
      expect(find.text('Software engineer from Pune.'), findsOneWidget);
    });
  });
}
