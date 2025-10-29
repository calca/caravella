#!/bin/bash

# Script per aggiungere import caravella_core ai file che lo richiedono

echo "=== Aggiunta import caravella_core ai file che lo richiedono ==="

FILES=(
  "lib/home/cards/widgets/group_card_content.dart"
  "lib/home/cards/widgets/horizontal_groups_list.dart"
  "lib/manager/details/export/ofx_exporter.dart"
  "lib/manager/details/pages/expense_group_detail_page.dart"
  "lib/manager/details/pages/tabs/categories_overview_tab.dart"
  "lib/manager/details/pages/tabs/participants_overview_tab.dart"
  "lib/manager/details/pages/unified_overview_page.dart"
  "lib/manager/group/pages/expenses_group_edit_page.dart"
  "lib/manager/history/expenses_history_page.dart"
  "lib/manager/history/widgets/swipeable_expense_group_card.dart"
  "lib/services/app_shortcuts_service.dart"
  "lib/services/shortcuts_initialization.dart"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    # Verifica se l'import esiste già
    if ! grep -q "import 'package:caravella_core/caravella_core.dart'" "$file"; then
      # Trova la prima riga di import
      first_import_line=$(grep -n "^import" "$file" | head -1 | cut -d: -f1)
      
      if [ -n "$first_import_line" ]; then
        # Aggiunge l'import dopo l'ultimo import di flutter
        last_flutter_import=$(grep -n "^import 'package:flutter" "$file" | tail -1 | cut -d: -f1)
        if [ -n "$last_flutter_import" ]; then
          insert_line=$((last_flutter_import + 1))
        else
          insert_line=$first_import_line
        fi
        
        # Inserisce l'import
        sed -i '' "${insert_line}i\\
import 'package:caravella_core/caravella_core.dart';\\
" "$file"
        echo "✓ Aggiunto import a $file"
      else
        echo "⚠ Nessun import trovato in $file, skip"
      fi
    else
      echo "- Import già presente in $file"
    fi
  else
    echo "✗ File non trovato: $file"
  fi
done

echo ""
echo "=== Completato! ==="
