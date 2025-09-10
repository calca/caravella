import 'package:flutter/material.dart';
import '../../../data/model/expense_category.dart';
import '../../../data/model/expense_participant.dart';
import 'category_selector_widget.dart';
import 'participant_selector_widget.dart';
import 'multi_payer_selector_widget.dart';
import '../../../themes/form_theme.dart';
import 'field_status_wrapper.dart';

/// Combined participant + category selectors section.
class ParticipantCategorySectionWidget extends StatelessWidget {
  final bool showExtendedLayout;
  final List<ExpenseParticipant> participants;
  final List<ExpenseCategory> categories;
  final ExpenseParticipant?
  selectedParticipant; // legacy single selection (edit mode)
  final List<ExpenseParticipant>?
  selectedPayers; // multi selection (create mode)
  final ExpenseCategory? selectedCategory;
  final ValueChanged<String> onParticipantSelected; // single mode callback
  final ValueChanged<ExpenseParticipant>? onTogglePayer; // multi mode toggle
  final ValueChanged<ExpenseCategory?> onCategorySelected;
  final Future<void> Function() onAddCategory;
  final Future<void> Function(String) onAddCategoryInline;
  final TextStyle? textStyle;
  final bool isPaidByValid;
  final bool paidByTouched;
  final bool isCategoryValid;
  final bool categoryTouched;

  final bool multiPayerEnabled;
  final int maxPayers;
  final double? totalAmount; // for split hint
  final String? currency;

  const ParticipantCategorySectionWidget({
    super.key,
    required this.showExtendedLayout,
    required this.participants,
    required this.categories,
    required this.selectedParticipant,
    this.selectedPayers,
    required this.selectedCategory,
    required this.onParticipantSelected,
    this.onTogglePayer,
    required this.onCategorySelected,
    required this.onAddCategory,
    required this.onAddCategoryInline,
    required this.textStyle,
    required this.isPaidByValid,
    required this.paidByTouched,
    required this.isCategoryValid,
    required this.categoryTouched,
    this.multiPayerEnabled = false,
    this.maxPayers = 2,
    this.totalAmount,
    this.currency,
  });

  Widget _spacer() => const SizedBox(height: FormTheme.fieldSpacing);

  @override
  Widget build(BuildContext context) {
    if (showExtendedLayout) {
      return Column(
        children: [
          if (multiPayerEnabled)
            FieldStatusWrapper(
              isValid: isPaidByValid,
              isTouched: paidByTouched,
              child: MultiPayerSelectorWidget(
                participants: participants,
                selected: selectedPayers ?? const [],
                maxPayers: maxPayers,
                onToggle: (p) => onTogglePayer?.call(p),
                textStyle: textStyle,
                totalAmount: totalAmount,
                currency: currency,
              ),
            )
          else
            FieldStatusWrapper(
              isValid: isPaidByValid,
              isTouched: paidByTouched,
              child: ParticipantSelectorWidget(
                participants: participants.map((p) => p.name).toList(),
                selectedParticipant: selectedParticipant?.name,
                onParticipantSelected: onParticipantSelected,
                textStyle: textStyle,
                fullEdit: true,
              ),
            ),
          _spacer(),
          FieldStatusWrapper(
            isValid: isCategoryValid,
            isTouched: categoryTouched,
            child: CategorySelectorWidget(
              categories: categories,
              selectedCategory: selectedCategory,
              onCategorySelected: onCategorySelected,
              onAddCategory: onAddCategory,
              onAddCategoryInline: onAddCategoryInline,
              textStyle: textStyle,
              fullEdit: true,
            ),
          ),
        ],
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          if (multiPayerEnabled)
            FieldStatusWrapper(
              isValid: isPaidByValid,
              isTouched: paidByTouched,
              child: MultiPayerSelectorWidget(
                participants: participants,
                selected: selectedPayers ?? const [],
                maxPayers: maxPayers,
                onToggle: (p) => onTogglePayer?.call(p),
                textStyle: textStyle,
                totalAmount: totalAmount,
                currency: currency,
              ),
            )
          else
            FieldStatusWrapper(
              isValid: isPaidByValid,
              isTouched: paidByTouched,
              child: ParticipantSelectorWidget(
                participants: participants.map((p) => p.name).toList(),
                selectedParticipant: selectedParticipant?.name,
                onParticipantSelected: onParticipantSelected,
                textStyle: textStyle,
                fullEdit: false,
              ),
            ),
          FieldStatusWrapper(
            isValid: isCategoryValid,
            isTouched: categoryTouched,
            child: CategorySelectorWidget(
              categories: categories,
              selectedCategory: selectedCategory,
              onCategorySelected: onCategorySelected,
              onAddCategory: onAddCategory,
              onAddCategoryInline: onAddCategoryInline,
              textStyle: textStyle,
              fullEdit: false,
            ),
          ),
        ],
      ),
    );
  }
}
