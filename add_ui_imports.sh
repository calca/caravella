#!/bin/bash

# Script per aggiungere import caravella_core_ui ai file che usano classi UI
# come AppToast, ToastType, CurrencyDisplay, Material3Dialog, etc.

echo "=== Aggiunta import caravella_core_ui ai file che lo richiedono ==="

# Lista file che usano AppToast, ToastType o altri widget da caravella_core_ui
FILES=(
  "lib/home/home_page.dart"
  "lib/home/cards/widgets/group_card_content.dart"
  "lib/manager/details/pages/expense_group_detail_page.dart"
  "lib/manager/history/expenses_history_page.dart"
  "lib/manager/history/widgets/swipeable_expense_group_card.dart"
  "lib/services/shortcuts_initialization.dart"
  "lib/updates/update_check_helper.dart"
  "lib/updates/update_check_widget.dart"
  "lib/settings/pages/settings_page.dart"
  "lib/manager/group/group_form_controller.dart"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    # Verifica se l'import esiste già
    if ! grep -q "import 'package:caravella_core_ui/caravella_core_ui.dart'" "$file"; then
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
import 'package:caravella_core_ui/caravella_core_ui.dart';\\
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
