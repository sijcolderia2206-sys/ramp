// lib/providers/landlord_providers.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/db_result.dart';
import '../models/unit_model.dart';
import '../models/tenant_model.dart';
import '../models/payment_model.dart';
import '../models/maintenance_ticket_model.dart';
import '../models/pending_sync_action.dart';
import '../models/notification_model.dart';
import '../core/mock_data.dart';
import '../core/supabase_db_service.dart';
import '../core/services/local_database_service.dart';
import '../core/services/connectivity_service.dart';

// ==========================================
// 0. SHELL NAVIGATION & FILTER PROVIDERS
// ==========================================
final activeShellTabProvider = StateProvider<int>((ref) => 0);
final financeTabFilterProvider = StateProvider<int>((ref) => 0); // 0: Rent Ledger, 1: Maintenance Expenses, 2: Pending Queue

// ==========================================
// 1. UNITS PROVIDER (Supabase Connected, Offline Cached & Realtime Stream Subscribed)
// ==========================================
class UnitsNotifier extends StateNotifier<List<RentalUnit>> {
  final Ref _ref;
  final SupabaseDbService _dbService = SupabaseDbService();
  final LocalDatabaseService _localDb = LocalDatabaseService();
  StreamSubscription<List<RentalUnit>>? _streamSubscription;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  UnitsNotifier(this._ref) : super(const []) {
    _initAndLoad();
    _subscribeRealtime();
  }

  Future<void> _initAndLoad() async {
    final cached = await _localDb.getUnits();
    if (cached.isNotEmpty) {
      state = cached;
    }
    await loadUnits();
  }

