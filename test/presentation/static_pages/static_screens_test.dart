import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:banjarabio/presentation/static_pages/terms_conditions_screen.dart';
import 'package:banjarabio/presentation/static_pages/privacy_policy_screen.dart';
import 'package:banjarabio/presentation/static_pages/faq_screen.dart';
import 'package:banjarabio/presentation/static_pages/contact_us_screen.dart';
import 'package:banjarabio/presentation/static_pages/account_deletion_screen.dart';

Widget _buildTestWrapper(Widget child) {
  return Sizer(
    builder: (context, orientation, deviceType) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      );
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Static Pages Widget Tests', () {
    testWidgets('TermsConditionsScreen renders properly', (tester) async {
      await tester.pumpWidget(_buildTestWrapper(const TermsConditionsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TermsConditionsScreen), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('PrivacyPolicyScreen renders properly', (tester) async {
      await tester.pumpWidget(_buildTestWrapper(const PrivacyPolicyScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('FAQScreen renders and filters queries', (tester) async {
      await tester.pumpWidget(_buildTestWrapper(const FAQScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(FAQScreen), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'trust');
      await tester.pumpAndSettle();
      expect(find.byType(FAQScreen), findsOneWidget);
    });

    testWidgets('ContactUsScreen renders support channels', (tester) async {
      await tester.pumpWidget(_buildTestWrapper(const ContactUsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ContactUsScreen), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('AccountDeletionScreen renders warning and checkbox', (tester) async {
      await tester.pumpWidget(_buildTestWrapper(const AccountDeletionScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(AccountDeletionScreen), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
    });
  });
}
