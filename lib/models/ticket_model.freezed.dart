// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TicketStatusHistoryEntry {
  String get status;
  DateTime? get timestamp;
  String? get note;

  /// Create a copy of TicketStatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TicketStatusHistoryEntryCopyWith<TicketStatusHistoryEntry> get copyWith =>
      _$TicketStatusHistoryEntryCopyWithImpl<TicketStatusHistoryEntry>(
          this as TicketStatusHistoryEntry, _$identity);

  /// Serializes this TicketStatusHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TicketStatusHistoryEntry &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, timestamp, note);

  @override
  String toString() {
    return 'TicketStatusHistoryEntry(status: $status, timestamp: $timestamp, note: $note)';
  }
}

/// @nodoc
abstract mixin class $TicketStatusHistoryEntryCopyWith<$Res> {
  factory $TicketStatusHistoryEntryCopyWith(TicketStatusHistoryEntry value,
          $Res Function(TicketStatusHistoryEntry) _then) =
      _$TicketStatusHistoryEntryCopyWithImpl;
  @useResult
  $Res call({String status, DateTime? timestamp, String? note});
}

/// @nodoc
class _$TicketStatusHistoryEntryCopyWithImpl<$Res>
    implements $TicketStatusHistoryEntryCopyWith<$Res> {
  _$TicketStatusHistoryEntryCopyWithImpl(this._self, this._then);

  final TicketStatusHistoryEntry _self;
  final $Res Function(TicketStatusHistoryEntry) _then;

  /// Create a copy of TicketStatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? timestamp = freezed,
    Object? note = freezed,
  }) {
    return _then(TicketStatusHistoryEntry(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [TicketStatusHistoryEntry].
extension TicketStatusHistoryEntryPatterns on TicketStatusHistoryEntry {
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
    TResult Function(_TicketStatusHistoryEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TicketStatusHistoryEntry() when $default != null:
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
    TResult Function(_TicketStatusHistoryEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketStatusHistoryEntry():
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
    TResult? Function(_TicketStatusHistoryEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketStatusHistoryEntry() when $default != null:
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
    TResult Function(String status, DateTime? timestamp, String? note)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TicketStatusHistoryEntry() when $default != null:
        return $default(_that.status, _that.timestamp, _that.note);
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
    TResult Function(String status, DateTime? timestamp, String? note) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketStatusHistoryEntry():
        return $default(_that.status, _that.timestamp, _that.note);
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
    TResult? Function(String status, DateTime? timestamp, String? note)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketStatusHistoryEntry() when $default != null:
        return $default(_that.status, _that.timestamp, _that.note);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TicketStatusHistoryEntry extends TicketStatusHistoryEntry {
  const _TicketStatusHistoryEntry({this.status = '', this.timestamp, this.note})
      : super._();
  factory _TicketStatusHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$TicketStatusHistoryEntryFromJson(json);

  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? timestamp;
  @override
  final String? note;

  /// Create a copy of TicketStatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TicketStatusHistoryEntryCopyWith<_TicketStatusHistoryEntry> get copyWith =>
      __$TicketStatusHistoryEntryCopyWithImpl<_TicketStatusHistoryEntry>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TicketStatusHistoryEntryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TicketStatusHistoryEntry &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, timestamp, note);

  @override
  String toString() {
    return 'TicketStatusHistoryEntry(status: $status, timestamp: $timestamp, note: $note)';
  }
}

/// @nodoc
abstract mixin class _$TicketStatusHistoryEntryCopyWith<$Res>
    implements $TicketStatusHistoryEntryCopyWith<$Res> {
  factory _$TicketStatusHistoryEntryCopyWith(_TicketStatusHistoryEntry value,
          $Res Function(_TicketStatusHistoryEntry) _then) =
      __$TicketStatusHistoryEntryCopyWithImpl;
  @override
  @useResult
  $Res call({String status, DateTime? timestamp, String? note});
}

/// @nodoc
class __$TicketStatusHistoryEntryCopyWithImpl<$Res>
    implements _$TicketStatusHistoryEntryCopyWith<$Res> {
  __$TicketStatusHistoryEntryCopyWithImpl(this._self, this._then);

  final _TicketStatusHistoryEntry _self;
  final $Res Function(_TicketStatusHistoryEntry) _then;

  /// Create a copy of TicketStatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? status = null,
    Object? timestamp = freezed,
    Object? note = freezed,
  }) {
    return _then(_TicketStatusHistoryEntry(
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$Ticket {
  String get id;
  String? get unitId;
  String get unitNumber;
  String? get tenantId;
  String get tenantName;
  String get title;
  String get description;
  String get category;
  String? get photoPath;
  String? get photoBefore;
  String? get photoAfter;
  List<String> get photos;
  String get priority;
  String get status;
  String get assignedTo;
  String get assignedToName;
  String? get vendorId;
  double get estimatedCost;
  double get actualCost;
  double get vendorCost;
  DateTime? get date;
  DateTime? get createdAt;
  DateTime? get slaDueDate;
  int get rating;
  String? get ratingFeedback;
  String get responsibleParty;
  bool get paymentRequired;
  String get paymentStatus;
  String? get tenancyId;
  List<TicketStatusHistoryEntry> get statusHistory;
  List<String> get affectedAreas;
  DateTime? get issueStartedAt;
  DateTime? get visitScheduledAt;
  String get visitTimeWindow;
  bool get visitReminderSent;
  List<String> get replacementItems;
  DateTime? get repairScheduledAt;
  String get repairTimeWindow;
  String get repairer;
  bool get repairReminderSent;
  String get completionSummary;

  /// Create a copy of Ticket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TicketCopyWith<Ticket> get copyWith =>
      _$TicketCopyWithImpl<Ticket>(this as Ticket, _$identity);

  /// Serializes this Ticket to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Ticket &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.unitNumber, unitNumber) ||
                other.unitNumber == unitNumber) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.tenantName, tenantName) ||
                other.tenantName == tenantName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.photoPath, photoPath) ||
                other.photoPath == photoPath) &&
            (identical(other.photoBefore, photoBefore) ||
                other.photoBefore == photoBefore) &&
            (identical(other.photoAfter, photoAfter) ||
                other.photoAfter == photoAfter) &&
            const DeepCollectionEquality().equals(other.photos, photos) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.assignedToName, assignedToName) ||
                other.assignedToName == assignedToName) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.estimatedCost, estimatedCost) ||
                other.estimatedCost == estimatedCost) &&
            (identical(other.actualCost, actualCost) ||
                other.actualCost == actualCost) &&
            (identical(other.vendorCost, vendorCost) ||
                other.vendorCost == vendorCost) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.slaDueDate, slaDueDate) ||
                other.slaDueDate == slaDueDate) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.ratingFeedback, ratingFeedback) ||
                other.ratingFeedback == ratingFeedback) &&
            (identical(other.responsibleParty, responsibleParty) ||
                other.responsibleParty == responsibleParty) &&
            (identical(other.paymentRequired, paymentRequired) ||
                other.paymentRequired == paymentRequired) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.tenancyId, tenancyId) ||
                other.tenancyId == tenancyId) &&
            const DeepCollectionEquality()
                .equals(other.statusHistory, statusHistory) &&
            const DeepCollectionEquality()
                .equals(other.affectedAreas, affectedAreas) &&
            (identical(other.issueStartedAt, issueStartedAt) ||
                other.issueStartedAt == issueStartedAt) &&
            (identical(other.visitScheduledAt, visitScheduledAt) ||
                other.visitScheduledAt == visitScheduledAt) &&
            (identical(other.visitTimeWindow, visitTimeWindow) ||
                other.visitTimeWindow == visitTimeWindow) &&
            (identical(other.visitReminderSent, visitReminderSent) ||
                other.visitReminderSent == visitReminderSent) &&
            const DeepCollectionEquality()
                .equals(other.replacementItems, replacementItems) &&
            (identical(other.repairScheduledAt, repairScheduledAt) ||
                other.repairScheduledAt == repairScheduledAt) &&
            (identical(other.repairTimeWindow, repairTimeWindow) ||
                other.repairTimeWindow == repairTimeWindow) &&
            (identical(other.repairer, repairer) ||
                other.repairer == repairer) &&
            (identical(other.repairReminderSent, repairReminderSent) ||
                other.repairReminderSent == repairReminderSent) &&
            (identical(other.completionSummary, completionSummary) ||
                other.completionSummary == completionSummary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        unitId,
        unitNumber,
        tenantId,
        tenantName,
        title,
        description,
        category,
        photoPath,
        photoBefore,
        photoAfter,
        const DeepCollectionEquality().hash(photos),
        priority,
        status,
        assignedTo,
        assignedToName,
        vendorId,
        estimatedCost,
        actualCost,
        vendorCost,
        date,
        createdAt,
        slaDueDate,
        rating,
        ratingFeedback,
        responsibleParty,
        paymentRequired,
        paymentStatus,
        tenancyId,
        const DeepCollectionEquality().hash(statusHistory),
        const DeepCollectionEquality().hash(affectedAreas),
        issueStartedAt,
        visitScheduledAt,
        visitTimeWindow,
        visitReminderSent,
        const DeepCollectionEquality().hash(replacementItems),
        repairScheduledAt,
        repairTimeWindow,
        repairer,
        repairReminderSent,
        completionSummary
      ]);

  @override
  String toString() {
    return 'Ticket(id: $id, unitId: $unitId, unitNumber: $unitNumber, tenantId: $tenantId, tenantName: $tenantName, title: $title, description: $description, category: $category, photoPath: $photoPath, photoBefore: $photoBefore, photoAfter: $photoAfter, photos: $photos, priority: $priority, status: $status, assignedTo: $assignedTo, assignedToName: $assignedToName, vendorId: $vendorId, estimatedCost: $estimatedCost, actualCost: $actualCost, vendorCost: $vendorCost, date: $date, createdAt: $createdAt, slaDueDate: $slaDueDate, rating: $rating, ratingFeedback: $ratingFeedback, responsibleParty: $responsibleParty, paymentRequired: $paymentRequired, paymentStatus: $paymentStatus, tenancyId: $tenancyId, statusHistory: $statusHistory, affectedAreas: $affectedAreas, issueStartedAt: $issueStartedAt, visitScheduledAt: $visitScheduledAt, visitTimeWindow: $visitTimeWindow, visitReminderSent: $visitReminderSent, replacementItems: $replacementItems, repairScheduledAt: $repairScheduledAt, repairTimeWindow: $repairTimeWindow, repairer: $repairer, repairReminderSent: $repairReminderSent, completionSummary: $completionSummary)';
  }
}

