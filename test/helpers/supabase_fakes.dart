import 'dart:io';
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, FakeSupabaseQueryBuilder> _queries;
  final FakeGoTrueClient _auth = FakeGoTrueClient();
  final FakeSupabaseStorageClient _storage = FakeSupabaseStorageClient();
  final Map<String, FakeRealtimeChannel> _channels = {};
  
  FakeSupabaseClient({Map<String, FakeSupabaseQueryBuilder>? queries})
      : _queries = queries ?? {};

  Map<String, FakeSupabaseQueryBuilder> get queries => _queries;

  String? rpcFunction;

  Map<String, dynamic>? rpcParams;
  dynamic rpcResponse = [];
  Object? rpcError;

  /// 🧪 Action-specific responses (Mapping 'action' payload to response)
  final Map<String, dynamic> rpcResponses = {};



  @override
  GoTrueClient get auth => _auth;

  @override
  SupabaseStorageClient get storage => _storage;

  @override
  SupabaseQueryBuilder from(String table) {
    return _queries.putIfAbsent(table, () => FakeSupabaseQueryBuilder());
  }

  @override
  PostgrestFilterBuilder<T> rpc<T>(String fn, {Map<String, dynamic>? params, Object? get}) {
    rpcFunction = fn;
    rpcParams = params;
    if (rpcError != null) throw rpcError!;

    final action = params?['action'] as String?;
    debugPrint('🧪 FakeSupabaseClient.rpc: fn=$fn, action=$action');
    if (action != null && rpcResponses.containsKey(action)) {
      final res = rpcResponses[action];
      debugPrint('🧪 FakeSupabaseClient.rpc: Matched action=$action, returning type=${res.runtimeType}');
      return FakePostgrestFilterBuilder<T>(res as T);
    }
    if (rpcResponses.containsKey(fn)) {
      final res = rpcResponses[fn];
      return FakePostgrestFilterBuilder<T>(res as T);
    }
    if (fn == 'fn_check_phone_available') {
      return FakePostgrestFilterBuilder<T>(true as T);
    }

    return FakePostgrestFilterBuilder<T>(rpcResponse as T);
  }

  /// Backward compatibility for tests using the old fake style
  set mockUser(User? user) {
    (auth as dynamic).mockUser = user;
  }

  /// Backward compatibility for tests using the old fake style
  set functionResponse(Map<String, dynamic> response) {
    (functions as dynamic).functionResponse = response;
  }
  set functionError(Exception error) {
    (functions as dynamic).functionError = error;
  }
  
  // Dummy functions client to satisfy some potential accesses
  late final FunctionsClient _functions = FakeFunctionsClient();
  @override
  FunctionsClient get functions => _functions;

  /// Backward compatibility for setTableData
  void setTableData(String table, List<Map<String, dynamic>> data) {
    (from(table) as dynamic).builder.responseData = data;
  }

  @override
  RealtimeChannel channel(String name, {RealtimeChannelConfig opts = const RealtimeChannelConfig()}) {
    return _channels.putIfAbsent(name, () => FakeRealtimeChannel(name));
  }

  /// Backward compatibility for tests using the old fake style
  RealtimeChannel getChannel(String name) => channel(name);

  @override
  Future<List<String>> removeAllChannels() async {
    final names = _channels.keys.toList();
    _channels.clear();
    return names;
  }
}

class FakeFunctionsClient extends Fake implements FunctionsClient {
  Map<String, dynamic>? functionResponse;
  Exception? functionError;

  @override
  Future<FunctionResponse> invoke(String functionName, {Object? body, Iterable<MultipartFile>? files, Map<String, String>? headers, HttpMethod method = HttpMethod.post, Map<String, dynamic>? queryParameters, String? region}) async {
    if (functionError != null) throw functionError!;
    return FunctionResponse(data: functionResponse ?? <String, dynamic>{}, status: 200);
  }
}

