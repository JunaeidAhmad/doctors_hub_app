#!/bin/bash
set -e

echo "=== Running Flutter analyze ==="
flutter analyze

echo "=== Running Flutter tests ==="
flutter test

echo "=== All checks passed successfully! ==="
