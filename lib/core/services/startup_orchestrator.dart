import 'dart:async';
import 'package:flutter/foundation.dart';

enum StartupPhase {
  preBoot,      // Initial bare-metal state
  booting,      // Loading core configs, DB connections
  critical,     // Secure storage, Authentication state
  interactive,  // First frame rendered, initial feed fetch
  background,   // Analytics, Notifications, Background syncs
  idle,         // Everything loaded, prefetching can begin
}

/// Startup Orchestrator: Anti-"Startup Surge" Architecture
/// 
/// Prevents all services from hydrating simultaneously when the app starts.
/// By staging initialization, we drastically reduce the chance of 
/// out-of-memory or watchdog timeout terminations (Signal 3).
class StartupOrchestrator {
  static final StartupOrchestrator _instance = StartupOrchestrator._internal();
  factory StartupOrchestrator() => _instance;
  StartupOrchestrator._internal();

  StartupPhase _currentPhase = StartupPhase.preBoot;
  StartupPhase get currentPhase => _currentPhase;

  // Listeners for specific phases
  final Map<StartupPhase, List<Future<void> Function()>> _tasks = {
    StartupPhase.booting: [],
    StartupPhase.critical: [],
    StartupPhase.interactive: [],
    StartupPhase.background: [],
    StartupPhase.idle: [],
  };

  // 🚨 SIGNAL 3 FIX: Track executed task names to prevent duplicate execution
  final Set<String> _executedTasks = {};

  /// Register a task to be executed during a specific phase.
  /// If the phase has already passed, the task executes immediately.
  /// Named tasks are deduplicated - a task with the same name will not run twice.
  void registerTask(StartupPhase phase, Future<void> Function() task, {String name = 'Unknown Task'}) {
    // Prevent duplicate execution of named tasks
    if (name != 'Unknown Task' && _executedTasks.contains(name)) {
      debugPrint('🚀 [ORCHESTRATOR] Skipping duplicate task: $name');
      return;
    }
    
    if (_currentPhase.index >= phase.index) {
      debugPrint('🚀 [ORCHESTRATOR] Phase $phase already passed. Running $name immediately.');
      if (name != 'Unknown Task') _executedTasks.add(name);
      task().catchError((e) => debugPrint('Error in delayed orchestrator task $name: $e'));
    } else {
      debugPrint('🚀 [ORCHESTRATOR] Registered $name for Phase $phase.');
      _tasks[phase]!.add(() async {
        if (name != 'Unknown Task') {
          if (_executedTasks.contains(name)) return;
          _executedTasks.add(name);
        }
        await task();
      });
    }
  }

  /// Transition to the next phase and execute all registered tasks in parallel.
  Future<void> advanceToPhase(StartupPhase phase) async {
    if (phase.index <= _currentPhase.index) return; // Prevent going backwards

    // 🚨 ANR FIX: Brief yield before starting a new phase.
    // Just enough (50ms) for the OS scheduler to process events.
    await Future.delayed(const Duration(milliseconds: 50));

    debugPrint('🚀 [ORCHESTRATOR] Advancing to Phase: ${phase.name.toUpperCase()}');
    _currentPhase = phase;

    final tasksToRun = _tasks[phase] ?? [];
    if (tasksToRun.isEmpty) return;

    final stopwatch = Stopwatch()..start();
    
    // Execute tasks sequentially with micro-yields between them.
    // Running all tasks with Future.wait caused sustained CPU starvation
    // on Vivo devices. Sequential + yields lets the OS breathe.
    try {
      for (final task in tasksToRun) {
        await task();
        // 🚨 ANR OS YIELD FIX: Wait 100ms between background tasks.
        // Duration.zero just defers execution to the end of the Dart microtask queue,
        // which completely bypasses the underlying Android Main Looper if native
        // JNI calls are involved (Firebase, Supabase Realtime). By forcing 100ms,
        // we guarantee the UI thread can process 6 frames between every heavy initialization,
        // preventing the >2.0 second continuous Dart execution that causes Vivo devices to Signal 3.
        await Future.delayed(const Duration(milliseconds: 100));
      }
      debugPrint('🚀 [ORCHESTRATOR] Phase ${phase.name.toUpperCase()} completed in ${stopwatch.elapsedMilliseconds}ms.');
    } catch (e) {
      debugPrint('🚨 [ORCHESTRATOR] Error during Phase ${phase.name.toUpperCase()}: $e');
      // Decide whether to rethrow or continue based on criticality.
      if (phase == StartupPhase.critical) {
        rethrow;
      }
    }
  }

  /// Sugar method for interactive phase
  Future<void> markInteractive() => advanceToPhase(StartupPhase.interactive);
  
  /// Sugar method for background phase (Analytics, FCM)
  Future<void> markBackground() => advanceToPhase(StartupPhase.background);
  
  /// Sugar method for idle phase (cleanup, prefetch)
  Future<void> markIdle() => advanceToPhase(StartupPhase.idle);

  @visibleForTesting
  void reset() {
    _currentPhase = StartupPhase.preBoot;
    _tasks.forEach((key, value) => value.clear());
  }
}
