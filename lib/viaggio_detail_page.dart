import 'package:flutter/material.dart';
import 'viaggi_storage.dart';
import 'add_viaggio_page.dart';

class ViaggioDetailPage extends StatefulWidget {
  final Viaggio viaggio;
  const ViaggioDetailPage({super.key, required this.viaggio});

  @override
  State<ViaggioDetailPage> createState() => _ViaggioDetailPageState();
}

class _ViaggioDetailPageState extends State<ViaggioDetailPage> {
  late Viaggio _viaggio;

  @override
  void initState() {
    super.initState();
    _viaggio = widget.viaggio;
  }

  Future<void> _refreshViaggio() async {
    final viaggi = await ViaggiStorage.readViaggi();
    final idx = viaggi.indexWhere((v) =>
      v.titolo == _viaggio.titolo &&
      v.dataInizio == _viaggio.dataInizio &&
      v.dataFine == _viaggio.dataFine
    );
    if (idx != -1) {
      setState(() {
        _viaggio = viaggi[idx];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_viaggio.titolo),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifica',
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddViaggioPage(
                    viaggio: _viaggio,
                  ),
                ),
              );
              if (result == true && context.mounted) {
                await _refreshViaggio();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Periodo: ${_viaggio.dataInizio.day}/${_viaggio.dataInizio.month}/${_viaggio.dataInizio.year} - ${_viaggio.dataFine.day}/${_viaggio.dataFine.month}/${_viaggio.dataFine.year}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Partecipanti: ${_viaggio.partecipanti.join(", ")}'),
            const SizedBox(height: 16),
            const Text('Spese:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: _viaggio.spese.isEmpty
                  ? const Text('Nessuna spesa inserita')
                  : ListView.builder(
                      itemCount: _viaggio.spese.length,
                      itemBuilder: (context, i) {
                        final spesa = _viaggio.spese[i];
                        return ListTile(
                          title: Text(spesa.descrizione),
                          subtitle: Text('Pagato da: ${spesa.pagatoDa}\nData: ${spesa.data.day}/${spesa.data.month}/${spesa.data.year}'),
                          trailing: Text('€ ${spesa.importo.toStringAsFixed(2)}'),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi spesa'),
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
                      partecipanti: _viaggio.partecipanti,
                      onSpesaAdded: (spesa) async {
                        final viaggi = await ViaggiStorage.readViaggi();
                        final idx = viaggi.indexWhere((v) =>
                          v.titolo == _viaggio.titolo &&
                          v.dataInizio == _viaggio.dataInizio &&
                          v.dataFine == _viaggio.dataFine
                        );
                        if (idx != -1) {
                          viaggi[idx].spese.add(spesa);
                          await ViaggiStorage.writeViaggi(viaggi);
                          await _refreshViaggio();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- SHEET PER AGGIUNTA SPESA ---
class AddSpesaSheet extends StatefulWidget {
  final List<String> partecipanti;
  final void Function(Spesa) onSpesaAdded;
  const AddSpesaSheet({super.key, required this.partecipanti, required this.onSpesaAdded});

  @override
  State<AddSpesaSheet> createState() => _AddSpesaSheetState();
}

class _AddSpesaSheetState extends State<AddSpesaSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _categoria;
  double? _importo;
  String? _pagatoDa;
  DateTime _data = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Aggiungi spesa', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Categoria'),
              validator: (v) => v == null || v.isEmpty ? 'Obbligatorio' : null,
              onSaved: (v) => _categoria = v,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Importo'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v == null || double.tryParse(v) == null ? 'Importo non valido' : null,
              onSaved: (v) => _importo = double.tryParse(v ?? ''),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Pagato da'),
              items: widget.partecipanti.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => _pagatoDa = v,
              validator: (v) => v == null ? 'Obbligatorio' : null,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annulla'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final spesa = Spesa(
                        descrizione: _categoria ?? '',
                        importo: _importo ?? 0,
                        pagatoDa: _pagatoDa ?? '',
                        data: _data,
                      );
                      widget.onSpesaAdded(spesa);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Salva'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
