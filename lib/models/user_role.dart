// lib/models/user_role.dart
import 'package:flutter/foundation.dart';

/// Supported user roles in the RAMP platform
enum UserRole {
  superAdmin,
  landlord,
  tenant;

  static UserRole fromString(String? role) {
    if (role == null || role.trim().isEmpty) return UserRole.landlord;
    switch (role.trim().toLowerCase()) {
      case 'superadmin':
      case 'super_admin':
      case 'admin':
        return UserRole.superAdmin;
      case 'tenant':
        return UserRole.tenant;
      case 'landlord':
      default:
        return UserRole.landlord;
    }
  }

  String get value {
    switch (this) {
      case UserRole.superAdmin:
        return 'superAdmin';
      case UserRole.landlord:
        return 'landlord';
      case UserRole.tenant:
        return 'tenant';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Administrator';
      case UserRole.landlord:
        return 'Landlord / Property Manager';
      case UserRole.tenant:
        return 'Tenant Portal User';
    }
  }
}

/// Strongly typed user profile model stored in the Firestore database
@immutable
class RampUser {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? tenantId;
  final String? landlordId;
  final bool isApproved;
  final bool mustChangePassword;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const RampUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.tenantId,
    this.landlordId,
    this.isApproved = true,
    this.mustChangePassword = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isLandlord =>
      role == UserRole.landlord || role == UserRole.superAdmin;
  bool get isTenant => role == UserRole.tenant;

  factory RampUser.fromJson(Map<String, dynamic> json, String documentId) {
    return RampUser(
      uid: json['uid'] as String? ?? documentId,
      email: (json['email'] as String? ?? '').trim().toLowerCase(),
      displayName: (json['displayName'] as String? ?? 'RAMP User').trim(),
      role: UserRole.fromString(json['role'] as String?),
      tenantId: json['tenantId'] as String?,
      landlordId: json['landlordId'] as String?,
      isApproved: json['isApproved'] as bool? ?? true,
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.tryParse(json['lastLoginAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.value,
      'tenantId': tenantId,
      'landlordId': landlordId,
      'isApproved': isApproved,
      'mustChangePassword': mustChangePassword,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': (lastLoginAt ?? DateTime.now()).toIso8601String(),
    };
  }

  RampUser copyWith({
    String? displayName,
    UserRole? role,
    String? tenantId,
    String? landlordId,
    bool? isApproved,
    bool? mustChangePassword,
    DateTime? lastLoginAt,
  }) {
    return RampUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      landlordId: landlordId ?? this.landlordId,
      isApproved: isApproved ?? this.isApproved,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
