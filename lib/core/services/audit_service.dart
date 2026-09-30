import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_service.dart';
import 'persistence_queue.dart';

class AuditLogEntry {
  final String id;
  final String action;
  final String details;
  final DateTime timestamp;

  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.details,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'action': action,
        'details': details,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AuditLogEntry.fromMap(Map<String, dynamic> map) => AuditLogEntry(
        id: map['id'] as String? ?? 'audit_${DateTime.now().millisecondsSinceEpoch}',
        action: map['action'] as String? ?? 'System Action',
        details: map['details'] as String? ?? '',
        timestamp: map['timestamp'] != null
            ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}

class AuditService extends StateNotifier<List<AuditLogEntry>> {
  AuditService() : super([]) {
    _loadPersistedLogs();
  }

  Future<void> _loadPersistedLogs() async {
    try {
      final res = await SupabaseService().loadTable('audit_logs');
      final logsData = res.dataOrNull ?? [];
      if (logsData.isNotEmpty) {
        final logs = logsData.map((data) => AuditLogEntry.fromMap(data)).toList();
        logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        state = logs;
      }
    } catch (e) {
      debugPrint('ℹ️ AuditService log hydration notice: $e');
    }
  }

  void logAction(String action, String details) {
    final entry = AuditLogEntry(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      action: action,
      details: details,
      timestamp: DateTime.now(),
    );
    state = [entry, ...state];
    PersistenceQueue.instance.enqueueUpsert('audit_logs', entry.id, entry.toMap());
  }
}

final auditServiceProvider =
    StateNotifierProvider<AuditService, List<AuditLogEntry>>((ref) {
  return AuditService();
});
