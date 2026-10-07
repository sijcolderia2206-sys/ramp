// lib/models/rental_unit.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'rental_unit.freezed.dart';
part 'rental_unit.g.dart';

@freezed
abstract class Unit with _$Unit {
  const Unit._();

  const factory Unit({
    @Default('') String id,
    @Default('') String name,
    String? title,
    String? unitNumber,
    @Default('1st Floor') String floor,
    @Default('Main Property') String location,
    double? latitude,
    double? longitude,
    @Default(8500.0) double rent,
    @Default(8500.0) double monthlyRent,
    @Default('Vacant') String status,
    @Default('') String description,
    @Default(28.0) double area,
    @Default(28.0) double areaSqm,
    @Default(1) int bedrooms,
    @Default(1) int bathrooms,
    @Default([]) List<String> amenities,
    @Default(['Water', 'Electricity', 'Wifi']) List<String> inclusions,
    @Default([]) List<String> images,
    String? imageUrl,
    String? tenantId,
    String? tenantName,
    String? currentTenancyId,
    DateTime? dueDate,
    @Default(5) int rentDueDay,
    @Default(500.0) double lateFee,
    @Default(0) int vacantDays,
    @Default(120.5) double waterReadingPrev,
    @Default(135.2) double waterReadingCurr,
    @Default(1450.0) double electricReadingPrev,
    @Default(1620.0) double electricReadingCurr,
    String? leasePdfTitle,
    @Default(false) bool isArchived,
    @Default(true) bool detailsCompleted,
    @Default(true) bool waterUtilityEnabled,
    @Default(true) bool electricityUtilityEnabled,
    double? waterRateOverride,
    double? electricityRateOverride,
    @Default(['Bathroom', 'Bedroom', 'Indoor Area', 'Outdoor Area'])
    List<String> maintenanceAreas,
  }) = _Unit;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  double get rentAmount => rent;

  DateTime get effectiveDueDate => dueDate ?? DateTime.now();

  bool get isOccupied => status.toLowerCase() == 'occupied';
  bool get isVacant => status.toLowerCase() == 'vacant';
  bool get isMaintenance => status.toLowerCase() == 'maintenance';
  bool get isLongVacant => isVacant && vacantDays > 30;

  bool get hasWater => waterUtilityEnabled;
  bool get hasElectricity => electricityUtilityEnabled;
  bool get hasWifi => inclusions.any((i) =>
      i.toLowerCase().contains('wifi') || i.toLowerCase().contains('internet'));

  double get waterUsage => (waterReadingCurr - waterReadingPrev).clamp(0, 9999);
  double get electricUsage =>
      (electricReadingCurr - electricReadingPrev).clamp(0, 9999);

  double utilityBill(
          {required double waterRate, required double electricityRate}) =>
      (waterUtilityEnabled ? waterUsage * effectiveWaterRate(waterRate) : 0) +
      (electricityUtilityEnabled
          ? electricUsage * effectiveElectricityRate(electricityRate)
          : 0);

  double effectiveWaterRate(double masterRate) =>
      waterRateOverride ?? masterRate;
  double effectiveElectricityRate(double masterRate) =>
      electricityRateOverride ?? masterRate;

  String get formattedRent {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 0,
    );
    return '${formatter.format(rent)}/mo';
  }

  String get formattedDueDate {
    if (dueDate == null) return 'Due date not set';
    return DateFormat('MMM dd, yyyy').format(dueDate!);
  }

  String get formattedRentDueDay =>
      '$rentDueDay${_daySuffix(rentDueDay)} of month';

  static String _daySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
