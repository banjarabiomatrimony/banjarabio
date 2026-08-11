import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:banjarabio/core/services/analytics_service.dart';
import 'package:banjarabio/presentation/melava_screen/melava_screen.dart';

import '../../helpers/widget_test_helpers.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

void main() {
  late MockFirebaseAnalytics mockAnalytics;
  late MockUrlLauncher mockUrlLauncher;

  setUpAll(() {
    registerFallbackValue(<String, Object?>{});
    registerFallbackValue(Uri.parse('tel:+919876543210'));
    registerFallbackValue(const LaunchOptions());
  });

  setUp(() {
    setupWidgetTestMocks();

    mockAnalytics = MockFirebaseAnalytics();
    AnalyticsService().testAnalytics = mockAnalytics;

    mockUrlLauncher = MockUrlLauncher();
    UrlLauncherPlatform.instance = mockUrlLauncher;
  });

  tearDown(() {
    tearDownWidgetTestMocks();
    AnalyticsService().reset();
  });

  testWidgets('MelavaScreen renders all components and mock events', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Mock screen view analytics
    when(() => mockAnalytics.logScreenView(screenName: any(named: 'screenName')))
        .thenAnswer((_) async {});

    await tester.pumpWidget(createTestableWidget(
      const MelavaScreen(),
    ));

    await tester.pumpAndSettle();

    // Verify analytics screen view is logged
    verify(() => mockAnalytics.logScreenView(screenName: 'melava_directory')).called(1);

    // Verify Title & Header card elements are present (Appbar title and section header both default to localized values)
    expect(find.text('Upcoming Melavas'), findsWidgets);
    expect(find.text('Banjara Parichay Melavas'), findsOneWidget);
    expect(
      find.text('Discover regional matrimonial get-togethers. Partner trusts list these events. Reach organizers directly to register.'),
      findsOneWidget,
    );

    // Verify the mock events are displayed
    expect(find.text('Pune Banjara Vadhu-Var Melava'), findsOneWidget);
    expect(find.text('Washim Banjara Parichay Melava'), findsOneWidget);
    expect(find.text('Bengaluru Banjara Matrimony Meet'), findsOneWidget);
    expect(find.text('Hyderabad Lambada Parichay Melava'), findsOneWidget);
    expect(find.text('Nanded Gor Banjara Mahamelava'), findsOneWidget);
    expect(find.text('Global Gor-Banjara Matrimony Meet (Virtual)'), findsOneWidget);

    // Verify trust badges and metadata chips are rendered on the screen
    expect(find.text('VERIFIED TRUST PARTNER'), findsWidgets);
    expect(find.text('OFFICIAL DIGITAL PARTNER'), findsWidgets);
    expect(find.text('IT & Urban Professionals'), findsWidgets);
    expect(find.text('800+ Candidates'), findsWidgets);
    expect(find.text('Free Entry (Booklet Inc.)'), findsWidgets);
  });

  testWidgets('Tapping View Details opens bottom sheet and logs analytics', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => mockAnalytics.logScreenView(screenName: any(named: 'screenName')))
        .thenAnswer((_) async {});
    when(() => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});

    await tester.pumpWidget(createTestableWidget(
      const MelavaScreen(),
    ));

    await tester.pumpAndSettle();

    // Find first "View Venue" button (which maps to localized viewVenue key, fallback 'View Details')
    final viewVenueButtons = find.text('View Venue');
    expect(viewVenueButtons, findsWidgets);

    // Tap the first View Venue button
    await tester.tap(viewVenueButtons.first);
    await tester.pumpAndSettle();

    // Verify bottom sheet is displayed by looking for close button or organizer field
    expect(find.text('Event Details'), findsOneWidget);
    expect(find.text('by Banjara Seva Sangh, Pune'), findsOneWidget);

    // Verify new metadata rows in bottom sheet
    expect(find.text('Candidate Focus'), findsOneWidget);
    expect(find.text('IT & Urban Professionals'), findsWidgets);
    expect(find.text('Expected Profiles'), findsOneWidget);
    expect(find.text('800+ Candidates'), findsWidgets);
    expect(find.text('Registration Info'), findsOneWidget);
    expect(find.text('Free Entry (Booklet Inc.)'), findsWidgets);
    expect(find.text('Verification Status'), findsOneWidget);
    expect(find.text('Verified Trust Partner'), findsOneWidget);

    // Verify Partnership Vision Callout banner is present
    expect(find.text('BanjaraBio Platform Partnership'), findsOneWidget);
    expect(
      find.text('This event is organized by a verified community trust. BanjaraBio acts as a digital discovery partner to help you find and connect with local matrimonial events. Together, we are building a stronger, digital Banjara community.'),
      findsOneWidget,
    );

    // Verify analytics logged the view details event
    verify(() => mockAnalytics.logEvent(
          name: 'melava_view_details_tap',
          parameters: {
            'melava_id': 'pune_2026',
            'melava_title': 'Pune Banjara Vadhu-Var Melava',
          },
        )).called(1);

    // Tap Close to dismiss
    await tester.tap(find.byKey(const Key('melava_details_close_btn')));
    await tester.pumpAndSettle();

    expect(find.text('Event Details'), findsNothing);
  });

  testWidgets('Tapping Call Organizer calls dialer and logs analytics', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => mockAnalytics.logScreenView(screenName: any(named: 'screenName')))
        .thenAnswer((_) async {});
    when(() => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});

    when(() => mockUrlLauncher.canLaunch('tel:+919876543210')).thenAnswer((_) async => true);
    when(() => mockUrlLauncher.launchUrl(any(), any())).thenAnswer((_) async => true);

    await tester.pumpWidget(createTestableWidget(
      const MelavaScreen(),
    ));

    await tester.pumpAndSettle();

    // Tap call button for Pune event
    final callButtons = find.text('Call Organizer');
    expect(callButtons, findsWidgets);

    await tester.tap(callButtons.first);
    await tester.pumpAndSettle();

    // Verify analytics event
    verify(() => mockAnalytics.logEvent(
          name: 'melava_call_organizer_tap',
          parameters: {
            'melava_id': 'pune_2026',
            'melava_title': 'Pune Banjara Vadhu-Var Melava',
          },
        )).called(1);

    // Verify that url_launcher was triggered
    verify(() => mockUrlLauncher.canLaunch('tel:+919876543210')).called(1);
  });

  testWidgets('Searching events by text filters the list', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => mockAnalytics.logScreenView(screenName: any(named: 'screenName')))
        .thenAnswer((_) async {});

    await tester.pumpWidget(createTestableWidget(
      const MelavaScreen(),
    ));
    await tester.pumpAndSettle();

    // Verify initially we see multiple events
    expect(find.text('Pune Banjara Vadhu-Var Melava'), findsOneWidget);
    expect(find.text('Bengaluru Banjara Matrimony Meet'), findsOneWidget);

    // Enter search text
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'Pune');
    await tester.pumpAndSettle();

    // Now we should see Pune, but not Bengaluru
    expect(find.text('Pune Banjara Vadhu-Var Melava'), findsOneWidget);
    expect(find.text('Bengaluru Banjara Matrimony Meet'), findsNothing);

    // Clear search
    final clearButton = find.byIcon(Icons.clear_rounded);
    expect(clearButton, findsOneWidget);
    await tester.tap(clearButton);
    await tester.pumpAndSettle();

    // Now we should see both again
    expect(find.text('Pune Banjara Vadhu-Var Melava'), findsOneWidget);
    expect(find.text('Bengaluru Banjara Matrimony Meet'), findsOneWidget);
  });

  testWidgets('Tapping state chips filters the list by state', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => mockAnalytics.logScreenView(screenName: any(named: 'screenName')))
        .thenAnswer((_) async {});

    await tester.pumpWidget(createTestableWidget(
      const MelavaScreen(),
    ));
    await tester.pumpAndSettle();

    // Tap Maharashtra chip
    final maharashtraChip = find.text('Maharashtra');
    expect(maharashtraChip, findsOneWidget);
    await tester.tap(maharashtraChip);
    await tester.pumpAndSettle();

    // Pune is in Maharashtra, Bengaluru is in Karnataka
    expect(find.text('Pune Banjara Vadhu-Var Melava'), findsOneWidget);
    expect(find.text('Bengaluru Banjara Matrimony Meet'), findsNothing);

    // Tap Karnataka chip
    final karnatakaChip = find.text('Karnataka');
    expect(karnatakaChip, findsOneWidget);
    await tester.tap(karnatakaChip);
    await tester.pumpAndSettle();

    expect(find.text('Pune Banjara Vadhu-Var Melava'), findsNothing);
    expect(find.text('Bengaluru Banjara Matrimony Meet'), findsOneWidget);

    // Tap All chip
    final allChip = find.text('All');
    expect(allChip, findsOneWidget);
    await tester.tap(allChip);
    await tester.pumpAndSettle();

    expect(find.text('Pune Banjara Vadhu-Var Melava'), findsOneWidget);
    expect(find.text('Bengaluru Banjara Matrimony Meet'), findsOneWidget);
  });

  testWidgets('Searching for non-existent event shows empty state and suggests event', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => mockAnalytics.logScreenView(screenName: any(named: 'screenName')))
        .thenAnswer((_) async {});
    when(() => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});
    when(() => mockUrlLauncher.canLaunch(any())).thenAnswer((_) async => true);
    when(() => mockUrlLauncher.launchUrl(any(), any())).thenAnswer((_) async => true);

    await tester.pumpWidget(createTestableWidget(
      const MelavaScreen(),
    ));
    await tester.pumpAndSettle();

    // Enter search query with no match
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'xyzxyz');
    await tester.pumpAndSettle();

    // Verify empty state is displayed
    expect(find.text('No Parichay Melavas Found'), findsOneWidget);
    expect(find.text('Suggest an Event'), findsOneWidget);

    // Tap Suggest an Event
    await tester.tap(find.text('Suggest an Event'));
    await tester.pumpAndSettle();

    // Verify analytics logged the suggest event click
    verify(() => mockAnalytics.logEvent(
          name: 'melava_suggest_event_tap',
        )).called(1);

    // Verify that url_launcher was triggered with the WhatsApp URL
    verify(() => mockUrlLauncher.canLaunch(any(that: startsWith('https://wa.me/')))).called(1);
  });

  testWidgets('Tapping share button logs analytics and triggers share', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => mockAnalytics.logScreenView(screenName: any(named: 'screenName')))
        .thenAnswer((_) async {});
    when(() => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});

    // Set up mock method call handler for share channel
    final List<MethodCall> methodCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/share'),
      (MethodCall methodCall) async {
        methodCalls.add(methodCall);
        return null;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/share'),
      (MethodCall methodCall) async {
        methodCalls.add(methodCall);
        return null;
      },
    );

    await tester.pumpWidget(createTestableWidget(
      const MelavaScreen(),
    ));
    await tester.pumpAndSettle();

    // Tap share button for Pune event (should be first one since it's the first event card)
    final shareButton = find.byKey(const Key('share_btn_pune_2026'));
    expect(shareButton, findsOneWidget);

    await tester.tap(shareButton);
    await tester.pumpAndSettle();

    // Verify analytics event
    verify(() => mockAnalytics.logEvent(
          name: 'melava_share_tap',
          parameters: {
            'melava_id': 'pune_2026',
            'melava_title': 'Pune Banjara Vadhu-Var Melava',
          },
        )).called(1);

    // Verify method channel was called with the share text
    expect(methodCalls.length, 1);
    expect(methodCalls.first.method, 'share');
    expect(methodCalls.first.arguments['text'], contains('Banjara Parichay Melava Invitation'));
    expect(methodCalls.first.arguments['text'], contains('Pune Banjara Vadhu-Var Melava'));
  });
}