class FakeGoTrueClient extends Fake implements GoTrueClient {
  User? mockUser;
  Session? mockSession;
  AuthException? error;

  /// Stream controller for auth state changes — allows tests to simulate
  /// signedIn, signedOut, tokenRefreshed events.
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get onAuthStateChange => _authStateController.stream;

  /// Emit a fake auth state event (for widget tests).
  void emitAuthState(AuthChangeEvent event) {
    _authStateController.add(AuthState(event, mockSession));
  }

  @override
  User? get currentUser => mockUser;

  @override
  Session? get currentSession => mockSession;

  @override
  Future<AuthResponse> signInWithIdToken({
    required OAuthProvider provider,
    required String idToken,
    String? accessToken,
    String? nonce,
    String? captchaToken,
  }) async {
    if (error != null) throw error!;
    return AuthResponse(session: mockSession, user: mockUser);
  }

  Future<bool> signInWithOAuth(
    OAuthProvider provider, {
    String? redirectTo,
    String? scopes,
    Map<String, String>? queryParams,
    LaunchMode authScreenLaunchMode = LaunchMode.platformDefault,
  }) async {
    if (error != null) throw error!;
    return true;
  }

  @override
  Future<AuthResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
    String? captchaToken,
  }) async {
    if (error != null) throw error!;
    return AuthResponse(session: mockSession, user: mockUser);
  }

  @override
  Future<AuthResponse> signUp({
    String? email,
    String? phone,
    required String password,
    String? emailRedirectTo,
    Map<String, dynamic>? data,
    String? captchaToken,
    dynamic channel,
  }) async {
    if (error != null) throw error!;
    return AuthResponse(session: mockSession, user: mockUser);
  }

  @override
  Future<void> signOut({SignOutScope scope = SignOutScope.local}) async {
    if (error != null) throw error!;
  }

  @override
  Future<void> signInWithOtp({
    String? email,
    String? phone,
    String? emailRedirectTo,
    Map<String, dynamic>? data,
    String? captchaToken,
    bool? shouldCreateUser,
    OtpChannel channel = OtpChannel.sms,
  }) async {
    if (error != null) throw error!;
  }

  @override
  Future<AuthResponse> verifyOTP({
    String? email,
    String? phone,
    String? token,
    String? tokenHash,
    required OtpType type,
    String? redirectTo,
    String? captchaToken,
  }) async {
    if (error != null) throw error!;
    return AuthResponse(session: mockSession, user: mockUser);
  }

  @override
  Future<AuthResponse> refreshSession([String? refreshToken]) async {
    if (error != null) throw error!;
    return AuthResponse(session: mockSession, user: mockUser);
  }
}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final FakePostgrestFilterBuilder<List<Map<String, dynamic>>> builder = 
      FakePostgrestFilterBuilder<List<Map<String, dynamic>>>([]);
  final FakeCountBuilder countBuilder = FakeCountBuilder();

  @override
  FakePostgrestFilterBuilder<List<Map<String, dynamic>>> select([String columns = '*']) => builder;

  @override
  PostgrestFilterBuilder<int> count([CountOption count = CountOption.exact]) {
    return FakePostgrestFilterBuilder<int>(countBuilder.count);
  }

  FakePostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, Object value) {
    debugPrint('FakeSupabaseQueryBuilder.eq: column=$column, value=$value');
    builder.eq(column, value);
    return builder;
  }

  @override
  FakeSupabaseStreamFilterBuilder stream({required List<String> primaryKey}) => 
      FakeSupabaseStreamFilterBuilder(builder);

  @override
  FakePostgrestFilterBuilder<List<Map<String, dynamic>>> insert(Object values, {bool defaultToNull = true}) {
    return builder;
  }

  @override
  FakePostgrestFilterBuilder<List<Map<String, dynamic>>> update(Map values) {
    if (builder.responseData is List) {
      final list = (builder.responseData as List).map((e) {
        if (e is Map) {
          final updatedMap = Map<String, dynamic>.from(e);
          values.forEach((k, v) => updatedMap[k.toString()] = v);
          return updatedMap;
        }
        return e;
      }).toList();
      builder.responseData = list;
    } else if (builder.responseData is Map) {
      final updatedMap = Map<String, dynamic>.from(builder.responseData as Map);
      values.forEach((k, v) => updatedMap[k.toString()] = v);
      builder.responseData = updatedMap;
    }
    return builder;
  }

  @override
  FakePostgrestFilterBuilder<List<Map<String, dynamic>>> upsert(Object values, {Object? onConflict, bool ignoreDuplicates = false, bool defaultToNull = true}) {
    return builder;
  }

  @override
  FakePostgrestFilterBuilder<List<Map<String, dynamic>>> delete() {
    return builder;
  }


}

