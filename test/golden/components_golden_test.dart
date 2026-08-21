import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/widgets/custom_error_widget.dart';
import 'package:banjarabio/widgets/trust_score_badge.dart';
import 'package:banjarabio/widgets/shimmer_widget.dart';
import 'package:banjarabio/widgets/tactile/tactile_action_button.dart';
import 'package:banjarabio/widgets/tactile/tactile_detail_chip.dart';
import 'package:banjarabio/widgets/branded_empty_state.dart';
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

    testWidgets('TactileActionButton renders correctly', (WidgetTester tester) async {
      await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TactileActionButton(
                iconData: Icons.arrow_back_ios_new_rounded,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(TactileActionButton),
        matchesGoldenFile('goldens/tactile_action_button.png'),
      );
    });

    testWidgets('TactileDetailChip renders correctly', (WidgetTester tester) async {
      await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: TactileDetailChip(
                iconData: Icons.school_rounded,
                label: 'Education',
                value: 'B.Tech Computer Science',
                tintColor: Color(0xFF673AB7),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(TactileDetailChip),
        matchesGoldenFile('goldens/tactile_detail_chip.png'),
      );
    });

    testWidgets('BrandedEmptyState renders correctly', (WidgetTester tester) async {
      await pumpWidgetSafely(
        tester,
        createTestableWidget(
          Container(
            color: Colors.white,
            child: const BrandedEmptyState(
              icon: Icons.people_outline_rounded,
              title: 'No Matches Found',
              description: 'Try adjusting your search filters to find more matches.',
              ctaText: 'Reset Filters',
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(BrandedEmptyState),
        matchesGoldenFile('goldens/branded_empty_state.png'),
      );
    });
  });
}
