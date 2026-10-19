import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:provider/provider.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../services/voice_input_service.dart';
import '../../../manager/expense/pages/expense_form_page.dart';
import '../../../services/notification_manager.dart';
import '../../home_constants.dart';

/// A microphone icon button shown next to the "Add expense" CTA on each group card.
///
/// Behaviour:
/// - Tapping starts voice recognition.
/// - If the recognised text contains sufficient data (amount + paidBy + category)
///   the expense is saved **directly** without opening any form.
/// - If any required field is missing the expense form is opened pre-filled
///   with whatever was parsed.
class GroupCardVoiceButton extends StatefulWidget {
  final ExpenseGroup group;
  final VoidCallback onExpenseAdded;

  /// Custom look (e.g. Home's quick actions): gets the start action (null
  /// while listening or processing) and the listening state. Without it the
  /// button draws its own mic icon.
  final Widget Function(
    BuildContext context,
    VoidCallback? onPressed,
    bool listening,
  )?
  builder;

  const GroupCardVoiceButton({
    super.key,
    required this.group,
    required this.onExpenseAdded,
    this.builder,
  });

  @override
  State<GroupCardVoiceButton> createState() => _GroupCardVoiceButtonState();
}

class _GroupCardVoiceButtonState extends State<GroupCardVoiceButton>
    with SingleTickerProviderStateMixin {
  final VoiceInputService _service = VoiceInputService();
  bool _isAvailable = false;
  bool _isListening = false;
  bool _isProcessing = false;
  late final AnimationController _pulseController;

  /// Live feedback for the listening panel (quick-action mode).
  final ValueNotifier<String> _partial = ValueNotifier('');
  final ValueNotifier<double> _level = ValueNotifier(0);
  NavigatorState? _panelNavigator;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Checking availability initializes speech recognition, which asks for
    // the microphone permission: a shortcut that is always on screen (Home's
    // quick actions) defers that to the first tap — startListening checks
    // again and reports "not available" if needed.
    if (widget.builder != null) {
      _isAvailable = true;
    } else {
      _checkAvailability();
    }
  }

  Future<void> _checkAvailability() async {
    final available = await _service.isAvailable();
    if (mounted) {
      setState(() => _isAvailable = available);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _partial.dispose();
    _level.dispose();
    _service.cancel();
    super.dispose();
  }

  // ── Voice flow ────────────────────────────────────────────────────────────

  Future<void> _startListening() async {
    if (_isListening || _isProcessing) return;

    setState(() {
      _isListening = true;
      _isProcessing = false;
    });
    _pulseController.repeat(reverse: true);

    final locale = Localizations.localeOf(context);
    final localeId =
        '${locale.languageCode}_${locale.countryCode ?? locale.languageCode.toUpperCase()}';

    if (widget.builder != null) _openListeningPanel();

    await _service.startListening(
      localeId: localeId,
      onPartial: (words) => _partial.value = words,
      onSoundLevel: (level) => _level.value = level,
      onResult: (text) {
        _closeListeningPanel();
        _handleResult(text);
      },
      onError: (error) {
        _closeListeningPanel();
        if (mounted) {
          _pulseController.stop();
          setState(() {
            _isListening = false;
            _isProcessing = false;
          });
          _showSnack(_getError(error));
        }
      },
      onDone: () {
        _closeListeningPanel();
        if (mounted) {
          _pulseController.stop();
          setState(() {
            _isListening = false;
            _isProcessing = false;
          });
        }
      },
    );
  }

  /// A panel from the bottom while listening: a microphone pulsing with the
  /// voice level, the words recognised so far, and Cancel.
  void _openListeningPanel() {
    _partial.value = '';
    _level.value = 0;
    final navigator = Navigator.of(context);
    _panelNavigator = navigator;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _ListeningPanel(
        partial: _partial,
        level: _level,
        onCancel: () => navigator.maybePop(),
      ),
    ).whenComplete(() {
      // Closed by the user (cancel, swipe, back): stop listening.
      if (_panelNavigator != null) {
        _panelNavigator = null;
        _service.cancel();
        if (mounted) {
          _pulseController.stop();
          setState(() {
            _isListening = false;
            _isProcessing = false;
          });
        }
      }
    });
  }

  void _closeListeningPanel() {
    final navigator = _panelNavigator;
    _panelNavigator = null;
    navigator?.maybePop();
  }

  String _getError(VoiceInputError error) {
    final gloc = gen.AppLocalizations.of(context);
    switch (error) {
      case VoiceInputError.notAvailable:
        return gloc.voice_input_not_available;
      case VoiceInputError.permissionDenied:
        return gloc.voice_input_permission_denied;
      case VoiceInputError.noSpeech:
        return gloc.voice_input_no_speech;
      case VoiceInputError.recognitionFailed:
        return gloc.voice_input_error;
    }
  }

  Future<void> _handleResult(String text) async {
    if (!mounted) return;

    _pulseController.stop();
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });

    final participants = widget.group.participants;
    final participantNames = participants.map((p) => p.name).toList();

    final parsed = VoiceInputService.parseExpenseFromText(
      text,
      participantNames: participantNames,
    );

    setState(() => _isProcessing = false);

    if (!mounted) return;

    final amount = parsed['amount'] as double?;
    final categoryKeyword = parsed['category'] as String?;
    final paidByName = parsed['paidBy'] as String?;

    // Resolve participant
    ExpenseParticipant? paidBy;
    if (paidByName != null) {
      paidBy = participants.where((p) => p.name == paidByName).firstOrNull;
    }
    paidBy ??= participants.isNotEmpty ? participants.first : null;

    // Resolve category
    final categories = widget.group.categories;
    ExpenseCategory? category;
    if (categoryKeyword != null) {
      category = categories
          .where(
            (c) =>
                c.name.toLowerCase().contains(categoryKeyword) ||
                categoryKeyword.contains(c.name.toLowerCase()),
          )
          .firstOrNull;
    }
    category ??= categories.isNotEmpty ? categories.first : null;

    final isSufficient =
        amount != null && amount > 0 && paidBy != null && category != null;

    if (isSufficient) {
      // ── Save directly ──────────────────────────────────────────────────────
      await _saveDirectly(parsed, amount, paidBy, category);
    } else {
      // ── Open pre-filled form ───────────────────────────────────────────────
      if (mounted) {
        final gloc = gen.AppLocalizations.of(context);
        _showSnack(gloc.voice_expense_needs_more_info);
        _openPreFilledForm(parsed, paidBy, category);
      }
    }
  }

  Future<void> _saveDirectly(
    Map<String, dynamic> parsed,
    double amount,
    ExpenseParticipant paidBy,
    ExpenseCategory category,
  ) async {
    if (!mounted) return;

    final gloc = gen.AppLocalizations.of(context);
    final notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);

    final expense = ExpenseDetails(
      amount: amount,
      paidBy: paidBy,
      category: category,
      date: (parsed['date'] as DateTime?) ?? DateTime.now(),
      name: parsed['name'] as String?,
      note: null,
      location: null,
    );

    await ExpenseGroupStorageV2.addExpenseToGroup(widget.group.id, expense);
    await notifier.refreshGroup();
    notifier.notifyGroupUpdated(widget.group.id);

    if (mounted) {
      await NotificationManager().updateNotificationForGroupById(
        widget.group.id,
        gloc,
      );
      _showSnack(gloc.voice_expense_saved);
    }

    RatingService.checkAndPromptForRating();
    widget.onExpenseAdded();
  }

  void _openPreFilledForm(
    Map<String, dynamic> parsed,
    ExpenseParticipant? paidBy,
    ExpenseCategory? category,
  ) {
    if (!mounted) return;

    final notifier = Provider.of<ExpenseGroupNotifier>(context, listen: false);
    final currentGroup = widget.group;
    notifier.setCurrentGroup(currentGroup);

    final partialExpense = ExpenseDetails(
      amount: parsed['amount'] as double?,
      paidBy: paidBy ?? ExpenseParticipant(name: ''),
      category: category ?? ExpenseCategory(name: ''),
      date: (parsed['date'] as DateTime?) ?? DateTime.now(),
      name: parsed['name'] as String?,
      note: null,
      location: null,
    );

    final parentContext = context;

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => Consumer<ExpenseGroupNotifier>(
              builder: (context, groupNotifier, _) {
                final group = groupNotifier.currentGroup ?? currentGroup;
                return ExpenseFormPage(
                  group: group,
                  initialExpense: partialExpense,
                  onExpenseSaved: (expense) async {
                    final expenseWithId = expense.copyWith(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                    );
                    await ExpenseGroupStorageV2.addExpenseToGroup(
                      group.id,
                      expenseWithId,
                    );
                    await groupNotifier.refreshGroup();
                    groupNotifier.notifyGroupUpdated(group.id);

                    if (parentContext.mounted) {
                      final gloc = gen.AppLocalizations.of(parentContext);
                      await NotificationManager()
                          .updateNotificationForGroupById(group.id, gloc);
                    }

                    RatingService.checkAndPromptForRating();
                    widget.onExpenseAdded();
                  },
                  onCategoryAdded: (name) async {
                    await notifier.addCategory(name);
                  },
                  onParticipantAdded: (name) async {
                    await notifier.addParticipant(name);
                  },
                );
              },
            ),
          ),
        )
        .whenComplete(() => notifier.clearCurrentGroup());
  }

  void _showSnack(String message) {
    if (!mounted) return;
    AppToast.show(context, message, duration: const Duration(seconds: 3));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) return const SizedBox.shrink();
    if (widget.builder case final builder?) {
      return builder(
        context,
        (_isListening || _isProcessing) ? null : _startListening,
        _isListening || _isProcessing,
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);

    return Tooltip(
      message: gloc.voice_add_expense,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = _isListening
              ? 1.0 + (_pulseController.value * 0.12)
              : 1.0;
          return Transform.scale(scale: scale, child: child);
        },
        child: SizedBox(
          height: HomeLayoutConstants.buttonBorderRadius * 2 + 16,
          child: IconButton(
            onPressed: (_isListening || _isProcessing) ? null : _startListening,
            icon: _buildIcon(colorScheme),
            style: IconButton.styleFrom(
              backgroundColor: _isListening
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              foregroundColor: _isListening
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    if (_isProcessing) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      );
    }
    return Icon(_isListening ? Icons.mic : Icons.mic_none_outlined, size: 22);
  }
}

class _ListeningPanel extends StatelessWidget {
  final ValueListenable<String> partial;
  final ValueListenable<double> level;
  final VoidCallback onCancel;

  const _ListeningPanel({
    required this.partial,
    required this.level,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 140,
              child: Center(
                child: ValueListenableBuilder<double>(
                  valueListenable: level,
                  builder: (context, value, child) {
                    // Sound level is roughly -2..10 dB: map to a halo scale.
                    final t = ((value + 2) / 12).clamp(0.0, 1.0);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: 88 + 48 * t,
                          height: 88 + 48 * t,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child!,
                      ],
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.primary,
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      size: 40,
                      color: s.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
            Semantics(
              liveRegion: true,
              child: Text(
                gloc.voice_input_listening,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String>(
              valueListenable: partial,
              builder: (context, words, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  words.isEmpty ? gloc.voice_input_hint : words,
                  key: ValueKey(words.isEmpty),
                  textAlign: TextAlign.center,
                  style: words.isEmpty
                      ? theme.textTheme.bodyMedium?.copyWith(
                          color: s.onSurfaceVariant,
                        )
                      : theme.textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(onPressed: onCancel, child: Text(gloc.cancel)),
          ],
        ),
      ),
    );
  }
}
