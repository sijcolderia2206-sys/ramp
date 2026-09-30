// lib/core/widgets/clay_container.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Flat & Minimalist Container
/// Renders a flat, clean container with rounded corners and interactive feedback.
/// Replaces the old 3D claymorphism style.
class ClayContainer extends StatefulWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final Color? color;
  final double borderRadius;
  final double depth; // Kept for API compatibility, but ignored in UI
  final double spread; // Kept for API compatibility, but ignored in UI
  final bool isConcave; // Kept for API compatibility, but ignored in UI
  final bool isInset; // Kept for API compatibility, but ignored in UI
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Border? border;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  const ClayContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.borderRadius = 20.0,
    this.depth = 8.0,
    this.spread = 0.0,
    this.isConcave = false,
    this.isInset = false,
    this.padding,
    this.margin,
    this.onTap,
    this.border,
    this.alignment,
    this.clipBehavior = Clip.none,
  });

  @override
  State<ClayContainer> createState() => _ClayContainerState();
}

class _ClayContainerState extends State<ClayContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      HapticFeedback.lightImpact();
      _animController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _animController.reverse();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = widget.color ??
        (isDark ? theme.colorScheme.surface : Colors.white);

    return AnimatedBuilder(
      animation: _pressAnimation,
      builder: (context, child) {
        final pressFactor = _pressAnimation.value;
        final scale = 1.0 - (0.02 * pressFactor); // Subtle scale effect

        Widget result = Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          padding: widget.padding,
          alignment: widget.alignment,
          clipBehavior: widget.clipBehavior,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border ??
                Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  width: 1.0,
                ),
          ),
          child: Material(
            color: baseColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            clipBehavior: widget.clipBehavior == Clip.none ? Clip.antiAlias : widget.clipBehavior,
            child: widget.padding != null || widget.alignment != null
                ? Container(
                    padding: widget.padding,
                    alignment: widget.alignment,
                    child: widget.child,
                  )
                : widget.child,
          ),
        );

        if (widget.onTap != null) {
          result = GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            behavior: HitTestBehavior.opaque,
            child: Transform.scale(
              scale: scale,
              child: result,
            ),
          );
        }

        return result;
      },
    );
  }
}
