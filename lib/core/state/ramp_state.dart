import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../services/firestore_service.dart';
import '../services/supabase_service.dart';
import '../services/persistence_queue.dart';
import '../services/audit_service.dart';

export '../../models/models.dart';

/// Monthly Payment Chart Data
class MonthlyPaymentData {
  final String monthLabel;
  final double collectedAmount;
  final double dueAmount;

  const MonthlyPaymentData({
    required this.monthLabel,
    required this.collectedAmount,
    required this.dueAmount,
  });
}

/// --- Immutable Global App State ---
class RampState {
  final String currentRole; // Always 'landlord'
  final int
      activeNavIndex; // 0: Home, 1: Properties, 2: Maintenance, 3: Tenants, 4: Profile
  final List<Unit> units;
  final List<Tenant> tenants;
  final List<PaymentData> payments;
  final List<Ticket> tickets;
  final List<AppEvent> events;
  final List<RecordChange> activities;
  final List<AppNotification> notifications;
  final List<MonthlyPaymentData> monthlyChartData;
  final List<ExpenseItem> expenses;

  const RampState({
    required this.currentRole,
    required this.activeNavIndex,
    required this.units,
    required this.tenants,
    required this.payments,
    required this.tickets,
    required this.events,
    required this.activities,
    required this.notifications,
    required this.monthlyChartData,
    this.expenses = const [],
  });

  bool get isLandlord => true;
  bool get isTenant => false;

  int get unreadNotificationsCount =>
      notifications.where((n) => !n.isRead).length;

  int get totalUnits => units.length;
  int get totalTenants => tenants.length;
  int get occupiedUnits => units.where((u) => u.isOccupied).length;

  double get occupancyRate {
    if (units.isEmpty) return 0.0;
    return (occupiedUnits / totalUnits) * 100;
  }

