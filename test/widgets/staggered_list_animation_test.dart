import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/widgets/staggered_list_animation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StaggeredListAnimation Tests', () {
    testWidgets('StaggeredListItem animates opacity and translation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StaggeredListItem(
              index: 0,
              delay: Duration.zero,
              animationDuration: Duration(milliseconds: 50),
              child: Text('Animated Item 1'),
            ),
          ),
        ),
      );

      expect(find.text('Animated Item 1'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Animated Item 1'), findsOneWidget);
    });

    testWidgets('StaggeredColumn renders all child items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StaggeredColumn(
              delay: Duration.zero,
              animationDuration: Duration(milliseconds: 50),
              children: [
                Text('Child 1'),
                Text('Child 2'),
                Text('Child 3'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
      expect(find.text('Child 3'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 60));
    });
  });
}
