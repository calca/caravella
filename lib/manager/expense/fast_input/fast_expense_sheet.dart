import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import 'fast_input_parser.dart';

/// An expense written in one line (#623): `coffee 5.50 @yesterday #food
/// +Anna`. Under the field, what was understood; while a `@`, `#` or `+`
/// word is being typed, the days, categories or people that complete it.
/// [onSave] gets a complete line and returns whether it was saved (the
/// sheet then closes); [onOpenForm] gets what was understood so far.
class FastExpenseSheet extends StatefulWidget {
  final ExpenseGroup group;
  final Future<bool> Function(FastInput input) onSave;
  final void Function(FastInput input) onOpenForm;

  /// Fixed "now" for tests.
  final DateTime? now;

  const FastExpenseSheet({
    super.key,
    required this.group,
    required this.onSave,
    required this.onOpenForm,
    this.now,
  });

  @override
  State<FastExpenseSheet> createState() => _FastExpenseSheetState();
}

class _FastExpenseSheetState extends State<FastExpenseSheet> {
  late final _MarkedTextController _text;
  final _focus = FocusNode();
  late final List<ExpenseCategory> _categories;
  late final List<ExpenseParticipant> _participants;
  bool _saving = false;

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    // Defaults follow the hand-written form: who paid last, the category
    // used last.
    _categories = widget.group.getCategoriesByLastUsed();
    _participants = widget.group.getParticipantsByLastUsed();
    _text = _MarkedTextController()..addListener(_onChanged);
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  FastInput get _input => FastInputParser.parse(
    _text.text,
    categories: _categories,
    participants: _participants,
    now: _now,
  );

  FastActiveToken? get _active {
    final sel = _text.selection;
    if (!sel.isValid || !sel.isCollapsed) return null;
    return FastInputParser.activeToken(_text.text, sel.baseOffset);
  }

  void _onChanged() {
    final input = _input;
    _text.invalidWords = {
      if (input.unknownPayer != null) '+${input.unknownPayer}',
      if (input.invalidDate != null) '@${input.invalidDate}',
    };
    setState(() {});
  }

