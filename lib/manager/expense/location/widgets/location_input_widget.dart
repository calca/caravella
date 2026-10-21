import 'package:material_ui/material_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import '../location_service.dart';
import '../constants.dart';
import '../../pages/place_search_page.dart';

/// The expense's place as a pill: dashed "Place" when empty (tap searches
/// a place, current location included), the locality once set (tap shows
/// the details sheet: current location, search, remove), a spinner while
/// the position is being detected — by this widget or, via [isRetrieving],
/// by the form's automatic detection.
class LocationInputWidget extends StatefulWidget {
  final ExpenseLocation? initialLocation;
  final Function(ExpenseLocation?) onLocationChanged;
  final bool autoRetrieve;
  final bool isRetrieving;
  final Function(bool)? onRetrievalStatusChanged;
  final bool enabled;

  const LocationInputWidget({
    super.key,
    this.initialLocation,
    required this.onLocationChanged,
    this.autoRetrieve = false,
    this.isRetrieving = false,
    this.onRetrievalStatusChanged,
    this.enabled = true,
  });

  @override
  State<LocationInputWidget> createState() => _LocationInputWidgetState();
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  bool _isGettingLocation = false;
  bool _isResolvingAddress = false;
  ExpenseLocation? _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
    if (_currentLocation == null && widget.autoRetrieve) {
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
    }
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
      });

      // Optional lightweight feedback when an address gets resolved
      if (location.address != null) {
        final gloc = gen.AppLocalizations.of(context);
        AppToast.show(
          context,
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
    });
    widget.onLocationChanged(null);
  }

  Future<void> _showPlaceSearch() async {
    final gloc = gen.AppLocalizations.of(context);

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
          _isResolvingAddress = false;
        });

        widget.onLocationChanged(location);

        if (mounted) {
          AppToast.show(
            context,
            gloc.address_resolved,
            duration: const Duration(seconds: 2),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isResolvingAddress = false;
          });
          AppToast.show(context, gloc.location_error, type: ToastType.error);
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
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isRetrieving || _isGettingLocation || _isResolvingAddress) {
      return FormPill(
        leading: SizedBox.square(
          dimension: LocationConstants.loaderSize,
          child: CircularProgressIndicator(
            strokeWidth: LocationConstants.loaderStrokeWidth,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        label: _isResolvingAddress
            ? gloc.address_resolved
            : gloc.getting_location,
      );
    }

    final location = _currentLocation;
    if (location != null) {
      final displayText =
          location.locality ??
          location.name ??
          location.address ??
          (location.latitude != null && location.longitude != null
              ? '${location.latitude!.toStringAsFixed(4)}, ${location.longitude!.toStringAsFixed(4)}'
              : gloc.location);
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: FormPill(
          icon: Icons.place_outlined,
          label: displayText,
          semanticsLabel: '${gloc.location}: $displayText',
          onTap: widget.enabled ? _showLocationDetails : null,
        ),
      );
    }

    return FormPill(
      icon: Icons.place_outlined,
      label: gloc.location,
      style: FormPillStyle.add,
      onTap: widget.enabled ? _showPlaceSearch : null,
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

    return CaravellaBottomSheetScaffold(
      title: gloc.location,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full address (and coordinates) in a card.
          SettingsGroup(
            topSpacing: 0,
            children: [
              SettingsTile(
                icon: Icons.place_outlined,
                title: fullAddress,
                subtitle:
                    location.latitude != null && location.longitude != null
                    ? '${location.latitude!.toStringAsFixed(6)}, '
                          '${location.longitude!.toStringAsFixed(6)}'
                    : null,
              ),
            ],
          ),
          SettingsGroup(
            topSpacing: 12,
            children: [
              SettingsTile(
                icon: Icons.my_location_rounded,
                title: gloc.get_current_location,
                chevron: false,
                onTap: onGetCurrentLocation,
              ),
              SettingsTile(
                icon: Icons.search_rounded,
                title: gloc.place_search_action,
                chevron: false,
                onTap: onSearchPlace,
              ),
            ],
          ),
          SettingsGroup(
            topSpacing: 12,
            children: [
              SettingsTile(
                icon: Icons.delete_outline_rounded,
                title: gloc.clear,
                destructive: true,
                chevron: false,
                onTap: onClearLocation,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
