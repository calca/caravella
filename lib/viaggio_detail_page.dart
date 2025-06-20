import 'package:flutter/material.dart';
import 'viaggi_storage.dart';

class ViaggioDetailPage extends StatelessWidget {
  final Viaggio viaggio;
  const ViaggioDetailPage({super.key, required this.viaggio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(viaggio.titolo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Periodo: ${viaggio.dataInizio.day}/${viaggio.dataInizio.month}/${viaggio.dataInizio.year} - ${viaggio.dataFine.day}/${viaggio.dataFine.month}/${viaggio.dataFine.year}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Partecipanti: ${viaggio.partecipanti.join(", ")}'),
            const SizedBox(height: 16),
            const Text('Spese:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: viaggio.spese.isEmpty
                  ? const Text('Nessuna spesa inserita')
                  : ListView.builder(
                      itemCount: viaggio.spese.length,
                      itemBuilder: (context, i) {
                        final spesa = viaggio.spese[i];
                        return ListTile(
                          title: Text(spesa.descrizione),
                          subtitle: Text('Pagato da: ${spesa.pagatoDa}\nData: ${spesa.data.day}/${spesa.data.month}/${spesa.data.year}'),
                          trailing: Text('€ ${spesa.importo.toStringAsFixed(2)}'),
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
