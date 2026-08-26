import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/utils/tour_keys.dart';

void main() {
  group('TourKeys Tests', () {
    test('all keys are initialized', () {
      expect(TourKeys.locationKey, isNotNull);
      expect(TourKeys.searchKey, isNotNull);
      expect(TourKeys.homeTabKey, isNotNull);
      expect(TourKeys.profileTabKey, isNotNull);
      expect(TourKeys.interestButtonKey, isNotNull);
    });

    test('resetAll regenerates brand new GlobalKey instances', () {
      final oldHome = TourKeys.homeTabKey;
      TourKeys.resetAll();
      final newHome = TourKeys.homeTabKey;

      expect(newHome, isNotNull);
      expect(identical(oldHome, newHome), isFalse);
    });
  });
}
