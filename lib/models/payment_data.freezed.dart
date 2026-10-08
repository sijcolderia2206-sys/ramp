// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentData {
  String get id;
  String get month;
  double get amount;
  String get method;
  String get paymentMethod;
  DateTime? get date;
  DateTime? get paymentDate;
  String get status;
  String get unitId;
  String get referenceNumber;
  double get baseRent;
  double get waterBill;
  double get electricBill;
  double get lateFee;
  double get otherCharge;
  String get tenantName;
  String get unitNumber;
  String get tenantId;
  String? get tenancyId;
  String get proofImageUrl;
  String? get remarks;
  String? get declineReason;
  String get transactionType;
  String? get ticketId;

  /// Create a copy of PaymentData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PaymentDataCopyWith<PaymentData> get copyWith =>
      _$PaymentDataCopyWithImpl<PaymentData>(this as PaymentData, _$identity);

  /// Serializes this PaymentData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PaymentData &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.baseRent, baseRent) ||
                other.baseRent == baseRent) &&
            (identical(other.waterBill, waterBill) ||
                other.waterBill == waterBill) &&
            (identical(other.electricBill, electricBill) ||
                other.electricBill == electricBill) &&
            (identical(other.lateFee, lateFee) || other.lateFee == lateFee) &&
            (identical(other.otherCharge, otherCharge) ||
                other.otherCharge == otherCharge) &&
            (identical(other.tenantName, tenantName) ||
                other.tenantName == tenantName) &&
            (identical(other.unitNumber, unitNumber) ||
                other.unitNumber == unitNumber) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.tenancyId, tenancyId) ||
                other.tenancyId == tenancyId) &&
            (identical(other.proofImageUrl, proofImageUrl) ||
                other.proofImageUrl == proofImageUrl) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.declineReason, declineReason) ||
                other.declineReason == declineReason) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.ticketId, ticketId) ||
                other.ticketId == ticketId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        month,
        amount,
        method,
        paymentMethod,
        date,
        paymentDate,
        status,
        unitId,
        referenceNumber,
        baseRent,
        waterBill,
        electricBill,
        lateFee,
        otherCharge,
        tenantName,
        unitNumber,
        tenantId,
        tenancyId,
        proofImageUrl,
        remarks,
        declineReason,
        transactionType,
        ticketId
      ]);

  @override
  String toString() {
    return 'PaymentData(id: $id, month: $month, amount: $amount, method: $method, paymentMethod: $paymentMethod, date: $date, paymentDate: $paymentDate, status: $status, unitId: $unitId, referenceNumber: $referenceNumber, baseRent: $baseRent, waterBill: $waterBill, electricBill: $electricBill, lateFee: $lateFee, otherCharge: $otherCharge, tenantName: $tenantName, unitNumber: $unitNumber, tenantId: $tenantId, tenancyId: $tenancyId, proofImageUrl: $proofImageUrl, remarks: $remarks, declineReason: $declineReason, transactionType: $transactionType, ticketId: $ticketId)';
  }
}

/// @nodoc
abstract mixin class $PaymentDataCopyWith<$Res> {
  factory $PaymentDataCopyWith(
          PaymentData value, $Res Function(PaymentData) _then) =
      _$PaymentDataCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String month,
      double amount,
      String method,
      String paymentMethod,
      DateTime? date,
      DateTime? paymentDate,
      String status,
      String unitId,
      String referenceNumber,
      double baseRent,
      double waterBill,
      double electricBill,
      double lateFee,
      double otherCharge,
      String tenantName,
      String unitNumber,
      String tenantId,
      String? tenancyId,
      String proofImageUrl,
      String? remarks,
      String? declineReason,
      String transactionType,
      String? ticketId});
}

/// @nodoc
class _$PaymentDataCopyWithImpl<$Res> implements $PaymentDataCopyWith<$Res> {
  _$PaymentDataCopyWithImpl(this._self, this._then);

  final PaymentData _self;
  final $Res Function(PaymentData) _then;

