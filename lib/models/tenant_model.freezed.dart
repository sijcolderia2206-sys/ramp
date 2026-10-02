// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenant_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReminderLog {
  String get id;
  String get tenantId;
  String get channel;
  DateTime? get timestamp;
  String get rentCycle;
  String get messageType;

  /// Create a copy of ReminderLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReminderLogCopyWith<ReminderLog> get copyWith =>
      _$ReminderLogCopyWithImpl<ReminderLog>(this as ReminderLog, _$identity);

  /// Serializes this ReminderLog to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReminderLog &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.rentCycle, rentCycle) ||
                other.rentCycle == rentCycle) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, tenantId, channel, timestamp, rentCycle, messageType);

  @override
  String toString() {
    return 'ReminderLog(id: $id, tenantId: $tenantId, channel: $channel, timestamp: $timestamp, rentCycle: $rentCycle, messageType: $messageType)';
  }
}

/// @nodoc
abstract mixin class $ReminderLogCopyWith<$Res> {
  factory $ReminderLogCopyWith(
          ReminderLog value, $Res Function(ReminderLog) _then) =
      _$ReminderLogCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String channel,
      DateTime? timestamp,
      String rentCycle,
      String messageType});
}

/// @nodoc
class _$ReminderLogCopyWithImpl<$Res> implements $ReminderLogCopyWith<$Res> {
  _$ReminderLogCopyWithImpl(this._self, this._then);

  final ReminderLog _self;
  final $Res Function(ReminderLog) _then;