  /// Sum of all verified ('Paid') payments
  double get totalRevenue {
    return payments
        .where((p) => p.isRent && p.isPaid)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Sum of all expenses
  double get totalOperatingExpenses {
    double expenseTotal = expenses.fold(0.0, (sum, e) => sum + e.amount);
    double ticketTotal = tickets.fold(0.0, (sum, t) => sum + t.cost);
    return expenseTotal + ticketTotal;
  }

  /// Net Operating Income (Revenue - Expenses)
  double get netOperatingIncome => totalRevenue - totalOperatingExpenses;

  double get monthlyCollection => totalRevenue;

  double get pendingDues {
    return payments
        .where((p) => p.isPending)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  List<PaymentData> get upcomingDueNotifications {
    final now = DateTime.now();
    final threeDaysLater = now.add(const Duration(days: 3));
    return payments.where((p) {
      if (p.isPaid) return false;
      return p.paymentDate.isBefore(threeDaysLater);
    }).toList();
  }

  List<RecordChange> get recentActivities {
    final list = List<RecordChange>.from(activities);
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list.take(5).toList();
  }

  RampState copyWith({
    String? currentRole,
    int? activeNavIndex,
    List<Unit>? units,
    List<Tenant>? tenants,
    List<PaymentData>? payments,
    List<Ticket>? tickets,
    List<AppEvent>? events,
    List<RecordChange>? activities,
    List<AppNotification>? notifications,
    List<MonthlyPaymentData>? monthlyChartData,
    List<ExpenseItem>? expenses,
  }) {
    return RampState(
      currentRole: currentRole ?? this.currentRole,
      activeNavIndex: activeNavIndex ?? this.activeNavIndex,
      units: units ?? this.units,
      tenants: tenants ?? this.tenants,
      payments: payments ?? this.payments,
      tickets: tickets ?? this.tickets,
      events: events ?? this.events,
      activities: activities ?? this.activities,
      notifications: notifications ?? this.notifications,
      monthlyChartData: monthlyChartData ?? this.monthlyChartData,
      expenses: expenses ?? this.expenses,
    );
  }
}

/// --- StateNotifier State Engine ---
class RampNotifier extends StateNotifier<RampState> {
  RampNotifier() : super(_initialState);

  static final DateTime _now = DateTime.now();

  static final RampState _initialState = RampState(
    currentRole: 'landlord',
    activeNavIndex: 0,
    units: [
      Unit(
        id: 'u1',
        name: 'Executive Studio 1',
        title: 'Executive Studio 1',
        unitNumber: 'Unit 1',
        floor: '1st Floor',
        rent: 8500.0,
        status: 'Occupied',
        description:
            'Clean executive studio with private bathroom, split aircon, and fiber Wi-Fi.',
        amenities: ['1 Bed', '1 Bath', 'Aircon', 'Fiber Wi-Fi'],
        inclusions: ['Water', 'Electricity', 'Wifi'],
        tenantId: 't2',
        tenantName: 'Juan Dela Cruz',
        bedrooms: 1,
        bathrooms: 1,
        area: 28.0,
      ),
      Unit(
        id: 'u2',
        name: 'Deluxe Suite 2',
        title: 'Deluxe Suite 2',
        unitNumber: 'Unit 2',
        floor: '1st Floor',
        rent: 12000.0,
        status: 'Occupied',
        description:
            'Spacious 2-bedroom suite occupied by Maria Santos. Features kitchen counter and garden view.',
        amenities: ['2 Bed', '1 Bath', 'Inverter Aircon', 'Balcony'],
        inclusions: ['Water', 'Electricity', 'Wifi'],
        tenantId: 't1',
        tenantName: 'Maria Santos',
        bedrooms: 2,
        bathrooms: 1,
        area: 45.0,
      ),
      Unit(
        id: 'u3',
        name: 'Penthouse Loft 3',
        title: 'Penthouse Loft 3',
        unitNumber: 'Unit 3',
        floor: '2nd Floor',
        rent: 16500.0,
        status: 'Vacant',
        description:
            'Premium penthouse loft with scenic river views. High ceiling and secure access.',
        amenities: ['2 Bed', '2 Bath', 'River View', '24/7 Security'],
        inclusions: ['Water', 'Electricity', 'Wifi'],
        tenantId: null,
        tenantName: null,
        bedrooms: 2,
        bathrooms: 2,
        area: 60.0,
      ),
      Unit(
        id: 'u4',
        name: 'Executive Suite 4',
        title: 'Executive Suite 4',
        unitNumber: 'Unit 4',
        floor: '2nd Floor',
        rent: 10500.0,
        status: 'Occupied',
        description:
            'Executive 1-bedroom apartment with dedicated workspace and secure parking.',
        amenities: ['1 Bed', '1 Bath', 'Parking Slot', 'Water Heater'],
        inclusions: ['Water', 'Electricity'],
        tenantId: 't3',
        tenantName: 'Carlos Ramos',
        bedrooms: 1,
        bathrooms: 1,
        area: 32.0,
      ),
      Unit(
        id: 'u5',
        name: 'Garden Suite 5',
        title: 'Garden Suite 5',
        unitNumber: 'Unit 5',
        floor: '1st Floor',
        rent: 9500.0,
        status: 'Vacant',
        description:
            'Ground-floor garden suite with direct courtyard access. Quiet environment.',
        amenities: ['1 Bed', '1 Bath', 'Garden Patio', 'Wi-Fi Ready'],
        inclusions: ['Water', 'Electricity', 'Wifi'],
        tenantId: null,
        tenantName: null,
        bedrooms: 1,
        bathrooms: 1,
        area: 28.0,
      ),
    ],
    tenants: [
      Tenant(
        id: 't1',
        name: 'Maria Santos',
        unitId: 'u2',
        unitNumber: 'Unit 2',
        phone: '0918-222-3344',
        email: 'maria.santos@gmail.com',
        monthlyRent: 12000.0,
        leaseStart: DateTime(2026, 3, 1),
        leaseEnd: DateTime(2027, 3, 1),
        status: 'Active',
      ),
      Tenant(
        id: 't2',
        name: 'Juan Dela Cruz',
        unitId: 'u1',
        unitNumber: 'Unit 1',
        phone: '0917-111-2233',
        email: 'juan.delacruz@gmail.com',
        monthlyRent: 8500.0,
        leaseStart: DateTime(2026, 1, 15),
        leaseEnd: DateTime(2027, 1, 15),
        status: 'Active',
      ),
      Tenant(
        id: 't3',
        name: 'Carlos Ramos',
        unitId: 'u4',
        unitNumber: 'Unit 4',
        phone: '0919-333-4455',
        email: 'carlos.ramos@gmail.com',
        monthlyRent: 10500.0,
        leaseStart: DateTime(2026, 6, 10),
        leaseEnd: DateTime(2027, 6, 10),
        status: 'Active',
      ),
    ],
    payments: [
      PaymentData(
        id: 'p_001',
        unitId: 'u2',
        unitNumber: 'Unit 2',
        tenantId: 't1',
        tenantName: 'Maria Santos',
        amount: 12000.0,
        month: 'Oct',
        date: _now.subtract(const Duration(hours: 3)),
        method: 'GCash',
        proofImageUrl:
            'https://images.unsplash.com/photo-1556742049-0a67e0e854f3?w=800',
        referenceNumber: 'GC-902182910',
        status: 'Pending',
        remarks: 'October rent payment via GCash app.',
      ),
      PaymentData(
        id: 'p_002',
        unitId: 'u1',
        unitNumber: 'Unit 1',
        tenantId: 't2',
        tenantName: 'Juan Dela Cruz',
        amount: 8500.0,
        month: 'Oct',
        date: _now.subtract(const Duration(hours: 14)),
        method: 'Maya',
        proofImageUrl:
            'https://images.unsplash.com/photo-1580519542036-c47de6196ba5?w=800',
        referenceNumber: 'MY-819201928',
        status: 'Pending',
        remarks: 'October rent payment via Maya.',
      ),
      PaymentData(
        id: 'p_003',
        unitId: 'u4',
        unitNumber: 'Unit 4',
        tenantId: 't3',
        tenantName: 'Carlos Ramos',
        amount: 10500.0,
        month: 'Sep',
        date: _now.subtract(const Duration(days: 4)),
        method: 'Bank Transfer',
        proofImageUrl:
            'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800',
        referenceNumber: 'BDO-772910283',
        status: 'Paid',
        remarks: 'Verified rent payment for Unit 4.',
      ),
    ],
    tickets: [
      Ticket(
        id: 'tkt_001',
        unitId: 'u2',
        unitNumber: 'Unit 2',
        tenantId: 't1',
        tenantName: 'Maria Santos',
        title: 'Bathroom Sink Leakage',
        description:
            'Water pipe beneath the bathroom sink has a steady drip leak onto cabinet shelf.',
        category: 'Plumbing',
        priority: 'High',
        photos: [
          'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800',
        ],
        status: 'Schedule Visit',
        createdAt: _now.subtract(const Duration(hours: 18)),
        assignedToName: 'Alex Rivera',
      ),
      Ticket(
        id: 'tkt_002',
        unitId: 'u1',
        unitNumber: 'Unit 1',
        tenantId: 't2',
        tenantName: 'Juan Dela Cruz',
        title: 'Aircon Cleaning & Filter Wash',
        description:
            'Scheduled quarterly aircon unit cleaning and filter replacement.',
        category: 'Appliance',
        priority: 'Medium',
        photos: [],
        status: 'Schedule Repair',
        createdAt: _now.subtract(const Duration(days: 2)),
        assignedToName: 'Alex Rivera',
      ),
      Ticket(
        id: 'tkt_003',
        unitId: 'u4',
        unitNumber: 'Unit 4',
        tenantId: 't3',
        tenantName: 'Carlos Ramos',
        title: 'Main Door Lock Inspection',
        description: 'Door lock cylinder maintenance and lubricate latch.',
        category: 'General',
        priority: 'Low',
        photos: [],
        status: 'Completed',
        createdAt: _now.subtract(const Duration(days: 5)),
        assignedToName: 'Alex Rivera',
      ),
    ],
    events: [
      AppEvent(
        id: 'evt_1',
        title: 'Unit 1 Monthly Rent Due',
        date: _now,
        type: 'Payment Due Date',
        unitNumber: 'Unit 1',
        description: 'Juan Dela Cruz rent due date (₱8,500).',
        unitId: 'u1',
        tenantId: 't2',
      ),
      AppEvent(
        id: 'evt_2',
        title: 'Unit 2 Plumbing Inspection',
        date: _now,
        type: 'Maintenance Schedule',
        unitNumber: 'Unit 2',
        description: 'Plumbing service appointment.',
        unitId: 'u2',
        ticketId: 'tkt_001',
      ),
    ],
    activities: [
      RecordChange(
        id: 'act_1',
        entityType: 'Payment',
        entityId: 'p_002',
        action: 'CREATED',
        description: 'Juan Dela Cruz submitted ₱8,500 via Maya for Unit 1',
        timestamp: _now.subtract(const Duration(minutes: 15)),
        unitId: 'u1',
        tenantId: 't2',
      ),
      RecordChange(
        id: 'act_2',
        entityType: 'Ticket',
        entityId: 'tkt_001',
        action: 'CREATED',
        description:
            'Maria Santos created High Priority Plumbing Ticket for Unit 2',
        timestamp: _now.subtract(const Duration(hours: 2)),
        unitId: 'u2',
        tenantId: 't1',
      ),
    ],
    notifications: [
      AppNotification(
        id: 'notif_1',
        title: 'Payment Verification Required',
        message: 'Maria Santos submitted ₱12,000 via GCash for Unit 2.',
        timestamp: _now.subtract(const Duration(minutes: 25)),
        isRead: false,
        entityType: 'payment',
        entityId: 'p_001',
      ),
      AppNotification(
        id: 'notif_2',
        title: 'New Maintenance Ticket',
        message: 'Bathroom Sink Leakage logged for Unit 2 (High Priority).',
        timestamp: _now.subtract(const Duration(hours: 2)),
        isRead: false,
        entityType: 'ticket',
        entityId: 'tkt_001',
      ),
    ],
    monthlyChartData: const [
      MonthlyPaymentData(
          monthLabel: 'May', collectedAmount: 38000, dueAmount: 40000),
      MonthlyPaymentData(
          monthLabel: 'Jun', collectedAmount: 42000, dueAmount: 42000),
      MonthlyPaymentData(
          monthLabel: 'Jul', collectedAmount: 39500, dueAmount: 40500),
      MonthlyPaymentData(
          monthLabel: 'Aug', collectedAmount: 45000, dueAmount: 47000),
      MonthlyPaymentData(
          monthLabel: 'Sep', collectedAmount: 41000, dueAmount: 43500),
      MonthlyPaymentData(
          monthLabel: 'Oct', collectedAmount: 31000, dueAmount: 51500),
    ],
    expenses: [
      ExpenseItem(
        id: 'exp_001',
        title: 'Plumbing Pipe & Sink Drain Fittings',
        category: 'Maintenance',
        amount: 1500.0,
        date: _now.subtract(const Duration(days: 3)),
        unitId: 'u2',
        unitNumber: 'Unit 2',
        notes: 'Replaced corroded PVC drainage pipe beneath bathroom sink.',
      ),
      ExpenseItem(
        id: 'exp_002',
        title: 'Property High-Speed Fiber Internet',
        category: 'Utilities',
        amount: 2800.0,
        date: _now.subtract(const Duration(days: 7)),
        notes: 'Monthly high-speed Wi-Fi router subscription for Units 1 to 5.',
      ),
    ],
  );

  Future<void> loadFromFirestore() async {
    final supabase = SupabaseService();
    final firestoreService = FirestoreService();
    final data = await supabase.loadCoreData();
    final units = data['units'] ?? const <Map<String, dynamic>>[];
    final tenants = data['tenants'] ?? const <Map<String, dynamic>>[];
    final payments = data['payments'] ?? const <Map<String, dynamic>>[];
    final tickets =
        data['maintenanceTickets'] ?? const <Map<String, dynamic>>[];

    state = state.copyWith(
      units: units.isEmpty
          ? state.units
          : units.map(firestoreService.unitFromMap).toList(),
      tenants: tenants.isEmpty
          ? state.tenants
          : tenants.map(firestoreService.tenantFromMap).toList(),
      payments: payments.isEmpty
          ? state.payments
          : payments.map(firestoreService.paymentFromMap).toList(),
      tickets: tickets.isEmpty
          ? state.tickets
          : tickets.map(firestoreService.ticketFromMap).toList(),
    );
  }

  void updateTicketStatus(String ticketId, String newStatus) {
    final updatedTickets = state.tickets.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(
          status: newStatus,
          statusHistory: [
            ...t.statusHistory,
            TicketStatusHistoryEntry(
              status: newStatus,
              timestamp: DateTime.now(),
              note: 'Status advanced to $newStatus',
            ),
          ],
        );
      }
      return t;
    }).toList();
    state = state.copyWith(tickets: updatedTickets);
  }

  void scheduleTicketVisit(
      String ticketId, DateTime visitDate, String timeWindow) {
    final updatedTickets = state.tickets.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(
          status: 'Schedule Visit',
          visitScheduledAt: visitDate,
          visitTimeWindow: timeWindow,
          statusHistory: [
            ...t.statusHistory,
            TicketStatusHistoryEntry(
              status: 'Schedule Visit',
              timestamp: DateTime.now(),
              note:
                  'Visit scheduled for ${DateFormat('MMM dd, yyyy').format(visitDate)} ($timeWindow)',
            ),
          ],
        );
      }
      return t;
    }).toList();
    state = state.copyWith(tickets: updatedTickets);
  }

  void markTicketVisitDone(String ticketId) {
    final updatedTickets = state.tickets.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(
          status: 'Estimate',
          statusHistory: [
            ...t.statusHistory,
            TicketStatusHistoryEntry(
              status: 'Estimate',
              timestamp: DateTime.now(),
              note: 'Inspection visit completed. Awaiting estimate.',
            ),
          ],
        );
      }
      return t;
    }).toList();
    state = state.copyWith(tickets: updatedTickets);
  }

  void submitTicketEstimate(
      String ticketId, double amount, List<String> replacedItems) {
    Ticket? targetTicket;
    final updatedTickets = state.tickets.map((t) {
      if (t.id == ticketId) {
        targetTicket = t.copyWith(
          estimatedCost: amount,
          vendorCost: amount,
          actualCost: amount,
          replacementItems: replacedItems,
          status: 'Schedule Repair',
          statusHistory: [
            ...t.statusHistory,
            TicketStatusHistoryEntry(
              status: 'Schedule Repair',
              timestamp: DateTime.now(),
              note:
                  'Estimate saved (₱${amount.toStringAsFixed(2)} for ${replacedItems.join(", ")}). Ready to schedule repair.',
            ),
          ],
        );
        return targetTicket!;
      }
      return t;
    }).toList();

    state = state.copyWith(tickets: updatedTickets);

    // Automatically log Maintenance expense into Unit's payment / ledger history
    if (targetTicket != null) {
      final maintenancePayment = PaymentData(
        id: 'maint_pay_${DateTime.now().millisecondsSinceEpoch}',
        month: DateFormat('MMM').format(DateTime.now()),
        amount: amount,
        paymentMethod: 'Maintenance',
        method: 'Maintenance',
        date: DateTime.now(),
        paymentDate: DateTime.now(),
        status: 'Paid',
        unitId: targetTicket!.unitId ?? 'u1',
        unitNumber: targetTicket!.unitNumber,
        tenantId: targetTicket!.tenantId ?? '',
        tenantName: targetTicket!.tenantName,
        referenceNumber:
            'MAINT-${targetTicket!.id.substring(0, targetTicket!.id.length.clamp(0, 6))}',
        remarks: 'Maintenance Repair Estimate: ${replacedItems.join(", ")}',
        otherCharge: amount,
      );
      addPayment(maintenancePayment);
    }
  }

  void scheduleTicketRepair(String ticketId, DateTime repairDate,
      String timeWindow, String contractor) {
    final updatedTickets = state.tickets.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(
          status: 'Schedule Repair',
          repairScheduledAt: repairDate,
          repairTimeWindow: timeWindow,
          repairer: contractor,
          assignedToName: contractor,
          statusHistory: [
            ...t.statusHistory,
            TicketStatusHistoryEntry(
              status: 'Schedule Repair',
              timestamp: DateTime.now(),
              note:
                  'Repair scheduled for ${DateFormat('MMM dd, yyyy').format(repairDate)} ($timeWindow) by $contractor',
            ),
          ],
        );
      }
      return t;
    }).toList();
    state = state.copyWith(tickets: updatedTickets);
  }

  void markTicketCompleted(String ticketId,
      {String? completionPhoto, String? summary}) {
    final updatedTickets = state.tickets.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(
          status: 'Completed',
          photoAfter: completionPhoto ?? t.photoAfter,
          completionSummary: summary ?? t.completionSummary,
          statusHistory: [
            ...t.statusHistory,
            TicketStatusHistoryEntry(
              status: 'Completed',
              timestamp: DateTime.now(),
              note: 'Repair completed. ${summary ?? ""}',
            ),
          ],
        );
      }
      return t;
    }).toList();
    state = state.copyWith(tickets: updatedTickets);
  }

  void addPayment(PaymentData payment) {
    state = state.copyWith(payments: [payment, ...state.payments]);
  }

  void approvePayment(String paymentId) {
    final payments = state.payments
        .map((p) => p.id == paymentId ? p.copyWith(status: 'Paid') : p)
        .toList();
    state = state.copyWith(payments: payments);
  }

  void declinePayment(String paymentId, String reason) {
    final payments = state.payments
        .map((p) => p.id == paymentId
            ? p.copyWith(status: 'Declined', declineReason: reason)
            : p)
        .toList();
    state = state.copyWith(payments: payments);
  }

  void revertToPendingPayment(String paymentId) {
    final payments = state.payments
        .map((p) => p.id == paymentId
            ? p.copyWith(status: 'Pending', declineReason: null)
            : p)
        .toList();
    state = state.copyWith(payments: payments);
  }

  void deletePayment(String paymentId) {
    final payments = state.payments.where((p) => p.id != paymentId).toList();
    state = state.copyWith(payments: payments);
  }

  void addTicket(Ticket ticket) {
    state = state.copyWith(tickets: [ticket, ...state.tickets]);
  }

  /// Navigation Bar Index
  void setNavIndex(int index) {
    HapticFeedback.selectionClick();
    state = state.copyWith(activeNavIndex: index);
  }

  /// Sets Role explicitly
  void setRole(String role) {
    HapticFeedback.mediumImpact();
    state = state.copyWith(currentRole: role);
  }

  void toggleRole() {
    setRole(state.currentRole == 'landlord' ? 'tenant' : 'landlord');
  }

  // --- Notifications Actions ---

  void markNotificationAsRead(String id) {
    final updated = state.notifications.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void markAllNotificationsAsRead() {
    final updated =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  void addNotification(AppNotification item) {
    state = state.copyWith(notifications: [item, ...state.notifications]);
  }
}

/// --- Riverpod Providers ---

final rampProvider = StateNotifierProvider<RampNotifier, RampState>(
  (ref) => RampNotifier(),
);

final currentRoleProvider = Provider<String>((ref) {
  return ref.watch(rampProvider).currentRole;
});

final activeNavIndexProvider = Provider<int>((ref) {
  return ref.watch(rampProvider).activeNavIndex;
});

final unitsProvider = Provider<List<Unit>>((ref) {
  return ref.watch(rampProvider).units;
});

final tenantsProvider = Provider<List<Tenant>>((ref) {
  return ref.watch(rampProvider).tenants;
});

final paymentsProvider = Provider<List<PaymentData>>((ref) {
  return ref.watch(rampProvider).payments;
});

final ticketsProvider = Provider<List<Ticket>>((ref) {
  return ref.watch(ticketProvider);
});

final eventsProvider = Provider<List<AppEvent>>((ref) {
  return ref.watch(rampProvider).events;
});

final activitiesProvider = Provider<List<RecordChange>>((ref) {
  return ref.watch(rampProvider).activities;
});

final notificationsProvider = Provider<List<AppNotification>>((ref) {
  return ref.watch(rampProvider).notifications;
});

final monthlyChartDataProvider = Provider<List<MonthlyPaymentData>>((ref) {
  return ref.watch(rampProvider).monthlyChartData;
});

final totalRevenueProvider = Provider<double>((ref) {
  return ref.watch(rampProvider).totalRevenue;
});

final expensesProvider = Provider<List<ExpenseItem>>((ref) {
  return ref.watch(rampProvider).expenses;
});

// --- Navigation & Filter Providers ---
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final unitFilterProvider = StateProvider<String>((ref) => 'All');
final ticketFilterProvider = StateProvider<String>((ref) => 'All');

// --- Simple Activity Model & Provider ---
class ActivityLog {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color iconBgColor;

  ActivityLog({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.iconBgColor,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd').format(timestamp);
  }
}

class ActivityNotifier extends StateNotifier<List<ActivityLog>> {
  ActivityNotifier()
      : super([
          ActivityLog(
            id: 'act_1',
            title: 'Payment Received',
            description: 'Maria Santos paid ₱12,000.00 for Oct',
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            icon: Icons.payments,
            iconBgColor: const Color(0x3310B981),
          ),
          ActivityLog(
            id: 'act_2',
            title: 'New Maintenance Ticket',
            description: 'Bathroom Sink Leakage in Unit 2 (Open)',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            icon: Icons.build,
            iconBgColor: const Color(0x33F59E0B),
          ),
        ]);

  void addActivity(ActivityLog activity) {
    state = [activity, ...state];
  }
}

final activityProvider =
    StateNotifierProvider<ActivityNotifier, List<ActivityLog>>(
        (ref) => ActivityNotifier());

void _persist(String collection, String id, Map<String, dynamic> data) {
  if (Firebase.apps.isEmpty) return;
  PersistenceQueue.instance.enqueueUpsert(collection, id, data);
}

void _deletePersisted(String collection, String id) {
  if (Firebase.apps.isEmpty) return;
  PersistenceQueue.instance.enqueueDelete(collection, id);
}

void _saveUnit(Unit unit) => _persist('units', unit.id, {
      'name': unit.name,
      'title': unit.title,
      'unitNumber': unit.unitNumber,
      'floor': unit.floor,
      'location': unit.location,
      'latitude': unit.latitude,
      'longitude': unit.longitude,
      'rent': unit.rent,
      'monthlyRent': unit.monthlyRent,
      'status': unit.status,
      'description': unit.description,
      'area': unit.area,
      'areaSqm': unit.areaSqm,
      'bedrooms': unit.bedrooms,
      'bathrooms': unit.bathrooms,
      'amenities': unit.amenities,
      'inclusions': unit.inclusions,
      'images': unit.images,
      'imageUrl': unit.imageUrl,
      'tenantId': unit.tenantId,
      'tenantName': unit.tenantName,
      'currentTenancyId': unit.currentTenancyId,
      'dueDate': unit.dueDate,
      'rentDueDay': unit.rentDueDay,
      'lateFee': unit.lateFee,
      'vacantDays': unit.vacantDays,
      'waterReadingPrev': unit.waterReadingPrev,
      'waterReadingCurr': unit.waterReadingCurr,
      'electricReadingPrev': unit.electricReadingPrev,
      'electricReadingCurr': unit.electricReadingCurr,
      'leasePdfTitle': unit.leasePdfTitle,
      'isArchived': unit.isArchived,
      'detailsCompleted': unit.detailsCompleted,
      'waterUtilityEnabled': unit.waterUtilityEnabled,
      'electricityUtilityEnabled': unit.electricityUtilityEnabled,
      'waterRateOverride': unit.waterRateOverride,
      'electricityRateOverride': unit.electricityRateOverride,
      'maintenanceAreas': unit.maintenanceAreas,
      'schemaVersion': 2,
    });

void _saveTenant(Tenant tenant) => _persist('tenants', tenant.id, {
      'name': tenant.name,
      'email': tenant.email,
      'phone': tenant.phone,
      'contactNumber': tenant.contactNumber,
      'address': tenant.address,
      'referral': tenant.referral,
      'unitId': tenant.unitId,
      'unitNumber': tenant.unitNumber,
      'monthlyRent': tenant.monthlyRent,
      'leaseStart': tenant.leaseStart,
      'leaseEnd': tenant.leaseEnd,
      'dueDate': tenant.dueDate,
      'balance': tenant.balance,
      'status': tenant.status,
      'isArchived': tenant.isArchived,
      'avatarUrl': tenant.avatarUrl,
      'currentTenancyId': tenant.currentTenancyId,
      'schemaVersion': 2,
    });

void _saveTicket(Ticket ticket) => _persist('maintenanceTickets', ticket.id, {
      'title': ticket.title,
      'description': ticket.description,
      'category': ticket.category,
      'photoPath': ticket.photoPath,
      'photoBefore': ticket.photoBefore,
      'photoAfter': ticket.photoAfter,
      'photos': ticket.photos,
      'priority': ticket.priority,
      'status': ticket.status,
      'assignedTo': ticket.assignedTo,
      'assignedToName': ticket.assignedToName,
      'vendorId': ticket.vendorId,
      'estimatedCost': ticket.estimatedCost,
      'actualCost': ticket.actualCost,
      'vendorCost': ticket.vendorCost,
      'date': ticket.date,
      'createdAt': ticket.createdAt,
      'slaDueDate': ticket.slaDueDate,
      'rating': ticket.rating,
      'ratingFeedback': ticket.ratingFeedback,
      'unitNumber': ticket.unitNumber,
      'tenantName': ticket.tenantName,
      'unitId': ticket.unitId,
      'tenantId': ticket.tenantId,
      'tenancyId': ticket.tenancyId,
      'responsibleParty': ticket.responsibleParty,
      'paymentRequired': ticket.paymentRequired,
      'paymentStatus': ticket.paymentStatus,
      'statusHistory': ticket.statusHistory.map((e) => e.toJson()).toList(),
      'affectedAreas': ticket.affectedAreas,
      'issueStartedAt': ticket.issueStartedAt,
      'visitScheduledAt': ticket.visitScheduledAt,
      'visitTimeWindow': ticket.visitTimeWindow,
      'visitReminderSent': ticket.visitReminderSent,
      'replacementItems': ticket.replacementItems,
      'repairScheduledAt': ticket.repairScheduledAt,
      'repairTimeWindow': ticket.repairTimeWindow,
      'repairer': ticket.repairer,
      'repairReminderSent': ticket.repairReminderSent,
      'completionSummary': ticket.completionSummary,
      'schemaVersion': 2,
    });

void _savePayment(PaymentData payment) => _persist('payments', payment.id, {
      'month': payment.month,
      'amount': payment.amount,
      'method': payment.method,
      'paymentMethod': payment.paymentMethod,
      'date': payment.date,
      'paymentDate': payment.paymentDate,
      'status': payment.status,
      'unitId': payment.unitId,
      'referenceNumber': payment.referenceNumber,
      'baseRent': payment.baseRent,
      'waterBill': payment.waterBill,
      'electricBill': payment.electricBill,
      'lateFee': payment.lateFee,
      'otherCharge': payment.otherCharge,
      'tenantName': payment.tenantName,
      'unitNumber': payment.unitNumber,
      'tenantId': payment.tenantId,
      'tenancyId': payment.tenancyId,
      'proofImageUrl': payment.proofImageUrl,
      'remarks': payment.remarks,
      'declineReason': payment.declineReason,
      'transactionType': payment.transactionType,
      'ticketId': payment.ticketId,
      'schemaVersion': 2,
    });

void _saveAnnouncement(Announcement item) =>
    _persist('announcements', item.id, {
      'title': item.title,
      'message': item.message,
      'timestamp': item.timestamp,
      'author': item.author,
      'isImportant': item.isImportant,
      'category': item.category,
      'isArchived': item.isArchived,
    });

void _saveNotification(AppNotification item) =>
    _persist('notifications', item.id, {
      'title': item.title,
      'message': item.message,
      'timestamp': item.timestamp,
      'isRead': item.isRead,
      'isArchived': item.isArchived,
      'type': item.type,
      'entityType': item.entityType,
      'entityId': item.entityId,
      'action': item.action,
    });

void _saveExpense(ExpenseItem item) => _persist('expenses', item.id, {
      'title': item.title,
      'category': item.category,
      'amount': item.amount,
      'date': item.date,
      'unitId': item.unitId,
      'unitNumber': item.unitNumber,
      'recordedBy': item.recordedBy,
      'notes': item.notes,
    });

void _saveTenantDocument(TenantDocument item) =>
    _persist('tenantDocuments', item.id, {
      'tenantId': item.tenantId,
      'tenantName': item.tenantName,
      'title': item.title,
      'type': item.type,
      'fileName': item.fileName,
      'fileSize': item.fileSize,
      'uploadedAt': item.uploadedAt,
    });

class UnitNotifier extends StateNotifier<List<Unit>> {
  UnitNotifier()
      : super([
          Unit(
            id: 'u1',
            name: 'Executive Studio 1',
            title: 'Executive Studio 1',
            unitNumber: 'Unit 1',
            floor: '1st Floor',
            rent: 8500.0,
            status: 'Occupied',
            area: 28,
            inclusions: ['wifi', 'water', 'electricity'],
            tenantId: 't2',
            tenantName: 'Juan Dela Cruz',
            dueDate: DateTime.now().add(const Duration(days: 5)),
            rentDueDay: 5,
            lateFee: 500.0,
            vacantDays: 0,
            waterReadingPrev: 110.0,
            waterReadingCurr: 122.5,
            electricReadingPrev: 1200.0,
            electricReadingCurr: 1345.0,
            leasePdfTitle: 'Lease_Contract_Unit1_Juan.pdf',
            imageUrl:
                'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
          ),
          Unit(
            id: 'u2',
            name: 'Deluxe Suite 2',
            title: 'Deluxe Suite 2',
            unitNumber: 'Unit 2',
            floor: '1st Floor',
            rent: 12000.0,
            status: 'Occupied',
            area: 45,
            inclusions: ['wifi', 'water', 'aircon'],
            tenantId: 't1',
            tenantName: 'Maria Santos',
            dueDate: DateTime.now().add(const Duration(days: 2)),
            rentDueDay: 10,
            lateFee: 0.0,
            vacantDays: 0,
            waterReadingPrev: 145.2,
            waterReadingCurr: 162.8,
            electricReadingPrev: 1850.0,
            electricReadingCurr: 2040.0,
            leasePdfTitle: 'Lease_Contract_Unit2_Maria.pdf',
            imageUrl:
                'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
          ),
          Unit(
            id: 'u3',
            name: 'Penthouse Loft 3',
            title: 'Penthouse Loft 3',
            unitNumber: 'Unit 3',
            floor: '2nd Floor',
            rent: 16500.0,
            status: 'Vacant',
            area: 60,
            inclusions: ['wifi', 'river view'],
            tenantName: null,
            dueDate: null,
            rentDueDay: 5,
            lateFee: 0.0,
            vacantDays: 42,
            waterReadingPrev: 200.0,
            waterReadingCurr: 200.0,
            electricReadingPrev: 2500.0,
            electricReadingCurr: 2505.0,
            leasePdfTitle: 'Lease_Template_Unit3.pdf',
            imageUrl:
                'https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=800',
          ),
          Unit(
            id: 'u4',
            name: 'Executive Suite 4',
            title: 'Executive Suite 4',
            unitNumber: 'Unit 4',
            floor: '2nd Floor',
            rent: 10500.0,
            status: 'Maintenance',
            area: 32,
            inclusions: ['parking', 'water'],
            tenantId: 't3',
            tenantName: 'Carlos Ramos',
            dueDate: DateTime.now().add(const Duration(days: 10)),
            rentDueDay: 15,
            lateFee: 300.0,
            vacantDays: 0,
            waterReadingPrev: 95.0,
            waterReadingCurr: 106.2,
            electricReadingPrev: 1100.0,
            electricReadingCurr: 1215.0,
            leasePdfTitle: 'Lease_Contract_Unit4_Carlos.pdf',
            imageUrl:
                'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800',
          ),
          Unit(
            id: 'u5',
            name: 'Garden Suite 5',
            title: 'Garden Suite 5',
            unitNumber: 'Unit 5',
            floor: '1st Floor',
            rent: 9500.0,
            status: 'Vacant',
            area: 28,
            inclusions: ['wifi', 'garden'],
            tenantName: null,
            dueDate: null,
            rentDueDay: 5,
            lateFee: 500.0,
            vacantDays: 14,
            waterReadingPrev: 80.0,
            waterReadingCurr: 80.0,
            electricReadingPrev: 900.0,
            electricReadingCurr: 902.0,
            leasePdfTitle: 'Lease_Template_Unit5.pdf',
            imageUrl:
                'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
          ),
        ]);

  void replaceAll(List<Unit> units) => state = units;

  void addUnit(Unit unit) {
    state = [...state, unit];
    _saveUnit(unit);
  }

  void updateUnit(Unit updatedUnit) {
    state = [
      for (final unit in state)
        if (unit.id == updatedUnit.id) updatedUnit else unit
    ];
    _saveUnit(updatedUnit);
  }

  void archiveUnit(String id) {
    state = [
      for (final unit in state)
        if (unit.id == id)
          unit.copyWith(isArchived: true, status: 'Inactive')
        else
          unit
    ];
    final updated = state.where((unit) => unit.id == id).firstOrNull;
    if (updated != null) _saveUnit(updated);
  }

  void deleteUnit(String id) {
    state = state.where((unit) => unit.id != id).toList();
    _deletePersisted('units', id);
  }

  void markVacant(String id) {
    state = [
      for (final unit in state)
        if (unit.id == id)
          unit.copyWith(status: 'Vacant', clearTenantAssignment: true)
        else
          unit
    ];
    final updated = state.where((unit) => unit.id == id).firstOrNull;
    if (updated != null) _saveUnit(updated);
  }
}

final unitProvider =
    StateNotifierProvider<UnitNotifier, List<Unit>>((ref) => UnitNotifier());

class TenantNotifier extends StateNotifier<List<Tenant>> {
  final Ref? _ref;
  TenantNotifier([this._ref])
      : super([
          Tenant(
            id: 't1',
            name: 'Maria Santos',
            email: 'maria.santos@gmail.com',
            phone: '0918-222-3344',
            unitId: 'u2',
            unitNumber: 'Unit 2',
            leaseStart: DateTime(2026, 3, 1),
            leaseEnd: DateTime(2027, 3, 1),
            dueDate: DateTime.now().add(const Duration(days: 2)),
            balance: 12000.0,
            avatarUrl:
                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
          ),
          Tenant(
            id: 't2',
            name: 'Juan Dela Cruz',
            email: 'juan.delacruz@gmail.com',
            phone: '0917-111-2233',
            unitId: 'u1',
            unitNumber: 'Unit 1',
            leaseStart: DateTime(2026, 1, 15),
            leaseEnd: DateTime(2027, 1, 15),
            dueDate: DateTime.now().subtract(const Duration(days: 3)),
            balance: 8500.0,
            avatarUrl:
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
          ),
          Tenant(
            id: 't3',
            name: 'Carlos Ramos',
            email: 'carlos.ramos@gmail.com',
            phone: '0919-333-4455',
            unitId: 'u4',
            unitNumber: 'Unit 4',
            leaseStart: DateTime(2026, 6, 10),
            leaseEnd: DateTime(2027, 6, 10),
            dueDate: DateTime.now().add(const Duration(days: 15)),
            balance: 0.0,
            avatarUrl:
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
          ),
        ]);

  void replaceAll(List<Tenant> tenants) => state = tenants;

  void addTenant(Tenant tenant) {
    state = [...state, tenant];
    _saveTenant(tenant);
  }

  void recordPayment(String tenantId, double amount) {
    if (amount <= 0) return;
    state = [
      for (final tenant in state)
        if (tenant.id == tenantId)
          tenant.copyWith(
            balance: (tenant.balance - amount).clamp(0, double.infinity),
          )
        else
          tenant,
    ];
    final updated = state.where((tenant) => tenant.id == tenantId).firstOrNull;
    if (updated != null) _saveTenant(updated);
  }

  /// Recalculates tenant balance based on valid payments vs expected rent/charges
  void recalculateTenantBalance(String tenantId) {
    if (_ref == null) return;
    final tenant = state.where((t) => t.id == tenantId).firstOrNull;
    if (tenant == null) return;

    final allPayments = _ref!.read(paymentProvider);
    final tenantPayments = allPayments.where((p) =>
        (p.tenantId == tenantId ||
            p.tenantName.toLowerCase() == tenant.name.toLowerCase()) &&
        p.isPaid && p.isRent);

    final totalPaid = tenantPayments.fold(0.0, (sum, p) => sum + p.amount);
    final totalExpected = tenant.monthlyRent; // Current monthly rent charge
    final double newBalance =
        (totalExpected - totalPaid).clamp(0, double.infinity).toDouble();

    state = [
      for (final t in state)
        if (t.id == tenantId) t.copyWith(balance: newBalance) else t
    ];
    final updated = state.where((t) => t.id == tenantId).firstOrNull;
    if (updated != null) _saveTenant(updated);
  }

  void updateTenant(Tenant updatedTenant) {
    state = [
      for (final tenant in state)
        if (tenant.id == updatedTenant.id) updatedTenant else tenant
    ];
    _saveTenant(updatedTenant);
  }

  void applyAutoLateFee(String tenantId, double fee) {
    state = [
      for (final tenant in state)
        if (tenant.id == tenantId)
          tenant.copyWith(balance: tenant.balance + fee)
        else
          tenant
    ];
    final updated = state.where((tenant) => tenant.id == tenantId).firstOrNull;
    if (updated != null) _saveTenant(updated);
    if (_ref != null) {
      _ref!.read(activityProvider.notifier).addActivity(
            ActivityLog(
              id: 'act_${DateTime.now().millisecondsSinceEpoch}',
              title: 'Auto Late Fee Applied',
              description: '₱${fee.toInt()} late fee added to unpaid balance',
              timestamp: DateTime.now(),
              icon: Icons.warning_amber_rounded,
              iconBgColor: const Color(0x33EF4444),
            ),
          );
    }
  }

  void archiveTenant(String id) {
    state = [
      for (final tenant in state)
        if (tenant.id == id)
          tenant.copyWith(isArchived: true, status: 'Former/Archived')
        else
          tenant
    ];
    final updated = state.where((tenant) => tenant.id == id).firstOrNull;
    if (updated != null) _saveTenant(updated);
  }

  void incrementTenantReminder(String tenantId, {String channel = 'SMS'}) {
    state = [
      for (final tenant in state)
        if (tenant.id == tenantId)
          tenant.copyWith(
            reminderLogs: [
              ...tenant.reminderLogs,
              ReminderLog(
                id: 'log_${DateTime.now().millisecondsSinceEpoch}',
                tenantId: tenantId,
                channel: channel,
                timestamp: DateTime.now(),
                rentCycle: DateFormat('MMM yyyy').format(DateTime.now()),
              ),
            ],
          )
        else
          tenant
    ];
    final updated = state.where((tenant) => tenant.id == tenantId).firstOrNull;
    if (updated != null) _saveTenant(updated);
  }

  void unarchiveTenant(String id) {
    state = [
      for (final tenant in state)
        if (tenant.id == id)
          tenant.copyWith(
              isArchived: false,
              status: tenant.isAssigned ? 'Active' : 'Unassigned')
        else
          tenant
    ];
    final updated = state.where((tenant) => tenant.id == id).firstOrNull;
    if (updated != null) _saveTenant(updated);
  }

  void deleteTenant(String id) {
    state = state.where((tenant) => tenant.id != id).toList();
    _deletePersisted('tenants', id);
  }
}

final tenantProvider = StateNotifierProvider<TenantNotifier, List<Tenant>>(
    (ref) => TenantNotifier(ref));

class TicketNotifier extends StateNotifier<List<Ticket>> {
  final Ref _ref;
  TicketNotifier(this._ref)
      : super([
          Ticket(
            id: 'tk1',
            title: 'Bathroom Sink Leakage',
            description:
                'Water pipe beneath bathroom sink is leaking steadily onto wooden cabinet.',
            category: 'Plumbing',
            priority: 'High',
            status: 'Schedule Visit',
            assignedTo: 'Alex Rivera (Plumbing & HVAC)',
            estimatedCost: 1500.0,
            actualCost: 0.0,
            date: DateTime.now().subtract(const Duration(hours: 4)),
            unitId: 'u2',
            unitNumber: 'Unit 2',
            tenantId: 't1',
            tenantName: 'Maria Santos',
            photoBefore:
                'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800',
          ),
          Ticket(
            id: 'tk2',
            title: 'Living Room Window Frame',
            description:
                'Living room glass window frame loose, needs re-caulking.',
            category: 'General',
            priority: 'Med',
            status: 'Schedule Repair',
            assignedTo: 'Marco Gomez (Carpentry)',
            estimatedCost: 3500.0,
            actualCost: 3200.0,
            date: DateTime.now().subtract(const Duration(days: 1)),
            unitId: 'u3',
            unitNumber: 'Unit 3',
            tenantName: 'Sij Co',
            photoBefore:
                'https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=800',
          ),
          Ticket(
            id: 'tk3',
            title: 'Aircon Cleaning & Filter Wash',
            description:
                'Quarterly split inverter aircon filter wash and coolant check.',
            category: 'Appliance',
            priority: 'Low',
            status: 'Completed',
            assignedTo: 'Alex Rivera (Plumbing & HVAC)',
            estimatedCost: 1200.0,
            actualCost: 1200.0,
            date: DateTime.now().subtract(const Duration(days: 4)),
            unitId: 'u1',
            unitNumber: 'Unit 1',
            tenantId: 't2',
            tenantName: 'Juan Dela Cruz',
            photoBefore:
                'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
            photoAfter:
                'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
            rating: 5,
            ratingFeedback:
                'Excellent service! Aircon is super cold and clean now.',
          ),
        ]);

  void replaceAll(List<Ticket> tickets) => state = tickets;

  void addTicket(Ticket ticket) {
    state = [ticket, ...state];
    _saveTicket(ticket);
    _ref.read(activityProvider.notifier).addActivity(
          ActivityLog(
            id: 'act_${DateTime.now().millisecondsSinceEpoch}',
            title: 'New Maintenance Ticket',
            description:
                '${ticket.title} (${ticket.priority} Priority - ${ticket.status})',
            timestamp: DateTime.now(),
            icon: Icons.build,
            iconBgColor: const Color(0x33F59E0B),
          ),
        );
  }

  void updateTicketStatus(String ticketId, String newStatus, {String? note}) {
    state = [
      for (final t in state)
        if (t.id == ticketId)
          t.copyWith(
            status: newStatus,
            statusHistory: [
              ...t.statusHistory,
              TicketStatusHistoryEntry(
                status: newStatus,
                timestamp: DateTime.now(),
                note: note ?? 'Status changed to $newStatus',
              ),
            ],
          )
        else
          t
    ];
    final updated = state.where((t) => t.id == ticketId).firstOrNull;
    if (updated != null) _saveTicket(updated);

    _ref.read(activityProvider.notifier).addActivity(
          ActivityLog(
            id: 'act_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Ticket Status Updated',
            description: 'Ticket status changed to $newStatus',
            timestamp: DateTime.now(),
            icon: Icons.task_alt,
            iconBgColor: const Color(0x3310B981),
          ),
        );
  }

  void updateTicket(Ticket updatedTicket) {
    state = [
      for (final ticket in state)
        if (ticket.id == updatedTicket.id) updatedTicket else ticket
    ];
    _saveTicket(updatedTicket);
  }

  bool scheduleTicketVisit(
      String ticketId, DateTime visitDate, String timeWindow) {
    final ticket = state.where((item) => item.id == ticketId).firstOrNull;
    if (ticket == null ||
        !ticket.isScheduleVisitStage ||
        timeWindow.trim().isEmpty) {
      return false;
    }
    state = [
      for (final t in state)
        if (t.id == ticketId)
          t.copyWith(
            status: 'Schedule Visit',
            visitScheduledAt: visitDate,
            visitTimeWindow: timeWindow,
            statusHistory: [
              ...t.statusHistory,
              TicketStatusHistoryEntry(
                status: 'Schedule Visit',
                timestamp: DateTime.now(),
                note:
                    'Visit scheduled for ${DateFormat('MMM dd, yyyy').format(visitDate)} ($timeWindow)',
              ),
            ],
          )
        else
          t
    ];
    final updated = state.where((t) => t.id == ticketId).firstOrNull;
    if (updated != null) _saveTicket(updated);
    return updated != null;
  }

  bool prepareTicketVisitReminder(String ticketId) {
    final ticket = state.where((item) => item.id == ticketId).firstOrNull;
    if (ticket == null ||
        ticket.tenantId == null ||
        ticket.tenantId!.isEmpty ||
        ticket.visitScheduledAt == null) {
      return false;
    }
    updateTicket(ticket.copyWith(visitReminderSent: true));
    return true;
  }

  bool markTicketVisitDone(String ticketId) {
    final ticket = state.where((item) => item.id == ticketId).firstOrNull;
    if (ticket == null ||
        !ticket.isScheduleVisitStage ||
        ticket.visitScheduledAt == null ||
        ticket.visitTimeWindow.trim().isEmpty) {
      return false;
    }
    state = [
      for (final t in state)
        if (t.id == ticketId)
          t.copyWith(
            status: 'Estimate',
            statusHistory: [
              ...t.statusHistory,
              TicketStatusHistoryEntry(
                status: 'Estimate',
                timestamp: DateTime.now(),
                note: 'Inspection visit completed. Awaiting estimate.',
              ),
            ],
          )
        else
          t
    ];
    final updated = state.where((t) => t.id == ticketId).firstOrNull;
    if (updated != null) _saveTicket(updated);
    return updated != null;
  }

  bool submitTicketEstimate(
      String ticketId, double amount, List<String> replacedItems) {
    final ticket = state.where((item) => item.id == ticketId).firstOrNull;
    final cleanedItems = replacedItems
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (ticket == null ||
        !(ticket.isEstimateStage || ticket.isScheduleRepairStage) ||
        amount <= 0 ||
        cleanedItems.isEmpty) {
      return false;
    }
    Ticket? updatedTicket;
    state = [
      for (final t in state)
        if (t.id == ticketId) ...[
          (() {
            updatedTicket = t.copyWith(
              estimatedCost: amount,
              vendorCost: amount,
              actualCost: 0,
              replacementItems: cleanedItems,
              status: 'Schedule Repair',
              statusHistory: [
                ...t.statusHistory,
                TicketStatusHistoryEntry(
                  status: 'Schedule Repair',
                  timestamp: DateTime.now(),
                  note:
                      'Estimate saved (₱${amount.toStringAsFixed(2)} for ${replacedItems.join(", ")}). Ready to schedule repair.',
                ),
              ],
            );
            return updatedTicket!;
          })()
        ] else
          t
    ];

    if (updatedTicket != null) {
      _saveTicket(updatedTicket!);

      final maintenancePayment = PaymentData(
        id: 'maintenance_${updatedTicket!.id}',
        month: DateFormat('MMM').format(DateTime.now()),
        amount: amount,
        paymentMethod: 'Maintenance',
        method: 'Maintenance',
        date: DateTime.now(),
        paymentDate: DateTime.now(),
        status: 'Recorded',
        unitId: updatedTicket!.unitId ?? 'u1',
        unitNumber: updatedTicket!.unitNumber,
        tenantId: '',
        tenantName: 'Property maintenance',
        referenceNumber:
            'MAINT-${updatedTicket!.id.substring(0, updatedTicket!.id.length.clamp(0, 6))}',
        remarks: 'Maintenance Repair Estimate: ${replacedItems.join(", ")}',
        baseRent: 0,
        otherCharge: amount,
        transactionType: 'Maintenance',
        ticketId: updatedTicket!.id,
      );
      _ref
          .read(paymentProvider.notifier)
          .upsertMaintenanceLedger(maintenancePayment);
    }
    return updatedTicket != null;
  }

  bool scheduleTicketRepair(String ticketId, DateTime repairDate,
      String timeWindow, String contractor) {
    final ticket = state.where((item) => item.id == ticketId).firstOrNull;
    if (ticket == null ||
        !ticket.isScheduleRepairStage ||
        timeWindow.trim().isEmpty ||
        contractor.trim().isEmpty) {
      return false;
    }
    state = [
      for (final t in state)
        if (t.id == ticketId)
          t.copyWith(
            status: 'Schedule Repair',
            repairScheduledAt: repairDate,
            repairTimeWindow: timeWindow,
            repairer: contractor,
            assignedToName: contractor,
            statusHistory: [
              ...t.statusHistory,
              TicketStatusHistoryEntry(
                status: 'Schedule Repair',
                timestamp: DateTime.now(),
                note:
                    'Repair scheduled for ${DateFormat('MMM dd, yyyy').format(repairDate)} ($timeWindow) by $contractor',
              ),
            ],
          )
        else
          t
    ];
    final updated = state.where((t) => t.id == ticketId).firstOrNull;
    if (updated != null) _saveTicket(updated);
    return updated != null;
  }

  bool prepareTicketRepairReminder(String ticketId) {
    final ticket = state.where((item) => item.id == ticketId).firstOrNull;
    if (ticket == null ||
        ticket.tenantId == null ||
        ticket.tenantId!.isEmpty ||
        ticket.repairScheduledAt == null) {
      return false;
    }
    updateTicket(ticket.copyWith(repairReminderSent: true));
    return true;
  }

  bool markTicketCompleted(String ticketId,
      {String? completionPhoto, String? summary}) {
    final ticket = state.where((item) => item.id == ticketId).firstOrNull;
    final cleanedSummary = summary?.trim() ?? '';
    if (ticket == null ||
        !ticket.isScheduleRepairStage ||
        ticket.repairScheduledAt == null ||
        ticket.repairTimeWindow.trim().isEmpty ||
        ticket.repairer.trim().isEmpty ||
        cleanedSummary.isEmpty) {
      return false;
    }
    state = [
      for (final t in state)
        if (t.id == ticketId)
          t.copyWith(
            status: 'Completed',
            photoAfter: completionPhoto ?? t.photoAfter,
            completionSummary: cleanedSummary,
            statusHistory: [
              ...t.statusHistory,
              TicketStatusHistoryEntry(
                status: 'Completed',
                timestamp: DateTime.now(),
                note: 'Repair completed. ${summary ?? ""}',
              ),
            ],
          )
        else
          t
    ];
    final updated = state.where((t) => t.id == ticketId).firstOrNull;
    if (updated != null) _saveTicket(updated);
    return updated != null;
  }

  void deleteTicket(String id) {
    state = state.where((ticket) => ticket.id != id).toList();
    _deletePersisted('maintenanceTickets', id);
  }
}

final ticketProvider = StateNotifierProvider<TicketNotifier, List<Ticket>>(
    (ref) => TicketNotifier(ref));

class EventNotifier extends StateNotifier<List<AppEvent>> {
  EventNotifier()
      : super([
          AppEvent(
              id: 'e1',
              title: 'Rent Due • Unit 101',
              date: DateTime.now(),
              type: 'rent',
              unitId: 'u1',
              tenantId: 't2',
              priority: 'high',
              description: 'Monthly rental collection for Unit 101'),
          AppEvent(
              id: 'e2',
              title: 'Routine Inspection • Unit 101',
              date: DateTime.now().add(const Duration(days: 2)),
              type: 'inspection',
              unitId: 'u1',
              priority: 'medium',
              description: 'Quarterly property condition check'),
          AppEvent(
              id: 'e3',
              title: 'Plumbing Repair • Unit 102',
              date: DateTime.now().subtract(const Duration(days: 1)),
              type: 'maintenance',
              unitId: 'u2',
              ticketId: 'tk1',
              priority: 'urgent',
              isCompleted: true,
              description: 'Pipe leak fix under kitchen sink'),
          AppEvent(
              id: 'e4',
              title: 'Submeter Water Reading',
              date: DateTime.now().add(const Duration(days: 5)),
              type: 'meter_reading',
              priority: 'medium',
              description: 'Monthly submeter recording for billing'),
        ]);

  void addEvent(AppEvent event) => state = [...state, event];

  void updateEvent(AppEvent updatedEvent) {
    state = [
      for (final event in state)
        if (event.id == updatedEvent.id) updatedEvent else event
    ];
  }

  void toggleEventCompleted(String id) {
    state = [
      for (final event in state)
        if (event.id == id)
          event.copyWith(isCompleted: !event.isCompleted)
        else
          event
    ];
  }

  void deleteEvent(String id) {
    state = state.where((event) => event.id != id).toList();
  }

  List<AppEvent> get eventList => state;
}

final eventProvider = StateNotifierProvider<EventNotifier, List<AppEvent>>(
    (ref) => EventNotifier());

class PaymentNotifier extends StateNotifier<List<PaymentData>> {
  final Ref _ref;
  static final DateTime _now = DateTime.now();

  PaymentNotifier(this._ref)
      : super([
          PaymentData(
            id: 'p_curr',
            month: DateFormat('MMM').format(_now),
            amount: 11375.0,
            method: 'GCash',
            date: _now.subtract(const Duration(hours: 2)),
            status: 'Paid',
            unitId: 'u1',
            unitNumber: 'Unit 1',
            tenantId: 't2',
            tenantName: 'Juan Dela Cruz',
            referenceNumber: 'GC-99182019',
            baseRent: 8500.0,
            waterBill: 562.50,
            electricBill: 1812.50,
            lateFee: 500.0,
          ),
          PaymentData(
            id: 'p_1mo',
            month: DateFormat('MMM')
                .format(_now.subtract(const Duration(days: 30))),
            amount: 12000.0,
            method: 'Maya',
            date: _now.subtract(const Duration(days: 28)),
            status: 'Paid',
            unitId: 'u2',
            unitNumber: 'Unit 2',
            tenantId: 't1',
            tenantName: 'Maria Santos',
            referenceNumber: 'MY-88120192',
            baseRent: 12000.0,
            waterBill: 620.0,
            electricBill: 1950.0,
            lateFee: 0.0,
          ),
          PaymentData(
            id: 'p_2mo',
            month: DateFormat('MMM')
                .format(_now.subtract(const Duration(days: 60))),
            amount: 8500.0,
            method: 'Bank Transfer',
            date: _now.subtract(const Duration(days: 58)),
            status: 'Paid',
            unitId: 'u1',
            unitNumber: 'Unit 1',
            tenantId: 't2',
            tenantName: 'Juan Dela Cruz',
            referenceNumber: 'BDO-77281920',
            baseRent: 8500.0,
            waterBill: 510.0,
            electricBill: 1720.0,
            lateFee: 0.0,
          ),
          PaymentData(
            id: 'p_3mo',
            month: DateFormat('MMM')
                .format(_now.subtract(const Duration(days: 90))),
            amount: 10500.0,
            method: 'Cash',
            date: _now.subtract(const Duration(days: 88)),
            status: 'Paid',
            unitId: 'u4',
            unitNumber: 'Unit 4',
            tenantId: 't3',
            tenantName: 'Carlos Ramos',
            referenceNumber: 'CASH-002910',
            baseRent: 10500.0,
            waterBill: 480.0,
            electricBill: 1650.0,
            lateFee: 0.0,
          ),
        ]);

  void replaceAll(List<PaymentData> payments) => state = payments;

  void addPayment(PaymentData payment) {
    if (payment.isMaintenance) {
      upsertMaintenanceLedger(payment);
      return;
    }
    final unit = _ref
        .read(unitProvider)
        .where((u) => u.id == payment.unitId)
        .firstOrNull;
    final dueDay = (unit?.rentDueDay ?? _ref.read(dueDateDayProvider)) ?? 5;
    final configuredLateFee =
        (unit?.lateFee ?? _ref.read(lateFeeAmountProvider)) ?? 0.0;
    final bool isLate = payment.date.day > dueDay && configuredLateFee > 0;
    final double finalAmount = payment.amount;

    if (isLate) {
      _ref.read(activityProvider.notifier).addActivity(
            ActivityLog(
              id: 'act_${DateTime.now().millisecondsSinceEpoch}_fee',
              title: 'Late Fee Notice',
              description:
                  'Payment date past due day $dueDay. ₱${configuredLateFee.toInt()} late fee policy applied.',
              timestamp: DateTime.now(),
              icon: Icons.warning_amber_rounded,
              iconBgColor: const Color(0x33EF4444),
            ),
          );
    }

    final updatedPayment = payment.copyWith(amount: finalAmount);
    state = [updatedPayment, ...state];
    _savePayment(updatedPayment);

    // Re-reconcile tenant balance
    final tenant = _ref
        .read(tenantProvider)
        .where((item) =>
            item.id == payment.tenantId ||
            item.unitId == payment.unitId ||
            item.name.toLowerCase() == payment.tenantName.toLowerCase())
        .firstOrNull;
    if (tenant != null && payment.isPaid) {
      _ref.read(tenantProvider.notifier).recordPayment(tenant.id, finalAmount);
    }

    final formatter =
        NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);
    _ref.read(activityProvider.notifier).addActivity(
          ActivityLog(
            id: 'act_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Payment Recorded',
            description:
                'Recorded ${formatter.format(finalAmount)} via ${payment.method} for ${payment.month}',
            timestamp: DateTime.now(),
            icon: Icons.payments,
            iconBgColor: const Color(0x3310B981),
          ),
        );
  }

  /// Records the latest ticket estimate as a property expense. Revising the
  /// estimate replaces the ticket's existing ledger entry.
  void upsertMaintenanceLedger(PaymentData payment) {
    if (!payment.isMaintenance || payment.ticketId?.isNotEmpty != true) return;
    final index = state.indexWhere(
      (entry) => entry.isMaintenance && entry.ticketId == payment.ticketId,
    );
    state = index == -1
        ? [payment, ...state]
        : [
            for (var i = 0; i < state.length; i++)
              if (i == index) payment else state[i],
          ];
    _savePayment(payment);
  }

  void updatePayment(PaymentData updatedPayment) {
    final oldPayment = state.firstWhere((p) => p.id == updatedPayment.id,
        orElse: () => updatedPayment);
    state = [
      for (final payment in state)
        if (payment.id == updatedPayment.id) updatedPayment else payment
    ];
    _savePayment(updatedPayment);

    // Recalculate tenant balance if payment amount or status changed
    if (updatedPayment.isRent &&
        (oldPayment.amount != updatedPayment.amount ||
            oldPayment.status != updatedPayment.status)) {
      _ref
          .read(tenantProvider.notifier)
          .recalculateTenantBalance(updatedPayment.tenantId);
    }
  }

  void reversePayment(String id) {
    final payment =
        state.firstWhere((p) => p.id == id, orElse: () => state.first);
    final reversed = payment.copyWith(status: 'Reversed');
    updatePayment(reversed);
  }

  void approvePayment(String paymentId, {String? remark}) {
    final payment = state.firstWhere((p) => p.id == paymentId,
        orElse: () => throw Exception('Payment not found'));
    final approvedPayment = payment.copyWith(
      status: 'Paid',
      remarks: remark ?? payment.remarks,
    );
    updatePayment(approvedPayment);

    // Re-reconcile tenant balance
    final tenant = _ref
        .read(tenantProvider)
        .where((item) =>
            item.id == approvedPayment.tenantId ||
            item.unitId == approvedPayment.unitId ||
            item.name.toLowerCase() == approvedPayment.tenantName.toLowerCase())
        .firstOrNull;
    if (tenant != null) {
      _ref.read(tenantProvider.notifier).recordPayment(tenant.id, approvedPayment.amount);
    }

    final formatter =
        NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);
    _ref.read(activityProvider.notifier).addActivity(
          ActivityLog(
            id: 'act_${DateTime.now().millisecondsSinceEpoch}_appr',
            title: 'Payment Verified & Approved',
            description:
                'Verified ${formatter.format(approvedPayment.amount)} (${approvedPayment.method}) from ${approvedPayment.tenantName} for ${approvedPayment.month}',
            timestamp: DateTime.now(),
            icon: Icons.check_circle_rounded,
            iconBgColor: const Color(0x3310B981),
          ),
        );
    _ref.read(auditServiceProvider.notifier).logAction(
          'PAYMENT_APPROVED',
          'Approved payment ${approvedPayment.id} of ${formatter.format(approvedPayment.amount)} for ${approvedPayment.tenantName}',
        );
  }

  void declinePayment(String paymentId, {String? reason}) {
    final payment = state.firstWhere((p) => p.id == paymentId,
        orElse: () => throw Exception('Payment not found'));
    final declinedPayment = payment.copyWith(
      status: 'Declined',
      declineReason: reason ?? 'Proof of payment verification failed.',
    );
    updatePayment(declinedPayment);

    final formatter =
        NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);
    _ref.read(activityProvider.notifier).addActivity(
          ActivityLog(
            id: 'act_${DateTime.now().millisecondsSinceEpoch}_decl',
            title: 'Payment Declined',
            description:
                'Declined payment of ${formatter.format(declinedPayment.amount)} for ${declinedPayment.tenantName}. Reason: ${declinedPayment.declineReason}',
            timestamp: DateTime.now(),
            icon: Icons.cancel_rounded,
            iconBgColor: const Color(0x33EF4444),
          ),
        );
    _ref.read(auditServiceProvider.notifier).logAction(
          'PAYMENT_DECLINED',
          'Declined payment ${declinedPayment.id} for ${declinedPayment.tenantName}. Reason: ${declinedPayment.declineReason}',
        );
  }

  void deletePayment(String id) {
    final payment =
        state.firstWhere((p) => p.id == id, orElse: () => state.first);
    state = state.where((p) => p.id != id).toList();
    _deletePersisted('payments', id);

    // Recalculate tenant balance
    if (payment.isRent && payment.tenantId.isNotEmpty) {
      _ref
          .read(tenantProvider.notifier)
          .recalculateTenantBalance(payment.tenantId);
    }
  }
}

