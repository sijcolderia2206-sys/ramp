// lib/providers/tenant_providers.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tenant_model.dart';
import '../models/unit_model.dart';
import '../models/payment_model.dart';
import '../models/maintenance_ticket_model.dart';
import '../models/announcement_model.dart';
import '../models/tenant_document_model.dart';
import '../core/supabase_auth_service.dart';
import '../core/supabase_db_service.dart';
import 'landlord_providers.dart';

/// Current Tenant Provider strictly based on authenticated user or active session
final currentTenantProvider = Provider<TenantRecord?>((ref) {
  final authService = SupabaseAuthService();
  final currentUser = authService.currentUser;
  final activeEmail = authService.activeEmail.trim().toLowerCase();
  final tenants = ref.watch(tenantsProvider);

  if (tenants.isEmpty) return null;

  try {
    return tenants.firstWhere((t) {
      if (currentUser != null && t.id == currentUser.id) return true;
      if (t.email != null && t.email!.isNotEmpty && t.email!.toLowerCase() == activeEmail) return true;
      if (currentUser != null && currentUser.email != null && t.email != null && t.email!.toLowerCase() == currentUser.email!.toLowerCase()) return true;
      return false;
    });
  } catch (_) {
    return null;
  }
});

/// Current Tenant Assigned Unit Provider
final currentTenantUnitProvider = Provider<RentalUnit?>((ref) {
  final tenant = ref.watch(currentTenantProvider);
  if (tenant == null) return null;
  final units = ref.watch(unitsProvider);

  try {
    return units.firstWhere((u) {
      if (tenant.unitId.isNotEmpty) {
        return u.id == tenant.unitId;
      }
      return tenant.unitNumber.isNotEmpty && tenant.unitNumber != 'Unassigned' && u.unitNumber == tenant.unitNumber;
    });
  } catch (_) {
    return null;
  }
});

// ============================================================================
// TENANT SPECIFIC PAYMENTS PROVIDER
// ============================================================================
final tenantPaymentsProvider = Provider<List<PaymentRecord>>((ref) {
  final tenant = ref.watch(currentTenantProvider);
  final allPayments = ref.watch(paymentsProvider);

  if (tenant == null) return [];

  return allPayments.where((p) {
    if (p.tenantId != null && p.tenantId!.isNotEmpty) {
      return p.tenantId == tenant.id;
    }
    if (p.unitId.isNotEmpty && tenant.unitId.isNotEmpty) {
      return p.unitId == tenant.unitId;
    }
    return false;
  }).toList();
});

// ============================================================================
// ANNOUNCEMENTS PROVIDER
// ============================================================================
class AnnouncementsNotifier extends StateNotifier<List<AnnouncementRecord>> {
  final SupabaseDbService _dbService = SupabaseDbService();
  StreamSubscription<List<AnnouncementRecord>>? _streamSubscription;

  AnnouncementsNotifier() : super(const []) {
    loadAnnouncements();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    try {
      _streamSubscription = _dbService.streamAnnouncements().listen(
        (liveAnnouncements) {
          if (liveAnnouncements.isNotEmpty) {
            state = liveAnnouncements;
          }
        },
        onError: (e) {
          debugPrint('Realtime announcements stream note: $e');
          loadAnnouncements();
        },
      );
    } catch (e) {
      debugPrint('Realtime announcements subscribe exception: $e');
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadAnnouncements() async {
    try {
      final fetched = await _dbService.fetchAnnouncements();
      state = fetched;
    } catch (e) {
      debugPrint('Announcements fetch note: $e');
      state = const [];
    }
  }

  Future<bool> addAnnouncement(AnnouncementRecord announcement) async {
    state = [announcement, ...state];
    return await _dbService.upsertAnnouncement(announcement);
  }
}

final announcementsProvider = StateNotifierProvider<AnnouncementsNotifier, List<AnnouncementRecord>>((ref) {
  return AnnouncementsNotifier();
});

// ============================================================================
// TENANT SPECIFIC MAINTENANCE TICKETS PROVIDER
// ============================================================================
final tenantTicketsProvider = Provider<List<MaintenanceTicket>>((ref) {
  final tenant = ref.watch(currentTenantProvider);
  final allTickets = ref.watch(maintenanceTicketsProvider);

  if (tenant == null) return [];

  return allTickets.where((t) {
    return t.tenantId != null && t.tenantId == tenant.id;
  }).toList();
});

// ============================================================================
// TENANT DOCUMENTS PROVIDER
// ============================================================================
class TenantDocumentsNotifier extends StateNotifier<List<TenantDocumentRecord>> {
  final Ref _ref;
  final SupabaseDbService _dbService = SupabaseDbService();
  StreamSubscription<List<TenantDocumentRecord>>? _streamSubscription;

  TenantDocumentsNotifier(this._ref) : super(const []) {
    loadDocuments();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    try {
      final tenant = _ref.read(currentTenantProvider);
      _streamSubscription = _dbService.streamTenantDocuments(tenant?.id).listen(
        (liveDocs) {
          if (liveDocs.isNotEmpty) {
            final map = <String, TenantDocumentRecord>{};
            for (final d in state) {
              map[d.id] = d;
            }
            for (final d in liveDocs) {
              map[d.id] = d;
            }
            state = map.values.toList();
          }
        },
        onError: (e) {
          debugPrint('Realtime documents stream note: $e');
          loadDocuments();
        },
      );
    } catch (e) {
      debugPrint('Realtime documents subscribe exception: $e');
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadDocuments() async {
    final tenant = _ref.read(currentTenantProvider);
    if (tenant == null) return;

    try {
      final fetched = await _dbService.fetchTenantDocuments(tenant.id);
      state = fetched;
    } catch (e) {
      debugPrint('Tenant documents fetch note: $e');
      state = const [];
    }
  }

  Future<bool> addDocument(TenantDocumentRecord document) async {
    state = [document, ...state];
    return await _dbService.upsertTenantDocument(document);
  }
}

final tenantDocumentsProvider = StateNotifierProvider<TenantDocumentsNotifier, List<TenantDocumentRecord>>((ref) {
  return TenantDocumentsNotifier(ref);
});

// ============================================================================
// SUPABASE MEDIA STORAGE BUCKET HELPER
// ============================================================================
Future<String?> uploadToRampMedia(XFile file, String folder) async {
  try {
    final client = Supabase.instance.client;
    final bytes = await file.readAsBytes();
    final fileExt = file.name.contains('.') ? file.name.split('.').last : 'jpg';
    final fileName = '$folder/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await client.storage.from('ramp_media').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );

    final publicUrl = client.storage.from('ramp_media').getPublicUrl(fileName);
    return publicUrl;
  } catch (e) {
    debugPrint('Supabase storage upload note: $e');
    // Fallback to local file path when offline or unconfigured bucket
    return file.path;
  }
}