class FakePostgrestState {
  dynamic responseData;
  Object? error;
}

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T>, PostgrestTransformBuilder<T> {
  final FakePostgrestState _state;
  final T Function(dynamic data)? _transform;

  FakePostgrestFilterBuilder(dynamic initialData, [FakePostgrestState? state, this._transform])
      : _state = state ?? FakePostgrestState() {
    _state.responseData = initialData;
  }

  dynamic get responseData => _state.responseData;
  set responseData(dynamic value) => _state.responseData = value;

  Object? get error => _state.error;
  set error(Object? value) => _state.error = value;

  Future<T> _asFuture() {
    final err = _state.error;
    if (err != null) {
      if (err is Function) {
        final resolvedErr = err();
        if (resolvedErr != null) return Future.error(resolvedErr);
      } else {
        return Future.error(err);
      }
    }

    final data = _state.responseData;
    dynamic resolvedData = (data is Function) ? data() : data;
    debugPrint('🧪 FakePostgrestFilterBuilder._asFuture: T=$T, resolvedData type=${resolvedData.runtimeType}');

    if (_transform != null) {
      return Future.value(_transform(resolvedData));
    }
    
    // Safety check for Map/List casting
    if (resolvedData is Map && T == Map<String, dynamic>) {
      resolvedData = Map<String, dynamic>.from(resolvedData);
    } else if (resolvedData is List && T == List<Map<String, dynamic>>) {
      resolvedData = resolvedData.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    
    return Future.value(resolvedData as T);
  }

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) {
    var data = _state.responseData;
    if (data is Function) data = data();
    
    if (data is List) {
      _state.responseData = data.where((item) {
        if (item is Map) {
          return item[column] == value;
        }
        return false;
      }).toList();
    }
    return this;
  }

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> select([String columns = '*']) {
     return this as dynamic;
  }

  @override
  PostgrestFilterBuilder<T> order(String column, {bool ascending = false, bool nullsFirst = false, String? referencedTable}) => this;

  Stream<T> asyncMap<E>(FutureOr<E> Function(T event) convert) {
    return Stream.fromFuture(_asFuture()).asyncMap((data) => convert(data) as FutureOr<T>);
  }

  Stream<T> handleError(Function onError, {bool Function(dynamic error)? test}) {
    return Stream.fromFuture(_asFuture()).handleError(onError, test: test);
  }

  @override
  PostgrestFilterBuilder<T> neq(String column, Object value) => this;
  @override
  PostgrestFilterBuilder<T> gt(String column, Object value) => this;
  @override
  PostgrestFilterBuilder<T> gte(String column, Object value) {
    if (_state.responseData is List) {
      final list = _state.responseData as List;
      _state.responseData = list.where((item) {
        if (item is Map && item.containsKey(column)) {
          final val = item[column];
          if (val is Comparable && value is Comparable) {
            return val.compareTo(value) >= 0;
          }
        }
        return false;
      }).toList();
    }
    return this;
  }

  @override
  PostgrestFilterBuilder<T> lt(String column, Object value) => this;
  @override
  PostgrestFilterBuilder<T> lte(String column, Object value) => this;
  @override
  PostgrestFilterBuilder<T> like(String column, String pattern) => this;
  @override
  PostgrestFilterBuilder<T> ilike(String column, String pattern) => this;
  @override
  PostgrestFilterBuilder<T> or(String filters, {String? referencedTable}) => this;
  @override
  PostgrestFilterBuilder<T> filter(String column, String operator, Object? value) => this;
  @override
  PostgrestFilterBuilder<T> inFilter(String column, List<dynamic> values) {
    if (_state.responseData is List) {
      final list = _state.responseData as List;
      _state.responseData = list.where((item) {
        if (item is Map) {
          return values.contains(item[column]);
        }
        return false;
      }).toList();
    }
    return this;
  }

  @override
  PostgrestFilterBuilder<T> limit(int count, {String? referencedTable}) => this;

  @override
  PostgrestTransformBuilder<String> csv() =>
      FakePostgrestFilterBuilder<String>(_state.responseData.toString(), _state, (data) => data.toString());

  @override
  ResponsePostgrestBuilder<PostgrestResponse<T>, T, T> count([CountOption option = CountOption.exact]) {
    final data = responseData;
    int countVal = 0;
    if (data is List) {
      countVal = data.length;
    } else if (data is int) {
      countVal = data;
    }
    return FakeResponsePostgrestBuilder<T>(data as T, countVal);
  }

  @override
  PostgrestFilterBuilder<Map<String, dynamic>> single() {
    return FakePostgrestFilterBuilder<Map<String, dynamic>>(_state.responseData, _state, (data) {
      final item = (data is List && data.isNotEmpty) ? data.first : data;
      if (item is Map) return Map<String, dynamic>.from(item);
      return <String, dynamic>{};
    });
  }

  @override
  PostgrestFilterBuilder<Map<String, dynamic>?> maybeSingle() {
    return FakePostgrestFilterBuilder<Map<String, dynamic>?>(_state.responseData, _state, (data) {
      final item = (data is List) ? (data.isNotEmpty ? data.first : null) : data;
      if (item is Map) return Map<String, dynamic>.from(item);
      return null;
    });
  }

  @override
  Future<U> then<U>(FutureOr<U> Function(T value) onValue, {Function? onError}) =>
      _asFuture().then(onValue, onError: onError);

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      _asFuture().catchError(onError, test: test);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _asFuture().whenComplete(action);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      _asFuture().timeout(timeLimit, onTimeout: onTimeout);
}

