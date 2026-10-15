// lib/core/services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _controller;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  /// Stream of connection status changes (true = online, false = offline)
  Stream<bool> get onConnectivityChanged {
    _controller ??= StreamController<bool>.broadcast(
      onListen: _startMonitoring,
      onCancel: _stopMonitoring,
    );
    return _controller!.stream;
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void _startMonitoring() {
    _checkInitialConnection();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final connected = _isResultConnected(results);
      _isConnected = connected;
      _controller?.add(connected);
      debugPrint('Connectivity changed: online = $connected');
    });
  }

  void _stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isConnected = _isResultConnected(results);
      return _isConnected;
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      _isConnected = true; // Fallback to assume connected if check fails
      return _isConnected;
    }
  }

  Future<void> _checkInitialConnection() async {
    await checkConnection();
    _controller?.add(_isConnected);
  }

  bool _isResultConnected(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }
}
