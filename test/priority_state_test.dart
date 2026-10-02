import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ramp/core/state/ramp_state.dart';

void main() {
  test('unit billing policy survives an edit', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final original = container.read(unitProvider).first;
    container.read(unitProvider.notifier).updateUnit(
          original.copyWith(rentDueDay: 17, lateFee: 275),
        );

    final updated = container.read(unitProvider).first;
    expect(updated.rentDueDay, 17);
    expect(updated.lateFee, 275);
    expect(
      container.read(effectiveUnitBillingPolicyProvider(updated.id)),
      (dueDay: 17, lateFee: 275),
    );
  });

  test('utility rates are adjustable, logged, and used for unit charges', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(utilityRateProvider.notifier);

    notifier.updateRate(
      utility: 'Water',
      newRate: 51.25,
      note: 'Supplier adjustment',
      effectiveAt: DateTime(2026, 9, 1),
    );
    notifier.updateRate(
      utility: 'Electricity',
      newRate: 13.75,
      note: 'September billing rate',
      effectiveAt: DateTime(2026, 9, 2),
    );

    final rates = container.read(utilityRateProvider);
    expect(rates.waterRate, 51.25);
    expect(rates.electricityRate, 13.75);
    expect(rates.history, hasLength(2));
    expect(rates.history.first.note, 'September billing rate');
    expect(notifier.rateAt('Water', DateTime(2026, 9, 15)), 51.25);
    expect(notifier.rateAt('Water', DateTime(2026, 8, 15)), 45.0);

    final unit = container.read(unitProvider).first;
    expect(
      unit.utilityBill(
        waterRate: rates.waterRate,
        electricityRate: rates.electricityRate,
      ),
      closeTo(
        unit.waterUsage * 51.25 + unit.electricUsage * 13.75,
        0.001,
      ),
    );
  });

  test('new unit intake starts vacant with only its name and location', () {
    final unit = Unit(
      id: 'unit_basic',
      name: 'Unit 12',
      location: 'North Building, Second Floor',
      rent: 0,
      area: 0,
      status: 'Vacant',
      inclusions: const [],
      detailsCompleted: false,
      waterUtilityEnabled: false,
      electricityUtilityEnabled: false,
    );

    expect(unit.name, 'Unit 12');
    expect(unit.location, 'North Building, Second Floor');
    expect(unit.status, 'Vacant');
    expect(unit.detailsCompleted, isFalse);
    expect(unit.utilityBill(waterRate: 45, electricityRate: 12), 0);
  });

  test('unit utility settings support master rates and individual overrides',
      () {
    final unit = Unit(
      id: 'unit_rates',
      name: 'Unit Rates',
      location: 'Annex',
      rent: 8000,
      area: 24,
      status: 'Vacant',
      inclusions: const [],
      waterReadingPrev: 10,
      waterReadingCurr: 13,
      electricReadingPrev: 20,
      electricReadingCurr: 25,
      waterUtilityEnabled: true,
      electricityUtilityEnabled: false,
      waterRateOverride: 52,
    );

    expect(unit.effectiveWaterRate(45), 52);
    expect(unit.effectiveElectricityRate(12), 12);
    expect(unit.utilityBill(waterRate: 45, electricityRate: 12), 156);

    final usingMaster = unit.copyWith(
      waterRateOverride: null,
      electricityUtilityEnabled: true,
    );
    expect(usingMaster.effectiveWaterRate(48), 48);
    expect(usingMaster.utilityBill(waterRate: 48, electricityRate: 13), 209);
  });

  test('all seeded units include a location', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container
          .read(unitProvider)
          .every((unit) => unit.location.trim().isNotEmpty),
      isTrue,
    );
  });

  test('tenant profiles support create, update, archive, restore, and delete',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(tenantProvider.notifier);
    final tenant = Tenant(
      id: 'tenant_test',
      name: 'Draft Tenant',
      unitId: 'u5',
      unitNumber: 'Unit 5',
      monthlyRent: 9500,
    );

    notifier.addTenant(tenant);
    expect(container.read(tenantProvider).any((item) => item.id == tenant.id),
        isTrue);

    notifier.updateTenant(tenant.copyWith(name: 'Updated Tenant'));
    expect(
      container
          .read(tenantProvider)
          .singleWhere((item) => item.id == tenant.id)
          .name,
      'Updated Tenant',
    );

    notifier.archiveTenant(tenant.id);
    expect(
      container
          .read(tenantProvider)
          .singleWhere((item) => item.id == tenant.id)
          .isArchived,
      isTrue,
    );

    notifier.unarchiveTenant(tenant.id);
    expect(
      container
          .read(tenantProvider)
          .singleWhere((item) => item.id == tenant.id)
          .isArchived,
      isFalse,
    );

    notifier.deleteTenant(tenant.id);
    expect(container.read(tenantProvider).any((item) => item.id == tenant.id),
        isFalse);
  });

  test(
      'unassigned tenant intake and unit vacancy preserve assignment integrity',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final intake = Tenant(
      id: 'tenant_intake',
      name: 'Prospective Tenant',
      address: 'Pagsanjan, Laguna',
      phone: '09171234567',
      referral: 'Walk-in referral',
      status: 'Unassigned',
    );
    container.read(tenantProvider.notifier).addTenant(intake);
    expect(intake.isAssigned, isFalse);
    expect(intake.balanceStatusText, 'UNASSIGNED');

    final occupied =
        container.read(unitProvider).firstWhere((u) => u.isOccupied);
    container.read(unitProvider.notifier).markVacant(occupied.id);
    final vacant = container
        .read(unitProvider)
        .singleWhere((unit) => unit.id == occupied.id);
    expect(vacant.status, 'Vacant');
    expect(vacant.tenantId, isNull);
    expect(vacant.tenantName, isNull);
  });

  test('recording a payment updates both the ledger and tenant balance', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final tenant = container.read(tenantProvider).first;
    final startingBalance = tenant.balance;

    container.read(paymentProvider.notifier).addPayment(
          PaymentData(
            month: 'September 2026',
            amount: 1000,
            unitId: tenant.unitId,
            unitNumber: tenant.unitNumber,
            tenantName: tenant.name,
            waterBill: 0,
            electricBill: 0,
          ),
        );

    expect(container.read(paymentProvider).first.amount, 1000);
    expect(
      container
          .read(tenantProvider)
          .singleWhere((item) => item.id == tenant.id)
          .balance,
      (startingBalance - 1000).clamp(0, double.infinity),
    );
  });
}
