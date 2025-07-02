import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../data/expense_group.dart';
import '../../data/expense_group_storage.dart';
import '../../state/locale_notifier.dart';
import 'widgets/widgets.dart';

class HomeCardsSection extends StatefulWidget {
  final VoidCallback onTripAdded;

  const HomeCardsSection({
    super.key,
    required this.onTripAdded,
  });

  @override
  State<HomeCardsSection> createState() => _HomeCardsSectionState();
}

class _HomeCardsSectionState extends State<HomeCardsSection> {
  List<ExpenseGroup> _activeGroups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveGroups();
  }

  Future<void> _loadActiveGroups() async {
    try {
      final groups = await ExpenseGroupStorage.getActiveGroups();
      if (mounted) {
        setState(() {
          _activeGroups = groups;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleNotifier.of(context)?.locale ?? 'it';
    final loc = AppLocalizations(locale);
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con avatar e saluto dinamico
          HomeCardsHeader(
            localizations: loc,
            theme: theme,
          ),

          // Content area - occupa 2/3 della pagina
          SizedBox(
            height: screenHeight * 0.67, // 2/3 della pagina
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _activeGroups.isEmpty
                    ? EmptyGroupsState(
                        localizations: loc,
                        theme: theme,
                        onGroupAdded: () {
                          widget.onTripAdded();
                          _loadActiveGroups();
                        },
                      )
                    : HorizontalGroupsList(
                        groups: _activeGroups,
                        localizations: loc,
                        theme: theme,
                        onGroupUpdated: () {
                          widget.onTripAdded();
                          _loadActiveGroups();
                        },
                      ),
          ),

          // Bottom bar semplificata
          SimpleBottomBar(
            localizations: loc,
            theme: theme,
          ),
        ],
      ),
    );
  }
}
