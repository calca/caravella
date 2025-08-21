import 'package:flutter/material.dart';
import 'dart:async';
import '../data/currencies.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/bottom_sheet_scaffold.dart';

class CurrencySelectorSheet extends StatefulWidget {
  const CurrencySelectorSheet({super.key});

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
    return RichText(text: TextSpan(children: matches));
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

    return GroupBottomSheetScaffold(
      title: l.select_currency,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l.search_currency,
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
                border: const OutlineInputBorder(),
                isDense: true,
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
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (c, i) {
                        final currency = filtered[i];
                        final name = localizedCurrencyName(
                          l,
                          currency['code']!,
                        );
                        final query = _query;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            dense: true,
                            minVerticalPadding: 8,
                            contentPadding: EdgeInsets.zero,
                            leading: Text(
                              currency['symbol'] ?? '',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              semanticsLabel: currency['symbol'] ?? '',
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
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
