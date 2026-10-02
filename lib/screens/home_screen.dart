import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../core/theme/ramp_theme.dart';
import '../core/widgets/core_widgets.dart';
import '../core/services/persistence_queue.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../features/calendar/widgets/calendar_bottom_sheet.dart';
import '../features/calendar/providers/calendar_providers.dart';
import '../core/navigation/custom_page_transitions.dart';
import 'ai_assistant.dart';
import 'payments_screen.dart';
import 'payment_form.dart';
import 'tenant_profile.dart';
import 'tenant_form.dart';
import 'ticket_form.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  bool _showAllSchedule = false;
  bool _showAllDueSoon = false;
  bool _showAllActivity = false;

  Widget _buildShowMoreLessButton({
    required bool isExpanded,
    required int remainingCount,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final label = isExpanded
        ? 'Show Less'
        : (remainingCount > 0
            ? 'See More ($remainingCount more)'
            : 'See More');

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B)
              : RampColors.softBlueTint.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: RampColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: RampColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: RampColors.primary,
            ),
          ],
        ),
      ),
    );
  }

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

  String _getInitials(String name) {
    final cleanName = name.replaceAll(RegExp(r"[^\w\s]"), '').trim();
    final parts =
        cleanName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'EM';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(1, 2))
          .toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }



  void _openRecentActivity(ActivityLog activity) {
    final text = '${activity.title} ${activity.description}'.toLowerCase();
    if (text.contains('payment') || text.contains('late fee')) {
      Navigator.of(context, rootNavigator: true).push(
        FadePageRoute(page: const PaymentsScreen()),
      );
    } else if (text.contains('maintenance') || text.contains('ticket')) {
      ref.read(bottomNavIndexProvider.notifier).state = 3;
    } else if (text.contains('tenant')) {
      ref.read(bottomNavIndexProvider.notifier).state = 2;
    } else if (text.contains('unit') || text.contains('property')) {
      ref.read(bottomNavIndexProvider.notifier).state = 1;
    }
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
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

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final hasSpace = label.contains(' ');
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: hasSpace ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingScheduleTab(
      BuildContext context, WidgetRef ref, bool isDark) {
    final allEvents = ref.watch(unifiedCalendarEventsProvider);
    final nowAtMidnight =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final upcoming = allEvents.where((e) {
      final eDate = DateTime(e.date.year, e.date.month, e.date.day);
      final isUpcoming = !eDate.isBefore(nowAtMidnight) || e.isOverdue;
      final isRepairOrNonRent = e.type != 'rent'; // Rent Dues belong to the adjacent "Due Soon" tab
      return isUpcoming && isRepairOrNonRent;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (upcoming.isEmpty) {
      return Center(
        child: Text(
          'No upcoming repair or maintenance schedules.',
          style: GoogleFonts.poppins(color: RampColors.mutedText, fontSize: 13),
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    final hasMoreThanFive = upcoming.length > 5;
    final displayCount =
        (_showAllSchedule || !hasMoreThanFive) ? upcoming.length : 5;
    final totalItemCount = hasMoreThanFive ? displayCount + 1 : displayCount;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: totalItemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (hasMoreThanFive && index == displayCount) {
          return _buildShowMoreLessButton(
            isExpanded: _showAllSchedule,
            remainingCount: upcoming.length - 5,
            isDark: isDark,
            onTap: () {
              setState(() {
                _showAllSchedule = !_showAllSchedule;
              });
            },
          );
        }

        final e = upcoming[index];
        return ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: 48), // Minimum 48px height
          child: InkWell(
            onTap: () => showRampCalendarBottomSheet(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF181A1C) : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(14),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
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
                            fontSize: 10.5,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(
            duration: (200 + index * 40).ms); // Individual FadeIn per item
      },
    );
  }

  Widget _buildDueSoonTab(BuildContext context, WidgetRef ref,
      List<dynamic> upcomingDues, bool isDark) {
    if (upcomingDues.isEmpty) {
      return Center(
        child: Text(
          'No upcoming rent dues pending.',
          style: GoogleFonts.poppins(color: RampColors.mutedText, fontSize: 13),
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    final hasMoreThanFive = upcomingDues.length > 5;
    final displayCount =
        (_showAllDueSoon || !hasMoreThanFive) ? upcomingDues.length : 5;
    final totalItemCount = hasMoreThanFive ? displayCount + 1 : displayCount;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: totalItemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (hasMoreThanFive && index == displayCount) {
          return _buildShowMoreLessButton(
            isExpanded: _showAllDueSoon,
            remainingCount: upcomingDues.length - 5,
            isDark: isDark,
            onTap: () {
              setState(() {
                _showAllDueSoon = !_showAllDueSoon;
              });
            },
          );
        }

        final item = upcomingDues[index];
        final isOverdue = item.isOverdue;

        return ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: 48), // Minimum 48px height
          child: InkWell(
            onTap: () {
              final tenant = ref
                  .read(tenantProvider)
                  .where((t) => t.id == item.tenantId)
                  .firstOrNull;
              if (tenant != null) {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => TenantProfileScreen(tenantId: tenant.id),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF181A1C) : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isOverdue
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isOverdue
                        ? const Color(0x20EF4444)
                        : const Color(0x2010B981),
                    child: Icon(
                      isOverdue
                          ? Icons.warning_amber_outlined
                          : Icons.schedule_outlined,
                      color: isOverdue
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.tenantName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${item.unitNumber} • ${item.dueStatusText}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: isOverdue
                                ? const Color(0xFFEF4444)
                                : RampColors.mutedText,
                            fontWeight:
                                isOverdue ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.formattedAmount,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: const Color(0xFF10B981),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        onTap: () {
                          final tenant = ref
                              .read(tenantProvider)
                              .where((tenant) => tenant.id == item.tenantId)
                              .firstOrNull;
                          Navigator.of(context, rootNavigator: true).push(
                            FadePageRoute(
                              page: PaymentsScreen(
                                initialTenant: tenant,
                                openPaymentForm: true,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: RampColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Pay ₱',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(
            duration: (200 + index * 40).ms); // Individual FadeIn per item
      },
    );
  }

  Widget _buildRecentActivityTab(BuildContext context, WidgetRef ref,
      List<dynamic> activities, bool isDark) {
    if (activities.isEmpty) {
      return Center(
        child: Text(
          'No recent activity logged.',
          style: GoogleFonts.poppins(color: RampColors.mutedText, fontSize: 13),
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    final hasMoreThanFive = activities.length > 5;
    final displayCount =
        (_showAllActivity || !hasMoreThanFive) ? activities.length : 5;
    final totalItemCount = hasMoreThanFive ? displayCount + 1 : displayCount;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: totalItemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (hasMoreThanFive && index == displayCount) {
          return _buildShowMoreLessButton(
            isExpanded: _showAllActivity,
            remainingCount: activities.length - 5,
            isDark: isDark,
            onTap: () {
              setState(() {
                _showAllActivity = !_showAllActivity;
              });
            },
          );
        }

        final act = activities[index];
        return ConstrainedBox(
          constraints:
              const BoxConstraints(minHeight: 48), // Minimum 48px height
          child: InkWell(
            onTap: () => _openRecentActivity(act),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF181A1C) : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: act.iconBgColor,
                    child: Icon(act.icon, size: 16, color: RampColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          act.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          act.description,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: RampColors.mutedText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      act.timeAgo,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: RampColors.mutedText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(
            duration: (200 + index * 40).ms); // Individual FadeIn per item
      },
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
    final activities = ref.watch(activityProvider);
    final upcomingDues = ref.watch(upcomingDues7DaysProvider);
    final landlordProfile = ref.watch(landlordProfileProvider);

    // KPI Values via Riverpod Computed Providers
    final activeTenants = ref
        .watch(tenantProvider)
        .where((tenant) => !tenant.isArchived)
        .toList();
    final now = DateTime.now();

    final totalRevenueCollected = ref.watch(kpiTotalRevenueProvider);
    final netOperatingIncomeVal = ref.watch(netOperatingIncomeProvider);
    final pendingDuesVal = activeTenants.fold<double>(
      0.0,
      (sum, tenant) => sum + (tenant.balance > 0 ? tenant.balance : 0.0),
    );
    final targetRevenueVal = totalRevenueCollected + pendingDuesVal;

    final collectionProgress = targetRevenueVal > 0 
        ? (totalRevenueCollected / targetRevenueVal).clamp(0.0, 1.0)
        : (totalRevenueCollected > 0 ? 1.0 : 0.0);
    final collectionPercent = (collectionProgress * 100).round();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, right: 16.0, left: 16.0, top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: 'ramp_ai_fab',
              onPressed: () => _showAiAssistantBottomSheet(context),
              backgroundColor: RampColors.primary,
              elevation: 0,
              icon: const Icon(Icons.auto_awesome_outlined,
                  color: Colors.white, size: 20),
              label: Text(
                'RAMP AI',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
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
                    padding: const EdgeInsets.only(
                      left: 18,
                      right: 18,
                      top: 16,
                      bottom:
                          120, // Extra bottom padding so FAB never obscures list items
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- 1. TOP HEADER: Dynamic Greeting & Header Shortcuts Row ---
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      // Clickable Profile Avatar
                                      GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(bottomNavIndexProvider.notifier)
                                              .state = 4;
                                        },
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            boxShadow: null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getInitials(landlordProfile.name),
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${_getGreeting()}, ${landlordProfile.name.split(' ').first}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Apex Rental Properties',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16.5,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Notification Bell Icon with Badge Aligned to the Right
                                Consumer(
                                  builder: (context, ref, child) {
                                    final notifs = ref.watch(notificationProvider);
                                    final unreadCount = notifs
                                        .where((n) => !n.isRead && !n.isArchived)
                                        .length;
                                    return Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      child: InkWell(
                                        onTap: () => _showNotifications(context),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outlineVariant,
                                            ),
                                            boxShadow: null,
                                          ),
                                          child: Badge(
                                            label: Text(
                                              unreadCount.toString(),
                                              style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            isLabelVisible: unreadCount > 0,
                                            backgroundColor: RampColors.primary,
                                            child: Icon(
                                              Icons.notifications_none_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // --- OFFLINE SYNC BANNER ---
                        ValueListenableBuilder<PersistenceQueueState>(
                          valueListenable: PersistenceQueue.instance,
                          builder: (context, writes, _) {
                            if (writes.pending.isEmpty &&
                                !writes.isSyncing &&
                                writes.lastError == null) {
                              return const SizedBox.shrink();
                            }
                            final hasFailure = writes.lastError != null;
                            final pendingCount = writes.pending.length;
                            return Column(
                              children: [
                                RampCard(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  backgroundColor: isDark
                                      ? const Color(0xFF342B1D)
                                      : const Color(0xFFFFF3E0),
                                  borderColor: isDark
                                      ? const Color(0xFF8A6A35)
                                      : const Color(0xFFF59E0B),
                                  child: Row(
                                    children: [
                                      Icon(
                                        hasFailure
                                            ? Icons.error_outline_rounded
                                            : Icons.cloud_sync_rounded,
                                        color: hasFailure
                                            ? RampColors.danger
                                            : const Color(0xFFF59E0B),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              hasFailure
                                                  ? 'Sync Error'
                                                  : (writes.isSyncing
                                                      ? 'Syncing Changes...'
                                                      : 'Pending Sync Queue'),
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: isDark
                                                    ? const Color(0xFFD5B477)
                                                    : const Color(0xFFB45309),
                                              ),
                                            ),
                                            Text(
                                              hasFailure
                                                  ? writes.lastError!
                                                  : '$pendingCount action(s) stored locally. Will sync when reconnected.',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: RampColors.mutedText),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.sync_rounded,
                                            size: 20, color: Color(0xFFF59E0B)),
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

                        // --- 2. SIDE-BY-SIDE FINANCIAL OVERVIEW CARD ---
                        RampCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF1E3A5F)
                                              : const Color(0xFFE8F1FF),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                            Icons.pie_chart_outline_rounded,
                                            color: RampColors.primary,
                                            size: 20),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Financial Overview',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
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
                              const SizedBox(height: 18),

                              // Side-by-Side Content: Circular Progress (Left) + Vertical Stacked Stats (Right)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Left: Circular Progress Indicator
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox.expand(
                                          child: CircularProgressIndicator(
                                            value: collectionProgress,
                                            strokeWidth: 8,
                                            backgroundColor: isDark
                                                ? const Color(0xFF334155)
                                                : const Color(0xFFE2E8F0),
                                            color: RampColors.primary,
                                            strokeCap: StrokeCap.round,
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                '$collectionPercent%',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'Collected',
                                              style: GoogleFonts.poppins(
                                                fontSize: 9.5,
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

                                  // Right: Stacked Statistics Vertically
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _buildFinancialMetricRow(
                                          icon: Icons.my_location_outlined,
                                          iconColor: const Color(0xFF6B7280),
                                          label: 'Target',
                                          value: _currencyFormat
                                              .format(targetRevenueVal),
                                          isDark: isDark,
                                        ),
                                        const SizedBox(height: 6),
                                        _buildFinancialMetricRow(
                                          icon: Icons
                                              .check_circle_outline_rounded,
                                          iconColor: const Color(0xFF10B981),
                                          label: 'Collected',
                                          value: _currencyFormat
                                              .format(totalRevenueCollected),
                                          isDark: isDark,
                                        ),
                                        const SizedBox(height: 6),
                                        _buildFinancialMetricRow(
                                          icon: Icons.hourglass_empty_outlined,
                                          iconColor: pendingDuesVal > 0
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF10B981),
                                          label: 'Pending',
                                          value: _currencyFormat
                                              .format(pendingDuesVal),
                                          isDark: isDark,
                                        ),
                                        const SizedBox(height: 6),
                                        _buildFinancialMetricRow(
                                          icon: Icons
                                              .account_balance_wallet_outlined,
                                          iconColor: RampColors.primary,
                                          label: 'Net NOI',
                                          value: _currencyFormat
                                              .format(netOperatingIncomeVal),
                                          isDark: isDark,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Bottom Deadline Strip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_outlined,
                                        size: 16, color: RampColors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Next Due Cycle: ${DateFormat("MMM dd, yyyy").format(DateTime(now.year, now.month + 1, 5))}',
                                        style: GoogleFonts.poppins(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Compact "View Full Ledger" Button at the Bottom
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    side: BorderSide(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0),
                                      width: 1.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(22)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    minimumSize: const Size(0, 40),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.receipt_long_outlined,
                                      size: 16),
                                  label: Text(
                                    'View Full Ledger',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context, rootNavigator: true)
                                          .push(FadePageRoute(
                                              page: const PaymentsScreen())),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- 3. QUICK MANAGEMENT ACTIONS (HORIZONTAL ROW OF CIRCULAR BUTTONS) ---
                        Text(
                          'Manage',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQuickActionButton(
                              context: context,
                              icon: Icons.add_card_outlined,
                              label: 'Record Payment',
                              color: RampColors.primary,
                              bgColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE8F1FF),
                              onTap: () => showRecordPaymentSheet(context, ref),
                            ),
                            _buildQuickActionButton(
                              context: context,
                              icon: Icons.handyman_outlined,
                              label: 'Maintenance',
                              color: RampColors.primary,
                              bgColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE8F1FF),
                              onTap: () =>
                                  Navigator.of(context, rootNavigator: true)
                                      .push(
                                SlideUpFadeRoute(
                                    page: const TicketFormScreen()),
                              ),
                            ),
                            _buildQuickActionButton(
                              context: context,
                              icon: Icons.person_add_outlined,
                              label: 'Add Tenant',
                              color: RampColors.primary,
                              bgColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE8F1FF),
                              onTap: () =>
                                  Navigator.of(context, rootNavigator: true)
                                      .push(
                                SlideUpFadeRoute(
                                    page: const TenantFormScreen()),
                              ),
                            ),
                            _buildQuickActionButton(
                              context: context,
                              icon: Icons.calendar_month_outlined,
                              label: 'Calendar',
                              color: RampColors.primary,
                              bgColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE8F1FF),
                              onTap: () => showRampCalendarBottomSheet(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- 4. COMBINED TABBED SECTION (SCHEDULE | DUE SOON | RECENT ACTIVITY) ---
                        DefaultTabController(
                          length: 3,
                          child: RampCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Standard Material 3 TabBar with Clean Bottom Indicator Line
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0),
                                        width: 1.0,
                                      ),
                                    ),
                                  ),
                                  child: TabBar(
                                    indicatorColor: RampColors.primary,
                                    indicatorWeight: 2.5,
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    dividerColor: Colors.transparent,
                                    labelColor: RampColors.primary,
                                    unselectedLabelColor: isDark
                                        ? const Color(0xFF94A3B8)
                                        : RampColors.mutedText,
                                    labelStyle: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                    unselectedLabelStyle: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                    padding: EdgeInsets.zero,
                                    labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 8),
                                    tabs: const [
                                      Tab(
                                        height: 38,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.build_outlined,
                                                size: 16),
                                            SizedBox(width: 6),
                                            Text('Repairs'),
                                          ],
                                        ),
                                      ),
                                      Tab(
                                        height: 38,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.hourglass_empty_outlined,
                                                size: 16),
                                            SizedBox(width: 6),
                                            Text('Due Soon'),
                                          ],
                                        ),
                                      ),
                                      Tab(
                                        height: 38,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.history_outlined,
                                                size: 16),
                                            SizedBox(width: 6),
                                            Text('Activity'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // TabBarView Content (With Minimum 48px Item Height & FadeIn Animation)
                                SizedBox(
                                  height: 350,
                                  child: TabBarView(
                                    children: [
                                      _buildUpcomingScheduleTab(
                                          context, ref, isDark),
                                      _buildDueSoonTab(
                                          context, ref, upcomingDues, isDark),
                                      _buildRecentActivityTab(
                                          context, ref, activities, isDark),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
