import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:banjarabio/core/services/analytics_service.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  late AnalyticsService analyticsService;
  late MockFirebaseAnalytics mockAnalytics;

  setUp(() {
    analyticsService = AnalyticsService();
    mockAnalytics = MockFirebaseAnalytics();
    
    // Inject mock
    analyticsService.testAnalytics = mockAnalytics;
    
    // Register fallbacks
    registerFallbackValue(<String, Object?>{});
  });

  group('AnalyticsService Events', () {
    test('logs screen view', () async {
      when(() => mockAnalytics.logScreenView(screenName: any(named: 'screenName')))
          .thenAnswer((_) async {});
          
      await analyticsService.instanceLogScreenView('TestScreen');
      
      verify(() => mockAnalytics.logScreenView(screenName: 'TestScreen')).called(1);
    });

    test('logs event with parameters', () async {
      when(() => mockAnalytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      )).thenAnswer((_) async {});
      
      await analyticsService.instanceLogEvent('test_event', parameters: {'key': 'value'});
      
      verify(() => mockAnalytics.logEvent(
        name: 'test_event',
        parameters: {'key': 'value'},
      )).called(1);
    });

    test('logs search event', () async {
      when(() => mockAnalytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      )).thenAnswer((_) async {});
      
      await analyticsService.instanceLogSearch('search_query');
      
      verify(() => mockAnalytics.logEvent(
        name: 'search',
        parameters: {'search_term': 'search_query'},
      )).called(1);
    });

    test('logs conversion event', () async {
      when(() => mockAnalytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      )).thenAnswer((_) async {});
      
      await analyticsService.instanceLogConversion('premium_purchase', value: 99.9);
      
      verify(() => mockAnalytics.logEvent(
        name: 'conversion',
        parameters: {
          'type': 'premium_purchase',
          'value': 99.9,
        },
      )).called(1);
    });
  });

  group('User Identification', () {
    test('sets user id', () async {
      when(() => mockAnalytics.setUserId(id: any(named: 'id')))
          .thenAnswer((_) async {});
          
      await analyticsService.instanceSetUserId('user_123');
      
      verify(() => mockAnalytics.setUserId(id: 'user_123')).called(1);
    });

    test('sets user properties', () async {
      when(() => mockAnalytics.setUserProperty(
        name: any(named: 'name'),
        value: any(named: 'value'),
      )).thenAnswer((_) async {});
      
      await analyticsService.instanceSetUserProperties({'tier': 'gold'});
      
      verify(() => mockAnalytics.setUserProperty(name: 'tier', value: 'gold')).called(1);
    });
  });
}
