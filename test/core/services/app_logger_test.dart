import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/core/services/app_logger.dart';

void main() {
  group('AppLogger Tests', () {
    test('debug, info, warn, error logging methods execute without crash', () {
      expect(() => AppLogger.debug('TestTag', 'Debug message'), returnsNormally);
      expect(() => AppLogger.info('TestTag', 'Info message'), returnsNormally);
      expect(() => AppLogger.warn('TestTag', 'Warning message'), returnsNormally);
      expect(() => AppLogger.error('TestTag', 'Error message', Exception('Test exception')), returnsNormally);
    });

    test('minLevel configuration behaves properly', () {
      final prev = AppLogger.minLevel;
      AppLogger.minLevel = 2; // Warn level
      expect(() => AppLogger.debug('Tag', 'Ignored debug'), returnsNormally);
      expect(() => AppLogger.warn('Tag', 'Visible warn'), returnsNormally);
      AppLogger.minLevel = prev;
    });
  });
}
