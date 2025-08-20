import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import 'icon_leading_field.dart';
import '../../../data/expense_location.dart';

class LocationInputWidget extends StatefulWidget {
  final ExpenseLocation? initialLocation;
  final TextStyle? textStyle;
  final Function(ExpenseLocation?) onLocationChanged;

  const LocationInputWidget({
    super.key,
    this.initialLocation,
    this.textStyle,
    required this.onLocationChanged,
  });

  @override
  State<LocationInputWidget> createState() => _LocationInputWidgetState();
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isGettingLocation = false;
  ExpenseLocation? _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
    if (_currentLocation != null) {
      _controller.text = _currentLocation!.displayText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                gen.AppLocalizations.of(context).location_service_disabled,
              ),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  gen.AppLocalizations.of(context).location_permission_denied,
                ),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                gen.AppLocalizations.of(context).location_permission_denied,
              ),
            ),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      final location = ExpenseLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        name:
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
      );

      setState(() {
        _currentLocation = location;
        _controller.text = location.displayText;
      });

      widget.onLocationChanged(location);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(gen.AppLocalizations.of(context).location_error),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
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
    if (value.trim().isEmpty) {
      _currentLocation = null;
      widget.onLocationChanged(null);
    } else {
      final location = ExpenseLocation(name: value.trim());
      setState(() {
        _currentLocation = location;
      });
      widget.onLocationChanged(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final field = TextFormField(
      controller: _controller,
      style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall,
      onChanged: _onTextChanged,
      decoration: InputDecoration(
        hintText: gloc.location_hint,
  // rely on theme hintStyle
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        suffixIconConstraints: const BoxConstraints(minHeight: 32, minWidth: 32),
        suffixIcon: _buildSuffixIcons(context, gloc),
      ),
    );

    return IconLeadingField(
      icon: const Icon(Icons.place_outlined),
      semanticsLabel: gloc.location,
      tooltip: gloc.location,
      alignTop: false,
      iconPadding: const EdgeInsets.only(top: 8, bottom: 8, right: 6),
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
      return Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: Icon(icon, size: 20, color: color),
            ),
          ),
        ),
      );
    }

    if (_isGettingLocation) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colorScheme.primary,
          ),
        ),
      );
    }

    final actions = <Widget>[
      buildAction(
        icon: Icons.my_location,
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
    ];

    return Row(mainAxisSize: MainAxisSize.min, children: actions);
  }
}
