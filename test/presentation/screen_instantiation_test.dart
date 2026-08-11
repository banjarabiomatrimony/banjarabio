import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:banjarabio/core/supabase_client.dart';
import 'package:banjarabio/core/services/local_cache_service.dart';

import 'package:banjarabio/presentation/onboarding_screen/onboarding_screen.dart';
import 'package:banjarabio/presentation/authentication_screen/authentication_screen.dart';
import 'package:banjarabio/presentation/chat/conversation_list_screen.dart';
import 'package:banjarabio/presentation/my_profile_screen/my_profile_screen.dart';
import 'package:banjarabio/presentation/trust_score_screen/trust_score_screen.dart';
import 'package:banjarabio/presentation/analytics/who_viewed_me_screen.dart';
import 'package:banjarabio/presentation/subscription_screen/subscription_screen.dart';
import 'package:banjarabio/presentation/home_screen/location_selection_screen.dart';
import 'package:banjarabio/presentation/biodata_creation_screen/biodata_creation_screen.dart';
import 'package:banjarabio/presentation/biodata_editor_screen/biodata_editor_screen.dart';
import 'package:banjarabio/presentation/admin_screen/admin_dashboard_screen.dart';
import 'package:banjarabio/presentation/profile_detail_screen/profile_detail_screen.dart';
import 'package:banjarabio/presentation/saved_profiles_screen/saved_profiles_screen.dart';
import 'package:banjarabio/presentation/shared_profiles_screen/shared_profiles_screen.dart';
import 'package:banjarabio/presentation/home_screen/home_screen.dart';
import 'package:banjarabio/presentation/filter_screen/filter_screen.dart';
import 'package:banjarabio/presentation/user_type_selection_screen/user_type_selection_screen.dart';

class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}
class MockBox extends Mock implements Box<dynamic> {}

void main() {
  setUp(() {
    final mockAuth = MockGoTrueClient();
    final mockUser = MockUser();
    final mockBox = MockBox();
    AppSupabaseClient.testAuth = mockAuth;
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user');
    when(() => mockUser.email).thenReturn('test@test.com');
    LocalCacheService().testBoxOpener = (name) => mockBox;
    when(() => mockBox.get(any())).thenReturn(null);
    when(() => mockBox.get(any(), defaultValue: any(named: 'defaultValue'))).thenReturn(null);
    when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});
  });

  group('Screen Instantiation Tests', () {
    test('OnboardingScreen can be constructed', () {
      const screen = OnboardingScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('AuthenticationScreen can be constructed', () {
      const screen = AuthenticationScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('ConversationListScreen can be constructed', () {
      const screen = ConversationListScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('MyProfileScreen can be constructed', () {
      const screen = MyProfileScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('TrustScoreScreen can be constructed', () {
      const screen = TrustScoreScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('WhoViewedMeScreen can be constructed', () {
      const screen = WhoViewedMeScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('SubscriptionScreen can be constructed', () {
      const screen = SubscriptionScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('LocationSelectionScreen can be constructed', () {
      const screen = LocationSelectionScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('BiodataCreationScreen can be constructed', () {
      const screen = BiodataCreationScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('BiodataEditorScreen can be constructed', () {
      const screen = BiodataEditorScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('AdminDashboardScreen can be constructed', () {
      const screen = AdminDashboardScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('ProfileDetailScreen can be constructed', () {
      const screen = ProfileDetailScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('SavedProfilesScreen can be constructed', () {
      const screen = SavedProfilesScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('SharedProfilesScreen can be constructed', () {
      const screen = SharedProfilesScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('HomeScreen can be constructed', () {
      const screen = HomeScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('FilterScreen can be constructed', () {
      const screen = FilterScreen();
      expect(screen, isA<StatefulWidget>());
    });

    test('UserTypeSelectionScreen can be constructed', () {
      const screen = UserTypeSelectionScreen();
      expect(screen, isA<StatefulWidget>());
    });
  });
}
