import 'package:flutter/material.dart';

/// Screen transition that turns content like a book page hinged on the left edge.
/// Incoming screens swing in and fade up; outgoing screens swing away (the same
/// animation run in reverse by AnimatedSwitcher).
class PageTurnTransition extends StatelessWidget {
  const PageTurnTransition({super.key, required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final v = Curves.easeOutCubic.transform(animation.value);
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0008)
              ..rotateY(-(1 - v) * 1.1),
            child: child,
          ),
        );
      },
    );
  }
}
