import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'icon_leading_field.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:caravella_core/caravella_core.dart';

class LocationInputWidget extends StatefulWidget {
  final ExpenseLocation? initialLocation;
  final TextStyle? textStyle;
  final Function(ExpenseLocation?) onLocationChanged;
  final FocusNode? externalFocusNode;

  const LocationInputWidget({
    super.key,
    this.initialLocation,
    this.textStyle,
    required this.onLocationChanged,
    this.externalFocusNode,
  });

  @override
  State<LocationInputWidget> createState() => _LocationInputWidgetState();
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isGettingLocation = false;
  bool _isResolvingAddress = false;
  ExpenseLocation? _currentLocation;
  late final FocusNode _fieldFocusNode;

  @override
  void initState() {
    super.initState();
    _fieldFocusNode = widget.externalFocusNode ?? FocusNode();
    _currentLocation = widget.initialLocation;
    if (_currentLocation != null) {
      _controller.text = _currentLocation!.displayText;
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
    // Capture messenger before any async gaps to avoid using BuildContext after awaits
    final messenger = ScaffoldMessenger.of(context);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          AppToast.showFromMessenger(
            messenger,
            gen.AppLocalizations.of(context).location_service_disabled,
            type: ToastType.info,
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            AppToast.showFromMessenger(
              messenger,
              gen.AppLocalizations.of(context).location_permission_denied,
              type: ToastType.info,
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          AppToast.showFromMessenger(
            messenger,
            gen.AppLocalizations.of(context).location_permission_denied,
            type: ToastType.info,
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      if (mounted) {
        setState(() => _isResolvingAddress = true);
      }

      // Reverse geocoding to human-readable address
      String? address;
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            if ((p.thoroughfare ?? '').isNotEmpty) p.thoroughfare,
            if ((p.subThoroughfare ?? '').isNotEmpty) p.subThoroughfare,
            if ((p.locality ?? '').isNotEmpty) p.locality,
            if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea,
            if ((p.country ?? '').isNotEmpty) p.country,
          ].whereType<String>().where((e) => e.trim().isNotEmpty).toList();
          if (parts.isNotEmpty) {
            address = parts.join(', ');
          }
        }
      } catch (_) {
        // Ignore reverse geocoding failure; fallback below
      }

      final location = ExpenseLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      setState(() {
        _currentLocation = location;
        _controller.text = location.displayText.isNotEmpty
            ? location.displayText
            : '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        _isResolvingAddress = false;
      });

      // Optional lightweight feedback when an address gets resolved
      if (address != null && mounted) {
        final gloc = gen.AppLocalizations.of(context);
        AppToast.showFromMessenger(
          messenger,
          gloc.address_resolved,
          duration: const Duration(seconds: 2),
        );
      }

      widget.onLocationChanged(location);
    } catch (e) {
      if (mounted) {
        AppToast.showFromMessenger(
          messenger,
          gen.AppLocalizations.of(context).location_error,
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
          _isResolvingAddress = false;
        });
      }
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
            : _isResolvingAddress
            ? gloc.resolving_address
            : gloc.location_hint,
        // rely on theme hintStyle
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
              child: Center(child: Icon(icon, size: 20, color: color)),
            ),
          ),
        ),
      );
    }

    if (_isGettingLocation || _isResolvingAddress) {
      return Semantics(
        liveRegion: true,
        label: _isGettingLocation
            ? gloc.get_current_location
            : 'Resolving address',
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
              semanticsLabel: _isGettingLocation
                  ? 'Getting your current location'
                  : 'Resolving address from coordinates',
            ),
          ),
        ),
      );
    }

    final actions = <Widget>[
      buildAction(
        icon: Icons.my_location_outlined,
        tooltip: gloc.get_current_location,
        onTap: _getCurrentLocation,
        color: colorScheme.primary,
      ),
      if (_currentLocation != null)
        buildAction(
          icon: Icons.clear,
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
