import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/providers/profile_providers.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/features/trust_score/providers/trust_score_providers.dart';
import 'package:banjarabio/features/trust_score/repository/trust_score_repository.dart';
import 'package:banjarabio/presentation/trust_score_screen/trust_score_screen.dart';

class MockTrustScoreRepository extends Mock implements TrustScoreRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

Widget wrapWithSizer(Widget child) {
  return Sizer(
    builder: (context, orientation, screenType) => child,
  );
}

void main() {
  late MockTrustScoreRepository mockTrustScoreRepo;
  late MockProfileRepository mockProfileRepo;

  setUp(() {
    mockTrustScoreRepo = MockTrustScoreRepository();
    mockProfileRepo = MockProfileRepository();

    when(() => mockTrustScoreRepo.calculateTrustScore(profile: any(named: 'profile')))
        .thenAnswer((_) async => BackendResponse.success(50));
    when(() => mockTrustScoreRepo.getVerificationStatus(profile: any(named: 'profile')))
        .thenAnswer((_) async => BackendResponse.success({}));
    when(() => mockProfileRepo.getOwnProfile())
        .thenAnswer((_) async => BackendResponse.success(null));
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trustScoreRepositoryProvider.overrideWithValue(mockTrustScoreRepo),
          profileRepositoryProvider.overrideWithValue(mockProfileRepo),
        ],
        child: wrapWithSizer(
          const MaterialApp(
            home: TrustScoreScreen(),
          ),
        ),
      ),
    );
  }

  test('TrustScoreScreen is ConsumerStatefulWidget', () {
    expect(const TrustScoreScreen(), isA<ConsumerStatefulWidget>());
  });

  testWidgets('shows loading or content', (tester) async {
    await pumpScreen(tester);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    final hasTitle = find.text('Trust Score & Discounts').evaluate().isNotEmpty;
    final hasScoreCard = find.text('Your Trust Score').evaluate().isNotEmpty;
    final hasIncreaseText = find.textContaining('Increase your Trust Score').evaluate().isNotEmpty;

    expect(hasLoading || hasTitle || hasScoreCard || hasIncreaseText, true);
  });
}
