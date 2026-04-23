# Golden Tests (Visual Regression)

Compares widget screenshots against saved "golden" reference images to detect unintended visual changes.

## What to test here
- Critical UI screens (Home, Profile, Biodata)
- Custom widgets with complex styling
- Theme changes (dark/light mode)
- Layout at different screen sizes

## Run
```bash
# Generate/update golden files
flutter test test/golden/ --update-goldens

# Run golden comparison tests
flutter test test/golden/
```

## Notes
- Golden files are stored in `test/golden/goldens/`
- Commit golden files to version control
- Re-generate goldens after intentional UI changes
