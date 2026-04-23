# Backend / API Contract Tests

Tests that the app correctly handles Supabase & Firebase API responses, including error cases.

## What to test here
- Repository methods handle success responses correctly
- Repository methods handle error/timeout responses gracefully
- JSON parsing from API matches expected models
- Auth flow handles token expiry and refresh
- Edge cases: empty lists, null fields, malformed responses

## Run
```bash
flutter test test/api_contract/
```
