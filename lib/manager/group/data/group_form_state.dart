import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/foundation.dart';

class GroupFormState extends ChangeNotifier {
  String title = '';
  String? id;
  ExpenseGroup? originalGroup;
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
  ExpenseGroupType? groupType = ExpenseGroupType.personal;
  bool autoLocationEnabled = false;
  bool loadingImage = false;
  bool isSaving = false;

  bool get isBusy => loadingImage || isSaving;

  bool get _hasPartialDates =>
      (startDate != null && endDate == null) ||
      (startDate == null && endDate != null);

  bool get isValid =>
      title.trim().isNotEmpty &&
      participants.isNotEmpty &&
      categories.isNotEmpty &&
      !_hasPartialDates;

  void setTitle(String v) {
    if (title == v) return;
    title = v;
    notifyListeners();
  }

  void setId(String? v) {
    if (id == v) return;
    id = v;
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

  void setGroupType(ExpenseGroupType? type) {
    groupType = type;
    notifyListeners();
  }

  void setColor(int? c) {
    color = c;
    if (c != null) imagePath = null;
    notifyListeners();
  }

  void setAutoLocationEnabled(bool enabled) {
    if (autoLocationEnabled == enabled) return;
    autoLocationEnabled = enabled;
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

  /// Store or clear the original group snapshot used for diffing/restore.
  void setOriginalGroup(ExpenseGroup? g) {
    originalGroup = g;
    notifyListeners();
  }

  void refresh() => notifyListeners();
}
