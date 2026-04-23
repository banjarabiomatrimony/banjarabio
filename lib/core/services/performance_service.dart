import 'package:flutter/material.dart';

/// Service to handle global performance and memory optimizations.
/// mimicking high-scale apps (Instagram/Facebook) by proactively
/// responding to OS-level memory pressure.
class PerformanceService with WidgetsBindingObserver {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    WidgetsBinding.instance.addObserver(this);
    
    // 🧬 PROACTIVE LIMITS: Constrain the image cache early.
    // 50 images / 20MB is plenty for a profile feed but small enough 
    // to prevent OOM on 2GB devices.
    PaintingBinding.instance.imageCache.maximumSize = 50;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 20 * 1024 * 1024; // 20MB
    
    _isInitialized = true;
    debugPrint('🚀 PerformanceService: Global Memory Observer & Caps Active');
  }

  @override
  void didHaveMemoryPressure() {
    // 🚨 ATOMIC CLEAR: The OS is about to kill the app due to RAM.
    // We proactively dump EVERYTHING that can be reloaded.
    debugPrint(
      '⚠️ CRITICAL: OS Memory Pressure Detected. Clearing all caches...',
    );

    // 1. Clear Image Cache (GPU Buffers)
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    // 2. Clear transient build buffers
    // We don't trigger a frame here as it might add CPU/RAM pressure
    // while the OS is already struggling.
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
  }

  @visibleForTesting
  void simulateMemoryPressure() {
    didHaveMemoryPressure();
  }
}
