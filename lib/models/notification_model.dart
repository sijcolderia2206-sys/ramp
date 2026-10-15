// lib/models/notification_model.dart

import '../core/utils/safe_parse.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'payment', 'maintenance', 'system'
  final String? targetId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = 'system',
    this.targetId,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    String? targetId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'type': type,
      'target_id': targetId,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: parseString(json['id'], 'notif_${DateTime.now().millisecondsSinceEpoch}'),
      title: parseString(json['title'], 'Notification'),
      message: parseString(json['message']),
      timestamp: parseDateTime(json['timestamp']),
      isRead: parseBool(json['is_read']),
      type: parseString(json['type'], 'system'),
      targetId: parseNullableString(json['target_id']),
    );
  }
}
