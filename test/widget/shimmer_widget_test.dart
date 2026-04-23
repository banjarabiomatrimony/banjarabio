import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';

void main() {
  group('ShimmerWidget.rectangular', () {
    testWidgets('renders with correct height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerWidget.rectangular(height: 50),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxHeight, 50);
    });

    testWidgets('uses light mode grey color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: ShimmerWidget.rectangular(height: 50),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as ShapeDecoration;
      expect(decoration.color, Colors.grey[200]);
    });

    testWidgets('uses dark mode grey color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: ShimmerWidget.rectangular(height: 50),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as ShapeDecoration;
      expect(decoration.color, Colors.grey[800]);
    });
  });

  group('ShimmerWidget.circular', () {
    testWidgets('renders with CircleBorder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerWidget.circular(width: 40, height: 40),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as ShapeDecoration;
      expect(decoration.shape, isA<CircleBorder>());
    });
  });
}
