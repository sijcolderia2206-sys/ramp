// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'property_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PropertyModel {
  String get id;
  String get landlordId;
  String get name;
  String get address;
  List<String> get unitIds;

  /// Create a copy of PropertyModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PropertyModelCopyWith<PropertyModel> get copyWith =>
      _$PropertyModelCopyWithImpl<PropertyModel>(
          this as PropertyModel, _$identity);

  /// Serializes this PropertyModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PropertyModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.landlordId, landlordId) ||
                other.landlordId == landlordId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            const DeepCollectionEquality().equals(other.unitIds, unitIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, landlordId, name, address,
      const DeepCollectionEquality().hash(unitIds));

  @override
  String toString() {
    return 'PropertyModel(id: $id, landlordId: $landlordId, name: $name, address: $address, unitIds: $unitIds)';
  }
}

/// @nodoc
abstract mixin class $PropertyModelCopyWith<$Res> {
  factory $PropertyModelCopyWith(
          PropertyModel value, $Res Function(PropertyModel) _then) =
      _$PropertyModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String landlordId,
      String name,
      String address,
      List<String> unitIds});
}

/// @nodoc
class _$PropertyModelCopyWithImpl<$Res>
    implements $PropertyModelCopyWith<$Res> {
  _$PropertyModelCopyWithImpl(this._self, this._then);

  final PropertyModel _self;
  final $Res Function(PropertyModel) _then;

  /// Create a copy of PropertyModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? landlordId = null,
    Object? name = null,
    Object? address = null,
    Object? unitIds = null,
  }) {
    return _then(PropertyModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      landlordId: null == landlordId
          ? _self.landlordId
          : landlordId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      unitIds: null == unitIds
          ? _self.unitIds
          : unitIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [PropertyModel].
extension PropertyModelPatterns on PropertyModel {
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
    TResult Function(_PropertyModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PropertyModel() when $default != null:
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
    TResult Function(_PropertyModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PropertyModel():
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
    TResult? Function(_PropertyModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PropertyModel() when $default != null:
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
    TResult Function(String id, String landlordId, String name, String address,
            List<String> unitIds)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PropertyModel() when $default != null:
        return $default(_that.id, _that.landlordId, _that.name, _that.address,
            _that.unitIds);
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
    TResult Function(String id, String landlordId, String name, String address,
            List<String> unitIds)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PropertyModel():
        return $default(_that.id, _that.landlordId, _that.name, _that.address,
            _that.unitIds);
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
    TResult? Function(String id, String landlordId, String name, String address,
            List<String> unitIds)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PropertyModel() when $default != null:
        return $default(_that.id, _that.landlordId, _that.name, _that.address,
            _that.unitIds);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PropertyModel implements PropertyModel {
  const _PropertyModel(
      {required this.id,
      required this.landlordId,
      required this.name,
      required this.address,
      List<String> unitIds = const []})
      : _unitIds = unitIds;
  factory _PropertyModel.fromJson(Map<String, dynamic> json) =>
      _$PropertyModelFromJson(json);

  @override
  final String id;
  @override
  final String landlordId;
  @override
  final String name;
  @override
  final String address;
  final List<String> _unitIds;
  @override
  @JsonKey()
  List<String> get unitIds {
    if (_unitIds is EqualUnmodifiableListView) return _unitIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unitIds);
  }

  /// Create a copy of PropertyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PropertyModelCopyWith<_PropertyModel> get copyWith =>
      __$PropertyModelCopyWithImpl<_PropertyModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PropertyModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PropertyModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.landlordId, landlordId) ||
                other.landlordId == landlordId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            const DeepCollectionEquality().equals(other._unitIds, _unitIds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, landlordId, name, address,
      const DeepCollectionEquality().hash(_unitIds));

  @override
  String toString() {
    return 'PropertyModel(id: $id, landlordId: $landlordId, name: $name, address: $address, unitIds: $unitIds)';
  }
}

/// @nodoc
abstract mixin class _$PropertyModelCopyWith<$Res>
    implements $PropertyModelCopyWith<$Res> {
  factory _$PropertyModelCopyWith(
          _PropertyModel value, $Res Function(_PropertyModel) _then) =
      __$PropertyModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String landlordId,
      String name,
      String address,
      List<String> unitIds});
}

/// @nodoc
class __$PropertyModelCopyWithImpl<$Res>
    implements _$PropertyModelCopyWith<$Res> {
  __$PropertyModelCopyWithImpl(this._self, this._then);

  final _PropertyModel _self;
  final $Res Function(_PropertyModel) _then;

  /// Create a copy of PropertyModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? landlordId = null,
    Object? name = null,
    Object? address = null,
    Object? unitIds = null,
  }) {
    return _then(_PropertyModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      landlordId: null == landlordId
          ? _self.landlordId
          : landlordId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      unitIds: null == unitIds
          ? _self._unitIds
          : unitIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
mixin _$UnitModel {
  String get id;
  String get propertyId;
  String get unitNumber;
  double get baseRent;
  String? get currentTenantId;
  bool get isOccupied;

  /// Create a copy of UnitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UnitModelCopyWith<UnitModel> get copyWith =>
      _$UnitModelCopyWithImpl<UnitModel>(this as UnitModel, _$identity);

  /// Serializes this UnitModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UnitModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.unitNumber, unitNumber) ||
                other.unitNumber == unitNumber) &&
            (identical(other.baseRent, baseRent) ||
                other.baseRent == baseRent) &&
            (identical(other.currentTenantId, currentTenantId) ||
                other.currentTenantId == currentTenantId) &&
            (identical(other.isOccupied, isOccupied) ||
                other.isOccupied == isOccupied));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, propertyId, unitNumber,
      baseRent, currentTenantId, isOccupied);

  @override
  String toString() {
    return 'UnitModel(id: $id, propertyId: $propertyId, unitNumber: $unitNumber, baseRent: $baseRent, currentTenantId: $currentTenantId, isOccupied: $isOccupied)';
  }
}

