// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance_ticket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaintenanceTicket {
  String get id;
  String get tenantId;
  String get unitId;
  String get title;
  String get description;
  TicketSeverity get severity;
  TicketStatus get status;
  List<String>? get photoUrls;
  int? get rating;
  DateTime get createdAt;
  DateTime? get resolvedAt;

  /// Create a copy of MaintenanceTicket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MaintenanceTicketCopyWith<MaintenanceTicket> get copyWith =>
      _$MaintenanceTicketCopyWithImpl<MaintenanceTicket>(
          this as MaintenanceTicket, _$identity);

  /// Serializes this MaintenanceTicket to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MaintenanceTicket &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other.photoUrls, photoUrls) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      unitId,
      title,
      description,
      severity,
      status,
      const DeepCollectionEquality().hash(photoUrls),
      rating,
      createdAt,
      resolvedAt);

  @override
  String toString() {
    return 'MaintenanceTicket(id: $id, tenantId: $tenantId, unitId: $unitId, title: $title, description: $description, severity: $severity, status: $status, photoUrls: $photoUrls, rating: $rating, createdAt: $createdAt, resolvedAt: $resolvedAt)';
  }
}

/// @nodoc
abstract mixin class $MaintenanceTicketCopyWith<$Res> {
  factory $MaintenanceTicketCopyWith(
          MaintenanceTicket value, $Res Function(MaintenanceTicket) _then) =
      _$MaintenanceTicketCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String unitId,
      String title,
      String description,
      TicketSeverity severity,
      TicketStatus status,
      List<String>? photoUrls,
      int? rating,
      DateTime createdAt,
      DateTime? resolvedAt});
}

/// @nodoc
class _$MaintenanceTicketCopyWithImpl<$Res>
    implements $MaintenanceTicketCopyWith<$Res> {
  _$MaintenanceTicketCopyWithImpl(this._self, this._then);

  final MaintenanceTicket _self;
  final $Res Function(MaintenanceTicket) _then;

  /// Create a copy of MaintenanceTicket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? unitId = null,
    Object? title = null,
    Object? description = null,
    Object? severity = null,
    Object? status = null,
    Object? photoUrls = freezed,
    Object? rating = freezed,
    Object? createdAt = null,
    Object? resolvedAt = freezed,
  }) {
    return _then(MaintenanceTicket(
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
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _self.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as TicketSeverity,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as TicketStatus,
      photoUrls: freezed == photoUrls
          ? _self.photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      rating: freezed == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resolvedAt: freezed == resolvedAt
          ? _self.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [MaintenanceTicket].
extension MaintenanceTicketPatterns on MaintenanceTicket {
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
    TResult Function(_MaintenanceTicket value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MaintenanceTicket() when $default != null:
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
    TResult Function(_MaintenanceTicket value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MaintenanceTicket():
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
    TResult? Function(_MaintenanceTicket value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MaintenanceTicket() when $default != null:
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
            String title,
            String description,
            TicketSeverity severity,
            TicketStatus status,
            List<String>? photoUrls,
            int? rating,
            DateTime createdAt,
            DateTime? resolvedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MaintenanceTicket() when $default != null:
        return $default(
            _that.id,
            _that.tenantId,
            _that.unitId,
            _that.title,
            _that.description,
            _that.severity,
            _that.status,
            _that.photoUrls,
            _that.rating,
            _that.createdAt,
            _that.resolvedAt);
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
            String title,
            String description,
            TicketSeverity severity,
            TicketStatus status,
            List<String>? photoUrls,
            int? rating,
            DateTime createdAt,
            DateTime? resolvedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MaintenanceTicket():
        return $default(
            _that.id,
            _that.tenantId,
            _that.unitId,
            _that.title,
            _that.description,
            _that.severity,
            _that.status,
            _that.photoUrls,
            _that.rating,
            _that.createdAt,
            _that.resolvedAt);
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
            String title,
            String description,
            TicketSeverity severity,
            TicketStatus status,
            List<String>? photoUrls,
            int? rating,
            DateTime createdAt,
            DateTime? resolvedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MaintenanceTicket() when $default != null:
        return $default(
            _that.id,
            _that.tenantId,
            _that.unitId,
            _that.title,
            _that.description,
            _that.severity,
            _that.status,
            _that.photoUrls,
            _that.rating,
            _that.createdAt,
            _that.resolvedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MaintenanceTicket extends MaintenanceTicket {
  const _MaintenanceTicket(
      {required this.id,
      required this.tenantId,
      required this.unitId,
      required this.title,
      required this.description,
      required this.severity,
      this.status = TicketStatus.open,
      List<String>? photoUrls,
      this.rating,
      required this.createdAt,
      this.resolvedAt})
      : _photoUrls = photoUrls,
        super._();
  factory _MaintenanceTicket.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceTicketFromJson(json);

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String unitId;
  @override
  final String title;
  @override
  final String description;
  @override
  final TicketSeverity severity;
  @override
  @JsonKey()
  final TicketStatus status;
  final List<String>? _photoUrls;
  @override
  List<String>? get photoUrls {
    final value = _photoUrls;
    if (value == null) return null;
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? rating;
  @override
  final DateTime createdAt;
  @override
  final DateTime? resolvedAt;

  /// Create a copy of MaintenanceTicket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MaintenanceTicketCopyWith<_MaintenanceTicket> get copyWith =>
      __$MaintenanceTicketCopyWithImpl<_MaintenanceTicket>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MaintenanceTicketToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MaintenanceTicket &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._photoUrls, _photoUrls) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tenantId,
      unitId,
      title,
      description,
      severity,
      status,
      const DeepCollectionEquality().hash(_photoUrls),
      rating,
      createdAt,
      resolvedAt);

  @override
  String toString() {
    return 'MaintenanceTicket(id: $id, tenantId: $tenantId, unitId: $unitId, title: $title, description: $description, severity: $severity, status: $status, photoUrls: $photoUrls, rating: $rating, createdAt: $createdAt, resolvedAt: $resolvedAt)';
  }
}

/// @nodoc
abstract mixin class _$MaintenanceTicketCopyWith<$Res>
    implements $MaintenanceTicketCopyWith<$Res> {
  factory _$MaintenanceTicketCopyWith(
          _MaintenanceTicket value, $Res Function(_MaintenanceTicket) _then) =
      __$MaintenanceTicketCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String tenantId,
      String unitId,
      String title,
      String description,
      TicketSeverity severity,
      TicketStatus status,
      List<String>? photoUrls,
      int? rating,
      DateTime createdAt,
      DateTime? resolvedAt});
}

/// @nodoc
class __$MaintenanceTicketCopyWithImpl<$Res>
    implements _$MaintenanceTicketCopyWith<$Res> {
  __$MaintenanceTicketCopyWithImpl(this._self, this._then);

  final _MaintenanceTicket _self;
  final $Res Function(_MaintenanceTicket) _then;

  /// Create a copy of MaintenanceTicket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? tenantId = null,
    Object? unitId = null,
    Object? title = null,
    Object? description = null,
    Object? severity = null,
    Object? status = null,
    Object? photoUrls = freezed,
    Object? rating = freezed,
    Object? createdAt = null,
    Object? resolvedAt = freezed,
  }) {
    return _then(_MaintenanceTicket(
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
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _self.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as TicketSeverity,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as TicketStatus,
      photoUrls: freezed == photoUrls
          ? _self._photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      rating: freezed == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      resolvedAt: freezed == resolvedAt
          ? _self.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
