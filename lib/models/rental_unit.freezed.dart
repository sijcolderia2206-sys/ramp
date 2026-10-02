// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rental_unit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Unit {
  String get id;
  String get name;
  String? get title;
  String? get unitNumber;
  String get floor;
  String get location;
  double? get latitude;
  double? get longitude;
  double get rent;
  double get monthlyRent;
  String get status;
  String get description;
  double get area;
  double get areaSqm;
  int get bedrooms;
  int get bathrooms;
  List<String> get amenities;
  List<String> get inclusions;
  List<String> get images;
  String? get imageUrl;
  String? get tenantId;
  String? get tenantName;
  String? get currentTenancyId;
  DateTime? get dueDate;
  int get rentDueDay;
  double get lateFee;
  int get vacantDays;
  double get waterReadingPrev;
  double get waterReadingCurr;
  double get electricReadingPrev;
  double get electricReadingCurr;
  String? get leasePdfTitle;
  bool get isArchived;
  bool get detailsCompleted;
  bool get waterUtilityEnabled;
  bool get electricityUtilityEnabled;
  double? get waterRateOverride;
  double? get electricityRateOverride;
  List<String> get maintenanceAreas;

  /// Create a copy of Unit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UnitCopyWith<Unit> get copyWith =>
      _$UnitCopyWithImpl<Unit>(this as Unit, _$identity);

  /// Serializes this Unit to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Unit &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.unitNumber, unitNumber) ||
                other.unitNumber == unitNumber) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.rent, rent) || other.rent == rent) &&
            (identical(other.monthlyRent, monthlyRent) ||
                other.monthlyRent == monthlyRent) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.areaSqm, areaSqm) || other.areaSqm == areaSqm) &&
            (identical(other.bedrooms, bedrooms) ||
                other.bedrooms == bedrooms) &&
            (identical(other.bathrooms, bathrooms) ||
                other.bathrooms == bathrooms) &&
            const DeepCollectionEquality().equals(other.amenities, amenities) &&
            const DeepCollectionEquality()
                .equals(other.inclusions, inclusions) &&
            const DeepCollectionEquality().equals(other.images, images) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.tenantName, tenantName) ||
                other.tenantName == tenantName) &&
            (identical(other.currentTenancyId, currentTenancyId) ||
                other.currentTenancyId == currentTenancyId) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.rentDueDay, rentDueDay) ||
                other.rentDueDay == rentDueDay) &&
            (identical(other.lateFee, lateFee) || other.lateFee == lateFee) &&
            (identical(other.vacantDays, vacantDays) ||
                other.vacantDays == vacantDays) &&
            (identical(other.waterReadingPrev, waterReadingPrev) ||
                other.waterReadingPrev == waterReadingPrev) &&
            (identical(other.waterReadingCurr, waterReadingCurr) ||
                other.waterReadingCurr == waterReadingCurr) &&
            (identical(other.electricReadingPrev, electricReadingPrev) ||
                other.electricReadingPrev == electricReadingPrev) &&
            (identical(other.electricReadingCurr, electricReadingCurr) ||
                other.electricReadingCurr == electricReadingCurr) &&
            (identical(other.leasePdfTitle, leasePdfTitle) ||
                other.leasePdfTitle == leasePdfTitle) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.detailsCompleted, detailsCompleted) ||
                other.detailsCompleted == detailsCompleted) &&
            (identical(other.waterUtilityEnabled, waterUtilityEnabled) ||
                other.waterUtilityEnabled == waterUtilityEnabled) &&
            (identical(other.electricityUtilityEnabled,
                    electricityUtilityEnabled) ||
                other.electricityUtilityEnabled == electricityUtilityEnabled) &&
            (identical(other.waterRateOverride, waterRateOverride) ||
                other.waterRateOverride == waterRateOverride) &&
            (identical(
                    other.electricityRateOverride, electricityRateOverride) ||
                other.electricityRateOverride == electricityRateOverride) &&
            const DeepCollectionEquality()
                .equals(other.maintenanceAreas, maintenanceAreas));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        title,
        unitNumber,
        floor,
        location,
        latitude,
        longitude,
        rent,
        monthlyRent,
        status,
        description,
        area,
        areaSqm,
        bedrooms,
        bathrooms,
        const DeepCollectionEquality().hash(amenities),
        const DeepCollectionEquality().hash(inclusions),
        const DeepCollectionEquality().hash(images),
        imageUrl,
        tenantId,
        tenantName,
        currentTenancyId,
        dueDate,
        rentDueDay,
        lateFee,
        vacantDays,
        waterReadingPrev,
        waterReadingCurr,
        electricReadingPrev,
        electricReadingCurr,
        leasePdfTitle,
        isArchived,
        detailsCompleted,
        waterUtilityEnabled,
        electricityUtilityEnabled,
        waterRateOverride,
        electricityRateOverride,
        const DeepCollectionEquality().hash(maintenanceAreas)
      ]);

  @override
  String toString() {
    return 'Unit(id: $id, name: $name, title: $title, unitNumber: $unitNumber, floor: $floor, location: $location, latitude: $latitude, longitude: $longitude, rent: $rent, monthlyRent: $monthlyRent, status: $status, description: $description, area: $area, areaSqm: $areaSqm, bedrooms: $bedrooms, bathrooms: $bathrooms, amenities: $amenities, inclusions: $inclusions, images: $images, imageUrl: $imageUrl, tenantId: $tenantId, tenantName: $tenantName, currentTenancyId: $currentTenancyId, dueDate: $dueDate, rentDueDay: $rentDueDay, lateFee: $lateFee, vacantDays: $vacantDays, waterReadingPrev: $waterReadingPrev, waterReadingCurr: $waterReadingCurr, electricReadingPrev: $electricReadingPrev, electricReadingCurr: $electricReadingCurr, leasePdfTitle: $leasePdfTitle, isArchived: $isArchived, detailsCompleted: $detailsCompleted, waterUtilityEnabled: $waterUtilityEnabled, electricityUtilityEnabled: $electricityUtilityEnabled, waterRateOverride: $waterRateOverride, electricityRateOverride: $electricityRateOverride, maintenanceAreas: $maintenanceAreas)';
  }
}

