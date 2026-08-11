import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/presentation/admin_screen/admin_dashboard_screen.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/core/repositories/influencer_repository.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/models/creator_model.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../helpers/supabase_fakes.dart';

import 'dart:io';

class MockAdminRepository extends Mock implements AdminRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}
class MockInfluencerRepository extends Mock implements InfluencerRepository {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient extends Mock implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest extends Mock implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }
}

class _MockHttpClientResponse extends Mock implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => transparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([transparentImage]).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  static final List<int> transparentImage = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
    0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
    0x41, 0x54, 0x08, 0xD7, 0x63, 0x60, 0x00, 0x02, 0x00, 0x01, 0x05, 0x00, 0x01,
    0x0D, 0x26, 0xE5, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
    0x60, 0x82,
  ];
}

void main() {
  late MockAdminRepository mockAdminRepository;
  late MockProfileRepository mockProfileRepository;
  late MockInfluencerRepository mockInfluencerRepository;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
    registerFallbackValue(Uri.parse('http://localhost'));
  });

  setUp(() {
    mockAdminRepository = MockAdminRepository();
    mockProfileRepository = MockProfileRepository();
    mockInfluencerRepository = MockInfluencerRepository();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    // Setup Singletons/DI
    AdminRepository().testClient = FakeSupabaseClient();
    ProfileRepository().testClient = FakeSupabaseClient();
    InfluencerRepository().testClient = FakeSupabaseClient();
    
    // Setup Auth
    AppSupabaseClient.testAuth = mockAuth;
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.email).thenReturn('admin@banjarabio.com');
  });

  Widget createWidgetUnderTest() {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: AdminDashboardScreen(
            adminRepository: mockAdminRepository,
            influencerRepository: mockInfluencerRepository,
            profileRepository: mockProfileRepository,
          ),
        );
      },
    );
  }

  testWidgets('AdminDashboardScreen shows loading initially and then shows stats', (WidgetTester tester) async {
    // Stub repo calls
    when(() => mockProfileRepository.getOwnProfile()).thenAnswer(
      (_) async => BackendResponse.success(null), // Admin by email check first
    );
    when(() => mockAdminRepository.getAdminStats()).thenAnswer(
      (_) async => BackendResponse.success({
        'total_auth_users': 100,
        'pending_verifications': 5,
        'women_count': 40,
        'men_count': 60,
        'revenue_total': 5000,
        'revenue_monthly': 1500,
        'revenue_today': 200,
        'revenue_pdf': 300,
        'revenue_subscription': 4700,
      }),
    );
    when(() => mockAdminRepository.getPendingVerifications()).thenAnswer(
      (_) async => BackendResponse.success([]),
    );
    when(() => mockAdminRepository.getPendingReferences()).thenAnswer(
      (_) async => BackendResponse.success([]),
    );
    when(() => mockInfluencerRepository.getAllCreators()).thenAnswer(
      (_) async => BackendResponse.success([]),
    );
    when(() => mockAdminRepository.getPaymentsList(
      limit: any(named: 'limit'),
      offset: any(named: 'offset'),
    )).thenAnswer(
      (_) async => BackendResponse.success([]),
    );
    when(() => mockAdminRepository.getAllProfiles(
      limit: any(named: 'limit'),
      offset: any(named: 'offset'),
      searchQuery: any(named: 'searchQuery'),
      gender: any(named: 'gender'),
      isPremium: any(named: 'isPremium'),
    )).thenAnswer(
      (_) async => BackendResponse.success([]),
    );

    // Load widget
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify loading state or screen presence
    expect(find.byType(AdminDashboardScreen), findsOneWidget);

    // Wait for data load
    await tester.pumpAndSettle();

    // Check if we are still on the screen (did not pop)
    expect(find.byType(AdminDashboardScreen), findsOneWidget);

    // Verify stats are displayed
    // Financial section - Visible in diagnostics
    expect(find.textContaining('Financial Performance'), findsWidgets);
    expect(find.textContaining('All Time Revenue'), findsWidgets);
    expect(find.textContaining('5000'), findsWidgets); // revenue_total
    expect(find.textContaining(RegExp('combined', caseSensitive: false)), findsWidgets);
  });

  testWidgets('Verification Review Dialog shows Identity Comparison and Contact buttons', (WidgetTester tester) async {
    // 1. Mock Data Setup
    final mockRequest = {
      'id': 'req1',
      'user_id': 'user1',
      'verification_type': 'govt_id',
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
      'payload': {
        'doc_type': 'Aadhar',
        'id_number': '123456789012',
        'selfie_url': 'selfie.jpg',
        'proof_url': 'aadhar.jpg',
      },
      'profiles': {
        'full_name': 'Test User',
        'email': 'test@example.com',
        'phone_number': '9876543210',
        'photos': [
          {'public_url': 'https://example.com/photo.jpg'}
        ]
      }
    };

    when(() => mockProfileRepository.getOwnProfile()).thenAnswer(
      (_) async => BackendResponse.success(null),
    );
    when(() => mockAdminRepository.getAdminStats()).thenAnswer(
      (_) async => BackendResponse.success({'total_auth_users': 100}),
    );
    when(() => mockAdminRepository.getPendingVerifications()).thenAnswer(
      (_) async => BackendResponse.success([mockRequest]),
    );
    when(() => mockAdminRepository.getPendingReferences()).thenAnswer(
      (_) async => BackendResponse.success([]),
    );
    when(() => mockInfluencerRepository.getAllCreators()).thenAnswer(
      (_) async => BackendResponse.success([]),
    );
    when(() => mockAdminRepository.getPaymentsList()).thenAnswer(
      (_) async => BackendResponse.success([]),
    );
    when(() => mockAdminRepository.getSignedUrl(any(), any())).thenAnswer(
      (_) async => BackendResponse.success('https://signed-url.com'),
    );

    // 2. Load Widget
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // 3. Switch to Review Tab
    await tester.tap(find.byIcon(Icons.rate_review_outlined)); 
    await tester.pumpAndSettle();

    // 4. Verify Request Card presence
    expect(find.text('Test User'), findsWidgets);
    expect(find.text('Aadhar'), findsWidgets);

    // 5. Open Review Dialog
    await tester.tap(find.text('Review & Verify'));
    await tester.pumpAndSettle();

    // 6. Verify Identity Comparison and Contact buttons in Dialog
    expect(find.text('Identity Verification'), findsOneWidget);
    expect(find.text('Profile Photo'), findsOneWidget);
    expect(find.text('Selfie Proof'), findsOneWidget);
    
    // Check contact buttons specifically in the dialog (BottomSheet)
    expect(find.descendant(of: find.byType(BottomSheet), matching: find.text('Call')), findsOneWidget);
    expect(find.descendant(of: find.byType(BottomSheet), matching: find.text('WhatsApp')), findsOneWidget);
    
    // Verify icons exist in the dialog
    expect(find.descendant(of: find.byType(BottomSheet), matching: find.byIcon(Icons.call)), findsOneWidget);
    expect(find.descendant(of: find.byType(BottomSheet), matching: find.byIcon(Icons.chat)), findsOneWidget);

    // Close the dialog first (so everything is unmounted/disposed)
    await tester.tapAt(const Offset(10, 10)); // Tap outside bottom sheet to close it
    await tester.pumpAndSettle();

    // Allow background cache manager timers to complete
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('Payments Search Bar filters correctly', (WidgetTester tester) async {
    // 1. Mock Data Setup
    final mockPayments = [
      {
        'id': 'pay1',
        'amount': 500,
        'category': 'Subscription',
        'payment_type': 'Subscription',
        'promo_code': 'PROMO10',
        'created_at': DateTime.now().toIso8601String(),
        'profiles': {'full_name': 'Alice User', 'email': 'alice@example.com'}
      },
      {
        'id': 'pay2',
        'amount': 300,
        'category': 'Subscription',
        'payment_type': 'Subscription',
        'promo_code': 'OFFER20',
        'created_at': DateTime.now().toIso8601String(),
        'profiles': {'full_name': 'Bob Smith', 'email': 'bob@example.com'}
      },
    ];

    when(() => mockAdminRepository.getAdminStats()).thenAnswer(
      (_) async => BackendResponse.success({}),
    );
    when(() => mockAdminRepository.getPaymentsList(
      limit: any(named: 'limit'),
      offset: any(named: 'offset'),
    )).thenAnswer(
      (_) async => BackendResponse.success(mockPayments),
    );
    when(() => mockAdminRepository.getPendingVerifications()).thenAnswer((_) async => BackendResponse.success([]));
    when(() => mockAdminRepository.getPendingReferences()).thenAnswer((_) async => BackendResponse.success([]));
    when(() => mockInfluencerRepository.getAllCreators()).thenAnswer((_) async => BackendResponse.success([]));

    // 2. Load Widget
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // 3. Switch to Payments Tab
    await tester.tap(find.byIcon(Icons.payments_outlined));
    await tester.pumpAndSettle();

    // 4. Verify both payments exist
    expect(find.text('Alice User'), findsOneWidget);
    expect(find.text('Bob Smith'), findsOneWidget);

    // 5. Use Search Bar
    final searchField = find.byType(TextField); // First TextField in Payments is search
    await tester.enterText(searchField, 'Alice');
    await tester.pump(); // Client-side filter

    // 6. Verify Bob is filtered out
    expect(find.text('Alice User'), findsOneWidget);
    expect(find.text('Bob Smith'), findsNothing);

    // 7. Search by Promo Code
    await tester.enterText(searchField, 'OFFER20');
    await tester.pump();

    // 8. Verify Alice is filtered out
    expect(find.text('Alice User'), findsNothing);
    expect(find.text('Bob Smith'), findsOneWidget);
  });

  testWidgets('Creators card shows call and whatsapp buttons', (WidgetTester tester) async {
    // 1. Mock Data Setup
    final mockCreators = [
      Creator(
        id: 'c1',
        name: 'Influencer One',
        promoCode: 'INF10',
        commissionPct: 0.1,
        phoneNumber: '9998887776',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    when(() => mockAdminRepository.getAdminStats()).thenAnswer((_) async => BackendResponse.success({}));
    when(() => mockAdminRepository.getPendingVerifications()).thenAnswer((_) async => BackendResponse.success([]));
    when(() => mockAdminRepository.getPendingReferences()).thenAnswer((_) async => BackendResponse.success([]));
    when(() => mockInfluencerRepository.getAllCreators()).thenAnswer((_) async => BackendResponse.success(mockCreators));
    when(() => mockAdminRepository.getPaymentsList(
      limit: any(named: 'limit'),
      offset: any(named: 'offset'),
    )).thenAnswer((_) async => BackendResponse.success([]));

    // 2. Load Widget
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // 3. Switch to Creators Tab
    await tester.tap(find.byIcon(Icons.campaign_outlined));
    await tester.pumpAndSettle();

    // 4. Verify Creator presence
    expect(find.text('Influencer One'), findsOneWidget);

    // 5. Verify Contact Buttons
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.byIcon(Icons.call), findsOneWidget);
    expect(find.byIcon(Icons.chat), findsOneWidget);
  });
}
