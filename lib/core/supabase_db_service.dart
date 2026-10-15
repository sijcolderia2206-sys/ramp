// lib/core/supabase_db_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'db_result.dart';
import '../models/unit_model.dart';
import '../models/tenant_model.dart';
import '../models/payment_model.dart';
import '../models/maintenance_ticket_model.dart';
import '../models/announcement_model.dart';
import '../models/tenant_document_model.dart';
import '../models/notification_model.dart';
import '../models/pending_sync_action.dart';
import 'services/local_database_service.dart';
import 'supabase_auth_service.dart';

class SupabaseDbService {
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('Supabase client uninitialized: $e');
      return null;
    }
  }

  /// Stream of Supabase Realtime Connection Status
  Stream<bool> get realtimeStatusStream {
    try {
      final client = _client;
      if (client == null) return Stream.value(false);
      return Stream.value(true);
    } catch (_) {
      return Stream.value(false);
    }
  }

  // ============================================================================
  // UNITS TABLE OPERATIONS
  // ============================================================================
  Future<List<RentalUnit>> fetchUnits({int limit = 50, int offset = 0}) async {
    final client = _client;
    if (client == null) return [];
    try {
      final response = await client
          .from('units')
          .select()
          .order('unit_number')
          .range(offset, offset + limit - 1);
      final list = <RentalUnit>[];
      for (final json in response) {
        try {
          list.add(RentalUnit.fromJson(Map<String, dynamic>.from(json)));
        } catch (itemErr) {
          debugPrint('fetchUnits item parse note: $itemErr');
        }
      }
      return list;
    } catch (e) {
      debugPrint('fetchUnits exception: $e');
      return [];
    }
  }

  Stream<List<RentalUnit>> streamUnits() {
    final client = _client;
    if (client == null) return const Stream.empty();
    try {
      return client
          .from('units')
          .stream(primaryKey: ['id'])
          .order('unit_number')
          .handleError((err) {
            debugPrint('streamUnits error: $err');
          })
          .map((data) {
            final list = <RentalUnit>[];
            for (final json in data) {
              try {
                list.add(RentalUnit.fromJson(Map<String, dynamic>.from(json)));
              } catch (itemErr) {
                debugPrint('streamUnits item parse note: $itemErr');
              }
            }
            return list;
          });
    } catch (e) {
      debugPrint('streamUnits setup exception: $e');
      return const Stream.empty();
    }
  }

  Future<DbResult> upsertUnit(RentalUnit unit) async {
    final client = _client;
    if (client == null) return const DbResult.failure('Supabase client uninitialized');
    try {
      final user = client.auth.currentUser;
      final payload = unit.toJson();
      if (user != null) {
        payload['landlord_id'] = user.id;
      }
      try {
        await client.from('units').upsert(payload);
      } catch (upsertErr) {
        debugPrint('Extended schema unit upsert note: $upsertErr. Fallback to core schema payload...');
        final corePayload = {
          'id': unit.id,
          'landlord_id': payload['landlord_id'],
          'title': unit.title,
          'unit_number': unit.unitNumber,
          'floor': unit.floor,
          'location': unit.location,
          'monthly_rent': unit.monthlyRent,
          'rent_due_day': unit.rentDueDay,
          'late_fee': unit.lateFee,
          'status': unit.status,
          'tenant_id': unit.tenantId,
          'tenant_name': unit.tenantName,
          'water_reading_prev': unit.waterReadingPrev,
          'water_reading_curr': unit.waterReadingCurr,
          'electric_reading_prev': unit.electricReadingPrev,
          'electric_reading_curr': unit.electricReadingCurr,
        };
        await client.from('units').upsert(corePayload);
      }
      return const DbResult.success();
    } on PostgrestException catch (pErr) {
      debugPrint('upsertUnit PostgrestException: ${pErr.message} (code: ${pErr.code}, details: ${pErr.details})');
      return DbResult.failure('Postgres Error: ${pErr.message}');
    } catch (e) {
      debugPrint('upsertUnit exception: $e');
      return DbResult.failure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> updateUnitStatus(String unitId, String status, [String? tenantId, String? tenantName]) async {
    final client = _client;
    if (client == null) return false;
    try {
      final updateData = <String, dynamic>{
        'status': status,
      };
      if (tenantId != null) updateData['tenant_id'] = tenantId;
      if (tenantName != null) updateData['tenant_name'] = tenantName;

      await client.from('units').update(updateData).eq('id', unitId);
      return true;
    } catch (e) {
      debugPrint('updateUnitStatus note: $e');
      return false;
    }
  }

  Future<bool> updateSubmeters(String unitId, double waterCurr, double electricCurr) async {
    final client = _client;
    if (client == null) return false;
    try {
      final existing = await client.from('units').select('water_reading_curr, electric_reading_curr').eq('id', unitId).maybeSingle();
      final prevWater = existing != null ? (existing['water_reading_curr'] ?? 0.0).toDouble() : 0.0;
      final prevElectric = existing != null ? (existing['electric_reading_curr'] ?? 0.0).toDouble() : 0.0;

      await client.from('units').update({
        'water_reading_prev': prevWater,
        'water_reading_curr': waterCurr,
        'electric_reading_prev': prevElectric,
        'electric_reading_curr': electricCurr,
      }).eq('id', unitId);
      return true;
    } catch (e) {
      debugPrint('updateSubmeters exception: $e');
      return false;
    }
  }

  // ============================================================================
  // TENANTS TABLE OPERATIONS
  // ============================================================================
  Future<List<TenantRecord>> fetchTenants({int limit = 50, int offset = 0}) async {
    final client = _client;
    if (client == null) return [];
    try {
      final response = await client
          .from('tenants')
          .select()
          .order('name')
          .range(offset, offset + limit - 1);
      final list = <TenantRecord>[];
      for (final json in response) {
        try {
          list.add(TenantRecord.fromJson(Map<String, dynamic>.from(json)));
        } catch (itemErr) {
          debugPrint('fetchTenants item parse note: $itemErr');
        }
      }
      return list;
    } catch (e) {
      debugPrint('fetchTenants exception: $e');
      return [];
    }
  }

  Stream<List<TenantRecord>> streamTenants() {
    final client = _client;
    if (client == null) return const Stream.empty();
    try {
      return client
          .from('tenants')
          .stream(primaryKey: ['id'])
          .order('name')
          .handleError((err) {
            debugPrint('streamTenants error: $err');
          })
          .map((data) {
            final list = <TenantRecord>[];
            for (final json in data) {
              try {
                list.add(TenantRecord.fromJson(Map<String, dynamic>.from(json)));
              } catch (itemErr) {
                debugPrint('streamTenants item parse note: $itemErr');
              }
            }
            return list;
          });
    } catch (e) {
      debugPrint('streamTenants setup exception: $e');
      return const Stream.empty();
    }
  }

  Future<DbResult> upsertTenant(TenantRecord tenant) async {
    final client = _client;
    if (client == null) return const DbResult.failure('Supabase client uninitialized');
    try {
      final user = client.auth.currentUser;
      final payload = tenant.toJson();
      payload['health_status'] = tenant.healthStatus;

      if (user != null) {
        payload['landlord_id'] = user.id;
      }

      try {
        await client.from('tenants').upsert(payload);
      } catch (upsertErr) {
        debugPrint('Extended schema tenant upsert note: $upsertErr. Fallback to core schema payload...');
        final corePayload = {
          'id': tenant.id,
          'landlord_id': payload['landlord_id'],
          'name': tenant.name,
          'phone': tenant.phone,
          'email': tenant.email,
          'unit_id': tenant.unitId,
          'unit_number': tenant.unitNumber,
          'monthly_rent': tenant.monthlyRent,
          'balance': tenant.balance,
          'lease_start': tenant.leaseStart.toIso8601String(),
          'lease_end': tenant.leaseEnd.toIso8601String(),
          'due_date': tenant.dueDate.toIso8601String(),
          'messenger_handle': tenant.messengerHandle ?? tenant.facebookUrl,
          'is_archived': tenant.isArchived,
        };
        await client.from('tenants').upsert(corePayload);
      }

      if (tenant.email != null && tenant.email!.trim().isNotEmpty) {
        try {
          final cleanEmail = tenant.email!.trim().toLowerCase();
          // 1. Create the Auth account using REST to avoid logging out the landlord
          // Default password for new tenants is 'Password123!'
          final authUserId = await SupabaseAuthService.createTenantAuthAccount(
            email: cleanEmail,
            password: 'Password123!',
            name: tenant.name,
            tenantId: tenant.id,
            unitId: tenant.unitId,
          );

          // 2. Create the public user profile mapping
          await client.from('users').upsert({
            'id': tenant.id,
            'uid': authUserId ?? tenant.id, // Use real auth UUID if successful
            'email': cleanEmail,
            'display_name': tenant.name,
            'role': 'tenant',
            'tenant_id': tenant.id,
            'unit_id': tenant.unitId,
            'is_approved': true,
          });
        } catch (uErr) {
          debugPrint('User profile creation note for tenant: $uErr');
        }
      }
      return const DbResult.success();
    } on PostgrestException catch (pErr) {
      debugPrint('upsertTenant PostgrestException: ${pErr.message} (code: ${pErr.code}, details: ${pErr.details})');
      return DbResult.failure('Postgres Error: ${pErr.message}');
    } catch (e) {
      debugPrint('upsertTenant exception: $e');
      return DbResult.failure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> updateTenantBalance(String tenantId, double newBalance, String healthStatus) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('tenants').update({
        'balance': newBalance,
      }).eq('id', tenantId);
      return true;
    } catch (e) {
      debugPrint('updateTenantBalance note: $e');
      return false;
    }
  }

  Future<bool> updateTenantConfirmation(String tenantId, bool isConfirmed) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('tenants').update({
        'is_confirmed': isConfirmed,
      }).eq('id', tenantId);

      try {
        await client.from('users').update({
          'is_approved': isConfirmed,
        }).eq('tenant_id', tenantId);
      } catch (uErr) {
        debugPrint('Users table is_approved update note: $uErr');
      }

      return true;
    } catch (e) {
      debugPrint('updateTenantConfirmation note: $e');
      return false;
    }
  }

  // ============================================================================
  // PAYMENTS TABLE OPERATIONS
  // ============================================================================
  Future<List<PaymentRecord>> fetchPayments({int limit = 50, int offset = 0}) async {
    final client = _client;
    if (client == null) return [];
    try {
      final response = await client
          .from('payments')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      final list = <PaymentRecord>[];
      for (final json in response) {
        try {
          list.add(PaymentRecord.fromJson(Map<String, dynamic>.from(json)));
        } catch (itemErr) {
          debugPrint('fetchPayments item parse note: $itemErr');
        }
      }
      return list;
    } catch (e) {
      debugPrint('fetchPayments exception: $e');
      return [];
    }
  }

  Stream<List<PaymentRecord>> streamPayments() {
    final client = _client;
    if (client == null) return const Stream.empty();
    try {
      return client
          .from('payments')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .handleError((err) {
            debugPrint('streamPayments error: $err');
          })
          .map((data) {
            final list = <PaymentRecord>[];
            for (final json in data) {
              try {
                list.add(PaymentRecord.fromJson(Map<String, dynamic>.from(json)));
              } catch (itemErr) {
                debugPrint('streamPayments item parse note: $itemErr');
              }
            }
            return list;
          });
    } catch (e) {
      debugPrint('streamPayments setup exception: $e');
      return const Stream.empty();
    }
  }

  Future<DbResult> insertPayment(PaymentRecord payment) async {
    final client = _client;
    if (client == null) return const DbResult.failure('Supabase client uninitialized');
    try {
      final user = client.auth.currentUser;
      final payload = payment.toJson();
      if (user != null) {
        payload['landlord_id'] = user.id;
      }
      await client.from('payments').insert(payload);

      // Auto-dispatch real-time notification to Supabase
      insertNotification(
        AppNotification(
          id: 'n_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Payment Recorded (${payment.paymentMethod})',
          message: 'Payment ₱${payment.amount.toStringAsFixed(2)} for Unit ${payment.unitNumber} (${payment.tenantName})',
          timestamp: DateTime.now(),
          type: 'payment',
          targetId: payment.id,
        ),
      );

      return const DbResult.success();
    } on PostgrestException catch (pErr) {
      debugPrint('insertPayment PostgrestException: ${pErr.message} (code: ${pErr.code}, details: ${pErr.details})');
      return DbResult.failure('Postgres Error: ${pErr.message}');
    } catch (e) {
      debugPrint('insertPayment exception: $e');
      return DbResult.failure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('payments').update({'status': status}).eq('id', paymentId);
      return true;
    } catch (e) {
      debugPrint('updatePaymentStatus exception: $e');
      return false;
    }
  }

  // ============================================================================
  // MAINTENANCE TICKETS TABLE OPERATIONS
  // ============================================================================
  Future<List<MaintenanceTicket>> fetchTickets({int limit = 50, int offset = 0}) async {
    final client = _client;
    if (client == null) return [];
    try {
      final response = await client
          .from('maintenance_tickets')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      final list = <MaintenanceTicket>[];
      for (final json in response) {
        try {
          list.add(MaintenanceTicket.fromJson(Map<String, dynamic>.from(json)));
        } catch (itemErr) {
          debugPrint('fetchTickets item parse note: $itemErr');
        }
      }
      return list;
    } catch (e) {
      debugPrint('fetchTickets exception: $e');
      return [];
    }
  }

  Stream<List<MaintenanceTicket>> streamTickets() {
    final client = _client;
    if (client == null) return const Stream.empty();
    try {
      return client
          .from('maintenance_tickets')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .handleError((err) {
            debugPrint('streamTickets error: $err');
          })
          .map((data) {
            final list = <MaintenanceTicket>[];
            for (final json in data) {
              try {
                list.add(MaintenanceTicket.fromJson(Map<String, dynamic>.from(json)));
              } catch (itemErr) {
                debugPrint('streamTickets item parse note: $itemErr');
              }
            }
            return list;
          });
    } catch (e) {
      debugPrint('streamTickets setup exception: $e');
      return const Stream.empty();
    }
  }

  Future<DbResult> upsertTicket(MaintenanceTicket ticket) async {
    final client = _client;
    if (client == null) return const DbResult.failure('Supabase client uninitialized');
    try {
      final user = client.auth.currentUser;
      final payload = ticket.toJson();
      if (user != null) {
        payload['landlord_id'] = user.id;
      }
      try {
        await client.from('maintenance_tickets').upsert(payload);
      } catch (upsertErr) {
        debugPrint('Extended ticket upsert note: $upsertErr. Fallback to core ticket payload...');
        final corePayload = {
          'id': ticket.id,
          'landlord_id': payload['landlord_id'],
          'unit_id': ticket.unitId,
          'unit_number': ticket.unitNumber,
          'tenant_id': ticket.tenantId,
          'tenant_name': ticket.tenantName,
          'title': ticket.title,
          'description': ticket.description,
          'category': ticket.unitArea,
          'priority': ticket.priority,
          'status': ticket.stage,
          'estimated_cost': ticket.estimatedCost,
          'sla_due_date': ticket.slaDueDate.toIso8601String(),
          'created_at': ticket.createdAt.toIso8601String(),
        };
        await client.from('maintenance_tickets').upsert(corePayload);
      }

      // Auto-dispatch real-time notification to Supabase
      insertNotification(
        AppNotification(
          id: 'n_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Maintenance Ticket (${ticket.stage})',
          message: 'Ticket "${ticket.title}" for Unit ${ticket.unitNumber} is in stage: ${ticket.stage}',
          timestamp: DateTime.now(),
          type: 'maintenance',
          targetId: ticket.id,
        ),
      );

      return const DbResult.success();
    } on PostgrestException catch (pErr) {
      debugPrint('upsertTicket PostgrestException: ${pErr.message} (code: ${pErr.code}, details: ${pErr.details})');
      return DbResult.failure('Postgres Error: ${pErr.message}');
    } catch (e) {
      debugPrint('upsertTicket exception: $e');
      return DbResult.failure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ============================================================================
  // AUDIT LOGS
  // ============================================================================
  Future<bool> logAuditAction(String action, String details) async {
    final client = _client;
    if (client == null) return false;
    try {
      final user = client.auth.currentUser;
      await client.from('audit_logs').insert({
        'id': 'log_${DateTime.now().millisecondsSinceEpoch}',
        'landlord_id': user?.id ?? 'system',
        'action': action,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('logAuditAction exception: $e');
      return false;
    }
  }

  // ============================================================================
  // ANNOUNCEMENTS TABLE OPERATIONS
  // ============================================================================
  Future<List<AnnouncementRecord>> fetchAnnouncements() async {
    final client = _client;
    if (client == null) return [];
    try {
      final response = await client
          .from('announcements')
          .select()
          .order('timestamp', ascending: false);
      final list = <AnnouncementRecord>[];
      for (final json in response) {
        try {
          list.add(AnnouncementRecord.fromJson(Map<String, dynamic>.from(json)));
        } catch (itemErr) {
          debugPrint('fetchAnnouncements item parse note: $itemErr');
        }
      }
      return list;
    } catch (e) {
      debugPrint('fetchAnnouncements exception: $e');
      return [];
    }
  }

  Stream<List<AnnouncementRecord>> streamAnnouncements() {
    final client = _client;
    if (client == null) return const Stream.empty();
    try {
      return client
          .from('announcements')
          .stream(primaryKey: ['id'])
          .order('timestamp', ascending: false)
          .handleError((err) {
            debugPrint('streamAnnouncements error: $err');
          })
          .map((data) {
            final list = <AnnouncementRecord>[];
            for (final json in data) {
              try {
                list.add(AnnouncementRecord.fromJson(Map<String, dynamic>.from(json)));
              } catch (itemErr) {
                debugPrint('streamAnnouncements item parse note: $itemErr');
              }
            }
            return list;
          });
    } catch (e) {
      debugPrint('streamAnnouncements setup exception: $e');
      return const Stream.empty();
    }
  }

  Future<bool> upsertAnnouncement(AnnouncementRecord announcement) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('announcements').upsert(announcement.toJson());
      return true;
    } catch (e) {
      debugPrint('upsertAnnouncement note: $e');
      return false;
    }
  }

  // ============================================================================
  // TENANT DOCUMENTS TABLE OPERATIONS
  // ============================================================================
  Future<List<TenantDocumentRecord>> fetchTenantDocuments([String? tenantId]) async {
    final client = _client;
    if (client == null) return [];
    try {
      final response = (tenantId != null && tenantId.isNotEmpty)
          ? await client
              .from('tenant_documents')
              .select()
              .eq('tenant_id', tenantId)
              .order('uploaded_at', ascending: false)
          : await client
              .from('tenant_documents')
              .select()
              .order('uploaded_at', ascending: false);
      final list = <TenantDocumentRecord>[];
      for (final json in response) {
        try {
          list.add(TenantDocumentRecord.fromJson(Map<String, dynamic>.from(json)));
        } catch (itemErr) {
          debugPrint('fetchTenantDocuments item parse note: $itemErr');
        }
      }
      return list;
    } catch (e) {
      debugPrint('fetchTenantDocuments exception: $e');
      return [];
    }
  }

  Stream<List<TenantDocumentRecord>> streamTenantDocuments([String? tenantId]) {
    final client = _client;
    if (client == null) return const Stream.empty();
    try {
      return client
          .from('tenant_documents')
          .stream(primaryKey: ['id'])
          .order('uploaded_at', ascending: false)
          .handleError((err) {
            debugPrint('streamTenantDocuments error: $err');
          })
          .map((data) {
            final docs = <TenantDocumentRecord>[];
            for (final json in data) {
              try {
                docs.add(TenantDocumentRecord.fromJson(Map<String, dynamic>.from(json)));
              } catch (itemErr) {
                debugPrint('streamTenantDocuments item parse note: $itemErr');
              }
            }
            if (tenantId != null && tenantId.isNotEmpty) {
              return docs.where((d) => d.tenantId == tenantId).toList();
            }
            return docs;
          });
    } catch (e) {
      debugPrint('streamTenantDocuments setup exception: $e');
      return const Stream.empty();
    }
  }

  Future<bool> upsertTenantDocument(TenantDocumentRecord document) async {
    final client = _client;
    if (client == null) return false;
    try {
      final payload = document.toJson();
      try {
        await client.from('tenant_documents').upsert(payload);
      } catch (upsertErr) {
        debugPrint('Extended document upsert note: $upsertErr. Fallback to core document payload...');
        payload.remove('file_url');
        await client.from('tenant_documents').upsert(payload);
      }
      return true;
    } catch (e) {
      debugPrint('upsertTenantDocument note: $e');
      return false;
    }
  }

  // ============================================================================
  // NOTIFICATIONS TABLE OPERATIONS
  // ============================================================================
  Future<List<AppNotification>> fetchNotifications() async {
    final client = _client;
    if (client == null) return [];
    try {
      final response = await client
          .from('notifications')
          .select()
          .order('timestamp', ascending: false);
      final list = <AppNotification>[];
      for (final json in response) {
        try {
          list.add(AppNotification.fromJson(Map<String, dynamic>.from(json)));
        } catch (itemErr) {
          debugPrint('fetchNotifications item parse note: $itemErr');
        }
      }
      return list;
    } catch (e) {
      debugPrint('fetchNotifications exception: $e');
      return [];
    }
  }

  Stream<List<AppNotification>> streamNotifications() {
    final client = _client;
    if (client == null) return const Stream.empty();
    try {
      return client
          .from('notifications')
          .stream(primaryKey: ['id'])
          .order('timestamp', ascending: false)
          .handleError((err) {
            debugPrint('streamNotifications error: $err');
          })
          .map((data) {
            final list = <AppNotification>[];
            for (final json in data) {
              try {
                list.add(AppNotification.fromJson(Map<String, dynamic>.from(json)));
              } catch (itemErr) {
                debugPrint('streamNotifications item parse note: $itemErr');
              }
            }
            return list;
          });
    } catch (e) {
      debugPrint('streamNotifications setup exception: $e');
      return const Stream.empty();
    }
  }

  Future<bool> insertNotification(AppNotification notification) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('notifications').insert(notification.toJson());
      return true;
    } catch (e) {
      debugPrint('insertNotification note: $e');
      return false;
    }
  }

  Future<bool> markAllNotificationsAsRead() async {
    final client = _client;
    if (client == null) return false;
    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('is_read', false);
      return true;
    } catch (e) {
      debugPrint('markAllNotificationsAsRead note: $e');
      return false;
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      return true;
    } catch (e) {
      debugPrint('markNotificationAsRead note: $e');
      return false;
    }
  }

  // ============================================================================
  // OFFLINE PENDING SYNC QUEUE PROCESSING
  // ============================================================================
  Future<int> processPendingSyncQueue() async {
    final localDb = LocalDatabaseService();
    final pendingActions = await localDb.getPendingActions();
    if (pendingActions.isEmpty) return 0;

    final remaining = <PendingSyncAction>[];
    int syncedCount = 0;

    for (final action in pendingActions) {
      bool success = false;
      try {
        switch (action.actionType) {
          case 'ADD_TENANT':
            final tenant = TenantRecord.fromJson(action.payload);
            final res = await upsertTenant(tenant);
            success = res.isSuccess;
            break;
          case 'CREATE_UNIT':
            final unit = RentalUnit.fromJson(action.payload);
            final res = await upsertUnit(unit);
            success = res.isSuccess;
            break;
          case 'RECORD_PAYMENT':
            final payment = PaymentRecord.fromJson(action.payload);
            final res = await insertPayment(payment);
            success = res.isSuccess;
            if (success && payment.status == 'Paid' && payment.transactionType == 'Rent' && payment.tenantId != null) {
              try {
                final client = _client;
                if (client != null) {
                  final existingTenant = await client.from('tenants').select('balance, monthly_rent').eq('id', payment.tenantId!).maybeSingle();
                  if (existingTenant != null) {
                    final currBal = (existingTenant['balance'] ?? 0.0).toDouble();
                    final newBal = (currBal - payment.amount).clamp(0.0, double.infinity);
                    final monthlyRent = (existingTenant['monthly_rent'] ?? 0.0).toDouble();
                    final health = (newBal <= 0) ? 'green' : (newBal > monthlyRent ? 'red' : 'yellow');
                    await updateTenantBalance(payment.tenantId!, newBal, health);
                  }
                }
              } catch (bErr) {
                debugPrint('Note syncing tenant balance for queued payment: $bErr');
              }
            }
            break;
          case 'ADD_TICKET':
            final ticket = MaintenanceTicket.fromJson(action.payload);
            final res = await upsertTicket(ticket);
            success = res.isSuccess;
            break;
          default:
            success = true;
        }
      } catch (e) {
        debugPrint('processPendingSyncQueue error for ${action.id}: $e');
        success = false;
      }

      if (success) {
        syncedCount++;
      } else {
        final newRetryCount = action.retryCount + 1;
        if (newRetryCount < 5) {
          remaining.add(action.copyWith(retryCount: newRetryCount, status: 'failed'));
        } else {
          debugPrint('Dead-letter queue: Dropped action ${action.id} (${action.actionType}) after 5 failed sync retries.');
        }
      }
    }

    await localDb.savePendingActions(remaining);
    return syncedCount;
  }
}
