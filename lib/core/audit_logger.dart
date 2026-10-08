// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/core/audit_logger.dart
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a single compliance audit log entry.
class AuditLogEntry {
  final String userId;
  final String action;
  final String details;
  final DateTime timestamp;

  const AuditLogEntry({
    required this.userId,
    required this.action,
    required this.details,
    required this.timestamp,
  });

  @override
  String toString() {
    return '[${timestamp.toIso8601String()}] USER:$userId ACTION:$action DETAILS:$details';
  }
}

final auditLoggerProvider = NotifierProvider<AuditLoggerNotifier, List<AuditLogEntry>>(
  () => AuditLoggerNotifier(),
);

/// In-memory circular buffer for audit logging. 
/// Maintains the last [maxCapacity] logs. Administrative mutations must 
/// write to this system-wide immutable circular buffer for compliance tracking.
class AuditLoggerNotifier extends Notifier<List<AuditLogEntry>> {
  final int maxCapacity = 1000;
  final Queue<AuditLogEntry> _buffer = Queue<AuditLogEntry>();

  @override
  List<AuditLogEntry> build() {
    return _buffer.toList();
  }

  /// Write an administrative mutation to the immutable circular buffer
  void logAction(String userId, String action, String details) {
    final entry = AuditLogEntry(
      userId: userId,
      action: action,
      details: details,
      timestamp: DateTime.now(),
    );

    if (_buffer.length >= maxCapacity) {
      _buffer.removeFirst(); // Enforce circular buffer limit
    }
    
    _buffer.addLast(entry);
    
    // Update state to allow UI observers if necessary
    state = _buffer.toList();
    
    // TODO: In a production scenario, concurrently append this to a remote secure log stream (e.g. Firestore).
  }
}
