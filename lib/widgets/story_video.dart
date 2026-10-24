import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// The Effective AI story film, playing silently on a loop.
///
/// The still image shows while the film loads, and stays where video can't
/// play (the Windows desktop app, tests). People who ask for reduced motion get
/// the still image with a play button instead of autoplay.
class StoryVideo extends StatefulWidget {
  const StoryVideo({super.key});

  static const asset = 'assets/video/effective-ai-story.mp4';
  static const poster = 'assets/video/effective-ai-story.jpg';

  /// The film is 1920 × 972 (its letterbox bars were cropped off).
  static const aspectRatio = 1920 / 972;

  @override
  State<StoryVideo> createState() => _StoryVideoState();
}

class _StoryVideoState extends State<StoryVideo> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Reduced motion: wait for the learner to press play.
    if (!MediaQuery.disableAnimationsOf(context)) _load(autoplay: true);
  }

  Future<void> _load({required bool autoplay}) async {
    final controller = VideoPlayerController.asset(
      StoryVideo.asset,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setVolume(0);
      await controller.setLooping(true);
      if (autoplay || mounted) await controller.play();
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      // No video support on this platform: keep showing the still image.
      if (identical(_controller, controller)) _controller = null;
      await controller.dispose();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return AspectRatio(
      aspectRatio: StoryVideo.aspectRatio,
      child: Semantics(
        label: 'Effective AI story film: a student goes from late-night cramming to exam-ready with their own course',
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black),
            Image.asset(StoryVideo.poster, fit: BoxFit.cover),
            if (_ready && controller != null)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            if (!_ready && controller == null && MediaQuery.disableAnimationsOf(context))
              Center(
                child: IconButton.filled(
                  onPressed: () => _load(autoplay: true),
                  iconSize: 32,
                  tooltip: 'Play the film',
                  icon: const Icon(Icons.play_arrow),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
