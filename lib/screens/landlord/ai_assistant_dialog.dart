// lib/screens/landlord/ai_assistant_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme.dart';
import '../../providers/landlord_providers.dart';

class RampAiAssistantDialog extends ConsumerStatefulWidget {
  const RampAiAssistantDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RampAiAssistantDialog(),
    );
  }

  @override
  ConsumerState<RampAiAssistantDialog> createState() => _RampAiAssistantDialogState();
}

class _RampAiAssistantDialogState extends ConsumerState<RampAiAssistantDialog> {
  final TextEditingController _queryController = TextEditingController();

  final List<String> _quickPrompts = [
    "What's my vacancy rate?",
    "Show me Net Operating Income",
    "Who has overdue rent?",
    "Draft rent reminder for tenants",
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _submitQuery(String query) {
    if (query.trim().isEmpty) return;
    ref.read(geminiAssistantProvider.notifier).askAssistant(query);
    _queryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(geminiAssistantProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: RampTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RampTheme.spacing24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: RampTheme.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/ai_assistant.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      RampTheme.primaryBlue,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: RampTheme.spacing12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RAMP AI Property Assistant',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'Powered by Gemini Intelligence',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(),

          // Body Response
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(RampTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested Quick Queries',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: RampTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: RampTheme.spacing8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickPrompts.map((prompt) {
                      return ActionChip(
                        label: Text(prompt),
                        backgroundColor: RampTheme.scaffoldBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onPressed: () => _submitQuery(prompt),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: RampTheme.spacing24),

                  aiState.when(
                    data: (response) {
                      if (response.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(RampTheme.spacing24),
                          decoration: BoxDecoration(
                            color: RampTheme.scaffoldBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, color: RampTheme.primaryBlue),
                              const SizedBox(width: RampTheme.spacing12),
                              Expanded(
                                child: Text(
                                  'Ask me anything about your portfolio, revenues, vacancy rates, or draft tenant messages.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Container(
                        padding: const EdgeInsets.all(RampTheme.spacing16),
                        decoration: BoxDecoration(
                          color: RampTheme.primaryBlue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: RampTheme.primaryBlue.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/ai_assistant.svg',
                                  width: 18,
                                  height: 18,
                                  colorFilter: const ColorFilter.mode(
                                    RampTheme.primaryBlue,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Gemini Analysis',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: RampTheme.primaryBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: RampTheme.spacing12),
                            SelectableText(
                              response,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    color: RampTheme.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(RampTheme.spacing32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => Container(
                      padding: const EdgeInsets.all(RampTheme.spacing16),
                      decoration: BoxDecoration(
                        color: RampTheme.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Error processing query: $err',
                        style: const TextStyle(color: RampTheme.errorRed),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar Input
          Padding(
            padding: const EdgeInsets.all(RampTheme.spacing16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: InputDecoration(
                      hintText: 'Ask Gemini AI about your properties...',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset(
                          'assets/icons/search.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            RampTheme.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    onSubmitted: _submitQuery,
                  ),
                ),
                const SizedBox(width: RampTheme.spacing8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: RampTheme.primaryBlue,
                    padding: const EdgeInsets.all(14),
                  ),
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () => _submitQuery(_queryController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
