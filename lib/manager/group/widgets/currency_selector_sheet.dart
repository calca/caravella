import 'package:flutter/material.dart';
import '../currencies.dart';
import '../../../l10n/app_localizations.dart';

class CurrencySelectorSheet extends StatelessWidget {
  const CurrencySelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Copia e ordina alfabeticamente in base al nome localizzato tramite ARB.
    final currencies = List<Map<String, String>>.from(kCurrencies)
      ..sort((a, b) {
        final aName = localizedCurrencyName(l, a['code']!);
        final bName = localizedCurrencyName(l, b['code']!);
        return aName.compareTo(bName);
      });
    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (c, i) => ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: Text(localizedCurrencyName(l, currencies[i]['code']!)),
          subtitle: Text(
            '${currencies[i]['symbol']} 0   ${currencies[i]['code']}',
          ),
          onTap: () {
            final selected = Map<String, String>.from(currencies[i]);
            selected['name'] = localizedCurrencyName(l, currencies[i]['code']!);
            Navigator.pop<Map<String, String>>(context, selected);
          },
        ),
        separatorBuilder: (context, index) => const Divider(height: 0),
        itemCount: currencies.length,
      ),
    );
  }
}
