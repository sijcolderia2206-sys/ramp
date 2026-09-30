// lib/models/gps_location.dart
import 'package:latlong2/latlong.dart';

/// Canonical GeoPoint Location Model for RAMP GPS Tracking
class GeoPointLocation {
  final double latitude;
  final double longitude;
  final double heading;
  final double speed;
  final DateTime timestamp;

  const GeoPointLocation({
    required this.latitude,
    required this.longitude,
    this.heading = 0.0,
    this.speed = 0.0,
    required this.timestamp,
  });

  LatLng get toLatLng => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'heading': heading,
        'speed': speed,
        'timestamp': timestamp.toIso8601String(),
      };

  factory GeoPointLocation.fromJson(Map<String, dynamic> json) {
    return GeoPointLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 14.2713, // Default Pagsanjan
      longitude: (json['longitude'] as num?)?.toDouble() ?? 121.4243,
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
