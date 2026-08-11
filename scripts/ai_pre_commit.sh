#!/bin/bash
# Pre-commit hook to speed up development by catching easy errors
# and ensuring the code-review-graph is up to date.

echo "🚀 Running AI Efficiency Pre-commit standard..."

# 1. Run dart format
dart format lib test --set-exit-if-changed
if [ $? -ne 0 ]; then
  echo "❌ Format check failed. Run 'dart format lib test' and try again."
  exit 1
fi

# 2. Run flutter analyze
flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Static analysis failed. Fix issues before committing."
  exit 1
fi

echo "✅ Pre-commit checks passed!"
