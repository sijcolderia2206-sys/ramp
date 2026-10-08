// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'billing_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BillingInvoice {
  String get id;
  String get tenantId;
  String get unitId;
  double get baseRent;
  double get waterUsage; // in cu.m
  double get electricUsage; // in kWh
  double get lateFees;
  DateTime get dueDate;
  InvoiceStatus get status;
  DateTime? get paidAt;

  /// Create a copy of BillingInvoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BillingInvoiceCopyWith<BillingInvoice> get copyWith =>
      _$BillingInvoiceCopyWithImpl<BillingInvoice>(
          this as BillingInvoice, _$identity);

  /// Serializes this BillingInvoice to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BillingInvoice &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.baseRent, baseRent) ||
                other.baseRent == baseRent) &&
            (identical(other.waterUsage, waterUsage) ||
                other.waterUsage == waterUsage) &&
            (identical(other.electricUsage, electricUsage) ||
                other.electricUsage == electricUsage) &&
            (identical(other.lateFees, lateFees) ||
                other.lateFees == lateFees) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, tenantId, unitId, baseRent,
      waterUsage, electricUsage, lateFees, dueDate, status, paidAt);

  @override
  String toString() {
    return 'BillingInvoice(id: $id, tenantId: $tenantId, unitId: $unitId, baseRent: $baseRent, waterUsage: $waterUsage, electricUsage: $electricUsage, lateFees: $lateFees, dueDate: $dueDate, status: $status, paidAt: $paidAt)';
  }
}

/// @nodoc
abstract mixin class $BillingInvoiceCopyWith<$Res> {
  factory $BillingInvoiceCopyWith(
          BillingInvoice value, $Res Function(BillingInvoice) _then) =
      _$BillingInvoiceCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String unitId,
      double baseRent,
      double waterUsage,
      double electricUsage,
      double lateFees,
      DateTime dueDate,
      InvoiceStatus status,
      DateTime? paidAt});
}

