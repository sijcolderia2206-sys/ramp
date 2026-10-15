// lib/models/tenant_model.dart

import '../core/utils/safe_parse.dart';

class TenantRecord {
  final String id;
  final String landlordId;
  final String name;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? suffix;
  final DateTime? dateOfBirth;
  final String phone;
  final String? email;
  final String? facebookUrl;
  final String? emergencyName;
  final String? emergencyRelationship;
  final String? emergencyPhone;
  final String? emergencyFacebookUrl;
  final String unitId;
  final String unitNumber;
  final double monthlyRent;
  final double balance;
  final double securityDeposit;
  final DateTime leaseStart;
  final DateTime leaseEnd;
  final DateTime dueDate;
  final String healthStatus; // 'green', 'yellow', 'red'
  final String? messengerHandle;
  final bool isArchived;
  final bool isConfirmed;

  const TenantRecord({
    required this.id,
    this.landlordId = 'l1',
    required this.name,
    this.firstName,
    this.middleName,
    this.lastName,
    this.suffix,
    this.dateOfBirth,
    required this.phone,
    this.email,
    this.facebookUrl,
    this.emergencyName,
    this.emergencyRelationship,
    this.emergencyPhone,
    this.emergencyFacebookUrl,
    required this.unitId,
    required this.unitNumber,
    required this.monthlyRent,
    this.balance = 0.0,
    this.securityDeposit = 0.0,
    required this.leaseStart,
    required this.leaseEnd,
    required this.dueDate,
    this.healthStatus = 'green',
    this.messengerHandle,
    this.isArchived = false,
    this.isConfirmed = true,
  });

  bool get isOverdue => balance > 0 && DateTime.now().isAfter(dueDate);

  /// Calculated Late Fee if current date exceeds dueDate + 3 grace period days
  double get calculatedLateFee {
    if (balance <= 0) return 0.0;
    final graceDeadline = dueDate.add(const Duration(days: 3));
    if (DateTime.now().isAfter(graceDeadline)) {
      return 500.0; // Standard late fee ₱500.00
    }
    return 0.0;
  }

  double get totalAmountDue => balance + calculatedLateFee;

  /// Model Compatibility Getters for RAMP Property Management Specification
  String get fullName => name;
  String get contactNumber => phone;
  double get balanceDue => totalAmountDue;
  String get paymentStatus => (balance > 0 && (isOverdue || healthStatus == 'red')) ? 'Overdue' : 'Paid';
  String? get profileImageUrl => null;

  TenantRecord copyWith({
    String? id,
    String? landlordId,
    String? name,
    String? firstName,
    String? middleName,
    String? lastName,
    String? suffix,
    DateTime? dateOfBirth,
    String? phone,
    String? email,
    String? facebookUrl,
    String? emergencyName,
    String? emergencyRelationship,
    String? emergencyPhone,
    String? emergencyFacebookUrl,
    String? unitId,
    String? unitNumber,
    double? monthlyRent,
    double? balance,
    double? securityDeposit,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    DateTime? dueDate,
    String? healthStatus,
    String? messengerHandle,
    bool? isArchived,
    bool? isConfirmed,
  }) {
    return TenantRecord(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      suffix: suffix ?? this.suffix,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      emergencyName: emergencyName ?? this.emergencyName,
      emergencyRelationship: emergencyRelationship ?? this.emergencyRelationship,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      emergencyFacebookUrl: emergencyFacebookUrl ?? this.emergencyFacebookUrl,
      unitId: unitId ?? this.unitId,
      unitNumber: unitNumber ?? this.unitNumber,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      balance: balance ?? this.balance,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      leaseStart: leaseStart ?? this.leaseStart,
      leaseEnd: leaseEnd ?? this.leaseEnd,
      dueDate: dueDate ?? this.dueDate,
      healthStatus: healthStatus ?? this.healthStatus,
      messengerHandle: messengerHandle ?? this.messengerHandle,
      isArchived: isArchived ?? this.isArchived,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'landlord_id': landlordId,
      'name': name,
      'first_name': firstName ?? '',
      'middle_name': middleName ?? '',
      'last_name': lastName ?? '',
      'suffix': suffix ?? '',
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone': phone,
      'email': email,
      'facebook_url': facebookUrl,
      'emergency_name': emergencyName,
      'emergency_relationship': emergencyRelationship,
      'emergency_phone': emergencyPhone,
      'emergency_facebook_url': emergencyFacebookUrl,
      'unit_id': unitId,
      'unit_number': unitNumber,
      'monthly_rent': monthlyRent,
      'balance': balance,
      'security_deposit': securityDeposit,
      'lease_start': leaseStart.toIso8601String(),
      'lease_end': leaseEnd.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'messenger_handle': messengerHandle ?? facebookUrl,
      'is_archived': isArchived,
      'is_confirmed': isConfirmed,
    };
  }

  factory TenantRecord.fromJson(Map<String, dynamic> json) {
    final rawName = parseString(json['name']);
    final firstName = parseNullableString(json['first_name']);
    final lastName = parseNullableString(json['last_name']);
    final computedName = rawName.isNotEmpty
        ? rawName
        : '${firstName ?? ''} ${lastName ?? ''}'.trim();

    return TenantRecord(
      id: parseString(json['id'], 'tenant_${DateTime.now().millisecondsSinceEpoch}'),
      landlordId: parseString(json['landlord_id'], 'l1'),
      name: computedName.isNotEmpty ? computedName : 'Tenant',
      firstName: firstName,
      middleName: parseNullableString(json['middle_name']),
      lastName: lastName,
      suffix: parseNullableString(json['suffix']),
      dateOfBirth: parseNullableDateTime(json['date_of_birth']),
      phone: parseString(json['phone'] ?? json['contact_number']),
      email: parseNullableString(json['email']),
      facebookUrl: parseNullableString(json['facebook_url'] ?? json['messenger_handle']),
      emergencyName: parseNullableString(json['emergency_name']),
      emergencyRelationship: parseNullableString(json['emergency_relationship']),
      emergencyPhone: parseNullableString(json['emergency_phone']),
      emergencyFacebookUrl: parseNullableString(json['emergency_facebook_url']),
      unitId: parseString(json['unit_id']),
      unitNumber: parseString(json['unit_number'], 'Unassigned'),
      monthlyRent: parseDouble(json['monthly_rent']),
      balance: parseDouble(json['balance']),
      securityDeposit: parseDouble(json['security_deposit']),
      leaseStart: parseDateTime(json['lease_start']),
      leaseEnd: parseDateTime(json['lease_end'], DateTime.now().add(const Duration(days: 365))),
      dueDate: parseDateTime(json['due_date']),
      healthStatus: parseString(json['health_status'], 'green'),
      messengerHandle: parseNullableString(json['messenger_handle']),
      isArchived: parseBool(json['is_archived']),
      isConfirmed: parseBool(json['is_confirmed'] ?? json['is_approved'], true),
    );
  }
}
