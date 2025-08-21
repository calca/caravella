import 'package:flutter/material.dart';

class CurrencySelectorSheet extends StatelessWidget {
  const CurrencySelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final currencies = const [
      {'symbol': '€', 'code': 'EUR', 'name': 'Euro'},
      {'symbol': '£', 'code': 'GBP', 'name': 'Sterlina'},
      {'symbol': r'$', 'code': 'USD', 'name': 'Dollaro USA'},
    ];
    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (c, i) => ListTile(
          leading: const Icon(Icons.account_balance_wallet_outlined),
          title: Text(currencies[i]['name']!),
          subtitle: Text(
            '${currencies[i]['symbol']} 0   ${currencies[i]['code']}',
          ),
          onTap: () {
            Navigator.pop<Map<String, String>>(context, currencies[i]);
          },
        ),
        separatorBuilder: (context, index) => const Divider(height: 0),
        itemCount: currencies.length,
      ),
    );
  }
}