class FakeResponsePostgrestBuilder<T> extends Fake implements ResponsePostgrestBuilder<PostgrestResponse<T>, T, T> {
  final T _data;
  final int _count;
  FakeResponsePostgrestBuilder(this._data, this._count);

  @override
  Future<U> then<U>(FutureOr<U> Function(PostgrestResponse<T> value) onValue, {Function? onError}) {
    final response = PostgrestResponse<T>(data: _data, count: _count);
    return Future.value(response).then((v) => onValue(v), onError: onError);
  }
}

class FakeCountBuilder extends Fake {
  int _count = 0;
  void setData(int count) => _count = count;
  int get count => _count;
}

class FakeUser extends Fake implements User {
  @override
  final String id;
  FakeUser({required this.id});
  @override
  String? get email => 'test@example.com';
  @override
  String? get phone => '1234567890';
}

class FakeSharedPreferences extends Fake implements SharedPreferences {
  final Map<String, dynamic> _values;
  FakeSharedPreferences([Map<String, dynamic>? values]) : _values = Map.from(values ?? {});

  @override
  String? getString(String key) => _values[key] as String?;
  @override
  bool? getBool(String key) => _values[key] as bool?;
  @override
  int? getInt(String key) => _values[key] as int?;
  @override
  double? getDouble(String key) => _values[key] as double?;
  @override
  List<String>? getStringList(String key) => _values[key] as List<String>?;
  @override
  Future<bool> setString(String key, String value) async { _values[key] = value; return true; }
  @override
  Future<bool> setBool(String key, bool value) async { _values[key] = value; return true; }
  @override
  Future<bool> setInt(String key, int value) async { _values[key] = value; return true; }
  @override
  Future<bool> remove(String key) async { _values.remove(key); return true; }
  @override
  bool containsKey(String key) => _values.containsKey(key);
}
class FakeRealtimeChannel extends Fake implements RealtimeChannel {
  final String name;
  void Function(PostgresChangePayload payload)? _callback;

