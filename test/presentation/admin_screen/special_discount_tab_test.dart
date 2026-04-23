import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:banjarabio/presentation/admin_screen/special_discount_tab.dart';
import 'package:banjarabio/core/repositories/admin_repository.dart';
import 'package:banjarabio/core/models/backend_response.dart';

class MockAdminRepository extends Mock implements AdminRepository {}

void main() {
  late MockAdminRepository mockAdminRepository;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockAdminRepository = MockAdminRepository();
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
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SpecialDiscountTab(
                  theme: ThemeData.light(),
                  adminRepository: mockAdminRepository,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  testWidgets('SpecialDiscountTab validates input and calls grantSpecialDiscount', (WidgetTester tester) async {
    // 1. Setup mock
    when(() => mockAdminRepository.grantSpecialDiscount(
      userId: any(named: 'userId'),
      percentage: any(named: 'percentage'),
      expiresAt: any(named: 'expiresAt'),
    )).thenAnswer((_) async => BackendResponse.success(null));

    // 2. Load widget
    await tester.pumpWidget(createWidgetUnderTest());

    // 3. Enter data
    await tester.enterText(find.byType(TextFormField).at(0), 'test-user-id');
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(1), '20');
    await tester.pump();

    // 4. Click Grant
    await tester.tap(find.widgetWithText(ElevatedButton, 'Grant Special Discount'));
    await tester.pumpAndSettle();

    // 5. Verify repository call
    verify(() => mockAdminRepository.grantSpecialDiscount(
      userId: 'test-user-id',
      percentage: 20,
      expiresAt: any(named: 'expiresAt'),
    )).called(1);

    // 6. Check success message
    expect(find.text('Special discount granted successfully!'), findsOneWidget);
  });

  testWidgets('SpecialDiscountTab shows error for invalid discount percentage', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Enter invalid discount (>100)
    await tester.enterText(find.byType(TextFormField).at(0), 'user-123');
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(1), '150');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Grant Special Discount'));
    await tester.pump();

    expect(find.text('Enter 0-100'), findsOneWidget);
  });
}
