// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PropertyModel _$PropertyModelFromJson(Map<String, dynamic> json) =>
    _PropertyModel(
      id: json['id'] as String,
      landlordId: json['landlordId'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      unitIds: (json['unitIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PropertyModelToJson(_PropertyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'landlordId': instance.landlordId,
      'name': instance.name,
      'address': instance.address,
      'unitIds': instance.unitIds,
    };

_UnitModel _$UnitModelFromJson(Map<String, dynamic> json) => _UnitModel(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      unitNumber: json['unitNumber'] as String,
      baseRent: (json['baseRent'] as num).toDouble(),
      currentTenantId: json['currentTenantId'] as String?,
      isOccupied: json['isOccupied'] as bool? ?? false,
    );

Map<String, dynamic> _$UnitModelToJson(_UnitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'propertyId': instance.propertyId,
      'unitNumber': instance.unitNumber,
      'baseRent': instance.baseRent,
      'currentTenantId': instance.currentTenantId,
      'isOccupied': instance.isOccupied,
    };