/// @nodoc
abstract mixin class $UnitCopyWith<$Res> {
  factory $UnitCopyWith(Unit value, $Res Function(Unit) _then) =
      _$UnitCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? title,
      String? unitNumber,
      String floor,
      String location,
      double? latitude,
      double? longitude,
      double rent,
      double monthlyRent,
      String status,
      String description,
      double area,
      double areaSqm,
      int bedrooms,
      int bathrooms,
      List<String> amenities,
      List<String> inclusions,
      List<String> images,
      String? imageUrl,
      String? tenantId,
      String? tenantName,
      String? currentTenancyId,
      DateTime? dueDate,
      int rentDueDay,
      double lateFee,
      int vacantDays,
      double waterReadingPrev,
      double waterReadingCurr,
      double electricReadingPrev,
      double electricReadingCurr,
      String? leasePdfTitle,
      bool isArchived,
      bool detailsCompleted,
      bool waterUtilityEnabled,
      bool electricityUtilityEnabled,
      double? waterRateOverride,
      double? electricityRateOverride,
      List<String> maintenanceAreas});
}

/// @nodoc
class _$UnitCopyWithImpl<$Res> implements $UnitCopyWith<$Res> {
  _$UnitCopyWithImpl(this._self, this._then);

  final Unit _self;
  final $Res Function(Unit) _then;

