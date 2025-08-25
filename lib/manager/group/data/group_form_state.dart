import '../../../data/model/expense_participant.dart';
import '../../../data/model/expense_category.dart';
import 'package:flutter/foundation.dart';

class GroupFormState extends ChangeNotifier {
  String id = '';
  String title = '';
  final List<ExpenseParticipant> participants = [];
  final List<ExpenseCategory> categories = [];
  DateTime? startDate;
  DateTime? endDate;
  String? imagePath;
  int? color;
  Map<String, String> currency = const {
    'symbol': '€',
    'code': 'EUR',
    'name': 'Euro',
  };
  bool loadingImage = false;
  bool isSaving = false;

  bool get isBusy => loadingImage || isSaving;

  bool get isValid => title.trim().isNotEmpty && participants.isNotEmpty;

  void setTitle(String v) {
    if (title == v) return;
    title = v;
    notifyListeners();
  }

  void addParticipant(ExpenseParticipant p) {
    participants.add(p);
    notifyListeners();
  }

  void editParticipant(int i, String name) {
    participants[i] = participants[i].copyWith(name: name);
    notifyListeners();
  }

  void removeParticipant(int i) {
    participants.removeAt(i);
    notifyListeners();
  }

  void addCategory(ExpenseCategory c) {
    categories.add(c);
    notifyListeners();
  }

  void editCategory(int i, String name) {
    categories[i] = categories[i].copyWith(name: name);
    notifyListeners();
  }

  void removeCategory(int i) {
    categories.removeAt(i);
    notifyListeners();
  }

  void setDates({DateTime? start, DateTime? end}) {
    startDate = start;
    endDate = end;
    notifyListeners();
  }

  void clearDates() {
    startDate = null;
    endDate = null;
    notifyListeners();
  }

  void setCurrency(Map<String, String> c) {
    currency = c;
    notifyListeners();
  }

  void setColor(int? c) {
    color = c;
    if (c != null) imagePath = null;
    notifyListeners();
  }

  void setImage(String? path) {
    imagePath = path;
    if (path != null) color = null;
    notifyListeners();
  }

  void setLoading(bool v) {
    if (loadingImage == v) return;
    loadingImage = v;
    notifyListeners();
  }

  void setSaving(bool v) {
    if (isSaving == v) return;
    isSaving = v;
    notifyListeners();
  }

  void refresh() => notifyListeners();
}
