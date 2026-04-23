import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banjarabio/theme/app_theme.dart';

void main() {
  group('AppTheme - light color constants', () {
    test('primaryLight is Midnight Amethyst', () {
      expect(AppTheme.primaryLight, const Color(0xFF432C7A));
    });

    test('primaryVariantLight is deeper amethyst', () {
      expect(AppTheme.primaryVariantLight, const Color(0xFF33215E));
    });

    test('secondaryLight is Saffron Gold', () {
      expect(AppTheme.secondaryLight, const Color(0xFFF4C430));
    });

    test('secondaryVariantLight is darker gold', () {
      expect(AppTheme.secondaryVariantLight, const Color(0xFFD4A017));
    });

    test('backgroundLight is ultra-soft amethyst tint', () {
      expect(AppTheme.backgroundLight, const Color(0xFFF9F7FD));
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
      expect(AppTheme.onSecondaryLight, const Color(0xFF1D1B20));
    });
  });

  group('AppTheme - dark color constants', () {
    test('primaryDark is light amethyst', () {
      expect(AppTheme.primaryDark, const Color(0xFFD0BCFF));
    });

    test('primaryVariantDark is correct', () {
      expect(AppTheme.primaryVariantDark, const Color(0xFF4F378B));
    });

    test('secondaryDark is soft rose/gold blend', () {
      expect(AppTheme.secondaryDark, const Color(0xFFEFB8C8));
    });

    test('backgroundDark is Material deep dark', () {
      expect(AppTheme.backgroundDark, const Color(0xFF1C1B1F));
    });

    test('surfaceDark is elevated dark', () {
      expect(AppTheme.surfaceDark, const Color(0xFF2B2930));
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
