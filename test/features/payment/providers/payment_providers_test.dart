import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:banjarabio/features/payment/providers/payment_providers.dart';
import 'package:banjarabio/features/payment/repository/payment_repository.dart';
import 'package:banjarabio/core/models/backend_response.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  group('paymentRepositoryProvider', () {
    test('provides PaymentRepository when overridden with mock', () {
      final mockRepo = MockPaymentRepository();
      final container = ProviderContainer(
        overrides: [paymentRepositoryProvider.overrideWithValue(mockRepo)],
      );
      addTearDown(container.dispose);

      final repo = container.read(paymentRepositoryProvider);

      expect(repo, isNotNull);
      expect(repo, isA<PaymentRepository>());
      expect(repo, same(mockRepo));
    });

    test('can be overridden with mock', () async {
      final mockRepo = MockPaymentRepository();
      when(() => mockRepo.isPdfUnlocked())
          .thenAnswer((_) async => BackendResponse.success(true));

      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(paymentRepositoryProvider);
      final result = await repo.isPdfUnlocked();

      expect(result.isSuccess, true);
      expect(result.data, true);
      verify(() => mockRepo.isPdfUnlocked()).called(1);
    });

    test('recordPaymentSuccess delegates to repository', () async {
      final mockRepo = MockPaymentRepository();
      when(() => mockRepo.recordPaymentSuccess(
            orderId: any(named: 'orderId'),
            paymentId: any(named: 'paymentId'),
            signature: any(named: 'signature'),
            amount: any(named: 'amount'),
            planType: any(named: 'planType'),
          )).thenAnswer((_) async => BackendResponse.success(null));

      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(paymentRepositoryProvider);
      await repo.recordPaymentSuccess(
        orderId: 'order-1',
        paymentId: 'pay-1',
        signature: 'sig-1',
        amount: 10000,
        planType: 'biodata_unlock',
      );

      verify(() => mockRepo.recordPaymentSuccess(
            orderId: 'order-1',
            paymentId: 'pay-1',
            signature: 'sig-1',
            amount: 10000,
            planType: 'biodata_unlock',
          )).called(1);
    });
  });
}