  /// Create a copy of PaymentData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? month = null,
    Object? amount = null,
    Object? method = null,
    Object? paymentMethod = null,
    Object? date = freezed,
    Object? paymentDate = freezed,
    Object? status = null,
    Object? unitId = null,
    Object? referenceNumber = null,
    Object? baseRent = null,
    Object? waterBill = null,
    Object? electricBill = null,
    Object? lateFee = null,
    Object? otherCharge = null,
    Object? tenantName = null,
    Object? unitNumber = null,
    Object? tenantId = null,
    Object? tenancyId = freezed,
    Object? proofImageUrl = null,
    Object? remarks = freezed,
    Object? declineReason = freezed,
    Object? transactionType = null,
    Object? ticketId = freezed,
  }) {
    return _then(PaymentData(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      month: null == month
          ? _self.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      method: null == method
          ? _self.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      paymentMethod: null == paymentMethod
          ? _self.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      date: freezed == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentDate: freezed == paymentDate
          ? _self.paymentDate
          : paymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _self.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      referenceNumber: null == referenceNumber
          ? _self.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String,
      baseRent: null == baseRent
          ? _self.baseRent
          : baseRent // ignore: cast_nullable_to_non_nullable
              as double,
      waterBill: null == waterBill
          ? _self.waterBill
          : waterBill // ignore: cast_nullable_to_non_nullable
              as double,
      electricBill: null == electricBill
          ? _self.electricBill
          : electricBill // ignore: cast_nullable_to_non_nullable
              as double,
      lateFee: null == lateFee
          ? _self.lateFee
          : lateFee // ignore: cast_nullable_to_non_nullable
              as double,
      otherCharge: null == otherCharge
          ? _self.otherCharge
          : otherCharge // ignore: cast_nullable_to_non_nullable
              as double,
      tenantName: null == tenantName
          ? _self.tenantName
          : tenantName // ignore: cast_nullable_to_non_nullable
              as String,
      unitNumber: null == unitNumber
          ? _self.unitNumber
          : unitNumber // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _self.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      tenancyId: freezed == tenancyId
          ? _self.tenancyId
          : tenancyId // ignore: cast_nullable_to_non_nullable
              as String?,
      proofImageUrl: null == proofImageUrl
          ? _self.proofImageUrl
          : proofImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      remarks: freezed == remarks
          ? _self.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
      declineReason: freezed == declineReason
          ? _self.declineReason
          : declineReason // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionType: null == transactionType
          ? _self.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      ticketId: freezed == ticketId
          ? _self.ticketId
          : ticketId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PaymentData].
extension PaymentDataPatterns on PaymentData {
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
    TResult Function(_PaymentData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PaymentData() when $default != null:
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
    TResult Function(_PaymentData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaymentData():
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
    TResult? Function(_PaymentData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaymentData() when $default != null:
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
            String month,
            double amount,
            String method,
            String paymentMethod,
            DateTime? date,
            DateTime? paymentDate,
            String status,
            String unitId,
            String referenceNumber,
            double baseRent,
            double waterBill,
            double electricBill,
            double lateFee,
            double otherCharge,
            String tenantName,
            String unitNumber,
            String tenantId,
            String? tenancyId,
            String proofImageUrl,
            String? remarks,
            String? declineReason,
            String transactionType,
            String? ticketId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PaymentData() when $default != null:
        return $default(
            _that.id,
            _that.month,
            _that.amount,
            _that.method,
            _that.paymentMethod,
            _that.date,
            _that.paymentDate,
            _that.status,
            _that.unitId,
            _that.referenceNumber,
            _that.baseRent,
            _that.waterBill,
            _that.electricBill,
            _that.lateFee,
            _that.otherCharge,
            _that.tenantName,
            _that.unitNumber,
            _that.tenantId,
            _that.tenancyId,
            _that.proofImageUrl,
            _that.remarks,
            _that.declineReason,
            _that.transactionType,
            _that.ticketId);
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
            String month,
            double amount,
            String method,
            String paymentMethod,
            DateTime? date,
            DateTime? paymentDate,
            String status,
            String unitId,
            String referenceNumber,
            double baseRent,
            double waterBill,
            double electricBill,
            double lateFee,
            double otherCharge,
            String tenantName,
            String unitNumber,
            String tenantId,
            String? tenancyId,
            String proofImageUrl,
            String? remarks,
            String? declineReason,
            String transactionType,
            String? ticketId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaymentData():
        return $default(
            _that.id,
            _that.month,
            _that.amount,
            _that.method,
            _that.paymentMethod,
            _that.date,
            _that.paymentDate,
            _that.status,
            _that.unitId,
            _that.referenceNumber,
            _that.baseRent,
            _that.waterBill,
            _that.electricBill,
            _that.lateFee,
            _that.otherCharge,
            _that.tenantName,
            _that.unitNumber,
            _that.tenantId,
            _that.tenancyId,
            _that.proofImageUrl,
            _that.remarks,
            _that.declineReason,
            _that.transactionType,
            _that.ticketId);
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
            String month,
            double amount,
            String method,
            String paymentMethod,
            DateTime? date,
            DateTime? paymentDate,
            String status,
            String unitId,
            String referenceNumber,
            double baseRent,
            double waterBill,
            double electricBill,
            double lateFee,
            double otherCharge,
            String tenantName,
            String unitNumber,
            String tenantId,
            String? tenancyId,
            String proofImageUrl,
            String? remarks,
            String? declineReason,
            String transactionType,
            String? ticketId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PaymentData() when $default != null:
        return $default(
            _that.id,
            _that.month,
            _that.amount,
            _that.method,
            _that.paymentMethod,
            _that.date,
            _that.paymentDate,
            _that.status,
            _that.unitId,
            _that.referenceNumber,
            _that.baseRent,
            _that.waterBill,
            _that.electricBill,
            _that.lateFee,
            _that.otherCharge,
            _that.tenantName,
            _that.unitNumber,
            _that.tenantId,
            _that.tenancyId,
            _that.proofImageUrl,
            _that.remarks,
            _that.declineReason,
            _that.transactionType,
            _that.ticketId);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PaymentData extends PaymentData {
  const _PaymentData(
      {this.id = '',
      this.month = 'Oct',
      this.amount = 0.0,
      this.method = 'GCash',
      this.paymentMethod = 'GCash',
      this.date,
      this.paymentDate,
      this.status = 'Paid',
      this.unitId = 'u1',
      this.referenceNumber = '',
      this.baseRent = 0.0,
      this.waterBill = 0.0,
      this.electricBill = 0.0,
      this.lateFee = 0.0,
      this.otherCharge = 0.0,
      this.tenantName = 'Juan Dela Cruz',
      this.unitNumber = 'Unit 1',
      this.tenantId = '',
      this.tenancyId,
      this.proofImageUrl = '',
      this.remarks,
      this.declineReason,
      this.transactionType = 'Rent',
      this.ticketId})
      : super._();
  factory _PaymentData.fromJson(Map<String, dynamic> json) =>
      _$PaymentDataFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String month;
  @override
  @JsonKey()
  final double amount;
  @override
  @JsonKey()
  final String method;
  @override
  @JsonKey()
  final String paymentMethod;
  @override
  final DateTime? date;
  @override
  final DateTime? paymentDate;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String unitId;
  @override
  @JsonKey()
  final String referenceNumber;
  @override
  @JsonKey()
  final double baseRent;
  @override
  @JsonKey()
  final double waterBill;
  @override
  @JsonKey()
  final double electricBill;
  @override
  @JsonKey()
  final double lateFee;
  @override
  @JsonKey()
  final double otherCharge;
  @override
  @JsonKey()
  final String tenantName;
  @override
  @JsonKey()
  final String unitNumber;
  @override
  @JsonKey()
  final String tenantId;
  @override
  final String? tenancyId;
  @override
  @JsonKey()
  final String proofImageUrl;
  @override
  final String? remarks;
  @override
  final String? declineReason;
  @override
  @JsonKey()
  final String transactionType;
  @override
  final String? ticketId;

  /// Create a copy of PaymentData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PaymentDataCopyWith<_PaymentData> get copyWith =>
      __$PaymentDataCopyWithImpl<_PaymentData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PaymentDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PaymentData &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.referenceNumber, referenceNumber) ||
                other.referenceNumber == referenceNumber) &&
            (identical(other.baseRent, baseRent) ||
                other.baseRent == baseRent) &&
            (identical(other.waterBill, waterBill) ||
                other.waterBill == waterBill) &&
            (identical(other.electricBill, electricBill) ||
                other.electricBill == electricBill) &&
            (identical(other.lateFee, lateFee) || other.lateFee == lateFee) &&
            (identical(other.otherCharge, otherCharge) ||
                other.otherCharge == otherCharge) &&
            (identical(other.tenantName, tenantName) ||
                other.tenantName == tenantName) &&
            (identical(other.unitNumber, unitNumber) ||
                other.unitNumber == unitNumber) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.tenancyId, tenancyId) ||
                other.tenancyId == tenancyId) &&
            (identical(other.proofImageUrl, proofImageUrl) ||
                other.proofImageUrl == proofImageUrl) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.declineReason, declineReason) ||
                other.declineReason == declineReason) &&
            (identical(other.transactionType, transactionType) ||
                other.transactionType == transactionType) &&
            (identical(other.ticketId, ticketId) ||
                other.ticketId == ticketId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        month,
        amount,
        method,
        paymentMethod,
        date,
        paymentDate,
        status,
        unitId,
        referenceNumber,
        baseRent,
        waterBill,
        electricBill,
        lateFee,
        otherCharge,
        tenantName,
        unitNumber,
        tenantId,
        tenancyId,
        proofImageUrl,
        remarks,
        declineReason,
        transactionType,
        ticketId
      ]);

  @override
  String toString() {
    return 'PaymentData(id: $id, month: $month, amount: $amount, method: $method, paymentMethod: $paymentMethod, date: $date, paymentDate: $paymentDate, status: $status, unitId: $unitId, referenceNumber: $referenceNumber, baseRent: $baseRent, waterBill: $waterBill, electricBill: $electricBill, lateFee: $lateFee, otherCharge: $otherCharge, tenantName: $tenantName, unitNumber: $unitNumber, tenantId: $tenantId, tenancyId: $tenancyId, proofImageUrl: $proofImageUrl, remarks: $remarks, declineReason: $declineReason, transactionType: $transactionType, ticketId: $ticketId)';
  }
}

