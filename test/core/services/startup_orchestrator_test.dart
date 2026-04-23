// Phase 11: StartupOrchestrator unit tests
// Tests the phased startup pipeline, task registration, deduplication, and phase ordering.

import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/startup_orchestrator.dart';

void main() {
  late StartupOrchestrator orchestrator;

  setUp(() {
    orchestrator = StartupOrchestrator();
    orchestrator.reset();
  });

  group('StartupOrchestrator', () {
    test('starts in preBoot phase', () {
      expect(orchestrator.currentPhase, StartupPhase.preBoot);
    });

    test('advances through phases in order', () async {
      await orchestrator.advanceToPhase(StartupPhase.booting);
      expect(orchestrator.currentPhase, StartupPhase.booting);

      await orchestrator.advanceToPhase(StartupPhase.critical);
      expect(orchestrator.currentPhase, StartupPhase.critical);

      await orchestrator.advanceToPhase(StartupPhase.interactive);
      expect(orchestrator.currentPhase, StartupPhase.interactive);
    });

    test('cannot go backwards to an earlier phase', () async {
      await orchestrator.advanceToPhase(StartupPhase.interactive);
      await orchestrator.advanceToPhase(StartupPhase.booting);
      expect(orchestrator.currentPhase, StartupPhase.interactive);
    });

    test('executes registered tasks when phase is reached', () async {
      var taskRan = false;
      orchestrator.registerTask(StartupPhase.interactive, () async {
        taskRan = true;
      });

      expect(taskRan, isFalse);
      await orchestrator.advanceToPhase(StartupPhase.interactive);
      expect(taskRan, isTrue);
    });

    test('executes task immediately if phase has already passed', () async {
      await orchestrator.advanceToPhase(StartupPhase.interactive);

      var taskRan = false;
      orchestrator.registerTask(StartupPhase.booting, () async {
        taskRan = true;
      });

      // Give microtask queue a chance to flush
      await Future.delayed(Duration.zero);
      expect(taskRan, isTrue);
    });

    test('deduplicates named tasks', () async {
      var executionCount = 0;
      orchestrator.registerTask(StartupPhase.interactive, () async {
        executionCount++;
      }, name: 'Matchmaking');

      // Register again with the same name
      orchestrator.registerTask(StartupPhase.interactive, () async {
        executionCount++;
      }, name: 'Matchmaking');

      await orchestrator.advanceToPhase(StartupPhase.interactive);
      expect(executionCount, 1);
    });

    test('does not deduplicate unnamed tasks', () async {
      var executionCount = 0;
      orchestrator.registerTask(StartupPhase.interactive, () async {
        executionCount++;
      });
      orchestrator.registerTask(StartupPhase.interactive, () async {
        executionCount++;
      });

      await orchestrator.advanceToPhase(StartupPhase.interactive);
      expect(executionCount, 2);
    });

    test('runs multiple phase tasks concurrently', () async {
      final log = <int>[];
      orchestrator.registerTask(StartupPhase.background, () async {
        await Future.delayed(const Duration(milliseconds: 10));
        log.add(1);
      });
      orchestrator.registerTask(StartupPhase.background, () async {
        log.add(2);
      });

      await orchestrator.advanceToPhase(StartupPhase.background);
      expect(log, containsAll([1, 2]));
    });

    test('sugar methods advance to correct phases', () async {
      await orchestrator.markInteractive();
      expect(orchestrator.currentPhase, StartupPhase.interactive);

      await orchestrator.markBackground();
      expect(orchestrator.currentPhase, StartupPhase.background);

      await orchestrator.markIdle();
      expect(orchestrator.currentPhase, StartupPhase.idle);
    });

    test('reset restores preBoot phase and clears tasks', () async {
      var taskRan = false;
      orchestrator.registerTask(StartupPhase.interactive, () async {
        taskRan = true;
      });

      orchestrator.reset();
      expect(orchestrator.currentPhase, StartupPhase.preBoot);

      await orchestrator.advanceToPhase(StartupPhase.interactive);
      expect(taskRan, isFalse);
    });

    test('rethrows errors in critical phase', () async {
      orchestrator.registerTask(StartupPhase.critical, () async {
        throw Exception('Critical failure');
      });

      expect(
        () => orchestrator.advanceToPhase(StartupPhase.critical),
        throwsException,
      );
    });

    test('swallows errors in non-critical phases', () async {
      orchestrator.registerTask(StartupPhase.background, () async {
        throw Exception('Non-critical failure');
      });

      // Should not throw
      await orchestrator.advanceToPhase(StartupPhase.background);
      expect(orchestrator.currentPhase, StartupPhase.background);
    });
  });
}
