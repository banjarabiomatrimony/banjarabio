import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/main_navigation_screen/main_navigation_screen.dart';
import 'package:banjarabio/widgets/custom_bottom_bar.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  setUp(() {
    setupWidgetTestMocks();
  });

  testWidgets('HomeScreen mounts correctly', (WidgetTester tester) async {
    setTestScreenSize(tester);

    await tester.pumpWidget(createTestableWidget(
      const MainNavigationScreen(),
    ));

    // Pump frames to let async initState, timers, and inner Navigator settle
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));

    // The Scaffold and CustomBottomBar should be rendered
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byType(CustomBottomBar), findsOneWidget);
  });
}