  void _subscribeRealtime() {
    try {
      _streamSubscription = _dbService.streamUnits().listen(
        (liveUnits) {
          if (liveUnits.isNotEmpty) {
            state = liveUnits;
            _localDb.saveUnits(liveUnits);
          }
        },
        onError: (e) {
          debugPrint('Realtime units stream note: $e');
          loadUnits();
        },
      );
    } catch (e) {
      debugPrint('Realtime units subscribe exception: $e');
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadUnits() async {
    try {
      final liveUnits = await _dbService.fetchUnits(limit: 100, offset: 0);
      if (liveUnits.isNotEmpty) {
        state = liveUnits;
        await _localDb.saveUnits(liveUnits);
      } else if (state.isEmpty) {
        state = RampMockData.initialUnits;
        await _localDb.saveUnits(state);
      }
    } catch (e) {
      debugPrint('Supabase units fetch: $e');
      if (state.isEmpty) {
        state = RampMockData.initialUnits;
      }
    }
  }

  Future<void> fetchMore() async {
    if (!_hasMore) return;
    try {
      final additional = await _dbService.fetchUnits(limit: 20, offset: state.length);
      if (additional.isEmpty) {
        _hasMore = false;
      } else {
        final existingIds = state.map((u) => u.id).toSet();
        final filtered = additional.where((u) => !existingIds.contains(u.id)).toList();
        if (filtered.isEmpty) {
          _hasMore = false;
        } else {
          state = [...state, ...filtered];
          await _localDb.saveUnits(state);
        }
      }
    } catch (e) {
      debugPrint('fetchMore units error: $e');
    }
  }

  void clearAll() {
    state = const [];
  }

  Future<DbResult> addUnit(RentalUnit unit) async {
    final isOnline = ConnectivityService().isConnected;
    if (!isOnline) {
      state = [unit, ...state];
      await _localDb.saveUnits(state);
      _ref.read(offlineSyncProvider.notifier).enqueueAction('CREATE_UNIT', unit.toJson());
      return const DbResult.offline();
    }

    final res = await _dbService.upsertUnit(unit);
    if (res.isSuccess) {
      state = [unit, ...state];
      await _localDb.saveUnits(state);
      await _dbService.logAuditAction('CREATE_UNIT', 'Created unit ${unit.unitNumber}');
    }
    return res;
  }

  Future<DbResult> updateUnit(RentalUnit unit) async {
    final isOnline = ConnectivityService().isConnected;
    if (!isOnline) {
      state = state.map((u) => u.id == unit.id ? unit : u).toList();
      await _localDb.saveUnits(state);
      _ref.read(offlineSyncProvider.notifier).enqueueAction('CREATE_UNIT', unit.toJson());
      return const DbResult.offline();
    }

    final res = await _dbService.upsertUnit(unit);
    if (res.isSuccess) {
      state = state.map((u) => u.id == unit.id ? unit : u).toList();
      await _localDb.saveUnits(state);
      await _dbService.logAuditAction('UPDATE_UNIT', 'Updated unit ${unit.unitNumber}');
    }
    return res;
  }

  Future<bool> updateSubmeters(String unitId, double waterCurr, double electricCurr) async {
    final existingUnit = state.where((u) => u.id == unitId).firstOrNull;
    if (existingUnit != null) {
      if (waterCurr < existingUnit.waterReadingCurr || electricCurr < existingUnit.electricReadingCurr) {
        debugPrint('Validation Error: Current submeter reading cannot be lower than previous reading.');
        return false;
      }
    }

    state = state.map((u) {
      if (u.id == unitId) {
        return u.copyWith(
          waterReadingPrev: u.waterReadingCurr,
          waterReadingCurr: waterCurr,
          electricReadingPrev: u.electricReadingCurr,
          electricReadingCurr: electricCurr,
        );
      }
      return u;
    }).toList();
    await _localDb.saveUnits(state);

    final success = await _dbService.updateSubmeters(unitId, waterCurr, electricCurr);
    if (success) {
      await _dbService.logAuditAction('UPDATE_SUBMETERS', 'Updated meters for unit ID $unitId');
    }
    return success;
  }

  Future<bool> updateUnitStatus(String unitId, String newStatus, [String? tenantId, String? tenantName]) async {
    state = state.map((u) {
      if (u.id == unitId) {
        return u.copyWith(
          status: newStatus,
          tenantId: tenantId ?? u.tenantId,
          tenantName: tenantName ?? u.tenantName,
        );
      }
      return u;
    }).toList();
    await _localDb.saveUnits(state);

    final success = await _dbService.updateUnitStatus(unitId, newStatus, tenantId, tenantName);
    if (!success && state.isNotEmpty) {
      final targetUnit = state.firstWhere((u) => u.id == unitId, orElse: () => state.first);
      await _dbService.upsertUnit(targetUnit);
    }
    return true;
  }
}

final unitsProvider = StateNotifierProvider<UnitsNotifier, List<RentalUnit>>((ref) {
  return UnitsNotifier(ref);
});

// ==========================================
// 2. TENANTS PROVIDER (Supabase Connected, Offline Cached & Realtime Stream Subscribed)
// ==========================================
class TenantsNotifier extends StateNotifier<List<TenantRecord>> {
  final Ref _ref;
  final SupabaseDbService _dbService = SupabaseDbService();
  final LocalDatabaseService _localDb = LocalDatabaseService();
  StreamSubscription<List<TenantRecord>>? _streamSubscription;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  TenantsNotifier(this._ref) : super(const []) {
    _initAndLoad();
    _subscribeRealtime();
  }

  Future<void> _initAndLoad() async {
    final cached = await _localDb.getTenants();
    if (cached.isNotEmpty) {
      state = cached;
    }
    await loadTenants();
  }

  void _subscribeRealtime() {
    try {
      _streamSubscription = _dbService.streamTenants().listen(
        (liveTenants) {
          if (liveTenants.isNotEmpty) {
            state = liveTenants;
            _localDb.saveTenants(liveTenants);
          }
        },
        onError: (e) {
          debugPrint('Realtime tenants stream note: $e');
          loadTenants();
        },
      );
    } catch (e) {
      debugPrint('Realtime tenants subscribe exception: $e');
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadTenants() async {
    try {
      final liveTenants = await _dbService.fetchTenants(limit: 100, offset: 0);
      if (liveTenants.isNotEmpty) {
        state = liveTenants;
        await _localDb.saveTenants(liveTenants);
      } else if (state.isEmpty) {
        state = RampMockData.initialTenants;
        await _localDb.saveTenants(state);
      }
    } catch (e) {
      debugPrint('Supabase tenants fetch: $e');
      if (state.isEmpty) {
        state = RampMockData.initialTenants;
      }
    }
  }

  Future<void> fetchMore() async {
    if (!_hasMore) return;
    try {
      final additional = await _dbService.fetchTenants(limit: 20, offset: state.length);
      if (additional.isEmpty) {
        _hasMore = false;
      } else {
        final existingIds = state.map((t) => t.id).toSet();
        final filtered = additional.where((t) => !existingIds.contains(t.id)).toList();
        if (filtered.isEmpty) {
          _hasMore = false;
        } else {
          state = [...state, ...filtered];
          await _localDb.saveTenants(state);
        }
      }
    } catch (e) {
      debugPrint('fetchMore tenants error: $e');
    }
  }

  void clearAll() {
    state = const [];
  }

  Future<DbResult> addTenant(TenantRecord tenant) async {
    final isOnline = ConnectivityService().isConnected;
    if (!isOnline) {
      state = [tenant, ...state];
      await _localDb.saveTenants(state);
      _ref.read(offlineSyncProvider.notifier).enqueueAction('ADD_TENANT', tenant.toJson());
      return const DbResult.offline();
    }

    final res = await _dbService.upsertTenant(tenant);
    if (res.isSuccess) {
      state = [tenant, ...state];
      await _localDb.saveTenants(state);
      await _dbService.logAuditAction('ADD_TENANT', 'Added tenant ${tenant.name}');
    }
    return res;
  }

  Future<DbResult> updateTenant(TenantRecord tenant) async {
    final isOnline = ConnectivityService().isConnected;
    if (!isOnline) {
      state = state.map((t) => t.id == tenant.id ? tenant : t).toList();
      await _localDb.saveTenants(state);
      _ref.read(offlineSyncProvider.notifier).enqueueAction('UPDATE_TENANT', tenant.toJson());
      return const DbResult.offline();
    }

    final res = await _dbService.upsertTenant(tenant);
    if (res.isSuccess) {
      state = state.map((t) => t.id == tenant.id ? tenant : t).toList();
      await _localDb.saveTenants(state);
      await _dbService.logAuditAction('UPDATE_TENANT', 'Updated tenant ${tenant.name}');
    }
    return res;
  }

  Future<bool> updateTenantBalance(String tenantId, double newBalance) async {
    state = state.map((t) {
      if (t.id == tenantId) {
        final updated = t.copyWith(balance: newBalance);
        final newHealth = _evaluateHealth(updated);
        return updated.copyWith(healthStatus: newHealth);
      }
      return t;
    }).toList();
    await _localDb.saveTenants(state);

    if (state.isNotEmpty) {
      final updatedTenant = state.firstWhere((t) => t.id == tenantId, orElse: () => state.first);
      return await _dbService.updateTenantBalance(tenantId, newBalance, updatedTenant.healthStatus);
    }
    return false;
  }

  Future<bool> toggleTenantConfirmation(String tenantId) async {
    bool newStatus = false;
    state = state.map((t) {
      if (t.id == tenantId) {
        newStatus = !t.isConfirmed;
        return t.copyWith(isConfirmed: newStatus);
      }
      return t;
    }).toList();

    await _localDb.saveTenants(state);
    await _dbService.logAuditAction(
      'CONFIRM_TENANT',
      'Set tenant confirmation to $newStatus for ID $tenantId',
    );
    return await _dbService.updateTenantConfirmation(tenantId, newStatus);
  }

  String _evaluateHealth(TenantRecord t) {
    if (t.balance <= 0) return 'green';
    if (t.isOverdue || t.balance > t.monthlyRent) return 'red';
    return 'yellow';
  }
}

final tenantsProvider = StateNotifierProvider<TenantsNotifier, List<TenantRecord>>((ref) {
  return TenantsNotifier(ref);
});

// ==========================================
// 3. PAYMENTS PROVIDER (Supabase Connected, Offline Cached & Realtime Financial Ledger)
// ==========================================
class PaymentsNotifier extends StateNotifier<List<PaymentRecord>> {
  final Ref _ref;
  final SupabaseDbService _dbService = SupabaseDbService();
  final LocalDatabaseService _localDb = LocalDatabaseService();
  StreamSubscription<List<PaymentRecord>>? _streamSubscription;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  PaymentsNotifier(this._ref) : super(const []) {
    _initAndLoad();
    _subscribeRealtime();
  }

  Future<void> _initAndLoad() async {
    final cached = await _localDb.getPayments();
    if (cached.isNotEmpty) {
      state = cached;
    }
    await loadPayments();
  }

  void _subscribeRealtime() {
    try {
      _streamSubscription = _dbService.streamPayments().listen(
        (livePayments) {
          if (livePayments.isNotEmpty) {
            state = livePayments;
            _localDb.savePayments(livePayments);
          }
        },
        onError: (e) {
          debugPrint('Realtime payments stream note: $e');
          loadPayments();
        },
      );
    } catch (e) {
      debugPrint('Realtime payments subscribe exception: $e');
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadPayments() async {
    try {
      final livePayments = await _dbService.fetchPayments(limit: 100, offset: 0);
      if (livePayments.isNotEmpty) {
        state = livePayments;
        await _localDb.savePayments(livePayments);
      } else if (state.isEmpty) {
        state = RampMockData.initialPayments;
        await _localDb.savePayments(state);
      }
    } catch (e) {
      debugPrint('Supabase payments fetch: $e');
      if (state.isEmpty) {
        state = RampMockData.initialPayments;
      }
    }
  }

  Future<void> fetchMore() async {
    if (!_hasMore) return;
    try {
      final additional = await _dbService.fetchPayments(limit: 20, offset: state.length);
      if (additional.isEmpty) {
        _hasMore = false;
      } else {
        final existingIds = state.map((p) => p.id).toSet();
        final filtered = additional.where((p) => !existingIds.contains(p.id)).toList();
        if (filtered.isEmpty) {
          _hasMore = false;
        } else {
          state = [...state, ...filtered];
          await _localDb.savePayments(state);
        }
      }
    } catch (e) {
      debugPrint('fetchMore payments error: $e');
    }
  }

  void clearAll() {
    state = const [];
  }

  Future<bool> verifyPayment(String paymentId, bool approve) async {
    if (state.isEmpty) return false;
    final payment = state.firstWhere((p) => p.id == paymentId, orElse: () => state.first);

    // Enforce valid status transition: payment must currently be Pending
    if (payment.status != 'Pending') {
      debugPrint('Invalid state transition: Payment $paymentId status is already ${payment.status}');
      return false;
    }

    final newStatus = approve ? 'Paid' : 'Declined';
    state = state.map((p) {
      if (p.id == paymentId) {
        return p.copyWith(status: newStatus);
      }
      return p;
    }).toList();
    await _localDb.savePayments(state);

    if (approve && payment.transactionType == 'Rent' && payment.tenantId != null) {
      final tenants = _ref.read(tenantsProvider);
      final tenantList = tenants.where((t) => t.id == payment.tenantId).toList();
      if (tenantList.isNotEmpty) {
        final tenant = tenantList.first;
        final newBalance = (tenant.balance - payment.amount).clamp(0.0, double.infinity);
        _ref.read(tenantsProvider.notifier).updateTenantBalance(tenant.id, newBalance);
      }
      // Auto-advance unit submeter readings for next billing cycle
      final units = _ref.read(unitsProvider);
      final unitList = units.where((u) => u.id == payment.unitId || u.unitNumber == payment.unitNumber).toList();
      if (unitList.isNotEmpty) {
        final unit = unitList.first;
        _ref.read(unitsProvider.notifier).updateSubmeters(unit.id, unit.waterReadingCurr, unit.electricReadingCurr);
      }
    }

    final success = await _dbService.updatePaymentStatus(paymentId, newStatus);
    if (success) {
      await _dbService.logAuditAction('VERIFY_PAYMENT', '${approve ? "Approved" : "Declined"} payment $paymentId');
      _ref.read(notificationsProvider.notifier).addNotification(
        'Payment ${approve ? "Approved" : "Declined"}',
        'Payment of ₱${payment.amount.toStringAsFixed(2)} for Unit ${payment.unitNumber} was ${approve ? "approved" : "declined"}.',
        'payment',
      );
    }
    return success;
  }

  Future<DbResult> recordPayment(PaymentRecord payment) async {
    final isOnline = ConnectivityService().isConnected;
    if (!isOnline) {
      state = [payment, ...state];
      await _localDb.savePayments(state);

      if (payment.status == 'Paid' && payment.transactionType == 'Rent' && payment.tenantId != null) {
        final tenants = _ref.read(tenantsProvider);
        final tenantList = tenants.where((t) => t.id == payment.tenantId).toList();
        if (tenantList.isNotEmpty) {
          final tenant = tenantList.first;
          final newBalance = (tenant.balance - payment.amount).clamp(0.0, double.infinity);
          _ref.read(tenantsProvider.notifier).updateTenantBalance(tenant.id, newBalance);
        }
      }

      _ref.read(offlineSyncProvider.notifier).enqueueAction('RECORD_PAYMENT', payment.toJson());
      return const DbResult.offline();
    }

    final res = await _dbService.insertPayment(payment);
    if (res.isSuccess) {
      state = [payment, ...state];
      await _localDb.savePayments(state);

      if (payment.status == 'Paid' && payment.transactionType == 'Rent' && payment.tenantId != null) {
        final tenants = _ref.read(tenantsProvider);
        final tenantList = tenants.where((t) => t.id == payment.tenantId).toList();
        if (tenantList.isNotEmpty) {
          final tenant = tenantList.first;
          final newBalance = (tenant.balance - payment.amount).clamp(0.0, double.infinity);
          _ref.read(tenantsProvider.notifier).updateTenantBalance(tenant.id, newBalance);
        }
        // Auto-advance unit submeter readings for next billing cycle
        final units = _ref.read(unitsProvider);
        final unitList = units.where((u) => u.id == payment.unitId || u.unitNumber == payment.unitNumber).toList();
        if (unitList.isNotEmpty) {
          final unit = unitList.first;
          _ref.read(unitsProvider.notifier).updateSubmeters(unit.id, unit.waterReadingCurr, unit.electricReadingCurr);
        }
      }
      await _dbService.logAuditAction('RECORD_PAYMENT', 'Recorded payment ${payment.referenceNumber}');
    }
    return res;
  }

  Future<DbResult> upsertMaintenanceExpense({
    required String ticketId,
    required String unitId,
    required String unitNumber,
    required double amount,
    required String description,
  }) async {
    final existingIndex = state.indexWhere((p) => p.ticketId == ticketId && p.transactionType == 'Maintenance');

    PaymentRecord target;
    if (existingIndex != -1) {
      target = state[existingIndex].copyWith(amount: amount, remarks: description);
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex) target else state[i]
      ];
    } else {
      target = PaymentRecord(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        unitId: unitId,
        unitNumber: unitNumber,
        amount: amount,
        paymentDate: DateTime.now(),
        paymentMethod: 'Cash',
        referenceNumber: 'TICKET-$ticketId',
        status: 'Paid',
        transactionType: 'Maintenance',
        ticketId: ticketId,
        remarks: description,
      );
      state = [target, ...state];
    }
    await _localDb.savePayments(state);

    return await _dbService.insertPayment(target);
  }
}

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, List<PaymentRecord>>((ref) {
  return PaymentsNotifier(ref);
});

// ==========================================
// 4. MAINTENANCE TICKETS PROVIDER (Supabase Connected, Offline Cached & Realtime Pipeline)
// ==========================================
class MaintenanceTicketsNotifier extends StateNotifier<List<MaintenanceTicket>> {
  final Ref _ref;
  final SupabaseDbService _dbService = SupabaseDbService();
  final LocalDatabaseService _localDb = LocalDatabaseService();
  StreamSubscription<List<MaintenanceTicket>>? _streamSubscription;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  MaintenanceTicketsNotifier(this._ref) : super(const []) {
    _initAndLoad();
    _subscribeRealtime();
  }

  Future<void> _initAndLoad() async {
    final cached = await _localDb.getTickets();
    if (cached.isNotEmpty) {
      state = cached;
    }
    await loadTickets();
  }

  void _subscribeRealtime() {
    try {
      _streamSubscription = _dbService.streamTickets().listen(
        (liveTickets) {
          if (liveTickets.isNotEmpty) {
            state = liveTickets;
            _localDb.saveTickets(liveTickets);
          }
        },
        onError: (e) {
          debugPrint('Realtime tickets stream note: $e');
          loadTickets();
        },
      );
    } catch (e) {
      debugPrint('Realtime tickets subscribe exception: $e');
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadTickets() async {
    try {
      final liveTickets = await _dbService.fetchTickets(limit: 100, offset: 0);
      if (liveTickets.isNotEmpty) {
        state = liveTickets;
        await _localDb.saveTickets(liveTickets);
      } else if (state.isEmpty) {
        state = RampMockData.initialTickets;
        await _localDb.saveTickets(state);
      }
    } catch (e) {
      debugPrint('Supabase tickets fetch: $e');
      if (state.isEmpty) {
        state = RampMockData.initialTickets;
      }
    }
  }

  Future<void> fetchMore() async {
    if (!_hasMore) return;
    try {
      final additional = await _dbService.fetchTickets(limit: 20, offset: state.length);
      if (additional.isEmpty) {
        _hasMore = false;
      } else {
        final existingIds = state.map((t) => t.id).toSet();
        final filtered = additional.where((t) => !existingIds.contains(t.id)).toList();
        if (filtered.isEmpty) {
          _hasMore = false;
        } else {
          state = [...state, ...filtered];
          await _localDb.saveTickets(state);
        }
      }
    } catch (e) {
      debugPrint('fetchMore tickets error: $e');
    }
  }

  void clearAll() {
    state = const [];
  }

  Future<DbResult> addTicket(MaintenanceTicket ticket) async {
    final isOnline = ConnectivityService().isConnected;
    if (!isOnline) {
      state = [ticket, ...state];
      await _localDb.saveTickets(state);
      _ref.read(offlineSyncProvider.notifier).enqueueAction('ADD_TICKET', ticket.toJson());
      return const DbResult.offline();
    }

    final res = await _dbService.upsertTicket(ticket);
    if (res.isSuccess) {
      state = [ticket, ...state];
      await _localDb.saveTickets(state);
      await _dbService.logAuditAction('DISPATCH_TICKET', 'Dispatched maintenance ticket ${ticket.title}');
      _ref.read(notificationsProvider.notifier).addNotification(
        'Maintenance Ticket Created',
        'Ticket "${ticket.title}" for Unit ${ticket.unitNumber} was submitted.',
        'maintenance',
      );
    }
    return res;
  }

  Future<DbResult> updateTicket(MaintenanceTicket ticket) async {
    final isOnline = ConnectivityService().isConnected;
    if (!isOnline) {
      state = state.map((t) => t.id == ticket.id ? ticket : t).toList();
      await _localDb.saveTickets(state);
      _ref.read(offlineSyncProvider.notifier).enqueueAction('ADD_TICKET', ticket.toJson());
      return const DbResult.offline();
    }

    final res = await _dbService.upsertTicket(ticket);
    if (res.isSuccess) {
      state = state.map((t) => t.id == ticket.id ? ticket : t).toList();
      await _localDb.saveTickets(state);
      await _dbService.logAuditAction('UPDATE_TICKET', 'Updated maintenance ticket ${ticket.title}');
      _ref.read(notificationsProvider.notifier).addNotification(
        'Maintenance Ticket Updated',
        'Ticket "${ticket.title}" for Unit ${ticket.unitNumber} was updated.',
        'maintenance',
      );
    }
    return res;
  }

  Future<bool> updateStageVisit(String ticketId, DateTime visitDate, String timeSlot) async {
    state = state.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(
          stage: 'Estimate',
          visitDate: visitDate,
          visitTimeSlot: timeSlot,
        );
      }
      return t;
    }).toList();
    await _localDb.saveTickets(state);

    if (state.isNotEmpty) {
      final target = state.firstWhere((t) => t.id == ticketId, orElse: () => state.first);
      await _dbService.logAuditAction('STAGE_VISIT_SCHEDULED', 'Scheduled visit for Unit ${target.unitNumber}: ${target.title}');
      final res = await _dbService.upsertTicket(target);
      if (res.isSuccess) {
        _ref.read(notificationsProvider.notifier).addNotification(
          'Inspection Visit Scheduled',
          'Visit scheduled for Unit ${target.unitNumber} on ${visitDate.month}/${visitDate.day}.',
          'maintenance',
        );
      }
      return res.isSuccess;
    }
    return false;
  }

  Future<bool> updateStageEstimate(
    String ticketId,
    double estimatedCost,
    List<String> items, {
    bool isTenantChargeable = false,
  }) async {
    state = state.map((t) {
      if (t.id == ticketId) {
        final updated = t.copyWith(
          stage: 'Schedule Repair',
          estimatedCost: estimatedCost,
          replacementItems: items,
          isTenantChargeable: isTenantChargeable,
        );

        _ref.read(paymentsProvider.notifier).upsertMaintenanceExpense(
              ticketId: ticketId,
              unitId: updated.unitId,
              unitNumber: updated.unitNumber,
              amount: estimatedCost,
              description: 'Estimate for ${updated.title} (${updated.unitNumber})${isTenantChargeable ? " [Tenant Chargeable]" : ""}',
            );

        return updated;
      }
      return t;
    }).toList();
    await _localDb.saveTickets(state);

    if (state.isNotEmpty) {
      final target = state.firstWhere((t) => t.id == ticketId, orElse: () => state.first);
      await _dbService.logAuditAction('STAGE_ESTIMATE_UPDATED', 'Updated estimate (PHP $estimatedCost) for Unit ${target.unitNumber}');
      final res = await _dbService.upsertTicket(target);
      return res.isSuccess;
    }
    return false;
  }

  Future<bool> updateStageRepair(
    String ticketId,
    String repairer,
    DateTime repairDate,
    String timeSlot, {
    String? repairerPhone,
    bool markCompleted = false,
  }) async {
    state = state.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(
          stage: markCompleted ? 'Completed' : 'Schedule Repair',
          repairer: repairer,
          repairerPhone: repairerPhone,
          repairDate: repairDate,
          repairTimeSlot: timeSlot,
        );
      }
      return t;
    }).toList();
    await _localDb.saveTickets(state);

    if (state.isNotEmpty) {
      final target = state.firstWhere((t) => t.id == ticketId, orElse: () => state.first);
      await _dbService.logAuditAction('STAGE_REPAIR_SCHEDULED', 'Assigned contractor $repairer for Unit ${target.unitNumber}');
      final res = await _dbService.upsertTicket(target);
      return res.isSuccess;
    }
    return false;
  }

