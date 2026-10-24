import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';

/// Card surface (`bg-card rounded-lg shadow-card`).
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(24)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: p.cardShadow,
      ),
      // Its own Material so list tiles and ink ripples inside show on the card colour.
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

/// Small rounded label, e.g. a status or category. Background defaults to a tint of [color].
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, required this.color, this.background});

  final String label;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? tint(color),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Grey pill for neutral facts such as a category or duration.
class NeutralPill extends StatelessWidget {
  const NeutralPill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Pill(label: label, color: p.mutedForeground, background: p.muted);
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (action != null)
          TextButton.icon(
            onPressed: onAction,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: Text(action!),
            style: TextButton.styleFrom(foregroundColor: context.palette.primaryText),
          ),
      ],
    );
  }
}

/// Lays children out in as many equal columns as fit `minItemWidth`.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.minItemWidth,
    this.spacing = 16,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = math.max(1, ((width + spacing) / (minItemWidth + spacing)).floor());
        final itemWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final child in children) SizedBox(width: itemWidth, child: child)],
        );
      },
    );
  }
}

/// Screen title in Fraunces with a one-line description underneath.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.display(wide ? 34 : 28)),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(color: context.palette.mutedForeground, fontSize: 15)),
      ],
    );
  }
}

/// Shared look for text fields. [fill] defaults to the muted surface used inside cards.
InputDecoration fieldDecoration(
  BuildContext context, {
  required String hint,
  Widget? prefixIcon,
  Color? fill,
}) {
  final p = context.palette;
  OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.base),
        borderSide: BorderSide(color: c),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: p.subtle, fontSize: 14),
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: fill ?? p.muted,
    border: border(p.border),
    enabledBorder: border(p.border),
    focusedBorder: border(AppColors.brand),
  );
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
