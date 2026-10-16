import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';

const _lineColors = [AppColors.violet, AppColors.blue, AppColors.green, AppColors.amber];

/// Loading indicator: an open book whose right page fills with colored lines
/// while a page turns over the spine, on repeat.
class BookLoader extends StatefulWidget {
  const BookLoader({super.key, this.label, this.pageWidth = 56});

  final String? label;
  final double pageWidth;

  @override
  State<BookLoader> createState() => _BookLoaderState();
}

class _BookLoaderState extends State<BookLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final w = widget.pageWidth;
    final h = w * 1.3;

    final book = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final turn = Curves.easeInOutCubic.transform(_controller.value);
        final angle = -math.pi * turn;
        final frontVisible = angle > -math.pi / 2;

        return SizedBox(
          width: w * 2,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(left: 0, top: 0, child: _Page(width: w, height: h, isLeft: true, fill: 1)),
              Positioned(left: w, top: 0, child: _Page(width: w, height: h, isLeft: false, fill: turn)),
              // The turning page, hinged on the spine.
              Positioned(
                left: w,
                top: 0,
                child: Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateY(angle),
                  child: frontVisible
                      ? _Page(width: w, height: h, isLeft: false, fill: 0, lifted: true)
                      : Transform.flip(
                          flipX: true,
                          child: _Page(width: w, height: h, isLeft: true, fill: 1, lifted: true),
                        ),
                ),
              ),
              Positioned(
                left: w - 1,
                top: 4,
                bottom: 4,
                child: Container(width: 2, color: p.border),
              ),
            ],
          ),
        );
      },
    );

    return Semantics(
      label: widget.label ?? 'Loading',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          book,
          if (widget.label != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.label!,
              style: TextStyle(color: p.mutedForeground, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.width,
    required this.height,
    required this.isLeft,
    required this.fill,
    this.lifted = false,
  });

  final double width;
  final double height;
  final bool isLeft;

  /// 0 = all lines grey, 1 = all lines fully colored.
  final double fill;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    const corner = Radius.circular(8);
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.fromLTRB(isLeft ? 8 : 10, 10, isLeft ? 10 : 8, 10),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? corner : Radius.zero,
          right: isLeft ? Radius.zero : corner,
        ),
        boxShadow: lifted
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < _lineColors.length; i++)
            _Line(
              color: _lineColors[i],
              base: p.shimmerBase,
              // Lines fill one after another as `fill` goes from 0 to 1.
              fill: (fill * 1.6 - i * 0.2).clamp(0.0, 1.0),
              length: i.isEven ? 1 : 0.7,
            ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.color, required this.base, required this.fill, required this.length});

  final Color color;
  final Color base;
  final double fill;
  final double length;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      width: double.infinity,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: length,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: base),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fill,
                child: ColoredBox(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
