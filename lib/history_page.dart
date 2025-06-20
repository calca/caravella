import 'package:flutter/material.dart';
import 'viaggi_storage.dart';
import 'viaggio_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Viaggio>> _viaggiFuture;

  @override
  void initState() {
    super.initState();
    _viaggiFuture = ViaggiStorage.readViaggi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storico viaggi')),
      body: FutureBuilder<List<Viaggio>>(
        future: _viaggiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessun viaggio presente'));
          }
          final viaggi = snapshot.data!;
          return ListView.builder(
            itemCount: viaggi.length,
            itemBuilder: (context, index) {
              final viaggio = viaggi[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(viaggio.titolo),
                  subtitle: Text(
                    'Dal ${viaggio.dataInizio.day}/${viaggio.dataInizio.month}/${viaggio.dataInizio.year} al ${viaggio.dataFine.day}/${viaggio.dataFine.month}/${viaggio.dataFine.year}\nPartecipanti: ${viaggio.partecipanti.join(", ")}',
                  ),
                  trailing: Text(
                    'Spese: ${viaggio.spese.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViaggioDetailPage(viaggio: viaggio),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