  /// Create a copy of ReminderLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? channel = null,
    Object? timestamp = freezed,
    Object? rentCycle = null,
    Object? messageType = null,
  }) {
    return _then(ReminderLog(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _self.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _self.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rentCycle: null == rentCycle
          ? _self.rentCycle
          : rentCycle // ignore: cast_nullable_to_non_nullable
              as String,
      messageType: null == messageType
          ? _self.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ReminderLog].
extension ReminderLogPatterns on ReminderLog {
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
    TResult Function(_ReminderLog value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReminderLog() when $default != null:
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
    TResult Function(_ReminderLog value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReminderLog():
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
    TResult? Function(_ReminderLog value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReminderLog() when $default != null:
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
    TResult Function(String id, String tenantId, String channel,
            DateTime? timestamp, String rentCycle, String messageType)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ReminderLog() when $default != null:
        return $default(_that.id, _that.tenantId, _that.channel,
            _that.timestamp, _that.rentCycle, _that.messageType);
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
    TResult Function(String id, String tenantId, String channel,
            DateTime? timestamp, String rentCycle, String messageType)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReminderLog():
        return $default(_that.id, _that.tenantId, _that.channel,
            _that.timestamp, _that.rentCycle, _that.messageType);
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
    TResult? Function(String id, String tenantId, String channel,
            DateTime? timestamp, String rentCycle, String messageType)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ReminderLog() when $default != null:
        return $default(_that.id, _that.tenantId, _that.channel,
            _that.timestamp, _that.rentCycle, _that.messageType);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ReminderLog extends ReminderLog {
  const _ReminderLog(
      {this.id = '',
      this.tenantId = '',
      this.channel = '',
      this.timestamp,
      this.rentCycle = '',
      this.messageType = 'Rent Notice'})
      : super._();
  factory _ReminderLog.fromJson(Map<String, dynamic> json) =>
      _$ReminderLogFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String tenantId;
  @override
  @JsonKey()
  final String channel;
  @override
  final DateTime? timestamp;
  @override
  @JsonKey()
  final String rentCycle;
  @override
  @JsonKey()
  final String messageType;

  /// Create a copy of ReminderLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReminderLogCopyWith<_ReminderLog> get copyWith =>
      __$ReminderLogCopyWithImpl<_ReminderLog>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ReminderLogToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReminderLog &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.rentCycle, rentCycle) ||
                other.rentCycle == rentCycle) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, tenantId, channel, timestamp, rentCycle, messageType);

  @override
  String toString() {
    return 'ReminderLog(id: $id, tenantId: $tenantId, channel: $channel, timestamp: $timestamp, rentCycle: $rentCycle, messageType: $messageType)';
  }
}

/// @nodoc
abstract mixin class _$ReminderLogCopyWith<$Res>
    implements $ReminderLogCopyWith<$Res> {
  factory _$ReminderLogCopyWith(
          _ReminderLog value, $Res Function(_ReminderLog) _then) =
      __$ReminderLogCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String channel,
      DateTime? timestamp,
      String rentCycle,
      String messageType});
}

/// @nodoc
class __$ReminderLogCopyWithImpl<$Res> implements _$ReminderLogCopyWith<$Res> {
  __$ReminderLogCopyWithImpl(this._self, this._then);

  final _ReminderLog _self;
  final $Res Function(_ReminderLog) _then;

  /// Create a copy of ReminderLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? channel = null,
    Object? timestamp = freezed,
    Object? rentCycle = null,
    Object? messageType = null,
  }) {
    return _then(_ReminderLog(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: null == tenantId
          ? _self.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _self.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rentCycle: null == rentCycle
          ? _self.rentCycle
          : rentCycle // ignore: cast_nullable_to_non_nullable
              as String,
      messageType: null == messageType
          ? _self.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$Tenant {
  String get id;
  String get name;
  String get email;
  String get phone;
  String get contactNumber;
  String get address;
  String get referral;
  String get unitId;
  String get unitNumber;
  double get monthlyRent;
  DateTime? get leaseStart;
  DateTime? get leaseEnd;
  DateTime? get dueDate;
  double get balance;
  String get status;
  bool get isArchived;
  String? get avatarUrl;
  String? get currentTenancyId;
  String? get messengerHandle;
  List<ReminderLog> get reminderLogs;

  /// Create a copy of Tenant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TenantCopyWith<Tenant> get copyWith =>
      _$TenantCopyWithImpl<Tenant>(this as Tenant, _$identity);

  /// Serializes this Tenant to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Tenant &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.contactNumber, contactNumber) ||
                other.contactNumber == contactNumber) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.referral, referral) ||
                other.referral == referral) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.unitNumber, unitNumber) ||
                other.unitNumber == unitNumber) &&
            (identical(other.monthlyRent, monthlyRent) ||
                other.monthlyRent == monthlyRent) &&
            (identical(other.leaseStart, leaseStart) ||
                other.leaseStart == leaseStart) &&
            (identical(other.leaseEnd, leaseEnd) ||
                other.leaseEnd == leaseEnd) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.currentTenancyId, currentTenancyId) ||
                other.currentTenancyId == currentTenancyId) &&
            (identical(other.messengerHandle, messengerHandle) ||
                other.messengerHandle == messengerHandle) &&
            const DeepCollectionEquality()
                .equals(other.reminderLogs, reminderLogs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        email,
        phone,
        contactNumber,
        address,
        referral,
        unitId,
        unitNumber,
        monthlyRent,
        leaseStart,
        leaseEnd,
        dueDate,
        balance,
        status,
        isArchived,
        avatarUrl,
        currentTenancyId,
        messengerHandle,
        const DeepCollectionEquality().hash(reminderLogs)
      ]);

  @override
  String toString() {
    return 'Tenant(id: $id, name: $name, email: $email, phone: $phone, contactNumber: $contactNumber, address: $address, referral: $referral, unitId: $unitId, unitNumber: $unitNumber, monthlyRent: $monthlyRent, leaseStart: $leaseStart, leaseEnd: $leaseEnd, dueDate: $dueDate, balance: $balance, status: $status, isArchived: $isArchived, avatarUrl: $avatarUrl, currentTenancyId: $currentTenancyId, messengerHandle: $messengerHandle, reminderLogs: $reminderLogs)';
  }
}

