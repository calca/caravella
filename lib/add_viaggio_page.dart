import 'package:flutter/material.dart';
import 'viaggi_storage.dart';

class AddViaggioPage extends StatefulWidget {
  final Viaggio? viaggio;
  const AddViaggioPage({super.key, this.viaggio});

  @override
  State<AddViaggioPage> createState() => _AddViaggioPageState();
}

class _AddViaggioPageState extends State<AddViaggioPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titoloController = TextEditingController();
  final TextEditingController _partecipantiController = TextEditingController();
  DateTime? _dataInizio;
  DateTime? _dataFine;

  @override
  void initState() {
    super.initState();
    if (widget.viaggio != null) {
      _titoloController.text = widget.viaggio!.titolo;
      _partecipantiController.text = widget.viaggio!.partecipanti.join(', ');
      _dataInizio = widget.viaggio!.dataInizio;
      _dataFine = widget.viaggio!.dataFine;
    }
  }

  Future<void> _pickDate(BuildContext context, bool isInizio) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isInizio) {
          _dataInizio = picked;
        } else {
          _dataFine = picked;
        }
      });
    }
  }

  Future<void> _saveViaggio() async {
    if (!_formKey.currentState!.validate() || _dataInizio == null || _dataFine == null) return;
    final partecipanti = _partecipantiController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (widget.viaggio != null) {
      // MODIFICA: aggiorna viaggio esistente
      final viaggi = await ViaggiStorage.readViaggi();
      final idx = viaggi.indexWhere((v) =>
        v.titolo == widget.viaggio!.titolo &&
        v.dataInizio == widget.viaggio!.dataInizio &&
        v.dataFine == widget.viaggio!.dataFine
      );
      if (idx != -1) {
        viaggi[idx] = Viaggio(
          titolo: _titoloController.text,
          spese: viaggi[idx].spese, // mantiene le spese
          partecipanti: partecipanti,
          dataInizio: _dataInizio!,
          dataFine: _dataFine!,
        );
        await ViaggiStorage.writeViaggi(viaggi);
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
    }
    // CREAZIONE: aggiungi nuovo viaggio
    final nuovoViaggio = Viaggio(
      titolo: _titoloController.text,
      spese: [],
      partecipanti: partecipanti,
      dataInizio: _dataInizio!,
      dataFine: _dataFine!,
    );
    final viaggi = await ViaggiStorage.readViaggi();
    viaggi.add(nuovoViaggio);
    await ViaggiStorage.writeViaggi(viaggi);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aggiungi viaggio')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titoloController,
                decoration: const InputDecoration(labelText: 'Titolo viaggio'),
                validator: (v) => v == null || v.isEmpty ? 'Inserisci un titolo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _partecipantiController,
                decoration: const InputDecoration(
                  labelText: 'Partecipanti (separati da virgola)',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Inserisci almeno un partecipante' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(_dataInizio == null
                        ? 'Data inizio non selezionata'
                        : 'Inizio: ${_dataInizio!.day}/${_dataInizio!.month}/${_dataInizio!.year}'),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(context, true),
                    child: const Text('Seleziona inizio'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(_dataFine == null
                        ? 'Data fine non selezionata'
                        : 'Fine: ${_dataFine!.day}/${_dataFine!.month}/${_dataFine!.year}'),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(context, false),
                    child: const Text('Seleziona fine'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveViaggio,
                child: const Text('Salva'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
