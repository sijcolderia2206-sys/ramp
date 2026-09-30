// lib/providers/gps_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ramp/core/services/location_service.dart';
import 'package:ramp/core/services/routing_service.dart';
import 'package:ramp/models/gps_location.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final routingServiceProvider = Provider<RoutingService>((ref) {
  return RoutingService();
});

/// Stream provider for live device position
final liveUserPositionProvider = StreamProvider<Position>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getDevicePositionStream();
});

/// Stream provider for live technician location on a ticket
final ticketLiveLocationProvider =
    StreamProvider.family<GeoPointLocation?, String>((ref, ticketId) {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.streamTicketTechnicianLocation(ticketId);
});