/// @nodoc
abstract mixin class $UnitModelCopyWith<$Res> {
  factory $UnitModelCopyWith(UnitModel value, $Res Function(UnitModel) _then) =
      _$UnitModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String propertyId,
      String unitNumber,
      double baseRent,
      String? currentTenantId,
      bool isOccupied});
}

/// @nodoc
class _$UnitModelCopyWithImpl<$Res> implements $UnitModelCopyWith<$Res> {
  _$UnitModelCopyWithImpl(this._self, this._then);

  final UnitModel _self;
  final $Res Function(UnitModel) _then;

  /// Create a copy of UnitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? propertyId = null,
    Object? unitNumber = null,
    Object? baseRent = null,
    Object? currentTenantId = freezed,
    Object? isOccupied = null,
  }) {
    return _then(UnitModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      propertyId: null == propertyId
          ? _self.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as String,
      unitNumber: null == unitNumber
          ? _self.unitNumber
          : unitNumber // ignore: cast_nullable_to_non_nullable
              as String,
      baseRent: null == baseRent
          ? _self.baseRent
          : baseRent // ignore: cast_nullable_to_non_nullable
              as double,
      currentTenantId: freezed == currentTenantId
          ? _self.currentTenantId
          : currentTenantId // ignore: cast_nullable_to_non_nullable
              as String?,
      isOccupied: null == isOccupied
          ? _self.isOccupied
          : isOccupied // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [UnitModel].
extension UnitModelPatterns on UnitModel {
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
    TResult Function(_UnitModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UnitModel() when $default != null:
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
    TResult Function(_UnitModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UnitModel():
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
    TResult? Function(_UnitModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UnitModel() when $default != null:
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
    TResult Function(String id, String propertyId, String unitNumber,
            double baseRent, String? currentTenantId, bool isOccupied)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UnitModel() when $default != null:
        return $default(_that.id, _that.propertyId, _that.unitNumber,
            _that.baseRent, _that.currentTenantId, _that.isOccupied);
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
    TResult Function(String id, String propertyId, String unitNumber,
            double baseRent, String? currentTenantId, bool isOccupied)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UnitModel():
        return $default(_that.id, _that.propertyId, _that.unitNumber,
            _that.baseRent, _that.currentTenantId, _that.isOccupied);
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
    TResult? Function(String id, String propertyId, String unitNumber,
            double baseRent, String? currentTenantId, bool isOccupied)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UnitModel() when $default != null:
        return $default(_that.id, _that.propertyId, _that.unitNumber,
            _that.baseRent, _that.currentTenantId, _that.isOccupied);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _UnitModel implements UnitModel {
  const _UnitModel(
      {required this.id,
      required this.propertyId,
      required this.unitNumber,
      required this.baseRent,
      this.currentTenantId,
      this.isOccupied = false});
  factory _UnitModel.fromJson(Map<String, dynamic> json) =>
      _$UnitModelFromJson(json);

  @override
  final String id;
  @override
  final String propertyId;
  @override
  final String unitNumber;
  @override
  final double baseRent;
  @override
  final String? currentTenantId;
  @override
  @JsonKey()
  final bool isOccupied;

  /// Create a copy of UnitModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UnitModelCopyWith<_UnitModel> get copyWith =>
      __$UnitModelCopyWithImpl<_UnitModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UnitModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UnitModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.propertyId, propertyId) ||
                other.propertyId == propertyId) &&
            (identical(other.unitNumber, unitNumber) ||
                other.unitNumber == unitNumber) &&
            (identical(other.baseRent, baseRent) ||
                other.baseRent == baseRent) &&
            (identical(other.currentTenantId, currentTenantId) ||
                other.currentTenantId == currentTenantId) &&
            (identical(other.isOccupied, isOccupied) ||
                other.isOccupied == isOccupied));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, propertyId, unitNumber,
      baseRent, currentTenantId, isOccupied);

  @override
  String toString() {
    return 'UnitModel(id: $id, propertyId: $propertyId, unitNumber: $unitNumber, baseRent: $baseRent, currentTenantId: $currentTenantId, isOccupied: $isOccupied)';
  }
}

/// @nodoc
abstract mixin class _$UnitModelCopyWith<$Res>
    implements $UnitModelCopyWith<$Res> {
  factory _$UnitModelCopyWith(
          _UnitModel value, $Res Function(_UnitModel) _then) =
      __$UnitModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String propertyId,
      String unitNumber,
      double baseRent,
      String? currentTenantId,
      bool isOccupied});
}

/// @nodoc
class __$UnitModelCopyWithImpl<$Res> implements _$UnitModelCopyWith<$Res> {
  __$UnitModelCopyWithImpl(this._self, this._then);

  final _UnitModel _self;
  final $Res Function(_UnitModel) _then;

  /// Create a copy of UnitModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? propertyId = null,
    Object? unitNumber = null,
    Object? baseRent = null,
    Object? currentTenantId = freezed,
    Object? isOccupied = null,
  }) {
    return _then(_UnitModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      propertyId: null == propertyId
          ? _self.propertyId
          : propertyId // ignore: cast_nullable_to_non_nullable
              as String,
      unitNumber: null == unitNumber
          ? _self.unitNumber
          : unitNumber // ignore: cast_nullable_to_non_nullable
              as String,
      baseRent: null == baseRent
          ? _self.baseRent
          : baseRent // ignore: cast_nullable_to_non_nullable
              as double,
      currentTenantId: freezed == currentTenantId
          ? _self.currentTenantId
          : currentTenantId // ignore: cast_nullable_to_non_nullable
              as String?,
      isOccupied: null == isOccupied
          ? _self.isOccupied
          : isOccupied // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
