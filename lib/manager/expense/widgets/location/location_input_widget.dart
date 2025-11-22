import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../expense_form/icon_leading_field.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'location_service.dart';
import 'location_widget_constants.dart';

class LocationInputWidget extends StatefulWidget {
  final ExpenseLocation? initialLocation;
  final TextStyle? textStyle;
  final Function(ExpenseLocation?) onLocationChanged;
  final FocusNode? externalFocusNode;
  final bool autoRetrieve;
  final Function(bool)? onRetrievalStatusChanged;

  const LocationInputWidget({
    super.key,
    this.initialLocation,
    this.textStyle,
    required this.onLocationChanged,
    this.externalFocusNode,
    this.autoRetrieve = false,
    this.onRetrievalStatusChanged,
  });

  @override
  State<LocationInputWidget> createState() => _LocationInputWidgetState();
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isGettingLocation = false;
  ExpenseLocation? _currentLocation;
  late final FocusNode _fieldFocusNode;

  @override
  void initState() {
    super.initState();
    _fieldFocusNode = widget.externalFocusNode ?? FocusNode();
    _currentLocation = widget.initialLocation;
    if (_currentLocation != null) {
      _controller.text = _currentLocation!.displayText;
    } else if (widget.autoRetrieve) {
      // Auto-retrieve location if enabled and no initial location
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
      });
    }
  }

  @override
  void didUpdateWidget(LocationInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal state if initialLocation changes externally
    if (widget.initialLocation != oldWidget.initialLocation) {
      _currentLocation = widget.initialLocation;
      _controller.text = _currentLocation?.displayText ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (widget.externalFocusNode == null) {
      _fieldFocusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });
    widget.onRetrievalStatusChanged?.call(true);

    final location = await LocationService.getCurrentLocation(
      context,
      resolveAddress: true,
      onStatusChanged: (status) {
        if (mounted) {
          setState(() {
            _isGettingLocation = status;
          });
          widget.onRetrievalStatusChanged?.call(status);
        }
      },
    );

    if (location != null && mounted) {
      setState(() {
        _currentLocation = location;
        _controller.text = location.displayText.isNotEmpty
            ? location.displayText
            : '${location.latitude!.toStringAsFixed(6)}, ${location.longitude!.toStringAsFixed(6)}';
      });

      // Optional lightweight feedback when an address gets resolved
      if (location.address != null) {
        final gloc = gen.AppLocalizations.of(context);
        final messenger = ScaffoldMessenger.of(context);
        AppToast.showFromMessenger(
          messenger,
          gloc.address_resolved,
          duration: const Duration(seconds: 2),
        );
      }

      widget.onLocationChanged(location);
    }

    if (mounted) {
      setState(() {
        _isGettingLocation = false;
      });
      widget.onRetrievalStatusChanged?.call(false);
    }
  }

  void _clearLocation() {
    setState(() {
      _currentLocation = null;
      _controller.clear();
    });
    widget.onLocationChanged(null);
  }

  void _onTextChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      // Preserve nothing if user clears completely
      _currentLocation = null;
      widget.onLocationChanged(null);
      return;
    }
    // If we already have coordinates, keep them and treat user text as refined address
    if (_currentLocation != null &&
        _currentLocation!.latitude != null &&
        _currentLocation!.longitude != null) {
      final updated = _currentLocation!.copyWith(address: trimmed, name: null);
      setState(() => _currentLocation = updated);
      widget.onLocationChanged(updated);
    } else {
      final location = ExpenseLocation(name: trimmed);
      setState(() => _currentLocation = location);
      widget.onLocationChanged(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final field = TextFormField(
      controller: _controller,
      focusNode: _fieldFocusNode,
      style: widget.textStyle ?? FormTheme.getFieldTextStyle(context),
      onChanged: _onTextChanged,
      decoration: InputDecoration(
        hintText: _isGettingLocation
            ? gloc.getting_location
            : gloc.location_hint,
        border: InputBorder.none,
        isDense: true,
        contentPadding: FormTheme.standardContentPadding,
        suffixIconConstraints: const BoxConstraints(
          minHeight: 32,
          minWidth: 32,
        ),
        suffixIcon: _buildSuffixIcons(context, gloc),
      ),
    );

    return IconLeadingField(
      icon: const Icon(Icons.place_outlined),
      semanticsLabel: gloc.location,
      tooltip: gloc.location,
      alignTop: false,
      iconPadding: FormTheme.standardIconPadding,
      child: field,
    );
  }

  Widget _buildSuffixIcons(BuildContext context, gen.AppLocalizations gloc) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildAction({
      required IconData icon,
      required String tooltip,
      required VoidCallback onTap,
      required Color color,
    }) {
      return Semantics(
        button: true,
        label: tooltip,
        hint: 'Double tap to $tooltip',
        child: Tooltip(
          message: tooltip,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Icon(
                  icon,
                  size: LocationWidgetConstants.iconSize,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_isGettingLocation) {
      return Semantics(
        liveRegion: true,
        label: gloc.get_current_location,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: LocationWidgetConstants.loaderSize,
            height: LocationWidgetConstants.loaderSize,
            child: CircularProgressIndicator(
              strokeWidth: LocationWidgetConstants.loaderStrokeWidth,
              color: colorScheme.primary,
              semanticsLabel: 'Getting your current location',
            ),
          ),
        ),
      );
    }

    final actions = <Widget>[
      buildAction(
        icon: LocationWidgetConstants.loadingIcon,
        tooltip: gloc.get_current_location,
        onTap: _getCurrentLocation,
        color: colorScheme.primary,
      ),
      if (_currentLocation != null)
        buildAction(
          icon: LocationWidgetConstants.clearIcon,
          tooltip: gloc.cancel,
          onTap: _clearLocation,
          color: colorScheme.onSurfaceVariant,
        ),
      if (_currentLocation != null)
        buildAction(
          icon: Icons.edit_location_alt_outlined,
          tooltip: gloc.enter_location_manually,
          onTap: () {
            // Allow manual refinement while keeping stored lat/long in _currentLocation
            _controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controller.text.length,
            );
            _fieldFocusNode.requestFocus();
          },
          color: colorScheme.onSurfaceVariant,
        ),
    ];

    return Row(mainAxisSize: MainAxisSize.min, children: actions);
  }
}
