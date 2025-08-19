import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../app_localizations.dart';
import '../../../data/expense_location.dart';

class LocationInputWidget extends StatefulWidget {
  final ExpenseLocation? initialLocation;
  final AppLocalizations loc;
  final TextStyle? textStyle;
  final Function(ExpenseLocation?) onLocationChanged;

  const LocationInputWidget({
    super.key,
    this.initialLocation,
    required this.loc,
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
            SnackBar(content: Text(widget.loc.get('location_service_disabled'))),
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
              SnackBar(content: Text(widget.loc.get('location_permission_denied'))),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.loc.get('location_permission_denied'))),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      
      final location = ExpenseLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        name: '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
      );

      setState(() {
        _currentLocation = location;
        _controller.text = location.displayText;
      });

      widget.onLocationChanged(location);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.loc.get('location_error'))),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.loc.get('location'),
                style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall,
              ),
            ),
            // Pulsante per ottenere posizione corrente
            IconButton(
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              icon: _isGettingLocation
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.my_location,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              tooltip: widget.loc.get('get_current_location'),
            ),
            // Pulsante per pulire
            if (_currentLocation != null)
              IconButton(
                onPressed: _clearLocation,
                icon: Icon(
                  Icons.clear,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                tooltip: widget.loc.get('cancel'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          style: widget.textStyle ?? Theme.of(context).textTheme.bodySmall,
          decoration: InputDecoration(
            hintText: widget.loc.get('location_hint'),
            hintStyle: widget.textStyle?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ) ??
                Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
            border: const OutlineInputBorder(),
            suffixIcon: _isGettingLocation
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : null,
          ),
          onChanged: _onTextChanged,
        ),
      ],
    );
  }
}