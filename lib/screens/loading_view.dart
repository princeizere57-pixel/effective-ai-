import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../widgets/book_loader.dart';
import '../widgets/common.dart';
import '../widgets/shimmer.dart';
import 'page_scaffold.dart';

/// Shown while a section loads: a shimmering outline of the page with the
/// book loader on top.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Stack(
      fit: StackFit.expand,
      children: [
        Shimmer(
          child: PageScaffold(
            builder: (context, width) => [
              const Align(alignment: Alignment.centerLeft, child: SkeletonBox(width: 260, height: 34)),
              const SizedBox(height: 10),
              const Align(alignment: Alignment.centerLeft, child: SkeletonBox(width: 340, height: 16)),
              const SizedBox(height: 28),
              ResponsiveGrid(
                minItemWidth: 200,
                children: [
                  for (var i = 0; i < 4; i++) const SkeletonBox(height: 120, radius: AppRadius.lg),
                ],
              ),
              const SizedBox(height: 24),
              ResponsiveGrid(
                minItemWidth: 260,
                children: [
                  for (var i = 0; i < 3; i++) const SkeletonBox(height: 180, radius: AppRadius.lg),
                ],
              ),
            ],
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.fromLTRB(36, 32, 36, 24),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: p.cardHoverShadow,
            ),
            child: BookLoader(label: 'Opening $label'),
          ),
        ),
      ],
    );
  }
}
