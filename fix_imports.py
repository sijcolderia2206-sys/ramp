import os

providers = [
    'activity_provider.dart', 'unit_provider.dart', 'tenant_provider.dart',
    'ticket_provider.dart', 'payment_provider.dart', 'expense_provider.dart',
    'utility_rate_provider.dart', 'tenant_document_provider.dart', 'event_provider.dart'
]

for p in providers:
    filepath = f'lib/providers/{p}'
    if not os.path.exists(filepath): continue
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    imports = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ramp/models/models.dart';
import 'package:ramp/core/services/audit_service.dart';
import 'package:ramp/core/state/ramp_state.dart';
"""
    if p != 'activity_provider.dart':
        imports += "import 'package:ramp/providers/activity_provider.dart';\n"

    lines = [imports] + lines

    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(lines)