final paymentProvider =
    StateNotifierProvider<PaymentNotifier, List<PaymentData>>(
        (ref) => PaymentNotifier(ref));

class AnnouncementNotifier extends StateNotifier<List<Announcement>> {
  AnnouncementNotifier()
      : super([
          Announcement(
            id: 'ann_1',
            title: 'Meralco Maintenance Outage',
            message:
                'Scheduled brownout this Friday, 8:00 AM - 5:00 PM. Please charge backup lights.',
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            author: "Emin and Mila's Property Management",
            isImportant: true,
            category: 'Maintenance',
          ),
          Announcement(
            id: 'ann_2',
            title: 'Water Submeter Reading Schedule',
            message:
                'Submeter readings take place every 25th of the month at 9:00 AM.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            author: "Emin and Mila's Property Management",
            isImportant: true,
            category: 'Billing',
          ),
        ]);

  void replaceAll(List<Announcement> announcements) => state = announcements;

  void addAnnouncement(Announcement announcement) {
    state = [announcement, ...state];
    _saveAnnouncement(announcement);
  }

  void updateAnnouncement(Announcement updated) {
    state = [
      for (final a in state)
        if (a.id == updated.id) updated else a
    ];
    _saveAnnouncement(updated);
  }

  void deleteAnnouncement(String id) {
    state = state.where((a) => a.id != id).toList();
    _deletePersisted('announcements', id);
  }

