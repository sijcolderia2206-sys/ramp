// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReminderLog _$ReminderLogFromJson(Map<String, dynamic> json) => _ReminderLog(
      id: json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      channel: json['channel'] as String? ?? '',
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      rentCycle: json['rentCycle'] as String? ?? '',
      messageType: json['messageType'] as String? ?? 'Rent Notice',
    );

Map<String, dynamic> _$ReminderLogToJson(_ReminderLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'channel': instance.channel,
      'timestamp': instance.timestamp?.toIso8601String(),
      'rentCycle': instance.rentCycle,
      'messageType': instance.messageType,
    };

_Tenant _$TenantFromJson(Map<String, dynamic> json) => _Tenant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      contactNumber: json['contactNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      referral: json['referral'] as String? ?? '',
      unitId: json['unitId'] as String? ?? '',
      unitNumber: json['unitNumber'] as String? ?? 'Unassigned',
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble() ?? 0.0,
      leaseStart: json['leaseStart'] == null
          ? null
          : DateTime.parse(json['leaseStart'] as String),
      leaseEnd: json['leaseEnd'] == null
          ? null
          : DateTime.parse(json['leaseEnd'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Active',
      isArchived: json['isArchived'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      currentTenancyId: json['currentTenancyId'] as String?,
      messengerHandle: json['messengerHandle'] as String?,
      reminderLogs: (json['reminderLogs'] as List<dynamic>?)
              ?.map((e) => ReminderLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TenantToJson(_Tenant instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'contactNumber': instance.contactNumber,
      'address': instance.address,
      'referral': instance.referral,
      'unitId': instance.unitId,
      'unitNumber': instance.unitNumber,
      'monthlyRent': instance.monthlyRent,
      'leaseStart': instance.leaseStart?.toIso8601String(),
      'leaseEnd': instance.leaseEnd?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'balance': instance.balance,
      'status': instance.status,
      'isArchived': instance.isArchived,
      'avatarUrl': instance.avatarUrl,
      'currentTenancyId': instance.currentTenancyId,
      'messengerHandle': instance.messengerHandle,
      'reminderLogs': instance.reminderLogs,
    };
