// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/features/payments/payment_queue_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/services/persistence_queue.dart';
import '../../core/audit_logger.dart';
import '../../core/state/ramp_state.dart';

part 'payment_queue_notifier.g.dart';

// A simple DTO for the payment verification queue
class PaymentVerificationTask {
  final String invoiceId;
  final String tenantId;
  final double amount;
  final String receiptUrl;

  PaymentVerificationTask({
    required this.invoiceId,
    required this.tenantId,
    required this.amount,
    required this.receiptUrl,
  });
}

@riverpod
class PaymentQueue extends _$PaymentQueue {
  @override
  FutureOr<List<PaymentVerificationTask>> build() async {
    // Mocking initial queue
    return [
      PaymentVerificationTask(
        invoiceId: 'inv_123',
        tenantId: 'tenant_abc',
        amount: 15500.0,
        receiptUrl: 'https://example.com/receipt.jpg',
      )
    ];
  }

  Future<void> approvePayment(String invoiceId) async {
    final previousState = state.value ?? [];
    
    // 0ms Latency Optimistic Update for critical flows
    state = AsyncData(previousState.where((task) => task.invoiceId != invoiceId).toList());

    // Queue action for offline sync
    PersistenceQueue.instance.enqueueUpsert('payments', invoiceId, {'id': invoiceId, 'status': 'approved'});
    
    // Audit log
    final currentUser = ref.read(currentUserProvider);
    ref.read(auditLoggerProvider.notifier).logAction(
      currentUser?.uid ?? 'system',
      'APPROVE_PAYMENT',
      'Approved payment for invoice $invoiceId',
    );
  }
  
  Future<void> rejectPayment(String invoiceId, String reason) async {
    final previousState = state.value ?? [];
    
    // 0ms Latency Optimistic Update
    state = AsyncData(previousState.where((task) => task.invoiceId != invoiceId).toList());

    PersistenceQueue.instance.enqueueUpsert('payments', invoiceId, {'id': invoiceId, 'status': 'rejected', 'rejectReason': reason});
    
    final currentUser = ref.read(currentUserProvider);
    ref.read(auditLoggerProvider.notifier).logAction(
      currentUser?.uid ?? 'system',
      'REJECT_PAYMENT',
      'Rejected payment for invoice $invoiceId. Reason: $reason',
    );
  }
}
