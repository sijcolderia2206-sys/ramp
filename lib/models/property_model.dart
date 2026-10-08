// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/models/property_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'property_model.freezed.dart';
part 'property_model.g.dart';

typedef Property = PropertyModel;

@freezed
abstract class PropertyModel with _$PropertyModel {
  const factory PropertyModel({
    required String id,
    required String landlordId,
    required String name,
    required String address,
    @Default([]) List<String> unitIds,
  }) = _PropertyModel;

  factory PropertyModel.fromJson(Map<String, dynamic> json) => _$PropertyModelFromJson(json);
}

@freezed
abstract class UnitModel with _$UnitModel {
  const factory UnitModel({
    required String id,
    required String propertyId,
    required String unitNumber,
    required double baseRent,
    String? currentTenantId,
    @Default(false) bool isOccupied,
  }) = _UnitModel;

  factory UnitModel.fromJson(Map<String, dynamic> json) => _$UnitModelFromJson(json);
}
