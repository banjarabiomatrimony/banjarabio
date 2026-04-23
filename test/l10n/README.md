# Localization (L10n) Tests

Tests that all translation strings exist, are non-empty, and render correctly in widgets.

## What to test here
- All ARB keys have translations for every supported locale (en, hi, mr, te, kn)
- Translated strings render without overflow in widgets
- Pluralization and interpolation work correctly
- Locale switching updates the UI

## Run
```bash
flutter test test/l10n/
```