  /// Create a copy of Unit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? title = freezed,
    Object? unitNumber = freezed,
    Object? floor = null,
    Object? location = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? rent = null,
    Object? monthlyRent = null,
    Object? status = null,
    Object? description = null,
    Object? area = null,
    Object? areaSqm = null,
    Object? bedrooms = null,
    Object? bathrooms = null,
    Object? amenities = null,
    Object? inclusions = null,
    Object? images = null,
    Object? imageUrl = freezed,
    Object? tenantId = freezed,
    Object? tenantName = freezed,
    Object? currentTenancyId = freezed,
    Object? dueDate = freezed,
    Object? rentDueDay = null,
    Object? lateFee = null,
    Object? vacantDays = null,
    Object? waterReadingPrev = null,
    Object? waterReadingCurr = null,
    Object? electricReadingPrev = null,
    Object? electricReadingCurr = null,
    Object? leasePdfTitle = freezed,
    Object? isArchived = null,
    Object? detailsCompleted = null,
    Object? waterUtilityEnabled = null,
    Object? electricityUtilityEnabled = null,
    Object? waterRateOverride = freezed,
    Object? electricityRateOverride = freezed,
    Object? maintenanceAreas = null,
  }) {
    return _then(Unit(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      unitNumber: freezed == unitNumber
          ? _self.unitNumber
          : unitNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      floor: null == floor
          ? _self.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      rent: null == rent
          ? _self.rent
          : rent // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyRent: null == monthlyRent
          ? _self.monthlyRent
          : monthlyRent // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      area: null == area
          ? _self.area
          : area // ignore: cast_nullable_to_non_nullable
              as double,
      areaSqm: null == areaSqm
          ? _self.areaSqm
          : areaSqm // ignore: cast_nullable_to_non_nullable
              as double,
      bedrooms: null == bedrooms
          ? _self.bedrooms
          : bedrooms // ignore: cast_nullable_to_non_nullable
              as int,
      bathrooms: null == bathrooms
          ? _self.bathrooms
          : bathrooms // ignore: cast_nullable_to_non_nullable
              as int,
      amenities: null == amenities
          ? _self.amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      inclusions: null == inclusions
          ? _self.inclusions
          : inclusions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      images: null == images
          ? _self.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tenantId: freezed == tenantId
          ? _self.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String?,
      tenantName: freezed == tenantName
          ? _self.tenantName
          : tenantName // ignore: cast_nullable_to_non_nullable
              as String?,
      currentTenancyId: freezed == currentTenancyId
          ? _self.currentTenancyId
          : currentTenancyId // ignore: cast_nullable_to_non_nullable
              as String?,
      dueDate: freezed == dueDate
          ? _self.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rentDueDay: null == rentDueDay
          ? _self.rentDueDay
          : rentDueDay // ignore: cast_nullable_to_non_nullable
              as int,
      lateFee: null == lateFee
          ? _self.lateFee
          : lateFee // ignore: cast_nullable_to_non_nullable
              as double,
      vacantDays: null == vacantDays
          ? _self.vacantDays
          : vacantDays // ignore: cast_nullable_to_non_nullable
              as int,
      waterReadingPrev: null == waterReadingPrev
          ? _self.waterReadingPrev
          : waterReadingPrev // ignore: cast_nullable_to_non_nullable
              as double,
      waterReadingCurr: null == waterReadingCurr
          ? _self.waterReadingCurr
          : waterReadingCurr // ignore: cast_nullable_to_non_nullable
              as double,
      electricReadingPrev: null == electricReadingPrev
          ? _self.electricReadingPrev
          : electricReadingPrev // ignore: cast_nullable_to_non_nullable
              as double,
      electricReadingCurr: null == electricReadingCurr
          ? _self.electricReadingCurr
          : electricReadingCurr // ignore: cast_nullable_to_non_nullable
              as double,
      leasePdfTitle: freezed == leasePdfTitle
          ? _self.leasePdfTitle
          : leasePdfTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      detailsCompleted: null == detailsCompleted
          ? _self.detailsCompleted
          : detailsCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      waterUtilityEnabled: null == waterUtilityEnabled
          ? _self.waterUtilityEnabled
          : waterUtilityEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      electricityUtilityEnabled: null == electricityUtilityEnabled
          ? _self.electricityUtilityEnabled
          : electricityUtilityEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      waterRateOverride: freezed == waterRateOverride
          ? _self.waterRateOverride
          : waterRateOverride // ignore: cast_nullable_to_non_nullable
              as double?,
      electricityRateOverride: freezed == electricityRateOverride
          ? _self.electricityRateOverride
          : electricityRateOverride // ignore: cast_nullable_to_non_nullable
              as double?,
      maintenanceAreas: null == maintenanceAreas
          ? _self.maintenanceAreas
          : maintenanceAreas // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [Unit].
extension UnitPatterns on Unit {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Unit value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Unit() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Unit value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Unit():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Unit value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Unit() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String? title,
            String? unitNumber,
            String floor,
            String location,
            double? latitude,
            double? longitude,
            double rent,
            double monthlyRent,
            String status,
            String description,
            double area,
            double areaSqm,
            int bedrooms,
            int bathrooms,
            List<String> amenities,
            List<String> inclusions,
            List<String> images,
            String? imageUrl,
            String? tenantId,
            String? tenantName,
            String? currentTenancyId,
            DateTime? dueDate,
            int rentDueDay,
            double lateFee,
            int vacantDays,
            double waterReadingPrev,
            double waterReadingCurr,
            double electricReadingPrev,
            double electricReadingCurr,
            String? leasePdfTitle,
            bool isArchived,
            bool detailsCompleted,
            bool waterUtilityEnabled,
            bool electricityUtilityEnabled,
            double? waterRateOverride,
            double? electricityRateOverride,
            List<String> maintenanceAreas)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Unit() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.title,
            _that.unitNumber,
            _that.floor,
            _that.location,
            _that.latitude,
            _that.longitude,
            _that.rent,
            _that.monthlyRent,
            _that.status,
            _that.description,
            _that.area,
            _that.areaSqm,
            _that.bedrooms,
            _that.bathrooms,
            _that.amenities,
            _that.inclusions,
            _that.images,
            _that.imageUrl,
            _that.tenantId,
            _that.tenantName,
            _that.currentTenancyId,
            _that.dueDate,
            _that.rentDueDay,
            _that.lateFee,
            _that.vacantDays,
            _that.waterReadingPrev,
            _that.waterReadingCurr,
            _that.electricReadingPrev,
            _that.electricReadingCurr,
            _that.leasePdfTitle,
            _that.isArchived,
            _that.detailsCompleted,
            _that.waterUtilityEnabled,
            _that.electricityUtilityEnabled,
            _that.waterRateOverride,
            _that.electricityRateOverride,
            _that.maintenanceAreas);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String? title,
            String? unitNumber,
            String floor,
            String location,
            double? latitude,
            double? longitude,
            double rent,
            double monthlyRent,
            String status,
            String description,
            double area,
            double areaSqm,
            int bedrooms,
            int bathrooms,
            List<String> amenities,
            List<String> inclusions,
            List<String> images,
            String? imageUrl,
            String? tenantId,
            String? tenantName,
            String? currentTenancyId,
            DateTime? dueDate,
            int rentDueDay,
            double lateFee,
            int vacantDays,
            double waterReadingPrev,
            double waterReadingCurr,
            double electricReadingPrev,
            double electricReadingCurr,
            String? leasePdfTitle,
            bool isArchived,
            bool detailsCompleted,
            bool waterUtilityEnabled,
            bool electricityUtilityEnabled,
            double? waterRateOverride,
            double? electricityRateOverride,
            List<String> maintenanceAreas)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Unit():
        return $default(
            _that.id,
            _that.name,
            _that.title,
            _that.unitNumber,
            _that.floor,
            _that.location,
            _that.latitude,
            _that.longitude,
            _that.rent,
            _that.monthlyRent,
            _that.status,
            _that.description,
            _that.area,
            _that.areaSqm,
            _that.bedrooms,
            _that.bathrooms,
            _that.amenities,
            _that.inclusions,
            _that.images,
            _that.imageUrl,
            _that.tenantId,
            _that.tenantName,
            _that.currentTenancyId,
            _that.dueDate,
            _that.rentDueDay,
            _that.lateFee,
            _that.vacantDays,
            _that.waterReadingPrev,
            _that.waterReadingCurr,
            _that.electricReadingPrev,
            _that.electricReadingCurr,
            _that.leasePdfTitle,
            _that.isArchived,
            _that.detailsCompleted,
            _that.waterUtilityEnabled,
            _that.electricityUtilityEnabled,
            _that.waterRateOverride,
            _that.electricityRateOverride,
            _that.maintenanceAreas);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            String? title,
            String? unitNumber,
            String floor,
            String location,
            double? latitude,
            double? longitude,
            double rent,
            double monthlyRent,
            String status,
            String description,
            double area,
            double areaSqm,
            int bedrooms,
            int bathrooms,
            List<String> amenities,
            List<String> inclusions,
            List<String> images,
            String? imageUrl,
            String? tenantId,
            String? tenantName,
            String? currentTenancyId,
            DateTime? dueDate,
            int rentDueDay,
            double lateFee,
            int vacantDays,
            double waterReadingPrev,
            double waterReadingCurr,
            double electricReadingPrev,
            double electricReadingCurr,
            String? leasePdfTitle,
            bool isArchived,
            bool detailsCompleted,
            bool waterUtilityEnabled,
            bool electricityUtilityEnabled,
            double? waterRateOverride,
            double? electricityRateOverride,
            List<String> maintenanceAreas)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Unit() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.title,
            _that.unitNumber,
            _that.floor,
            _that.location,
            _that.latitude,
            _that.longitude,
            _that.rent,
            _that.monthlyRent,
            _that.status,
            _that.description,
            _that.area,
            _that.areaSqm,
            _that.bedrooms,
            _that.bathrooms,
            _that.amenities,
            _that.inclusions,
            _that.images,
            _that.imageUrl,
            _that.tenantId,
            _that.tenantName,
            _that.currentTenancyId,
            _that.dueDate,
            _that.rentDueDay,
            _that.lateFee,
            _that.vacantDays,
            _that.waterReadingPrev,
            _that.waterReadingCurr,
            _that.electricReadingPrev,
            _that.electricReadingCurr,
            _that.leasePdfTitle,
            _that.isArchived,
            _that.detailsCompleted,
            _that.waterUtilityEnabled,
            _that.electricityUtilityEnabled,
            _that.waterRateOverride,
            _that.electricityRateOverride,
            _that.maintenanceAreas);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Unit extends Unit {
  const _Unit(
      {this.id = '',
      this.name = '',
      this.title,
      this.unitNumber,
      this.floor = '1st Floor',
      this.location = 'Main Property',
      this.latitude,
      this.longitude,
      this.rent = 8500.0,
      this.monthlyRent = 8500.0,
      this.status = 'Vacant',
      this.description = '',
      this.area = 28.0,
      this.areaSqm = 28.0,
      this.bedrooms = 1,
      this.bathrooms = 1,
      List<String> amenities = const [],
      List<String> inclusions = const ['Water', 'Electricity', 'Wifi'],
      List<String> images = const [],
      this.imageUrl,
      this.tenantId,
      this.tenantName,
      this.currentTenancyId,
      this.dueDate,
      this.rentDueDay = 5,
      this.lateFee = 500.0,
      this.vacantDays = 0,
      this.waterReadingPrev = 120.5,
      this.waterReadingCurr = 135.2,
      this.electricReadingPrev = 1450.0,
      this.electricReadingCurr = 1620.0,
      this.leasePdfTitle,
      this.isArchived = false,
      this.detailsCompleted = true,
      this.waterUtilityEnabled = true,
      this.electricityUtilityEnabled = true,
      this.waterRateOverride,
      this.electricityRateOverride,
      List<String> maintenanceAreas = const [
        'Bathroom',
        'Bedroom',
        'Indoor Area',
        'Outdoor Area'
      ]})
      : _amenities = amenities,
        _inclusions = inclusions,
        _images = images,
        _maintenanceAreas = maintenanceAreas,
        super._();
  factory _Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String name;
  @override
  final String? title;
  @override
  final String? unitNumber;
  @override
  @JsonKey()
  final String floor;
  @override
  @JsonKey()
  final String location;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey()
  final double rent;
  @override
  @JsonKey()
  final double monthlyRent;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final double area;
  @override
  @JsonKey()
  final double areaSqm;
  @override
  @JsonKey()
  final int bedrooms;
  @override
  @JsonKey()
  final int bathrooms;
  final List<String> _amenities;
  @override
  @JsonKey()
  List<String> get amenities {
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amenities);
  }

  final List<String> _inclusions;
  @override
  @JsonKey()
  List<String> get inclusions {
    if (_inclusions is EqualUnmodifiableListView) return _inclusions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inclusions);
  }

  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  final String? imageUrl;
  @override
  final String? tenantId;
  @override
  final String? tenantName;
  @override
  final String? currentTenancyId;
  @override
  final DateTime? dueDate;
  @override
  @JsonKey()
  final int rentDueDay;
  @override
  @JsonKey()
  final double lateFee;
  @override
  @JsonKey()
  final int vacantDays;
  @override
  @JsonKey()
  final double waterReadingPrev;
  @override
  @JsonKey()
  final double waterReadingCurr;
  @override
  @JsonKey()
  final double electricReadingPrev;
  @override
  @JsonKey()
  final double electricReadingCurr;
  @override
  final String? leasePdfTitle;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  @JsonKey()
  final bool detailsCompleted;
  @override
  @JsonKey()
  final bool waterUtilityEnabled;
  @override
  @JsonKey()
  final bool electricityUtilityEnabled;
  @override
  final double? waterRateOverride;
  @override
  final double? electricityRateOverride;
  final List<String> _maintenanceAreas;
  @override
  @JsonKey()
  List<String> get maintenanceAreas {
    if (_maintenanceAreas is EqualUnmodifiableListView)
      return _maintenanceAreas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_maintenanceAreas);
  }

  /// Create a copy of Unit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UnitCopyWith<_Unit> get copyWith =>
      __$UnitCopyWithImpl<_Unit>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UnitToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Unit &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.unitNumber, unitNumber) ||
                other.unitNumber == unitNumber) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.rent, rent) || other.rent == rent) &&
            (identical(other.monthlyRent, monthlyRent) ||
                other.monthlyRent == monthlyRent) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.areaSqm, areaSqm) || other.areaSqm == areaSqm) &&
            (identical(other.bedrooms, bedrooms) ||
                other.bedrooms == bedrooms) &&
            (identical(other.bathrooms, bathrooms) ||
                other.bathrooms == bathrooms) &&
            const DeepCollectionEquality()
                .equals(other._amenities, _amenities) &&
            const DeepCollectionEquality()
                .equals(other._inclusions, _inclusions) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.tenantName, tenantName) ||
                other.tenantName == tenantName) &&
            (identical(other.currentTenancyId, currentTenancyId) ||
                other.currentTenancyId == currentTenancyId) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.rentDueDay, rentDueDay) ||
                other.rentDueDay == rentDueDay) &&
            (identical(other.lateFee, lateFee) || other.lateFee == lateFee) &&
            (identical(other.vacantDays, vacantDays) ||
                other.vacantDays == vacantDays) &&
            (identical(other.waterReadingPrev, waterReadingPrev) ||
                other.waterReadingPrev == waterReadingPrev) &&
            (identical(other.waterReadingCurr, waterReadingCurr) ||
                other.waterReadingCurr == waterReadingCurr) &&
            (identical(other.electricReadingPrev, electricReadingPrev) ||
                other.electricReadingPrev == electricReadingPrev) &&
            (identical(other.electricReadingCurr, electricReadingCurr) ||
                other.electricReadingCurr == electricReadingCurr) &&
            (identical(other.leasePdfTitle, leasePdfTitle) ||
                other.leasePdfTitle == leasePdfTitle) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.detailsCompleted, detailsCompleted) ||
                other.detailsCompleted == detailsCompleted) &&
            (identical(other.waterUtilityEnabled, waterUtilityEnabled) ||
                other.waterUtilityEnabled == waterUtilityEnabled) &&
            (identical(other.electricityUtilityEnabled,
                    electricityUtilityEnabled) ||
                other.electricityUtilityEnabled == electricityUtilityEnabled) &&
            (identical(other.waterRateOverride, waterRateOverride) ||
                other.waterRateOverride == waterRateOverride) &&
            (identical(
                    other.electricityRateOverride, electricityRateOverride) ||
                other.electricityRateOverride == electricityRateOverride) &&
            const DeepCollectionEquality()
                .equals(other._maintenanceAreas, _maintenanceAreas));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        title,
        unitNumber,
        floor,
        location,
        latitude,
        longitude,
        rent,
        monthlyRent,
        status,
        description,
        area,
        areaSqm,
        bedrooms,
        bathrooms,
        const DeepCollectionEquality().hash(_amenities),
        const DeepCollectionEquality().hash(_inclusions),
        const DeepCollectionEquality().hash(_images),
        imageUrl,
        tenantId,
        tenantName,
        currentTenancyId,
        dueDate,
        rentDueDay,
        lateFee,
        vacantDays,
        waterReadingPrev,
        waterReadingCurr,
        electricReadingPrev,
        electricReadingCurr,
        leasePdfTitle,
        isArchived,
        detailsCompleted,
        waterUtilityEnabled,
        electricityUtilityEnabled,
        waterRateOverride,
        electricityRateOverride,
        const DeepCollectionEquality().hash(_maintenanceAreas)
      ]);

  @override
  String toString() {
    return 'Unit(id: $id, name: $name, title: $title, unitNumber: $unitNumber, floor: $floor, location: $location, latitude: $latitude, longitude: $longitude, rent: $rent, monthlyRent: $monthlyRent, status: $status, description: $description, area: $area, areaSqm: $areaSqm, bedrooms: $bedrooms, bathrooms: $bathrooms, amenities: $amenities, inclusions: $inclusions, images: $images, imageUrl: $imageUrl, tenantId: $tenantId, tenantName: $tenantName, currentTenancyId: $currentTenancyId, dueDate: $dueDate, rentDueDay: $rentDueDay, lateFee: $lateFee, vacantDays: $vacantDays, waterReadingPrev: $waterReadingPrev, waterReadingCurr: $waterReadingCurr, electricReadingPrev: $electricReadingPrev, electricReadingCurr: $electricReadingCurr, leasePdfTitle: $leasePdfTitle, isArchived: $isArchived, detailsCompleted: $detailsCompleted, waterUtilityEnabled: $waterUtilityEnabled, electricityUtilityEnabled: $electricityUtilityEnabled, waterRateOverride: $waterRateOverride, electricityRateOverride: $electricityRateOverride, maintenanceAreas: $maintenanceAreas)';
  }
}

