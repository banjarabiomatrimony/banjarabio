// test/helpers/supabase_mocks.dart
// Shared mock classes for Supabase client and dependencies using mocktail.
//
// Usage:
//   import 'package:mocktail/mocktail.dart';
//   import '../helpers/supabase_mocks.dart';
//
//   final client = MockSupabaseClient();
//   final gotrue = MockGoTrueClient();
//   when(() => client.auth).thenReturn(gotrue);

import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Core Supabase Mocks ---
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder {}

class MockSupabaseStreamBuilder extends Mock
    implements SupabaseStreamBuilder {}

// Convenience for chaining .from().select().eq() etc.
// Since Supabase chaining is complex, we mock at the RPC level when possible.
