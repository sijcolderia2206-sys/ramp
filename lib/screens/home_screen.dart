import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/providers.dart';
import '../core/theme/ramp_theme.dart';
import '../core/widgets/core_widgets.dart';
import '../core/services/persistence_queue.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../features/calendar/widgets/calendar_bottom_sheet.dart';
import '../features/calendar/providers/calendar_providers.dart';
import 'ai_assistant.dart';
import 'payments_screen.dart';
import 'tenant_profile.dart';
import 'tenant_form.dart';
import 'ticket_form.dart';
import 'unit_detail.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _CalendarEventCard extends StatelessWidget {
  const _CalendarEventCard({
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.details,
    required this.actions,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;
  final String details;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RampCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(14, 6, 10, 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                details,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarAction extends StatelessWidget {
  const _CalendarAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  Future<bool> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showNotificationArchive(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final archived = ref
              .watch(notificationProvider)
              .where((notification) => notification.isArchived)
              .toList();
          return SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.7,
            child: SafeArea(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Archived Notifications'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ),
                  Expanded(
                    child: archived.isEmpty
                        ? const RampEmptyState(
                            title: 'No Archived Notifications',
                            description:
                                'Archived notifications will remain available here.',
                            icon: Icons.archive_outlined,
                          )
                        : ListView.builder(
                            itemCount: archived.length,
                            itemBuilder: (_, index) {
                              final notification = archived[index];
                              return ListTile(
                                title: Text(notification.message),
                                subtitle: Text(
                                    _formatTimeAgo(notification.timestamp)),
                                trailing: IconButton(
                                  tooltip: 'Restore notification',
                                  icon: const Icon(Icons.unarchive_outlined),
                                  onPressed: () => ref
                                      .read(notificationProvider.notifier)
                                      .restoreNotification(notification.id),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  DateTime _rentDateForMonth(
      Tenant tenant, List<Unit> units, DateTime monthReference) {
    final unit = units.where((u) => u.id == tenant.unitId).firstOrNull;
    final requestedDay = unit?.rentDueDay ?? tenant.dueDate.day;
    final lastDay =
        DateTime(monthReference.year, monthReference.month + 1, 0).day;
    return DateTime(monthReference.year, monthReference.month,
        requestedDay.clamp(1, lastDay).toInt());
  }

  String _getInitials(String name) {
    final cleanName = name.replaceAll(RegExp(r"[^\w\s]"), '').trim();
    final parts = cleanName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'EM';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _closeCalendarAndOpen(
    BuildContext pageContext,
    String route, {
    Tenant? tenant,
    Ticket? ticket,
  }) {
    if (Navigator.canPop(pageContext)) {
      Navigator.pop(pageContext);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (route == '/payments/new') {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
              builder: (_) => PaymentsScreen(initialTenant: tenant)),
        );
      } else if (route == '/maintenance/new') {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const TicketFormScreen()),
        );
      } else if (route == '/payments') {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const PaymentsScreen()),
        );
      } else if (route == '/maintenance') {
        if (ticket != null) {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => TicketFormScreen(existingTicket: ticket),
            ),
          );
        } else {
          ref.read(bottomNavIndexProvider.notifier).state = 3;
        }
      } else if (route == '/tenants') {
        if (tenant != null) {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => TenantProfileScreen(tenantId: tenant.id),
            ),
          );
        } else {
          ref.read(bottomNavIndexProvider.notifier).state = 2;
        }
      } else if (route == '/units') {
        ref.read(bottomNavIndexProvider.notifier).state = 1;
      } else if (route.startsWith('/units/')) {
        final unitId = route.substring('/units/'.length);
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => UnitDetailScreen(unitId: unitId)),
        );
      }
    });
  }

  void _openRecentActivity(ActivityLog activity) {
    final text = '${activity.title} ${activity.description}'.toLowerCase();
    if (text.contains('payment') || text.contains('late fee')) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => const PaymentsScreen()),
      );
    } else if (text.contains('maintenance') || text.contains('ticket')) {
      ref.read(bottomNavIndexProvider.notifier).state = 3;
    } else if (text.contains('tenant')) {
      ref.read(bottomNavIndexProvider.notifier).state = 2;
    } else if (text.contains('unit') || text.contains('property')) {
      ref.read(bottomNavIndexProvider.notifier).state = 1;
    }
  }

  // --- CALENDAR IN BOTTOM SHEET ---
  void _showCalendarBottomSheet(BuildContext context) {
    showRampCalendarBottomSheet(context);
  }



  Widget _buildFinancialMetricRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : RampColors.slate,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAiAssistantBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiAssistantBottomSheet(),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final notifications = ref
                .watch(notificationProvider)
                .where((notification) => !notification.isArchived)
                .toList();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Notifications',
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: notifications.any((n) => !n.isRead)
                              ? () => ref
                                  .read(notificationProvider.notifier)
                                  .markAllAsRead()
                              : null,
                          child: const Text('Mark all read'),
                        ),
                        IconButton(
                          tooltip: 'View archived notifications',
                          icon: const Icon(Icons.archive_outlined),
                          onPressed: () {
                            Navigator.pop(context);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                _showNotificationArchive(this.context);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: notifications.isEmpty
                          ? const RampEmptyState(
                              title: 'All Caught Up!',
                              description:
                                  'You have no new system notifications at this time.',
                              icon: Icons.notifications_none_rounded,
                            )
                          : ListView.builder(
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                final notif = notifications[index];
                                return ListTile(
                                  tileColor: notif.isRead
                                      ? null
                                      : RampColors.softBlueTint,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    child: const Icon(Icons.notifications,
                                        color: Colors.white, size: 20),
                                  ),
                                  title: Text(
                                    notif.message,
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    _formatTimeAgo(notif.timestamp),
                                    style: GoogleFonts.poppins(
                                        fontSize: 11, color: Colors.grey),
                                  ),
                                  trailing: IconButton(
                                    tooltip: 'Archive notification',
                                    icon: const Icon(Icons.archive_outlined),
                                    onPressed: () async {
                                      final confirmed = await _confirmAction(
                                        context,
                                        title: 'Archive notification?',
                                        message:
                                            'This notification will be removed from your active list.',
                                        confirmLabel: 'ARCHIVE',
                                      );
                                      if (confirmed && context.mounted) {
                                        ref
                                            .read(notificationProvider.notifier)
                                            .archiveNotification(notif.id);
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    ref
                                        .read(notificationProvider.notifier)
                                        .markAsRead(notif.id);
                                    Navigator.pop(context);
                                    if (notif.message
                                        .toLowerCase()
                                        .contains('ticket')) {
                                      ref
                                          .read(bottomNavIndexProvider.notifier)
                                          .state = 3;
                                    } else if (notif.message
                                        .toLowerCase()
                                        .contains('lease')) {
                                      ref
                                          .read(bottomNavIndexProvider.notifier)
                                          .state = 1;
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tickets = ref.watch(ticketProvider);
    final payments = ref.watch(paymentProvider);
    final events = ref.watch(eventProvider);
    final activities = ref.watch(activityProvider);
    final upcomingDues = ref.watch(upcomingDues7DaysProvider);
    final landlordProfile = ref.watch(landlordProfileProvider);

    // KPI Values via Riverpod Computed Providers
    final activeTenants = ref
        .watch(tenantProvider)
        .where((tenant) => !tenant.isArchived)
        .toList();
    final now = DateTime.now();
    final paidTenantKeys = payments
        .where((payment) =>
            payment.isRent &&
            payment.status.toLowerCase() == 'paid' &&
            payment.date.year == now.year &&
            payment.date.month == now.month)
        .map((payment) => '${payment.tenantName}|${payment.unitNumber}')
        .toSet();
    final paidTenantCount = activeTenants
        .where((tenant) =>
            paidTenantKeys.contains('${tenant.name}|${tenant.unitNumber}') ||
            payments.any((p) =>
                p.tenantId == tenant.id &&
                p.isRent &&
                p.isPaid &&
                p.date.year == now.year &&
                p.date.month == now.month))
        .length;
    final collectionProgress = activeTenants.isEmpty
        ? 0.0
        : (paidTenantCount / activeTenants.length).clamp(0.0, 1.0);
    final collectionPercent = (collectionProgress * 100).round();

    final totalRevenueCollected = ref.watch(kpiTotalRevenueProvider);
    final netOperatingIncomeVal = ref.watch(netOperatingIncomeProvider);
    final pendingDuesVal = activeTenants.fold<double>(
      0.0,
      (sum, tenant) => sum + (tenant.balance > 0 ? tenant.balance : 0.0),
    );
    final targetRevenueVal = totalRevenueCollected + pendingDuesVal;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showAiAssistantBottomSheet(context),
        backgroundColor: Color(0xFF0D6EFD),
        elevation: 4,
        icon: Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(
          'RAMP AI',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await hydratePersistentAppData(ref);
        },
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding:
                    EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. TOP HEADER: "Good morning" + Profile Avatar + Notification Bell with Badge ---
                    AdaptiveRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Clickable Profile Avatar
                            GestureDetector(
                              onTap: () {
                                // Navigate to Profile tab (Index 4)
                                ref
                                    .read(bottomNavIndexProvider.notifier)
                                    .state = 4;
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x1A0D6EFD),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitials(landlordProfile.name),
                                    style: GoogleFonts.poppins(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good morning',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  landlordProfile.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Notification Bell Icon with Badge
                        Consumer(
                          builder: (context, ref, child) {
                            final notifs = ref.watch(notificationProvider);
                            final unreadCount = notifs
                                .where((n) => !n.isRead && !n.isArchived)
                                .length;
                            return Material(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () => _showNotifications(context),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x0A000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Badge(
                                    label: Text(
                                      unreadCount.toString(),
                                      style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    isLabelVisible: unreadCount > 0,
                                    backgroundColor: Color(0xFF0D6EFD),
                                    child: Icon(
                                      Icons.notifications_none_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // --- OFFLINE SYNC BANNER ---
                    ValueListenableBuilder<PersistenceQueueState>(
                      valueListenable: PersistenceQueue.instance,
                      builder: (context, writes, _) {
                        if (writes.pending.isEmpty && !writes.isSyncing && writes.lastError == null) {
                          return const SizedBox.shrink();
                        }
                        final hasFailure = writes.lastError != null;
                        final pendingCount = writes.pending.length;
                        return Column(
                          children: [
                            RampCard(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              backgroundColor: isDark ? const Color(0xFF342B1D) : const Color(0xFFFFF3E0),
                              borderColor: isDark ? const Color(0xFF8A6A35) : const Color(0xFFF59E0B),
                              child: Row(
                                children: [
                                  Icon(
                                    hasFailure ? Icons.error_outline_rounded : Icons.cloud_sync_rounded,
                                    color: hasFailure ? RampColors.danger : const Color(0xFFF59E0B),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hasFailure ? 'Sync Error' : (writes.isSyncing ? 'Syncing Changes...' : 'Pending Sync Queue'),
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: isDark ? const Color(0xFFD5B477) : const Color(0xFFB45309),
                                          ),
                                        ),
                                        Text(
                                          hasFailure
                                              ? writes.lastError!
                                              : '$pendingCount action(s) stored locally. Will sync when reconnected.',
                                          style: GoogleFonts.poppins(fontSize: 11, color: RampColors.mutedText),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.sync_rounded, size: 20, color: Color(0xFFF59E0B)),
                                    tooltip: 'Retry Sync',
                                    onPressed: () {
                                      PersistenceQueue.instance.retry();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),

                    // --- 2. HERO REVENUE OVERVIEW ---
                    // --- 2. DEDICATED FINANCIAL OVERVIEW CARD (IMAGE 1 INSPIRATION) ---
                    RampCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE8F1FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.pie_chart_outline_rounded,
                                        color: RampColors.primary, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Financial Overview',
                                        style: GoogleFonts.poppins(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        'Monthly Rent Collection Performance',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: RampColors.mutedText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Gauge & Metrics Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Circular Collection Meter (Left)
                              SizedBox(
                                width: 115,
                                height: 115,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox.expand(
                                      child: CircularProgressIndicator(
                                        value: collectionProgress,
                                        strokeWidth: 12,
                                        backgroundColor: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0),
                                        color: const Color(0xFF0D6EFD),
                                        strokeCap: StrokeCap.round,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '$collectionPercent%',
                                            style: GoogleFonts.poppins(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Collected',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: RampColors.mutedText,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 18),

                              // Stacked Metrics (Right)
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildFinancialMetricRow(
                                      icon: Icons.gps_fixed_rounded,
                                      iconColor: const Color(0xFF6B7280),
                                      label: 'Target',
                                      value: _currencyFormat.format(targetRevenueVal),
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildFinancialMetricRow(
                                      icon: Icons.check_circle_rounded,
                                      iconColor: const Color(0xFF10B981),
                                      label: 'Collected',
                                      value: _currencyFormat.format(totalRevenueCollected),
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildFinancialMetricRow(
                                      icon: Icons.pending_actions_rounded,
                                      iconColor: pendingDuesVal > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                      label: 'Pending',
                                      value: _currencyFormat.format(pendingDuesVal),
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildFinancialMetricRow(
                                      icon: Icons.trending_up_rounded,
                                      iconColor: const Color(0xFF0D6EFD),
                                      label: 'Net NOI',
                                      value: _currencyFormat.format(netOperatingIncomeVal),
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Bottom Deadline Strip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_outlined, size: 18, color: RampColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Next Due Cycle: ${DateFormat("MMM dd, yyyy").format(DateTime(now.year, now.month + 1, 5))}',
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Primary Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D6EFD),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'View Full Ledger',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                              onPressed: () => Navigator.of(context, rootNavigator: true)
                                  .push(MaterialPageRoute(builder: (_) => const PaymentsScreen())),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 3. QUICK MANAGEMENT ACTIONS ---
                    Text(
                      'Manage',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 14),
                    AdaptiveRow(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ActionButton(
                            icon: Icons.add_card_rounded,
                            label: 'Payments',
                            color: Color(0xFF10B981),
                            backgroundColor: Color(0xFFE6F4EA),
                            onTap: () => showRecordPaymentSheet(context, ref),
                          ),
                        ),
                        Expanded(
                          child: ActionButton(
                            icon: Icons.handyman_rounded,
                            label: 'Maintenance',
                            color: Color(0xFFF59E0B),
                            backgroundColor: Color(0xFFFEF3C7),
                            onTap: () => Navigator.of(context,
                                    rootNavigator: true)
                                .push(MaterialPageRoute(
                                    builder: (_) => const TicketFormScreen())),
                          ),
                        ),
                        Expanded(
                          child: ActionButton(
                            icon: Icons.person_add_rounded,
                            label: 'Add Tenant',
                            color: Color(0xFF0D6EFD),
                            backgroundColor: Color(0xFFE8F1FF),
                            onTap: () => Navigator.of(context,
                                    rootNavigator: true)
                                .push(MaterialPageRoute(
                                    builder: (_) => const TenantFormScreen())),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // --- 4. CALENDAR / SCHEDULE HEADER WITH TAP ICON -> BOTTOM SHEET ---
                    RampCard(
                      borderColor: Colors.transparent,
                      boxShadow: const [],
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    // TAP ICON = Opens full interactive calendar
                                    InkWell(
                                      onTap: () =>
                                          showRampCalendarBottomSheet(context),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? const Color(0xFF202B3D)
                                              : const Color(0xFFE8F1FF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.calendar_month_rounded,
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? const Color(0xFF7896CC)
                                              : const Color(0xFF0D6EFD),
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Upcoming Schedule',
                                            style: GoogleFonts.poppins(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                          Text(
                                            'Tap to open interactive calendar',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // View Calendar Button
                              OutlinedButton.icon(
                                onPressed: () =>
                                    showRampCalendarBottomSheet(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0D6EFD),
                                  side: const BorderSide(color: Color(0xFF0D6EFD)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                ),
                                icon: const Icon(Icons.date_range_rounded, size: 16),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Calendar',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 12),

                          // Category Color Dots Legend
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _CalendarLegendDot(color: const Color(0xFF0D6EFD), label: 'Rent Dues'),
                                const SizedBox(width: 12),
                                _CalendarLegendDot(color: const Color(0xFFF59E0B), label: 'Maintenance'),
                                const SizedBox(width: 12),
                                _CalendarLegendDot(color: const Color(0xFF0EA5E9), label: 'Inspections'),
                                const SizedBox(width: 12),
                                _CalendarLegendDot(color: const Color(0xFF10B981), label: 'Custom'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Upcoming Schedule Events
                          Consumer(
                            builder: (context, ref, _) {
                              final allEvents = ref.watch(unifiedCalendarEventsProvider);
                              final nowAtMidnight = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

                              // Filter upcoming and overdue events
                              final upcoming = allEvents.where((e) {
                                final eDate = DateTime(e.date.year, e.date.month, e.date.day);
                                return !eDate.isBefore(nowAtMidnight) || e.isOverdue;
                              }).toList()
                                ..sort((a, b) => a.date.compareTo(b.date));

                              if (upcoming.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Text(
                                    'No upcoming scheduled events.',
                                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                                  ),
                                );
                              }

                              return Column(
                                children: upcoming.take(4).map((e) {
                                  final isDark = Theme.of(context).brightness == Brightness.dark;
                                  return InkWell(
                                    onTap: () => showRampCalendarBottomSheet(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF181A1C) : const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: e.isOverdue
                                              ? Colors.red.withValues(alpha: 0.3)
                                              : Colors.transparent,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: e.isOverdue ? Colors.red : e.categoryColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e.title,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  e.categoryLabel,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: e.categoryColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              DateFormat('MMM dd').format(e.date),
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: e.categoryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // --- 5. SECTION: [Alert Icon] Due in 7 Days ---
                    AdaptiveRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(0xFFFEF3C7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFD97706),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Due Soon',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F1FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${upcomingDues.length} Dues',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D6EFD),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    if (upcomingDues.isEmpty)
                      RampEmptyState(
                        title: 'No Rent Dues Pending',
                        description:
                            'All tenant accounts are in good standing with no upcoming dues in the next 7 days.',
                        icon: Icons.task_alt_rounded,
                        iconColor: RampColors.success,
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      )
                    else
                      Column(
                        children: upcomingDues.map((item) {
                          final isOverdue = item.isOverdue;
                          return RampCard(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(14),
                            child: InkWell(
                              onTap: () {
                                final tenant = ref
                                    .read(tenantProvider)
                                    .where((t) => t.id == item.tenantId)
                                    .firstOrNull;
                                if (tenant != null) {
                                  Navigator.of(context, rootNavigator: true)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (_) => TenantProfileScreen(
                                          tenantId: tenant.id),
                                    ),
                                  );
                                } else {
                                  ref
                                      .read(bottomNavIndexProvider.notifier)
                                      .state = 2;
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isOverdue
                                        ? Color(0x20EF4444)
                                        : Color(0x2010B981),
                                    child: Icon(
                                      isOverdue
                                          ? Icons.warning_amber_rounded
                                          : Icons.schedule_rounded,
                                      color: isOverdue
                                          ? Color(0xFFEF4444)
                                          : Color(0xFF10B981),
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.tenantName,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          '${item.unitNumber} • ${item.dueStatusText}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: isOverdue
                                                ? Color(0xFFEF4444)
                                                : Colors.grey[700],
                                            fontWeight: isOverdue
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        item.formattedAmount,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF10B981)),
                                      ),
                                      SizedBox(height: 4),
                                      InkWell(
                                        onTap: () {
                                          final tenant = ref
                                              .read(tenantProvider)
                                              .where((tenant) =>
                                                  tenant.id == item.tenantId)
                                              .firstOrNull;
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .push(MaterialPageRoute(
                                                  builder: (_) =>
                                                      PaymentsScreen(
                                                          initialTenant: tenant,
                                                          openPaymentForm:
                                                              true)));
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF0D6EFD),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Pay ₱',
                                            style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                    SizedBox(height: 24),

                    // --- 6. SECTION: [Clock Icon] Recent Activity ---
                    AdaptiveRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(0xFFE8F1FF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.access_time_filled_rounded,
                                color: Color(0xFF0D6EFD),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Recent Activity',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${activities.length} logged',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    RampCard(
                      padding: EdgeInsets.all(14.0),
                      child: activities.isEmpty
                          ? RampEmptyState(
                              title: 'No Activity Logged',
                              description:
                                  'Audit logs and recent tenant activities will automatically appear here.',
                              icon: Icons.history_rounded,
                              padding: EdgeInsets.all(16),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  activities.length > 5 ? 5 : activities.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 16, color: Color(0xFFE2E8F0)),
                              itemBuilder: (context, index) {
                                final act = activities[index];
                                return InkWell(
                                  onTap: () => _openRecentActivity(act),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: act.iconBgColor,
                                          child: Icon(act.icon,
                                              size: 18,
                                              color: Color(0xFF0D6EFD)),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                act.title,
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                act.description,
                                                style: GoogleFonts.poppins(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              act.timeAgo,
                                              style: GoogleFonts.poppins(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                  fontSize: 11),
                                            ),
                                            const SizedBox(height: 4),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              size: 18,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fade(duration: 500.ms).scale(delay: 100.ms);
  }
}

class _CalendarLegendDot extends StatelessWidget {
  const _CalendarLegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