/// @nodoc
abstract mixin class $TenantCopyWith<$Res> {
  factory $TenantCopyWith(Tenant value, $Res Function(Tenant) _then) =
      _$TenantCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      String phone,
      String contactNumber,
      String address,
      String referral,
      String unitId,
      String unitNumber,
      double monthlyRent,
      DateTime? leaseStart,
      DateTime? leaseEnd,
      DateTime? dueDate,
      double balance,
      String status,
      bool isArchived,
      String? avatarUrl,
      String? currentTenancyId,
      String? messengerHandle,
      List<ReminderLog> reminderLogs});
}

/// @nodoc
class _$TenantCopyWithImpl<$Res> implements $TenantCopyWith<$Res> {
  _$TenantCopyWithImpl(this._self, this._then);

  final Tenant _self;
  final $Res Function(Tenant) _then;

  /// Create a copy of Tenant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? phone = null,
    Object? contactNumber = null,
    Object? address = null,
    Object? referral = null,
    Object? unitId = null,
    Object? unitNumber = null,
    Object? monthlyRent = null,
    Object? leaseStart = freezed,
    Object? leaseEnd = freezed,
    Object? dueDate = freezed,
    Object? balance = null,
    Object? status = null,
    Object? isArchived = null,
    Object? avatarUrl = freezed,
    Object? currentTenancyId = freezed,
    Object? messengerHandle = freezed,
    Object? reminderLogs = null,
  }) {
    return _then(Tenant(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      contactNumber: null == contactNumber
          ? _self.contactNumber
          : contactNumber // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      referral: null == referral
          ? _self.referral
          : referral // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _self.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      unitNumber: null == unitNumber
          ? _self.unitNumber
          : unitNumber // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyRent: null == monthlyRent
          ? _self.monthlyRent
          : monthlyRent // ignore: cast_nullable_to_non_nullable
              as double,
      leaseStart: freezed == leaseStart
          ? _self.leaseStart
          : leaseStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      leaseEnd: freezed == leaseEnd
          ? _self.leaseEnd
          : leaseEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dueDate: freezed == dueDate
          ? _self.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      balance: null == balance
          ? _self.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      currentTenancyId: freezed == currentTenancyId
          ? _self.currentTenancyId
          : currentTenancyId // ignore: cast_nullable_to_non_nullable
              as String?,
      messengerHandle: freezed == messengerHandle
          ? _self.messengerHandle
          : messengerHandle // ignore: cast_nullable_to_non_nullable
              as String?,
      reminderLogs: null == reminderLogs
          ? _self.reminderLogs
          : reminderLogs // ignore: cast_nullable_to_non_nullable
              as List<ReminderLog>,
    ));
  }
}

