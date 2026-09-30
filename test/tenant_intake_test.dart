import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramp/core/state/ramp_state.dart';
import 'package:ramp/screens/tenant_form.dart';
import 'package:ramp/screens/tenant_profile.dart';
import 'package:ramp/screens/tenants_screen.dart';

void main() {
  testWidgets('new tenant intake creates an unassigned contact-only profile',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: TenantFormScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Home Address'), findsOneWidget);
    expect(find.text('Phone Number (SMS)'), findsOneWidget);
    expect(
        find.text('Facebook / Messenger Username (optional)'), findsOneWidget);
    expect(find.text('Referral (optional)'), findsOneWidget);
    expect(find.text('Assigned Unit (optional)'), findsNothing);
    expect(find.text('Monthly Rent (₱)'), findsNothing);
    expect(find.text('Lease Start'), findsNothing);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Nicole Test Tenant');
    await tester.enterText(fields.at(1), '123 Rizal Street, Pagsanjan');
    await tester.enterText(fields.at(2), '09171234567');
    await tester.enterText(fields.at(3), 'nicole.tenant');
    await tester.enterText(fields.at(4), 'Referred by Maria');
    await tester.ensureVisible(find.text('CREATE UNASSIGNED PROFILE'));
    await tester.tap(find.text('CREATE UNASSIGNED PROFILE'));
    await tester.pumpAndSettle();

    final tenant = container
        .read(tenantProvider)
        .singleWhere((item) => item.name == 'Nicole Test Tenant');
    expect(tenant.address, '123 Rizal Street, Pagsanjan');
    expect(tenant.phone, '09171234567');
    expect(tenant.messengerHandle, 'nicole.tenant');
    expect(tenant.referral, 'Referred by Maria');
    expect(tenant.isAssigned, isFalse);
    expect(tenant.unitId, isEmpty);
    expect(tenant.unitNumber, 'Unassigned');
    expect(tenant.monthlyRent, 0);
    expect(tenant.status, 'Unassigned');
  });

  testWidgets('tenant directory opens the canonical tenant profile',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final tenant = container.read(tenantProvider).first;

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: TenantsScreen()),
    ));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    await tester.tap(find.text(tenant.name).first);
    await tester.pumpAndSettle();

    expect(find.byType(TenantProfileScreen), findsOneWidget);
    expect(find.text('${tenant.name} Profile'), findsOneWidget);
  });
}
