import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../group_form_state.dart';

class GroupTitleField extends StatefulWidget {
  const GroupTitleField({super.key});

  @override
  State<GroupTitleField> createState() => _GroupTitleFieldState();
}

class _GroupTitleFieldState extends State<GroupTitleField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = context.read<GroupFormState>();
    _controller = TextEditingController(text: state.title);
    _controller.addListener(() => state.setTitle(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        hintText: 'Nome gruppo',
        border: InputBorder.none,
        isDense: true,
      ),
    );
  }
}
