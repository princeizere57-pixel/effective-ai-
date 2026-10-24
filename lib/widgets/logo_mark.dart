import 'package:flutter/material.dart';

/// The Effective AI symbol: a blue-teal figure reaching for an open book.
/// Transparent background, so it sits on light and dark surfaces alike.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.medium,
        semanticLabel: 'Effective AI',
      );
}