  void archiveAnnouncement(String id) {
    state = [
      for (final announcement in state)
        if (announcement.id == id)
          announcement.copyWith(isArchived: true)
        else
          announcement,
    ];
    final updated = state.where((item) => item.id == id).firstOrNull;
    if (updated != null) _saveAnnouncement(updated);
  }

  void restoreAnnouncement(String id) {
    state = [
      for (final announcement in state)
        if (announcement.id == id)
          announcement.copyWith(isArchived: false)
        else
          announcement,
    ];
    final updated = state.where((item) => item.id == id).firstOrNull;
    if (updated != null) _saveAnnouncement(updated);
  }
}

final announcementProvider =
    StateNotifierProvider<AnnouncementNotifier, List<Announcement>>(
  (ref) => AnnouncementNotifier(),
);

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier()
      : super([
          AppNotification(
              id: 'n1',
              title: 'Payment Received',
              message: 'Juan Dela Cruz paid rent for Unit 1',
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              entityType: 'payment',
              entityId: 'p_curr'),
          AppNotification(
              id: 'n2',
              title: 'New Ticket',
              message: 'Bathroom Sink Leakage for Unit 2',
              timestamp: DateTime.now().subtract(const Duration(hours: 5)),
              entityType: 'ticket',
              entityId: 'tk1'),
        ]);

  void replaceAll(List<AppNotification> notifications) => state = notifications;

  void addNotification(AppNotification notif) {
    state = [...state, notif];
    _saveNotification(notif);
  }

  void archiveNotification(String id) {
    state = [
      for (final notification in state)
        notification.id == id
            ? notification.copyWith(isArchived: true)
            : notification
    ];
    final updated = state.where((item) => item.id == id).firstOrNull;
    if (updated != null) _saveNotification(updated);
  }

  void restoreNotification(String id) {
    state = [
      for (final notification in state)
        notification.id == id
            ? notification.copyWith(isArchived: false)
            : notification
    ];
    final updated = state.where((item) => item.id == id).firstOrNull;
    if (updated != null) _saveNotification(updated);
  }

  void deleteNotification(String id) {
    state = state.where((notif) => notif.id != id).toList();
    _deletePersisted('notifications', id);
  }

  void markAsRead(String id) {
    state = [
      for (final notification in state)
        notification.id == id
            ? notification.copyWith(isRead: true)
            : notification
    ];
    final updated = state.where((item) => item.id == id).firstOrNull;
    if (updated != null) _saveNotification(updated);
  }

  void markAllAsRead() {
    state = [
      for (final notification in state) notification.copyWith(isRead: true)
    ];
    for (final notification in state) {
      _saveNotification(notification);
    }
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>(
        (ref) => NotificationNotifier());

class ExpenseNotifier extends StateNotifier<List<ExpenseItem>> {
  ExpenseNotifier()
      : super([
          ExpenseItem(
            id: 'exp_1',
            title: 'Plumbing Pipe & Sink Drain Fittings',
            category: 'Maintenance',
            amount: 1500.0,
            date: DateTime.now().subtract(const Duration(days: 3)),
            unitId: 'u2',
            unitNumber: 'Unit 2',
            notes: 'Replaced corroded PVC drainage pipe beneath bathroom sink.',
          ),
          ExpenseItem(
            id: 'exp_2',
            title: 'Property High-Speed Fiber Internet',
            category: 'Utilities',
            amount: 2800.0,
            date: DateTime.now().subtract(const Duration(days: 7)),
            notes:
                'Monthly high-speed Wi-Fi router subscription for Units 1 to 5.',
          ),
        ]);

  void replaceAll(List<ExpenseItem> expenses) => state = expenses;

  void addExpense(ExpenseItem expense) {
    state = [expense, ...state];
    _saveExpense(expense);
  }

  void updateExpense(ExpenseItem updated) {
    state = [
      for (final e in state)
        if (e.id == updated.id) updated else e
    ];
    _saveExpense(updated);
  }

  void deleteExpense(String id) {
    state = state.where((e) => e.id != id).toList();
    _deletePersisted('expenses', id);
  }
}

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, List<ExpenseItem>>(
  (ref) => ExpenseNotifier(),
);

/// Firebase UID for the authenticated landlord. Tenant records never authenticate.
final authProvider = StateProvider<String?>((ref) => null);
final landlordProfileProvider = StateProvider<
    ({
      String name,
      String role,
      String contact,
    })>((ref) => (
      name: "Emin and Mila's",
      role: 'Property Representative / Admin',
      contact: '0917-123-4567 • support@ramp-properties.com',
    ));

void persistAppSettings({
  double? defaultLateFee,
  int? defaultDueDay,
  bool? autoLateFeeEnabled,
  bool? autoBackupEnabled,
  bool? darkMode,
  String? landlordName,
  String? landlordRole,
  String? landlordContact,
  double? waterRate,
  double? electricityRate,
}) {
  final values = <String, dynamic>{
    if (defaultLateFee != null) 'defaultLateFee': defaultLateFee,
    if (defaultDueDay != null) 'defaultDueDay': defaultDueDay,
    if (autoLateFeeEnabled != null) 'autoLateFeeEnabled': autoLateFeeEnabled,
    if (autoBackupEnabled != null) 'autoBackupEnabled': autoBackupEnabled,
    if (darkMode != null) 'darkMode': darkMode,
    if (landlordName != null) 'landlordName': landlordName,
    if (landlordRole != null) 'landlordRole': landlordRole,
    if (landlordContact != null) 'landlordContact': landlordContact,
    if (waterRate != null) 'waterRate': waterRate,
    if (electricityRate != null) 'electricityRate': electricityRate,
  };
  _persist('settings', 'app', values);
}

final darkModeProvider = StateProvider<bool>((ref) => false);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final isDark = ref.watch(darkModeProvider);
  return isDark ? ThemeMode.dark : ThemeMode.light;
});

