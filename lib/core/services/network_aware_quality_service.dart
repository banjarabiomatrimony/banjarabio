import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum NetworkSpeed { slow, medium, fast }

/// [NetworkAwareQualityService]
/// 
/// Dynamically adjusts image quality and resolution based on real-time network conditions.
/// Essential for extreme scale (10M+ DAU) to ensure both high performance and visual fidelity.
class NetworkAwareQualityService {
  static final NetworkAwareQualityService _instance = NetworkAwareQualityService._();
  factory NetworkAwareQualityService() => _instance;
  NetworkAwareQualityService._() {
    _initialize();
  }

  final Connectivity _connectivity = Connectivity();
  NetworkSpeed _cachedSpeed = NetworkSpeed.fast;
  bool lowRamMode = false;
  
  NetworkSpeed get cachedSpeed => _cachedSpeed;

  void _initialize() {
    // Basic initialization if needed
    getSpeedProfile().then((speed) => _cachedSpeed = speed);
  }
  
  /// Get current network speed profile
  Future<NetworkSpeed> getSpeedProfile() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      
      // If any high-speed connection is available, return fast
      if (results.contains(ConnectivityResult.wifi) || 
          results.contains(ConnectivityResult.ethernet)) {
        return NetworkSpeed.fast;
      }
      
      if (results.contains(ConnectivityResult.mobile)) {
        // In a real pro-scale app, we could use native platform channels to check
        // if it's 5G, 4G, or 3G. For now, we assume mobile is 'medium'
        // and adjust based on further signals if needed.
        return NetworkSpeed.medium;
      }

      if (results.contains(ConnectivityResult.none)) {
        return NetworkSpeed.slow;
      }
      
      return NetworkSpeed.medium;
    } catch (e) {
      debugPrint('Network Detection Error: $e');
      return NetworkSpeed.medium;
    }
  }

  /// Returns adjusted quality parameters based on network speed.
  /// Used by CustomImageWidget for just-in-time optimization.
  Map<String, int> getOptimizationParams({bool isHighQuality = false, NetworkSpeed? forcedSpeed}) {
    var speed = forcedSpeed ?? _cachedSpeed; 
    
    // 🧬 EXTREME SCALE: If lowRamMode is active, force a downgrade
    if (lowRamMode) {
      if (speed == NetworkSpeed.fast) {
        speed = NetworkSpeed.medium;
      } else if (speed == NetworkSpeed.medium) {
        speed = NetworkSpeed.slow;
      }
    }

    switch (speed) {
      case NetworkSpeed.fast:
        return {
          'quality': isHighQuality ? 95 : 85,
          'targetWidth': isHighQuality ? 1200 : 1080,
        };
      case NetworkSpeed.medium:
        return {
          'quality': isHighQuality ? 85 : 75,
          'targetWidth': isHighQuality ? 1000 : 800,
        };
      case NetworkSpeed.slow:
        return {
          'quality': 60,
          'targetWidth': 600,
        };
    }
  }
}
