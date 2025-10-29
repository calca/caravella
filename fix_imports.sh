#!/bin/bash

# Script to fix imports from io_caravella_egm to new package structure
# This migrates from monolithic to multi-package architecture

set -e

echo "🔧 Starting import migration..."

# Function to replace imports in a file
replace_imports() {
  local file="$1"
  
  # Skip if file doesn't exist
  [ ! -f "$file" ] && return
  
  # Create backup
  cp "$file" "$file.bak"
  
  # Core package imports (models, storage, services, state)
  sed -i '' \
    -e "s|package:io_caravella_egm/data/model/expense_category.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/model/expense_details.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/model/expense_group.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/model/expense_location.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/model/expense_participant.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/expense_group_repository.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/expense_group_storage_v2.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/file_based_expense_group_repository.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/storage_benchmark.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/storage_errors.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/storage_index.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/storage_performance.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/storage_transaction.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/services/logger_service.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/services/preferences_service.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/data/services/rating_service.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/state/dynamic_color_notifier.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/state/expense_group_notifier.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/state/locale_notifier.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/state/theme_mode_notifier.dart|package:caravella_core/caravella_core.dart|g" \
    -e "s|package:io_caravella_egm/config/app_config.dart|package:caravella_core/caravella_core.dart|g" \
    "$file"
  
  # Core UI package imports (themes, widgets)
  sed -i '' \
    -e "s|package:io_caravella_egm/themes/app_text_styles.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    -e "s|package:io_caravella_egm/themes/caravella_themes.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    -e "s|package:io_caravella_egm/themes/form_theme.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    -e "s|package:io_caravella_egm/widgets/add_fab.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    -e "s|package:io_caravella_egm/widgets/app_toast.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    -e "s|package:io_caravella_egm/widgets/base_card.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    -e "s|package:io_caravella_egm/widgets/bottom_sheet_scaffold.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    -e "s|package:io_caravella_egm/widgets/caravella_app_bar.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    -e "s|package:io_caravella_egm/widgets/currency_display.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    -e "s|package:io_caravella_egm/widgets/material3_dialog.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    -e "s|package:io_caravella_egm/widgets/no_expense.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    -e "s|package:io_caravella_egm/widgets/selection_bottom_sheet.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    -e "s|package:io_caravella_egm/widgets/charts/chart_badge.dart|package:caravella_core_ui/caravella_core_ui.dart|g" \
    "$file"
  
  # Config imports that stay in main app
  sed -i '' \
    -e "s|package:io_caravella_egm/config/app_icons.dart|package:io_caravella_egm/config/app_icons.dart|g" \
    "$file"
  
  # Check if file was actually modified
  if diff -q "$file" "$file.bak" > /dev/null 2>&1; then
    rm "$file.bak"
  else
    echo "  ✓ Updated: $file"
    rm "$file.bak"
  fi
}

# Process all Dart files
echo "📁 Processing lib/ directory..."
find lib -name "*.dart" -type f | while read -r file; do
  replace_imports "$file"
done

echo ""
echo "📁 Processing test/ directory..."
find test -name "*.dart" -type f | while read -r file; do
  replace_imports "$file"
done

echo ""
echo "✅ Import migration complete!"
echo ""
echo "Next steps:"
echo "1. Run: flutter pub get"
echo "2. Run: flutter analyze"
echo "3. Run: flutter test"
