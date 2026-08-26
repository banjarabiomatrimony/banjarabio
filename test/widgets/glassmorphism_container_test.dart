import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/widgets/glassmorphism_container.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GlassmorphismContainer Widget Tests', () {
    testWidgets('renders child with backdrop blur and border styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassmorphismContainer(
              width: 200,
              height: 100,
              blur: 20,
              opacity: 0.2,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              child: Text('Glass Content'),
            ),
          ),
        ),
      );

      expect(find.byType(GlassmorphismContainer), findsOneWidget);
      expect(find.text('Glass Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
