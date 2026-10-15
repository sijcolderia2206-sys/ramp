// lib/widgets/neumorphic_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../core/utils/debouncer.dart';

/// Formats monetary values with commas as thousands separators and exactly two decimal places.
String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 2);
  return formatter.format(amount);
}

/// Helper for generating Neumorphic Soft UI decorations
class NeumorphicDecoration {
  static const Color baseColor = Color(0xFFE0E5EC);
  static const Color darkShadow = Color(0xFFA3B1C6);
  static const Color lightShadow = Colors.white;

  /// Elevated / Convex decoration (Soft drop shadow)
  static BoxDecoration convex({
    double borderRadius = 16.0,
    Color color = baseColor,
    BoxShape shape = BoxShape.rectangle,
    BorderRadiusGeometry? customBorderRadius,
  }) {
    return BoxDecoration(
      color: color,
      shape: shape,
      borderRadius: shape == BoxShape.circle ? null : (customBorderRadius ?? BorderRadius.circular(borderRadius)),
      boxShadow: const [
        BoxShadow(
          color: lightShadow,
          offset: Offset(-4, -4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: darkShadow,
          offset: Offset(4, 4),
          blurRadius: 8,
        ),
      ],
    );
  }

  /// Recessed / Inset decoration (Sunken/concave effect)
  static BoxDecoration inset({
    double borderRadius = 16.0,
    Color color = baseColor,
    BoxShape shape = BoxShape.rectangle,
    BorderRadiusGeometry? customBorderRadius,
  }) {
    return BoxDecoration(
      color: color,
      shape: shape,
      borderRadius: shape == BoxShape.circle ? null : (customBorderRadius ?? BorderRadius.circular(borderRadius)),
      boxShadow: const [
        BoxShadow(
          color: darkShadow,
          offset: Offset(2, 2),
          blurRadius: 4,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: lightShadow,
          offset: Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ],
    );
  }
}

/// Generic Neumorphic Container Widget supporting both Convex and Inset states
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool isInset;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final BoxShape shape;
  final Color backgroundColor;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.isInset = false,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.shape = BoxShape.rectangle,
    this.backgroundColor = NeumorphicDecoration.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = isInset
        ? NeumorphicDecoration.inset(
            borderRadius: borderRadius,
            color: backgroundColor,
            shape: shape,
          )
        : NeumorphicDecoration.convex(
            borderRadius: borderRadius,
            color: backgroundColor,
            shape: shape,
          );

    final content = RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        decoration: decoration,
        child: child,
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        child: content,
      ),
    );
  }
}

/// Neumorphic Search Bar Widget with 300ms Debouncer
class NeumorphicSearchBar extends StatefulWidget {
  final String hintText;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const NeumorphicSearchBar({
    super.key,
    required this.hintText,
    this.initialValue = '',
    required this.onChanged,
    this.onClear,
  });

  @override
  State<NeumorphicSearchBar> createState() => _NeumorphicSearchBarState();
}

class _NeumorphicSearchBarState extends State<NeumorphicSearchBar> {
  late TextEditingController _controller;
  late Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _debouncer = Debouncer(milliseconds: 300);
  }

  @override
  void didUpdateWidget(covariant NeumorphicSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text && oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NeumorphicContainer(
      isInset: true,
      borderRadius: 16.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.search, color: RampTheme.textSecondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 14, color: RampTheme.textPrimary, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: RampTheme.textSecondary, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (val) {
                setState(() {});
                _debouncer.run(() => widget.onChanged(val));
              },
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                setState(() {});
                widget.onChanged('');
                if (widget.onClear != null) widget.onClear!();
              },
              child: const Icon(Icons.close, color: RampTheme.textSecondary, size: 18),
            ),
        ],
      ),
    );
  }
}

