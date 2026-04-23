import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/home_screen/widgets/offer_banner_widget.dart';
import 'package:banjarabio/core/repositories/banner_repository.dart';
import 'package:sizer/sizer.dart';
import '../../../helpers/supabase_fakes.dart';

void main() {
  late FakeSupabaseClient fakeSupabase;
  late BannerRepository bannerRepository;

  setUp(() {
    fakeSupabase = FakeSupabaseClient();
    bannerRepository = BannerRepository();
    bannerRepository.testClient = fakeSupabase;
  });

  Widget createWidgetUnderTest() {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          home: Scaffold(
            body: OfferBannerWidget(repository: bannerRepository),
          ),
        );
      },
    );
  }

  group('OfferBannerWidget Tests', () {
    testWidgets('shows banners when loaded', (tester) async {
      final now = DateTime.now();
      final mockBanners = [
        {
          'id': 'b1',
          'title': 'Offer 1',
          'image_url': 'https://example.com/img1.jpg',
          'is_active': true,
          'priority': 1,
          'created_at': now.toIso8601String(),
        }
      ];
      
      fakeSupabase.rpcResponse = mockBanners;

      await tester.pumpWidget(createWidgetUnderTest());
      // Initial loading state
      expect(find.byType(OfferBannerWidget), findsOneWidget);
      
      // Wait for loading to finish and images to load
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('shows nothing when no banners found', (tester) async {
      fakeSupabase.rpcResponse = [];

      await tester.pumpWidget(createWidgetUnderTest());
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      expect(find.byType(PageView), findsNothing);
      expect(find.byType(SizedBox), findsWidgets); // Shrink box
    });
  });
}
