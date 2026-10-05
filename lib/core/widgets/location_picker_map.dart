// lib/core/widgets/location_picker_map.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:ramp/core/services/location_service.dart';
import 'package:ramp/core/services/routing_service.dart';
import 'package:ramp/core/theme/ramp_theme.dart';
import 'package:ramp/core/utils/toast_service.dart';

class LocationPickerResult {
  final LatLng coordinates;
  final String formattedLocation;

  const LocationPickerResult({
    required this.coordinates,
    required this.formattedLocation,
  });
}

class LocationPickerMapDialog extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;

  const LocationPickerMapDialog({
    super.key,
    this.initialLocation,
    this.initialAddress,
  });

  static Future<LocationPickerResult?> show(
    BuildContext context, {
    LatLng? initialLocation,
    String? initialAddress,
  }) {
    return showDialog<LocationPickerResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPickerMapDialog(
        initialLocation: initialLocation,
        initialAddress: initialAddress,
      ),
    );
  }

  @override
  State<LocationPickerMapDialog> createState() =>
      _LocationPickerMapDialogState();
}

class _LocationPickerMapDialogState extends State<LocationPickerMapDialog> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final RoutingService _routingService = RoutingService();

  late LatLng _pinnedLocation;
  LatLng? _currentLocation;
  bool _isLoadingCurrentLocation = true;
  StreamSubscription<Position>? _positionSubscription;

  RoadRouteResult? _roadRoute;
  bool _isFetchingRoute = false;

  @override
  void initState() {
    super.initState();
    _pinnedLocation =
        widget.initialLocation ?? LocationService.defaultPagsanjanCoordinates;
    _initLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initLocationTracking() async {
    final hasPermission = await _locationService.checkAndRequestPermissions();
    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
      }
      return;
    }

    final pos = await _locationService.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _isLoadingCurrentLocation = false;
        if (widget.initialLocation == null) {
          _pinnedLocation = _currentLocation!;
        }
      });
      _mapController.move(_pinnedLocation, 16.0);
      _fetchRoadRoute();
    }

    _positionSubscription =
        _locationService.getDevicePositionStream().listen((pos) {
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(pos.latitude, pos.longitude);
        });
      }
    });
  }

  Future<void> _fetchRoadRoute() async {
    if (_currentLocation == null) return;
    setState(() {
      _isFetchingRoute = true;
    });

    final result = await _routingService.getRoadDirections(
      _currentLocation!,
      _pinnedLocation,
    );

    if (mounted) {
      setState(() {
        _roadRoute = result;
        _isFetchingRoute = false;
      });
    }
  }

  void _pinCurrentLocation() {
    if (_currentLocation != null) {
      setState(() {
        _pinnedLocation = _currentLocation!;
      });
      _mapController.move(_currentLocation!, 16.5);
      _fetchRoadRoute();
    } else {
      ToastService.showInfo('Acquiring your current GPS position...');
    }
  }

  String _formatDistance() {
    if (_currentLocation == null) return 'Current position unavailable';
    if (_roadRoute != null) {
      return '${_roadRoute!.formattedDistance} (${_roadRoute!.formattedEta})';
    }
    final meters = _locationService.calculateDistanceMeters(
      _currentLocation!,
      _pinnedLocation,
    );
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m from your position';
    }
    return '${(meters / 1000).toStringAsFixed(2)} km from your position';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pin Unit Location',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Tap on map to set property coordinates',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Interactive Map View
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _pinnedLocation,
                        initialZoom: 16.0,
                        onTap: (_, point) {
                          setState(() {
                            _pinnedLocation = point;
                          });
                          _fetchRoadRoute();
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.apex.ramp',
                        ),
                        TileLayer(
                          urlTemplate:
                              'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Transportation/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.apex.ramp',
                        ),

                        // 3D Ribbon Polyline
                        if (_roadRoute != null &&
                            _roadRoute!.polylinePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _roadRoute!.polylinePoints,
                                strokeWidth: 8.0,
                                color: Colors.black.withValues(alpha: 0.4),
                              ),
                              Polyline(
                                points: _roadRoute!.polylinePoints,
                                strokeWidth: 4.5,
                                color: RampColors.primary,
                              ),
                            ],
                          )
                        else if (_currentLocation != null)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [_currentLocation!, _pinnedLocation],
                                strokeWidth: 3.5,
                                color:
                                    RampColors.primary.withValues(alpha: 0.6),
                              ),
                            ],
                          ),

                        // Markers
                        MarkerLayer(
                          markers: [
                            if (_currentLocation != null)
                              Marker(
                                point: _currentLocation!,
                                width: 50,
                                height: 50,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.blue.withValues(alpha: 0.25),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade600,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Marker(
                              point: _pinnedLocation,
                              width: 50,
                              height: 50,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: RampColors.danger,
                                    size: 42,
                                  ),
                                  Positioned(
                                    top: 8,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Top Floating Distance & Coordinates Card
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A).withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.add_road,
                                  size: 16,
                                  color: RampColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _isFetchingRoute
                                        ? 'Snapping road route...'
                                        : _formatDistance(),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pinned Coordinates: ${_pinnedLocation.latitude.toStringAsFixed(5)}, ${_pinnedLocation.longitude.toStringAsFixed(5)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Floating Controls
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'pin_my_location',
                            backgroundColor: RampColors.primary,
                            tooltip: 'Pin My Current Location',
                            onPressed: _pinCurrentLocation,
                            child: _isLoadingCurrentLocation
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location,
                                    color: Colors.white,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            heroTag: 'recenter_pinned',
                            backgroundColor:
                                isDark ? const Color(0xFF334155) : Colors.white,
                            tooltip: 'Recenter Pinned Marker',
                            onPressed: () {
                              _mapController.move(_pinnedLocation, 16.0);
                            },
                            child: Icon(
                              Icons.center_focus_strong,
                              color: isDark ? Colors.white : RampColors.slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Confirmation Bar
              SafeArea(
                top: false,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.my_location, size: 18),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Use My Location',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          onPressed: _pinCurrentLocation,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: RampColors.primary,
                            side: const BorderSide(
                                color: RampColors.primary, width: 1.5),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon:
                              const Icon(Icons.check_circle_rounded, size: 18),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Confirm Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RampColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            final result = LocationPickerResult(
                              coordinates: _pinnedLocation,
                              formattedLocation:
                                  'Pagsanjan (${_pinnedLocation.latitude.toStringAsFixed(4)}, ${_pinnedLocation.longitude.toStringAsFixed(4)})',
                            );
                            Navigator.pop(context, result);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
