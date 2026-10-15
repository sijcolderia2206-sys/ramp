// lib/screens/landlord/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../theme.dart';
import '../../providers/landlord_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  
  String _timeHorizon = 'Month'; // 'Year', 'Month', 'Today'
  String _selectedCategory = 'All'; // 'All', 'Dues', 'Payments', 'Maintenance'

  List<Map<String, dynamic>> _getEventsForDay(DateTime day, List<Map<String, dynamic>> allEvents) {
    return allEvents.where((e) {
      final date = e['date'] as DateTime;
      return isSameDay(date, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tenants = ref.watch(tenantsProvider);
    final payments = ref.watch(paymentsProvider);
    final tickets = ref.watch(maintenanceTicketsProvider);

    final List<Map<String, dynamic>> allEvents = [];

    // 1. Dues Schedule Events
    for (final t in tenants) {
      allEvents.add({
        'type': 'Dues',
        'title': 'Rent Due: Unit ${t.unitNumber}',
        'subtitle': '${t.name} • ₱${t.monthlyRent.toStringAsFixed(0)}',
        'date': t.dueDate,
        'color': RampTheme.errorRed,
        'icon': Icons.event_busy,
      });
    }

    // 2. Payments Schedule Events
    for (final p in payments) {
      allEvents.add({
        'type': 'Payments',
        'title': 'Payment: Unit ${p.unitNumber ?? "N/A"}',
        'subtitle': '${p.tenantName ?? "Tenant"} • ₱${p.amount.toStringAsFixed(2)} (${p.paymentMethod})',
        'date': p.paymentDate,
        'color': RampTheme.successGreen,
        'icon': Icons.payments,
      });
    }

    // 3. Maintenance Schedule Events
    for (final tk in tickets) {
      allEvents.add({
        'type': 'Maintenance',
        'title': 'Repair Visit: Unit ${tk.unitNumber}',
        'subtitle': '${tk.title} • Priority: ${tk.priority}',
        'date': tk.visitDate ?? tk.createdAt,
        'color': const Color(0xFFFB8C00),
        'icon': Icons.build,
      });
    }

    // Filter events based on Category Chip Selection ('All', 'Dues', 'Payments', 'Maintenance')
    final categoryFilteredEvents = allEvents.where((e) {
      if (_selectedCategory == 'All') return true;
      return e['type'] == _selectedCategory;
    }).toList();

    // Filter events by selected date or time horizon
    final displayedEvents = categoryFilteredEvents.where((e) {
      final date = e['date'] as DateTime;
      if (_timeHorizon == 'Today') {
        final now = DateTime.now();
        return isSameDay(date, now);
      } else if (_timeHorizon == 'Month') {
        if (_selectedDay != null) {
          return isSameDay(date, _selectedDay!);
        }
        return date.year == _focusedDay.year && date.month == _focusedDay.month;
      } else if (_timeHorizon == 'Year') {
        return date.year == _focusedDay.year;
      }
      return true;
    }).toList();

    displayedEvents.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return Scaffold(
      backgroundColor: RampTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Calendar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Controls Section: Time Horizon Buttons & Category Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: RampTheme.spacing16, vertical: 12),
              color: RampTheme.cardBackground,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Time Horizon Filter Buttons with Icons (Year, Month, Today)
                  Row(
                    children: [
                      Expanded(
                        child: _HorizonIconButton(
                          icon: Icons.date_range,
                          label: 'Year',
                          isSelected: _timeHorizon == 'Year',
                          onTap: () {
                            setState(() {
                              _timeHorizon = 'Year';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HorizonIconButton(
                          icon: Icons.calendar_view_month,
                          label: 'Month',
                          isSelected: _timeHorizon == 'Month',
                          onTap: () {
                            setState(() {
                              _timeHorizon = 'Month';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _HorizonIconButton(
                          icon: Icons.today,
                          label: 'Today',
                          isSelected: _timeHorizon == 'Today',
                          onTap: () {
                            setState(() {
                              _timeHorizon = 'Today';
                              _focusedDay = DateTime.now();
                              _selectedDay = DateTime.now();
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 2. Category Filter Chips (All, Dues, Payments, Maintenance)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 'All' Chip comes FIRST
                        _CategoryFilterChip(
                          label: 'All',
                          icon: Icons.grid_view_rounded,
                          color: RampTheme.primaryBlue,
                          isSelected: _selectedCategory == 'All',
                          onSelected: () => setState(() => _selectedCategory = 'All'),
                        ),
                        const SizedBox(width: 8),
                        // 'Dues' Chip
                        _CategoryFilterChip(
                          label: 'Dues',
                          icon: Icons.event_busy,
                          color: RampTheme.errorRed,
                          isSelected: _selectedCategory == 'Dues',
                          onSelected: () => setState(() => _selectedCategory = 'Dues'),
                        ),
                        const SizedBox(width: 8),
                        // 'Payments' Chip
                        _CategoryFilterChip(
                          label: 'Payments',
                          icon: Icons.payments,
                          color: RampTheme.successGreen,
                          isSelected: _selectedCategory == 'Payments',
                          onSelected: () => setState(() => _selectedCategory = 'Payments'),
                        ),
                        const SizedBox(width: 8),
                        // 'Maintenance' Chip
                        _CategoryFilterChip(
                          label: 'Maintenance',
                          icon: Icons.build,
                          color: const Color(0xFFFB8C00),
                          isSelected: _selectedCategory == 'Maintenance',
                          onSelected: () => setState(() => _selectedCategory = 'Maintenance'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // 3. Full Monthly Calendar View
            Container(
              margin: const EdgeInsets.all(RampTheme.spacing16),
              decoration: BoxDecoration(
                color: RampTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: RampTheme.standardShadow,
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                eventLoader: (day) => _getEventsForDay(day, categoryFilteredEvents),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _timeHorizon = 'Month';
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: const BoxDecoration(
                    color: RampTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: RampTheme.primaryBlue.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: RampTheme.warningYellow,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: RampTheme.textPrimary,
                  ),
                  leftChevronIcon: const Icon(Icons.chevron_left, color: RampTheme.primaryBlue),
                  rightChevronIcon: const Icon(Icons.chevron_right, color: RampTheme.primaryBlue),
                ),
              ),
            ),

            // Selected Date / Time Horizon Subheader
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: RampTheme.spacing16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _timeHorizon == 'Today'
                        ? 'Today\'s Schedule (${DateFormat('MMM d, yyyy').format(DateTime.now())})'
                        : _selectedDay != null
                            ? DateFormat('EEEE, MMM d, yyyy').format(_selectedDay!)
                            : DateFormat('MMMM yyyy').format(_focusedDay),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: RampTheme.textPrimary),
                  ),
                  Text(
                    '${displayedEvents.length} Event${displayedEvents.length == 1 ? "" : "s"}',
                    style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 4. Events Schedule List
            displayedEvents.isEmpty
                ? Container(
                    margin: const EdgeInsets.all(RampTheme.spacing16),
                    padding: const EdgeInsets.all(RampTheme.spacing24),
                    decoration: BoxDecoration(
                      color: RampTheme.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: RampTheme.standardShadow,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 40, color: RampTheme.textSecondary),
                          const SizedBox(height: 10),
                          Text(
                            'No schedule events for this selection.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: RampTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: RampTheme.spacing16, vertical: 8),
                    itemCount: displayedEvents.length,
                    itemBuilder: (context, index) {
                      final event = displayedEvents[index];
                      final color = event['color'] as Color;

                      return Container(
                        margin: const EdgeInsets.only(bottom: RampTheme.spacing12),
                        padding: const EdgeInsets.all(RampTheme.spacing16),
                        decoration: BoxDecoration(
                          color: RampTheme.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: RampTheme.standardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                event['icon'] as IconData,
                                color: color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: RampTheme.spacing16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    event['subtitle'] as String,
                                    style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('EEE, MMM d, yyyy').format(event['date'] as DateTime),
                                    style: const TextStyle(fontSize: 11, color: RampTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                event['type'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HELPER WIDGETS
// ============================================================================

class _HorizonIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _HorizonIconButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? RampTheme.primaryBlue : RampTheme.scaffoldBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? RampTheme.primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : RampTheme.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : RampTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onSelected;

  const _CategoryFilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : color,
      ),
      label: Text(label),
      selectedColor: color,
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(
        color: isSelected ? color : color.withValues(alpha: 0.4),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}
