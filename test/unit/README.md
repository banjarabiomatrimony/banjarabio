# Unit Tests

Tests for individual functions, methods, and classes **in isolation**.

## What to test here
- Repository methods (with mocked dependencies)
- Data model serialization/deserialization (`.fromJson()`, `.toJson()`)
- Validation logic (forms, input parsing)
- Business logic (trust score calculation, referral logic)
- Utility/helper functions

## Run
```bash
flutter test test/unit/
```