  /// Replaces the word being typed with [word] and a space.
  void _complete(FastActiveToken token, String word) {
    final text = _text.text;
    final after = text.substring(token.end);
    final spaced = after.startsWith(' ') ? after : ' $after';
    final value = text.substring(0, token.start) + word + spaced;
    final cursor = token.start + word.length + 1;
    _text.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  /// Starts a marked word at the end of the line (the payer chip: tap to
  /// pick someone else), replacing the one already there.
  void _startMarker(String marker) {
    final words = _text.text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !w.startsWith(marker))
        .toList();
    final value = [...words, marker].join(' ');
    _text.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _focus.requestFocus();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final saved = await widget.onSave(_input);
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop();
    } else {
      setState(() => _saving = false);
    }
  }

  String _amountText(BuildContext context, double amount) {
    final locale = Localizations.localeOf(context).toString();
    final n = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 2,
    ).format(amount);
    return '$n ${widget.group.currency}';
  }

  String _dateText(gen.AppLocalizations gloc, DateTime date, String locale) {
    final today = DateTime(_now.year, _now.month, _now.day);
    final days = today.difference(date).inDays;
    if (days == 0) return gloc.today;
    if (days == 1) return gloc.fast_input_yesterday;
    return DateFormat.MMMEd(locale).format(date);
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final input = _input;
    final active = _active;

    final String buttonLabel;
    if (input.isComplete) {
      buttonLabel = gloc.fast_input_add(_amountText(context, input.amount!));
    } else if (!input.hasAmount) {
      buttonLabel = gloc.fast_input_need_amount;
    } else {
      buttonLabel = gloc.fast_input_fix_first;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: CaravellaBottomSheetScaffold(
        title: widget.group.title,
        scrollable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _text,
              focusNode: _focus,
              autofocus: true,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              decoration: FormTheme.getCardDecoration(
                fillColor: s.raisedSurface,
                borderColor: CardOutline.colorFor(theme.brightness),
                focusColor: s.primary,
                errorColor: s.error,
                hintText: gloc.fast_input_hint,
              ).copyWith(labelText: null),
              onSubmitted: (_) {
                if (input.isComplete) _save();
              },
            ),
            const SizedBox(height: 16),
            if (active != null)
              _Suggestions(
                token: active,
                categories: _categories,
                participants: _participants,
                now: _now,
                onPick: (word) => _complete(active, word),
              )
            else if (_text.text.trim().isNotEmpty)
              _Understood(
                input: input,
                amountText: input.hasAmount
                    ? _amountText(context, input.amount!)
                    : null,
                dateText: _dateText(
                  gloc,
                  input.date,
                  Localizations.localeOf(context).toString(),
                ),
                onPayerTap: () => _startMarker('+'),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                // The usual form, with what was understood so far: round
                // like the buttons left of Save in the expense form.
                IconButton(
                  tooltip: gloc.fast_input_open_form,
                  onPressed: () => widget.onOpenForm(input),
                  icon: const Icon(Icons.arrow_circle_up_outlined, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: s.raisedSurface,
                    foregroundColor: s.onSurface,
                    side: BorderSide(color: CardOutline.colorFor(s.brightness)),
                    minimumSize: const Size(52, 52),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: input.isComplete && !_saving ? _save : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: s.primary,
                      foregroundColor: s.onPrimary,
                      disabledBackgroundColor: s.surfaceContainerHighest,
                      disabledForegroundColor: s.onSurfaceVariant,
                      elevation: 0,
                      minimumSize: const Size(52, 52),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      buttonLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: input.isComplete
                            ? s.onPrimary
                            : s.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// What the line says, as chips: description, amount, day, category, who
/// paid (tap to pick someone else).
class _Understood extends StatelessWidget {
  final FastInput input;
  final String? amountText;
  final String dateText;
  final VoidCallback onPayerTap;

  const _Understood({
    required this.input,
    required this.amountText,
    required this.dateText,
    required this.onPayerTap,
  });

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final note = theme.textTheme.bodySmall?.copyWith(color: s.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsLabel(gloc.fast_input_understood),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (input.name != null) _Chip(label: input.name!),
            if (amountText != null)
              _Chip(label: amountText!, strong: true)
            else
              _Chip(
                label: gloc.fast_input_amount_missing,
                kind: _ChipKind.problem,
              ),
            if (input.invalidDate != null)
              _Chip(
                label: gloc.fast_input_invalid_date(input.invalidDate!),
                kind: _ChipKind.problem,
              )
            else
              _Chip(icon: Icons.event_outlined, label: dateText),
            if (input.newCategory != null)
              _Chip(
                icon: Icons.add_rounded,
                label: gloc.fast_input_new_category(input.newCategory!),
                kind: _ChipKind.created,
              )
            else if (input.category != null)
              _Chip(icon: Icons.sell_outlined, label: input.category!.name),
            if (input.unknownPayer != null)
              _Chip(
                label: gloc.fast_input_unknown_payer(input.unknownPayer!),
                kind: _ChipKind.problem,
                onTap: onPayerTap,
              )
            else if (input.paidBy != null)
              FormPill(
                icon: Icons.person_outline_rounded,
                label: gloc.fast_input_paid_by(input.paidBy!.name),
                trailingIcon: Icons.expand_more_rounded,
                onTap: onPayerTap,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (input.newCategory != null)
          Text(
            gloc.fast_input_new_category_note(input.newCategory!),
            style: note,
          )
        else
          Text(gloc.fast_input_split_all, style: note),
      ],
    );
  }
}

/// What completes the `@`, `#` or `+` word being typed.
class _Suggestions extends StatelessWidget {
  final FastActiveToken token;
  final List<ExpenseCategory> categories;
  final List<ExpenseParticipant> participants;
  final DateTime now;
  final ValueChanged<String> onPick;

  const _Suggestions({
    required this.token,
    required this.categories,
    required this.participants,
    required this.now,
    required this.onPick,
  });

  /// Today, yesterday and the four days before by weekday name.
  List<String> _dateWords(gen.AppLocalizations gloc, String locale) {
    final today = DateTime(now.year, now.month, now.day);
    return [
      gloc.fast_input_token_today,
      gloc.fast_input_token_yesterday,
      for (var back = 2; back <= 5; back++)
        DateFormat.E(locale)
            .format(today.subtract(Duration(days: back)))
            .toLowerCase()
            .replaceAll('.', ''),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final (
      String title,
      String marker,
      List<String> words,
    ) = switch (token.kind) {
      FastTokenKind.category => (
        gloc.fast_input_suggest_categories,
        '#',
        FastInputParser.suggest(
          categories,
          token.query,
          (c) => c.name,
        ).map((c) => c.name).toList(),
      ),
      FastTokenKind.payer => (
        gloc.fast_input_suggest_payers,
        '+',
        FastInputParser.suggest(
          participants,
          token.query,
          (p) => p.name,
        ).map((p) => p.name).toList(),
      ),
      FastTokenKind.date => (
        gloc.fast_input_suggest_dates,
        '@',
        FastInputParser.suggest(
          _dateWords(gloc, locale),
          token.query,
          (w) => w,
        ),
      ),
    };
    if (words.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsLabel(title),
        Wrap(
          spacing: 8,
          children: [
            for (final (i, w) in words.indexed)
              FormPill(
                label: w,
                // The first one is what the word already picks.
                style: i == 0 && token.query.isNotEmpty
                    ? FormPillStyle.selected
                    : FormPillStyle.normal,
                onTap: () => onPick(
                  marker +
                      (token.kind == FastTokenKind.date
                          ? w
                          : FastInputParser.tokenFor(w)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

enum _ChipKind { understood, problem, created }

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool strong;
  final _ChipKind kind;
  final VoidCallback? onTap;

  const _Chip({
    required this.label,
    this.icon,
    this.strong = false,
    this.kind = _ChipKind.understood,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final (Color bg, Color fg, BoxBorder? border) = switch (kind) {
      _ChipKind.understood => (s.primaryContainer, s.onPrimaryContainer, null),
      _ChipKind.created => (s.tertiaryContainer, s.onTertiaryContainer, null),
      _ChipKind.problem => (
        Colors.transparent,
        s.error,
        Border.all(color: s.error),
      ),
    };
    final chip = Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        border: border,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: fg,
                fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: chip,
      ),
    );
  }
}

/// Colors the `@`, `#` and `+` words as they are typed, red when they
/// can't be understood.
class _MarkedTextController extends TextEditingController {
  Set<String> invalidWords = const {};

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final s = Theme.of(context).colorScheme;
    final spans = <TextSpan>[];
    text.splitMapJoin(
      RegExp(r'\S+'),
      onMatch: (m) {
        final w = m[0]!;
        final marked =
            w.length > 1 &&
            (w.startsWith('@') || w.startsWith('#') || w.startsWith('+'));
        spans.add(
          TextSpan(
            text: w,
            style: marked
                ? TextStyle(
                    color: invalidWords.contains(w) ? s.error : s.primary,
                    fontWeight: FontWeight.w700,
                  )
                : null,
          ),
        );
        return w;
      },
      onNonMatch: (gap) {
        spans.add(TextSpan(text: gap));
        return gap;
      },
    );
    return TextSpan(style: style, children: spans);
  }
}
