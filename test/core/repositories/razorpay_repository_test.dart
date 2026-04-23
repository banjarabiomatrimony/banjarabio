import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:banjarabio/core/repositories/razorpay_repository.dart';
import 'package:banjarabio/core/repositories/subscription_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/models/subscription_model.dart';
import 'package:banjarabio/core/models/profile_model.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import '../../helpers/supabase_fakes.dart';

import 'package:banjarabio/shared/billing/razorpay_billing_registry.dart';
import 'package:banjarabio/shared/billing/razorpay_app_billing_config.dart';

class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}
class MockRazorpay extends Mock implements Razorpay {}
class MockRazorpayAppBillingConfig extends Mock implements RazorpayAppBillingConfig {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RazorpayRepository razorpayRepository;
  late FakeSupabaseClient fakeSupabase;
  late MockSubscriptionRepository mockSubscriptionRepository;
  late MockProfileRepository mockProfileRepository;
  late MockRazorpay mockRazorpay;

  late MockRazorpayAppBillingConfig mockBillingConfig;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    mockSubscriptionRepository = MockSubscriptionRepository();
    mockProfileRepository = MockProfileRepository();
    mockRazorpay = MockRazorpay();
    mockBillingConfig = MockRazorpayAppBillingConfig();

    // Register billing config
    when(() => mockBillingConfig.appName).thenReturn('BanjaraBio Test');
    when(() => mockBillingConfig.appSlug).thenReturn('banjara_test');
    when(() => mockBillingConfig.keyId).thenReturn('rzp_test_123');
    when(() => mockBillingConfig.brandColor).thenReturn('#000000');
    when(() => mockBillingConfig.getAmountInPaise(any())).thenReturn(8900);
    when(() => mockBillingConfig.getDisplayName(any())).thenReturn('Platinum Plan');
    when(() => mockBillingConfig.buildNotes(
      userId: any(named: 'userId'),
      planType: any(named: 'planType'),
    )).thenReturn({'user_id': 'u1', 'plan': 'platinum'});

    RazorpayBillingRegistry.register(mockBillingConfig);

    razorpayRepository = RazorpayRepository();
    razorpayRepository.reset();
    razorpayRepository.testClient = fakeSupabase;
    razorpayRepository.testSubscriptionRepository = mockSubscriptionRepository;
    razorpayRepository.testProfileRepository = mockProfileRepository;
    razorpayRepository.testRazorpay = mockRazorpay;

    // Default stubs
    when(() => mockRazorpay.on(any(), any())).thenReturn(null);
    when(() => mockRazorpay.clear()).thenReturn(null);
    
