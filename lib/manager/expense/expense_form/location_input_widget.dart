import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'icon_leading_field.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:caravella_core/caravella_core.dart';

class LocationInputWidget extends StatefulWidget {
  final ExpenseLocation? initialLocation;
  final TextStyle? textStyle;
  final Function(ExpenseLocation?) onLocationChanged;
  final FocusNode? externalFocusNode;
  final bool autoRetrieve;

  const LocationInputWidget({
    super.key,
    this.initialLocation,
    this.textStyle,
    required this.onLocationChanged,
    this.externalFocusNode,
    this.autoRetrieve = false,
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
    } else if (widget.autoRetrieve) {
      // Auto-retrieve location if enabled and no initial location
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
      });
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

  Future<void> _showPlaceSearch() async {
    final gloc = gen.AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Show dialog with place search
    final result = await showDialog<NominatimPlace>(
      context: context,
      builder: (ctx) => _PlaceSearchDialog(
        hintText: gloc.search_place_hint,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _isResolvingAddress = true;
      });

      try {
        final location = ExpenseLocation(
          latitude: result.latitude,
          longitude: result.longitude,
          address: result.displayName,
        );

        setState(() {
          _currentLocation = location;
          _controller.text = location.displayText;
          _isResolvingAddress = false;
        });

        widget.onLocationChanged(location);

        if (mounted) {
          AppToast.showFromMessenger(
            messenger,
            gloc.address_resolved,
            duration: const Duration(seconds: 2),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isResolvingAddress = false;
          });
          AppToast.showFromMessenger(
            messenger,
            gloc.location_error,
            type: ToastType.error,
          );
        }
      }
    }
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
        icon: Icons.search_outlined,
        tooltip: gloc.search_place,
        onTap: _showPlaceSearch,
        color: colorScheme.primary,
      ),
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

/// Represents a place from OpenStreetMap Nominatim
class NominatimPlace {
  final double latitude;
  final double longitude;
  final String displayName;

  NominatimPlace({
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      latitude: double.parse(json['lat'] as String),
      longitude: double.parse(json['lon'] as String),
      displayName: json['display_name'] as String,
    );
  }
}

/// Dialog for searching places using OpenStreetMap Nominatim
class _PlaceSearchDialog extends StatefulWidget {
  final String hintText;

  const _PlaceSearchDialog({required this.hintText});

  @override
  State<_PlaceSearchDialog> createState() => _PlaceSearchDialogState();
}

class _PlaceSearchDialogState extends State<_PlaceSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<NominatimPlace> _searchResults = [];
  bool _isSearching = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      // Use Nominatim API from OpenStreetMap
      // Respecting usage policy: https://operations.osmfoundation.org/policies/nominatim/
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&limit=10'
        '&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Caravella-ExpenseTracker/1.1.0',
          'Accept-Language': 'it,en',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          _searchResults = jsonList
              .map((json) => NominatimPlace.fromJson(json))
              .toList();
          _isSearching = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Search failed: ${response.statusCode}';
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 500, maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.hintText,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _errorMessage = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _performSearch(value);
                  }
                });
              },
              onSubmitted: _performSearch,
            ),
            const SizedBox(height: 16),
            if (_isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: colorScheme.error),
                ),
              ),
            if (!_isSearching && _searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final place = _searchResults[index];
                    return ListTile(
                      leading: Icon(
                        Icons.place,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        place.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.of(context).pop(place),
                    );
                  },
                ),
              ),
            if (!_isSearching &&
                _searchResults.isEmpty &&
                _searchController.text.isNotEmpty &&
                _errorMessage.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No results found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
