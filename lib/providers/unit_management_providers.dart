// lib/providers/unit_management_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/unit_model.dart';
import 'landlord_providers.dart';

enum UnitFilter { all, occupied, vacant, maintenance }

/// Replaces legacy StateProvider for filtering with modern Notifier
class UnitFilterStateNotifier extends Notifier<UnitFilter> {
  @override
  UnitFilter build() => UnitFilter.all;

  void updateFilter(UnitFilter filter) => state = filter;
}

final unitFilterStateProvider = NotifierProvider<UnitFilterStateNotifier, UnitFilter>(
  () => UnitFilterStateNotifier(),
);

/// Replaces legacy StateProvider for search with modern Notifier
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  () => SearchQueryNotifier(),
);

/// Derived provider enforcing client-side filtering without extra DB reads
final filteredUnitsProvider = Provider<List<RentalUnit>>((ref) {
  final rawUnits = ref.watch(unitsProvider);
  final filter = ref.watch(unitFilterStateProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return rawUnits.where((unit) {
    // 1. Filter Enum Check
    bool matchesFilter = true;
    if (filter == UnitFilter.occupied && unit.status != 'Occupied') matchesFilter = false;
    if (filter == UnitFilter.vacant && unit.status != 'Vacant') matchesFilter = false;
    if (filter == UnitFilter.maintenance && unit.status != 'Under Maintenance') matchesFilter = false;
    
    if (!matchesFilter) return false;

    // 2. Search Query Check
    if (query.isEmpty) return true;
    final matchesNumber = unit.unitNumber.toLowerCase().contains(query);
    final matchesType = unit.title.toLowerCase().contains(query);
    final matchesLocation = unit.location.toLowerCase().contains(query);
    final matchesTenant = unit.tenantName?.toLowerCase().contains(query) ?? false;

    return matchesNumber || matchesType || matchesLocation || matchesTenant;
  }).toList();
});
