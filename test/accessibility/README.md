# Accessibility Tests

Tests that widgets have proper semantic labels and meet accessibility standards.

## What to test here
- All interactive elements have `Semantics` labels
- Images have semantic descriptions
- Tap targets meet minimum size (48x48)
- Text contrast ratios are sufficient
- Screen reader traversal order is logical

## Run
```bash
flutter test test/accessibility/
```
