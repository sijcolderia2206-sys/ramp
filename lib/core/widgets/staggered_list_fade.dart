import 'package:flutter/material.dart';

/// Staggered List Item Animation Wrapper
/// Fades in and slides up individual list items sequentially based on their index.
class StaggeredListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration baseDelay;
  final Duration duration;
  final Offset offset;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.baseDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.offset = const Offset(0.0, 0.12),
  });

  @override
  Widget build(BuildContext context) {
    // Cap index offset to prevent long delays for items way down the list
    final effectiveIndex = index.clamp(0, 10);
    final delay = baseDelay * effectiveIndex;

    return TweenAnimationBuilder<double>(
      duration: duration + delay,
      curve: Curves.fastOutSlowIn,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, childWidget) {
        // Compute progress after accounting for delay ratio
        final double progress =
            (value - (delay.inMilliseconds / (duration + delay).inMilliseconds))
                .clamp(0.0, 1.0);

        final slideTween = Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).transform(progress);

        return FractionalTranslation(
          translation: slideTween,
          child: Opacity(
            opacity: progress,
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}
