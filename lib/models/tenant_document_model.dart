// lib/models/tenant_document_model.dart

import '../core/utils/safe_parse.dart';

class TenantDocumentRecord {
  final String id;
  final String tenantId;
  final String? tenantName;
  final String title;
  final String type; // 'Lease', 'ID Copy', 'Receipt', 'Rules', 'Other'
  final String? fileName;
  final String? fileSize;
  final String? fileUrl;
  final DateTime uploadedAt;

  const TenantDocumentRecord({
    required this.id,
    required this.tenantId,
    this.tenantName,
    required this.title,
    this.type = 'Other',
    this.fileName,
    this.fileSize,
    this.fileUrl,
    required this.uploadedAt,
  });

  factory TenantDocumentRecord.fromJson(Map<String, dynamic> json) {
    return TenantDocumentRecord(
      id: parseString(json['id'], 'doc_${DateTime.now().millisecondsSinceEpoch}'),
      tenantId: parseString(json['tenant_id']),
      tenantName: parseNullableString(json['tenant_name']),
      title: parseString(json['title'], 'Document'),
      type: parseString(json['type'], 'Other'),
      fileName: parseNullableString(json['file_name']),
      fileSize: parseNullableString(json['file_size']),
      fileUrl: parseNullableString(json['file_url']),
      uploadedAt: parseDateTime(json['uploaded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'title': title,
      'type': type,
      'file_name': fileName,
      'file_size': fileSize,
      'file_url': fileUrl,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