/// Adds pattern-matching-related methods to [Tenant].
extension TenantPatterns on Tenant {
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
    TResult Function(_Tenant value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Tenant() when $default != null:
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
    TResult Function(_Tenant value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Tenant():
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
    TResult? Function(_Tenant value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Tenant() when $default != null:
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
            String email,
            String phone,
            String contactNumber,
            String address,
            String referral,
            String unitId,
            String unitNumber,
            double monthlyRent,
            DateTime? leaseStart,
            DateTime? leaseEnd,
            DateTime? dueDate,
            double balance,
            String status,
            bool isArchived,
            String? avatarUrl,
            String? currentTenancyId,
            String? messengerHandle,
            List<ReminderLog> reminderLogs)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Tenant() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.email,
            _that.phone,
            _that.contactNumber,
            _that.address,
            _that.referral,
            _that.unitId,
            _that.unitNumber,
            _that.monthlyRent,
            _that.leaseStart,
            _that.leaseEnd,
            _that.dueDate,
            _that.balance,
            _that.status,
            _that.isArchived,
            _that.avatarUrl,
            _that.currentTenancyId,
            _that.messengerHandle,
            _that.reminderLogs);
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
            String email,
            String phone,
            String contactNumber,
            String address,
            String referral,
            String unitId,
            String unitNumber,
            double monthlyRent,
            DateTime? leaseStart,
            DateTime? leaseEnd,
            DateTime? dueDate,
            double balance,
            String status,
            bool isArchived,
            String? avatarUrl,
            String? currentTenancyId,
            String? messengerHandle,
            List<ReminderLog> reminderLogs)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Tenant():
        return $default(
            _that.id,
            _that.name,
            _that.email,
            _that.phone,
            _that.contactNumber,
            _that.address,
            _that.referral,
            _that.unitId,
            _that.unitNumber,
            _that.monthlyRent,
            _that.leaseStart,
            _that.leaseEnd,
            _that.dueDate,
            _that.balance,
            _that.status,
            _that.isArchived,
            _that.avatarUrl,
            _that.currentTenancyId,
            _that.messengerHandle,
            _that.reminderLogs);
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
            String email,
            String phone,
            String contactNumber,
            String address,
            String referral,
            String unitId,
            String unitNumber,
            double monthlyRent,
            DateTime? leaseStart,
            DateTime? leaseEnd,
            DateTime? dueDate,
            double balance,
            String status,
            bool isArchived,
            String? avatarUrl,
            String? currentTenancyId,
            String? messengerHandle,
            List<ReminderLog> reminderLogs)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Tenant() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.email,
            _that.phone,
            _that.contactNumber,
            _that.address,
            _that.referral,
            _that.unitId,
            _that.unitNumber,
            _that.monthlyRent,
            _that.leaseStart,
            _that.leaseEnd,
            _that.dueDate,
            _that.balance,
            _that.status,
            _that.isArchived,
            _that.avatarUrl,
            _that.currentTenancyId,
            _that.messengerHandle,
            _that.reminderLogs);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Tenant extends Tenant {
  const _Tenant(
      {this.id = '',
      this.name = '',
      this.email = '',
      this.phone = '',
      this.contactNumber = '',
      this.address = '',
      this.referral = '',
      this.unitId = '',
      this.unitNumber = 'Unassigned',
      this.monthlyRent = 0.0,
      this.leaseStart,
      this.leaseEnd,
      this.dueDate,
      this.balance = 0.0,
      this.status = 'Active',
      this.isArchived = false,
      this.avatarUrl,
      this.currentTenancyId,
      this.messengerHandle,
      List<ReminderLog> reminderLogs = const []})
      : _reminderLogs = reminderLogs,
        super._();
  factory _Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String contactNumber;
  @override
  @JsonKey()
  final String address;
  @override
  @JsonKey()
  final String referral;
  @override
  @JsonKey()
  final String unitId;
  @override
  @JsonKey()
  final String unitNumber;
  @override
  @JsonKey()
  final double monthlyRent;
  @override
  final DateTime? leaseStart;
  @override
  final DateTime? leaseEnd;
  @override
  final DateTime? dueDate;
  @override
  @JsonKey()
  final double balance;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  final String? avatarUrl;
  @override
  final String? currentTenancyId;
  @override
  final String? messengerHandle;
  final List<ReminderLog> _reminderLogs;
  @override
  @JsonKey()
  List<ReminderLog> get reminderLogs {
    if (_reminderLogs is EqualUnmodifiableListView) return _reminderLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reminderLogs);
  }

  /// Create a copy of Tenant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TenantCopyWith<_Tenant> get copyWith =>
      __$TenantCopyWithImpl<_Tenant>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TenantToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Tenant &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.contactNumber, contactNumber) ||
                other.contactNumber == contactNumber) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.referral, referral) ||
                other.referral == referral) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.unitNumber, unitNumber) ||
                other.unitNumber == unitNumber) &&
            (identical(other.monthlyRent, monthlyRent) ||
                other.monthlyRent == monthlyRent) &&
            (identical(other.leaseStart, leaseStart) ||
                other.leaseStart == leaseStart) &&
            (identical(other.leaseEnd, leaseEnd) ||
                other.leaseEnd == leaseEnd) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.currentTenancyId, currentTenancyId) ||
                other.currentTenancyId == currentTenancyId) &&
            (identical(other.messengerHandle, messengerHandle) ||
                other.messengerHandle == messengerHandle) &&
            const DeepCollectionEquality()
                .equals(other._reminderLogs, _reminderLogs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        email,
        phone,
        contactNumber,
        address,
        referral,
        unitId,
        unitNumber,
        monthlyRent,
        leaseStart,
        leaseEnd,
        dueDate,
        balance,
        status,
        isArchived,
        avatarUrl,
        currentTenancyId,
        messengerHandle,
        const DeepCollectionEquality().hash(_reminderLogs)
      ]);

  @override
  String toString() {
    return 'Tenant(id: $id, name: $name, email: $email, phone: $phone, contactNumber: $contactNumber, address: $address, referral: $referral, unitId: $unitId, unitNumber: $unitNumber, monthlyRent: $monthlyRent, leaseStart: $leaseStart, leaseEnd: $leaseEnd, dueDate: $dueDate, balance: $balance, status: $status, isArchived: $isArchived, avatarUrl: $avatarUrl, currentTenancyId: $currentTenancyId, messengerHandle: $messengerHandle, reminderLogs: $reminderLogs)';
  }
}

