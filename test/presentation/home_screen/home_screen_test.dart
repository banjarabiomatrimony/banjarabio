import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/home_screen/home_screen.dart';
import 'package:banjarabio/widgets/custom_bottom_bar.dart';

import '../../helpers/widget_test_helpers.dart';

void main() {
  setUp(() {
    setupWidgetTestMocks();
  });

  testWidgets('HomeScreen mounts correctly', (WidgetTester tester) async {
    // Set standard phone screen size to avoid RenderFlex overflow
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestableWidget(
      const HomeScreen(),
    ));

    // Pump a few frames to let async initState and inner Navigator settle
    await tester.pump(const Duration(milliseconds: 500));

    // The Scaffold and CustomBottomBar should be rendered
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byType(CustomBottomBar), findsOneWidget);

    // Replace the widget tree with an empty Container to trigger dispose()
    // on all child widgets (including _CountdownTimerRow's periodic Timer).
    // This prevents the "A Timer is still pending" assertion from the framework.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