    // Global profile stub for metadata collection
    when(() => mockProfileRepository.getOwnProfile(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((invocation) async {
          final isRefresh = invocation.namedArguments[#forceRefresh] == true;
          return BackendResponse.success(ProfileModel(
              id: '1',
              userId: 'u1',
              fullName: 'Test User',
              isPdfUnlocked: isRefresh, // Returns true if it was a refresh call (after payment)
              gender: 'Male',
              age: 25,
              surname: 'Test',
              height: "5'10\"",
              education: 'Graduate',
              profession: 'Engineer',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
        });
  });

  group('RazorpayRepository - startPayment', () {
    test('startPayment returns failure if user not authenticated', () async {
      (fakeSupabase.auth as dynamic).mockUser = null;

      final result = await razorpayRepository.startPayment(planType: PlanType.platinum);

      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('User not logged in'));
    });

    test('startPayment creates order and opens checkout', () async {
      // Mock authenticated user
      fakeSupabase.mockUser = User(
        id: 'u1',
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        createdAt: DateTime.now().toIso8601String(),
        email: 'test@example.com',
      );

      // Mock Edge Function Success
      fakeSupabase.functionResponse = <String, dynamic>{
        'id': 'order_123',
        'status': 'created',
      };

      // Mock Razorpay.open callback
      when(() => mockRazorpay.open(any())).thenReturn(null);

      // We start the payment but don't await yet because it's a Completer flow
      final paymentFuture = razorpayRepository.startPayment(planType: PlanType.platinum);

      // Verify Razorpay.open was called with expected options
      await untilCalled(() => mockRazorpay.open(any()));
      verify(() => mockRazorpay.open(any(that: isA<Map<String, dynamic>>().having(
        (m) => m['order_id'], 'order_id', 'order_123')))).called(1);

      // Simulate success callback from Razorpay
      final captured = verify(() => mockRazorpay.on(captureAny(), captureAny())).captured;
      int successIdx = -1;
      for (int i = 0; i < captured.length; i += 2) {
        if (captured[i] == 'payment.success') {
          successIdx = i;
          break;
        }
      }
      final successHandler = captured[successIdx + 1] as void Function(PaymentSuccessResponse);

      // Mock verify_payment RPC success
      fakeSupabase.rpcResponse = <String, dynamic>{'status': 'success'};

      // Mock profile and subscription refresh
      when(() => mockSubscriptionRepository.refreshSubscription())
          .thenAnswer((_) async => BackendResponse.success(null));

      // Execute success handler
      // PaymentSuccessResponse(String? paymentId, String? orderId, String? signature, [Map<dynamic, dynamic>? data])
      
      successHandler(PaymentSuccessResponse('pay_123', 'order_123', 'sig_123', {}));

      final result = await paymentFuture;
      expect(result.isSuccess, true);
    });

    test('startPayment handles RPC fallback if Edge Function fails', () async {
      fakeSupabase.mockUser = User(
        id: 'u1',
        appMetadata: {},
        userMetadata: {},
        aud: 'aud',
        createdAt: DateTime.now().toIso8601String(),
      );

      // Mock Edge Function 404
      fakeSupabase.functionError = Exception('Not Found');
      
      // Mock RPC fallback Success (returns 'amount_only' or similar)
      fakeSupabase.rpcResponse = <String, dynamic>{'id': 'amount_only', 'status': 'success'};

      when(() => mockRazorpay.open(any())).thenReturn(null);

      final paymentFuture = razorpayRepository.startPayment(planType: PlanType.platinum);

      // Verify Razorpay.open was called WITHOUT order_id (amount-only flow)
      await untilCalled(() => mockRazorpay.open(any()));
      verify(() => mockRazorpay.open(any(that: isA<Map<String, dynamic>>().having(
        (m) => m.containsKey('order_id'), 'has no order_id', false)))).called(1);

      // Simulate failure from Razorpay SDK
      final captured = verify(() => mockRazorpay.on(captureAny(), captureAny())).captured;
      int errorIdx = -1;
      for (int i = 0; i < captured.length; i += 2) {
        if (captured[i] == 'payment.error') {
          errorIdx = i;
          break;
        }
      }
      final errorHandler = captured[errorIdx + 1] as void Function(PaymentFailureResponse);

      // PaymentFailureResponse(int? code, String? message, [Map<dynamic, dynamic>? data])
      errorHandler(PaymentFailureResponse(Razorpay.PAYMENT_CANCELLED, 'User Cancelled', {}));

      final result = await paymentFuture;
      expect(result.isSuccess, false);
      expect(result.errorMessage, contains('Cancelled'));
    });
   group('RazorpayRepository - Payment History', () {
    test('getPaymentHistory parses list correctly', () async {
      final mockHistory = [
        {'id': 'p1', 'amount': 1000, 'status': 'captured', 'created_at': DateTime.now().toIso8601String()}
      ];
      fakeSupabase.rpcResponse = mockHistory;

      final result = await razorpayRepository.getPaymentHistory();

      expect(result.isSuccess, true);
      expect(result.data.length, 1);
      expect(result.data.first.id, 'p1');
    });
  });
});
}
