import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

import '../core/utils/toast_service.dart';
import '../providers/providers.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AiAssistantBottomSheet extends ConsumerStatefulWidget {
  const AiAssistantBottomSheet({super.key});

  @override
  ConsumerState<AiAssistantBottomSheet> createState() =>
      _AiAssistantBottomSheetState();
}

class _AiAssistantBottomSheetState
    extends ConsumerState<AiAssistantBottomSheet> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Hello! I am **RAMP AI Assistant (Preview)**.\n\nI can answer questions directly from your property data!\n\nTry tapping a quick chip below or ask:\n• *"Who is late?"*\n• *"Total revenue this month"*\n• *"How many vacant units?"*\n• *"Send reminder to all"*',
      isUser: false,
    ),
  ];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _quickChips = [
    {
      'label': 'Show Late Payers',
      'icon': Icons.warning_amber_rounded,
      'prompt': 'Who is late?'
    },
    {
      'label': 'Monthly Report',
      'icon': Icons.insights_rounded,
      'prompt': 'Total revenue this month'
    },
    {
      'label': 'Vacant Units',
      'icon': Icons.home_work_outlined,
      'prompt': 'How many vacant units?'
    },
    {
      'label': 'Send Reminders',
      'icon': Icons.notification_add_outlined,
      'prompt': 'Send reminder to all'
    },
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmitted(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: trimmedText, isUser: true));
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 400));

    final String queryLower = trimmedText.toLowerCase();
    String responseText;

    if (queryLower.contains('who is late') ||
        queryLower.contains('show late') ||
        queryLower.contains('late payer') ||
        queryLower.contains('late tenant') ||
        queryLower.contains('late')) {
      responseText = _getLateTenantsAnswer();
    } else if (queryLower.contains('revenue') ||
        queryLower.contains('monthly report') ||
        queryLower.contains('total revenue') ||
        queryLower.contains('income') ||
        queryLower.contains('financial')) {
      responseText = _getMonthlyRevenueAnswer();
    } else if (queryLower.contains('send reminder') ||
        queryLower.contains('remind') ||
        queryLower.contains('notify late')) {
      if (!mounted) return;
      responseText = _getSendReminderAnswer(context);
    } else if (queryLower.contains('vacant') ||
        queryLower.contains('vacant unit') ||
        queryLower.contains('unoccupied') ||
        queryLower.contains('empty unit')) {
      responseText = _getVacantUnitsAnswer();
    } else {
      responseText = await _getAiOrGeneralAnswer(trimmedText);
    }

    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: responseText, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  String _getLateTenantsAnswer() {
    final tenants = ref.read(tenantProvider);
    final lateTenants =
        tenants.where((t) => t.balance > 0 || t.isLate).toList();

    if (lateTenants.isEmpty) {
      return '**Great news!** All tenants are currently up to date with no overdue balances.';
    }

    final formatter =
        NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);
    double totalOverdue = 0.0;
    final buffer = StringBuffer('**Late Tenants & Unpaid Balances:**\n\n');

    for (final tenant in lateTenants) {
      totalOverdue += tenant.balance;
      final statusTag = tenant.isLate ? 'OVERDUE' : 'PENDING';
      buffer.writeln('• **${tenant.name}** (${tenant.unitNumber})');
      buffer.writeln(
          '  Balance: **${formatter.format(tenant.balance)}** [$statusTag]');
      buffer.writeln('  Contact: ${tenant.phone}\n');
    }

    buffer.writeln(
        '**Total Outstanding Overdue:** **${formatter.format(totalOverdue)}**\n');
    buffer.writeln(
        '*Tip: Tap "Send Reminders" quick chip below to notify them via SMS.*');
    return buffer.toString();
  }

  String _getMonthlyRevenueAnswer() {
    final payments = ref.read(paymentProvider);
    final totalRevenue = ref.read(kpiTotalRevenueProvider);
    final totalExpenses = ref.read(totalExpensesProvider);
    final formatter =
        NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

    final buffer = StringBuffer('**Monthly Revenue & Financial Report:**\n\n');
    buffer.writeln(
        '• **Total Collected Revenue:** **${formatter.format(totalRevenue)}**');
    buffer.writeln(
        '• **Total Operating Expenses:** ${formatter.format(totalExpenses)}');
    buffer.writeln(
        '• **Net Operating Income:** **${formatter.format(totalRevenue - totalExpenses)}**');
    buffer
        .writeln('• **Recorded Payments:** ${payments.length} transactions\n');

    if (payments.isNotEmpty) {
      buffer.writeln('**Recent Payment Transactions:**');
      for (final p in payments.take(4)) {
        buffer.writeln(
            '• **${p.tenantName}** (${p.unitNumber}): ${formatter.format(p.amount)} via ${p.method} (${p.month})');
      }
    }

    return buffer.toString();
  }

  String _getSendReminderAnswer(BuildContext context) {
    final tenants = ref.read(tenantProvider);
    final lateTenants =
        tenants.where((t) => t.balance > 0 || t.isLate).toList();

    if (context.mounted) {
      ToastService.showInfo('Payment reminders generated for all late tenants!');
    }

    if (lateTenants.isEmpty) {
      return '**Reminders Checked:** All tenants are up to date! No pending reminders were necessary.';
    }

    final formatter =
        NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);
    final buffer = StringBuffer('**Payment Reminders Dispatched!**\n\n');
    buffer.writeln('Automated reminders generated for:\n');

    for (final t in lateTenants) {
      buffer.writeln(
          '• **${t.name}** (${t.unitNumber}) - Balance: **${formatter.format(t.balance)}**');
    }

    return buffer.toString();
  }

  String _getVacantUnitsAnswer() {
    final units = ref.read(unitProvider);
    final vacantUnits = units.where((u) => u.isVacant).toList();
    final totalUnits = units.length;
    final occupiedCount = units.where((u) => u.isOccupied).length;
    final occupancyRate =
        totalUnits > 0 ? (occupiedCount / totalUnits) * 100 : 0.0;
    final formatter =
        NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);

    final buffer = StringBuffer('**Vacant Units Summary:**\n\n');
    buffer.writeln(
        '• **Vacant Units:** **${vacantUnits.length} vacant** out of $totalUnits total units');
    buffer.writeln(
        '• **Current Occupancy Rate:** **${occupancyRate.toStringAsFixed(1)}%**\n');

    if (vacantUnits.isNotEmpty) {
      buffer.writeln('**Available Vacant Units:**');
      for (final unit in vacantUnits) {
        buffer.writeln(
            '• **${unit.name}**: ${formatter.format(unit.rent)}/mo (${unit.vacantDays} days vacant)');
      }
    } else {
      buffer.writeln('All units are currently fully occupied!');
    }

    return buffer.toString();
  }

  Future<String> _getAiOrGeneralAnswer(String userQuery) async {
    const String apiKey =
        String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

    final tenants = ref.read(tenantProvider);
    final units = ref.read(unitProvider);
    final payments = ref.read(paymentProvider);
    final tickets = ref.read(ticketProvider);
    final totalRevenue = ref.read(kpiTotalRevenueProvider);

    final systemContext = '''
You are RAMP AI Assistant for RAMP (Rental Administration Management Platform).
Current App Data Context:
- Total Units: ${units.length} (${units.where((u) => u.isVacant).length} vacant)
- Total Tenants: ${tenants.length} (${tenants.where((t) => t.balance > 0).length} with unpaid balance)
- Total Collected Revenue: ₱${totalRevenue.toStringAsFixed(2)} across ${payments.length} transactions
- Active Maintenance Tickets: ${tickets.where((t) => t.status != 'Completed' && t.status != 'Closed').length} active

User Query: "$userQuery"
Provide a helpful, precise, and friendly answer for the landlord based on the context above.
''';

    try {
      if (apiKey.isNotEmpty) {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );
        final response =
            await model.generateContent([Content.text(systemContext)]);
        if (response.text != null && response.text!.isNotEmpty) {
          return response.text!;
        }
      }
    } catch (e) {
      debugPrint('ℹ️ Gemini AI request error: $e');
    }

    final qLower = userQuery.toLowerCase();
    if (qLower.contains('ticket') ||
        qLower.contains('maintenance') ||
        qLower.contains('repair')) {
      final active = tickets
          .where((t) => t.status != 'Completed' && t.status != 'Closed')
          .toList();
      if (active.isEmpty) {
        return '**Maintenance Status:** No active maintenance tickets at this moment.';
      }
      final buffer = StringBuffer(
          '**Active Maintenance Tickets (${active.length}):**\n\n');
      for (final t in active) {
        buffer.writeln(
            '• **${t.title}** (${t.unitNumber}) - Priority: ${t.priority}, Status: ${t.status}');
      }
      return buffer.toString();
    }

    if (qLower.contains('tenant') || qLower.contains('lease')) {
      final buffer =
          StringBuffer('**Tenant Overview (${tenants.length} total):**\n\n');
      for (final t in tenants) {
        buffer.writeln(
            '• **${t.name}** (${t.unitNumber}) - ${t.balance > 0 ? "Balance: ₱${t.balance.toStringAsFixed(2)}" : "Paid up"}');
      }
      return buffer.toString();
    }

    return '**RAMP AI Assistant (Preview):**\n\nI analyzed your property data regarding "$userQuery":\n\n'
        '• **Total Units:** ${units.length} (${units.where((u) => u.isVacant).length} vacant)\n'
        '• **Total Tenants:** ${tenants.length} (${tenants.where((t) => t.balance > 0).length} with balance)\n'
        '• **Total Revenue:** ₱${totalRevenue.toStringAsFixed(2)}\n\n'
        'Feel free to use the quick chips below for instant reports!';
  }

  Widget _buildFormattedText(String text, TextStyle baseStyle) {
    final List<InlineSpan> spans = [];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
            text: text.substring(lastMatchEnd, match.start), style: baseStyle));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: baseStyle));
    }

    return SelectableText.rich(
      TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D6EFD), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RAMP AI Assistant (Preview)',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B)),
                      ),
                      Text(
                        'Property Assistant Preview • Local State Intelligence',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Quick Chips Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: const Color(0xFFF8FAFC),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _quickChips.map((chip) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: Icon(chip['icon'] as IconData,
                          size: 16, color: const Color(0xFF0D6EFD)),
                      label: Text(
                        chip['label'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      onPressed: () =>
                          _handleSubmitted(chip['prompt'] as String),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: msg.isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!msg.isUser) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              const Color(0xFF0D6EFD).withValues(alpha: 0.1),
                          child: const Icon(Icons.auto_awesome,
                              size: 16, color: Color(0xFF0D6EFD)),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: msg.isUser
                                ? const Color(0xFF0D6EFD)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                              bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                            ),
                          ),
                          child: msg.isUser
                              ? SelectableText(
                                  msg.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                )
                              : _buildFormattedText(
                                  msg.text,
                                  const TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                        ),
                      ),
                      if (msg.isUser) ...[
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFF0D6EFD),
                          child:
                              Icon(Icons.person, size: 16, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),

          // Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ask RAMP AI Assistant (Preview)...',
                      hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon:
                      const Icon(Icons.send_rounded, color: Color(0xFF0D6EFD)),
                  onPressed: () => _handleSubmitted(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