/// @nodoc
abstract mixin class _$TenantCopyWith<$Res> implements $TenantCopyWith<$Res> {
  factory _$TenantCopyWith(_Tenant value, $Res Function(_Tenant) _then) =
      __$TenantCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      String phone,
      String contactNumber,
      String address,
      String referral,
      String unitId,
      String unitNumber,
      double monthlyRent,
      DateTime? leaseStart,
      DateTime? leaseEnd,
      DateTime? dueDate,
      double balance,
      String status,
      bool isArchived,
      String? avatarUrl,
      String? currentTenancyId,
      String? messengerHandle,
      List<ReminderLog> reminderLogs});
}

/// @nodoc
class __$TenantCopyWithImpl<$Res> implements _$TenantCopyWith<$Res> {
  __$TenantCopyWithImpl(this._self, this._then);

  final _Tenant _self;
  final $Res Function(_Tenant) _then;

  /// Create a copy of Tenant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? phone = null,
    Object? contactNumber = null,
    Object? address = null,
    Object? referral = null,
    Object? unitId = null,
    Object? unitNumber = null,
    Object? monthlyRent = null,
    Object? leaseStart = freezed,
    Object? leaseEnd = freezed,
    Object? dueDate = freezed,
    Object? balance = null,
    Object? status = null,
    Object? isArchived = null,
    Object? avatarUrl = freezed,
    Object? currentTenancyId = freezed,
    Object? messengerHandle = freezed,
    Object? reminderLogs = null,
  }) {
    return _then(_Tenant(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _self.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      contactNumber: null == contactNumber
          ? _self.contactNumber
          : contactNumber // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _self.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      referral: null == referral
          ? _self.referral
          : referral // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _self.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      unitNumber: null == unitNumber
          ? _self.unitNumber
          : unitNumber // ignore: cast_nullable_to_non_nullable
              as String,
      monthlyRent: null == monthlyRent
          ? _self.monthlyRent
          : monthlyRent // ignore: cast_nullable_to_non_nullable
              as double,
      leaseStart: freezed == leaseStart
          ? _self.leaseStart
          : leaseStart // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      leaseEnd: freezed == leaseEnd
          ? _self.leaseEnd
          : leaseEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dueDate: freezed == dueDate
          ? _self.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      balance: null == balance
          ? _self.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      avatarUrl: freezed == avatarUrl
          ? _self.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      currentTenancyId: freezed == currentTenancyId
          ? _self.currentTenancyId
          : currentTenancyId // ignore: cast_nullable_to_non_nullable
              as String?,
      messengerHandle: freezed == messengerHandle
          ? _self.messengerHandle
          : messengerHandle // ignore: cast_nullable_to_non_nullable
              as String?,
      reminderLogs: null == reminderLogs
          ? _self._reminderLogs
          : reminderLogs // ignore: cast_nullable_to_non_nullable
              as List<ReminderLog>,
    ));
  }
}

// dart format on
