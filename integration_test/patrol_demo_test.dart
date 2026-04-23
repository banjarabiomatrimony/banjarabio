import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:banjarabio/main.dart' as app;

void main() {
  patrolTest(
    'Verify app handles native permissions (Demonstration)',
    ($) async {
      // 1. Initialize the app
      app.main();
      await $.pumpAndSettle();

      // 2. Check for splash screen
      expect($(Scaffold), findsOneWidget);

      // 3. Demonstrate Native Permission Handling (Mock/Demo logic)
      // In a real device scenario, Patrol can interact with System dialogs:
      // await $.native.grantPermissionWhenInUse();
      
      // 4. Tap through the UI using Patrol's enhanced selectors
      // Patrol can select widgets by text or icon more easily
      // await $(Icons.person).tap();
      
      debugPrint('Patrol Demo: App initialized and native-aware selectors are ready.');
    },
  );
}
