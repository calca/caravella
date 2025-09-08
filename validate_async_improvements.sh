#!/bin/bash

# Simple validation script to check for common syntax issues in our Dart files

echo "Validating Dart syntax in new async state management files..."

# List of files to check
files=(
    "lib/state/async_state.dart"
    "lib/state/async_state_notifier.dart"
    "lib/state/app_version_notifier.dart"
    "lib/state/expense_groups_async_notifier.dart"
    "lib/widgets/async_value_builder.dart"
    "test/async_state_test.dart"
    "test/async_state_notifier_test.dart"
    "test/app_version_notifier_test.dart"
)

# Check for basic syntax issues
for file in "${files[@]}"; do
    echo "Checking $file..."
    
    # Check for unmatched braces
    open_braces=$(grep -o '{' "$file" | wc -l)
    close_braces=$(grep -o '}' "$file" | wc -l)
    
    if [ "$open_braces" -ne "$close_braces" ]; then
        echo "  WARNING: Unmatched braces in $file (open: $open_braces, close: $close_braces)"
    else
        echo "  ✓ Braces matched in $file"
    fi
    
    # Check for unmatched parentheses
    open_parens=$(grep -o '(' "$file" | wc -l)
    close_parens=$(grep -o ')' "$file" | wc -l)
    
    if [ "$open_parens" -ne "$close_parens" ]; then
        echo "  WARNING: Unmatched parentheses in $file (open: $open_parens, close: $close_parens)"
    else
        echo "  ✓ Parentheses matched in $file"
    fi
    
    # Check for basic import structure
    if grep -q "^import " "$file"; then
        echo "  ✓ Imports found in $file"
    else
        echo "  INFO: No imports in $file (may be normal for some files)"
    fi
    
    echo ""
done

echo "Basic syntax validation complete."
echo ""
echo "Key improvements implemented:"
echo "- AsyncValue<T> pattern for type-safe async state management"
echo "- AsyncStateNotifier for reactive state handling"
echo "- AsyncListNotifier for specialized list operations"
echo "- AsyncValueBuilder for declarative UI building"
echo "- Replaced FutureBuilder usage in settings and home pages"
echo "- Comprehensive test coverage for new components"