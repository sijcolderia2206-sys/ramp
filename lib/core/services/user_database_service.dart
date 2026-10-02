// lib/core/services/user_database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_role.dart';
import '../network/result.dart';
import 'supabase_service.dart';

/// Database service dedicated to User Profile & Role management in Firestore and Supabase
class UserDatabaseService {
  UserDatabaseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  static const String _usersCollection = 'users';

  /// Fetch user profile by UID (checks Supabase first, falls back to Firestore)
  Future<Result<RampUser>> getUserProfile(String uid) async {
    try {
      if (uid.trim().isEmpty) {
        return Result.failure('Invalid user UID provided.');
      }

      // 1. Try Supabase users table first
      try {
        final supaRes = await SupabaseService().loadTable(_usersCollection);
        final usersData = supaRes.dataOrNull ?? [];
        final matched = usersData.firstWhere(
          (u) => u['uid'] == uid || u['id'] == uid,
          orElse: () => <String, dynamic>{},
        );
        if (matched.isNotEmpty) {
          final rampUser = RampUser.fromJson(matched, uid);
          return Result.success(rampUser);
        }
      } catch (e) {
        debugPrint('ℹ️ Supabase getUserProfile notice [$uid]: $e');
      }

      // 2. Fallback to Firestore users collection
      DocumentSnapshot<Map<String, dynamic>>? doc;
      try {
        doc = await _firestore.collection(_usersCollection).doc(uid).get();
      } catch (e) {
        debugPrint('ℹ️ Firestore getUserProfile notice [$uid]: $e');
        return Result.failure('Firestore unavailable for user profile.', e);
      }

      if (!doc.exists || doc.data() == null) {
        return Result.failure(
            'User document not found in database for UID: $uid');
      }

      final rampUser = RampUser.fromJson(doc.data()!, doc.id);

      // Auto-sync profile to Supabase to establish single source of truth
      final userMap = rampUser.toJson();
      userMap['id'] = rampUser.uid;
      SupabaseService().upsertRecord(_usersCollection, userMap);

      return Result.success(rampUser);
    } catch (e, stack) {
      debugPrint('❌ getUserProfile Exception [$uid]: $e\n$stack');
      return Result.failure('Failed to load user profile from database.', e);
    }
  }

  /// Save or update user profile in both Firestore and Supabase
  Future<Result<void>> upsertUserProfile(RampUser user) async {
    try {
      final userMap = user.toJson();
      userMap['id'] = user.uid;

      // 1. Write to Firestore for Auth security rules
      try {
        final docRef = _firestore.collection(_usersCollection).doc(user.uid);
        await docRef.set(userMap, SetOptions(merge: true));
      } catch (e) {
        debugPrint('ℹ️ Firestore upsertUserProfile notice [${user.uid}]: $e');
      }

      // 2. Sync to Supabase master database
      try {
        await SupabaseService().upsertRecord(_usersCollection, userMap);
      } catch (e) {
        debugPrint('ℹ️ Supabase upsertUserProfile notice [${user.uid}]: $e');
      }

      return Result.success(null);
    } catch (e, stack) {
      debugPrint('❌ upsertUserProfile Exception [${user.uid}]: $e\n$stack');
      return Result.failure('Failed to save user profile in database.', e);
    }
  }

  /// Create user profile upon registration or fallback login
  Future<Result<RampUser>> createOrEnsureUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required UserRole role,
    String? tenantId,
    String? landlordId,
    bool mustChangePassword = false,
  }) async {
    try {
      final existingResult = await getUserProfile(uid);
      if (existingResult.isSuccess && existingResult.dataOrNull != null) {
        // Update last login timestamp
        final existing = existingResult.dataOrNull!;
        final updated = existing.copyWith(lastLoginAt: DateTime.now());
        await upsertUserProfile(updated);
        return Result.success(updated);
      }

      final newUser = RampUser(
        uid: uid,
        email: email.trim().toLowerCase(),
        displayName:
            displayName.trim().isEmpty ? 'RAMP User' : displayName.trim(),
        role: role,
        tenantId: tenantId,
        landlordId: landlordId,
        isApproved: true,
        mustChangePassword: mustChangePassword,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final saveResult = await upsertUserProfile(newUser);
      if (saveResult.isFailure) {
        return Result.failure(
            saveResult.errorOrNull ?? 'Failed to initialize user.');
      }

      return Result.success(newUser);
    } catch (e) {
      return Result.failure('Error ensuring user profile in database.', e);
    }
  }

  /// Super Admin functionality: Update user role in both Firestore and Supabase
  Future<Result<void>> updateUserRole(String uid, UserRole newRole) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'role': newRole.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await SupabaseService().upsertRecord(_usersCollection, {
        'id': uid,
        'uid': uid,
        'role': newRole.value,
      });
      return Result.success(null);
    } catch (e) {
      debugPrint('❌ updateUserRole Error [$uid -> ${newRole.value}]: $e');
      return Result.failure('Failed to update role in database.', e);
    }
  }

  /// Ensures a RampUser account profile exists for a tenant record with default password "tenant123"
  Future<Result<RampUser>> ensureTenantUserAccount({
    required String tenantId,
    required String tenantName,
    String? email,
    bool mustChangePassword = true,
  }) async {
    final effectiveEmail = (email != null && email.trim().isNotEmpty)
        ? email.trim().toLowerCase()
        : 'tenant_$tenantId@ramp.local';
    final uid = 'user_$tenantId';

    // Attempt creation in Firebase Auth with default password "tenant123"
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: effectiveEmail,
          password: 'tenant123',
        );
      }
    } catch (e) {
      debugPrint('ℹ️ Auth tenant account setup notice [$effectiveEmail]: $e');
    }

    return createOrEnsureUserProfile(
      uid: uid,
      email: effectiveEmail,
      displayName: tenantName,
      role: UserRole.tenant,
      tenantId: tenantId,
      mustChangePassword: mustChangePassword,
    );
  }

  /// Clears the password change requirement after tenant updates default password
  Future<Result<void>> clearMustChangePassword(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'mustChangePassword': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await SupabaseService().upsertRecord(_usersCollection, {
        'id': uid,
        'uid': uid,
        'mustChangePassword': false,
      });
      return Result.success(null);
    } catch (e) {
      debugPrint('❌ clearMustChangePassword Error [$uid]: $e');
      return Result.failure('Failed to clear password change flag.', e);
    }
  }

  /// Listen to real-time user document changes from Firestore
  Stream<RampUser?> userProfileStream(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _firestore
        .collection(_usersCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return RampUser.fromJson(snapshot.data()!, snapshot.id);
    });
  }
}
