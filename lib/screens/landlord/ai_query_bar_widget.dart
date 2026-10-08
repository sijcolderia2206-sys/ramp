// C:/Users/sijco/Downloads/ramp/ramp/ramp/lib/screens/landlord/ai_query_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/ramp_theme.dart';
import '../../features/ai/ai_assistant_provider.dart';

class AiQueryBarWidget extends ConsumerStatefulWidget {
  const AiQueryBarWidget({super.key});

  @override
  ConsumerState<AiQueryBarWidget> createState() => _AiQueryBarWidgetState();
}

class _AiQueryBarWidgetState extends ConsumerState<AiQueryBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      ref.read(aiAssistantProvider.notifier).askQuestion(text);
      _controller.clear();
      // Optional: Hide keyboard
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RampTheme.spacing16, vertical: RampTheme.spacing8),
      decoration: BoxDecoration(
        color: RampTheme.cardBackground,
        borderRadius: BorderRadius.circular(32), // Pill shape
        boxShadow: RampTheme.standardShadow,
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: RampTheme.primaryBlue),
          const SizedBox(width: RampTheme.spacing16),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ask Gemini about your properties...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: RampTheme.primaryBlue),
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
