// lib/core/services/location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ramp/models/gps_location.dart';
import 'persistence_queue.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _dispatchSubscription;

  /// Default fallback location: Apex Rental Properties (Pagsanjan, Laguna)
  static const LatLng defaultPagsanjanCoordinates = LatLng(14.2713, 121.4243);

  /// Check and request device location permissions
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current user device GPS position
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      // Fallback to last known position if current fails
      return await Geolocator.getLastKnownPosition();
    }
  }

  /// Live Stream of Current Device Position
  Stream<Position> getDevicePositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3, // Stream every 3 meters
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Calculate distance between two LatLng points in meters
  double calculateDistanceMeters(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Calculate distance between two LatLng points in kilometers
  double calculateDistanceKm(LatLng point1, LatLng point2) {
    return calculateDistanceMeters(point1, point2) / 1000.0;
  }

  /// Start broadcasting maintenance technician dispatch location
  Future<bool> startLiveDispatchBroadcast({
    required String ticketId,
    required String techId,
  }) async {
    final hasPermission = await checkAndRequestPermissions();
    if (!hasPermission) return false;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _dispatchSubscription?.cancel();
    _dispatchSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      final geoLoc = GeoPointLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
        speed: position.speed,
        timestamp: DateTime.now(),
      );

      // Queue the location update to Supabase
      PersistenceQueue.instance.enqueueUpsert('maintenanceTickets', ticketId, {
        'id': ticketId,
        'liveLocation': geoLoc.toJson(),
      });
    });

    return true;
  }

  /// Stop live dispatch broadcast
  void stopLiveBroadcast() {
    _dispatchSubscription?.cancel();
    _dispatchSubscription = null;
  }

  /// Subscribe to technician location stream for a specific ticket
  Stream<GeoPointLocation?> streamTicketTechnicianLocation(String ticketId) {
    // In a real application, implement Supabase Realtime channel subscription here
    return const Stream.empty();
  }
}