  Future<bool> updateStageComplete(
    String ticketId, {
    required String completionSummary,
    String? photoAfter,
  }) async {
    state = state.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(
          stage: 'Completed',
          completionSummary: completionSummary,
          photoAfter: photoAfter ?? t.photoAfter,
        );
      }
      return t;
    }).toList();
    await _localDb.saveTickets(state);

    if (state.isNotEmpty) {
      final target = state.firstWhere((t) => t.id == ticketId, orElse: () => state.first);
      await _dbService.logAuditAction('STAGE_REPAIR_COMPLETED', 'Completed repair for Unit ${target.unitNumber}: ${target.title}');
      final res = await _dbService.upsertTicket(target);
      return res.isSuccess;
    }
    return false;
  }

  Future<bool> rateTicket(String ticketId, int rating, [String? feedback]) async {
    state = state.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(rating: rating, tenantFeedback: feedback);
      }
      return t;
    }).toList();
    await _localDb.saveTickets(state);

    if (state.isNotEmpty) {
      final target = state.firstWhere((t) => t.id == ticketId, orElse: () => state.first);
      final res = await _dbService.upsertTicket(target);
      if (res.isSuccess) {
        await _dbService.logAuditAction('RATE_TICKET', 'Rated ticket $ticketId with $rating stars');
      }
      return res.isSuccess;
    }
    return false;
  }
}

