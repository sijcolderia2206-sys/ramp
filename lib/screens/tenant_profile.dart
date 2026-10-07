import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../core/widgets/core_widgets.dart';
import '../core/theme/ramp_theme.dart';
import '../core/utils/toast_service.dart';
import '../core/navigation/custom_page_transitions.dart';
import '../core/services/reminder_launcher_service.dart';
import 'payment_form.dart';
import 'tenant_form.dart';
import 'payments_screen.dart';
import 'unit_detail.dart';

class TenantProfileScreen extends ConsumerWidget {
  final String tenantId;

  const TenantProfileScreen({super.key, required this.tenantId});

  Future<bool> _confirmArchive(BuildContext context, Tenant tenant) async {
    final restoring = tenant.isArchived;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(restoring ? 'Restore tenant?' : 'Archive tenant?'),
            content: Text(restoring
                ? '${tenant.name} will return to the active tenant list.'
                : '${tenant.name} will be moved to the archived tenant list.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(restoring ? 'RESTORE' : 'ARCHIVE'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Color _getStatusDotColor(Ticket ticket) {
    if (ticket.status == 'Completed' ||
        ticket.status == 'Closed' ||
        ticket.status.toLowerCase() == 'resolved') {
      return const Color(0xFF10B981); // Green
    }
    if (ticket.priority.toLowerCase() == 'urgent' ||
        ticket.priority.toLowerCase() == 'emergency') {
      return const Color(0xFFEF4444); // Red
    }
    if (ticket.priority.toLowerCase() == 'high') {
      return const Color(0xFFF59E0B); // Amber / Orange
    }
    return RampColors.primary; // Primary blue
  }

  void _showTenantTicketsModal(
      BuildContext context, WidgetRef ref, Tenant tenant) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tickets = ref
        .read(ticketProvider)
        .where((t) =>
            t.tenantId == tenant.id ||
            t.tenantName == tenant.name ||
            t.unitNumber == tenant.unitNumber)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                blurRadius: 10,
                offset: const Offset(5, 5),
              ),
              BoxShadow(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                blurRadius: 10,
                offset: const Offset(-5, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.build_rounded,
                            color: RampColors.warning, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tickets for ${tenant.name}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : RampColors.slate,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              Divider(
                  height: 16,
                  color: isDark ? const Color(0xFF334155) : RampColors.border),
              Expanded(
                child: tickets.isEmpty
                    ? RampEmptyState(
                        title: 'No Tickets Found',
                        description:
                            'There are no active or past maintenance tickets for this tenant.',
                        icon: Icons.task_alt_rounded,
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: tickets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final t = tickets[index];
                          return StaggeredListItem(
                            index: index,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                                    blurRadius: 10,
                                    offset: const Offset(5, 5),
                                  ),
                                  BoxShadow(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                                    blurRadius: 10,
                                    offset: const Offset(-5, -5),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _getStatusDotColor(t),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: Text(
                                  t.title,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : RampColors.slate,
                                  ),
                                ),
                                subtitle: Text(
                                  'Priority: ${t.priority} • Status: ${t.status}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : RampColors.mutedText,
                                  ),
                                ),
                                trailing: Text(
                                  t.formattedCost,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : RampColors.slate,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tenant =
        ref.watch(tenantProvider).where((t) => t.id == tenantId).firstOrNull;

    if (tenant == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tenant Profile')),
        body: SafeArea(
          child: RampEmptyState(
            title: 'Tenant Not Found',
            description: 'The requested tenant record could not be found.',
            icon: Icons.person_off_outlined,
            actionLabel: 'Go Back',
            onActionPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }

    final Color statusColor = tenant.statusColor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: Text(
          '${tenant.name} Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : RampColors.slate,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Tenant',
            onPressed: () async {
              final saved = await Navigator.of(context).push<bool>(
                SlideUpFadeRoute(
                  page: TenantFormScreen(existingTenant: tenant),
                ),
              );
              if (saved == true && context.mounted) {
                ToastService.showSuccess('Tenant profile updated!');
              }
            },
          ),
          IconButton(
            icon: Icon(tenant.isArchived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined),
            tooltip: tenant.isArchived ? 'Restore Tenant' : 'Archive Tenant',
            onPressed: () async {
              final confirmed = await _confirmArchive(context, tenant);
              if (!context.mounted || !confirmed) return;
              if (tenant.isArchived) {
                ref.read(tenantProvider.notifier).unarchiveTenant(tenant.id);
                ToastService.showInfo('${tenant.name} restored from archives!');
              } else {
                ref.read(tenantProvider.notifier).archiveTenant(tenant.id);
                ToastService.showWarning('${tenant.name} moved to Archived list!');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: RampColors.danger),
            tooltip: 'Delete Tenant',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text('Delete ${tenant.name}?'),
                      content: Text(
                          'Are you sure you want to permanently remove ${tenant.name}? Any assigned unit will be vacated.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('CANCEL'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: RampColors.danger),
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('DELETE'),
                        ),
                      ],
                    ),
                  ) ??
                  false;

              if (!context.mounted || !confirmed) return;
              ref.read(tenantProvider.notifier).deleteTenant(tenant.id);
              Navigator.pop(context);
              ToastService.showInfo('${tenant.name} permanently deleted.');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 12.0, bottom: 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tenant Card Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                    BoxShadow(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: RampColors.softBlueTint,
                          backgroundImage: tenant.avatarUrl != null
                              ? NetworkImage(tenant.avatarUrl!)
                              : null,
                          onBackgroundImageError:
                              tenant.avatarUrl != null ? (_, __) {} : null,
                          child: tenant.avatarUrl == null
                              ? Text(
                                  tenant.name.isNotEmpty ? tenant.name[0] : 'T',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: RampColors.primary,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      tenant.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : RampColors.slate,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  StatusPill(status: tenant.balanceStatusText),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: tenant.healthColor,
                                          shape: BoxShape.circle)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Payer Health: ${tenant.healthStatusText} (${tenant.healthScore}/100)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: tenant.healthColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${tenant.unitNumber} • ${tenant.phone} ${tenant.messengerHandle != null && tenant.messengerHandle!.isNotEmpty ? "• @${tenant.messengerHandle}" : ""}',
                                style: GoogleFonts.poppins(
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : RampColors.mutedText,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                tenant.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : RampColors.mutedText,
                                  fontSize: 12,
                                ),
                              ),
                              if (tenant.referral.isNotEmpty)
                                Text(
                                  'Referral: ${tenant.referral}',
                                  style: GoogleFonts.poppins(
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : RampColors.mutedText,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(
                        height: 24,
                        color: isDark
                            ? const Color(0xFF334155)
                            : RampColors.border),
                    AdaptiveRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Outstanding Rent Balance:',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : RampColors.slate,
                          ),
                        ),
                        Text(
                          tenant.formattedBalance,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                            blurRadius: 10,
                            offset: const Offset(5, 5),
                          ),
                          BoxShadow(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                            blurRadius: 10,
                            offset: const Offset(-5, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: tenant.healthColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Payer Health Status',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white
                                          : RampColors.slate,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: tenant.healthColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Score: ${tenant.healthScore}/100',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tenant.healthStatusText,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: tenant.healthColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildHealthDetail(
                                  label: '30-Day Reminders',
                                  value: '${tenant.recentRentReminderCount}',
                                  isDark: isDark,
                                ),
                              ),
                              Expanded(
                                child: _buildHealthDetail(
                                  label: 'Total Reminders',
                                  value: '${tenant.rentReminderCount}',
                                  isDark: isDark,
                                ),
                              ),
                              Expanded(
                                child: _buildHealthDetail(
                                  label: 'Overdue Status',
                                  value: tenant.isLate
                                      ? '${tenant.daysOverdue}d Late'
                                      : 'On Schedule',
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (!tenant.isAssigned) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                        blurRadius: 10,
                        offset: const Offset(5, 5),
                      ),
                      BoxShadow(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                        blurRadius: 10,
                        offset: const Offset(-5, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Unassigned tenant',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      const Text(
                          'Add the remaining details and select a vacant unit when this tenant is ready to move in.'),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  TenantFormScreen(existingTenant: tenant),
                            ),
                          ),
                          icon: const Icon(Icons.apartment_rounded),
                          label: const Text('ADD DETAILS & ASSIGN UNIT'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Actions
              Text(
                'Tenant Actions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : RampColors.slate,
                ),
              ),
              const SizedBox(height: 12),
              if (tenant.isAssigned)
                Column(
                  children: [
                    AdaptiveRow(
                      children: [
                        Expanded(
                          child: _buildCRMActionButton(
                            icon: Icons.message_rounded,
                            label: 'SMS Reminder',
                            color: RampColors.primary,
                            isDark: isDark,
                            onTap: () async {
                              ref
                                  .read(tenantProvider.notifier)
                                  .incrementTenantReminder(tenant.id,
                                      channel: 'SMS');
                              final message =
                                  "Hello ${tenant.name}, this is a rent reminder for Unit ${tenant.unitNumber}. Balance: ${tenant.formattedBalance}, due on ${DateFormat('MMM d, yyyy').format(tenant.effectiveDueDate)}. Thank you!";
                              final launched =
                                  await ReminderLauncherService.launchSms(
                                      phone: tenant.phone, message: message);
                              if (!launched) {
                                await Clipboard.setData(
                                    ClipboardData(text: message));
                              }
                              if (!context.mounted) return;
                              ToastService.showInfo(launched
                                  ? 'SMS app opened for ${tenant.phone}! Health updated.'
                                  : 'Reminder text copied to clipboard! Health updated.');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCRMActionButton(
                            icon: Icons.forum_rounded,
                            label: 'Messenger Reminder',
                            color: const Color(0xFF0084FF),
                            isDark: isDark,
                            onTap: () async {
                              ref
                                  .read(tenantProvider.notifier)
                                  .incrementTenantReminder(tenant.id,
                                      channel: 'Messenger');
                              final message =
                                  "Hi ${tenant.name}! Friendly rent reminder for Unit ${tenant.unitNumber}: balance is ${tenant.formattedBalance} due on ${DateFormat('MMM d, yyyy').format(tenant.effectiveDueDate)}. Thank you!";
                              final launched =
                                  await ReminderLauncherService.launchMessenger(
                                      messengerHandle: tenant.messengerHandle,
                                      message: message);
                              if (!launched) {
                                await Clipboard.setData(
                                    ClipboardData(text: message));
                              }
                              if (!context.mounted) return;
                              ToastService.showInfo(launched
                                  ? 'Messenger opened for ${tenant.name}! Reminder text copied to clipboard.'
                                  : 'Reminder text copied to clipboard! Health updated.');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AdaptiveRow(
                      children: [
                        Expanded(
                          child: _buildCRMActionButton(
                            icon: Icons.receipt_long_rounded,
                            label: 'Record Payment',
                            color: RampColors.primary,
                            isDark: isDark,
                            onTap: () => showRecordPaymentSheet(context, ref,
                                initialTenant: tenant),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCRMActionButton(
                            icon: Icons.payments_rounded,
                            label: 'View Payments',
                            color: RampColors.primary,
                            isDark: isDark,
                            onTap: () =>
                                Navigator.of(context, rootNavigator: true)
                                    .push(MaterialPageRoute(
                              builder: (_) =>
                                  PaymentsScreen(tenantFilter: tenant),
                            )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AdaptiveRow(
                      children: [
                        Expanded(
                          child: _buildCRMActionButton(
                            icon: Icons.build_rounded,
                            label: 'View Tickets',
                            color: RampColors.warning,
                            isDark: isDark,
                            onTap: () =>
                                _showTenantTicketsModal(context, ref, tenant),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildCRMActionButton(
                            icon: Icons.apartment_rounded,
                            label: 'Unit Details',
                            color: const Color(0xFF6366F1),
                            isDark: isDark,
                            onTap: () {
                              if (tenant.unitId.isNotEmpty) {
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        UnitDetailScreen(unitId: tenant.unitId),
                                  ),
                                );
                              } else {
                                ToastService.showWarning('Tenant is not assigned to a unit.');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              if (tenant.reminderLogs.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Reminder Dispatch History (${tenant.reminderLogs.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : RampColors.slate,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                        blurRadius: 10,
                        offset: const Offset(5, 5),
                      ),
                      BoxShadow(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                        blurRadius: 10,
                        offset: const Offset(-5, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: tenant.reminderLogs.reversed.map((log) {
                      final isSms = log.channel.toLowerCase().contains('sms');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isSms
                                  ? RampColors.softBlueTint
                                  : const Color(0xFFE8F0FE),
                              child: Icon(
                                isSms ? Icons.sms_rounded : Icons.forum_rounded,
                                size: 16,
                                color: isSms
                                    ? RampColors.primary
                                    : const Color(0xFF0084FF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${log.messageType} via ${log.channel}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white
                                          : RampColors.slate,
                                    ),
                                  ),
                                  Text(
                                    log.formattedTime,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : RampColors.mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCRMActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return BouncingInteractive(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
              blurRadius: 10,
              offset: const Offset(5, 5),
            ),
            BoxShadow(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
              blurRadius: 10,
              offset: const Offset(-5, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthDetail({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : RampColors.slate,
          ),
        ),
      ],
    );
  }
}