/// @nodoc
abstract mixin class _$UnitCopyWith<$Res> implements $UnitCopyWith<$Res> {
  factory _$UnitCopyWith(_Unit value, $Res Function(_Unit) _then) =
      __$UnitCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? title,
      String? unitNumber,
      String floor,
      String location,
      double? latitude,
      double? longitude,
      double rent,
      double monthlyRent,
      String status,
      String description,
      double area,
      double areaSqm,
      int bedrooms,
      int bathrooms,
      List<String> amenities,
      List<String> inclusions,
      List<String> images,
      String? imageUrl,
      String? tenantId,
      String? tenantName,
      String? currentTenancyId,
      DateTime? dueDate,
      int rentDueDay,
      double lateFee,
      int vacantDays,
      double waterReadingPrev,
      double waterReadingCurr,
      double electricReadingPrev,
      double electricReadingCurr,
      String? leasePdfTitle,
      bool isArchived,
      bool detailsCompleted,
      bool waterUtilityEnabled,
      bool electricityUtilityEnabled,
      double? waterRateOverride,
      double? electricityRateOverride,
      List<String> maintenanceAreas});
}

/// @nodoc
class __$UnitCopyWithImpl<$Res> implements _$UnitCopyWith<$Res> {
  __$UnitCopyWithImpl(this._self, this._then);

