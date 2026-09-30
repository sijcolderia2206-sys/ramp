// lib/core/widgets/bouncing_interactive.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../theme/ramp_theme.dart';
import 'clay_container.dart';

/// Universal Spring Bounce Interactive Component
class BouncingInteractive extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;
  final bool enableHaptics;

  const BouncingInteractive({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.98,
    this.duration = const Duration(milliseconds: 120),
    this.enableHaptics = true,
  });

  @override
  State<BouncingInteractive> createState() => _BouncingInteractiveState();
}

class _BouncingInteractiveState extends State<BouncingInteractive>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      lowerBound: 0.0,
      upperBound: 1.0 - widget.scaleFactor,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      if (widget.enableHaptics) {
        HapticFeedback.selectionClick();
      }
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Convenience Component: Flat Minimalist BounceCard for unit feed cards & tiles
class BounceCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const BounceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.backgroundColor = RampColors.surface,
    this.borderColor = RampColors.border,
    this.borderRadius = 20.0,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingInteractive(
      onTap: onTap,
      child: ClayContainer(
        margin: margin,
        padding: padding,
        color: backgroundColor,
        borderRadius: borderRadius,
        depth: 6.0,
        child: child,
      ),
    );
  }
}

/// Convenience Component: BouncePillButton with flat aesthetics and morphing states
enum BounceButtonState { idle, loading, success }

class BouncePillButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final BounceButtonState buttonState;
  final IconData? icon;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;

  const BouncePillButton({
    super.key,
    required this.text,
    this.onPressed,
    this.buttonState = BounceButtonState.idle,
    this.icon,
    this.height = 52.0,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<BouncePillButton> createState() => _BouncePillButtonState();
}

class _BouncePillButtonState extends State<BouncePillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _morphController;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInteractable = widget.onPressed != null &&
        widget.buttonState == BounceButtonState.idle;

    final bg = widget.buttonState == BounceButtonState.success
        ? RampColors.success
        : (isInteractable
            ? (widget.backgroundColor ?? RampColors.primary)
            : RampColors.border);

    final fg = isInteractable || widget.buttonState == BounceButtonState.success
        ? (widget.textColor ?? Colors.white)
        : RampColors.mutedText;

    Widget stateContent;
    switch (widget.buttonState) {
      case BounceButtonState.loading:
        stateContent = SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(fg),
          ),
        );
        break;
      case BounceButtonState.success:
        stateContent = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Success!',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case BounceButtonState.idle:
        stateContent = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: fg, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }

    return ClayContainer(
      height: widget.height,
      width: double.infinity,
      color: bg,
      borderRadius: widget.height / 2,
      depth: isInteractable ? 8.0 : 2.0,
      onTap: isInteractable ? widget.onPressed : null,
      alignment: Alignment.center,
      child: stateContent,
    );
  }
}

/// Convenience Component: BounceNavTab for squash-and-stretch bottom tab bar items
class BounceNavTab extends StatefulWidget {
  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;

  const BounceNavTab({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<BounceNavTab> createState() => _BounceNavTabState();
}

class _BounceNavTabState extends State<BounceNavTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _squashController;
  late Animation<double> _scaleX;
  late Animation<double> _scaleY;

  @override
  void initState() {
    super.initState();
    _squashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scaleX = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.12), weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.12, end: 1.0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _squashController, curve: Curves.easeOutCubic));

    _scaleY = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 0.88), weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.88, end: 1.0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _squashController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _squashController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    _squashController.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _squashController,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..scaleByVector3(Vector3(_scaleX.value, _scaleY.value, 1.0)),
            alignment: Alignment.center,
            child: widget.child,
          );
        },
      ),
    );
  }
}