/// @nodoc
abstract mixin class _$PaymentDataCopyWith<$Res>
    implements $PaymentDataCopyWith<$Res> {
  factory _$PaymentDataCopyWith(
          _PaymentData value, $Res Function(_PaymentData) _then) =
      __$PaymentDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String month,
      double amount,
      String method,
      String paymentMethod,
      DateTime? date,
      DateTime? paymentDate,
      String status,
      String unitId,
      String referenceNumber,
      double baseRent,
      double waterBill,
      double electricBill,
      double lateFee,
      double otherCharge,
      String tenantName,
      String unitNumber,
      String tenantId,
      String? tenancyId,
      String proofImageUrl,
      String? remarks,
      String? declineReason,
      String transactionType,
      String? ticketId});
}

/// @nodoc
class __$PaymentDataCopyWithImpl<$Res> implements _$PaymentDataCopyWith<$Res> {
  __$PaymentDataCopyWithImpl(this._self, this._then);

  final _PaymentData _self;
  final $Res Function(_PaymentData) _then;

  /// Create a copy of PaymentData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? month = null,
    Object? amount = null,
    Object? method = null,
    Object? paymentMethod = null,
    Object? date = freezed,
    Object? paymentDate = freezed,
    Object? status = null,
    Object? unitId = null,
    Object? referenceNumber = null,
    Object? baseRent = null,
    Object? waterBill = null,
    Object? electricBill = null,
    Object? lateFee = null,
    Object? otherCharge = null,
    Object? tenantName = null,
    Object? unitNumber = null,
    Object? tenantId = null,
    Object? tenancyId = freezed,
    Object? proofImageUrl = null,
    Object? remarks = freezed,
    Object? declineReason = freezed,
    Object? transactionType = null,
    Object? ticketId = freezed,
  }) {
    return _then(_PaymentData(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      month: null == month
          ? _self.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      method: null == method
          ? _self.method
          : method // ignore: cast_nullable_to_non_nullable
              as String,
      paymentMethod: null == paymentMethod
          ? _self.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      date: freezed == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentDate: freezed == paymentDate
          ? _self.paymentDate
          : paymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _self.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      referenceNumber: null == referenceNumber
          ? _self.referenceNumber
          : referenceNumber // ignore: cast_nullable_to_non_nullable
              as String,
      baseRent: null == baseRent
          ? _self.baseRent
          : baseRent // ignore: cast_nullable_to_non_nullable
              as double,
      waterBill: null == waterBill
          ? _self.waterBill
          : waterBill // ignore: cast_nullable_to_non_nullable
              as double,
      electricBill: null == electricBill
          ? _self.electricBill
          : electricBill // ignore: cast_nullable_to_non_nullable
              as double,
      lateFee: null == lateFee
          ? _self.lateFee
          : lateFee // ignore: cast_nullable_to_non_nullable
              as double,
      otherCharge: null == otherCharge
          ? _self.otherCharge
          : otherCharge // ignore: cast_nullable_to_non_nullable
              as double,
      tenantName: null == tenantName
          ? _self.tenantName
          : tenantName // ignore: cast_nullable_to_non_nullable
              as String,
      unitNumber: null == unitNumber
          ? _self.unitNumber
          : unitNumber // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _self.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      tenancyId: freezed == tenancyId
          ? _self.tenancyId
          : tenancyId // ignore: cast_nullable_to_non_nullable
              as String?,
      proofImageUrl: null == proofImageUrl
          ? _self.proofImageUrl
          : proofImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      remarks: freezed == remarks
          ? _self.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
      declineReason: freezed == declineReason
          ? _self.declineReason
          : declineReason // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionType: null == transactionType
          ? _self.transactionType
          : transactionType // ignore: cast_nullable_to_non_nullable
              as String,
      ticketId: freezed == ticketId
          ? _self.ticketId
          : ticketId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
