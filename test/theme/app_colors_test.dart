import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/theme/app_colors.dart';

void main() {
  group('AppColors Palette Integrity Tests', () {
    test('brand core colors are properly defined', () {
      expect(AppColors.primary, equals(const Color(0xFF961B33)));
      expect(AppColors.primaryDark, equals(const Color(0xFF731224)));
      expect(AppColors.primaryLight, equals(const Color(0xFFFFF1F2)));
      expect(AppColors.gold, equals(const Color(0xFFD4AF37)));
      expect(AppColors.goldDark, equals(const Color(0xFFB8922A)));
      expect(AppColors.canvasLight, equals(const Color(0xFFFAF8F5)));
      expect(AppColors.canvasDark, equals(const Color(0xFF1A1616)));
    });

    test('semantic status colors are distinct', () {
      expect(AppColors.success, isNot(equals(AppColors.error)));
      expect(AppColors.warning, isNot(equals(AppColors.success)));
      expect(AppColors.error, equals(const Color(0xFFBA1A1A)));
    });

    test('gradients contain valid color stops', () {
      expect(AppColors.primaryGradient.colors.length, greaterThanOrEqualTo(2));
      expect(AppColors.romanceGradient.colors.length, greaterThanOrEqualTo(2));
      expect(AppColors.goldGradient.colors.length, greaterThanOrEqualTo(2));
      expect(AppColors.trustGradient.colors.length, greaterThanOrEqualTo(2));
      expect(AppColors.navHomeGradient.colors.length, greaterThanOrEqualTo(2));
    });

    test('standard opacity scale constants are within 0.0 to 1.0', () {
      expect(AppColors.opacity5, inInclusiveRange(0.0, 1.0));
      expect(AppColors.opacity10, inInclusiveRange(0.0, 1.0));
      expect(AppColors.opacity20, inInclusiveRange(0.0, 1.0));
      expect(AppColors.opacity50, inInclusiveRange(0.0, 1.0));
      expect(AppColors.opacity90, inInclusiveRange(0.0, 1.0));
      expect(AppColors.opacity5, lessThan(AppColors.opacity90));
    });
  });
}