final lateFeeAmountProvider = StateProvider<double>((ref) => 500.0);
final dueDateDayProvider = StateProvider<int>((ref) => 5);
final autoLateFeeEnabledProvider = StateProvider<bool>((ref) => true);
final autoBackupProvider = StateProvider<bool>((ref) => true);

class UtilityRateState {
  const UtilityRateState({
    this.waterRate = 45.0,
    this.electricityRate = 12.5,
    this.history = const [],
  });

  final double waterRate;
  final double electricityRate;
  final List<UtilityRateChange> history;

  UtilityRateState copyWith({
    double? waterRate,
    double? electricityRate,
    List<UtilityRateChange>? history,
  }) =>
      UtilityRateState(
        waterRate: waterRate ?? this.waterRate,
        electricityRate: electricityRate ?? this.electricityRate,
        history: history ?? this.history,
      );
}

class UtilityRateNotifier extends StateNotifier<UtilityRateState> {
  UtilityRateNotifier() : super(const UtilityRateState());

  void replaceAll({
    required double waterRate,
    required double electricityRate,
    required List<UtilityRateChange> history,
  }) {
    final sortedHistory = List<UtilityRateChange>.of(history)
      ..sort((a, b) => b.effectiveAt.compareTo(a.effectiveAt));
    state = UtilityRateState(
      waterRate: waterRate,
      electricityRate: electricityRate,
      history: sortedHistory,
    );
  }

