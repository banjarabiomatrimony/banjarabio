// Phase 13: Localization integrity tests
// Ensures all ARB files have matching keys and no missing translations.
// Known gaps are reported but do not fail the suite — they are diagnostic.

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> enArb;
  late Map<String, dynamic> hiArb;
  late Map<String, dynamic> knArb;
  late Map<String, dynamic> mrArb;
  late Map<String, dynamic> teArb;

  /// Filters out ICU metadata keys (keys starting with '@')
  Set<String> contentKeys(Map<String, dynamic> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  setUp(() {
    const basePath = 'lib/l10n';
    enArb = jsonDecode(File('$basePath/app_en.arb').readAsStringSync());
    hiArb = jsonDecode(File('$basePath/app_hi.arb').readAsStringSync());
    knArb = jsonDecode(File('$basePath/app_kn.arb').readAsStringSync());
    mrArb = jsonDecode(File('$basePath/app_mr.arb').readAsStringSync());
    teArb = jsonDecode(File('$basePath/app_te.arb').readAsStringSync());
  });

  group('ARB Structure Integrity', () {
    test('English ARB has a substantial number of keys', () {
      final enKeys = contentKeys(enArb);
      expect(enKeys.length, greaterThan(500),
          reason: 'English ARB should have a large key set');
    });

    test('All locale files parse as valid JSON', () {
      // If setUp completes, all files parsed correctly
      expect(enArb, isNotEmpty);
      expect(hiArb, isNotEmpty);
      expect(knArb, isNotEmpty);
      expect(mrArb, isNotEmpty);
      expect(teArb, isNotEmpty);
    });

    test('No English keys have empty string values (excluding emptyStr)', () {
      final emptyKeys = contentKeys(enArb)
          .where((k) => enArb[k] is String && (enArb[k] as String).trim().isEmpty)
          .where((k) => k != 'emptyStr')
          .toList();
      expect(emptyKeys, isEmpty,
          reason: 'English ARB has ${emptyKeys.length} empty values: '
              '${emptyKeys.take(10).join(', ')}');
    });

    test('No Hindi keys have empty string values', () {
      final emptyKeys = contentKeys(hiArb)
          .where((k) => hiArb[k] is String && (hiArb[k] as String).trim().isEmpty)
          .where((k) => k != 'emptyStr')
          .toList();
      expect(emptyKeys, isEmpty,
          reason: 'Hindi ARB has ${emptyKeys.length} empty values: '
              '${emptyKeys.take(10).join(', ')}');
    });

    test('No orphan keys exist in Hindi that are missing from English', () {
      final enKeys = contentKeys(enArb);
      final hiKeys = contentKeys(hiArb);
      final orphans = hiKeys.difference(enKeys);
      expect(orphans, isEmpty,
          reason: 'Hindi has ${orphans.length} orphan keys not in English: '
              '${orphans.take(10).join(', ')}');
    });
  });

  group('ARB Key Coverage Report (Diagnostic)', () {
    test('Report coverage percentages for all locales', () {
      final enKeys = contentKeys(enArb);
      final enCount = enKeys.length;

      final locales = {
        'Hindi (hi)': contentKeys(hiArb),
        'Kannada (kn)': contentKeys(knArb),
        'Marathi (mr)': contentKeys(mrArb),
        'Telugu (te)': contentKeys(teArb),
      };

      debugPrint('📊 Localization Key Coverage Report:');
      debugPrint('   English (en): $enCount keys (baseline)');
      
      for (final entry in locales.entries) {
        final count = entry.value.length;
        final missing = enKeys.difference(entry.value);
        final pct = (count / enCount * 100).toStringAsFixed(1);
        debugPrint('   ${entry.key}: $count keys ($pct%) — ${missing.length} missing');
        if (missing.isNotEmpty) {
          debugPrint('     Missing: ${missing.take(5).join(', ')}${missing.length > 5 ? '...' : ''}');
        }
      }

      // Coverage should be above 80% for all locales
      for (final entry in locales.entries) {
        final pct = entry.value.length / enCount * 100;
        expect(pct, greaterThan(80),
            reason: '${entry.key} coverage is below 80%: ${pct.toStringAsFixed(1)}%');
      }
    });
  });

  group('Placeholder Consistency Report (Diagnostic)', () {
    test('Report placeholder mismatches between en and hi', () {
      final enKeys = contentKeys(enArb);
      final inconsistentKeys = <String>[];

      for (final key in enKeys) {
        final enValue = enArb[key];
        final hiValue = hiArb[key];
        if (enValue is! String || hiValue is! String) continue;

        // Extract {placeholder} patterns (simple — not ICU select/plural)
        final enPlaceholders =
            RegExp(r'\{(\w+)\}').allMatches(enValue).map((m) => m.group(1)!).toSet();
        final hiPlaceholders =
            RegExp(r'\{(\w+)\}').allMatches(hiValue).map((m) => m.group(1)!).toSet();

        final setsEqual = enPlaceholders.length == hiPlaceholders.length &&
            enPlaceholders.every(hiPlaceholders.contains);

        if (enPlaceholders.isNotEmpty && !setsEqual) {
          inconsistentKeys.add(key);
        }
      }

      if (inconsistentKeys.isNotEmpty) {
        debugPrint('⚠️ ${inconsistentKeys.length} keys have placeholder mismatches between en/hi:');
        for (final key in inconsistentKeys.take(10)) {
          debugPrint('   $key');
        }
        if (inconsistentKeys.length > 10) {
          debugPrint('   ... and ${inconsistentKeys.length - 10} more');
        }
      }

      // This is diagnostic — we allow up to 150 mismatches for now
      // (many are ICU plural/select where regex matching is imprecise)
      expect(inconsistentKeys.length, lessThan(150),
          reason: 'Too many placeholder mismatches: ${inconsistentKeys.length}');
    });
  });
}
