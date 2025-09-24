import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

class GroupTitleField extends StatefulWidget {
  const GroupTitleField({super.key});

  @override
  State<GroupTitleField> createState() => _GroupTitleFieldState();
}

class _GroupTitleFieldState extends State<GroupTitleField> {
  late final TextEditingController _controller;
  late GroupFormState _state;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _state = context.read<GroupFormState>();
    _controller = TextEditingController(text: _state.title);
    _controller.addListener(() {
      if (_syncing) return; // skip updates originating from external sync
      if (_state.title != _controller.text) {
        _state.setTitle(_controller.text);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If state title changed externally (e.g., after async load), sync controller.
    final current = context.read<GroupFormState>().title;
    if (current != _controller.text) {
      _controller.text = current;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to title changes to update field when editing existing group.
    final title = context.select<GroupFormState, String>((s) => s.title);
    if (title != _controller.text) {
      _syncing = true;
      _controller.text = title;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
      _syncing = false;
    }
    return TextField(
      controller: _controller,
      style: FormTheme.getFieldTextStyle(context),
      textInputAction: TextInputAction.next,
      decoration: FormTheme.getBorderlessDecoration(
        hintText: 'Nome gruppo',
      ),
    );
  }
}
