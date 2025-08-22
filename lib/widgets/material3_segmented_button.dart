import 'package:flutter/material.dart';

/// A Material 3 segmented button implementation that provides proper styling
/// and behavior according to M3 design specifications.
/// 
/// This widget wraps the native Flutter SegmentedButton with consistent
/// styling that matches the app's Material 3 theme.
class Material3SegmentedButton<T> extends StatelessWidget {
  /// The segments to display
  final Set<ButtonSegment<T>> segments;
  
  /// The currently selected values
  final Set<T> selected;
  
  /// Called when the selection changes
  final ValueChanged<Set<T>>? onSelectionChanged;
  
  /// Whether multiple selections are allowed
  final bool multiSelectionEnabled;
  
  /// Whether empty selection is allowed
  final bool emptySelectionAllowed;
  
  /// Style for the segmented button
  final ButtonStyle? style;
  
  /// Whether the button should expand to fill available width
  final bool expandedWidth;

  const Material3SegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.style,
    this.expandedWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Create Material 3 compliant style
    final segmentedButtonStyle = style ?? SegmentedButton.styleFrom(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      selectedBackgroundColor: colorScheme.secondaryContainer,
      selectedForegroundColor: colorScheme.onSecondaryContainer,
      side: BorderSide(color: colorScheme.outline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      textStyle: theme.textTheme.labelLarge,
    );

    final segmentedButton = SegmentedButton<T>(
      segments: segments,
      selected: selected,
      onSelectionChanged: onSelectionChanged,
      multiSelectionEnabled: multiSelectionEnabled,
      emptySelectionAllowed: emptySelectionAllowed,
      style: segmentedButtonStyle,
    );

    if (expandedWidth) {
      return SizedBox(
        width: double.infinity,
        child: segmentedButton,
      );
    }

    return segmentedButton;
  }
}

/// Extension to provide common segment creation patterns
extension Material3SegmentHelpers on Material3SegmentedButton {
  /// Creates a segment with text and optional icon
  static ButtonSegment<T> createSegment<T>({
    required T value,
    required String label,
    IconData? icon,
    String? tooltip,
    bool enabled = true,
  }) {
    return ButtonSegment<T>(
      value: value,
      label: Text(label),
      icon: icon != null ? Icon(icon) : null,
      tooltip: tooltip,
      enabled: enabled,
    );
  }

  /// Creates a set of text-only segments from a map
  static Set<ButtonSegment<T>> createTextSegments<T>(
    Map<T, String> options, {
    Map<T, String>? tooltips,
    Set<T>? disabledValues,
  }) {
    return options.entries.map((entry) {
      return ButtonSegment<T>(
        value: entry.key,
        label: Text(entry.value),
        tooltip: tooltips?[entry.key],
        enabled: disabledValues?.contains(entry.key) != true,
      );
    }).toSet();
  }

  /// Creates a set of icon-only segments from a map
  static Set<ButtonSegment<T>> createIconSegments<T>(
    Map<T, IconData> options, {
    Map<T, String>? tooltips,
    Set<T>? disabledValues,
  }) {
    return options.entries.map((entry) {
      return ButtonSegment<T>(
        value: entry.key,
        icon: Icon(entry.value),
        tooltip: tooltips?[entry.key],
        enabled: disabledValues?.contains(entry.key) != true,
      );
    }).toSet();
  }
}