import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../network/result.dart';
import '../../models/models.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<Result<List<Map<String, dynamic>>>> loadCollectionResult(
      String name) async {
    try {
      final snapshot = await _firestore.collection(name).get();
      final docs = snapshot.docs
          .map((document) => {'id': document.id, ...document.data()})
          .toList();
      return Result.success(docs);
    } catch (e) {
      debugPrint('⚠️ Firestore loadCollection [$name]: $e');
      return Result.failure('Failed to load collection $name', e);
    }
  }

  Future<List<Map<String, dynamic>>> loadCollection(String name) async {
    final result = await loadCollectionResult(name);
    return result.dataOrNull ?? [];
  }

  Stream<List<Map<String, dynamic>>> collectionStream(String name) {
    return _firestore.collection(name).snapshots().map((snapshot) {
      return snapshot.docs
          .map((document) => {'id': document.id, ...document.data()})
          .toList();
    }).handleError((error) {
      debugPrint('❌ Firestore collectionStream error [$name]: $error');
      return <Map<String, dynamic>>[];
    });
  }

  Future<Result<void>> upsertDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(collection)
          .doc(id)
          .set(data, SetOptions(merge: true));
      return Result.success(null);
    } catch (e) {
      debugPrint('❌ Firestore upsertDocument error [$collection/$id]: $e');
      return Result.failure('Failed to save document $id in $collection', e);
    }
  }

  Future<Result<void>> deleteDocument(String collection, String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
      return Result.success(null);
    } catch (e) {
      debugPrint('❌ Firestore deleteDocument error [$collection/$id]: $e');
      return Result.failure('Failed to delete document $id in $collection', e);
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> loadCoreData() async {
    final collections = <String, List<Map<String, dynamic>>>{};
    for (final name in ['units', 'tenants', 'payments', 'maintenanceTickets']) {
      collections[name] = await loadCollection(name);
    }
    return collections;
  }

  static double number(Object? value, [double fallback = 0]) {
    return value is num ? value.toDouble() : fallback;
  }

  static int integer(Object? value, [int fallback = 0]) {
    return value is num ? value.toInt() : fallback;
  }

  static DateTime date(Object? value, [DateTime? fallback]) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? (fallback ?? DateTime.now());
    }
    return fallback ?? DateTime.now();
  }

  static String text(Object? value, [String fallback = '']) {
    return value is String && value.isNotEmpty ? value : fallback;
  }

  static List<String> strings(Object? value) {
    if (value is! Iterable) return const [];
    return value.whereType<String>().toList();
  }

  Unit unitFromMap(Map<String, dynamic> data) {
    final images = strings(data['images']);
    return Unit(
      id: text(data['id']),
      name: text(data['name'], text(data['title'], 'Unit')),
      title: text(data['title'], text(data['name'], 'Unit')),
      unitNumber: text(data['unitNumber'], text(data['name'], 'Unit')),
      floor: text(data['floor'], '1st Floor'),
      location: text(data['location'], 'Main Property'),
      latitude: data['latitude'] != null ? number(data['latitude']) : null,
      longitude: data['longitude'] != null ? number(data['longitude']) : null,
      rent: number(data['rent'], number(data['monthlyRent'])),
      monthlyRent: number(data['monthlyRent'], number(data['rent'])),
      status: text(data['status'], 'Vacant'),
      description: text(data['description']),
      area: number(data['area'], number(data['areaSqm'])),
      areaSqm: number(data['areaSqm'], number(data['area'])),
      bedrooms: integer(data['bedrooms'], 1),
      bathrooms: integer(data['bathrooms'], 1),
      amenities: strings(data['amenities']),
      inclusions: strings(data['inclusions']),
      images: images,
      imageUrl: text(data['imageUrl'], images.firstOrNull ?? ''),
      tenantId: data['tenantId'] as String?,
      tenantName: data['tenantName'] as String?,
      currentTenancyId: data['currentTenancyId'] as String?,
      dueDate: data['dueDate'] == null ? null : date(data['dueDate']),
      rentDueDay: integer(data['rentDueDay'], 5).clamp(1, 31),
      lateFee: number(data['lateFee'], 500).clamp(0, double.infinity),
      vacantDays: integer(data['vacantDays']),
      waterReadingPrev: number(data['waterReadingPrev']),
      waterReadingCurr: number(data['waterReadingCurr']),
      electricReadingPrev: number(data['electricReadingPrev']),
      electricReadingCurr: number(data['electricReadingCurr']),
      leasePdfTitle: data['leasePdfTitle'] as String?,
      isArchived:
          data['isArchived'] is bool ? data['isArchived'] as bool : false,
      detailsCompleted: data['detailsCompleted'] is bool
          ? data['detailsCompleted'] as bool
          : true,
      waterUtilityEnabled: data['waterUtilityEnabled'] is bool
          ? data['waterUtilityEnabled'] as bool
          : true,
      electricityUtilityEnabled: data['electricityUtilityEnabled'] is bool
          ? data['electricityUtilityEnabled'] as bool
          : true,
      waterRateOverride: data['waterRateOverride'] == null
          ? null
          : number(data['waterRateOverride']),
      electricityRateOverride: data['electricityRateOverride'] == null
          ? null
          : number(data['electricityRateOverride']),
      maintenanceAreas: strings(data['maintenanceAreas']).isNotEmpty
          ? strings(data['maintenanceAreas'])
          : const ['Bathroom', 'Bedroom', 'Indoor Area', 'Outdoor Area'],
    );
  }

  Tenant tenantFromMap(Map<String, dynamic> data) {
    List<ReminderLog> logs = const [];
    if (data['reminderLogs'] is List) {
      logs = (data['reminderLogs'] as List)
          .map((item) {
            if (item is Map<String, dynamic>) {
              return ReminderLog.fromJson(item);
            }
            return null;
          })
          .whereType<ReminderLog>()
          .toList();
    }

    return Tenant(
      id: text(data['id']),
      name: text(data['name'], 'Tenant'),
      email: text(data['email']),
      phone: text(data['phone'], text(data['contactNumber'])),
      contactNumber: text(data['contactNumber'], text(data['phone'])),
      address: text(data['address']),
      referral: text(data['referral']),
      unitId: text(data['unitId']),
      unitNumber: text(data['unitNumber'], 'Unassigned'),
      monthlyRent: number(data['monthlyRent']),
      leaseStart: date(data['leaseStart']),
      leaseEnd: date(data['leaseEnd']),
      dueDate: date(data['dueDate']),
      balance: number(data['balance']),
      status: text(data['status'], 'Active'),
      isArchived:
          data['isArchived'] is bool ? data['isArchived'] as bool : false,
      avatarUrl: data['avatarUrl'] as String?,
      currentTenancyId: data['currentTenancyId'] as String?,
      messengerHandle: data['messengerHandle'] as String?,
      reminderLogs: logs,
    );
  }

  PaymentData paymentFromMap(Map<String, dynamic> data) {
    return PaymentData(
      id: text(data['id']),
      month: text(data['month'], 'Oct'),
      amount: number(data['amount']),
      method: text(data['method'], text(data['paymentMethod'], 'GCash')),
      paymentMethod: text(data['paymentMethod'], text(data['method'], 'GCash')),
      date: date(data['date'], date(data['paymentDate'])),
      paymentDate: date(data['paymentDate'], date(data['date'])),
      status: text(data['status'], 'Paid'),
      unitId: text(data['unitId'], 'u1'),
      referenceNumber: text(data['referenceNumber']),
      baseRent: number(data['baseRent']),
      waterBill: number(data['waterBill']),
      electricBill: number(data['electricBill']),
      lateFee: number(data['lateFee']),
      otherCharge: number(data['otherCharge']),
      tenantName: text(data['tenantName'], 'Juan Dela Cruz'),
      unitNumber: text(data['unitNumber'], 'Unit 1'),
      tenantId: text(data['tenantId']),
      tenancyId: data['tenancyId'] as String?,
      proofImageUrl: text(data['proofImageUrl']),
      remarks: data['remarks'] as String?,
      declineReason: data['declineReason'] as String?,
      transactionType: text(data['transactionType'], 'Rent'),
      ticketId: data['ticketId'] as String?,
    );
  }

  Ticket ticketFromMap(Map<String, dynamic> data) {
    return Ticket(
      id: text(data['id']),
      unitId: data['unitId'] as String?,
      unitNumber: text(data['unitNumber'], 'Unit 1'),
      tenantId: data['tenantId'] as String?,
      tenantName: text(data['tenantName'], 'Juan Dela Cruz'),
      title: text(data['title'], 'Issue'),
      description: text(data['description']),
      category: text(data['category'], 'General'),
      photoPath: data['photoPath'] as String?,
      photoBefore: data['photoBefore'] as String?,
      photoAfter: data['photoAfter'] as String?,
      photos: strings(data['photos']),
      priority: text(data['priority'], 'Med'),
      status: text(data['status'], 'Schedule Visit'),
      assignedTo:
          text(data['assignedTo'], text(data['assignedToName'], 'Alex Rivera')),
      assignedToName:
          text(data['assignedToName'], text(data['assignedTo'], 'Alex Rivera')),
      vendorId: data['vendorId'] as String?,
      estimatedCost: number(data['estimatedCost']),
      actualCost: number(data['actualCost'], number(data['vendorCost'])),
      vendorCost: number(data['vendorCost'], number(data['actualCost'])),
      date: date(data['date'], date(data['createdAt'])),
      createdAt: date(data['createdAt'], date(data['date'])),
      slaDueDate: date(data['slaDueDate']),
      rating: integer(data['rating']),
      ratingFeedback: data['ratingFeedback'] as String?,
      responsibleParty: text(data['responsibleParty'], 'Landlord'),
      paymentRequired: data['paymentRequired'] is bool
          ? data['paymentRequired'] as bool
          : false,
      paymentStatus: text(data['paymentStatus'], 'Not Required'),
      tenancyId: data['tenancyId'] as String?,
      affectedAreas: strings(data['affectedAreas']),
      issueStartedAt:
          data['issueStartedAt'] == null ? null : date(data['issueStartedAt']),
      visitScheduledAt: data['visitScheduledAt'] == null
          ? null
          : date(data['visitScheduledAt']),
      visitTimeWindow: text(data['visitTimeWindow']),
      visitReminderSent: data['visitReminderSent'] is bool
          ? data['visitReminderSent'] as bool
          : false,
      replacementItems: strings(data['replacementItems']),
      repairScheduledAt: data['repairScheduledAt'] == null
          ? null
          : date(data['repairScheduledAt']),
      repairTimeWindow: text(data['repairTimeWindow']),
      repairer: text(data['repairer']),
      repairReminderSent: data['repairReminderSent'] is bool
          ? data['repairReminderSent'] as bool
          : false,
      completionSummary: text(data['completionSummary']),
    );
  }
}
