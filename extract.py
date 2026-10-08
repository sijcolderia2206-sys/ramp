import os, re

def extract_and_replace(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    patterns = {
        'unit': r'(class UnitNotifier extends StateNotifier<List<Unit>> \{.*?\n\})\s*final unitProvider =[\s\n]*StateNotifierProvider<UnitNotifier, List<Unit>>\([\s\n]*\(ref\) => UnitNotifier\(ref\),?[\s\n]*\);',
        'tenant': r'(class TenantNotifier extends StateNotifier<List<Tenant>> \{.*?\n\})\s*final tenantProvider =[\s\n]*StateNotifierProvider<TenantNotifier, List<Tenant>>\([\s\n]*\(ref\) => TenantNotifier\(ref\),?[\s\n]*\);',
        'ticket': r'(class TicketNotifier extends StateNotifier<List<Ticket>> \{.*?\n\})\s*final ticketProvider =[\s\n]*StateNotifierProvider<TicketNotifier, List<Ticket>>\([\s\n]*\(ref\) => TicketNotifier\(ref\),?[\s\n]*\);',
        'payment': r'(class PaymentNotifier extends StateNotifier<List<PaymentData>> \{.*?\n\})\s*final paymentProvider =[\s\n]*StateNotifierProvider<PaymentNotifier, List<PaymentData>>\([\s\n]*\(ref\) => PaymentNotifier\(ref\),?[\s\n]*\);',
        'expense': r'(class ExpenseNotifier extends StateNotifier<List<ExpenseItem>> \{.*?\n\})\s*final expenseProvider =[\s\n]*StateNotifierProvider<ExpenseNotifier, List<ExpenseItem>>\([\s\n]*\(ref\) => ExpenseNotifier\(ref\),?[\s\n]*\);',
        'activity': r'(class ActivityLog \{.*?\n\})\s*(class ActivityNotifier extends StateNotifier<List<ActivityLog>> \{.*?\n\})\s*final activityProvider =[\s\n]*StateNotifierProvider<ActivityNotifier, List<ActivityLog>>\([\s\n]*\(ref\) => ActivityNotifier\(\),?[\s\n]*\);',
        'utility_rate': r'(class UtilityRateState \{.*?\n\})\s*(class UtilityRateNotifier extends StateNotifier<UtilityRateState> \{.*?\n\})\s*final utilityRateProvider =[\s\n]*StateNotifierProvider<UtilityRateNotifier, UtilityRateState>\([\s\n]*\(ref\) => UtilityRateNotifier\(ref\),?[\s\n]*\);',
        'tenant_document': r'(class TenantDocumentNotifier extends StateNotifier<List<TenantDocument>> \{.*?\n\})\s*final tenantDocumentProvider =[\s\n]*StateNotifierProvider<TenantDocumentNotifier, List<TenantDocument>>\([\s\n]*\(ref\) => TenantDocumentNotifier\(\),?[\s\n]*\);',
        'event': r'(class EventNotifier extends StateNotifier<List<AppEvent>> \{.*?\n\})\s*final eventProvider =[\s\n]*StateNotifierProvider<EventNotifier, List<AppEvent>>\([\s\n]*\(ref\) => EventNotifier\(ref\),?[\s\n]*\);',
        'announcement': r'(class AnnouncementNotifier extends StateNotifier<List<Announcement>> \{.*?\n\})\s*final announcementProvider =[\s\n]*StateNotifierProvider<AnnouncementNotifier, List<Announcement>>\([\s\n]*\(ref\) => AnnouncementNotifier\(ref\),?[\s\n]*\);',
        'notification': r'(class NotificationNotifier extends StateNotifier<List<AppNotification>> \{.*?\n\})\s*final notificationProvider =[\s\n]*StateNotifierProvider<NotificationNotifier, List<AppNotification>>\([\s\n]*\(ref\) => NotificationNotifier\(ref\),?[\s\n]*\);'
    }

    imports = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../services/audit_service.dart';
import '../services/persistence_queue.dart';
import 'providers.dart';
"""

    extracted = []

    for name, pattern_str in patterns.items():
        pattern = re.compile(pattern_str, re.DOTALL)
        match = pattern.search(content)
        if match:
            extracted_code = match.group(0)

            new_file_path = f'lib/providers/{name}_provider.dart'
            with open(new_file_path, 'w', encoding='utf-8') as f:
                f.write(imports + '\n' + extracted_code + '\n')
            print(f'Extracted {name} to {new_file_path}')

            content = content.replace(extracted_code, '')
            extracted.append(f"export '{name}_provider.dart';")
        else:
            print(f'Failed to extract {name}')

    if extracted:
        export_statements = '\n'.join(extracted) + '\n'
        content = export_statements + content

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print('Updated ramp_state.dart')

extract_and_replace('lib/core/state/ramp_state.dart')
