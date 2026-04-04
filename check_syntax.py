#!/usr/bin/env python3
import re
import sys

def check_file_syntax(filepath):
    """Check for basic syntax issues in Dart files"""
    issues = []
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    # Check for unclosed braces
    open_braces = 0
    open_parens = 0
    open_brackets = 0
    
    for i, line in enumerate(lines, 1):
        # Count braces, parentheses, brackets
        for char in line:
            if char == '{':
                open_braces += 1
            elif char == '}':
                open_braces -= 1
            elif char == '(':
                open_parens += 1
            elif char == ')':
                open_parens -= 1
            elif char == '[':
                open_brackets += 1
            elif char == ']':
                open_brackets -= 1
        
        # Check for negative counts (closing without opening)
        if open_braces < 0:
            issues.append(f"Line {i}: Extra closing brace }}")
            open_braces = 0
        if open_parens < 0:
            issues.append(f"Line {i}: Extra closing parenthesis )")
            open_parens = 0
        if open_brackets < 0:
            issues.append(f"Line {i}: Extra closing bracket ]")
            open_brackets = 0
        
        # Check for missing semicolons (common pattern)
        stripped = line.rstrip()
        if stripped and not stripped.endswith((';', '{', '}', '(', ')', ',', ':', '//')) and not re.search(r'^\s*(if|else|for|while|switch|try|catch|finally|do)\b', stripped) and not re.search(r'=>\s*\{', stripped):
            # Check if it's a continuation or comment
            if not stripped.startswith('//') and not stripped.startswith('/*'):
                # This might need a semicolon
                if re.search(r'\b(return|break|continue|throw)\b.*[^\s{};,]$', stripped):
                    pass  # These might continue on next line
    
    # Final check
    if open_braces != 0:
        issues.append(f"Unclosed braces: {open_braces} brace(s) not closed")
    if open_parens != 0:
        issues.append(f"Unclosed parentheses: {open_parens} parenthesis/es not closed")
    if open_brackets != 0:
        issues.append(f"Unclosed brackets: {open_brackets} bracket(s) not closed")
    
    return issues

files = [
    'lib/manager/expense/widgets/participant_selector_widget.dart',
    'lib/manager/expense/components/expense_form_fields.dart',
    'lib/manager/expense/components/expense_form_component.dart',
    'packages/caravella_core/lib/state/expense_group_notifier.dart'
]

all_issues = {}
for file in files:
    try:
        issues = check_file_syntax(file)
        if issues:
            all_issues[file] = issues
    except Exception as e:
        print(f"Error checking {file}: {e}")

if all_issues:
    print("=== SYNTAX CHECK RESULTS ===\n")
    for file, issues in all_issues.items():
        print(f"\n{file}:")
        for issue in issues:
            print(f"  - {issue}")
else:
    print("=== SYNTAX CHECK RESULTS ===\n")
    print("No obvious syntax errors found in:")
    for file in files:
        print(f"  ✓ {file}")
