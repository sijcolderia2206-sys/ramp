import '../../models/models.dart';
import 'report_export_data.dart';
import 'report_export_io.dart' if (dart.library.html) 'report_export_stub.dart';

class ReportExportService {
  static Future<String> exportPaymentsReport(List<PaymentData> payments) async {
    final csvContent = buildPaymentsCsv(payments);
    final fileName =
        'RAMP_Payments_${DateTime.now().millisecondsSinceEpoch}.csv';
    return await exportReportToFile(content: csvContent, fileName: fileName);
  }

  static Future<String> exportPaymentsCsv(List<PaymentData> payments) async {
    return exportPaymentsReport(payments);
  }

  static Future<String> exportLandlordReport({
    String? reportType,
    String? timeFrame,
    List<Unit>? units,
    List<Tenant>? tenants,
    List<PaymentData>? payments,
    List<Ticket>? tickets,
  }) async {
    return exportPaymentsReport(payments ?? []);
  }
}
