import re
import os

with open('lib/core/state/ramp_state.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# 1. Rename private functions to public line by line
for i in range(len(lines)):
    lines[i] = lines[i].replace('void _saveUnit', 'void saveUnit')
    lines[i] = lines[i].replace('_saveUnit(', 'saveUnit(')
    lines[i] = lines[i].replace('void _saveTenant(', 'void saveTenant(')
    lines[i] = lines[i].replace('_saveTenant(', 'saveTenant(')
    lines[i] = lines[i].replace('void _saveTicket', 'void saveTicket')
    lines[i] = lines[i].replace('_saveTicket(', 'saveTicket(')
    lines[i] = lines[i].replace('void _savePayment', 'void savePayment')
    lines[i] = lines[i].replace('_savePayment(', 'savePayment(')
    lines[i] = lines[i].replace('void _saveAnnouncement', 'void saveAnnouncement')
    lines[i] = lines[i].replace('_saveAnnouncement(', 'saveAnnouncement(')
    lines[i] = lines[i].replace('void _saveNotification', 'void saveNotification')
    lines[i] = lines[i].replace('_saveNotification(', 'saveNotification(')
    lines[i] = lines[i].replace('void _saveExpense', 'void saveExpense')
    lines[i] = lines[i].replace('_saveExpense(', 'saveExpense(')
    lines[i] = lines[i].replace('void _saveTenantDocument', 'void saveTenantDocument')
    lines[i] = lines[i].replace('_saveTenantDocument(', 'saveTenantDocument(')
    lines[i] = lines[i].replace('void _persist', 'void persistData')
    lines[i] = lines[i].replace('_persist(', 'persistData(')
    lines[i] = lines[i].replace('void _deletePersisted', 'void deletePersistedData')
    lines[i] = lines[i].replace('_deletePersisted(', 'deletePersistedData(')

def extract_class(start_pattern):
    start = -1
    for i, line in enumerate(lines):
        if re.search(start_pattern, line):
            start = i
            break
    if start == -1: return [], -1, -1

    end = start
    brace_count = 0
    found_brace = False
    for i in range(start, len(lines)):
        line = lines[i]
        brace_count += line.count('{')
        brace_count -= line.count('}')
        if '{' in line: found_brace = True
        if found_brace and brace_count == 0:
            end = i
            break
    return lines[start:end+1], start, end

def extract_variable(start_pattern):
    start = -1
    for i, line in enumerate(lines):
        if line.startswith(start_pattern):
            start = i
            break
    if start == -1: return [], -1, -1

    end = start
    for i in range(start, len(lines)):
        if ';' in lines[i]:
            end = i
            break
    return lines[start:end+1], start, end

def write_provider_file(filename, chunks):
    os.makedirs('lib/providers', exist_ok=True)
    with open(f'lib/providers/{filename}', 'w', encoding='utf-8') as f:
        f.write("import 'package:flutter/material.dart';\n")
        f.write("import 'package:flutter_riverpod/flutter_riverpod.dart';\n")
        f.write("import 'package:intl/intl.dart';\n")
        f.write("import 'package:ramp/models/models.dart';\n")
        f.write("import 'package:ramp/core/services/audit_service.dart';\n")
        f.write("import 'package:ramp/core/state/ramp_state.dart';\n")

        if filename != 'activity_provider.dart':
            f.write("import 'package:ramp/providers/activity_provider.dart';\n")

        f.write('\n')
        for chunk in chunks:
            f.writelines(chunk)
            f.write('\n')

# Activity
c1, s1, e1 = extract_class('^class ActivityLog')
c2, s2, e2 = extract_class('^class ActivityNotifier')
v1, vs1, ve1 = extract_variable('final activityProvider')
write_provider_file('activity_provider.dart', [c1, c2, v1])

# Unit
c3, s3, e3 = extract_class('^class UnitNotifier')
v2, vs2, ve2 = extract_variable('final unitProvider')
write_provider_file('unit_provider.dart', [c3, v2])

# Tenant
c4, s4, e4 = extract_class('^class TenantNotifier')
v3, vs3, ve3 = extract_variable('final tenantProvider')
write_provider_file('tenant_provider.dart', [c4, v3])

# Ticket
c5, s5, e5 = extract_class('^class TicketNotifier')
v4, vs4, ve4 = extract_variable('final ticketProvider')
write_provider_file('ticket_provider.dart', [c5, v4])

# Payment
c6, s6, e6 = extract_class('^class PaymentNotifier')
v5, vs5, ve5 = extract_variable('final paymentProvider')
write_provider_file('payment_provider.dart', [c6, v5])

# Expense
c7, s7, e7 = extract_class('^class ExpenseNotifier')
v6, vs6, ve6 = extract_variable('final expenseProvider')
write_provider_file('expense_provider.dart', [c7, v6])

# UtilityRate
c8, s8, e8 = extract_class('^class UtilityRateState')
c9, s9, e9 = extract_class('^class UtilityRateNotifier')
v7, vs7, ve7 = extract_variable('final utilityRateProvider')
write_provider_file('utility_rate_provider.dart', [c8, c9, v7])

# TenantDocument
c10, s10, e10 = extract_class('^class TenantDocumentNotifier')
v8, vs8, ve8 = extract_variable('final tenantDocumentProvider')
write_provider_file('tenant_document_provider.dart', [c10, v8])

# Event
c11, s11, e11 = extract_class('^class EventNotifier')
v9, vs9, ve9 = extract_variable('final eventProvider')
write_provider_file('event_provider.dart', [c11, v9])

ranges_to_remove = [
    (s1, e1), (s2, e2), (vs1, ve1),
    (s3, e3), (vs2, ve2),
    (s4, e4), (vs3, ve3),
    (s5, e5), (vs4, ve4),
    (s6, e6), (vs5, ve5),
    (s7, e7), (vs6, ve6),
    (s8, e8), (s9, e9), (vs7, ve7),
    (s10, e10), (vs8, ve8),
    (s11, e11), (vs9, ve9),
]

ranges_to_remove.sort(key=lambda x: x[0], reverse=True)

for start, end in ranges_to_remove:
    if start != -1 and end != -1:
        del lines[start:end+1]

exports = [
    "import '../../providers/activity_provider.dart';\n",
    "export '../../providers/activity_provider.dart';\n",
    "import '../../providers/unit_provider.dart';\n",
    "export '../../providers/unit_provider.dart';\n",
    "import '../../providers/tenant_provider.dart';\n",
    "export '../../providers/tenant_provider.dart';\n",
    "import '../../providers/ticket_provider.dart';\n",
    "export '../../providers/ticket_provider.dart';\n",
    "import '../../providers/payment_provider.dart';\n",
    "export '../../providers/payment_provider.dart';\n",
    "import '../../providers/expense_provider.dart';\n",
    "export '../../providers/expense_provider.dart';\n",
    "import '../../providers/utility_rate_provider.dart';\n",
    "export '../../providers/utility_rate_provider.dart';\n",
    "import '../../providers/tenant_document_provider.dart';\n",
    "export '../../providers/tenant_document_provider.dart';\n",
    "import '../../providers/event_provider.dart';\n",
    "export '../../providers/event_provider.dart';\n"
]

lines = exports + lines

with open('lib/core/state/ramp_state.dart', 'w', encoding='utf-8') as f:
    f.writelines(lines)
