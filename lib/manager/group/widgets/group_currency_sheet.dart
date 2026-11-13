import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/services.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

import '../data/currencies.dart';
import 'currency_selector_sheet.dart';

/// What [showGroupCurrencySheet] gives back: the group's currency (as the
/// currency list gives it: symbol, code, name) and its second one, if any.
class GroupCurrencyChoice {
  final Map<String, String> currency;
  final SecondCurrency? second;

  const GroupCurrencyChoice(this.currency, this.second);
}

/// General › Currency: the group's own currency ("Balances, totals and
/// budget") and, below, "Expenses also in" a second one with its rate.
/// Null when closed without "Done".
Future<GroupCurrencyChoice?> showGroupCurrencySheet(
  BuildContext context, {
  required Map<String, String> currency,
  required SecondCurrency? second,
}) {
  return showAppBottomSheet<GroupCurrencyChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => GroupCurrencySheet(currency: currency, second: second),
  );
}

class GroupCurrencySheet extends StatefulWidget {
  final Map<String, String> currency;
  final SecondCurrency? second;

  const GroupCurrencySheet({
    super.key,
    required this.currency,
    required this.second,
  });

  @override
  State<GroupCurrencySheet> createState() => _GroupCurrencySheetState();
}

class _GroupCurrencySheetState extends State<GroupCurrencySheet> {
  late Map<String, String> _currency = widget.currency;

  /// The second currency picked (code and symbol); its rate is in [_rate].
  late Map<String, String>? _second = switch (widget.second) {
    final s? => {'code': s.code, 'symbol': s.symbol},
    null => null,
  };
  late final TextEditingController _rate = TextEditingController();
  final FocusNode _rateFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _rate.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_rate.text.isEmpty && widget.second != null) {
      _rate.text = CurrencyDisplay.formatRate(
        widget.second!.rate,
        Localizations.localeOf(context),
      );
    }
  }

  @override
  void dispose() {
    _rate.dispose();
    _rateFocus.dispose();
    super.dispose();
  }

  double? get _rateValue {
    final v = AmountField.parse(_rate.text);
    return v != null && v > 0 ? v : null;
  }

  /// Done is off while a second currency has no rate yet.
  bool get _canSave => _second == null || _rateValue != null;

  Future<Map<String, String>?> _pick(String? selectedCode) =>
      showAppBottomSheet<Map<String, String>>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => CurrencySelectorSheet(selectedCode: selectedCode),
      );

  Future<void> _changeGroupCurrency() async {
    final picked = await _pick(_currency['code']);
    if (picked == null || !mounted) return;
    setState(() {
      final changed = picked['code'] != _currency['code'];
      _currency = picked;
      // The same as the second: it is no longer a second one.
      if (_second?['code'] == picked['code']) {
        _second = null;
        _rate.clear();
      } else if (changed && _second != null) {
        // "1 € = 11,63 kr" says nothing about the new currency: ask again.
        _rate.clear();
        _rateFocus.requestFocus();
      }
    });
  }

  Future<void> _addSecond() async {
    final picked = await _pick(null);
    if (picked == null || !mounted) return;
    if (picked['code'] == _currency['code']) return;
    setState(() {
      _second = picked;
      _rate.clear();
    });
    _rateFocus.requestFocus();
  }

  void _removeSecond() => setState(() {
    _second = null;
    _rate.clear();
  });

  void _done() {
    if (!_canSave) return;
    final second = _second;
    Navigator.of(context).pop(
      GroupCurrencyChoice(
        _currency,
        second == null
            ? null
            : SecondCurrency(
                code: second['code']!,
                symbol: second['symbol'] ?? second['code']!,
                rate: _rateValue!,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final groupSymbol = _currency['symbol'] ?? _currency['code'] ?? '';
    final second = _second;

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: s.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    Widget badge(Widget child) => Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: s.onSurface.withValues(alpha: 0.06),
      ),
      child: child,
    );

    Widget symbolBadge(String symbol) => badge(
      Text(
        symbol,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    // A Material, not a DecoratedBox: the rows' ink shows on it.
    Widget card(Widget child) => Material(
      color: s.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: s.outlineVariant),
      ),
      child: child,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: CaravellaBottomSheetScaffold(
        title: gloc.currency,
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading(gloc.currency_section_group),
            card(
              ListTile(
                leading: symbolBadge(groupSymbol),
                title: Text(localizedCurrencyName(gloc, _currency['code']!)),
                subtitle: Text(gloc.currency_group_hint),
                trailing: TextButton(
                  onPressed: _changeGroupCurrency,
                  child: Text(gloc.currency_change),
                ),
              ),
            ),
            const SizedBox(height: 20),
            heading(gloc.second_currency_section),
            if (second == null)
              card(
                ListTile(
                  leading: badge(const Icon(Icons.add_rounded, size: 20)),
                  title: Text(gloc.second_currency_add),
                  subtitle: Text(gloc.second_currency_add_hint),
                  onTap: _addSecond,
                ),
              )
            else
              card(
                Column(
                  children: [
                    ListTile(
                      leading: symbolBadge(second['symbol'] ?? ''),
                      title: Text(localizedCurrencyName(gloc, second['code']!)),
                      subtitle: Text(second['code']!),
                      trailing: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: gloc.second_currency_remove(
                          localizedCurrencyName(gloc, second['code']!),
                        ),
                        onPressed: _removeSecond,
                      ),
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '1 $groupSymbol =',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: s.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Semantics(
                              label: gloc.second_currency_rate_label(
                                groupSymbol,
                                second['symbol'] ?? second['code']!,
                              ),
                              child: TextField(
                                controller: _rate,
                                focusNode: _rateFocus,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*[.,]?\d{0,4}'),
                                  ),
                                ],
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _done(),
                                style: theme.textTheme.headlineSmall,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: '0',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            second['symbol'] ?? second['code']!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: s.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                second == null
                    ? gloc.second_currency_empty_hint(groupSymbol)
                    : gloc.second_currency_rate_hint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: s.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _canSave ? _done : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: Text(gloc.done),
            ),
          ],
        ),
      ),
    );
  }
}
