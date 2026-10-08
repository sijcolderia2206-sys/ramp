// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/features/billing/billing_engine.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/billing_model.dart';
import '../../core/services/persistence_queue.dart';
import '../../core/audit_logger.dart';
import '../../core/state/ramp_state.dart';

part 'billing_engine.g.dart';

@riverpod
class BillingEngine extends _$BillingEngine {
  @override
  FutureOr<List<BillingInvoice>> build() async {
    // In a real app, fetch from Firestore/Supabase
    return [];
  }

  Future<void> generateInvoice({
    required String tenantId,
    required String unitId,
    required double baseRent,
    required double waterUsage,
    required double electricUsage,
  }) async {
    final newInvoice = BillingInvoice(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      tenantId: tenantId,
      unitId: unitId,
      baseRent: baseRent,
      waterUsage: waterUsage,
      electricUsage: electricUsage,
      dueDate: DateTime.now().add(const Duration(days: 7)),
    );

    // Optimistic update
    final currentInvoices = state.value ?? [];
    state = AsyncData([...currentInvoices, newInvoice]);

    // 1. Offline-First Protocol
    PersistenceQueue.instance.enqueueUpsert('invoices', newInvoice.id, newInvoice.toJson());
    
    // 2. Audit Logging Engine
    final currentUser = ref.read(currentUserProvider);
    ref.read(auditLoggerProvider.notifier).logAction(
      currentUser?.uid ?? 'system',
      'GENERATE_INVOICE',
      'Invoice ${newInvoice.id} generated for unit $unitId. Total: PHP ${newInvoice.totalAmount}',
    );
  }
}
