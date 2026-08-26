import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/widgets/celebration_spark_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CelebrationSparkPainter Unit Tests', () {
    testWidgets('paints particles and stars without errors at progress midpoint', (tester) async {
      final painter = CelebrationSparkPainter(
        tappedIndex: 2,
        itemCount: 4,
        progress: 0.5,
        screenWidth: 400,
        sparkColors: const [Colors.amber, Colors.red, Colors.pink],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(400, 80),
              painter: painter,
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    test('shouldRepaint returns true when progress or index changes', () {
      final painter1 = CelebrationSparkPainter(
        tappedIndex: 1,
        itemCount: 4,
        progress: 0.2,
        screenWidth: 400,
        sparkColors: const [Colors.amber],
      );

      final painter2 = CelebrationSparkPainter(
        tappedIndex: 1,
        itemCount: 4,
        progress: 0.4,
        screenWidth: 400,
        sparkColors: const [Colors.amber],
      );

      final painter3 = CelebrationSparkPainter(
        tappedIndex: 2,
        itemCount: 4,
        progress: 0.2,
        screenWidth: 400,
        sparkColors: const [Colors.amber],
      );

      expect(painter2.shouldRepaint(painter1), isTrue);
      expect(painter3.shouldRepaint(painter1), isTrue);
      expect(painter1.shouldRepaint(painter1), isFalse);
    });
  });
}
