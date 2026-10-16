import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Makes the [HopIcon]s inside it hop whenever the pointer enters this area or
/// it is tapped, so hovering anywhere on a menu item or card excites its icon.
class HopRegion extends StatefulWidget {
  const HopRegion({super.key, required this.child});

  final Widget child;

  @override
  State<HopRegion> createState() => _HopRegionState();
}

class _HopRegionState extends State<HopRegion> {
  final _pulse = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _pulse.value++,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _pulse.value++,
        child: _HopScope(pulse: _pulse, child: widget.child),
      ),
    );
  }
}

class _HopScope extends InheritedWidget {
  const _HopScope({required this.pulse, required super.child});

  final ValueNotifier<int> pulse;

  @override
  bool updateShouldNotify(_HopScope old) => old.pulse != pulse;
}

/// An icon (or icon tile) that does a small excited hop: a jump with a wiggle,
/// then two smaller bounces. Triggered by the surrounding [HopRegion], or by
/// hovering or tapping the icon itself when there is none. Skipped when the
/// device asks for reduced motion.
class HopIcon extends StatefulWidget {
  const HopIcon({super.key, required this.child, this.height = 8});

  final Widget child;

  /// How high the first hop goes, in logical pixels.
  final double height;

  @override
  State<HopIcon> createState() => _HopIconState();
}

class _HopIconState extends State<HopIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  ValueNotifier<int>? _pulse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pulse = context.dependOnInheritedWidgetOfExactType<_HopScope>()?.pulse;
    if (pulse != _pulse) {
      _pulse?.removeListener(_hop);
      _pulse = pulse;
      _pulse?.addListener(_hop);
    }
  }

  @override
  void dispose() {
    _pulse?.removeListener(_hop);
    _controller.dispose();
    super.dispose();
  }

  void _hop() {
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final animated = AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        final fade = 1 - t;
        // Three hops that get smaller, a wiggle that settles, and a quick grow.
        final y = -widget.height * (math.sin(3 * math.pi * t)).abs() * fade;
        final angle = 0.22 * math.sin(4 * math.pi * t) * fade;
        final scale = 1 + 0.14 * math.sin(math.pi * t) * fade;
        return Transform.translate(
          offset: Offset(0, y),
          child: Transform.rotate(angle: angle, child: Transform.scale(scale: scale, child: child)),
        );
      },
    );

    if (_pulse != null) return animated;
    // No surrounding region: the icon reacts to its own hover and tap.
    return MouseRegion(
      onEnter: (_) => _hop(),
      child: Listener(onPointerDown: (_) => _hop(), child: animated),
    );
  }
}
