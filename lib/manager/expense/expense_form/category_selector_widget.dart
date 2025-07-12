import 'package:flutter/material.dart';
import '../../../app_localizations.dart';
import '../../../widgets/themed_outlined_button.dart';

class CategorySelectorWidget extends StatefulWidget {
  final List<String> categories;
  final String? selectedCategory;
  final void Function(String?) onCategorySelected;
  final Future<void> Function() onAddCategory;
  final AppLocalizations loc;
  final void Function(void Function())? registerScrollToEnd;

  const CategorySelectorWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategory,
    required this.loc,
    this.registerScrollToEnd,
  });

  @override
  State<CategorySelectorWidget> createState() => _CategorySelectorWidgetState();
}

class _CategorySelectorWidgetState extends State<CategorySelectorWidget> {
  int _lastCategoryCount = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.registerScrollToEnd?.call(_scrollToEnd);
    _lastCategoryCount = widget.categories.length;
    // Scroll automatico alla categoria selezionata all'apertura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToSelected();
    });
  }
  void _scrollToSelected() {
    if (widget.selectedCategory != null && widget.categories.isNotEmpty) {
      final idx = widget.categories.indexOf(widget.selectedCategory!);
      if (idx >= 0 && _scrollController.hasClients) {
        // Calcola la posizione approssimativa del chip
        // Supponiamo larghezza chip ~100px + padding 8px
        final double chipWidth = 100.0 + 8.0;
        final double offset = idx * chipWidth;
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    }
  }
  @override
  void didUpdateWidget(covariant CategorySelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se la lista delle categorie è aumentata, scrolla alla fine
    if (widget.categories.length > _lastCategoryCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToEnd();
      });
    }
    _lastCategoryCount = widget.categories.length;
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${widget.loc.get('category')} *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: widget.categories.isNotEmpty
                        ? widget.categories.map((cat) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: widget.selectedCategory == cat,
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: widget.selectedCategory == cat
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                      fontWeight: widget.selectedCategory == cat
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                backgroundColor: widget.selectedCategory == cat
                                    ? null
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                selectedColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                side: BorderSide(
                                  color: widget.selectedCategory == cat
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                onSelected: (selected) {
                                  widget.onCategorySelected(selected ? cat : null);
                                },
                              ),
                            );
                          }).toList()
                        : [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                widget.loc.get('no_categories'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                  ),
                ),
              ),
            ),
            ThemedOutlinedButton.icon(
              onPressed: widget.onAddCategory,
              icon: const Icon(Icons.add, size: 22),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
