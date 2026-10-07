// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/providers.dart';
import '../core/theme/ramp_theme.dart';
import '../features/calendar/widgets/calendar_bottom_sheet.dart';
import '../core/navigation/custom_page_transitions.dart';
import 'payments_screen.dart';
import 'payment_form.dart';
import 'tenant_form.dart';
import 'ticket_form.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      body: Stack(
        children: [
          // Scrollable Content
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.lightImpact();
                await hydratePersistentAppData(ref);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // The Header Content
                  const SliverToBoxAdapter(
                    child: _BackdropHeader(),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _FinancialOverviewCard(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                  // The content
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                      ),
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.sizeOf(context).height - 250, // Ensuring it covers the rest of the screen
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 100), // Extra bottom padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _QuickActionsRow(),
                            const SizedBox(height: 32),
                            const _PriorityInsightsFeed(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Header Widget ---
class _BackdropHeader extends ConsumerWidget {
  const _BackdropHeader();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final landlordProfile = ref.watch(landlordProfileProvider);
    final userName = landlordProfile.name.split(' ').first;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC);
    
    // Check if there are any unread notifications
    final hasUnreadNotifications = ref.watch(notificationProvider).any((n) => !n.isRead);

    return Container(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Side: Profile Avatar & Greeting
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                // Profile tab is at index 4
                ref.read(bottomNavIndexProvider.notifier).state = 4;
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                          blurRadius: 8,
                          offset: const Offset(4, 4),
                        ),
                        BoxShadow(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                          blurRadius: 8,
                          offset: const Offset(-4, -4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'E',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: RampColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.2,
                          ),
                        ),
                        Text(
                          userName,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.2,
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
          ),
          
          // Right Side: Notification Bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(4, 4),
                    ),
                    BoxShadow(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
                      blurRadius: 8,
                      offset: const Offset(-4, -4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications_none_rounded, color: Theme.of(context).colorScheme.onSurface, size: 24),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (sheetContext) => const _NotificationsBottomSheet(),
                    );
                  },
                ),
              ),
              if (hasUnreadNotifications)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: bgColor, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Financial Overview Card ---
class _FinancialOverviewCard extends ConsumerWidget {
  const _FinancialOverviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // KPI Values via Riverpod Computed Providers
    final activeTenants = ref.watch(tenantProvider).where((tenant) => !tenant.isArchived).toList();
    final totalRevenueCollected = ref.watch(kpiTotalRevenueProvider);
    final pendingDuesVal = activeTenants.fold<double>(
      0.0,
      (sum, tenant) => sum + (tenant.balance > 0 ? tenant.balance : 0.0),
    );
    final targetRevenueVal = totalRevenueCollected + pendingDuesVal;

    final collectionProgress = targetRevenueVal > 0 
        ? (totalRevenueCollected / targetRevenueVal).clamp(0.0, 1.0)
        : (totalRevenueCollected > 0 ? 1.0 : 0.0);
    final collectionPercent = (collectionProgress * 100).round();
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

    final bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC);
    
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6).withValues(alpha: 0.6),
            blurRadius: 15,
            offset: const Offset(8, 8),
          ),
          BoxShadow(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.8),
            blurRadius: 15,
            offset: const Offset(-8, -8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context, rootNavigator: true).push(
              FadePageRoute(page: const PaymentsScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pie_chart_outline_rounded, color: RampColors.primary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Financial Overview',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, color: RampColors.mutedText, size: 20),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular Progress
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
                              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              color: RampColors.primary,
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
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
                    const SizedBox(width: 24),
                    // Stats Stacked Vertically
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Revenue Collected',
                            style: GoogleFonts.poppins(fontSize: 12, color: RampColors.mutedText),
                          ),
                          Text(
                            currencyFormat.format(totalRevenueCollected),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pending Dues',
                            style: GoogleFonts.poppins(fontSize: 12, color: RampColors.mutedText),
                          ),
                          Text(
                            currencyFormat.format(pendingDuesVal),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: RampColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Quick Actions Row ---
class _QuickActionsRow extends ConsumerWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuickActionItem(
              icon: Icons.add_card_outlined,
              label: 'Record\nPayment',
              onTap: () => showRecordPaymentSheet(context, ref),
            ),
            _QuickActionItem(
              icon: Icons.person_add_outlined,
              label: 'Add\nTenant',
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                SlideUpFadeRoute(page: const TenantFormScreen()),
              ),
            ),
            _QuickActionItem(
              icon: Icons.calendar_month_outlined,
              label: 'Calendar\n',
              onTap: () => showRampCalendarBottomSheet(context),
            ),
            _QuickActionItem(
              icon: Icons.handyman_outlined,
              label: 'Add\nRepair',
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                SlideUpFadeRoute(page: const TicketFormScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
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
            child: Icon(icon, color: RampColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36, // Fixed height to align multi-line texts perfectly
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Priority Insights Feed ---
class _PriorityInsightsFeed extends ConsumerWidget {
  const _PriorityInsightsFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allNotifications = ref.watch(notificationProvider);
    final insights = allNotifications
        .where((n) => !n.isArchived)
        .take(10) // Displaying a nice vertical list
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority Insights',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        if (insights.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: RampColors.primary.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 48, color: RampColors.success.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Text(
                  "You're all caught up!",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: RampColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ...insights.map((insight) => _InsightCard(insight: insight)),
      ],
    );
  }
}

class _InsightCard extends ConsumerWidget {
  final dynamic insight; 
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Parse insight type based on content for dynamic icons
    final title = insight.title.toString().toLowerCase();
    IconData iconData = Icons.info_outline_rounded;
    Color iconColor = RampColors.primary;
    Color bgColor = RampColors.softBlueTint;
    
    if (title.contains('rent') || title.contains('payment') || title.contains('overdue')) {
      iconData = Icons.warning_amber_rounded;
      iconColor = RampColors.danger;
      bgColor = RampColors.dangerTint;
    } else if (title.contains('maintenance') || title.contains('ticket') || title.contains('repair')) {
      iconData = Icons.build_circle_outlined;
      iconColor = const Color(0xFFF59E0B); // Amber
      bgColor = const Color(0xFFFEF3C7); // Light Amber
    } else if (title.contains('door') || title.contains('access') || title.contains('scan')) {
      iconData = Icons.meeting_room_outlined;
      iconColor = const Color(0xFF10B981); // Emerald
      bgColor = const Color(0xFFD1FAE5); // Light Emerald
    }

    // Format date properly
    final formattedDate = DateFormat('MMM d').format(insight.timestamp);

    final cardBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E5EC);
    final isUnread = insight.isRead == false;
    
    return GestureDetector(
      onTap: () {
        if (isUnread) {
          HapticFeedback.lightImpact();
          ref.read(notificationProvider.notifier).markAsRead(insight.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.15) : bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 22),
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
                        insight.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  insight.message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isUnread ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8) : RampColors.mutedText,
                    fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formattedDate,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
              color: isUnread ? RampColors.primary : RampColors.mutedText,
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// --- Notifications Bottom Sheet ---
class _NotificationsBottomSheet extends ConsumerWidget {
  const _NotificationsBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allNotifications = ref.watch(notificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        minHeight: MediaQuery.sizeOf(context).height * 0.5,
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (allNotifications.any((n) => !n.isRead))
                      TextButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(notificationProvider.notifier).markAllAsRead();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Mark all as read',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: RampColors.primary,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: allNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: RampColors.mutedText.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: RampColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: allNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = allNotifications[index];
                      return _InsightCard(insight: notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
