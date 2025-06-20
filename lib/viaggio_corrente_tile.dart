import 'package:flutter/material.dart';
import 'viaggio_detail_page.dart';
import 'viaggi_storage.dart';

class ViaggioCorrenteTile extends StatelessWidget {
  const ViaggioCorrenteTile({super.key});

  Future<Viaggio?> _getViaggioCorrente() async {
    final viaggi = await ViaggiStorage.readViaggi();
    if (viaggi.isEmpty) return null;
    viaggi.sort((a, b) => b.dataInizio.compareTo(a.dataInizio));
    return viaggi.first;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Viaggio?>(
      future: _getViaggioCorrente(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final viaggio = snapshot.data;
        if (viaggio == null) {
          return FractionallySizedBox(
            widthFactor: 0.8,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text('Nessun viaggio presente', style: TextStyle(fontSize: 18)),
            ),
          );
        }
        final totaleSpeso = viaggio.spese.fold<double>(0, (sum, s) => sum + s.importo);
        return FractionallySizedBox(
          widthFactor: 0.8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viaggio.titolo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Totale speso:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        '€ ${totaleSpeso.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.deepPurple, size: 32),
                      tooltip: 'Aggiungi spesa',
                      onPressed: () async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                              left: 16,
                              right: 16,
                              top: 24,
                            ),
                            child: AddSpesaSheet(
                              partecipanti: viaggio.partecipanti,
                              onSpesaAdded: (spesa) async {
                                final viaggi = await ViaggiStorage.readViaggi();
                                final idx = viaggi.indexWhere((v) =>
                                  v.titolo == viaggio.titolo &&
                                  v.dataInizio == viaggio.dataInizio &&
                                  v.dataFine == viaggio.dataFine
                                );
                                if (idx != -1) {
                                  viaggi[idx].spese.add(spesa);
                                  await ViaggiStorage.writeViaggi(viaggi);
                                  // Forza il refresh della tile
                                  (context as Element).markNeedsBuild();
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
