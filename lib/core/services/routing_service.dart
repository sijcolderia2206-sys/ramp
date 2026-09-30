// lib/core/services/routing_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Result container for road routing directions from OSRM
class RoadRouteResult {
  final List<LatLng> polylinePoints;
  final double distanceMeters;
  final double durationSeconds;

  const RoadRouteResult({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  /// Distance formatted in kilometers
  double get distanceKm => distanceMeters / 1000.0;

  /// Estimated duration in minutes
  int get durationMinutes => (durationSeconds / 60.0).ceil();

  /// Formatted string representation for distance
  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m on road';
    }
    return '${distanceKm.toStringAsFixed(2)} km on road';
  }

  /// Formatted string representation for ETA
  String get formattedEta {
    if (durationMinutes <= 1) return '~1 min';
    if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      return '${hours}h ${mins}m';
    }
    return '~$durationMinutes mins';
  }
}

class RoutingService {
  static final RoutingService _instance = RoutingService._internal();
  factory RoutingService() => _instance;
  RoutingService._internal();

  /// OSRM Public Routing API Base Endpoint
  static const String _osrmBaseUrl =
      'https://router.project-osrm.org/route/v1/driving';

  /// Fetches actual road driving directions and street geometries between two LatLng points
  Future<RoadRouteResult?> getRoadDirections(
    LatLng origin,
    LatLng destination,
  ) async {
    final url = Uri.parse(
      '$_osrmBaseUrl/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http
          .get(url, headers: {'User-Agent': 'com.apex.ramp/1.0'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List?;

        if (routes != null && routes.isNotEmpty) {
          final primaryRoute = routes[0];
          final geometry = primaryRoute['geometry'] as Map<String, dynamic>?;
          final coordinates = geometry?['coordinates'] as List?;

          if (coordinates != null && coordinates.isNotEmpty) {
            final polylinePoints = coordinates.map((coord) {
              final list = coord as List;
              return LatLng(
                (list[1] as num).toDouble(),
                (list[0] as num).toDouble(),
              );
            }).toList();

            final distance =
                (primaryRoute['distance'] as num?)?.toDouble() ?? 0.0;
            final duration =
                (primaryRoute['duration'] as num?)?.toDouble() ?? 0.0;

            return RoadRouteResult(
              polylinePoints: polylinePoints,
              distanceMeters: distance,
              durationSeconds: duration,
            );
          }
        }
      }
    } catch (e) {
      // Gracefully fall back to straight line if network or OSRM is unreachable
      print('RAMP RoutingService OSRM Error: $e');
    }
    return null;
  }
}
