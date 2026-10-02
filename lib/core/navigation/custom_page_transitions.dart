import 'package:flutter/material.dart';

/// Smooth Fade Transition Route for Screen Navigation (e.g., Full Ledger / PaymentsScreen)
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final Curve curve;

  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );
            return FadeTransition(
              opacity: fadeAnimation,
              child: child,
            );
          },
        );
}

/// Slide-up with Subtle Fade Transition Route for Bottom Sheets & Modal Views
class SlideUpFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpFadeRoute({required this.page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.08);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
