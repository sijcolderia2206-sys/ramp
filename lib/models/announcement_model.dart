// lib/models/announcement_model.dart

import '../core/utils/safe_parse.dart';

class AnnouncementRecord {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? author;
  final bool isImportant;
  final String category;
  final bool isArchived;

  const AnnouncementRecord({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.author = 'Property Manager',
    this.isImportant = false,
    this.category = 'General',
    this.isArchived = false,
  });

  factory AnnouncementRecord.fromJson(Map<String, dynamic> json) {
    return AnnouncementRecord(
      id: parseString(json['id'], 'ann_${DateTime.now().millisecondsSinceEpoch}'),
      title: parseString(json['title'], 'Announcement'),
      message: parseString(json['message']),
      timestamp: parseDateTime(json['timestamp']),
      author: parseString(json['author'], 'Property Manager'),
      isImportant: parseBool(json['is_important']),
      category: parseString(json['category'], 'General'),
      isArchived: parseBool(json['is_archived']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'author': author,
      'is_important': isImportant,
      'category': category,
      'is_archived': isArchived,
    };
  }
}
