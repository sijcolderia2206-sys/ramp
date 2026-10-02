// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Unit _$UnitFromJson(Map<String, dynamic> json) => _Unit(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      title: json['title'] as String?,
      unitNumber: json['unitNumber'] as String?,
      floor: json['floor'] as String? ?? '1st Floor',
      location: json['location'] as String? ?? 'Main Property',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rent: (json['rent'] as num?)?.toDouble() ?? 8500.0,
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble() ?? 8500.0,
      status: json['status'] as String? ?? 'Vacant',
      description: json['description'] as String? ?? '',
      area: (json['area'] as num?)?.toDouble() ?? 28.0,
      areaSqm: (json['areaSqm'] as num?)?.toDouble() ?? 28.0,
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 1,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 1,
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      inclusions: (json['inclusions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['Water', 'Electricity', 'Wifi'],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      imageUrl: json['imageUrl'] as String?,
      tenantId: json['tenantId'] as String?,
      tenantName: json['tenantName'] as String?,
      currentTenancyId: json['currentTenancyId'] as String?,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      rentDueDay: (json['rentDueDay'] as num?)?.toInt() ?? 5,
      lateFee: (json['lateFee'] as num?)?.toDouble() ?? 500.0,
      vacantDays: (json['vacantDays'] as num?)?.toInt() ?? 0,
      waterReadingPrev: (json['waterReadingPrev'] as num?)?.toDouble() ?? 120.5,
      waterReadingCurr: (json['waterReadingCurr'] as num?)?.toDouble() ?? 135.2,
      electricReadingPrev:
          (json['electricReadingPrev'] as num?)?.toDouble() ?? 1450.0,
      electricReadingCurr:
          (json['electricReadingCurr'] as num?)?.toDouble() ?? 1620.0,
      leasePdfTitle: json['leasePdfTitle'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      detailsCompleted: json['detailsCompleted'] as bool? ?? true,
      waterUtilityEnabled: json['waterUtilityEnabled'] as bool? ?? true,
      electricityUtilityEnabled:
          json['electricityUtilityEnabled'] as bool? ?? true,
      waterRateOverride: (json['waterRateOverride'] as num?)?.toDouble(),
      electricityRateOverride:
          (json['electricityRateOverride'] as num?)?.toDouble(),
      maintenanceAreas: (json['maintenanceAreas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['Bathroom', 'Bedroom', 'Indoor Area', 'Outdoor Area'],
    );

Map<String, dynamic> _$UnitToJson(_Unit instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'unitNumber': instance.unitNumber,
      'floor': instance.floor,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'rent': instance.rent,
      'monthlyRent': instance.monthlyRent,
      'status': instance.status,
      'description': instance.description,
      'area': instance.area,
      'areaSqm': instance.areaSqm,
      'bedrooms': instance.bedrooms,
      'bathrooms': instance.bathrooms,
      'amenities': instance.amenities,
      'inclusions': instance.inclusions,
      'images': instance.images,
      'imageUrl': instance.imageUrl,
      'tenantId': instance.tenantId,
      'tenantName': instance.tenantName,
      'currentTenancyId': instance.currentTenancyId,
      'dueDate': instance.dueDate?.toIso8601String(),
      'rentDueDay': instance.rentDueDay,
      'lateFee': instance.lateFee,
      'vacantDays': instance.vacantDays,
      'waterReadingPrev': instance.waterReadingPrev,
      'waterReadingCurr': instance.waterReadingCurr,
      'electricReadingPrev': instance.electricReadingPrev,
      'electricReadingCurr': instance.electricReadingCurr,
      'leasePdfTitle': instance.leasePdfTitle,
      'isArchived': instance.isArchived,
      'detailsCompleted': instance.detailsCompleted,
      'waterUtilityEnabled': instance.waterUtilityEnabled,
      'electricityUtilityEnabled': instance.electricityUtilityEnabled,
      'waterRateOverride': instance.waterRateOverride,
      'electricityRateOverride': instance.electricityRateOverride,
      'maintenanceAreas': instance.maintenanceAreas,
    };
