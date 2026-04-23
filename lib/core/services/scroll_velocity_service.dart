import 'package:flutter/material.dart';

class ScrollVelocityService extends ChangeNotifier {
  static final ScrollVelocityService instance = ScrollVelocityService._();
  ScrollVelocityService._();

  double _velocity = 0;
  bool _isHyperScrolling = false;
  double _lastOffset = 0;
  DateTime _lastTime = DateTime.now();

  /// Threshold in logical pixels per second where we trigger "Ghosting"
  static const double hyperScrollThreshold = 3500;

  double get velocity => _velocity;
  bool get isHyperScrolling => _isHyperScrolling;

  void updateVelocity(double pixels) {
    final now = DateTime.now();
    final dt = now.difference(_lastTime).inMicroseconds / 1000000.0;
    if (dt == 0) {
      _lastOffset = pixels; // Still update offset to prevent giant jumps
      return;
    }
    
    final instantVelocity = (pixels - _lastOffset) / dt;
    _lastOffset = pixels;
    _lastTime = now;

    final absVelocity = instantVelocity.abs();
    
    // Smooth out velocity with a simple low-pass filter (EMA)
    _velocity = (_velocity * 0.7) + (absVelocity * 0.3);
    
    final newIsHyper = _velocity > hyperScrollThreshold;
    
    if (newIsHyper != _isHyperScrolling) {
      _isHyperScrolling = newIsHyper;
      notifyListeners();
    }
  }

  /// Helper to attach a ScrollController to this service
  void attach(ScrollController controller) {
    _lastOffset = controller.hasClients ? controller.offset : 0;
    _lastTime = DateTime.now();
    
    controller.addListener(() {
      if (controller.hasClients) {
        updateVelocity(controller.offset);
      }
    });
  }
}
