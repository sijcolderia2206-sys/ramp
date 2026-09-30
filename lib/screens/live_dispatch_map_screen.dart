// lib/screens/live_dispatch_map_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:ramp/core/services/location_service.dart';
import 'package:ramp/core/services/routing_service.dart';
import 'package:ramp/core/theme/ramp_theme.dart';
import 'package:ramp/models/models.dart';
import 'package:ramp/providers/gps_provider.dart';

enum MapStyleType {
  satellite,
  dark3d,
  standard,
}

class LiveDispatchMapScreen extends ConsumerStatefulWidget {
  final Ticket ticket;
  final LatLng? unitLocation;

  const LiveDispatchMapScreen({
    super.key,
    required this.ticket,
    this.unitLocation,
  });

  @override
  ConsumerState<LiveDispatchMapScreen> createState() =>
      _LiveDispatchMapScreenState();
}

class _LiveDispatchMapScreenState extends ConsumerState<LiveDispatchMapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final RoutingService _routingService = RoutingService();

  LatLng? _myCurrentLocation;
  late LatLng _unitCoordinates;
  StreamSubscription<Position>? _positionSubscription;

  // Map Tile Style State
  MapStyleType _currentMapStyle = MapStyleType.satellite;

  // Road Routing State
  RoadRouteResult? _roadRoute;
  bool _isFetchingRoute = false;
  LatLng? _lastRoutedTechLoc;

  // Pulse & Smooth Gliding Marker Controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _vehicleGlidController;
  LatLng? _previousTechPosition;
  LatLng? _animatedTechPosition;
  double _animatedHeading = 0.0;

  @override
  void initState() {
    super.initState();
    _unitCoordinates = widget.unitLocation ??
        LocationService.defaultPagsanjanCoordinates;

    // Pulse Animation for GPS Beacon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOutQuad,
      ),
    );

    // Vehicle Smooth Movement Controller
    _vehicleGlidController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _startLiveUserLocationTracking();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _vehicleGlidController.dispose();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLiveUserLocationTracking() async {
    final hasPermission = await _locationService.checkAndRequestPermissions();
    if (!hasPermission) return;

    final pos = await _locationService.getCurrentPosition();
    if (pos != null && mounted) {
      setState(() {
        _myCurrentLocation = LatLng(pos.latitude, pos.longitude);
      });
      _updateRoadRouteIfNeeded(
        _myCurrentLocation!,
        force: true,
      );
    }

    _positionSubscription =
        _locationService.getDevicePositionStream().listen((pos) {
      if (mounted) {
        setState(() {
          _myCurrentLocation = LatLng(pos.latitude, pos.longitude);
        });
      }
    });
  }

  /// Calculates and snaps to real street directions using OSRM
  Future<void> _updateRoadRouteIfNeeded(LatLng origin, {bool force = false}) async {
    if (_isFetchingRoute) return;

    // Only re-route if distance shifted by > 15 meters or forced
    if (!force && _lastRoutedTechLoc != null) {
      final shiftedDist = _locationService.calculateDistanceMeters(
        origin,
        _lastRoutedTechLoc!,
      );
      if (shiftedDist < 15.0) return;
    }

    setState(() {
      _isFetchingRoute = true;
    });

    final routeResult = await _routingService.getRoadDirections(
      origin,
      _unitCoordinates,
    );

    if (mounted) {
      setState(() {
        _roadRoute = routeResult;
        _lastRoutedTechLoc = origin;
        _isFetchingRoute = false;
      });
    }
  }

  /// Animates vehicle marker position smoothly between GPS updates
  void _animateVehiclePosition(GeoPointLocation newLoc) {
    final targetLatLng = newLoc.toLatLng;

    if (_previousTechPosition == null) {
      _previousTechPosition = targetLatLng;
      _animatedTechPosition = targetLatLng;
      _animatedHeading = newLoc.heading;
      _updateRoadRouteIfNeeded(targetLatLng, force: true);
      return;
    }

    if (_previousTechPosition == targetLatLng) return;

    final startPos = _animatedTechPosition ?? _previousTechPosition!;
    _vehicleGlidController.reset();

    final animation = CurvedAnimation(
      parent: _vehicleGlidController,
      curve: Curves.easeInOutCubic,
    );

    animation.addListener(() {
      if (mounted) {
        setState(() {
          _animatedTechPosition = LatLng(
            startPos.latitude +
                (targetLatLng.latitude - startPos.latitude) * animation.value,
            startPos.longitude +
                (targetLatLng.longitude - startPos.longitude) * animation.value,
          );
          _animatedHeading = newLoc.heading;
        });
      }
    });

    _vehicleGlidController.forward();
    _previousTechPosition = targetLatLng;

    // Update road polyline on movement
    _updateRoadRouteIfNeeded(targetLatLng);
  }

  void _fitMapBounds(LatLng p1, LatLng p2) {
    final bounds = LatLngBounds.fromPoints([p1, p2]);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
      ),
    );
  }

  String _getTileUrl() {
    switch (_currentMapStyle) {
      case MapStyleType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case MapStyleType.dark3d:
        return 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
      case MapStyleType.standard:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final liveTechLocAsync =
        ref.watch(ticketLiveLocationProvider(widget.ticket.id));

    // Handle technician location update lerp
    liveTechLocAsync.whenData((techLoc) {
      if (techLoc != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _animateVehiclePosition(techLoc);
        });
      }
    });

    final currentTechLoc = liveTechLocAsync.valueOrNull;
    final activeVehiclePoint = _animatedTechPosition ??
        currentTechLoc?.toLatLng ??
        _myCurrentLocation;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Live 3D GPS Tracking',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ROAD SNAPPED',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Unit ${widget.ticket.unitNumber} • Ticket #${widget.ticket.id.length > 6 ? widget.ticket.id.substring(0, 6) : widget.ticket.id}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (activeVehiclePoint != null)
            IconButton(
              icon: const Icon(Icons.zoom_out_map),
              tooltip: 'Fit Vehicle & Target Unit',
              onPressed: () {
                _fitMapBounds(activeVehiclePoint, _unitCoordinates);
              },
            ),
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Center Target Unit',
            onPressed: () {
              _mapController.move(_unitCoordinates, 16.5);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. 3D Styled Flutter Map Layer
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _unitCoordinates,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: _getTileUrl(),
                userAgentPackageName: 'com.apex.ramp',
              ),

              // Labels tile overlay for Satellite mode
              if (_currentMapStyle == MapStyleType.satellite)
                TileLayer(
                  urlTemplate:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Transportation/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.apex.ramp',
                ),

              // 2. 3D Elevated Polyline Ribbon Layer (Snaps to Roads)
              if (_roadRoute != null && _roadRoute!.polylinePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Outer 3D Translucent Shadow Line
                    Polyline(
                      points: _roadRoute!.polylinePoints,
                      strokeWidth: 9.0,
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                    // Inner Glowing Primary Navigation Ribbon
                    Polyline(
                      points: _roadRoute!.polylinePoints,
                      strokeWidth: 5.5,
                      color: const Color(0xFF0D6EFD), // Ramp Primary Blue
                    ),
                    // Core Neon Pulse Track Line
                    Polyline(
                      points: _roadRoute!.polylinePoints,
                      strokeWidth: 2.0,
                      color: const Color(0xFF38BDF8), // Cyan Highlight
                    ),
                  ],
                )
              else if (activeVehiclePoint != null)
                // Fallback direct line while road geometry is loading
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [activeVehiclePoint, _unitCoordinates],
                      strokeWidth: 4.0,
                      color: RampColors.primary.withValues(alpha: 0.6),
                    ),
                  ],
                ),

              // 3. Markers Layer (3D Styled Pins & Radar Beacons)
              MarkerLayer(
                markers: [
                  // Unit Destination 3D Pin Marker
                  Marker(
                    point: _unitCoordinates,
                    width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ground Drop Shadow
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 24,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: const BorderRadius.all(
                                Radius.elliptical(24, 10),
                              ),
                            ),
                          ),
                        ),
                        // Elevated 3D Destination Badge
                        Positioned(
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.home,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // My Current Position Beacon
                  if (_myCurrentLocation != null)
                    Marker(
                      point: _myCurrentLocation!,
                      width: 50,
                      height: 50,
                      child: Tooltip(
                        message: 'My Device Position',
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.25),
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
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 3D Live Technician Vehicle Avatar & Radar Pulse
                  if (activeVehiclePoint != null)
                    Marker(
                      point: activeVehiclePoint,
                      width: 90,
                      height: 90,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated Pulsing Radar Pulse Ring
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF0D6EFD).withValues(
                                      alpha: (2.2 - _pulseAnimation.value)
                                          .clamp(0.0, 0.4),
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFF38BDF8).withValues(
                                        alpha: (2.2 - _pulseAnimation.value)
                                            .clamp(0.0, 0.6),
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Vehicle Drop Shadow
                          Positioned(
                            bottom: 8,
                            child: Container(
                              width: 32,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: const BorderRadius.all(
                                  Radius.elliptical(32, 12),
                                ),
                              ),
                            ),
                          ),

                          // 3D Directional Vehicle Badge
                          Transform.rotate(
                            angle: _animatedHeading * (math.pi / 180),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF1D4ED8),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x7A000000),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.build_circle,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  // Directional Arrow Tip
                                  Positioned(
                                    top: 2,
                                    child: Icon(
                                      Icons.arrow_drop_up,
                                      color: Colors.amber.shade400,
                                      size: 16,
                                    ),
                                  ),
                                ],
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

          // 4. Map Layer Switcher Floating Button Bar
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A).withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStyleChip(
                    style: MapStyleType.satellite,
                    label: '3D Satellite',
                    icon: Icons.satellite_alt,
                  ),
                  _buildStyleChip(
                    style: MapStyleType.dark3d,
                    label: 'Dark',
                    icon: Icons.dark_mode,
                  ),
                  _buildStyleChip(
                    style: MapStyleType.standard,
                    label: 'Vector',
                    icon: Icons.map,
                  ),
                ],
              ),
            ),
          ),

          // 5. Live Navigation & Telemetry HUD Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: liveTechLocAsync.when(
                  data: (techLoc) {
                    final speedKmh = ((techLoc?.speed ?? 0.0) * 3.6);
                    final roadDistText = _roadRoute?.formattedDistance ??
                        (activeVehiclePoint != null
                            ? '${_locationService.calculateDistanceKm(activeVehiclePoint, _unitCoordinates).toStringAsFixed(2)} km (direct)'
                            : 'Calculating...');
                    final etaText = _roadRoute?.formattedEta ??
                        (activeVehiclePoint != null
                            ? '~${(speedKmh > 5 ? (_locationService.calculateDistanceKm(activeVehiclePoint, _unitCoordinates) / speedKmh * 60).round() : 10)} mins'
                            : '--');

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row: Technician Info & Speed
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: RampColors.primary
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.engineering,
                                color: RampColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.ticket.assignedTo,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: techLoc != null
                                              ? const Color(0xFF10B981)
                                              : Colors.amber,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        techLoc != null
                                            ? 'En Route • Live Telemetry'
                                            : 'Awaiting technician broadcast',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Speed Meter Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${speedKmh.toStringAsFixed(0)} km/h',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: speedKmh > 0
                                          ? const Color(0xFF10B981)
                                          : RampColors.primary,
                                    ),
                                  ),
                                  Text(
                                    'SPEED',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        // Metrics Row: Road Distance & ETA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Road Distance
                            Row(
                              children: [
                                Icon(
                                  Icons.add_road,
                                  size: 18,
                                  color: RampColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      roadDistText,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      _isFetchingRoute
                                          ? 'Snapping street geometry...'
                                          : 'Road distance to property',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // ETA Pill Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.timer,
                                    size: 16,
                                    color: Color(0xFF10B981),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'ETA $etaText',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, _) => Text('GPS Stream Error: $err'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleChip({
    required MapStyleType style,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _currentMapStyle == style;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMapStyle = style;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? RampColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
