import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_role.dart';
import '../network/result.dart';
import 'supabase_service.dart';
import 'persistence_queue.dart';
import '../network/supabase/supabase_config.dart';

/// Clean Repository interface for User management
abstract class IUserRepository {
  Future<Result<RampUser>> getUserProfile(String uid);
  Future<Result<void>> upsertUserProfile(RampUser user);
  Future<Result<RampUser>> createOrEnsureUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required UserRole role,
    String? tenantId,
    String? landlordId,
    bool mustChangePassword = false,
  });
  Future<Result<void>> updateUserRole(String uid, UserRole newRole);
  Future<Result<RampUser>> ensureTenantUserAccount({
    required String tenantId,
    required String tenantName,
    String? email,
    bool mustChangePassword = true,
  });
  Future<Result<void>> clearMustChangePassword(String uid);
  Stream<RampUser?> userProfileStream(String uid);
}

/// Database service dedicated to User Profile & Role management in Supabase (Primary via SupabaseService & PersistenceQueue)
class UserDatabaseService implements IUserRepository {
  UserDatabaseService();

  static const String _usersCollection = 'users';

  /// Fetch user profile by UID (Primary source of truth: Supabase)
  @override
  Future<Result<RampUser>> getUserProfile(String uid) async {
    try {
      if (uid.trim().isEmpty) {
        return Result.failure('Invalid user UID provided.');
      }

      final supaRes = await SupabaseService().loadTable(_usersCollection);
      final usersData = supaRes.dataOrNull ?? [];
      final matched = usersData.firstWhere(
        (u) => u['uid'] == uid || u['id'] == uid,
        orElse: () => <String, dynamic>{},
      );
      
      if (matched.isEmpty) {
        return Result.failure(
            'User document not found in database for UID: $uid');
      }

      final rampUser = RampUser.fromJson(matched, uid);
      return Result.success(rampUser);
    } catch (e, stack) {
      debugPrint('❌ getUserProfile Exception [$uid]: $e\n$stack');
      return Result.failure('Failed to load user profile from database.', e);
    }
  }

  /// Save or update user profile in Supabase
  @override
  Future<Result<void>> upsertUserProfile(RampUser user) async {
    try {
      final userMap = user.toJson();
      userMap['id'] = user.uid;

      // Queue sync to Supabase master database
      PersistenceQueue.instance.enqueueUpsert(_usersCollection, user.uid, userMap);

      return Result.success(null);
    } catch (e, stack) {
      debugPrint('❌ upsertUserProfile Exception [${user.uid}]: $e\n$stack');
      return Result.failure('Failed to save user profile in database.', e);
    }
  }

  /// Create user profile upon registration or fallback login
  @override
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

  /// Super Admin functionality: Update user role in Supabase
  @override
  Future<Result<void>> updateUserRole(String uid, UserRole newRole) async {
    try {
      PersistenceQueue.instance.enqueueUpsert(_usersCollection, uid, {
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
  @override
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

    try {
      if (Firebase.apps.isNotEmpty) {
        FirebaseApp secondaryApp;
        try {
          secondaryApp = Firebase.app('SecondaryApp');
        } catch (e) {
          secondaryApp = await Firebase.initializeApp(
            name: 'SecondaryApp',
            options: Firebase.app().options,
          );
        }
        await FirebaseAuth.instanceFor(app: secondaryApp)
            .createUserWithEmailAndPassword(
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
  @override
  Future<Result<void>> clearMustChangePassword(String uid) async {
    try {
      PersistenceQueue.instance.enqueueUpsert(_usersCollection, uid, {
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

  /// Listen to real-time user document changes from Supabase
  @override
  Stream<RampUser?> userProfileStream(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    
    // Supabase streaming implementation using client
    return SupabaseConfig.client
        .from(_usersCollection)
        .stream(primaryKey: ['id'])
        .eq('uid', uid)
        .map((data) {
          if (data.isEmpty) return null;
          final mapped = SupabaseService.toCamelCaseMap(data.first);
          return RampUser.fromJson(mapped, uid);
        });
  }
}
