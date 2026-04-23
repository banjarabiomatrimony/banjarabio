import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart' as foundation;

/// Global utility to offload heavy computation.
class IsolateManager {
  static final IsolateManager instance = IsolateManager._();

  IsolateManager._();

  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _responsePort; // Keep reference to close it later

  // REGRESSION FIX 1: The Future Lock
  Future<void>? _initFuture;

  final Map<int, Completer<dynamic>> _activeRequests = {};
  int _idCounter = 0;
  bool _isInitialized = false;

  /// Initialize the persistent background isolate safely.
  Future<void> init() async {
    if (_isInitialized && _sendPort != null) return;

    // 1. Future Lock: Prevent double-spawning
    if (_initFuture != null) return _initFuture;

    _initFuture = _initializeIsolate();

    try {
      await _initFuture;
    } catch (e) {
      _initFuture = null;
      _disposeResources();
      rethrow;
    }
  }

  Future<void> _initializeIsolate() async {
    final initCompleter = Completer<void>();
    final receivePort = ReceivePort(); // Temporary port for handshake

    _isolate = await Isolate.spawn(
      _isolateEntry,
      receivePort.sendPort,
      debugName: 'GlobalBackgroundWorker',
    );

    // Handshake Part 1: Get Isolate's Port
    _sendPort = await receivePort.first as SendPort;

    // Handshake Part 2: Setup Long-Lived Response Port
    _responsePort = ReceivePort();
    _sendPort!.send(_responsePort!.sendPort);

    _responsePort!.listen(_handleResponse);

    _isInitialized = true;
    initCompleter.complete();
    receivePort.close(); // Close temp port
    foundation.debugPrint('Global Isolate Manager Initialized 🚀');
  }

  void _handleResponse(dynamic message) {
    if (message is _WorkerResponse) {
      final completer = _activeRequests.remove(message.id);
      if (completer != null) {
        if (message.success) {
          completer.complete(message.result);
        } else {
          completer.completeError(message.error ?? 'Unknown error');
        }
      }
    }
  }

  void dispose() {
    _disposeResources();
    _isInitialized = false;
    _initFuture = null;
  }

  void _disposeResources() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _sendPort = null;
    _responsePort?.close();
    _responsePort = null;
    _activeRequests.forEach((_, completer) {
      completer.completeError('Isolate terminated');
    });
    _activeRequests.clear();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  Future<dynamic> jsonDecode(String source) async {
    if (!_isInitialized) await init();

    final id = _idCounter++;
    final completer = Completer<dynamic>();
    _activeRequests[id] = completer;

    _sendPort!.send(
      _WorkerRequest(id: id, type: _RequestType.jsonDecode, data: source),
    );

    // Add timeout to prevent completer leak if isolate crashes
    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _activeRequests.remove(id);
        throw TimeoutException('Isolate operation timed out');
      },
    );
  }

  /// ⚠️ IMPORTANT: [fromJson] MUST be a static or top-level function.
  /// Passing a closure (e.g., `(x) => User.fromJson(x)`) will CRASH the app.
  Future<List<T>> mapListInstance<T>(
    List<dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    // Optimization: Small lists are typically faster on main thread,
    // but we use 10 as threshold to keep main thread free for UI events
    // during critical batch loading.
    if (data.length < 10) {
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }

    if (!_isInitialized) await init();

    final id = _idCounter++;
    final completer = Completer<dynamic>();
    _activeRequests[id] = completer;

    _sendPort!.send(
      _WorkerRequest(
        id: id,
        type: _RequestType.mapList,
        // We pass the function reference directly.
        // Dart allows sending static functions.
        data: _MapListData(data, fromJson),
      ),
    );

    // Add timeout to prevent completer leak if isolate crashes
    final result = await completer.future.timeout(
      const Duration(seconds: 60), // Longer timeout for list processing
      onTimeout: () {
        _activeRequests.remove(id);
        throw TimeoutException('Isolate operation timed out');
      },
    );
    // Cast strictly to ensure type safety
    return (result as List).cast<T>();
  }

  // ---------------------------------------------------------------------------
  // Static Compatibility Layer (Backward Compatible)
  // ---------------------------------------------------------------------------

  /// Static helper that redirects to the persistent instance.
  /// Used by existing repositories.
  static Future<List<T>> mapList<T>(
    List<dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    // Use the persistent worker
    return instance.mapListInstance(data, fromJson);
  }

  /// Static helper for general computation (falls back to spawning a new isolate).
  /// Use this for heavy tasks that are NOT [mapList] or [jsonDecode].
  static Future<R> compute<Q, R>(
    foundation.ComputeCallback<Q, R> callback,
    Q message, {
    String? debugLabel,
  }) {
    return foundation.compute(callback, message, debugLabel: debugLabel);
  }
}

// -----------------------------------------------------------------------------
// Isolate Logic
// -----------------------------------------------------------------------------

enum _RequestType { jsonDecode, mapList }

class _WorkerRequest {
  final int id;
  final _RequestType type;
  final dynamic data;
  _WorkerRequest({required this.id, required this.type, required this.data});
}

class _WorkerResponse {
  final int id;
  final bool success;
  final dynamic result;
  final String? error;
  _WorkerResponse({
    required this.id,
    required this.success,
    this.result,
    this.error,
  });
}

class _MapListData {
  final List<dynamic> data;
  final Function fromJson; // Keep as generic Function for transport
  _MapListData(this.data, this.fromJson);
}

void _isolateEntry(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  SendPort? responsePort;

  receivePort.listen((message) {
    if (message is SendPort) {
      responsePort = message;
      return;
    }

    if (message is _WorkerRequest && responsePort != null) {
      try {
        dynamic result;
        switch (message.type) {
          case _RequestType.jsonDecode:
            // JSON parsing is expensive, perfect for isolate
            result = json.decode(message.data as String);
            break;

          case _RequestType.mapList:
            final params = message.data as _MapListData;
            // The mapping logic
            // We cast the dynamic list item to Map<String, dynamic>
            // before passing to the static function
            result = params.data
                .map((item) => params.fromJson(item as Map<String, dynamic>))
                .toList();
            break;
        }

        responsePort!.send(
          _WorkerResponse(id: message.id, success: true, result: result),
        );
      } catch (e) {
        responsePort!.send(
          _WorkerResponse(id: message.id, success: false, error: e.toString()),
        );
      }
    }
  });
}
