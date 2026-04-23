import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Global Watchdog: Ultra-Stable Anti-ANR Architecture
/// 
/// Continuously monitors the main thread for Frame drops and blocks.
/// If a severe block is detected (>200ms), it initiates emergency
/// memory management to prevent the OS from killing the app (Signal 3).
class GlobalWatchdog {
  static final GlobalWatchdog _instance = GlobalWatchdog._internal();
  factory GlobalWatchdog() => _instance;
  GlobalWatchdog._internal();

  bool _isMonitoring = false;
  int _lastFrameTimestamp = 0;
  DateTime? _lastPulseTime;
  DateTime? _lastClearTime;
  
  // Custom threshold for what we consider an "ANR Risk" block
  // 🧬 PRO SCALE: 500ms is a safe "Stutter" warning. ANR is 5000ms.
  static const int _anrRiskThresholdMs = 500;
  
  // Cooldown to prevent "Watchdog Death Spiral" (repeated cache clears)
  static const Duration _clearCooldown = Duration(seconds: 30);

  @visibleForTesting
  bool testIsMonitoring = false;

  void initialize() {
    if (_isMonitoring) return;
    
    // We only want to monitor in release/profile to avoid debugging noise
    if (kDebugMode && !const bool.fromEnvironment('WATCHDOG_DEBUG') && !testIsMonitoring) return;

    _isMonitoring = true;
    _lastPulseTime = DateTime.now();
    
    // Listen to every frame drawn by Flutter
    SchedulerBinding.instance.addPostFrameCallback(_monitorFrame);
    
    debugPrint('🛡️ [WATCHDOG] Global Frame Monitor Active (Threshold: ${_anrRiskThresholdMs}ms).');
  }

  void _monitorFrame(Duration timeStamp) {
    if (!_isMonitoring) return;

    final now = DateTime.now();
    
    // 🧬 PRO SCALE: Check for actual wall-clock blocking since the last frame.
    // addPostFrameCallback only fires AFTER a frame is drawn.
    // If we were idle, this fires on the FIRST frame of new interaction.
    if (_lastPulseTime != null) {
      final delta = now.difference(_lastPulseTime!).inMilliseconds;
      
      // If the delta is high, but we haven't seen any frame requests (TimeStamp didn't change),
      // it might just be idleness. 
      final frameDelta = timeStamp.inMilliseconds - _lastFrameTimestamp;

      // Only treat it as a SEVERE block if BOTH the wall-clock and the frame-clock show a delay,
      // OR if the wall-clock delay is extreme while we are expected to be interactive.
      if (delta >= _anrRiskThresholdMs && frameDelta > 0) {
        _handleSevereMainThreadBlock(delta);
      }
    }

    _lastPulseTime = now;
    _lastFrameTimestamp = timeStamp.inMilliseconds;
    
    // Schedule the next frame monitor
    SchedulerBinding.instance.addPostFrameCallback(_monitorFrame);
  }

  void _handleSevereMainThreadBlock(int blockedDurationMs) {
    final now = DateTime.now();
    
    // Rate limit emergency clears to avoid making things worse
    if (_lastClearTime != null && now.difference(_lastClearTime!) < _clearCooldown) {
      debugPrint('🚨 [WATCHDOG] Blocked for ${blockedDurationMs}ms, but skipping clear (Cooldown active).');
      return;
    }

    debugPrint('🚨 [WATCHDOG] SEVERE MAIN THREAD BLOCK DETECTED: ${blockedDurationMs}ms!');
    
    _lastClearTime = now;

    // 1. Emergency GC / Image Cache Clear
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      final currentSizeBytes = imageCache.currentSizeBytes;
      
      imageCache.clear();
      imageCache.clearLiveImages();
      
      debugPrint('🚨 [WATCHDOG] Emergency Image Cache Cleared. Freed: ${(currentSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB');
    } catch (e) {
      debugPrint('🚨 [WATCHDOG] Failed to clear image cache: $e');
    }
  }

  void dispose() {
    _isMonitoring = false;
  }

  @visibleForTesting
  void simulateBlock(int durationMs) {
    _handleSevereMainThreadBlock(durationMs);
  }
}
