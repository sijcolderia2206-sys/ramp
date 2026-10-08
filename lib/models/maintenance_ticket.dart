// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/models/maintenance_ticket.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'maintenance_ticket.freezed.dart';
part 'maintenance_ticket.g.dart';

enum TicketSeverity {
  @JsonValue('emergency') emergency, // 24h SLA
  @JsonValue('medium') medium,       // 3 days SLA
  @JsonValue('low') low              // 7 days SLA
}

enum TicketStatus {
  @JsonValue('open') open,
  @JsonValue('in_progress') inProgress,
  @JsonValue('resolved') resolved,
  @JsonValue('closed') closed,
}

@freezed
abstract class MaintenanceTicket with _$MaintenanceTicket {
  const factory MaintenanceTicket({
    required String id,
    required String tenantId,
    required String unitId,
    required String title,
    required String description,
    required TicketSeverity severity,
    @Default(TicketStatus.open) TicketStatus status,
    List<String>? photoUrls,
    int? rating, // 1-to-5 star rating
    required DateTime createdAt,
    DateTime? resolvedAt,
  }) = _MaintenanceTicket;

  const MaintenanceTicket._();

  // SLA Maintenance Engine Logic
  DateTime get slaDeadline {
    switch (severity) {
      case TicketSeverity.emergency:
        return createdAt.add(const Duration(hours: 24));
      case TicketSeverity.medium:
        return createdAt.add(const Duration(days: 3));
      case TicketSeverity.low:
        return createdAt.add(const Duration(days: 7));
    }
  }

  factory MaintenanceTicket.fromJson(Map<String, dynamic> json) => _$MaintenanceTicketFromJson(json);
}
