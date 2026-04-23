import 'package:flutter/foundation.dart';
import 'package:banjarabio/core/services/telemetry_service.dart';

/// [BackendResponse]
///
/// A generic wrapper class for handling all backend API responses in a standardized way.
///
/// This class enforces a strict contract:
/// - A response is either **Success** (with data) or **Failure** (with an error message).
/// - It prevents "null check" hell in your UI code by using functional patterns like `.fold()`.
/// - It automatically logs errors to your analytics service.
///
/// ### Usage Example:
/// ```dart
/// final result = await api.getData();
///
/// return result.fold(
///   onSuccess: (data) => Text(data.title),
///   onFailure: (error) => ErrorWidget(error),
/// );
/// ```
@immutable
class BackendResponse<T> {
  final T? _data;
  final String? _error;
  final bool isSuccess;

  /// Optional callback to retry the operation that produced this response.
  /// Useful for "Tap to Retry" buttons in UI.
  final Future<BackendResponse<T>> Function()? onRetry;

  const BackendResponse._({
    T? data,
    String? error,
    required this.isSuccess,
    this.onRetry,
  }) : _data = data,
       _error = error;

  // ---------------------------------------------------------------------------
  // 1. Factory Constructors
  // ---------------------------------------------------------------------------

  /// Creates a successful response containing [data].
  factory BackendResponse.success(T data) {
    return BackendResponse._(data: data, isSuccess: true);
  }

  /// Creates a failed response with an [errorMessage].
  ///
  /// Automatically logs the error to [TelemetryService] if [stackTrace] is provided.
  factory BackendResponse.failure(
    String errorMessage, {
    StackTrace? stackTrace,
    Future<BackendResponse<T>> Function()? onRetry,
  }) {
    // 🚀 Automatic Telemetry Logging
    // We log this immediately so we don't have to remember to log it in the UI layer.
    try {
      TelemetryService().logError(errorMessage, stackTrace: stackTrace);
    } catch (_) {
      // Prevent telemetry errors from crashing the app logic
      debugPrint('Warning: TelemetryService failed to log error.');
    }

    return BackendResponse._(
      error: errorMessage,
      isSuccess: false,
      onRetry: onRetry,
    );
  }

  /// Creates a loading/empty state (Optional, useful for initial states).
  factory BackendResponse.loading() {
    return const BackendResponse._(
      isSuccess: false,
    ); // Treated as non-success until data arrives
  }

  // ---------------------------------------------------------------------------
  // 2. Data Accessors
  // ---------------------------------------------------------------------------

  /// Returns data if success, otherwise throws exception.
  /// Use [fold] or checks to avoid exceptions.
  T get data {
    if (!isSuccess) {
      throw Exception(
        'Cannot access data in a failed BackendResponse: $_error',
      );
    }
    // Trust that if isSuccess is true, usage is correct for type T (even if nullable or void)
    return _data as T;
  }

  /// Returns error message if failure, otherwise null.
  String get errorMessage => _error ?? 'Unknown error occurred';

  // ---------------------------------------------------------------------------
  // 3. Functional Helpers (The "10/10" Features)
  // ---------------------------------------------------------------------------

  /// Transforms the response based on its state.
  ///
  /// This forces the developer to handle both Success and Failure cases,
  /// preventing unhandled UI errors.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String error) onFailure,
  }) {
    if (isSuccess) {
      // Cast _data to T, relying on generic correctness.
      // Note: We do NOT check for _data != null here to allow nullable T and void.
      return onSuccess(_data as T);
    } else {
      return onFailure(errorMessage);
    }
  }

  /// Transforms the data inside the response if it is successful.
  ///
  /// 🔧 **Fix Applied**: The `onRetry` logic is now safe. It wraps the original
  /// retry function and maps the result, preventing runtime type casting errors.
  BackendResponse<R> map<R>(R Function(T data) mapper) {
    if (isSuccess) {
      try {
        return BackendResponse.success(mapper(_data as T));
      } catch (e, s) {
        return BackendResponse.failure('Mapping Error: $e', stackTrace: s);
      }
    } else {
      // ⚠️ CRITICAL FIX: Properly wrap the retry function
      Future<BackendResponse<R>> Function()? newRetry;
      if (onRetry != null) {
        newRetry = () async {
          final result = await onRetry!();
          // Recursively map the result of the retry
          return result.map(mapper);
        };
      }

      return BackendResponse.failure(errorMessage, onRetry: newRetry);
    }
  }

  /// Attempts to retry the original operation.
  /// Returns [this] if no retry callback was provided.
  Future<BackendResponse<T>> retry() async {
    if (onRetry != null) {
      return await onRetry!();
    }
    return this;
  }

  // ---------------------------------------------------------------------------
  // 4. Supabase / RPC Integration
  // ---------------------------------------------------------------------------

  /// Parses a raw response from a Supabase RPC or Function.
  ///
  /// Handles:
  /// - Null responses
  /// - Standard Supabase Error Objects `{ "status": "error", "message": "..." }`
  /// - Generic Mapping via [mapper]
  static BackendResponse<T> fromRpc<T>(
    dynamic response, {
    T Function(dynamic json)? mapper,
    Future<BackendResponse<T>> Function()? onRetry,
  }) {
    try {
      // 1. Null Check
      if (response == null) {
        return BackendResponse.failure(
          'Server returned null response',
          onRetry: onRetry,
        );
      }

      // 2. Error Object Check (Standard convention for many RPCs)
      if (response is Map && response['status'] == 'error') {
        return BackendResponse.failure(
          response['message']?.toString() ?? 'Unknown server error',
          onRetry: onRetry,
        );
      }

      // 3. Mapping Logic
      // If a mapper is provided, use it to transform the raw dynamic data
      if (mapper != null) {
        return BackendResponse.success(mapper(response));
      }

      // 4. Direct Cast (If no mapper needed, e.g. T is String or int)
      return BackendResponse.success(response as T);
    } catch (e, stack) {
      return BackendResponse.failure(
        'Data Parsing Error: ${e.toString()}',
        onRetry: onRetry,
        stackTrace: stack,
      );
    }
  }
}
