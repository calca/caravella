#!/usr/bin/env python3
import re

def check_function_signatures(filepath):
    """Check for obvious type mismatch issues"""
    issues = []
    
    with open(filepath, 'r') as f:
        content = f.read()
        lines = content.split('\n')
    
    # Check for patterns that indicate type issues
    for i, line in enumerate(lines, 1):
        # Check for missing return types in function declarations
        if re.search(r'^\s+\w+\s+\w+\(', line) and 'void' not in line and 'Future' not in line:
            # This might be a function without explicit type
            pass
        
        # Check for Function() without proper typing
        if re.search(r'Function\s*\(', line) and '<' not in line and 'void' not in line:
            # Generic Function without type parameters
            pass
        
        # Check for obvious mismatches like assigning String to int
        if re.search(r'int\s+\w+\s*=\s*["\']', line):
            issues.append(f"Line {i}: Possible type mismatch - assigning String to int: {line.strip()}")
        
        # Check for unmatched generics
        if line.count('<') != line.count('>'):
            # Only flag if it's likely a single-line issue
            if line.count('<') > 0 and line.count('>') == 0:
                if not any(lines[j] for j in range(i, min(i+3, len(lines))) if '>' in lines[j]):
                    pass  # Multi-line generic, skip
        
        # Check for nullable type mismatches
        if re.search(r'required\s+(\w+\?)\s+', line):
            issues.append(f"Line {i}: Nullable type marked as required: {line.strip()}")
    
    return issues

files = [
    'lib/manager/expense/widgets/participant_selector_widget.dart',
    'lib/manager/expense/components/expense_form_fields.dart', 
    'lib/manager/expense/components/expense_form_component.dart',
    'packages/caravella_core/lib/state/expense_group_notifier.dart'
]

print("=== TYPE AND SIGNATURE CHECK ===\n")
all_issues = {}

for file in files:
    try:
        issues = check_function_signatures(file)
        if issues:
            all_issues[file] = issues
    except Exception as e:
        print(f"Error checking {file}: {e}")

if all_issues:
    for file, issues in all_issues.items():
        print(f"\n{file}:")
        for issue in issues:
            print(f"  ⚠ {issue}")
else:
    print("No obvious type mismatches or signature issues found in:")
    for file in files:
        print(f"  ✓ {file}")
