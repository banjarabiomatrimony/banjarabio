import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:banjarabio/features/payment/repository/payment_repository.dart';
import 'package:banjarabio/features/payment/repository/payment_repository_impl.dart';

/// Provider for [PaymentRepository]. Override in tests with mock.
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl();
});
