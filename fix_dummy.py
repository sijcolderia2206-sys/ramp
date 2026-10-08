import os, re
with open('lib/core/state/ramp_state.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Instead of regex matching the entire class body which fails because of nested braces,
# we'll use a simple parser that counts braces to extract class definitions.
def extract_class(content, class_name):
    start_str = f"class {class_name} "
    start_idx = content.find(start_str)
    if start_idx == -1: return None, content

    # Find first opening brace
    brace_start = content.find('{', start_idx)
    if brace_start == -1: return None, content

    brace_count = 1
    idx = brace_start + 1
    while brace_count > 0 and idx < len(content):
        if content[idx] == '{': brace_count += 1
        elif content[idx] == '}': brace_count -= 1
        idx += 1

    class_code = content[start_idx:idx]
    return class_code, content.replace(class_code, '')

def extract_provider(content, provider_name):
    start_str = f"final {provider_name} ="
    start_idx = content.find(start_str)
    if start_idx == -1:
        start_str = f"final {provider_name}\n"
        start_idx = content.find(start_str)
        if start_idx == -1: return None, content

    end_idx = content.find(');', start_idx)
    if end_idx == -1: return None, content

    provider_code = content[start_idx:end_idx + 2]
    return provider_code, content.replace(provider_code, '')

pairs = {
    'unit': ('UnitNotifier', 'unitProvider'),
    'tenant': ('TenantNotifier', 'tenantProvider'),
    'ticket': ('TicketNotifier', 'ticketProvider'),
    'payment': ('PaymentNotifier', 'paymentProvider'),
    'expense': ('ExpenseNotifier', 'expenseProvider'),
    'utility_rate': ('UtilityRateNotifier', 'utilityRateProvider'),
    'tenant_document': ('TenantDocumentNotifier', 'tenantDocumentProvider'),
    'event': ('EventNotifier', 'eventProvider'),
    'announcement': ('AnnouncementNotifier', 'announcementProvider'),
    'notification': ('NotificationNotifier', 'notificationProvider'),
}

imports = """import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../services/audit_service.dart';
import '../services/persistence_queue.dart';
import 'providers.dart';
"""

extracted = []
for name, (class_name, provider_name) in pairs.items():
    class_code, content = extract_class(content, class_name)
    provider_code, content = extract_provider(content, provider_name)

    # Special cases
    extra_code = ""
    if name == 'utility_rate':
        rate_state_code, content = extract_class(content, 'UtilityRateState')
        if rate_state_code: extra_code = rate_state_code + "\n\n"

    if class_code and provider_code:
        full_code = imports + "\n" + extra_code + class_code + "\n\n" + provider_code + "\n"
        with open(f'lib/providers/{name}_provider.dart', 'w', encoding='utf-8') as f:
            f.write(full_code)
        extracted.append(f"export '{name}_provider.dart';")
        print(f"Extracted {name}")
    else:
        print(f"Failed {name}: class={bool(class_code)}, provider={bool(provider_code)}")

# Activity has two classes
act_log_code, content = extract_class(content, 'ActivityLog')
act_not_code, content = extract_class(content, 'ActivityNotifier')
act_prov_code, content = extract_provider(content, 'activityProvider')

if act_not_code and act_prov_code:
    full_code = imports + "\n" + (act_log_code or "") + "\n\n" + act_not_code + "\n\n" + act_prov_code + "\n"
    with open('lib/providers/activity_provider.dart', 'w', encoding='utf-8') as f:
        f.write(full_code)
    extracted.append("export 'activity_provider.dart';")
    print("Extracted activity")
else:
    print("Failed activity")

if extracted:
    export_statements = '\n'.join(extracted) + '\n'
    content = export_statements + content
    with open('lib/core/state/ramp_state.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print('Updated ramp_state.dart')
