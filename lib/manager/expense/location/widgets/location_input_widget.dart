import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../widgets/icon_leading_field.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import '../location_service.dart';
import '../constants.dart';
import '../../pages/place_search_page.dart';

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

  Future<void> _showPlaceSearch() async {
    final gloc = gen.AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Convert current location to NominatimPlace if exists
    NominatimPlace? initialPlace;
    if (_currentLocation != null) {
      final loc = _currentLocation!;
      initialPlace = NominatimPlace(
        latitude: loc.latitude!,
        longitude: loc.longitude!,
        displayName: loc.address ?? loc.displayText,
        name: loc.name,
        road: loc.street,
        houseNumber: loc.streetNumber,
        city: loc.locality,
        state: loc.administrativeArea,
        postcode: loc.postalCode,
        country: loc.country,
        countryCode: loc.isoCountryCode,
      );
    }

    // Show dialog with place search
    final result = await PlaceSearchPage.show(
      context,
      gloc.location_hint,
      initialPlace: initialPlace,
    );

    if (result != null && mounted) {
      setState(() {
        _isResolvingAddress = true;
      });

      try {
        // Map all address details from Nominatim to ExpenseLocation
        final locality =
            result.city ?? result.town ?? result.village ?? result.municipality;

        final location = ExpenseLocation(
          latitude: result.latitude,
          longitude: result.longitude,
          address: result.displayName,
          name: result.name,
          street: result.road,
          streetNumber: result.houseNumber,
          locality: locality,
          subLocality: result.suburb,
          administrativeArea: result.state,
          postalCode: result.postcode,
          country: result.country,
          isoCountryCode: result.countryCode,
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

  void _showLocationDetails() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _LocationDetailsSheet(
        location: _currentLocation!,
        onGetCurrentLocation: () {
          Navigator.pop(context);
          _getCurrentLocation();
        },
        onSearchPlace: () {
          Navigator.pop(context);
          _showPlaceSearch();
        },
        onClearLocation: () {
          Navigator.pop(context);
          _clearLocation();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show loading indicator
    if (_isGettingLocation || _isResolvingAddress) {
      return IconLeadingField(
        icon: SizedBox(
          width: LocationConstants.loaderSize,
          height: LocationConstants.loaderSize,
          child: CircularProgressIndicator(
            strokeWidth: LocationConstants.loaderStrokeWidth,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        semanticsLabel: gloc.location,
        tooltip: gloc.location,
        alignTop: false,
        iconPadding: FormTheme.standardIconPadding,
        child: Padding(
          padding: FormTheme.standardContentPadding,
          child: Text(
            _isGettingLocation ? gloc.getting_location : gloc.address_resolved,
            style: widget.textStyle ?? FormTheme.getFieldTextStyle(context),
          ),
        ),
      );
    }

    // Show read-only locality with dropdown if location exists
    if (_currentLocation != null) {
      final displayText =
          _currentLocation!.locality ??
          _currentLocation!.address ??
          _currentLocation!.name ??
          gloc.location_hint;

      return IconLeadingField(
        icon: const Icon(Icons.place_outlined),
        semanticsLabel: gloc.location,
        tooltip: gloc.location,
        alignTop: false,
        iconPadding: FormTheme.standardIconPadding,
        child: InkWell(
          onTap: _showLocationDetails,
          child: Padding(
            padding: FormTheme.standardContentPadding,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style:
                        widget.textStyle ??
                        FormTheme.getFieldTextStyle(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show empty state with action buttons
    return IconLeadingField(
      icon: const Icon(Icons.place_outlined),
      semanticsLabel: gloc.location,
      tooltip: gloc.location,
      alignTop: false,
      iconPadding: FormTheme.standardIconPadding,
      child: InkWell(
        onTap: _showPlaceSearch,
        child: Padding(
          padding: FormTheme.standardContentPadding,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  gloc.location_hint,
                  style: FormTheme.getFieldTextStyle(
                    context,
                  )?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.my_location),
                iconSize: LocationConstants.iconSize,
                color: colorScheme.onSurfaceVariant,
                tooltip: gloc.get_current_location,
                onPressed: _getCurrentLocation,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.search,
                size: LocationConstants.iconSize,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationDetailsSheet extends StatelessWidget {
  final ExpenseLocation location;
  final VoidCallback onGetCurrentLocation;
  final VoidCallback onSearchPlace;
  final VoidCallback onClearLocation;

  const _LocationDetailsSheet({
    required this.location,
    required this.onGetCurrentLocation,
    required this.onSearchPlace,
    required this.onClearLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);

    // Build full address text
    final addressParts = <String>[
      if (location.street != null && location.street!.isNotEmpty)
        location.street!,
      if (location.streetNumber != null && location.streetNumber!.isNotEmpty)
        location.streetNumber!,
      if (location.locality != null && location.locality!.isNotEmpty)
        location.locality!,
      if (location.administrativeArea != null &&
          location.administrativeArea!.isNotEmpty)
        location.administrativeArea!,
      if (location.postalCode != null && location.postalCode!.isNotEmpty)
        location.postalCode!,
      if (location.country != null && location.country!.isNotEmpty)
        location.country!,
    ];
    final fullAddress = addressParts.isNotEmpty
        ? addressParts.join(', ')
        : location.address ?? location.name ?? gloc.location;

    return GroupBottomSheetScaffold(
      title: gloc.location,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full address
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(fullAddress, style: theme.textTheme.bodyLarge),
          ),

          // Coordinates if available
          if (location.latitude != null && location.longitude != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${location.latitude!.toStringAsFixed(6)}, ${location.longitude!.toStringAsFixed(6)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              _ActionButton(
                icon: Icons.delete_outline,
                tooltip: gloc.cancel,
                onTap: onClearLocation,
                destructive: true,
              ),
              const Spacer(),
              _ActionButton(
                icon: Icons.my_location,
                tooltip: gloc.get_current_location,
                onTap: onGetCurrentLocation,
              ),
              _ActionButton(
                icon: Icons.search,
                tooltip: gloc.location_hint,
                onTap: onSearchPlace,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool destructive;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(icon),
      iconSize: 28,
      color: destructive ? colorScheme.error : colorScheme.primary,
      tooltip: tooltip,
      onPressed: onTap,
    );
  }
}
