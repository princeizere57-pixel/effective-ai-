import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Port of Tailwind `animate-slide-up` (slideUpFade, 0.9s).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _controller,
    curve: AppTheme.easeOutExpo,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final v = _t.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, 32 * (1 - v)), child: child),
        );
      },
    );
  }
}
