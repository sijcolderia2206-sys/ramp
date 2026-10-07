// lib/models/ticket_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'ticket_model.freezed.dart';
part 'ticket_model.g.dart';

@freezed
abstract class TicketStatusHistoryEntry with _$TicketStatusHistoryEntry {
  const TicketStatusHistoryEntry._();

  const factory TicketStatusHistoryEntry({
    @Default('') String status,
    DateTime? timestamp,
    String? note,
  }) = _TicketStatusHistoryEntry;

  factory TicketStatusHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$TicketStatusHistoryEntryFromJson(json);

  DateTime get effectiveTimestamp => timestamp ?? DateTime.now();

  String get formattedTime =>
      DateFormat('MMM dd, yyyy • hh:mm a').format(effectiveTimestamp);
}

@freezed
abstract class Ticket with _$Ticket {
  const Ticket._();

  const factory Ticket({
    @Default('') String id,
    String? unitId,
    @Default('Unit 1') String unitNumber,
    String? tenantId,
    @Default('Juan Dela Cruz') String tenantName,
    @Default('') String title,
    @Default('') String description,
    @Default('General') String category,
    String? photoPath,
    String? photoBefore,
    String? photoAfter,
    @Default([]) List<String> photos,
    @Default('Med') String priority,
    @Default('Schedule Visit') String status,
    @Default('Alex Rivera (Plumbing & HVAC)') String assignedTo,
    @Default('Alex Rivera (Plumbing & HVAC)') String assignedToName,
    String? vendorId,
    @Default(0.0) double estimatedCost,
    @Default(0.0) double actualCost,
    @Default(0.0) double vendorCost,
    DateTime? date,
    DateTime? createdAt,
    DateTime? slaDueDate,
    @Default(0) int rating,
    String? ratingFeedback,
    @Default('Landlord') String responsibleParty,
    @Default(false) bool paymentRequired,
    @Default('Not Required') String paymentStatus,
    String? tenancyId,
    @Default([]) List<TicketStatusHistoryEntry> statusHistory,
    @Default([]) List<String> affectedAreas,
    DateTime? issueStartedAt,
    DateTime? visitScheduledAt,
    @Default('') String visitTimeWindow,
    @Default(false) bool visitReminderSent,
    @Default([]) List<String> replacementItems,
    DateTime? repairScheduledAt,
    @Default('') String repairTimeWindow,
    @Default('') String repairer,
    @Default(false) bool repairReminderSent,
    @Default('') String completionSummary,
  }) = _Ticket;

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  DateTime get reportedAt => createdAt ?? date ?? DateTime.now();

  DateTime? get completedAt {
    for (final entry in statusHistory) {
      if (entry.status.toLowerCase() == 'completed') {
        return entry.timestamp;
      }
    }
    return null;
  }

  DateTime get effectiveCreatedAt => createdAt ?? date ?? DateTime.now();

  DateTime get effectiveDate => date ?? createdAt ?? DateTime.now();

  DateTime get effectiveSlaDueDate =>
      slaDueDate ?? computeSlaDueDate(priority, effectiveCreatedAt);

  static DateTime computeSlaDueDate(String priority, DateTime created) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'emergency':
        return created.add(const Duration(days: 1));
      case 'low':
        return created.add(const Duration(days: 7));
      case 'med':
      case 'medium':
      default:
        return created.add(const Duration(days: 3));
    }
  }

  bool get isSlaBreached {
    if (status.toLowerCase() == 'completed' ||
        status.toLowerCase() == 'closed') {
      return false;
    }
    return DateTime.now().isAfter(effectiveSlaDueDate);
  }

  String get slaStatusText {
    if (status.toLowerCase() == 'completed' ||
        status.toLowerCase() == 'closed') {
      return 'SLA Met';
    }
    final diff = effectiveSlaDueDate.difference(DateTime.now()).inHours;
    if (diff < 0) return 'SLA Breached!';
    if (diff < 24) return 'SLA Due in ${diff}h';
    return 'SLA Due in ${(diff / 24).ceil()}d';
  }

  double get cost => actualCost > 0 ? actualCost : estimatedCost;

  String get formattedCost {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(estimatedCost);
  }

  String get formattedActualCost {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(actualCost);
  }

  String get formattedDate =>
      DateFormat('MMM dd, yyyy • hh:mm a').format(effectiveCreatedAt);

  bool get isScheduleVisitStage =>
      status.toLowerCase() == 'pending' ||
      status.toLowerCase() == 'schedule visit';

  bool get isEstimateStage => status.toLowerCase() == 'estimate';

  bool get isScheduleRepairStage =>
      status.toLowerCase() == 'schedule repair' ||
      status.toLowerCase() == 'in progress';

  bool get isCompletedStage =>
      status.toLowerCase() == 'completed' || status.toLowerCase() == 'closed';
}
