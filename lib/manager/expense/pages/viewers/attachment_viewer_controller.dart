import 'package:flutter/material.dart';

/// Controller for attachment viewer state management
class AttachmentViewerController extends ChangeNotifier {
  final List<String> _attachments;
  int _currentIndex;

  AttachmentViewerController({
    required List<String> attachments,
    int initialIndex = 0,
  }) : _attachments = List.from(attachments),
       _currentIndex = initialIndex;

  List<String> get attachments => List.unmodifiable(_attachments);

  int get currentIndex => _currentIndex;

  int get totalCount => _attachments.length;

  String get currentAttachment => _attachments[_currentIndex];

  bool get canNavigate => _attachments.isNotEmpty;

  void setCurrentIndex(int index) {
    if (index >= 0 && index < _attachments.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void deleteCurrentAttachment() {
    if (_attachments.isNotEmpty) {
      _attachments.removeAt(_currentIndex);

      // Adjust current index if needed
      if (_currentIndex >= _attachments.length && _attachments.isNotEmpty) {
        _currentIndex = _attachments.length - 1;
      }

      notifyListeners();
    }
  }

  bool get isEmpty => _attachments.isEmpty;
}
