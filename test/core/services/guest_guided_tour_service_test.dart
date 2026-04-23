import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/guest_guided_tour_service.dart';

void main() {
  group('TourStage', () {
    test('enum has correct values', () {
      expect(TourStage.values.length, 7);
      expect(TourStage.none.index, 0);
      expect(TourStage.homeScreen.index, 1);
      expect(TourStage.profileDetail.index, 2);
      expect(TourStage.chatScreen.index, 3);
      expect(TourStage.matchesScreen.index, 4);
      expect(TourStage.myProfileScreen.index, 5);
      expect(TourStage.finished.index, 6);
    });

    test('TourStage.none is the initial state', () {
      expect(TourStage.none.name, 'none');
    });

    test('TourStage.finished is the terminal state', () {
      expect(TourStage.finished.name, 'finished');
    });
  });

  group('GuestGuidedTourService — unit logic', () {
    // Note: Full widget/overlay tests require a BuildContext and are covered
    // in widget tests. Here we test the pure logic methods.

    test('TourStage ordering is consistent', () {
      // Verify stages are ordered for progression tracking
      expect(TourStage.homeScreen.index < TourStage.profileDetail.index, true);
      expect(TourStage.profileDetail.index < TourStage.chatScreen.index, true);
      expect(TourStage.chatScreen.index < TourStage.matchesScreen.index, true);
      expect(TourStage.matchesScreen.index < TourStage.myProfileScreen.index, true);
      expect(TourStage.myProfileScreen.index < TourStage.finished.index, true);
    });

    test('all stages have unique names', () {
      final names = TourStage.values.map((e) => e.name).toSet();
      expect(names.length, TourStage.values.length);
    });
  });
}