/// @nodoc
class _$BillingInvoiceCopyWithImpl<$Res>
    implements $BillingInvoiceCopyWith<$Res> {
  _$BillingInvoiceCopyWithImpl(this._self, this._then);

  final BillingInvoice _self;
  final $Res Function(BillingInvoice) _then;

  /// Create a copy of BillingInvoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? unitId = null,
    Object? baseRent = null,
    Object? waterUsage = null,
    Object? electricUsage = null,
    Object? lateFees = null,
    Object? dueDate = null,
    Object? status = null,
    Object? paidAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _self.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _self.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      baseRent: null == baseRent
          ? _self.baseRent
          : baseRent // ignore: cast_nullable_to_non_nullable
              as double,
      waterUsage: null == waterUsage
          ? _self.waterUsage
          : waterUsage // ignore: cast_nullable_to_non_nullable
              as double,
      electricUsage: null == electricUsage
          ? _self.electricUsage
          : electricUsage // ignore: cast_nullable_to_non_nullable
              as double,
      lateFees: null == lateFees
          ? _self.lateFees
          : lateFees // ignore: cast_nullable_to_non_nullable
              as double,
      dueDate: null == dueDate
          ? _self.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as InvoiceStatus,
      paidAt: freezed == paidAt
          ? _self.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [BillingInvoice].
extension BillingInvoicePatterns on BillingInvoice {
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
    TResult Function(_BillingInvoice value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BillingInvoice() when $default != null:
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
    TResult Function(_BillingInvoice value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BillingInvoice():
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
    TResult? Function(_BillingInvoice value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BillingInvoice() when $default != null:
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
            String tenantId,
            String unitId,
            double baseRent,
            double waterUsage,
            double electricUsage,
            double lateFees,
            DateTime dueDate,
            InvoiceStatus status,
            DateTime? paidAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BillingInvoice() when $default != null:
        return $default(
            _that.id,
            _that.tenantId,
            _that.unitId,
            _that.baseRent,
            _that.waterUsage,
            _that.electricUsage,
            _that.lateFees,
            _that.dueDate,
            _that.status,
            _that.paidAt);
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
            String tenantId,
            String unitId,
            double baseRent,
            double waterUsage,
            double electricUsage,
            double lateFees,
            DateTime dueDate,
            InvoiceStatus status,
            DateTime? paidAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BillingInvoice():
        return $default(
            _that.id,
            _that.tenantId,
            _that.unitId,
            _that.baseRent,
            _that.waterUsage,
            _that.electricUsage,
            _that.lateFees,
            _that.dueDate,
            _that.status,
            _that.paidAt);
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
            String tenantId,
            String unitId,
            double baseRent,
            double waterUsage,
            double electricUsage,
            double lateFees,
            DateTime dueDate,
            InvoiceStatus status,
            DateTime? paidAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BillingInvoice() when $default != null:
        return $default(
            _that.id,
            _that.tenantId,
            _that.unitId,
            _that.baseRent,
            _that.waterUsage,
            _that.electricUsage,
            _that.lateFees,
            _that.dueDate,
            _that.status,
            _that.paidAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _BillingInvoice extends BillingInvoice {
  const _BillingInvoice(
      {required this.id,
      required this.tenantId,
      required this.unitId,
      required this.baseRent,
      required this.waterUsage,
      required this.electricUsage,
      this.lateFees = 0.0,
      required this.dueDate,
      this.status = InvoiceStatus.pending,
      this.paidAt})
      : super._();
  factory _BillingInvoice.fromJson(Map<String, dynamic> json) =>
      _$BillingInvoiceFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String unitId;
  @override
  final double baseRent;
  @override
  final double waterUsage;
// in cu.m
  @override
  final double electricUsage;
// in kWh
  @override
  @JsonKey()
  final double lateFees;
  @override
  final DateTime dueDate;
  @override
  @JsonKey()
  final InvoiceStatus status;
  @override
  final DateTime? paidAt;

  /// Create a copy of BillingInvoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BillingInvoiceCopyWith<_BillingInvoice> get copyWith =>
      __$BillingInvoiceCopyWithImpl<_BillingInvoice>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BillingInvoiceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BillingInvoice &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.baseRent, baseRent) ||
                other.baseRent == baseRent) &&
            (identical(other.waterUsage, waterUsage) ||
                other.waterUsage == waterUsage) &&
            (identical(other.electricUsage, electricUsage) ||
                other.electricUsage == electricUsage) &&
            (identical(other.lateFees, lateFees) ||
                other.lateFees == lateFees) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, tenantId, unitId, baseRent,
      waterUsage, electricUsage, lateFees, dueDate, status, paidAt);

  @override
  String toString() {
    return 'BillingInvoice(id: $id, tenantId: $tenantId, unitId: $unitId, baseRent: $baseRent, waterUsage: $waterUsage, electricUsage: $electricUsage, lateFees: $lateFees, dueDate: $dueDate, status: $status, paidAt: $paidAt)';
  }
}

/// @nodoc
abstract mixin class _$BillingInvoiceCopyWith<$Res>
    implements $BillingInvoiceCopyWith<$Res> {
  factory _$BillingInvoiceCopyWith(
          _BillingInvoice value, $Res Function(_BillingInvoice) _then) =
      __$BillingInvoiceCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String unitId,
      double baseRent,
      double waterUsage,
      double electricUsage,
      double lateFees,
      DateTime dueDate,
      InvoiceStatus status,
      DateTime? paidAt});
}

/// @nodoc
class __$BillingInvoiceCopyWithImpl<$Res>
    implements _$BillingInvoiceCopyWith<$Res> {
  __$BillingInvoiceCopyWithImpl(this._self, this._then);

  final _BillingInvoice _self;
  final $Res Function(_BillingInvoice) _then;

  /// Create a copy of BillingInvoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? unitId = null,
    Object? baseRent = null,
    Object? waterUsage = null,
    Object? electricUsage = null,
    Object? lateFees = null,
    Object? dueDate = null,
    Object? status = null,
    Object? paidAt = freezed,
  }) {
    return _then(_BillingInvoice(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _self.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _self.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      baseRent: null == baseRent
          ? _self.baseRent
          : baseRent // ignore: cast_nullable_to_non_nullable
              as double,
      waterUsage: null == waterUsage
          ? _self.waterUsage
          : waterUsage // ignore: cast_nullable_to_non_nullable
              as double,
      electricUsage: null == electricUsage
          ? _self.electricUsage
          : electricUsage // ignore: cast_nullable_to_non_nullable
              as double,
      lateFees: null == lateFees
          ? _self.lateFees
          : lateFees // ignore: cast_nullable_to_non_nullable
              as double,
      dueDate: null == dueDate
          ? _self.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as InvoiceStatus,
      paidAt: freezed == paidAt
          ? _self.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
