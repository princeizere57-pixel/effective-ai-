import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A silent, looping clip stretched behind a section (the classic "video
/// background"), under a [shade] that keeps the section's text readable. The
/// clip is softly blurred so the film's own on-screen text never competes with
/// the section's.
///
/// For a good experience the clip loads only when the section comes near the
/// screen, pauses when it scrolls away or the app goes to the background, and
/// shows its still frame instead where video can't play (Windows desktop,
/// tests) or when the device asks for reduced motion.
class SectionVideoBackground extends StatefulWidget {
  const SectionVideoBackground({
    super.key,
    required this.clip,
    required this.shade,
    required this.child,
    this.borderRadius = BorderRadius.zero,
  });

  /// Clip name: assets/video/[clip].mp4 with its still frame [clip].jpg.
  final String clip;
  final Gradient shade;
  final Widget child;
  final BorderRadius borderRadius;

  @override
  State<SectionVideoBackground> createState() => _SectionVideoBackgroundState();
}

class _SectionVideoBackgroundState extends State<SectionVideoBackground> with WidgetsBindingObserver {
  /// How far outside the screen a section still counts as "near".
  static const _margin = 200.0;

  VideoPlayerController? _controller;
  bool _loading = false;
  bool _near = false;
  bool _foreground = true;
  ScrollPosition? _position;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (!identical(position, _position)) {
      _position?.removeListener(_check);
      _position = position?..addListener(_check);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _foreground ? _check() : _controller?.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _position?.removeListener(_check);
    _controller?.dispose();
    super.dispose();
  }

  void _check() {
    if (!mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final screen = MediaQuery.sizeOf(context).height;
    _near = top < screen + _margin && top + box.size.height > -_margin;
    if (_near && _foreground && !MediaQuery.disableAnimationsOf(context)) {
      _play();
    } else {
      _controller?.pause();
    }
  }

  Future<void> _play() async {
    final existing = _controller;
    if (existing != null) {
      if (!existing.value.isPlaying) await existing.play();
      return;
    }
    if (_loading) return;
    _loading = true;
    final controller = VideoPlayerController.asset(
      'assets/video/${widget.clip}.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await controller.initialize();
      await controller.setVolume(0);
      await controller.setLooping(true);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
      if (_near && _foreground) await controller.play();
    } catch (_) {
      // No video support here: the still frame stays.
      await controller.dispose();
    } finally {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final media = controller != null && controller.value.isInitialized
        ? FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          )
        : Image.asset('assets/video/${widget.clip}.jpg', fit: BoxFit.cover);
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: Color(0xFF0A0D16)),
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Transform.scale(scale: 1.05, child: media),
                    ),
                    DecoratedBox(decoration: BoxDecoration(gradient: widget.shade)),
                  ],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