/// @nodoc
abstract mixin class $TicketCopyWith<$Res> {
  factory $TicketCopyWith(Ticket value, $Res Function(Ticket) _then) =
      _$TicketCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String? unitId,
      String unitNumber,
      String? tenantId,
      String tenantName,
      String title,
      String description,
      String category,
      String? photoPath,
      String? photoBefore,
      String? photoAfter,
      List<String> photos,
      String priority,
      String status,
      String assignedTo,
      String assignedToName,
      String? vendorId,
      double estimatedCost,
      double actualCost,
      double vendorCost,
      DateTime? date,
      DateTime? createdAt,
      DateTime? slaDueDate,
      int rating,
      String? ratingFeedback,
      String responsibleParty,
      bool paymentRequired,
      String paymentStatus,
      String? tenancyId,
      List<TicketStatusHistoryEntry> statusHistory,
      List<String> affectedAreas,
      DateTime? issueStartedAt,
      DateTime? visitScheduledAt,
      String visitTimeWindow,
      bool visitReminderSent,
      List<String> replacementItems,
      DateTime? repairScheduledAt,
      String repairTimeWindow,
      String repairer,
      bool repairReminderSent,
      String completionSummary});
}

/// @nodoc
class _$TicketCopyWithImpl<$Res> implements $TicketCopyWith<$Res> {
  _$TicketCopyWithImpl(this._self, this._then);