  void updateRate({
    required String utility,
    required double newRate,
    String note = '',
    DateTime? effectiveAt,
  }) {
    if (newRate <= 0 || !newRate.isFinite) return;
    final isWater = utility == 'Water';
    final previous = isWater ? state.waterRate : state.electricityRate;
    if (previous == newRate) return;
    final change = UtilityRateChange(
      id: 'rate_${DateTime.now().microsecondsSinceEpoch}',
      utility: utility,
      previousRate: previous,
      newRate: newRate,
      effectiveAt: effectiveAt ?? DateTime.now(),
      note: note.trim(),
    );
    state = state.copyWith(
      waterRate: isWater ? newRate : state.waterRate,
      electricityRate: isWater ? state.electricityRate : newRate,
      history: [change, ...state.history],
    );
    persistAppSettings(
      waterRate: state.waterRate,
      electricityRate: state.electricityRate,
    );
    _persist('utilityRateLogs', change.id, {
      'utility': change.utility,
      'previousRate': change.previousRate,
      'newRate': change.newRate,
      'effectiveAt': change.effectiveAt,
      'note': change.note,
    });
  }

  double rateAt(String utility, DateTime date) {
    final utilityChanges = state.history
        .where((item) => item.utility == utility)
        .toList()
      ..sort((a, b) => a.effectiveAt.compareTo(b.effectiveAt));
    final changes = utilityChanges
        .where((item) => !item.effectiveAt.isAfter(date))
        .toList()
      ..sort((a, b) => b.effectiveAt.compareTo(a.effectiveAt));
    if (changes.isNotEmpty) return changes.first.newRate;
    if (utilityChanges.isNotEmpty) return utilityChanges.first.previousRate;
    return utility == 'Water' ? state.waterRate : state.electricityRate;
  }
}