/// Neumorphic Filter Chip with Active (Inset) and Inactive (Convex) visual states
class NeumorphicFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const NeumorphicFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: isSelected
            ? NeumorphicDecoration.inset(
                borderRadius: 20.0,
                color: RampTheme.primaryBlue.withValues(alpha: 0.12),
              )
            : NeumorphicDecoration.convex(
                borderRadius: 20.0,
                color: NeumorphicDecoration.baseColor,
              ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? RampTheme.primaryBlue : RampTheme.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? RampTheme.primaryBlue : RampTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small Recessed Neumorphic Pill Badge for Statuses and Priorities
class NeumorphicPill extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color? backgroundColor;
  final IconData? icon;

  const NeumorphicPill({
    super.key,
    required this.text,
    required this.textColor,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: NeumorphicDecoration.inset(
        borderRadius: 12.0,
        color: backgroundColor ?? textColor.withValues(alpha: 0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Convex Neumorphic Action Button with Loading and Pressed States
class NeumorphicButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const NeumorphicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.height = 48.0,
    this.borderRadius = 16.0,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final primaryColor = widget.backgroundColor ?? RampTheme.primaryBlue;
    final fgColor = widget.textColor ?? Colors.white;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: widget.height,
        alignment: Alignment.center,
        decoration: _isPressed || isDisabled
            ? NeumorphicDecoration.inset(
                borderRadius: widget.borderRadius,
                color: isDisabled ? NeumorphicDecoration.baseColor : primaryColor,
              )
            : NeumorphicDecoration.convex(
                borderRadius: widget.borderRadius,
                color: primaryColor,
              ),
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: fgColor, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: isDisabled ? RampTheme.textSecondary : fgColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Neumorphic Inset Text Field with Form validation support
class NeumorphicTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool readOnly;
  final bool obscureText;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization textCapitalization;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const NeumorphicTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.obscureText = false,
    this.enabled = true,
    this.inputFormatters,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.none,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (stateVal) {
        final valueToValidate = controller != null ? controller!.text : stateVal;
        return validator?.call(valueToValidate);
      },
      initialValue: controller?.text,
      autovalidateMode: autovalidateMode,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: RampTheme.textPrimary,
                ),
              ),
            ),
            NeumorphicContainer(
              isInset: true,
              borderRadius: 14.0,
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, color: RampTheme.primaryBlue, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      keyboardType: keyboardType,
                      maxLines: maxLines,
                      readOnly: readOnly,
                      obscureText: obscureText,
                      enabled: enabled,
                      inputFormatters: inputFormatters,
                      textCapitalization: textCapitalization,
                      onTap: onTap,
                      style: TextStyle(
                        fontSize: 14,
                        color: enabled ? RampTheme.textPrimary : RampTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: const TextStyle(color: RampTheme.textSecondary, fontSize: 13),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (val) {
                        state.didChange(val);
                        if (onChanged != null) onChanged!(val);
                      },
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    suffixIcon!,
                  ],
                ],
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(color: RampTheme.errorRed, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Neumorphic Inset Dropdown Field with Form validation support
class NeumorphicDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final IconData? prefixIcon;
  final String? hintText;

  const NeumorphicDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      validator: validator,
      initialValue: value,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: RampTheme.textPrimary,
                ),
              ),
            ),
            NeumorphicContainer(
              isInset: true,
              borderRadius: 14.0,
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, color: RampTheme.primaryBlue, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<T>(
                        value: state.value ?? value,
                        isExpanded: true,
                        hint: hintText != null ? Text(hintText!, style: const TextStyle(color: RampTheme.textSecondary, fontSize: 13)) : null,
                        icon: const Icon(Icons.arrow_drop_down, color: RampTheme.primaryBlue),
                        style: const TextStyle(
                          fontSize: 14,
                          color: RampTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        dropdownColor: NeumorphicDecoration.baseColor,
                        items: items,
                        onChanged: (val) {
                          state.didChange(val);
                          if (onChanged != null) onChanged!(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(color: RampTheme.errorRed, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Neumorphic Stepper Widget for numeric inputs (1 - 31)
class NeumorphicStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String label;

  const NeumorphicStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RampTheme.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: value > min ? () => onChanged(value - 1) : null,
              child: NeumorphicContainer(
                isInset: false,
                borderRadius: 12,
                width: 36,
                height: 36,
                child: const Icon(Icons.remove, size: 18, color: RampTheme.primaryBlue),
              ),
            ),
            const SizedBox(width: 8),
            NeumorphicContainer(
              isInset: true,
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                '$value',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: RampTheme.primaryBlue),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: value < max ? () => onChanged(value + 1) : null,
              child: NeumorphicContainer(
                isInset: false,
                borderRadius: 12,
                width: 36,
                height: 36,
                child: const Icon(Icons.add, size: 18, color: RampTheme.primaryBlue),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Neumorphic Slider Widget
class NeumorphicSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  const NeumorphicSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
            NeumorphicPill(
              text: '${value.round()} Days',
              textColor: RampTheme.primaryBlue,
            ),
          ],
        ),
        const SizedBox(height: 8),
        NeumorphicContainer(
          isInset: true,
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: RampTheme.primaryBlue,
              inactiveTrackColor: Colors.transparent,
              thumbColor: RampTheme.primaryBlue,
              overlayColor: RampTheme.primaryBlue.withValues(alpha: 0.1),
              trackHeight: 8.0,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom Neumorphic Switch / Toggle Widget
class NeumorphicToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String? subtitle;

  const NeumorphicToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RampTheme.textPrimary)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: const TextStyle(fontSize: 12, color: RampTheme.textSecondary)),
              ],
            ],
          ),
        ),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 30,
            padding: const EdgeInsets.all(3),
            decoration: NeumorphicDecoration.inset(
              borderRadius: 20,
              color: value ? RampTheme.primaryBlue.withValues(alpha: 0.2) : NeumorphicDecoration.baseColor,
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: NeumorphicDecoration.convex(
                  borderRadius: 12,
                  color: value ? RampTheme.primaryBlue : Colors.white,
                ),
                child: value
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : const Icon(Icons.close, size: 14, color: RampTheme.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable Destructive Action Guard Dialog for Edit/Delete Confirmations
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  String cancelLabel = 'Cancel',
  bool isDestructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: const Color(0xFFE0E5EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isDestructive ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
              color: isDestructive ? const Color(0xFFE53935) : const Color(0xFF2196F3),
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF506070),
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              cancelLabel,
              style: const TextStyle(
                color: Color(0xFF708090),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? const Color(0xFFE53935) : const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              confirmLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Helper for Global UI Feedback (Neumorphic SnackBar and Error Dialogs)
class NeumorphicFeedback {
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E5EC),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFA3B1C6),
                offset: Offset(4, 4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-4, -4),
                blurRadius: 8,
              ),
            ],
            border: Border.all(
              color: isError ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                color: isError ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isError ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFE0E5EC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFE53935), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2C3E50)),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Color(0xFF506070)),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C3E50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}