  final Ticket _self;
  final $Res Function(Ticket) _then;

  /// Create a copy of Ticket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? unitId = freezed,
    Object? unitNumber = null,
    Object? tenantId = freezed,
    Object? tenantName = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? photoPath = freezed,
    Object? photoBefore = freezed,
    Object? photoAfter = freezed,
    Object? photos = null,
    Object? priority = null,
    Object? status = null,
    Object? assignedTo = null,
    Object? assignedToName = null,
    Object? vendorId = freezed,
    Object? estimatedCost = null,
    Object? actualCost = null,
    Object? vendorCost = null,
    Object? date = freezed,
    Object? createdAt = freezed,
    Object? slaDueDate = freezed,
    Object? rating = null,
    Object? ratingFeedback = freezed,
    Object? responsibleParty = null,
    Object? paymentRequired = null,
    Object? paymentStatus = null,
    Object? tenancyId = freezed,
    Object? statusHistory = null,
    Object? affectedAreas = null,
    Object? issueStartedAt = freezed,
    Object? visitScheduledAt = freezed,
    Object? visitTimeWindow = null,
    Object? visitReminderSent = null,
    Object? replacementItems = null,
    Object? repairScheduledAt = freezed,
    Object? repairTimeWindow = null,
    Object? repairer = null,
    Object? repairReminderSent = null,
    Object? completionSummary = null,
  }) {
    return _then(Ticket(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: freezed == unitId
          ? _self.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String?,
      unitNumber: null == unitNumber
          ? _self.unitNumber
          : unitNumber // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: freezed == tenantId
          ? _self.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String?,
      tenantName: null == tenantName
          ? _self.tenantName
          : tenantName // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      photoPath: freezed == photoPath
          ? _self.photoPath
          : photoPath // ignore: cast_nullable_to_non_nullable
              as String?,
      photoBefore: freezed == photoBefore
          ? _self.photoBefore
          : photoBefore // ignore: cast_nullable_to_non_nullable
              as String?,
      photoAfter: freezed == photoAfter
          ? _self.photoAfter
          : photoAfter // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _self.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      assignedTo: null == assignedTo
          ? _self.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as String,
      assignedToName: null == assignedToName
          ? _self.assignedToName
          : assignedToName // ignore: cast_nullable_to_non_nullable
              as String,
      vendorId: freezed == vendorId
          ? _self.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedCost: null == estimatedCost
          ? _self.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as double,
      actualCost: null == actualCost
          ? _self.actualCost
          : actualCost // ignore: cast_nullable_to_non_nullable
              as double,
      vendorCost: null == vendorCost
          ? _self.vendorCost
          : vendorCost // ignore: cast_nullable_to_non_nullable
              as double,
      date: freezed == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      slaDueDate: freezed == slaDueDate
          ? _self.slaDueDate
          : slaDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rating: null == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      ratingFeedback: freezed == ratingFeedback
          ? _self.ratingFeedback
          : ratingFeedback // ignore: cast_nullable_to_non_nullable
              as String?,
      responsibleParty: null == responsibleParty
          ? _self.responsibleParty
          : responsibleParty // ignore: cast_nullable_to_non_nullable
              as String,
      paymentRequired: null == paymentRequired
          ? _self.paymentRequired
          : paymentRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      paymentStatus: null == paymentStatus
          ? _self.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      tenancyId: freezed == tenancyId
          ? _self.tenancyId
          : tenancyId // ignore: cast_nullable_to_non_nullable
              as String?,
      statusHistory: null == statusHistory
          ? _self.statusHistory
          : statusHistory // ignore: cast_nullable_to_non_nullable
              as List<TicketStatusHistoryEntry>,
      affectedAreas: null == affectedAreas
          ? _self.affectedAreas
          : affectedAreas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      issueStartedAt: freezed == issueStartedAt
          ? _self.issueStartedAt
          : issueStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      visitScheduledAt: freezed == visitScheduledAt
          ? _self.visitScheduledAt
          : visitScheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      visitTimeWindow: null == visitTimeWindow
          ? _self.visitTimeWindow
          : visitTimeWindow // ignore: cast_nullable_to_non_nullable
              as String,
      visitReminderSent: null == visitReminderSent
          ? _self.visitReminderSent
          : visitReminderSent // ignore: cast_nullable_to_non_nullable
              as bool,
      replacementItems: null == replacementItems
          ? _self.replacementItems
          : replacementItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      repairScheduledAt: freezed == repairScheduledAt
          ? _self.repairScheduledAt
          : repairScheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      repairTimeWindow: null == repairTimeWindow
          ? _self.repairTimeWindow
          : repairTimeWindow // ignore: cast_nullable_to_non_nullable
              as String,
      repairer: null == repairer
          ? _self.repairer
          : repairer // ignore: cast_nullable_to_non_nullable
              as String,
      repairReminderSent: null == repairReminderSent
          ? _self.repairReminderSent
          : repairReminderSent // ignore: cast_nullable_to_non_nullable
              as bool,
      completionSummary: null == completionSummary
          ? _self.completionSummary
          : completionSummary // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [Ticket].
extension TicketPatterns on Ticket {
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
    TResult Function(_Ticket value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Ticket() when $default != null:
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
    TResult Function(_Ticket value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Ticket():
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
    TResult? Function(_Ticket value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Ticket() when $default != null:
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
            String? unitId,
            String unitNumber,
            String? tenantId,
            String tenantName,
            String title,
            String description,
            String category,
            String? photoPath,
            String? photoBefore,
            String? photoAfter,
            List<String> photos,
            String priority,
            String status,
            String assignedTo,
            String assignedToName,
            String? vendorId,
            double estimatedCost,
            double actualCost,
            double vendorCost,
            DateTime? date,
            DateTime? createdAt,
            DateTime? slaDueDate,
            int rating,
            String? ratingFeedback,
            String responsibleParty,
            bool paymentRequired,
            String paymentStatus,
            String? tenancyId,
            List<TicketStatusHistoryEntry> statusHistory,
            List<String> affectedAreas,
            DateTime? issueStartedAt,
            DateTime? visitScheduledAt,
            String visitTimeWindow,
            bool visitReminderSent,
            List<String> replacementItems,
            DateTime? repairScheduledAt,
            String repairTimeWindow,
            String repairer,
            bool repairReminderSent,
            String completionSummary)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Ticket() when $default != null:
        return $default(
            _that.id,
            _that.unitId,
            _that.unitNumber,
            _that.tenantId,
            _that.tenantName,
            _that.title,
            _that.description,
            _that.category,
            _that.photoPath,
            _that.photoBefore,
            _that.photoAfter,
            _that.photos,
            _that.priority,
            _that.status,
            _that.assignedTo,
            _that.assignedToName,
            _that.vendorId,
            _that.estimatedCost,
            _that.actualCost,
            _that.vendorCost,
            _that.date,
            _that.createdAt,
            _that.slaDueDate,
            _that.rating,
            _that.ratingFeedback,
            _that.responsibleParty,
            _that.paymentRequired,
            _that.paymentStatus,
            _that.tenancyId,
            _that.statusHistory,
            _that.affectedAreas,
            _that.issueStartedAt,
            _that.visitScheduledAt,
            _that.visitTimeWindow,
            _that.visitReminderSent,
            _that.replacementItems,
            _that.repairScheduledAt,
            _that.repairTimeWindow,
            _that.repairer,
            _that.repairReminderSent,
            _that.completionSummary);
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
            String? unitId,
            String unitNumber,
            String? tenantId,
            String tenantName,
            String title,
            String description,
            String category,
            String? photoPath,
            String? photoBefore,
            String? photoAfter,
            List<String> photos,
            String priority,
            String status,
            String assignedTo,
            String assignedToName,
            String? vendorId,
            double estimatedCost,
            double actualCost,
            double vendorCost,
            DateTime? date,
            DateTime? createdAt,
            DateTime? slaDueDate,
            int rating,
            String? ratingFeedback,
            String responsibleParty,
            bool paymentRequired,
            String paymentStatus,
            String? tenancyId,
            List<TicketStatusHistoryEntry> statusHistory,
            List<String> affectedAreas,
            DateTime? issueStartedAt,
            DateTime? visitScheduledAt,
            String visitTimeWindow,
            bool visitReminderSent,
            List<String> replacementItems,
            DateTime? repairScheduledAt,
            String repairTimeWindow,
            String repairer,
            bool repairReminderSent,
            String completionSummary)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Ticket():
        return $default(
            _that.id,
            _that.unitId,
            _that.unitNumber,
            _that.tenantId,
            _that.tenantName,
            _that.title,
            _that.description,
            _that.category,
            _that.photoPath,
            _that.photoBefore,
            _that.photoAfter,
            _that.photos,
            _that.priority,
            _that.status,
            _that.assignedTo,
            _that.assignedToName,
            _that.vendorId,
            _that.estimatedCost,
            _that.actualCost,
            _that.vendorCost,
            _that.date,
            _that.createdAt,
            _that.slaDueDate,
            _that.rating,
            _that.ratingFeedback,
            _that.responsibleParty,
            _that.paymentRequired,
            _that.paymentStatus,
            _that.tenancyId,
            _that.statusHistory,
            _that.affectedAreas,
            _that.issueStartedAt,
            _that.visitScheduledAt,
            _that.visitTimeWindow,
            _that.visitReminderSent,
            _that.replacementItems,
            _that.repairScheduledAt,
            _that.repairTimeWindow,
            _that.repairer,
            _that.repairReminderSent,
            _that.completionSummary);
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
            String? unitId,
            String unitNumber,
            String? tenantId,
            String tenantName,
            String title,
            String description,
            String category,
            String? photoPath,
            String? photoBefore,
            String? photoAfter,
            List<String> photos,
            String priority,
            String status,
            String assignedTo,
            String assignedToName,
            String? vendorId,
            double estimatedCost,
            double actualCost,
            double vendorCost,
            DateTime? date,
            DateTime? createdAt,
            DateTime? slaDueDate,
            int rating,
            String? ratingFeedback,
            String responsibleParty,
            bool paymentRequired,
            String paymentStatus,
            String? tenancyId,
            List<TicketStatusHistoryEntry> statusHistory,
            List<String> affectedAreas,
            DateTime? issueStartedAt,
            DateTime? visitScheduledAt,
            String visitTimeWindow,
            bool visitReminderSent,
            List<String> replacementItems,
            DateTime? repairScheduledAt,
            String repairTimeWindow,
            String repairer,
            bool repairReminderSent,
            String completionSummary)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Ticket() when $default != null:
        return $default(
            _that.id,
            _that.unitId,
            _that.unitNumber,
            _that.tenantId,
            _that.tenantName,
            _that.title,
            _that.description,
            _that.category,
            _that.photoPath,
            _that.photoBefore,
            _that.photoAfter,
            _that.photos,
            _that.priority,
            _that.status,
            _that.assignedTo,
            _that.assignedToName,
            _that.vendorId,
            _that.estimatedCost,
            _that.actualCost,
            _that.vendorCost,
            _that.date,
            _that.createdAt,
            _that.slaDueDate,
            _that.rating,
            _that.ratingFeedback,
            _that.responsibleParty,
            _that.paymentRequired,
            _that.paymentStatus,
            _that.tenancyId,
            _that.statusHistory,
            _that.affectedAreas,
            _that.issueStartedAt,
            _that.visitScheduledAt,
            _that.visitTimeWindow,
            _that.visitReminderSent,
            _that.replacementItems,
            _that.repairScheduledAt,
            _that.repairTimeWindow,
            _that.repairer,
            _that.repairReminderSent,
            _that.completionSummary);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Ticket extends Ticket {
  const _Ticket(
      {this.id = '',
      this.unitId,
      this.unitNumber = 'Unit 1',
      this.tenantId,
      this.tenantName = 'Juan Dela Cruz',
      this.title = '',
      this.description = '',
      this.category = 'General',
      this.photoPath,
      this.photoBefore,
      this.photoAfter,
      List<String> photos = const [],
      this.priority = 'Med',
      this.status = 'Schedule Visit',
      this.assignedTo = 'Alex Rivera (Plumbing & HVAC)',
      this.assignedToName = 'Alex Rivera (Plumbing & HVAC)',
      this.vendorId,
      this.estimatedCost = 0.0,
      this.actualCost = 0.0,
      this.vendorCost = 0.0,
      this.date,
      this.createdAt,
      this.slaDueDate,
      this.rating = 0,
      this.ratingFeedback,
      this.responsibleParty = 'Landlord',
      this.paymentRequired = false,
      this.paymentStatus = 'Not Required',
      this.tenancyId,
      List<TicketStatusHistoryEntry> statusHistory = const [],
      List<String> affectedAreas = const [],
      this.issueStartedAt,
      this.visitScheduledAt,
      this.visitTimeWindow = '',
      this.visitReminderSent = false,
      List<String> replacementItems = const [],
      this.repairScheduledAt,
      this.repairTimeWindow = '',
      this.repairer = '',
      this.repairReminderSent = false,
      this.completionSummary = ''})
      : _photos = photos,
        _statusHistory = statusHistory,
        _affectedAreas = affectedAreas,
        _replacementItems = replacementItems,
        super._();
  factory _Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  final String? unitId;
  @override
  @JsonKey()
  final String unitNumber;
  @override
  final String? tenantId;
  @override
  @JsonKey()
  final String tenantName;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String category;
  @override
  final String? photoPath;
  @override
  final String? photoBefore;
  @override
  final String? photoAfter;
  final List<String> _photos;
  @override
  @JsonKey()
  List<String> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  @JsonKey()
  final String priority;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final String assignedTo;
  @override
  @JsonKey()
  final String assignedToName;
  @override
  final String? vendorId;
  @override
  @JsonKey()
  final double estimatedCost;
  @override
  @JsonKey()
  final double actualCost;
  @override
  @JsonKey()
  final double vendorCost;
  @override
  final DateTime? date;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? slaDueDate;
  @override
  @JsonKey()
  final int rating;
  @override
  final String? ratingFeedback;
  @override
  @JsonKey()
  final String responsibleParty;
  @override
  @JsonKey()
  final bool paymentRequired;
  @override
  @JsonKey()
  final String paymentStatus;
  @override
  final String? tenancyId;
  final List<TicketStatusHistoryEntry> _statusHistory;
  @override
  @JsonKey()
  List<TicketStatusHistoryEntry> get statusHistory {
    if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusHistory);
  }

  final List<String> _affectedAreas;
  @override
  @JsonKey()
  List<String> get affectedAreas {
    if (_affectedAreas is EqualUnmodifiableListView) return _affectedAreas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_affectedAreas);
  }

  @override
  final DateTime? issueStartedAt;
  @override
  final DateTime? visitScheduledAt;
  @override
  @JsonKey()
  final String visitTimeWindow;
  @override
  @JsonKey()
  final bool visitReminderSent;
  final List<String> _replacementItems;
  @override
  @JsonKey()
  List<String> get replacementItems {
    if (_replacementItems is EqualUnmodifiableListView)
      return _replacementItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replacementItems);
  }

  @override
  final DateTime? repairScheduledAt;
  @override
  @JsonKey()
  final String repairTimeWindow;
  @override
  @JsonKey()
  final String repairer;
  @override
  @JsonKey()
  final bool repairReminderSent;
  @override
  @JsonKey()
  final String completionSummary;

  /// Create a copy of Ticket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TicketCopyWith<_Ticket> get copyWith =>
      __$TicketCopyWithImpl<_Ticket>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TicketToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Ticket &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.unitNumber, unitNumber) ||
                other.unitNumber == unitNumber) &&
            (identical(other.tenantId, tenantId) ||
                other.tenantId == tenantId) &&
            (identical(other.tenantName, tenantName) ||
                other.tenantName == tenantName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.photoPath, photoPath) ||
                other.photoPath == photoPath) &&
            (identical(other.photoBefore, photoBefore) ||
                other.photoBefore == photoBefore) &&
            (identical(other.photoAfter, photoAfter) ||
                other.photoAfter == photoAfter) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.assignedToName, assignedToName) ||
                other.assignedToName == assignedToName) &&
            (identical(other.vendorId, vendorId) ||
                other.vendorId == vendorId) &&
            (identical(other.estimatedCost, estimatedCost) ||
                other.estimatedCost == estimatedCost) &&
            (identical(other.actualCost, actualCost) ||
                other.actualCost == actualCost) &&
            (identical(other.vendorCost, vendorCost) ||
                other.vendorCost == vendorCost) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.slaDueDate, slaDueDate) ||
                other.slaDueDate == slaDueDate) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.ratingFeedback, ratingFeedback) ||
                other.ratingFeedback == ratingFeedback) &&
            (identical(other.responsibleParty, responsibleParty) ||
                other.responsibleParty == responsibleParty) &&
            (identical(other.paymentRequired, paymentRequired) ||
                other.paymentRequired == paymentRequired) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.tenancyId, tenancyId) ||
                other.tenancyId == tenancyId) &&
            const DeepCollectionEquality()
                .equals(other._statusHistory, _statusHistory) &&
            const DeepCollectionEquality()
                .equals(other._affectedAreas, _affectedAreas) &&
            (identical(other.issueStartedAt, issueStartedAt) ||
                other.issueStartedAt == issueStartedAt) &&
            (identical(other.visitScheduledAt, visitScheduledAt) ||
                other.visitScheduledAt == visitScheduledAt) &&
            (identical(other.visitTimeWindow, visitTimeWindow) ||
                other.visitTimeWindow == visitTimeWindow) &&
            (identical(other.visitReminderSent, visitReminderSent) ||
                other.visitReminderSent == visitReminderSent) &&
            const DeepCollectionEquality()
                .equals(other._replacementItems, _replacementItems) &&
            (identical(other.repairScheduledAt, repairScheduledAt) ||
                other.repairScheduledAt == repairScheduledAt) &&
            (identical(other.repairTimeWindow, repairTimeWindow) ||
                other.repairTimeWindow == repairTimeWindow) &&
            (identical(other.repairer, repairer) ||
                other.repairer == repairer) &&
            (identical(other.repairReminderSent, repairReminderSent) ||
                other.repairReminderSent == repairReminderSent) &&
            (identical(other.completionSummary, completionSummary) ||
                other.completionSummary == completionSummary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        unitId,
        unitNumber,
        tenantId,
        tenantName,
        title,
        description,
        category,
        photoPath,
        photoBefore,
        photoAfter,
        const DeepCollectionEquality().hash(_photos),
        priority,
        status,
        assignedTo,
        assignedToName,
        vendorId,
        estimatedCost,
        actualCost,
        vendorCost,
        date,
        createdAt,
        slaDueDate,
        rating,
        ratingFeedback,
        responsibleParty,
        paymentRequired,
        paymentStatus,
        tenancyId,
        const DeepCollectionEquality().hash(_statusHistory),
        const DeepCollectionEquality().hash(_affectedAreas),
        issueStartedAt,
        visitScheduledAt,
        visitTimeWindow,
        visitReminderSent,
        const DeepCollectionEquality().hash(_replacementItems),
        repairScheduledAt,
        repairTimeWindow,
        repairer,
        repairReminderSent,
        completionSummary
      ]);

  @override
  String toString() {
    return 'Ticket(id: $id, unitId: $unitId, unitNumber: $unitNumber, tenantId: $tenantId, tenantName: $tenantName, title: $title, description: $description, category: $category, photoPath: $photoPath, photoBefore: $photoBefore, photoAfter: $photoAfter, photos: $photos, priority: $priority, status: $status, assignedTo: $assignedTo, assignedToName: $assignedToName, vendorId: $vendorId, estimatedCost: $estimatedCost, actualCost: $actualCost, vendorCost: $vendorCost, date: $date, createdAt: $createdAt, slaDueDate: $slaDueDate, rating: $rating, ratingFeedback: $ratingFeedback, responsibleParty: $responsibleParty, paymentRequired: $paymentRequired, paymentStatus: $paymentStatus, tenancyId: $tenancyId, statusHistory: $statusHistory, affectedAreas: $affectedAreas, issueStartedAt: $issueStartedAt, visitScheduledAt: $visitScheduledAt, visitTimeWindow: $visitTimeWindow, visitReminderSent: $visitReminderSent, replacementItems: $replacementItems, repairScheduledAt: $repairScheduledAt, repairTimeWindow: $repairTimeWindow, repairer: $repairer, repairReminderSent: $repairReminderSent, completionSummary: $completionSummary)';
  }
}

