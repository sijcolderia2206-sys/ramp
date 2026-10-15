// lib/models/unit_model.dart

import '../core/utils/safe_parse.dart';

class RentalUnit {
  final String id;
  final String landlordId;
  final String title;
  final String unitNumber;
  final String floor;
  final String location;
  final double monthlyRent;
  final int rentDueDay;
  final double lateFee;
  final String status; // 'Vacant', 'Occupied', 'Under Maintenance'
  final String? tenantId;
  final String? tenantName;
  final double waterReadingPrev;
  final double waterReadingCurr;
  final double electricReadingPrev;
  final double electricReadingCurr;
  final double? waterRateOverride;
  final double? electricityRateOverride;
  final List<String> maintenanceAreas;
  final int bedrooms;
  final int bathrooms;
  final double areaSqm;
  final List<String> images;

  // Extended Property Specifications & Financial Terms
  final String propertyType; // e.g. 'Apartment', 'Studio', 'Condo', 'Commercial', 'Parking'
  final String furnishingStatus; // e.g. 'Unfurnished', 'Semi-Furnished', 'Fully Furnished'
  final double securityDeposit;
  final int advanceRentMonths;
  final int minimumLeaseMonths;
  final String waterMeterSerialNumber;
  final String electricMeterSerialNumber;
  final List<String> inclusions; // e.g. 'Aircon', 'Refrigerator', 'Bed', 'Wi-Fi', 'Water Heater'
  final bool isPublished; // Published on web listing for vacant units

  const RentalUnit({
    required this.id,
    this.landlordId = 'l1',
    required this.title,
    required this.unitNumber,
    this.floor = '1st Floor',
    this.location = 'Building A',
    required this.monthlyRent,
    this.rentDueDay = 5,
    this.lateFee = 500.0,
    this.status = 'Vacant',
    this.tenantId,
    this.tenantName,
    this.waterReadingPrev = 0.0,
    this.waterReadingCurr = 0.0,
    this.electricReadingPrev = 0.0,
    this.electricReadingCurr = 0.0,
    this.waterRateOverride,
    this.electricityRateOverride,
    this.maintenanceAreas = const ['Bathroom', 'Bedroom', 'Indoor Area', 'Outdoor Area'],
    this.bedrooms = 1,
    this.bathrooms = 1,
    this.areaSqm = 35.0,
    this.images = const [],
    this.propertyType = 'Apartment',
    this.furnishingStatus = 'Unfurnished',
    this.securityDeposit = 0.0,
    this.advanceRentMonths = 1,
    this.minimumLeaseMonths = 12,
    this.waterMeterSerialNumber = '',
    this.electricMeterSerialNumber = '',
    this.inclusions = const [],
    this.isPublished = false,
  });

  /// Water Bill Calculation = (Current - Prev) * (Water Rate, Default: PHP 45.00/cu.m)
  double get waterUsage => (waterReadingCurr - waterReadingPrev).clamp(0, double.infinity);
  double get calculatedWaterBill => waterUsage * (waterRateOverride ?? 45.0);
  double calculateWaterBillWithRate([double rate = 45.0]) => waterUsage * (waterRateOverride ?? rate);

  /// Electric Bill Calculation = (Current - Prev) * (Electric Rate, Default: PHP 12.50/kWh)
  double get electricUsage => (electricReadingCurr - electricReadingPrev).clamp(0, double.infinity);
  double get calculatedElectricBill => electricUsage * (electricityRateOverride ?? 12.5);
  double calculateElectricBillWithRate([double rate = 12.5]) => electricUsage * (electricityRateOverride ?? rate);

  /// Total Estimated Utility Bill
  double get totalUtilityBill => calculatedWaterBill + calculatedElectricBill;

  /// Model Compatibility Getters for RAMP Property Management Specification
  String get roomType => title;
  String get buildingName => location;
  double get submetersDue => totalUtilityBill;

