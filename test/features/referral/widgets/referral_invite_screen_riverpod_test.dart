import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/features/referral/providers/referral_invite_notifier.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/referral_stats_model.dart';
import 'package:banjarabio/core/repositories/referral_repository.dart';
import 'package:banjarabio/presentation/referral_screen/referral_invite_screen_riverpod.dart';

class MockReferralRepository extends Mock implements ReferralRepository {}

Widget wrapWithSizer(Widget child) {
  return Sizer(
    builder: (context, orientation, screenType) => child,
  );
}

void main() {
  group('ReferralInviteScreenRiverpod', () {
    late MockReferralRepository mockRepository;

    setUp(() {
      mockRepository = MockReferralRepository();
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            referralRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: wrapWithSizer(
            const MaterialApp(
              home: ReferralInviteScreenRiverpod(),
            ),
          ),
        ),
      );
    }

    testWidgets('shows loading then content', (tester) async {
      final statsCompleter = Completer<BackendResponse<ReferralStatsModel>>();
      when(() => mockRepository.getReferralStats())
          .thenAnswer((_) => statsCompleter.future);
      when(() => mockRepository.getMyReferralCode())
          .thenAnswer((_) async => BackendResponse.success('CODE'));

      await pumpScreen(tester);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      statsCompleter.complete(
          BackendResponse.success(ReferralStatsModel.empty('u1')));
      await tester.pumpAndSettle();
      expect(find.text('Refer 3 Friends, Get 1 Month Free!'), findsOneWidget);
    });

    testWidgets('shows content when data loads', (tester) async {
      final stats = ReferralStatsModel(
        userId: 'u1',
        referralCount: 3,
        rewardsEarned: 1,
        updatedAt: DateTime.now(),
      );
      when(() => mockRepository.getReferralStats())
          .thenAnswer((_) async => BackendResponse.success(stats));
      when(() => mockRepository.getMyReferralCode())
          .thenAnswer((_) async => BackendResponse.success('BANJARA-X'));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Refer 3 Friends, Get 1 Month Free!'), findsOneWidget);
      expect(find.text('Your Personal Invite Link'), findsOneWidget);
      expect(find.text('Share Link on WhatsApp'), findsOneWidget);
    });

    testWidgets('shows error state with retry when load throws', (tester) async {
      when(() => mockRepository.getReferralStats())
          .thenThrow(Exception('Network error'));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Failed to load referral data'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    test('is ConsumerWidget (Riverpod-based)', () {
      expect(const ReferralInviteScreenRiverpod(), isA<ConsumerWidget>());
    });
  });
}