/// @nodoc
abstract mixin class _$TicketCopyWith<$Res> implements $TicketCopyWith<$Res> {
  factory _$TicketCopyWith(_Ticket value, $Res Function(_Ticket) _then) =
      __$TicketCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String? unitId,
      String unitNumber,
      String? tenantId,
      String tenantName,
      String title,
      String description,
      String category,
      String? photoPath,
      String? photoBefore,
      String? photoAfter,
      List<String> photos,
      String priority,
      String status,
      String assignedTo,
      String assignedToName,
      String? vendorId,
      double estimatedCost,
      double actualCost,
      double vendorCost,
      DateTime? date,
      DateTime? createdAt,
      DateTime? slaDueDate,
      int rating,
      String? ratingFeedback,
      String responsibleParty,
      bool paymentRequired,
      String paymentStatus,
      String? tenancyId,
      List<TicketStatusHistoryEntry> statusHistory,
      List<String> affectedAreas,
      DateTime? issueStartedAt,
      DateTime? visitScheduledAt,
      String visitTimeWindow,
      bool visitReminderSent,
      List<String> replacementItems,
      DateTime? repairScheduledAt,
      String repairTimeWindow,
      String repairer,
      bool repairReminderSent,
      String completionSummary});
}

/// @nodoc
class __$TicketCopyWithImpl<$Res> implements _$TicketCopyWith<$Res> {
  __$TicketCopyWithImpl(this._self, this._then);

