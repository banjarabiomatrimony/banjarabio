import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/widget_test_helpers.dart';
import 'package:banjarabio/presentation/referral_screen/referral_invite_screen.dart';

void main() {
  setUp(() => setupWidgetTestMocks());
  tearDown(() => tearDownWidgetTestMocks());

  testWidgets('renders Scaffold', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const ReferralInviteScreen()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('does not crash on settle', (tester) async {
    setTestScreenSize(tester);
    await tester.pumpWidget(createTestableWidget(const ReferralInviteScreen()));
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(Scaffold), findsWidgets);
  });
}
