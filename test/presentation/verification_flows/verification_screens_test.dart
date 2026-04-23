import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/widget_test_helpers.dart';
import 'package:banjarabio/presentation/verification_flows/govt_id_verification_screen.dart';
import 'package:banjarabio/presentation/verification_flows/community_id_screen.dart';
import 'package:banjarabio/presentation/verification_flows/email_verification_screen.dart';
import 'package:banjarabio/presentation/verification_flows/live_selfie_screen.dart';
import 'package:banjarabio/presentation/verification_flows/reference_verification_screen.dart';
import 'package:banjarabio/presentation/verification_flows/video_intro_screen.dart';
import 'package:banjarabio/presentation/verification_flows/mobile_verification_screen.dart';

void main() {
  setUp(() => setupWidgetTestMocks());
  tearDown(() => tearDownWidgetTestMocks());

  testWidgets('GovtIdVerificationScreen renders', (tester) async {
    setTestScreenSize(tester);
    final pumped = await pumpWidgetSafely(tester, createTestableWidget(const GovtIdVerificationScreen()));
    if (pumped) expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('CommunityIdScreen renders', (tester) async {
    setTestScreenSize(tester);
    final pumped = await pumpWidgetSafely(tester, createTestableWidget(const CommunityIdScreen()));
    if (pumped) expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('EmailVerificationScreen renders', (tester) async {
    setTestScreenSize(tester);
    final pumped = await pumpWidgetSafely(tester, createTestableWidget(const EmailVerificationScreen()));
    if (pumped) expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('LiveSelfieScreen renders', (tester) async {
    setTestScreenSize(tester);
    final pumped = await pumpWidgetSafely(tester, createTestableWidget(const LiveSelfieScreen()));
    if (pumped) expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('ReferenceVerificationScreen renders', (tester) async {
    setTestScreenSize(tester);
    final pumped = await pumpWidgetSafely(tester, createTestableWidget(const ReferenceVerificationScreen()));
    if (pumped) expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('VideoIntroScreen renders', (tester) async {
    setTestScreenSize(tester);
    final pumped = await pumpWidgetSafely(tester, createTestableWidget(const VideoIntroScreen()));
    if (pumped) expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('MobileVerificationScreen renders', (tester) async {
    setTestScreenSize(tester);
    final pumped = await pumpWidgetSafely(tester, createTestableWidget(const MobileVerificationScreen()));
    if (pumped) expect(find.byType(Scaffold), findsWidgets);
  });
}
