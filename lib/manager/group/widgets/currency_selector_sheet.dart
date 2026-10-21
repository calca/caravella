import 'package:material_ui/material_ui.dart';
import 'dart:async';
import 'package:io_caravella_egm/manager/group/data/currencies.dart';
import '../../../l10n/app_localizations.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

class CurrencySelectorSheet extends StatefulWidget {
  /// The current currency's code, ticked in the list.
  final String? selectedCode;

  const CurrencySelectorSheet({super.key, this.selectedCode});

  @override
  State<CurrencySelectorSheet> createState() => _CurrencySelectorSheetState();
}

class _CurrencySelectorSheetState extends State<CurrencySelectorSheet> {
  String _query = '';
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  static const _debounceDuration = Duration(milliseconds: 220);

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      if (!mounted) return;
      setState(() => _query = value.trim());
    });
  }

  Text _plainText(String text) =>
      Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);

  Widget _buildHighlighted(String source, String query, TextStyle? baseStyle) {
    if (query.isEmpty) return _plainText(source);
    final lowerSource = source.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matches = <TextSpan>[];
    int start = 0;
    final highlightStyle =
        baseStyle?.copyWith(
          fontWeight: FontWeight.w600,
          color: baseStyle.color,
        ) ??
        const TextStyle(fontWeight: FontWeight.w600);
    while (true) {
      final index = lowerSource.indexOf(lowerQuery, start);
      if (index < 0) {
        matches.add(TextSpan(text: source.substring(start), style: baseStyle));
        break;
      }
      if (index > start) {
        matches.add(
          TextSpan(text: source.substring(start, index), style: baseStyle),
        );
      }
      matches.add(
        TextSpan(
          text: source.substring(index, index + lowerQuery.length),
          style: highlightStyle,
        ),
      );
      start = index + lowerQuery.length;
      if (start >= source.length) break;
    }
    return Text.rich(TextSpan(children: matches));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final all = List<Map<String, String>>.from(kCurrencies)
      ..sort((a, b) {
        final aName = localizedCurrencyName(l, a['code']!);
        final bName = localizedCurrencyName(l, b['code']!);
        return aName.compareTo(bName);
      });
    final lower = _query.toLowerCase();
    final filtered = lower.isEmpty
        ? all
        : all.where((c) {
            final name = localizedCurrencyName(l, c['code']!).toLowerCase();
            final code = c['code']!.toLowerCase();
            return name.contains(lower) || code.contains(lower);
          }).toList();

    return CaravellaBottomSheetScaffold(
      title: l.select_currency,
      child: SizedBox(
        // Room for the keyboard below the list.
        height:
            MediaQuery.sizeOf(context).height * 0.8 -
            MediaQuery.viewInsetsOf(context).bottom,
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: FormTheme.getSearchPillDecoration(
                backgroundColor: colorScheme.raisedSurface,
                hintText: l.search_currency,
                prefixIcon: const Icon(Icons.search_outlined),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).deleteButtonTooltip,
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _query = '';
                            _controller.clear();
                          });
                        },
                      ),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        '—',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : CardOutline(
                      borderRadius: BorderRadius.circular(20),
                      child: Material(
                        color: colorScheme.raisedSurface,
                        borderRadius: BorderRadius.circular(20),
                        clipBehavior: Clip.antiAlias,
                        child: ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            indent: 64,
                            endIndent: 16,
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          itemBuilder: (c, i) {
                            final currency = filtered[i];
                            final name = localizedCurrencyName(
                              l,
                              currency['code']!,
                            );
                            final query = _query;
                            final isSelected =
                                currency['code'] == widget.selectedCode;
                            return ListTile(
                              minVerticalPadding: 10,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              selected: isSelected,
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_rounded,
                                      color: colorScheme.primary,
                                    )
                                  : null,
                              leading: Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.06,
                                  ),
                                ),
                                child: Text(
                                  currency['symbol'] ?? '',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                  semanticsLabel: currency['symbol'] ?? '',
                                ),
                              ),
                              title: _buildHighlighted(
                                name,
                                query,
                                Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle: _buildHighlighted(
                                '${currency['code']}',
                                query,
                                Theme.of(context).textTheme.bodySmall,
                              ),
                              onTap: () {
                                final selected = Map<String, String>.from(
                                  currency,
                                );
                                selected['name'] = name;
                                Navigator.pop<Map<String, String>>(
                                  context,
                                  selected,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
