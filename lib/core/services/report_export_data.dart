import '../../models/models.dart';

String buildPaymentsCsv(List<PaymentData> payments) {
  final buffer = StringBuffer();
  buffer.writeln('ID,Tenant,Unit,Amount,Status,Date,Method,Reference');
  for (final p in payments) {
    buffer.writeln(
      '${p.id},"${p.tenantName}","${p.unitNumber}","${p.amount.toStringAsFixed(2)}","${p.status}","${p.formattedDate}","${p.method}","${p.referenceNumber}"',
    );
  }
  return buffer.toString();
}
