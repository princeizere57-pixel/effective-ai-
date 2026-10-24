import 'package:flutter/material.dart';

/// Wraps a menu item or card that contains a [HopIcon].
///
/// Icons no longer hop on hover or tap, so this simply shows its child. It is
/// kept so the screens that use it don't need changing.
class HopRegion extends StatelessWidget {
  const HopRegion({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// An icon (or icon tile) inside a [HopRegion]. Shown still: no hop animation.
class HopIcon extends StatelessWidget {
  const HopIcon({super.key, required this.child, this.height = 8});

  final Widget child;

  /// Unused; kept for existing callers.
  final double height;

  @override
  Widget build(BuildContext context) => child;
}
