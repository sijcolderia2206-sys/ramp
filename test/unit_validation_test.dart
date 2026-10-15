import 'package:flutter_test/flutter_test.dart';
import 'package:ramp/core/validators.dart';
import 'package:ramp/models/unit_model.dart';

void main() {
  group('Rental Unit Form Validations', () {
    final existingUnits = [
      const RentalUnit(
        id: 'u1',
        title: 'Unit 101',
        unitNumber: '101',
        monthlyRent: 15000,
      ),
      const RentalUnit(
        id: 'u2',
        title: 'Unit 102',
        unitNumber: '102',
        monthlyRent: 18000,
      ),
    ];

    test('Unit Number - required and length check', () {
      expect(RampValidators.validateUnitNumber('', existingUnits), 'Unit number is required.');
      expect(RampValidators.validateUnitNumber('   ', existingUnits), 'Unit number is required.');
      expect(RampValidators.validateUnitNumber('123456789012345678901', existingUnits), 'Unit number must not exceed 20 characters.');
    });

    test('Unit Number - character check', () {
      expect(
        RampValidators.validateUnitNumber('Unit#101', existingUnits),
        'Unit number can only contain letters, digits, spaces, or hyphens.',
      );
      expect(RampValidators.validateUnitNumber('103-A', existingUnits), isNull);
    });

    test('Unit Number - duplicate check', () {
      expect(
        RampValidators.validateUnitNumber('101', existingUnits),
        'Unit number "101" already exists.',
      );
      expect(
        RampValidators.validateUnitNumber('101', existingUnits, currentUnitId: 'u1'),
        isNull,
      );
      expect(
        RampValidators.validateUnitNumber('103', existingUnits),
        isNull,
      );
    });

    test('Monthly Base Rent - positive number validation', () {
      expect(
        RampValidators.validatePositiveNumber('', 'Monthly Base Rent', required: true),
        'Monthly Base Rent is required.',
      );
      expect(
        RampValidators.validatePositiveNumber('abc', 'Monthly Base Rent'),
        'Please enter a valid number for Monthly Base Rent.',
      );
      expect(
        RampValidators.validatePositiveNumber('-500', 'Monthly Base Rent'),
        'Monthly Base Rent must be at least ₱0.',
      );
      expect(
        RampValidators.validatePositiveNumber('0', 'Monthly Base Rent'),
        'Monthly Base Rent must be at least ₱0.',
      );
      expect(
        RampValidators.validatePositiveNumber('15000', 'Monthly Base Rent'),
        isNull,
      );
    });

    test('Rent Due Day - range check (1-28)', () {
      expect(
        RampValidators.validateRentDueDay(''),
        'Rent Due Day is required (1-28).',
      );
      expect(
        RampValidators.validateRentDueDay('0'),
        'Rent Due Day must be between 1 and 28.',
      );
      expect(
        RampValidators.validateRentDueDay('29'),
        'Rent Due Day must be between 1 and 28.',
      );
      expect(
        RampValidators.validateRentDueDay('5'),
        isNull,
      );
    });

    test('Floor Area - sqm validation', () {
      expect(
        RampValidators.validateFloorArea('-10'),
        'Floor area must be greater than 0 sqm.',
      );
      expect(
        RampValidators.validateFloorArea('0'),
        'Floor area must be greater than 0 sqm.',
      );
      expect(
        RampValidators.validateFloorArea('35.5'),
        isNull,
      );
    });

    test('Non-negative numbers - late fee & meter readings', () {
      expect(
        RampValidators.validateNonNegativeNumber('-50', 'Late Fee'),
        'Late Fee cannot be negative.',
      );
      expect(
        RampValidators.validateNonNegativeNumber('0', 'Late Fee'),
        isNull,
      );
      expect(
        RampValidators.validateNonNegativeNumber('500', 'Late Fee'),
        isNull,
      );
    });

    test('Custom Maintenance Area validation', () {
      final areas = ['Bathroom', 'Bedroom', 'Kitchen'];
      expect(
        RampValidators.validateCustomAreaName('', areas),
        'Area name cannot be empty.',
      );
      expect(
        RampValidators.validateCustomAreaName('Bedroom', areas),
        'Maintenance area "Bedroom" already exists.',
      );
      expect(
        RampValidators.validateCustomAreaName('Balcony', areas),
        isNull,
      );
    });
  });
}
