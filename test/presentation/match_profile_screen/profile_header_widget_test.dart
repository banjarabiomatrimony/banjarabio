import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';
import 'package:banjarabio/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:banjarabio/presentation/match_profile_screen/widgets/profile_header_widget.dart';

Widget wrapWithSizer(Widget child) => Sizer(
  builder: (context, orientation, deviceType) => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: SizedBox(
        width: 1080,
        height: 2400,
        child: child,
      ),
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final baseMockProfile = {
    'id': 'BB-1024',
    'name': 'Pooja Rathod',
    'age': 25,
    'height': "5'6\"",
    'gotra': 'Rathod (Khamani)',
    'profession': 'Software Engineer',
    'working_status': 'Working',
    'location': 'Pune, Maharashtra',
    'tanda': 'Kandhar Tanda',
    'annual_income': '₹18 LPA',
    'education': 'B.Tech Computer Science',
    'isVerified': true,
    'trust_score': 95,
    'profileCompletion': 90,
    'compatibility': 92,
    'photos': ['assets/images/placeholder.png', 'assets/images/placeholder2.png'],
  };

  group('ProfileHeaderWidget 4-Plan Dynamic UI/UX Overlays', () {
    testWidgets('renders Free plan top, center, and bottom glass card correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final freeProfile = Map<String, dynamic>.from(baseMockProfile)
        ..['membership_tier'] = 'free';

      await tester.pumpWidget(wrapWithSizer(
        ProfileHeaderWidget(
          profileData: freeProfile,
          isPremium: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      // Top Bar Badges
      expect(find.text('95% Trust'), findsOneWidget);
      expect(find.text('90% Complete'), findsOneWidget);
      expect(find.text('Free Plan'), findsOneWidget);

      // Center Rails
      expect(find.text('ID: BB-1024'), findsOneWidget);
      expect(find.textContaining('1 Photo (🔒 +1)'), findsOneWidget);

      // Bottom Glass Card
      expect(find.text('Pooja Rathod, 25'), findsOneWidget);
      expect(find.textContaining("5'6\""), findsWidgets);
      expect(find.textContaining('Software Engineer'), findsWidgets);
      expect(find.textContaining('Pune, Maharashtra'), findsWidgets);
      expect(find.text('92% Match'), findsOneWidget);
    });

    testWidgets('renders BVS Community plan with BVS badges and community hooks', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final bvsProfile = Map<String, dynamic>.from(baseMockProfile)
        ..['membership_tier'] = 'bvs'
        ..['isBvsVerified'] = true
        ..['displayId'] = 'BV-2048';

      await tester.pumpWidget(wrapWithSizer(
        ProfileHeaderWidget(
          profileData: bvsProfile,
          isPremium: false,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      // Row 3 Badges
      expect(find.text('🏛️ BVS Member'), findsOneWidget);
      expect(find.text('95% Trust'), findsOneWidget);
      expect(find.text('90% Complete'), findsOneWidget);

      // Center Rails
      expect(find.text('🏛️ BVS: BV-2048'), findsOneWidget);
      expect(find.text('📸 1/2'), findsOneWidget);
    });

    testWidgets('renders Self-Service Gold plan with Gold Member badge and completion', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final goldProfile = Map<String, dynamic>.from(baseMockProfile)
        ..['membership_tier'] = 'gold';

      await tester.pumpWidget(wrapWithSizer(
        ProfileHeaderWidget(
          profileData: goldProfile,
          isPremium: true,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      // Row 3 Badges
      expect(find.text('⭐ Gold Member'), findsOneWidget);
      expect(find.text('95% Trust'), findsOneWidget);
      expect(find.text('90% Complete'), findsOneWidget);

      // Center Rails
      expect(find.text('ID: BB-1024'), findsOneWidget);
      expect(find.text('📸 1/2'), findsOneWidget);
    });

    testWidgets('renders VIP Royal plan with VIP crown, VIP badge, and concierge tags', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final vipProfile = Map<String, dynamic>.from(baseMockProfile)
        ..['membership_tier'] = 'royal'
        ..['isVip'] = true
        ..['displayId'] = 'VIP-9012';

      await tester.pumpWidget(wrapWithSizer(
        ProfileHeaderWidget(
          profileData: vipProfile,
          isPremium: true,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      // Row 3 Badges
      expect(find.text('👑 VIP Royal'), findsOneWidget);
      expect(find.text('95% Trust'), findsOneWidget);
      expect(find.text('90% Complete'), findsOneWidget);

      // Center Rails
      expect(find.text('👑 VIP: VIP-9012'), findsOneWidget);
      expect(find.text('📸 1/2'), findsOneWidget);

      // VIP Crown in Name row
      expect(find.text('👑'), findsOneWidget);
    });
  });
}
