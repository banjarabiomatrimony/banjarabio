import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/vendor_registration_screen/vendor_registration_screen.dart';

Widget _buildVendorScreenTestWrapper(Widget child) {
  return ProviderScope(
    child: Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        );
      },
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VendorRegistrationScreen Widget Tests', () {
    testWidgets('renders vendor registration flow and category selectors', (tester) async {
      await tester.pumpWidget(_buildVendorScreenTestWrapper(const VendorRegistrationScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(VendorRegistrationScreen), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });
}
