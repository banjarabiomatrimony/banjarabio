import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/widgets/custom_error_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CustomErrorWidget Tests', () {
    testWidgets('renders friendly fallback error screen and back button', (tester) async {
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return const MaterialApp(
              home: CustomErrorWidget(
                errorMessage: 'Network timeout',
              ),
            );
          },
        ),
      );

      expect(find.byType(CustomErrorWidget), findsOneWidget);
      expect(find.byIcon(Icons.sentiment_dissatisfied_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