  FakeRealtimeChannel(this.name);

  @override
  RealtimeChannel onPostgresChanges({
    required PostgresChangeEvent event,
    String? schema,
    String? table,
    PostgresChangeFilter? filter,
    required void Function(PostgresChangePayload payload) callback,
  }) {
    _callback = callback;
    return this;
  }

  @override
  RealtimeChannel subscribe([void Function(RealtimeSubscribeStatus status, Object? error)? callback, Duration? timeout]) {
    if (callback != null) callback(RealtimeSubscribeStatus.subscribed, null);
    return this;
  }

  void simulatePostgresChange(PostgresChangePayload payload) {
    if (_callback != null) _callback!(payload);
  }

  @override
  Future<String> unsubscribe([Duration? timeout]) async => 'ok';
}

class FakeSupabaseStreamFilterBuilder extends Fake implements SupabaseStreamFilterBuilder {
  final FakePostgrestFilterBuilder<List<Map<String, dynamic>>> _builder;

  FakeSupabaseStreamFilterBuilder(this._builder);

  @override
  SupabaseStreamFilterBuilder eq(String column, Object value) => this;

  @override
  SupabaseStreamFilterBuilder order(String column, {bool ascending = false}) => this;

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(List<Map<String, dynamic>> event) convert) {
    return Stream.fromFuture((_builder as dynamic)._asFuture() as Future<List<Map<String, dynamic>>>).asyncMap(convert);
  }

  @override
  Stream<List<Map<String, dynamic>>> handleError(Function onError, {bool Function(dynamic error)? test}) {
    return _builder.handleError(onError, test: test);
  }
  
  @override
  StreamSubscription<List<Map<String, dynamic>>> listen(void Function(List<Map<String, dynamic>> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream.fromFuture((_builder as dynamic)._asFuture() as Future<List<Map<String, dynamic>>>).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class FakeSupabaseStorageClient extends Fake implements SupabaseStorageClient {
  final Map<String, FakeStorageFileApi> _buckets = {};

  @override
  StorageFileApi from(String id) {
    return _buckets.putIfAbsent(id, () => FakeStorageFileApi(id));
  }
}



class FakeStorageFileApi extends Fake implements StorageFileApi {
  final String id;
  final Set<String> uploadedPaths = {};
  Object? error;
  FakeStorageFileApi(this.id);


  @override
  Future<List<FileObject>> remove(List<String> paths) async {
    uploadedPaths.removeAll(paths);
    return <FileObject>[];
  }

  @override
  Future<String> upload(String path, File file, {FileOptions? fileOptions, int? retryAttempts, StorageRetryController? retryController}) async {
    uploadedPaths.add(path);
    return path;
  }

  @override
  Future<String> uploadBinary(String path, Uint8List data, {FileOptions? fileOptions, int? retryAttempts, StorageRetryController? retryController}) async {
    uploadedPaths.add(path);
    return path;
  }
  
  @override
  String getPublicUrl(String path, {TransformOptions? transform}) {
    return 'https://fake.supabase.co/storage/v1/object/public/$id/$path';
  }

  @override
  Future<String> createSignedUrl(String path, int expiresIn, {TransformOptions? transform}) async {
    if (error != null) throw error!;
    return 'https://fake.supabase.co/storage/v1/object/sign/$id/$path?token=fake';
  }
}
