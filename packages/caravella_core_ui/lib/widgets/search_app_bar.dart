import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/form_theme.dart';

/// Flat app bar hosting an inline search text field in a pill-shaped
/// background, with a transparent status bar tuned to the current theme.
class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final Widget? suffixIcon;
  final bool autofocus;

  const SearchAppBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.focusNode,
    this.suffixIcon,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final appBarColor = FormTheme.getGmailAppBarSearchBackground(colorScheme);

    return AppBar(
      backgroundColor: appBarColor,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      title: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: FormTheme.getSearchPillDecoration(
            backgroundColor: appBarColor,
            hintText: hintText,
            suffixIcon: suffixIcon,
          ),
          onChanged: onChanged,
          cursorColor: colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
