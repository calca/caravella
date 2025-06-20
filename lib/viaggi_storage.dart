import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Viaggio {
  final String titolo;
  final List<Spesa> spese;
  final List<String> partecipanti;
  final DateTime dataInizio;
  final DateTime dataFine;

  Viaggio({
    required this.titolo,
    required this.spese,
    required this.partecipanti,
    required this.dataInizio,
    required this.dataFine,
  });

  factory Viaggio.fromJson(Map<String, dynamic> json) {
    return Viaggio(
      titolo: json['titolo'],
      spese: (json['spese'] as List<dynamic>?)?.map((e) => Spesa.fromJson(e)).toList() ?? [],
      partecipanti: List<String>.from(json['partecipanti'] ?? []),
      dataInizio: DateTime.parse(json['dataInizio']),
      dataFine: DateTime.parse(json['dataFine']),
    );
  }

  Map<String, dynamic> toJson() => {
        'titolo': titolo,
        'spese': spese.map((e) => e.toJson()).toList(),
        'partecipanti': partecipanti,
        'dataInizio': dataInizio.toIso8601String(),
        'dataFine': dataFine.toIso8601String(),
      };
}

class Spesa {
  final String descrizione;
  final double importo;
  final String pagatoDa;
  final DateTime data;

  Spesa({
    required this.descrizione,
    required this.importo,
    required this.pagatoDa,
    required this.data,
  });

  factory Spesa.fromJson(Map<String, dynamic> json) {
    return Spesa(
      descrizione: json['descrizione'],
      importo: (json['importo'] as num).toDouble(),
      pagatoDa: json['pagatoDa'],
      data: DateTime.parse(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
        'descrizione': descrizione,
        'importo': importo,
        'pagatoDa': pagatoDa,
        'data': data.toIso8601String(),
      };
}

class ViaggiStorage {
  static const String fileName = 'viaggi.json';

  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  static Future<List<Viaggio>> readViaggi() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((e) => Viaggio.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> writeViaggi(List<Viaggio> viaggi) async {
    final file = await _getFile();
    final jsonList = viaggi.map((v) => v.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }
}