final utilityRateProvider =
    StateNotifierProvider<UtilityRateNotifier, UtilityRateState>(
  (ref) => UtilityRateNotifier(),
);

final effectiveUnitBillingPolicyProvider =
    Provider.family<({int dueDay, double lateFee}), String>((ref, unitId) {
  final unit = ref.watch(unitProvider).where((u) => u.id == unitId).firstOrNull;
  return (
    dueDay: unit?.rentDueDay ?? ref.watch(dueDateDayProvider),
    lateFee: unit?.lateFee ?? ref.watch(lateFeeAmountProvider),
  );
});

final autoLateFeeStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final now = DateTime.now();
  final dayOfMonth = now.day;
  final isEnabled = ref.watch(autoLateFeeEnabledProvider);
  final tenants = ref.watch(tenantProvider);
  final units = ref.watch(unitProvider);
  final defaultDueDay = ref.watch(dueDateDayProvider);
  final defaultLateFee = ref.watch(lateFeeAmountProvider);

  final unpaidTenants = tenants.where((t) => t.balance > 0).toList();
  final overdueTenants = unpaidTenants.where((tenant) {
    final unit = units.where((u) => u.id == tenant.unitId).firstOrNull;
    final dueDay = unit?.rentDueDay ?? defaultDueDay;
    return dayOfMonth > dueDay;
  }).toList();
  final double totalPenaltiesApplied = isEnabled
      ? overdueTenants.fold<double>(0, (sum, tenant) {
          final unit = units.where((u) => u.id == tenant.unitId).firstOrNull;
          return sum + (unit?.lateFee ?? defaultLateFee);
        })
      : 0.0;

  final bool hasActiveLateFeeAlert = overdueTenants.isNotEmpty && isEnabled;

  return {
    'isEnabled': isEnabled,
    'isPastFifth': dayOfMonth > 5,
    'isPastDueDate': overdueTenants.isNotEmpty,
    'dayOfMonth': dayOfMonth,
    'dueDateDay': ref.watch(dueDateDayProvider),
    'lateFeeAmount': ref.watch(lateFeeAmountProvider),
    'unpaidCount': unpaidTenants.length,
    'unpaidTenants': unpaidTenants,
    'overdueTenants': overdueTenants,
    'totalPenaltiesApplied': totalPenaltiesApplied,
    'hasActiveLateFeeAlert': hasActiveLateFeeAlert,
    'bannerTitle': hasActiveLateFeeAlert
        ? 'Auto Late Fees Active Per Unit'
        : 'Monthly Rent Due Policies',
    'bannerMessage': hasActiveLateFeeAlert
        ? '${overdueTenants.length} unpaid tenant(s) are past their unit due date.'
        : 'Each unit can set its own rent due day and late fee.',
  };
});

class UpcomingDueItem {
  final String id;
  final String tenantId;
  final String tenantName;
  final String unitNumber;
  final double amount;
  final DateTime dueDate;
  final String status;

  const UpcomingDueItem({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.unitNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  bool get isOverdue => daysRemaining < 0;

  String get formattedAmount {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String get formattedDueDate => DateFormat('MMM dd, yyyy').format(dueDate);

  String get dueStatusText {
    final days = daysRemaining;
    if (days < 0) return 'Overdue by ${days.abs()} day(s)';
    if (days == 0) return 'Due Today!';
    if (days == 1) return 'Due Tomorrow';
    return 'Due in $days days';
  }
}

final upcomingDues7DaysProvider = Provider<List<UpcomingDueItem>>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final tenants = ref.watch(tenantProvider);
  final payments = ref.watch(paymentProvider);

  final List<UpcomingDueItem> items = [];

  for (final p in payments) {
    final pDate =
        DateTime(p.paymentDate.year, p.paymentDate.month, p.paymentDate.day);
    final days = pDate.difference(today).inDays;
    if (!p.isPaid && days <= 7) {
      items.add(
        UpcomingDueItem(
          id: p.id,
          tenantId: p.tenantId,
          tenantName: p.tenantName,
          unitNumber: p.unitNumber,
          amount: p.amount,
          dueDate: p.paymentDate,
          status: days < 0 ? 'Overdue' : (days == 0 ? 'Due Today' : 'Upcoming'),
        ),
      );
    }
  }

  for (final t in tenants) {
    final tDue = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
    final days = tDue.difference(today).inDays;
    if (days <= 7 &&
        !items.any((i) => i.tenantName.toLowerCase() == t.name.toLowerCase())) {
      items.add(
        UpcomingDueItem(
          id: 'due_${t.id}',
          tenantId: t.id,
          tenantName: t.name,
          unitNumber: t.unitNumber,
          amount: t.balance > 0 ? t.balance : t.monthlyRent,
          dueDate: t.dueDate,
          status: days < 0 ? 'Overdue' : (days == 0 ? 'Due Today' : 'Upcoming'),
        ),
      );
    }
  }

  items.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  return items;
});

final kpiTotalRevenueProvider = Provider<double>((ref) {
  final payments = ref.watch(paymentProvider);
  final total =
      payments
          .where((p) => p.isRent && p.isPaid)
          .fold(0.0, (sum, p) => sum + p.amount);
  return total > 0 ? total : 42375.0;
});

final kpiTotalUnitsProvider = Provider<int>((ref) {
  final units = ref.watch(unitProvider);
  return units.length;
});

final kpiOccupancyRateProvider = Provider<double>((ref) {
  final units = ref.watch(unitProvider);
  if (units.isEmpty) return 0.0;
  final occupied = units.where((u) => u.isOccupied).length;
  return (occupied / units.length) * 100;
});

final kpiPendingTicketsProvider = Provider<int>((ref) {
  final tickets = ref.watch(ticketProvider);
  return tickets
      .where((t) =>
          t.status.toLowerCase() != 'completed' &&
          t.status.toLowerCase() != 'closed' &&
          t.status.toLowerCase() != 'cancelled')
      .length;
});

final totalExpensesProvider = Provider<double>((ref) {
  final recordedExpenses = ref.watch(expenseProvider);
  final maintenanceLedger = ref.watch(paymentProvider);

  double total = recordedExpenses.fold(0.0, (sum, e) => sum + e.amount);
  total += maintenanceLedger
      .where((entry) => entry.isMaintenance)
      .fold(0.0, (sum, entry) => sum + entry.amount);
  return total;
});

final netOperatingIncomeProvider = Provider<double>((ref) {
  final totalRevenue = ref.watch(kpiTotalRevenueProvider);
  final totalExpenses = ref.watch(totalExpensesProvider);
  return totalRevenue - totalExpenses;
});

class TenantDocumentNotifier extends StateNotifier<List<TenantDocument>> {
  TenantDocumentNotifier()
      : super([
          TenantDocument(
            id: 'doc_1',
            tenantId: 't1',
            tenantName: 'Maria Santos',
            title: 'Signed Lease Contract PDF',
            type: 'Contract',
            fileName: 'RAMP_Lease_Contract_Unit2_2024.pdf',
            fileSize: '1.8 MB',
            uploadedAt: DateTime(2024, 1, 5),
          ),
          TenantDocument(
            id: 'doc_2',
            tenantId: 't1',
            tenantName: 'Maria Santos',
            title: 'Primary Government ID',
            type: 'ID',
            fileName: 'Maria_Santos_DL_Front_Back.jpg',
            fileSize: '840 KB',
            uploadedAt: DateTime(2024, 1, 5),
          ),
        ]);

  void replaceAll(List<TenantDocument> documents) => state = documents;

  void uploadDocument(TenantDocument doc) {
    state = [doc, ...state];
    _saveTenantDocument(doc);
  }

