import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/presentation/staff_screen/staff_dashboard_screen.dart';
import 'package:banjarabio/core/repositories/staff_repository.dart';
import '../../helpers/widget_test_helpers.dart';
import '../../helpers/supabase_fakes.dart';

void main() {
  group('StaffDashboardScreen Widget Tests', () {
    late FakeSupabaseClient fakeClient;

    setUp(() {
      setupWidgetTestMocks();
      fakeClient = StaffRepository().testClient as FakeSupabaseClient;
    });

    tearDown(() {
      tearDownWidgetTestMocks();
      StaffRepository().testClient = null;
    });

    testWidgets('renders dashboard with summary cards and lead list', (WidgetTester tester) async {
      setTestScreenSize(tester);
      
      // Setup action-specific responses
      fakeClient.rpcResponses['get_my_leads'] = [
        {
          'id': 'lead-1',
          'user_id': 'uuid-1',
          'full_name': 'Rahul',
          'surname': 'Rathod',
          'gender': 'Male',
          'age': 25,
          'profile_completion': 45,
          'call_status': 'not_called',
          'height': "5'8\"", 'education': 'BE', 'profession': 'Engineer',
        }
      ];
      fakeClient.rpcResponses['get_my_summary'] = {
        'total_assigned': 10,
        'not_called': 5,
        'follow_up': 2,
        'converted': 3,
        'calls_today': 1
      };
      
      await tester.pumpWidget(createTestableWidget(const StaffDashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Rahul'), findsOneWidget);
      expect(find.text('Workspace'), findsOneWidget);
    });

    testWidgets('search filters leads by name or displayId', (WidgetTester tester) async {
      setTestScreenSize(tester);
      
      // Set leads list
      fakeClient.rpcResponses['get_my_leads'] = [
        {
          'id': 'lead-1',
          'user_id': 'uuid-1',
          'full_name': 'Rahul',
          'surname': 'Rathod',
          'gender': 'Male',
          'age': 25,
          'profile_completion': 45,
          'call_status': 'not_called',
          'height': "5'8\"", 'education': 'BE', 'profession': 'Engineer',
        }
      ];
      fakeClient.rpcResponses['get_my_summary'] = {
        'total_assigned': 1,
        'not_called': 1,
        'follow_up': 0,
        'converted': 0,
        'calls_today': 0
      };

      await tester.pumpWidget(createTestableWidget(const StaffDashboardScreen()));
      await tester.pumpAndSettle();

      // Find search field
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Rahul');
      await tester.pumpAndSettle();

      // Verify list is filtered
      // Using textContaining('Rahul') matches both the LeadCard and the search TextField
      // So we target the ListView specifically
      expect(find.descendant(of: find.byType(ListView), matching: find.textContaining('Rahul')), findsOneWidget);

      await tester.enterText(searchField, 'NonExistent');
      await tester.pumpAndSettle();
      
      expect(find.descendant(of: find.byType(ListView), matching: find.textContaining('Rahul')), findsNothing);
    });

    testWidgets('displays gender-aware User ID (BBM-/BBF-)', (WidgetTester tester) async {
      setTestScreenSize(tester);
      
      fakeClient.rpcResponses['get_my_leads'] = [
        {
          'id': 'lead-1',
          'user_id': 'uuid-1',
          'full_name': 'Rahul',
          'surname': 'Rathod',
          'gender': 'Male',
          'age': 25,
          'profile_completion': 45,
          'height': "5'8\"", 'education': 'BE', 'profession': 'Engineer',
        }
      ];
      fakeClient.rpcResponses['get_my_summary'] = {
        'total_assigned': 1,
        'not_called': 1,
        'follow_up': 0,
        'converted': 0,
        'calls_today': 0
      };

      await tester.pumpWidget(createTestableWidget(const StaffDashboardScreen()));
      await tester.pumpAndSettle();

      // Display ID for user-1 (ID is uuid-1, but displayId uses the short integer ID or last 4 of uuid)
      // Actually, Display ID uses the ID property.
      // For 'lead-1', displayId should be 'BBM-lead-1'
      expect(find.textContaining('BBM-'), findsOneWidget);
    });
  });
}