  final _Ticket _self;
  final $Res Function(_Ticket) _then;

  /// Create a copy of Ticket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? unitId = freezed,
    Object? unitNumber = null,
    Object? tenantId = freezed,
    Object? tenantName = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? photoPath = freezed,
    Object? photoBefore = freezed,
    Object? photoAfter = freezed,
    Object? photos = null,
    Object? priority = null,
    Object? status = null,
    Object? assignedTo = null,
    Object? assignedToName = null,
    Object? vendorId = freezed,
    Object? estimatedCost = null,
    Object? actualCost = null,
    Object? vendorCost = null,
    Object? date = freezed,
    Object? createdAt = freezed,
    Object? slaDueDate = freezed,
    Object? rating = null,
    Object? ratingFeedback = freezed,
    Object? responsibleParty = null,
    Object? paymentRequired = null,
    Object? paymentStatus = null,
    Object? tenancyId = freezed,
    Object? statusHistory = null,
    Object? affectedAreas = null,
    Object? issueStartedAt = freezed,
    Object? visitScheduledAt = freezed,
    Object? visitTimeWindow = null,
    Object? visitReminderSent = null,
    Object? replacementItems = null,
    Object? repairScheduledAt = freezed,
    Object? repairTimeWindow = null,
    Object? repairer = null,
    Object? repairReminderSent = null,
    Object? completionSummary = null,
  }) {
    return _then(_Ticket(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: freezed == unitId
          ? _self.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String?,
      unitNumber: null == unitNumber
          ? _self.unitNumber
          : unitNumber // ignore: cast_nullable_to_non_nullable
              as String,
      tenantId: freezed == tenantId
          ? _self.tenantId
          : tenantId // ignore: cast_nullable_to_non_nullable
              as String?,
      tenantName: null == tenantName
          ? _self.tenantName
          : tenantName // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      photoPath: freezed == photoPath
          ? _self.photoPath
          : photoPath // ignore: cast_nullable_to_non_nullable
              as String?,
      photoBefore: freezed == photoBefore
          ? _self.photoBefore
          : photoBefore // ignore: cast_nullable_to_non_nullable
              as String?,
      photoAfter: freezed == photoAfter
          ? _self.photoAfter
          : photoAfter // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _self._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      assignedTo: null == assignedTo
          ? _self.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as String,
      assignedToName: null == assignedToName
          ? _self.assignedToName
          : assignedToName // ignore: cast_nullable_to_non_nullable
              as String,
      vendorId: freezed == vendorId
          ? _self.vendorId
          : vendorId // ignore: cast_nullable_to_non_nullable
              as String?,
      estimatedCost: null == estimatedCost
          ? _self.estimatedCost
          : estimatedCost // ignore: cast_nullable_to_non_nullable
              as double,
      actualCost: null == actualCost
          ? _self.actualCost
          : actualCost // ignore: cast_nullable_to_non_nullable
              as double,
      vendorCost: null == vendorCost
          ? _self.vendorCost
          : vendorCost // ignore: cast_nullable_to_non_nullable
              as double,
      date: freezed == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      slaDueDate: freezed == slaDueDate
          ? _self.slaDueDate
          : slaDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      rating: null == rating
          ? _self.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      ratingFeedback: freezed == ratingFeedback
          ? _self.ratingFeedback
          : ratingFeedback // ignore: cast_nullable_to_non_nullable
              as String?,
      responsibleParty: null == responsibleParty
          ? _self.responsibleParty
          : responsibleParty // ignore: cast_nullable_to_non_nullable
              as String,
      paymentRequired: null == paymentRequired
          ? _self.paymentRequired
          : paymentRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      paymentStatus: null == paymentStatus
          ? _self.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      tenancyId: freezed == tenancyId
          ? _self.tenancyId
          : tenancyId // ignore: cast_nullable_to_non_nullable
              as String?,
      statusHistory: null == statusHistory
          ? _self._statusHistory
          : statusHistory // ignore: cast_nullable_to_non_nullable
              as List<TicketStatusHistoryEntry>,
      affectedAreas: null == affectedAreas
          ? _self._affectedAreas
          : affectedAreas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      issueStartedAt: freezed == issueStartedAt
          ? _self.issueStartedAt
          : issueStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      visitScheduledAt: freezed == visitScheduledAt
          ? _self.visitScheduledAt
          : visitScheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      visitTimeWindow: null == visitTimeWindow
          ? _self.visitTimeWindow
          : visitTimeWindow // ignore: cast_nullable_to_non_nullable
              as String,
      visitReminderSent: null == visitReminderSent
          ? _self.visitReminderSent
          : visitReminderSent // ignore: cast_nullable_to_non_nullable
              as bool,
      replacementItems: null == replacementItems
          ? _self._replacementItems
          : replacementItems // ignore: cast_nullable_to_non_nullable
              as List<String>,
      repairScheduledAt: freezed == repairScheduledAt
          ? _self.repairScheduledAt
          : repairScheduledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      repairTimeWindow: null == repairTimeWindow
          ? _self.repairTimeWindow
          : repairTimeWindow // ignore: cast_nullable_to_non_nullable
              as String,
      repairer: null == repairer
          ? _self.repairer
          : repairer // ignore: cast_nullable_to_non_nullable
              as String,
      repairReminderSent: null == repairReminderSent
          ? _self.repairReminderSent
          : repairReminderSent // ignore: cast_nullable_to_non_nullable
              as bool,
      completionSummary: null == completionSummary
          ? _self.completionSummary
          : completionSummary // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
