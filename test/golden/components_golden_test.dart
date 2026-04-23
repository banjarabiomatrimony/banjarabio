import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/widgets/custom_error_widget.dart';
import 'package:banjarabio/widgets/trust_score_badge.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import '../helpers/widget_test_helpers.dart';

void main() {
  setUp(() {
    setupWidgetTestMocks();
  });

  tearDown(() {
    tearDownWidgetTestMocks();
  });

  group('Golden Tests for Core Components', () {
    testWidgets('TrustScoreBadge renders correctly', (WidgetTester tester) async {
      await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: const TrustScoreBadge(
              score: 80,
              showLabel: true,
              isGhosting: true, // Disable complex animation for golden test
            ),
          ),
        ),
      );

      // We use matchesGoldenFile to do visual regression testing
      await expectLater(
        find.byType(TrustScoreBadge),
        matchesGoldenFile('goldens/trust_score_badge.png'),
      );
    });

    testWidgets('CustomErrorWidget renders correctly', (WidgetTester tester) async {
      await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Container(
            color: Colors.white,
            child: const CustomErrorWidget(
              errorMessage: 'Something went wrong.',
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CustomErrorWidget),
        matchesGoldenFile('goldens/custom_error_widget.png'),
      );
    });

    testWidgets('ShimmerWidget renders correctly', (WidgetTester tester) async {
      await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Container(
            color: Colors.white,
            child: const ShimmerWidget.rectangular(
              width: 100,
              height: 20,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ShimmerWidget),
        matchesGoldenFile('goldens/shimmer_widget.png'),
      );
    });
  });
}
