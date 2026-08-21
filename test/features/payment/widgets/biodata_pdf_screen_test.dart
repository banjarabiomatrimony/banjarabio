import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';
import 'package:printing/printing.dart';

import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/core/providers/locale_provider.dart';

import 'package:banjarabio/core/models/backend_response.dart';
import 'package:banjarabio/core/providers/profile_providers.dart';
import 'package:banjarabio/core/repositories/profile_repository.dart';
import 'package:banjarabio/presentation/biodata_screen/biodata_screen.dart';
import '../../../helpers/supabase_test_setup.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

Widget wrapWithSizer(Widget child) {
  return Sizer(
    builder: (context, orientation, screenType) => child,
  );
}

void main() {
  late MockProfileRepository mockProfileRepo;

  setUpAll(() async {
    await ensureSupabaseTestSetup();
  });

  setUp(() {
    mockProfileRepo = MockProfileRepository();
    when(() => mockProfileRepo.getOwnProfile())
        .thenAnswer((_) async => BackendResponse.success(null));
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockProfileRepo),
        ],
        child: wrapWithSizer(
          const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: appSupportedLocales,
            locale: Locale('en'),
            home: BiodataScreen(),
          ),
        ),
      ),
    );
  }

  test('BiodataScreen is ConsumerStatefulWidget', () {
    expect(const BiodataScreen(), isA<ConsumerStatefulWidget>());
  });

  testWidgets('shows loading or content', (tester) async {
    await pumpScreen(tester);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    final hasProfileNotFound = find.text('Profile not found').evaluate().isNotEmpty;
    final hasUnlockTitle = find.text('Unlock Premium Biodata').evaluate().isNotEmpty;
    final hasAppBar = find.text('Biodata PDF').evaluate().isNotEmpty;
    expect(hasLoading || hasProfileNotFound || hasUnlockTitle || hasAppBar, true);
  });

  testWidgets('bypasses paywall during growth campaign even when profile is locked', (tester) async {
    when(() => mockProfileRepo.getOwnProfile()).thenAnswer(
      (_) async => BackendResponse.success(createLockedTestProfile()),
    );
    await pumpScreen(tester);
    await tester.pump();
    
    // Wait for async tasks to complete
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    
    // During campaign, the unlock button is not shown, and preview is unlocked
    expect(find.text('Pay ₹199 to Unlock Full PDF'), findsNothing);
    expect(find.byType(PdfPreview), findsOneWidget);
  });
}