  RentalUnit copyWith({
    String? id,
    String? landlordId,
    String? title,
    String? unitNumber,
    String? floor,
    String? location,
    double? monthlyRent,
    int? rentDueDay,
    double? lateFee,
    String? status,
    String? tenantId,
    String? tenantName,
    double? waterReadingPrev,
    double? waterReadingCurr,
    double? electricReadingPrev,
    double? electricReadingCurr,
    double? waterRateOverride,
    double? electricityRateOverride,
    List<String>? maintenanceAreas,
    int? bedrooms,
    int? bathrooms,
    double? areaSqm,
    List<String>? images,
    String? propertyType,
    String? furnishingStatus,
    double? securityDeposit,
    int? advanceRentMonths,
    int? minimumLeaseMonths,
    String? waterMeterSerialNumber,
    String? electricMeterSerialNumber,
    List<String>? inclusions,
    bool? isPublished,
  }) {
    return RentalUnit(
      id: id ?? this.id,
      landlordId: landlordId ?? this.landlordId,
      title: title ?? this.title,
      unitNumber: unitNumber ?? this.unitNumber,
      floor: floor ?? this.floor,
      location: location ?? this.location,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      rentDueDay: rentDueDay ?? this.rentDueDay,
      lateFee: lateFee ?? this.lateFee,
      status: status ?? this.status,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      waterReadingPrev: waterReadingPrev ?? this.waterReadingPrev,
      waterReadingCurr: waterReadingCurr ?? this.waterReadingCurr,
      electricReadingPrev: electricReadingPrev ?? this.electricReadingPrev,
      electricReadingCurr: electricReadingCurr ?? this.electricReadingCurr,
      waterRateOverride: waterRateOverride ?? this.waterRateOverride,
      electricityRateOverride: electricityRateOverride ?? this.electricityRateOverride,
      maintenanceAreas: maintenanceAreas ?? this.maintenanceAreas,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      areaSqm: areaSqm ?? this.areaSqm,
      images: images ?? this.images,
      propertyType: propertyType ?? this.propertyType,
      furnishingStatus: furnishingStatus ?? this.furnishingStatus,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      advanceRentMonths: advanceRentMonths ?? this.advanceRentMonths,
      minimumLeaseMonths: minimumLeaseMonths ?? this.minimumLeaseMonths,
      waterMeterSerialNumber: waterMeterSerialNumber ?? this.waterMeterSerialNumber,
      electricMeterSerialNumber: electricMeterSerialNumber ?? this.electricMeterSerialNumber,
      inclusions: inclusions ?? this.inclusions,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'landlord_id': landlordId,
      'title': title,
      'unit_number': unitNumber,
      'floor': floor,
      'location': location,
      'monthly_rent': monthlyRent,
      'rent_due_day': rentDueDay,
      'late_fee': lateFee,
      'status': status,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'water_reading_prev': waterReadingPrev,
      'water_reading_curr': waterReadingCurr,
      'electric_reading_prev': electricReadingPrev,
      'electric_reading_curr': electricReadingCurr,
      'water_rate_override': waterRateOverride,
      'electricity_rate_override': electricityRateOverride,
      'maintenance_areas': maintenanceAreas,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area_sqm': areaSqm,
      'images': images,
      'property_type': propertyType,
      'furnishing_status': furnishingStatus,
      'security_deposit': securityDeposit,
      'advance_rent_months': advanceRentMonths,
      'minimum_lease_months': minimumLeaseMonths,
      'water_meter_serial': waterMeterSerialNumber,
      'electric_meter_serial': electricMeterSerialNumber,
      'inclusions': inclusions,
      'is_published': isPublished,
    };
  }

  factory RentalUnit.fromJson(Map<String, dynamic> json) {
    return RentalUnit(
      id: parseString(json['id'], 'unit_${DateTime.now().millisecondsSinceEpoch}'),
      landlordId: parseString(json['landlord_id'], 'l1'),
      title: parseString(json['title'] ?? json['name'], 'Unit'),
      unitNumber: parseString(json['unit_number'], '101'),
      floor: parseString(json['floor'], '1st Floor'),
      location: parseString(json['location'], 'Main Building'),
      monthlyRent: parseDouble(json['monthly_rent'] ?? json['rent'], 0.0),
      rentDueDay: parseInt(json['rent_due_day'], 5),
      lateFee: parseDouble(json['late_fee'], 500.0),
      status: parseString(json['status'], 'Vacant'),
      tenantId: parseNullableString(json['tenant_id']),
      tenantName: parseNullableString(json['tenant_name']),
      waterReadingPrev: parseDouble(json['water_reading_prev'], 0.0),
      waterReadingCurr: parseDouble(json['water_reading_curr'], 0.0),
      electricReadingPrev: parseDouble(json['electric_reading_prev'], 0.0),
      electricReadingCurr: parseDouble(json['electric_reading_curr'], 0.0),
      waterRateOverride: parseNullableDouble(json['water_rate_override']),
      electricityRateOverride: parseNullableDouble(json['electricity_rate_override']),
      maintenanceAreas: parseStringList(json['maintenance_areas'], const ['Bathroom', 'Bedroom', 'Indoor Area', 'Outdoor Area']),
      bedrooms: parseInt(json['bedrooms'], 1),
      bathrooms: parseInt(json['bathrooms'], 1),
      areaSqm: parseDouble(json['area_sqm'] ?? json['area'], 35.0),
      images: parseStringList(json['images']),
      propertyType: parseString(json['property_type'], 'Apartment'),
      furnishingStatus: parseString(json['furnishing_status'], 'Unfurnished'),
      securityDeposit: parseDouble(json['security_deposit'], 0.0),
      advanceRentMonths: parseInt(json['advance_rent_months'], 1),
      minimumLeaseMonths: parseInt(json['minimum_lease_months'], 12),
      waterMeterSerialNumber: parseString(json['water_meter_serial']),
      electricMeterSerialNumber: parseString(json['electric_meter_serial']),
      inclusions: parseStringList(json['inclusions']),
      isPublished: parseBool(json['is_published'], false),
    );
  }
}
