import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../core/widgets/core_widgets.dart';
import '../core/theme/ramp_theme.dart';
import '../core/services/reminder_launcher_service.dart';
import 'tenant_form.dart';
import 'tenant_profile.dart';
import 'payments_screen.dart';

enum TenantSortOption { name, unit, balance, dueDate }

class TenantsScreen extends ConsumerStatefulWidget {
  const TenantsScreen({super.key});

  @override
  ConsumerState<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends ConsumerState<TenantsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Late Dues, Due Soon, Paid
  bool _showArchived = false;
  TenantSortOption _sortOption = TenantSortOption.name;
  final Set<String> _expandedTenantIds = <String>{};

  final List<String> _filters = [
    'All',
    'Unassigned',
    'Late Dues',
    'Due Soon',
    'Paid'
  ];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  void _openTenantForm({Tenant? existingTenant}) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => TenantFormScreen(existingTenant: existingTenant),
      ),
    );
  }

  void _showSendReminderModal(BuildContext context, Tenant tenant) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String unitInfo = tenant.isAssigned && tenant.unitNumber.isNotEmpty
        ? "Unit ${tenant.unitNumber}"
        : "Apex Rental Properties";

    final String message = tenant.isAssigned
        ? "Hello ${tenant.name}, this is a rent reminder for $unitInfo. Your current balance is ${_currencyFormat.format(tenant.balance)}, due on ${DateFormat('MMM d, yyyy').format(_effectiveTenantDueDate(tenant))}. Thank you!"
        : "Hello ${tenant.name}, this is a friendly reminder regarding your tenant profile with $unitInfo. Current balance: ${_currencyFormat.format(tenant.balance)}. Thank you!";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? Theme.of(context).colorScheme.surface : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.send_rounded,
                              color: RampColors.primary, size: 22),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Send Reminder to ${tenant.name}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : RampColors.slate,
                              ),
                              maxLines: 1,
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
                const SizedBox(height: 12),
                Text(
                  'Select communication channel to dispatch notice to ${tenant.name}:',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color:
                        isDark ? const Color(0xFF94A3B8) : RampColors.mutedText,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: RampColors.softBlueTint,
                    child:
                        Icon(Icons.message_rounded, color: RampColors.primary),
                  ),
                  title: Text(
                    'SMS Reminder ${tenant.phone.isNotEmpty ? "(${tenant.phone})" : "(No phone)"}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : RampColors.slate,
                    ),
                  ),
                  subtitle: Text(
                    'Opens SMS app & updates payer health history',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: RampColors.mutedText),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    ref
                        .read(tenantProvider.notifier)
                        .incrementTenantReminder(tenant.id, channel: 'SMS');
                    final launched = await ReminderLauncherService.launchSms(
                        phone: tenant.phone, message: message);
                    if (!launched) {
                      await Clipboard.setData(ClipboardData(text: message));
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(launched
                            ? 'SMS app opened for ${tenant.phone}! Health updated.'
                            : 'Reminder copied to clipboard! (SMS launcher unavailable)'),
                        backgroundColor: RampColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F0FE),
                    child: Icon(Icons.forum_rounded, color: Color(0xFF0084FF)),
                  ),
                  title: Text(
                    'Messenger Reminder ${tenant.messengerHandle != null && tenant.messengerHandle!.isNotEmpty ? "(@${tenant.messengerHandle})" : ""}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : RampColors.slate,
                    ),
                  ),
                  subtitle: Text(
                    'Opens Messenger & updates payer health history',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: RampColors.mutedText),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    ref.read(tenantProvider.notifier).incrementTenantReminder(
                        tenant.id,
                        channel: 'Messenger');
                    final launched =
                        await ReminderLauncherService.launchMessenger(
                            messengerHandle: tenant.messengerHandle,
                            message: message);
                    if (!launched) {
                      await Clipboard.setData(ClipboardData(text: message));
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(launched
                            ? 'Messenger opened for ${tenant.name}! Health updated.'
                            : 'Reminder copied to clipboard! (Messenger launcher unavailable)'),
                        backgroundColor: const Color(0xFF0084FF),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: RampColors.successTint,
                    child: Icon(Icons.copy_rounded, color: RampColors.success),
                  ),
                  title: Text(
                    'Copy Reminder Text',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : RampColors.slate,
                    ),
                  ),
                  subtitle: Text(
                    'Copy notice text directly to clipboard',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: RampColors.mutedText),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    ref
                        .read(tenantProvider.notifier)
                        .incrementTenantReminder(tenant.id, channel: 'SMS');
                    await Clipboard.setData(ClipboardData(text: message));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Rent reminder text copied to clipboard! Health updated.'),
                        backgroundColor: RampColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  DateTime _effectiveTenantDueDate(Tenant tenant) {
    final unit = ref
        .read(unitProvider)
        .where((unit) => unit.id == tenant.unitId)
        .firstOrNull;
    if (unit == null) return tenant.dueDate;
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return DateTime(now.year, now.month, unit.rentDueDay.clamp(1, lastDay));
  }

  void _openTenantProfile(Tenant tenant) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => TenantProfileScreen(tenantId: tenant.id),
      ),
    );
  }
  Widget _buildTenantCard(Tenant tenant) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    TextStyle text(double size,
            {Color? color, FontWeight weight = FontWeight.w400}) =>
        GoogleFonts.poppins(
            fontSize: size,
            height: 1.5,
            color: color ?? theme.colorScheme.onSurface,
            fontWeight: weight);

    final statusColor = !tenant.isAssigned
        ? theme.colorScheme.primary
        : tenant.isLate
            ? theme.colorScheme.error
            : tenant.balance > 0
                ? const Color(0xFFD97706)
                : const Color(0xFF059669);
    final isExpanded = _expandedTenantIds.contains(tenant.id);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openTenantProfile(tenant),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: tenant.avatarUrl != null
                        ? NetworkImage(tenant.avatarUrl!)
                        : null,
                    onBackgroundImageError:
                        tenant.avatarUrl != null ? (_, __) {} : null,
                    child: tenant.avatarUrl == null
                        ? Text(
                            tenant.name.isNotEmpty
                                ? tenant.name[0].toUpperCase()
                                : 'T',
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tenant.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Tooltip(
                              message: 'Payer Health: ${tenant.healthStatusText}',
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: tenant.healthColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tenant.isAssigned
                              ? '${tenant.unitNumber}  •  Due ${DateFormat('MMM d').format(_effectiveTenantDueDate(tenant))}'
                              : 'Unassigned  •  ${tenant.address}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _currencyFormat.format(tenant.balance),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tenant.balanceStatusText,
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: isExpanded ? 'Hide quick details' : 'Show quick details',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() {
                      if (isExpanded) {
                        _expandedTenantIds.remove(tenant.id);
                      } else {
                        _expandedTenantIds.add(tenant.id);
                      }
                    }),
                    icon: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 14),
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                const SizedBox(height: 12),
                _tenantDetailLine('Contact', tenant.phone, muted, text),
                _tenantDetailLine('Address', tenant.address, muted, text),
                if (tenant.referral.isNotEmpty)
                  _tenantDetailLine('Referral', tenant.referral, muted, text),
                if (tenant.email.isNotEmpty)
                  _tenantDetailLine('Email', tenant.email, muted, text),
                if (tenant.isAssigned)
                  _tenantDetailLine('Monthly rent',
                      _currencyFormat.format(tenant.monthlyRent), muted, text),
                if (tenant.isAssigned)
                  _tenantDetailLine(
                      'Lease',
                      '${DateFormat('MMM d, yyyy').format(tenant.leaseStart)} – ${DateFormat('MMM d, yyyy').format(tenant.leaseEnd)}',
                      muted,
                      text),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () =>
                            _showSendReminderModal(context, tenant),
                        icon: const Icon(Icons.notifications_none_rounded,
                            size: 16),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('REMIND'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () =>
                            _openTenantForm(existingTenant: tenant),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('EDIT'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Open full tenant record',
                      onPressed: () => _openTenantProfile(tenant),
                      icon: const Icon(Icons.open_in_new_rounded, size: 19),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tenantDetailLine(String label, String value, Color muted,
      TextStyle Function(double, {Color? color, FontWeight weight}) text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: text(11, color: muted)),
          ),
          Expanded(
            child: Text(value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text(12, weight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTenants = ref.watch(tenantProvider);

    // Apply Filter & Search
    List<Tenant> displayTenants = allTenants.where((t) {
      if (_showArchived) return t.isArchived;
      if (t.isArchived) return false;

      if (_selectedFilter == 'Late Dues') return t.isLate;
      if (_selectedFilter == 'Due Soon') return t.isDueSoon;
      if (_selectedFilter == 'Unassigned') return !t.isAssigned;
      if (_selectedFilter == 'Paid') return t.isAssigned && t.balance <= 0;
      return true;
    }).toList();

    if (_searchQuery.isNotEmpty) {
      displayTenants = displayTenants.where((t) {
        final query = _searchQuery.toLowerCase();
        return t.name.toLowerCase().contains(query) ||
            t.unitNumber.toLowerCase().contains(query) ||
            t.address.toLowerCase().contains(query) ||
            t.referral.toLowerCase().contains(query) ||
            t.email.toLowerCase().contains(query) ||
            t.phone.contains(query);
      }).toList();
    }

    // Apply Sort
    displayTenants = List.from(displayTenants);
    if (_sortOption == TenantSortOption.name) {
      displayTenants.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortOption == TenantSortOption.unit) {
      displayTenants.sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
    } else if (_sortOption == TenantSortOption.balance) {
      displayTenants.sort((a, b) => b.balance.compareTo(a.balance));
    } else if (_sortOption == TenantSortOption.dueDate) {
      displayTenants.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }

    final lateCount = allTenants.where((t) => !t.isArchived && t.isLate).length;
    final dueSoonCount =
        allTenants.where((t) => !t.isArchived && t.isDueSoon).length;

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : RampColors.background,
      appBar: AppBar(
        title: Text(_showArchived ? 'Archived Tenants' : 'Tenants',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor:
            isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<TenantSortOption>(
            icon: const Icon(Icons.sort, color: RampColors.primary),
            onSelected: (option) => setState(() => _sortOption = option),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TenantSortOption.name,
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: TenantSortOption.unit,
                child: Text('Sort by Unit Number'),
              ),
              const PopupMenuItem(
                value: TenantSortOption.balance,
                child: Text('Sort by Balance'),
              ),
              const PopupMenuItem(
                value: TenantSortOption.dueDate,
                child: Text('Sort by Due Date'),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: Icon(
              _showArchived ? Icons.archive_rounded : Icons.more_vert_rounded,
              color: RampColors.primary,
            ),
            onSelected: (val) {
              if (val == 'toggleArchived') {
                setState(() => _showArchived = !_showArchived);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggleArchived',
                child: Text(_showArchived
                    ? 'Show Active Tenants'
                    : 'Show Archived Tenants'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                await Future<void>.delayed(const Duration(milliseconds: 500));
                if (mounted) setState(() => _isLoading = false);
              },
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 12.0, bottom: 100.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.white : RampColors.slate,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search tenant, unit, phone, or email...',
                        hintStyle: GoogleFonts.poppins(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : RampColors.mutedText,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : RampColors.border)),
                        prefixIcon:
                            const Icon(Icons.search, color: RampColors.primary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 16),
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _filters.map((f) {
                          final isSelected = _selectedFilter == f;
                          int badgeCount = 0;
                          if (f == 'Late Dues') badgeCount = lateCount;
                          if (f == 'Due Soon') badgeCount = dueSoonCount;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              label: Text(
                                badgeCount > 0 ? '$f ($badgeCount)' : f,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _selectedFilter = f),
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              checkmarkColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              side: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${displayTenants.length} ${displayTenants.length == 1 ? 'tenant' : 'tenants'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Tenant Cards List, Shimmer Loading, Error, or Empty State
                    if (_isLoading)
                      const ShimmerList(
                          itemCount: 5, height: 120, padding: EdgeInsets.zero)
                    else if (_hasError)
                      ErrorStateWidget(
                        message:
                            'Failed to load tenant records. Please try again.',
                        onRetry: () {
                          setState(() {
                            _hasError = false;
                            _isLoading = true;
                          });
                          Future.delayed(const Duration(milliseconds: 800), () {
                            if (mounted) setState(() => _isLoading = false);
                          });
                        },
                      )
                    else
                      displayTenants.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.people_outline_rounded,
                              title: _searchQuery.isNotEmpty ||
                                      _selectedFilter != 'All'
                                  ? 'No Tenants Match Filters'
                                  : 'No Tenants Found',
                              message: _searchQuery.isNotEmpty
                                  ? 'No tenants match "$_searchQuery". Try clearing your search keywords or resetting status filters.'
                                  : 'You have not added any tenants matching this view.',
                              buttonText: _searchQuery.isNotEmpty ||
                                      _selectedFilter != 'All'
                                  ? 'Reset Filters & Search'
                                  : 'Add Tenant',
                              buttonIcon: _searchQuery.isNotEmpty ||
                                      _selectedFilter != 'All'
                                  ? Icons.refresh_rounded
                                  : Icons.add_rounded,
                              onButtonPressed: () {
                                if (_searchQuery.isNotEmpty ||
                                    _selectedFilter != 'All') {
                                  _searchCtrl.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedFilter = 'All';
                                  });
                                } else {
                                  _openTenantForm();
                                }
                              },
                            )
                          : Column(
                              children:
                                  List.generate(displayTenants.length, (index) {
                                final tenant = displayTenants[index];

                                return StaggeredListItem(
                                  index: index,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildTenantCard(tenant),
                                  ),
                                );
                              }),
                            ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _openTenantForm(),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Add Tenant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

typedef TenantsDirectoryScreen = TenantsScreen;
