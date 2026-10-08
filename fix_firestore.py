with open('lib/core/state/ramp_state.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("import '../services/firestore_service.dart';", "// import '../services/firestore_service.dart';")
content = content.replace("final firestoreService = FirestoreService();", "// final firestoreService = FirestoreService();")

content = content.replace("units.map(firestoreService.unitFromMap).toList()", "units.map((u) => Unit.fromJson(Map<String, dynamic>.from(u))).toList()")
content = content.replace("tenants.map(firestoreService.tenantFromMap).toList()", "tenants.map((t) => Tenant.fromJson(Map<String, dynamic>.from(t))).toList()")
content = content.replace("payments.map(firestoreService.paymentFromMap).toList()", "payments.map((p) => PaymentData.fromJson(Map<String, dynamic>.from(p))).toList()")
content = content.replace("tickets.map(firestoreService.ticketFromMap).toList()", "tickets.map((t) => Ticket.fromJson(Map<String, dynamic>.from(t))).toList()")

content = content.replace("FirestoreService().syncUnit(updated);", "// FirestoreService().syncUnit(updated);")
content = content.replace("FirestoreService().syncTenant(updated);", "// FirestoreService().syncTenant(updated);")
content = content.replace("FirestoreService().syncPayment(payment);", "// FirestoreService().syncPayment(payment);")
content = content.replace("FirestoreService().syncTicket(updated);", "// FirestoreService().syncTicket(updated);")
content = content.replace("FirestoreService().syncExpense(updated);", "// FirestoreService().syncExpense(updated);")
content = content.replace("FirestoreService().syncTenantDocument(updated);", "// FirestoreService().syncTenantDocument(updated);")

content = content.replace("FirestoreService()", "/* FirestoreService() */")

with open('lib/core/state/ramp_state.dart', 'w', encoding='utf-8') as f:
    f.write(content)
