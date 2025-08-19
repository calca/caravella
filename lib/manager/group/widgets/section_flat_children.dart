import 'package:flutter/material.dart';

import '../../../app_localizations.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;

class SectionFlatChildren {
  static List<Widget> basicInfo({
    required BuildContext context,
    required TextEditingController titleController,
    required FocusNode titleFocusNode,
    required bool showError,
    required String? dateError,
    required AppLocalizations loc,
    required bool isEdit,
    required void Function() onChanged,
  }) {
    return [
      Row(
        children: [
          Text(
            gen.AppLocalizations.of(context).group_name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 4),
          const Text('*', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: titleController,
        focusNode: titleFocusNode,
        autofocus: !isEdit,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        decoration: const InputDecoration(
          labelText: '',
          border: UnderlineInputBorder(),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(width: 2),
          ),
        ),
    validator: (v) =>
      v == null || v.isEmpty ? gen.AppLocalizations.of(context).enter_title : null,
        onChanged: (_) => onChanged(),
      ),
      if (showError && dateError != null)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            dateError,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 13,
            ),
          ),
        ),
    ];
  }
}
