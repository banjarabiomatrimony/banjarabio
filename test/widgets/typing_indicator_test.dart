import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/widgets/typing_indicator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TypingIndicator Widget Tests', () {
    testWidgets('renders 3 animated dot indicators without crashing', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return const MaterialApp(
              home: Scaffold(
                body: TypingIndicator(
                  dotSize: 10,
                  dotColor: Colors.blue,
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(TypingIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });
  });
}