final maintenanceTicketsProvider =
    StateNotifierProvider<MaintenanceTicketsNotifier, List<MaintenanceTicket>>((ref) {
  return MaintenanceTicketsNotifier(ref);
});

// ==========================================
// 5. NOTIFICATIONS PROVIDER
// ==========================================
class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  final SupabaseDbService _dbService = SupabaseDbService();
  StreamSubscription<List<AppNotification>>? _streamSubscription;

  NotificationsNotifier() : super(const []) {
    loadNotifications();
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    try {
      _streamSubscription = _dbService.streamNotifications().listen(
        (liveNotifications) {
          if (liveNotifications.isNotEmpty) {
            state = liveNotifications;
          }
        },
        onError: (e) {
          debugPrint('Realtime notifications stream note: $e');
          loadNotifications();
        },
      );
    } catch (e) {
      debugPrint('Realtime notifications subscribe exception: $e');
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadNotifications() async {
    try {
      final fetched = await _dbService.fetchNotifications();
      if (fetched.isNotEmpty) {
        state = fetched;
      }
    } catch (e) {
      debugPrint('Notifications fetch error: $e');
    }
  }

  Future<void> markAllAsRead() async {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
    await _dbService.markAllNotificationsAsRead();
  }

  Future<void> markAsRead(String id) async {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
    await _dbService.markNotificationAsRead(id);
  }

  Future<void> addNotification(String title, String message, String type) async {
    final notification = AppNotification(
      id: 'n_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );
    state = [notification, ...state];
    await _dbService.insertNotification(notification);
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});

// ==========================================
// 6. OFFLINE SYNC PROVIDER
// ==========================================
class OfflineSyncNotifier extends StateNotifier<List<PendingSyncAction>> {
  final SupabaseDbService _dbService = SupabaseDbService();
  final LocalDatabaseService _localDb = LocalDatabaseService();
  final ConnectivityService _connectivity = ConnectivityService();
  StreamSubscription<bool>? _connectivitySubscription;

  OfflineSyncNotifier() : super([]) {
    _loadPersistedQueue();
    _listenToConnectivity();
  }

  Future<void> _loadPersistedQueue() async {
    final cached = await _localDb.getPendingActions();
    if (cached.isNotEmpty) {
      state = cached;
      if (_connectivity.isConnected) {
        flushQueue();
      }
    }
  }

  void _listenToConnectivity() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline && state.isNotEmpty) {
        flushQueue();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void enqueueAction(String actionType, Map<String, dynamic> payload) async {
    final action = PendingSyncAction(
      id: 'sync_${DateTime.now().millisecondsSinceEpoch}',
      actionType: actionType,
      payload: payload,
      timestamp: DateTime.now(),
    );
    state = [...state, action];
    await _localDb.savePendingActions(state);

    if (_connectivity.isConnected) {
      flushQueue();
    }
  }

  Future<int> flushQueue() async {
    if (state.isEmpty) return 0;
    final actionsToSync = List<PendingSyncAction>.from(state);
    final remainingActions = <PendingSyncAction>[];
    int syncedCount = 0;

    for (final action in actionsToSync) {
      bool success = false;
      String? errorMsg;
      try {
        switch (action.actionType) {
          case 'ADD_TENANT':
          case 'UPDATE_TENANT':
            final tenant = TenantRecord.fromJson(action.payload);
            final res = await _dbService.upsertTenant(tenant);
            success = res.isSuccess;
            if (!success) errorMsg = res.errorMessage;
            break;
          case 'CREATE_UNIT':
            final unit = RentalUnit.fromJson(action.payload);
            final res = await _dbService.upsertUnit(unit);
            success = res.isSuccess;
            if (!success) errorMsg = res.errorMessage;
            break;
          case 'RECORD_PAYMENT':
            final payment = PaymentRecord.fromJson(action.payload);
            final res = await _dbService.insertPayment(payment);
            success = res.isSuccess;
            if (!success) errorMsg = res.errorMessage;
            break;
          case 'ADD_TICKET':
            final ticket = MaintenanceTicket.fromJson(action.payload);
            final res = await _dbService.upsertTicket(ticket);
            success = res.isSuccess;
            if (!success) errorMsg = res.errorMessage;
            break;
          default:
            success = true;
        }
      } catch (e) {
        debugPrint('Failed to sync action ${action.id}: $e');
        success = false;
        errorMsg = e.toString();
      }

      if (success) {
        syncedCount++;
      } else {
        remainingActions.add(action.copyWith(
          status: 'failed',
          errorMessage: errorMsg ?? 'Database operation failed or network unreachable.',
        ));
      }
    }

    state = remainingActions;
    await _localDb.savePendingActions(state);
    return syncedCount;
  }

  void dismissAction(String actionId) async {
    state = state.where((a) => a.id != actionId).toList();
    await _localDb.savePendingActions(state);
  }

  void retryAction(String actionId) {
    if (_connectivity.isConnected) {
      flushQueue();
    }
  }
}

final offlineSyncProvider = StateNotifierProvider<OfflineSyncNotifier, List<PendingSyncAction>>((ref) {
  return OfflineSyncNotifier();
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  return ConnectivityService().onConnectivityChanged;
});

final supabaseRealtimeStatusProvider = StreamProvider<bool>((ref) {
  return SupabaseDbService().realtimeStatusStream;
});

// ==========================================
// 7. FINANCIAL ANALYTICS SELECTORS
// ==========================================
final grossRevenueProvider = Provider<double>((ref) {
  final payments = ref.watch(paymentsProvider);
  return payments
      .where((p) => p.transactionType == 'Rent' && p.status == 'Paid')
      .fold(0.0, (sum, p) => sum + p.amount);
});

final totalMaintenanceExpensesProvider = Provider<double>((ref) {
  final payments = ref.watch(paymentsProvider);
  return payments
      .where((p) => p.transactionType == 'Maintenance' && p.status == 'Paid')
      .fold(0.0, (sum, p) => sum + p.amount);
});

final netOperatingIncomeProvider = Provider<double>((ref) {
  final gross = ref.watch(grossRevenueProvider);
  final expenses = ref.watch(totalMaintenanceExpensesProvider);
  return gross - expenses;
});

final expectedMonthlyRentProvider = Provider<double>((ref) {
  final units = ref.watch(unitsProvider);
  return units
      .where((u) => u.status == 'Occupied')
      .fold(0.0, (sum, u) => sum + u.monthlyRent);
});

final collectionRateProvider = Provider<double>((ref) {
  final gross = ref.watch(grossRevenueProvider);
  final expected = ref.watch(expectedMonthlyRentProvider);
  if (expected <= 0) return 0.0;
  final rate = (gross / expected) * 100.0;
  return rate.clamp(0.0, 100.0);
});

final pendingPaymentsQueueProvider = Provider<List<PaymentRecord>>((ref) {
  final payments = ref.watch(paymentsProvider);
  return payments.where((p) => p.status == 'Pending').toList();
});

/// Ledger-derived Tenant Balance Provider
final tenantLedgerBalanceProvider = Provider.family<double, String>((ref, tenantId) {
  final tenants = ref.watch(tenantsProvider);
  final tenantList = tenants.where((t) => t.id == tenantId).toList();
  if (tenantList.isEmpty) return 0.0;

  final tenant = tenantList.first;
  return tenant.balance;
});

// ==========================================
// 8. GEMINI AI PROPERTY ASSISTANT
// ==========================================
class GeminiAssistantNotifier extends StateNotifier<AsyncValue<String>> {
  final Ref _ref;

  GeminiAssistantNotifier(this._ref) : super(const AsyncValue.data(''));

  Future<void> askAssistant(String prompt) async {
    state = const AsyncValue.loading();
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      final units = _ref.read(unitsProvider);
      final tenants = _ref.read(tenantsProvider);
      final gross = _ref.read(grossRevenueProvider);
      final noi = _ref.read(netOperatingIncomeProvider);

      final totalUnits = units.length;
      final occupiedUnits = units.where((u) => u.status == 'Occupied').length;
      final vacancyRate = totalUnits > 0 ? ((totalUnits - occupiedUnits) / totalUnits * 100).toStringAsFixed(1) : '0';

      if (apiKey.isNotEmpty) {
        try {
          final model = GenerativeModel(
            model: 'gemini-1.5-flash',
            apiKey: apiKey,
          );

          final contextPrompt = '''
You are the RAMP AI Property Assistant for Apex Rental Properties.
Portfolio Context:
- Total Units: $totalUnits ($occupiedUnits Occupied, ${totalUnits - occupiedUnits} Vacant)
- Vacancy Rate: $vacancyRate%
- Monthly Gross Revenue: PHP ${gross.toStringAsFixed(2)}
- Net Operating Income (NOI): PHP ${noi.toStringAsFixed(2)}
- Total Active Tenants: ${tenants.length}

User Question: $prompt
Answer concisely and professionally with actionable recommendations based on the portfolio context.
''';

          final content = [Content.text(contextPrompt)];
          final response = await model.generateContent(content);
          if (response.text != null && response.text!.isNotEmpty) {
            state = AsyncValue.data(response.text!);
            return;
          }
        } catch (genAiErr) {
          debugPrint('Gemini API call note: $genAiErr');
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final lowercasePrompt = prompt.toLowerCase();
      String responseText = '';

      if (lowercasePrompt.contains('overdue') || lowercasePrompt.contains('unpaid') || lowercasePrompt.contains('late')) {
        final overdueTenants = tenants.where((t) => t.isOverdue || t.healthStatus == 'red').toList();
        if (overdueTenants.isEmpty) {
          responseText = 'Great news! No tenants are currently overdue in your portfolio.';
        } else {
          final names = overdueTenants.map((t) => '${t.name} (Unit ${t.unitNumber}) - ₱${t.balance.toStringAsFixed(0)}').join(', ');
          responseText = 'You have ${overdueTenants.length} overdue tenant(s): $names.';
        }
      } else if (lowercasePrompt.contains('repair') || lowercasePrompt.contains('maintenance') || lowercasePrompt.contains('ticket')) {
        final tickets = _ref.read(maintenanceTicketsProvider);
        final openTickets = tickets.where((t) => t.stage != 'Completed' && t.stage != 'Resolved').toList();
        final emergencyCount = openTickets.where((t) => t.priority.toLowerCase() == 'emergency').length;
        responseText = 'You have ${openTickets.length} active repair ticket(s) ($emergencyCount Emergency priority).';
      } else if (lowercasePrompt.contains('deposit') || lowercasePrompt.contains('security')) {
        final totalDeposit = tenants.fold(0.0, (sum, t) => sum + t.securityDeposit);
        responseText = 'Total security deposits held across ${tenants.length} tenants: ₱${totalDeposit.toStringAsFixed(2)}.';
      } else if (lowercasePrompt.contains('vacancy') || lowercasePrompt.contains('occupancy')) {
        responseText = 'Your portfolio has $totalUnits total units. Occupancy rate is ${(100 - double.parse(vacancyRate)).toStringAsFixed(1)}% ($occupiedUnits occupied, ${totalUnits - occupiedUnits} vacant). Vacancy rate stands at $vacancyRate%.';
      } else if (lowercasePrompt.contains('noi') || lowercasePrompt.contains('revenue') || lowercasePrompt.contains('income')) {
        responseText = 'Monthly Gross Rent Collected is ₱${gross.toStringAsFixed(2)}. Net Operating Income (NOI) is ₱${noi.toStringAsFixed(2)}.';
      } else {
        responseText = 'Portfolio Summary: $totalUnits Units ($occupiedUnits Occupied), Gross Revenue: ₱${gross.toStringAsFixed(2)}, NOI: ₱${noi.toStringAsFixed(2)}.\n\nTip: Add `GEMINI_API_KEY` to your `.env` file to enable live Google Gemini AI insights.';
      }

      state = AsyncValue.data(responseText);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final geminiAssistantProvider =
    StateNotifierProvider<GeminiAssistantNotifier, AsyncValue<String>>((ref) {
  return GeminiAssistantNotifier(ref);
});

// ==========================================
// 10. TENANTS FILTERING & DERIVED PROVIDERS
// ==========================================
enum TenantFilter { all, active, overdue, inactive }

class TenantFilterNotifier extends Notifier<TenantFilter> {
  @override
  TenantFilter build() => TenantFilter.all;

  void updateFilter(TenantFilter filter) => state = filter;
}

final tenantFilterProvider = NotifierProvider<TenantFilterNotifier, TenantFilter>(
  () => TenantFilterNotifier(),
);

class TenantSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
  void clear() => state = '';
}

final tenantSearchQueryProvider = NotifierProvider<TenantSearchQueryNotifier, String>(
  () => TenantSearchQueryNotifier(),
);

final filteredTenantsProvider = Provider<List<TenantRecord>>((ref) {
  final rawTenants = ref.watch(tenantsProvider);
  final filter = ref.watch(tenantFilterProvider);
  final query = ref.watch(tenantSearchQueryProvider).trim().toLowerCase();

  return rawTenants.where((tenant) {
    bool matchesFilter = true;
    switch (filter) {
      case TenantFilter.active:
        matchesFilter = !tenant.isArchived && tenant.balance == 0;
        break;
      case TenantFilter.overdue:
        matchesFilter = !tenant.isArchived && (tenant.balance > 0 || tenant.isOverdue || tenant.healthStatus == 'red');
        break;
      case TenantFilter.inactive:
        matchesFilter = tenant.isArchived || tenant.healthStatus == 'inactive';
        break;
      case TenantFilter.all:
        matchesFilter = true;
        break;
    }

    if (!matchesFilter) return false;

    if (query.isEmpty) return true;
    final matchesName = tenant.fullName.toLowerCase().contains(query);
    final matchesUnit = tenant.unitNumber.toLowerCase().contains(query);
    final matchesEmail = tenant.email?.toLowerCase().contains(query) ?? false;

    return matchesName || matchesUnit || matchesEmail;
  }).toList();
});

// ==========================================
// 11. MAINTENANCE TICKETS FILTERING & DERIVED PROVIDERS
// ==========================================
enum TicketStatus { all, pending, inProgress, resolved }

class TicketFilterNotifier extends Notifier<TicketStatus> {
  @override
  TicketStatus build() => TicketStatus.pending;

  void updateFilter(TicketStatus filter) => state = filter;
}

final ticketFilterProvider = NotifierProvider<TicketFilterNotifier, TicketStatus>(
  () => TicketFilterNotifier(),
);

class TicketSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
  void clear() => state = '';
}

final ticketSearchQueryProvider = NotifierProvider<TicketSearchQueryNotifier, String>(
  () => TicketSearchQueryNotifier(),
);

final filteredTicketsProvider = Provider<List<MaintenanceTicket>>((ref) {
  final rawTickets = ref.watch(maintenanceTicketsProvider);
  final filter = ref.watch(ticketFilterProvider);
  final query = ref.watch(ticketSearchQueryProvider).trim().toLowerCase();

  return rawTickets.where((ticket) {
    bool matchesFilter = true;
    switch (filter) {
      case TicketStatus.pending:
        matchesFilter = ticket.status == 'Schedule Visit' || ticket.status == 'Pending';
        break;
      case TicketStatus.inProgress:
        matchesFilter = ticket.status == 'Estimate' || ticket.status == 'Schedule Repair' || ticket.status == 'In Progress';
        break;
      case TicketStatus.resolved:
        matchesFilter = ticket.status == 'Completed' || ticket.status == 'Resolved';
        break;
      case TicketStatus.all:
        matchesFilter = true;
        break;
    }

    if (!matchesFilter) return false;

    if (query.isEmpty) return true;
    final matchesUnit = ticket.unitNumber.toLowerCase().contains(query);
    final matchesTitle = ticket.issueTitle.toLowerCase().contains(query);
    final matchesCategory = ticket.category.toLowerCase().contains(query);
    final matchesTenant = ticket.tenantName?.toLowerCase().contains(query) ?? false;

    return matchesUnit || matchesTitle || matchesCategory || matchesTenant;
  }).toList();
});

// ==========================================
// 12. PROPERTY SETTINGS PROVIDER
// ==========================================
class PropertySettings {
  final int rentDueDate;
  final double gracePeriodDays;
  final double standardLateFee;
  final double waterRate;
  final double electricRate;
  final bool overdueSmsAlerts;
  final bool urgentPushNotifications;

  const PropertySettings({
    this.rentDueDate = 5,
    this.gracePeriodDays = 3.0,
    this.standardLateFee = 500.0,
    this.waterRate = 45.0,
    this.electricRate = 12.50,
    this.overdueSmsAlerts = true,
    this.urgentPushNotifications = true,
  });

  PropertySettings copyWith({
    int? rentDueDate,
    double? gracePeriodDays,
    double? standardLateFee,
    double? waterRate,
    double? electricRate,
    bool? overdueSmsAlerts,
    bool? urgentPushNotifications,
  }) {
    return PropertySettings(
      rentDueDate: rentDueDate ?? this.rentDueDate,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
      standardLateFee: standardLateFee ?? this.standardLateFee,
      waterRate: waterRate ?? this.waterRate,
      electricRate: electricRate ?? this.electricRate,
      overdueSmsAlerts: overdueSmsAlerts ?? this.overdueSmsAlerts,
      urgentPushNotifications: urgentPushNotifications ?? this.urgentPushNotifications,
    );
  }
}

class PropertySettingsNotifier extends Notifier<PropertySettings> {
  final LocalDatabaseService _localDb = LocalDatabaseService();

  @override
  PropertySettings build() {
    _loadFromCache();
    return const PropertySettings();
  }

  Future<void> _loadFromCache() async {
    try {
      final map = await _localDb.getPropertySettings();
      if (map != null) {
        state = PropertySettings(
          rentDueDate: map['rentDueDate'] as int? ?? 5,
          gracePeriodDays: (map['gracePeriodDays'] as num?)?.toDouble() ?? 3.0,
          standardLateFee: (map['standardLateFee'] as num?)?.toDouble() ?? 500.0,
          waterRate: (map['waterRate'] as num?)?.toDouble() ?? 45.0,
          electricRate: (map['electricRate'] as num?)?.toDouble() ?? 12.50,
          overdueSmsAlerts: map['overdueSmsAlerts'] as bool? ?? true,
          urgentPushNotifications: map['urgentPushNotifications'] as bool? ?? true,
        );
      }
    } catch (_) {}
  }

  Future<void> _saveToCache() async {
    try {
      await _localDb.savePropertySettings({
        'rentDueDate': state.rentDueDate,
        'gracePeriodDays': state.gracePeriodDays,
        'standardLateFee': state.standardLateFee,
        'waterRate': state.waterRate,
        'electricRate': state.electricRate,
        'overdueSmsAlerts': state.overdueSmsAlerts,
        'urgentPushNotifications': state.urgentPushNotifications,
      });
    } catch (_) {}
  }

  void updateRentDueDate(int day) {
    state = state.copyWith(rentDueDate: day);
    _saveToCache();
  }

  void updateGracePeriod(double days) {
    state = state.copyWith(gracePeriodDays: days);
    _saveToCache();
  }

  void updateStandardLateFee(double fee) {
    state = state.copyWith(standardLateFee: fee);
    _saveToCache();
  }

  void updateWaterRate(double rate) {
    state = state.copyWith(waterRate: rate);
    _saveToCache();
  }

  void updateElectricRate(double rate) {
    state = state.copyWith(electricRate: rate);
    _saveToCache();
  }

  void toggleOverdueSms(bool val) {
    state = state.copyWith(overdueSmsAlerts: val);
    _saveToCache();
  }

  void toggleUrgentNotifications(bool val) {
    state = state.copyWith(urgentPushNotifications: val);
    _saveToCache();
  }
}

final propertySettingsProvider = NotifierProvider<PropertySettingsNotifier, PropertySettings>(
  () => PropertySettingsNotifier(),
);
