// lib/core/widgets/ramp_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/ramp_theme.dart';
import 'clay_container.dart';

/// Minimalist Flat Input Field Component
class RampTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool enabled;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;

  const RampTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldBg = enabled
        ? (isDark ? const Color(0xFF1E2124) : RampColors.surface)
        : (isDark ? const Color(0xFF141618) : RampColors.background);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE5E7E9) : RampColors.slate,
            ),
          ),
          const SizedBox(height: 6),
        ],
        ClayContainer(
          borderRadius: 18,
          depth: enabled ? 5.0 : 2.0,
          isInset: true,
          color: fieldBg,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            maxLines: maxLines,
            enabled: enabled,
            focusNode: focusNode,
            onTap: onTap,
            readOnly: readOnly,
            inputFormatters: inputFormatters,
            autovalidateMode: autovalidateMode,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? const Color(0xFFF5F5F5) : RampColors.slate,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 15,
                color: RampColors.mutedText,
                fontWeight: FontWeight.w400,
              ),
              errorText: errorText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: RampColors.primary,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: RampColors.danger,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: RampColors.danger,
                  width: 2.0,
                ),
              ),
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
