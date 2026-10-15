// lib/models/pending_sync_action.dart

class PendingSyncAction {
  final String id;
  final String actionType; // 'CREATE_UNIT', 'UPDATE_SUBMETER', 'VERIFY_PAYMENT', 'UPDATE_TICKET_STAGE', 'RECORD_PAYMENT', 'ADD_TENANT', 'ADD_TICKET'
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final String status; // 'pending', 'syncing', 'failed', 'conflict'
  final String? errorMessage;
  final int retryCount;

  const PendingSyncAction({
    required this.id,
    required this.actionType,
    required this.payload,
    required this.timestamp,
    this.status = 'pending',
    this.errorMessage,
    this.retryCount = 0,
  });

  PendingSyncAction copyWith({
    String? id,
    String? actionType,
    Map<String, dynamic>? payload,
    DateTime? timestamp,
    String? status,
    String? errorMessage,
    int? retryCount,
  }) {
    return PendingSyncAction(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_type': actionType,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'error_message': errorMessage,
      'retry_count': retryCount,
    };
  }

  factory PendingSyncAction.fromJson(Map<String, dynamic> json) {
    return PendingSyncAction(
      id: json['id'] as String,
      actionType: json['action_type'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: (json['status'] as String?) ?? 'pending',
      errorMessage: json['error_message'] as String?,
      retryCount: (json['retry_count'] as int?) ?? 0,
    );
  }
}