  void deleteDocument(String id) {
    state = state.where((doc) => doc.id != id).toList();
    _deletePersisted('tenantDocuments', id);
  }
}

final tenantDocumentProvider =
    StateNotifierProvider<TenantDocumentNotifier, List<TenantDocument>>(
  (ref) => TenantDocumentNotifier(),
);

String _dbText(Map<String, dynamic> data, String key, [String fallback = '']) =>
    FirestoreService.text(data[key], fallback);
double _dbNumber(Map<String, dynamic> data, String key,
        [double fallback = 0]) =>
    FirestoreService.number(data[key], fallback);
int _dbInt(Map<String, dynamic> data, String key, [int fallback = 0]) =>
    FirestoreService.integer(data[key], fallback);
bool _dbBool(Map<String, dynamic> data, String key, [bool fallback = false]) =>
    data[key] is bool ? data[key] as bool : fallback;
DateTime _dbDate(Map<String, dynamic> data, String key, [DateTime? fallback]) =>
    FirestoreService.date(data[key], fallback);

Unit _unitFromDb(Map<String, dynamic> data) {
  final images = FirestoreService.strings(data['images']);
  final dueValue = data['dueDate'];
  return Unit(
    id: _dbText(data, 'id'),
    name: _dbText(data, 'name', _dbText(data, 'title', 'Unit')),
    title: _dbText(data, 'title', _dbText(data, 'name', 'Unit')),
    unitNumber: _dbText(data, 'unitNumber', _dbText(data, 'name', 'Unit')),
    floor: _dbText(data, 'floor', '1st Floor'),
    location: _dbText(data, 'location', 'Main Property'),
    latitude: data['latitude'] != null ? _dbNumber(data, 'latitude') : null,
    longitude: data['longitude'] != null ? _dbNumber(data, 'longitude') : null,
    rent: _dbNumber(data, 'rent', _dbNumber(data, 'monthlyRent')),
    monthlyRent: _dbNumber(data, 'monthlyRent', _dbNumber(data, 'rent')),
    status: _dbText(data, 'status', 'Vacant'),
    description: _dbText(data, 'description'),
    area: _dbNumber(data, 'area', _dbNumber(data, 'areaSqm')),
    areaSqm: _dbNumber(data, 'areaSqm', _dbNumber(data, 'area')),
    bedrooms: _dbInt(data, 'bedrooms', 1),
    bathrooms: _dbInt(data, 'bathrooms', 1),
    amenities: FirestoreService.strings(data['amenities']),
    inclusions: FirestoreService.strings(data['inclusions']),
    images: images,
    imageUrl: _dbText(data, 'imageUrl', images.firstOrNull ?? ''),
    tenantId: data['tenantId'] as String?,
    tenantName: data['tenantName'] as String?,
    currentTenancyId: data['currentTenancyId'] as String?,
    dueDate: dueValue == null ? null : FirestoreService.date(dueValue),
    rentDueDay: _dbInt(data, 'rentDueDay', 5).clamp(1, 31),
    lateFee: _dbNumber(data, 'lateFee', 500).clamp(0, double.infinity),
    vacantDays: _dbInt(data, 'vacantDays'),
    waterReadingPrev: _dbNumber(data, 'waterReadingPrev'),
    waterReadingCurr: _dbNumber(data, 'waterReadingCurr'),
    electricReadingPrev: _dbNumber(data, 'electricReadingPrev'),
    electricReadingCurr: _dbNumber(data, 'electricReadingCurr'),
    leasePdfTitle: data['leasePdfTitle'] as String?,
    isArchived: _dbBool(data, 'isArchived'),
    detailsCompleted: _dbBool(data, 'detailsCompleted', true),
    waterUtilityEnabled: _dbBool(data, 'waterUtilityEnabled', true),
    electricityUtilityEnabled: _dbBool(data, 'electricityUtilityEnabled', true),
    waterRateOverride: data['waterRateOverride'] == null
        ? null
        : _dbNumber(data, 'waterRateOverride'),
    electricityRateOverride: data['electricityRateOverride'] == null
        ? null
        : _dbNumber(data, 'electricityRateOverride'),
    maintenanceAreas: FirestoreService.strings(data['maintenanceAreas']).isEmpty
        ? const ['Bathroom', 'Bedroom', 'Indoor Area', 'Outdoor Area']
        : FirestoreService.strings(data['maintenanceAreas']),
  );
}

Tenant _tenantFromDb(Map<String, dynamic> data) {
  final unitNumber = _dbText(data, 'unitNumber', 'Unassigned');
  final numericUnit = RegExp(r'\d+').firstMatch(unitNumber)?.group(0);
  return Tenant(
    id: _dbText(data, 'id'),
    name: _dbText(data, 'name', 'Unnamed tenant'),
    email: _dbText(data, 'email'),
    phone: _dbText(data, 'phone', _dbText(data, 'contactNumber')),
    contactNumber: _dbText(data, 'contactNumber', _dbText(data, 'phone')),
    address: _dbText(data, 'address'),
    referral: _dbText(data, 'referral'),
    unitId: _dbText(data, 'unitId', numericUnit == null ? '' : 'u$numericUnit'),
    unitNumber: unitNumber,
    monthlyRent: _dbNumber(data, 'monthlyRent'),
    leaseStart: _dbDate(data, 'leaseStart'),
    leaseEnd: _dbDate(
        data, 'leaseEnd', DateTime.now().add(const Duration(days: 365))),
    dueDate: _dbDate(data, 'dueDate', DateTime.now()),
    balance: _dbNumber(data, 'balance'),
    status: _dbText(data, 'status', 'Active'),
    isArchived: _dbBool(data, 'isArchived'),
    avatarUrl: data['avatarUrl'] as String?,
    currentTenancyId: data['currentTenancyId'] as String?,
  );
}

PaymentData _paymentFromDb(Map<String, dynamic> data) => PaymentData(
      id: _dbText(data, 'id'),
      month: _dbText(
          data,
          'month',
          DateFormat('MMM').format(_dbDate(
              data, data.containsKey('date') ? 'date' : 'paymentDate'))),
      amount: _dbNumber(data, 'amount'),
      method: _dbText(data, 'method', _dbText(data, 'paymentMethod', 'Cash')),
      paymentMethod:
          _dbText(data, 'paymentMethod', _dbText(data, 'method', 'Cash')),
      date: _dbDate(data, data.containsKey('date') ? 'date' : 'paymentDate'),
      paymentDate: _dbDate(
          data, data.containsKey('paymentDate') ? 'paymentDate' : 'date'),
      status: _dbText(data, 'status', 'Pending'),
      unitId: _dbText(data, 'unitId'),
      referenceNumber: _dbText(data, 'referenceNumber'),
      baseRent: _dbNumber(data, 'baseRent', _dbNumber(data, 'amount')),
      waterBill: _dbNumber(data, 'waterBill'),
      electricBill: _dbNumber(data, 'electricBill'),
      lateFee: _dbNumber(data, 'lateFee'),
      otherCharge: _dbNumber(data, 'otherCharge'),
      tenantName: _dbText(data, 'tenantName'),
      unitNumber: _dbText(data, 'unitNumber'),
      tenantId: _dbText(data, 'tenantId'),
      tenancyId: data['tenancyId'] as String?,
      proofImageUrl: _dbText(data, 'proofImageUrl'),
      remarks: data['remarks'] as String?,
      declineReason: data['declineReason'] as String?,
      transactionType: _dbText(data, 'transactionType', 'Rent'),
      ticketId: data['ticketId'] as String?,
    );

Ticket _ticketFromDb(Map<String, dynamic> data) {
  final historyRaw = data['statusHistory'];
  List<TicketStatusHistoryEntry> history = [];
  if (historyRaw is List) {
    history = historyRaw
        .whereType<Map<String, dynamic>>()
        .map(TicketStatusHistoryEntry.fromJson)
        .toList();
  }

  return Ticket(
    id: _dbText(data, 'id'),
    title: _dbText(data, 'title'),
    description: _dbText(data, 'description'),
    category: _dbText(data, 'category', 'General'),
    photoPath: data['photoPath'] as String?,
    photoBefore: data['photoBefore'] as String?,
    photoAfter: data['photoAfter'] as String?,
    photos: FirestoreService.strings(data['photos']),
    priority: _dbText(data, 'priority', 'Med'),
    status: _dbText(data, 'status', 'Pending'),
    assignedTo: _dbText(data, 'assignedTo', _dbText(data, 'assignedToName')),
    assignedToName:
        _dbText(data, 'assignedToName', _dbText(data, 'assignedTo')),
    vendorId: data['vendorId'] as String?,
    estimatedCost:
        _dbNumber(data, 'estimatedCost', _dbNumber(data, 'vendorCost')),
    actualCost: _dbNumber(data, 'actualCost'),
    vendorCost: _dbNumber(data, 'vendorCost', _dbNumber(data, 'actualCost')),
    date: _dbDate(data, data.containsKey('date') ? 'date' : 'createdAt'),
    createdAt:
        _dbDate(data, data.containsKey('createdAt') ? 'createdAt' : 'date'),
    slaDueDate: data['slaDueDate'] == null
        ? null
        : FirestoreService.date(data['slaDueDate']),
    rating: _dbInt(data, 'rating'),
    ratingFeedback: data['ratingFeedback'] as String?,
    unitNumber: _dbText(data, 'unitNumber'),
    tenantName: _dbText(data, 'tenantName'),
    unitId: _dbText(data, 'unitId'),
    tenantId: data['tenantId'] as String?,
    tenancyId: data['tenancyId'] as String?,
    responsibleParty: _dbText(data, 'responsibleParty', 'Landlord'),
    paymentRequired: _dbBool(data, 'paymentRequired'),
    paymentStatus: _dbText(data, 'paymentStatus', 'Not Required'),
    statusHistory: history,
    affectedAreas: FirestoreService.strings(data['affectedAreas']),
    issueStartedAt: data['issueStartedAt'] == null
        ? null
        : FirestoreService.date(data['issueStartedAt']),
    visitScheduledAt: data['visitScheduledAt'] == null
        ? null
        : FirestoreService.date(data['visitScheduledAt']),
    visitTimeWindow: _dbText(data, 'visitTimeWindow'),
    visitReminderSent: _dbBool(data, 'visitReminderSent'),
    replacementItems: FirestoreService.strings(data['replacementItems']),
    repairScheduledAt: data['repairScheduledAt'] == null
        ? null
        : FirestoreService.date(data['repairScheduledAt']),
    repairTimeWindow: _dbText(data, 'repairTimeWindow'),
    repairer: _dbText(data, 'repairer'),
    repairReminderSent: _dbBool(data, 'repairReminderSent'),
    completionSummary: _dbText(data, 'completionSummary'),
  );
}

Future<void> hydratePersistentAppData(WidgetRef ref) async {
  final supabase = SupabaseService();
  final firestore = FirestoreService();

  Future<List<Map<String, dynamic>>> fetchCollection(String name) async {
    final supaResult = await supabase.loadTable(name);
    final supaData = supaResult.dataOrNull ?? [];
    if (supaData.isNotEmpty) return supaData;
    return await firestore.loadCollection(name);
  }

  final results = await Future.wait([
    fetchCollection('units'),
    fetchCollection('tenants'),
    fetchCollection('payments'),
    fetchCollection('maintenanceTickets'),
    fetchCollection('announcements'),
    fetchCollection('notifications'),
    fetchCollection('expenses'),
    fetchCollection('tenantDocuments'),
    fetchCollection('settings'),
    fetchCollection('utilityRateLogs'),
  ]);

  final units = results[0].map(_unitFromDb).toList();
  final tenants = results[1].map(_tenantFromDb).toList();
  final payments = results[2].map(_paymentFromDb).toList();
  final tickets = results[3].map(_ticketFromDb).toList();
  final announcements = results[4]
      .map((data) => Announcement(
            id: _dbText(data, 'id'),
            title: _dbText(data, 'title'),
            message: _dbText(data, 'message'),
            timestamp: _dbDate(data, 'timestamp'),
            author: _dbText(data, 'author'),
            isImportant: _dbBool(data, 'isImportant'),
            category: _dbText(data, 'category', 'General'),
            isArchived: _dbBool(data, 'isArchived'),
          ))
      .toList();
  final notifications = results[5]
      .map((data) => AppNotification(
            id: _dbText(data, 'id'),
            title: _dbText(data, 'title', _dbText(data, 'message')),
            message: _dbText(data, 'message'),
            timestamp: _dbDate(data, 'timestamp'),
            isRead: _dbBool(data, 'isRead'),
            isArchived: _dbBool(data, 'isArchived'),
            type: _dbText(data, 'type', 'system'),
            entityType: data['entityType'] as String?,
            entityId: data['entityId'] as String?,
            action: data['action'] as String?,
          ))
      .toList();
  final expenses = results[6]
      .map((data) => ExpenseItem(
            id: _dbText(data, 'id'),
            title: _dbText(data, 'title'),
            category: _dbText(data, 'category', 'Other'),
            amount: _dbNumber(data, 'amount'),
            date: _dbDate(data, 'date'),
            unitId: data['unitId'] as String?,
            unitNumber: data['unitNumber'] as String?,
            recordedBy: _dbText(
                data, 'recordedBy', "Emin and Mila's Property Management"),
            notes: data['notes'] as String?,
          ))
      .toList();
  final documents = results[7]
      .map((data) => TenantDocument(
            id: _dbText(data, 'id'),
            tenantId: _dbText(data, 'tenantId'),
            tenantName: _dbText(data, 'tenantName'),
            title: _dbText(data, 'title'),
            type: _dbText(data, 'type', 'Other'),
            fileName: _dbText(data, 'fileName'),
            fileSize: _dbText(data, 'fileSize'),
            uploadedAt: _dbDate(data, 'uploadedAt'),
          ))
      .toList();

  replacePersistentCollections(
    ref,
    units: units,
    tenants: tenants,
    payments: payments,
    tickets: tickets,
    announcements: announcements,
    notifications: notifications,
    expenses: expenses,
    documents: documents,
  );

  final settings = results[8].where((item) => item['id'] == 'app').firstOrNull;
  final utilityRateHistory = results[9]
      .map((data) => UtilityRateChange(
            id: _dbText(data, 'id'),
            utility: _dbText(data, 'utility', 'Water'),
            previousRate: _dbNumber(data, 'previousRate'),
            newRate: _dbNumber(data, 'newRate'),
            effectiveAt: _dbDate(data, 'effectiveAt'),
            note: _dbText(data, 'note'),
          ))
      .toList();
  if (settings != null) {
    ref.read(lateFeeAmountProvider.notifier).state =
        _dbNumber(settings, 'defaultLateFee', 500);
    ref.read(dueDateDayProvider.notifier).state =
        _dbInt(settings, 'defaultDueDay', 5).clamp(1, 31);
    ref.read(autoLateFeeEnabledProvider.notifier).state =
        _dbBool(settings, 'autoLateFeeEnabled', true);
    ref.read(autoBackupProvider.notifier).state =
        _dbBool(settings, 'autoBackupEnabled', true);
    ref.read(darkModeProvider.notifier).state =
        _dbBool(settings, 'darkMode', false);
    ref.read(landlordProfileProvider.notifier).state = (
      name: _dbText(settings, 'landlordName', "Emin and Mila's"),
      role:
          _dbText(settings, 'landlordRole', 'Property Representative / Admin'),
      contact: _dbText(settings, 'landlordContact',
          '0917-123-4567 • support@ramp-properties.com'),
    );
    ref.read(utilityRateProvider.notifier).replaceAll(
          waterRate: _dbNumber(settings, 'waterRate', 45),
          electricityRate: _dbNumber(settings, 'electricityRate', 12.5),
          history: utilityRateHistory,
        );
  } else {
    ref.read(utilityRateProvider.notifier).replaceAll(
          waterRate: 45,
          electricityRate: 12.5,
          history: utilityRateHistory,
        );
  }
}

/// Applies a complete Firestore snapshot, including valid empty collections.
void replacePersistentCollections(
  WidgetRef ref, {
  required List<Unit> units,
  required List<Tenant> tenants,
  required List<PaymentData> payments,
  required List<Ticket> tickets,
  required List<Announcement> announcements,
  required List<AppNotification> notifications,
  required List<ExpenseItem> expenses,
  required List<TenantDocument> documents,
}) {
  ref.read(unitProvider.notifier).replaceAll(units);
  ref.read(tenantProvider.notifier).replaceAll(tenants);
  ref.read(paymentProvider.notifier).replaceAll(payments);
  ref.read(ticketProvider.notifier).replaceAll(tickets);
  ref.read(announcementProvider.notifier).replaceAll(announcements);
  ref.read(notificationProvider.notifier).replaceAll(notifications);
  ref.read(expenseProvider.notifier).replaceAll(expenses);
  ref.read(tenantDocumentProvider.notifier).replaceAll(documents);
}