  final _Unit _self;
  final $Res Function(_Unit) _then;

  /// Create a copy of Unit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? title = freezed,
    Object? unitNumber = freezed,
    Object? floor = null,
    Object? location = null,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? rent = null,
    Object? monthlyRent = null,
    Object? status = null,
    Object? description = null,
    Object? area = null,
    Object? areaSqm = null,
    Object? bedrooms = null,
    Object? bathrooms = null,
    Object? amenities = null,
    Object? inclusions = null,
    Object? images = null,
    Object? imageUrl = freezed,
    Object? tenantId = freezed,
    Object? tenantName = freezed,
    Object? currentTenancyId = freezed,
    Object? dueDate = freezed,
    Object? rentDueDay = null,
    Object? lateFee = null,
    Object? vacantDays = null,
    Object? waterReadingPrev = null,
    Object? waterReadingCurr = null,
    Object? electricReadingPrev = null,
    Object? electricReadingCurr = null,
    Object? leasePdfTitle = freezed,
    Object? isArchived = null,
    Object? detailsCompleted = null,
    Object? waterUtilityEnabled = null,
    Object? electricityUtilityEnabled = null,
    Object? waterRateOverride = freezed,
    Object? electricityRateOverride = freezed,
    Object? maintenanceAreas = null,
  }) {
    return _then(_Unit(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      unitNumber: freezed == unitNumber
          ? _self.unitNumber
          : unitNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      floor: null == floor
          ? _self.floor
          : floor // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      rent: null == rent
          ? _self.rent
          : rent // ignore: cast_nullable_to_non_nullable
              as double,
      monthlyRent: null == monthlyRent
          ? _self.monthlyRent
          : monthlyRent // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      area: null == area
          ? _self.area
          : area // ignore: cast_nullable_to_non_nullable
              as double,
      areaSqm: null == areaSqm
          ? _self.areaSqm
          : areaSqm // ignore: cast_nullable_to_non_nullable
              as double,
      bedrooms: null == bedrooms
          ? _self.bedrooms
          : bedrooms // ignore: cast_nullable_to_non_nullable
              as int,
      bathrooms: null == bathrooms
          ? _self.bathrooms
          : bathrooms // ignore: cast_nullable_to_non_nullable
              as int,
      amenities: null == amenities
          ? _self._amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      inclusions: null == inclusions
          ? _self._inclusions
          : inclusions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      images: null == images
          ? _self._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tenantId: freezed == tenantId
          ? _self.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String?,
      tenantName: freezed == tenantName
          ? _self.tenantName
          : tenantName // ignore: cast_nullable_to_non_nullable
              as String?,
      currentTenancyId: freezed == currentTenancyId
          ? _self.currentTenancyId
          : currentTenancyId // ignore: cast_nullable_to_non_nullable
              as String?,
      dueDate: freezed == dueDate
          ? _self.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rentDueDay: null == rentDueDay
          ? _self.rentDueDay
          : rentDueDay // ignore: cast_nullable_to_non_nullable
              as int,
      lateFee: null == lateFee
          ? _self.lateFee
          : lateFee // ignore: cast_nullable_to_non_nullable
              as double,
      vacantDays: null == vacantDays
          ? _self.vacantDays
          : vacantDays // ignore: cast_nullable_to_non_nullable
              as int,
      waterReadingPrev: null == waterReadingPrev
          ? _self.waterReadingPrev
          : waterReadingPrev // ignore: cast_nullable_to_non_nullable
              as double,
      waterReadingCurr: null == waterReadingCurr
          ? _self.waterReadingCurr
          : waterReadingCurr // ignore: cast_nullable_to_non_nullable
              as double,
      electricReadingPrev: null == electricReadingPrev
          ? _self.electricReadingPrev
          : electricReadingPrev // ignore: cast_nullable_to_non_nullable
              as double,
      electricReadingCurr: null == electricReadingCurr
          ? _self.electricReadingCurr
          : electricReadingCurr // ignore: cast_nullable_to_non_nullable
              as double,
      leasePdfTitle: freezed == leasePdfTitle
          ? _self.leasePdfTitle
          : leasePdfTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      detailsCompleted: null == detailsCompleted
          ? _self.detailsCompleted
          : detailsCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      waterUtilityEnabled: null == waterUtilityEnabled
          ? _self.waterUtilityEnabled
          : waterUtilityEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      electricityUtilityEnabled: null == electricityUtilityEnabled
          ? _self.electricityUtilityEnabled
          : electricityUtilityEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      waterRateOverride: freezed == waterRateOverride
          ? _self.waterRateOverride
          : waterRateOverride // ignore: cast_nullable_to_non_nullable
              as double?,
      electricityRateOverride: freezed == electricityRateOverride
          ? _self.electricityRateOverride
          : electricityRateOverride // ignore: cast_nullable_to_non_nullable
              as double?,
      maintenanceAreas: null == maintenanceAreas
          ? _self._maintenanceAreas
          : maintenanceAreas // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
