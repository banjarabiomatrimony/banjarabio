import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/widgets/trust_score_badge.dart';

void main() {
  Widget buildBadge(int score, {bool showLabel = false}) {
    return Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: TrustScoreBadge(
              score: score,
              showLabel: showLabel,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }

  group('TrustScoreBadge visibility', () {
    testWidgets('score below threshold renders basic level badge', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildBadge(20));
      await tester.pump();

      // Score 20 = Basic level, renders progress indicator ring and shield
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('score at threshold renders badge', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildBadge(50));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });

  group('TrustScoreBadge icon', () {
    testWidgets('shows shield icon for Standard/Trusted', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildBadge(60));
      await tester.pump();

      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('shows verified icon for score >= 90', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildBadge(95));
      await tester.pump();

      expect(find.byIcon(Icons.verified), findsOneWidget);
    });
  });

  group('TrustScoreBadge label', () {
    testWidgets('showLabel=true displays level name', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildBadge(75, showLabel: true));
      await tester.pump();

      // Score 75 = "Trusted"
      expect(find.text('Trusted'), findsOneWidget);
    });

    testWidgets('showLabel=false hides level name', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildBadge(75));
      await tester.pump();

      expect(find.text('Trusted'), findsNothing);
    });
  });
}
