import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/theme/app_theme.dart';
import 'package:banjarabio/theme/app_colors.dart';

void main() {
  group('AppTheme - light color constants', () {
    test('primaryLight is Royal Crimson', () {
      expect(AppTheme.primaryLight, const Color(0xFF961B33));
    });

    test('primaryVariantLight is deeper crimson', () {
      expect(AppTheme.primaryVariantLight, const Color(0xFF731224));
    });

    test('secondaryLight is Champagne Gold', () {
      expect(AppTheme.secondaryLight, const Color(0xFFD4AF37));
    });

    test('secondaryVariantLight is darker gold', () {
      expect(AppTheme.secondaryVariantLight, const Color(0xFFB8922A));
    });

    test('backgroundLight is soft warm ivory', () {
      expect(AppTheme.backgroundLight, const Color(0xFFFAF8F5));
    });

    test('surfaceLight is pure white', () {
      expect(AppTheme.surfaceLight, const Color(0xFFFFFFFF));
    });

    test('errorLight is Material error red', () {
      expect(AppTheme.errorLight, const Color(0xFFBA1A1A));
    });

    test('successLight is green', () {
      expect(AppTheme.successLight, const Color(0xFF2E7D32));
    });

    test('warningLight is warm orange', () {
      expect(AppTheme.warningLight, const Color(0xFFF57C00));
    });

    test('onPrimaryLight is white', () {
      expect(AppTheme.onPrimaryLight, const Color(0xFFFFFFFF));
    });

    test('onSecondaryLight is dark', () {
      expect(AppTheme.onSecondaryLight, AppColors.canvasNearBlack);
    });
  });

  group('AppTheme - dark color constants', () {
    test('primaryDark is soft pinkish-crimson', () {
      expect(AppTheme.primaryDark, const Color(0xFFFFB3B4));
    });

    test('primaryVariantDark is correct', () {
      expect(AppTheme.primaryVariantDark, AppColors.crimson700);
    });

    test('secondaryDark is soft champagne gold', () {
      expect(AppTheme.secondaryDark, const Color(0xFFE5C158));
    });

    test('backgroundDark is deep warm charcoal', () {
      expect(AppTheme.backgroundDark, const Color(0xFF1A1616));
    });

    test('surfaceDark is elevated warm dark surface', () {
      expect(AppTheme.surfaceDark, const Color(0xFF262121));
    });

    test('errorDark is correct', () {
      expect(AppTheme.errorDark, const Color(0xFFF2B8B5));
    });

    test('successDark is correct', () {
      expect(AppTheme.successDark, const Color(0xFF81C784));
    });

    test('warningDark is correct', () {
      expect(AppTheme.warningDark, const Color(0xFFFFB74D));
    });
  });

  group('AppTheme - card and dialog colors', () {
    test('cardLight is white', () {
      expect(AppTheme.cardLight, const Color(0xFFFFFFFF));
    });

    test('cardDark is dark grey', () {
      expect(AppTheme.cardDark, const Color(0xFF2C2C2C));
    });

    test('dialogLight is white', () {
      expect(AppTheme.dialogLight, const Color(0xFFFFFFFF));
    });

    test('dialogDark is dark grey', () {
      expect(AppTheme.dialogDark, const Color(0xFF2C2C2C));
    });
  });

  group('AppTheme - shadow colors', () {
    test('shadowLight has correct opacity', () {
      expect(AppTheme.shadowLight, const Color(0x14000000));
    });

    test('shadowDark has correct opacity', () {
      expect(AppTheme.shadowDark, const Color(0x1FFFFFFF));
    });
  });

  group('AppTheme - divider colors', () {
    test('dividerLight is correct', () {
      expect(AppTheme.dividerLight, const Color(0xFFE0E0E0));
    });

    test('dividerDark is correct', () {
      expect(AppTheme.dividerDark, const Color(0xFF424242));
    });
  });

  group('AppTheme - text colors', () {
    test('textPrimaryLight is dark', () {
      expect(AppTheme.textPrimaryLight, const Color(0xFF2C2C2C));
    });

    test('textSecondaryLight is grey', () {
      expect(AppTheme.textSecondaryLight, const Color(0xFF666666));
    });

    test('textDisabledLight is lighter grey', () {
      expect(AppTheme.textDisabledLight, const Color(0xFF9E9E9E));
    });

    test('textPrimaryDark is near-white', () {
      expect(AppTheme.textPrimaryDark, const Color(0xFFFAFAFA));
    });

    test('textSecondaryDark is light grey', () {
      expect(AppTheme.textSecondaryDark, const Color(0xFFB0B0B0));
    });

    test('textDisabledDark is mid-grey', () {
      expect(AppTheme.textDisabledDark, const Color(0xFF757575));
    });
  });

  // Note: AppTheme.lightTheme and .darkTheme use Sizer's `sp` extension
  // which requires device initialization. We test only the static constants
  // in pure unit tests. The full theme construction is covered by widget tests
  // that use TestWidgetsFlutterBinding and Sizer wrapping.
}
