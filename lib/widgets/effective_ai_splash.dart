import 'package:flutter/material.dart';

/// The launch intro: a luminous blue-white splash where the Effective AI
/// emblem appears, settles with a soft light sweep, then dissolves as the real
/// app fades in underneath. Plays once per app launch (the website's version
/// in site/index.html plays once per browser session).
///
/// Timeline (1.5 s; phases overlap so it reads as one scene):
/// * 0–450 ms: emblem fades in, scales 0.92 → 1 and rises 10 px; cyan glow appears.
/// * 450–1,000 ms: emblem holds; a soft light sweep crosses it (inside its outline only).
/// * 700–1,500 ms: the app fades in underneath while the splash background
///   fades out; the emblem fades and scales 1 → 0.96.
///
/// Reduced motion: no scaling, rising or sweep. The emblem shows still and the
/// splash cross-fades into the app in 600 ms. The splash blocks taps only until
/// the app starts to appear, then lets everything through, and it leaves the
/// widget tree when it finishes. The app underneath is built from the start, so
/// nothing is delayed.
class EffectiveAiSplash extends StatefulWidget {
  const EffectiveAiSplash({super.key, required this.child, this.enabled = true});

  final Widget child;

  /// False skips the intro (used by tests that drive the app directly).
  final bool enabled;

  static const duration = Duration(milliseconds: 1500);
  static const reducedDuration = Duration(milliseconds: 600);
  static const logoAsset = 'assets/images/logo.png';
  static const logoSize = 112.0;

  static bool _played = false;

  /// Lets a test play the intro again.
  @visibleForTesting
  static void resetForTest() => _played = false;

  @override
  State<EffectiveAiSplash> createState() => _EffectiveAiSplashState();
}

class _EffectiveAiSplashState extends State<EffectiveAiSplash> with SingleTickerProviderStateMixin {
  // Overlap points on the 0–1 timeline (fractions of 1.5 s).
  static const _logoIn = Interval(0, 0.30, curve: Curves.easeOutCubic); // 0–450 ms
  static const _sweep = Interval(0.30, 0.67, curve: Curves.easeInOutSine); // 450–1,000 ms
  static const _appIn = Interval(0.47, 0.93, curve: Curves.easeOutCubic); // 700–1,400 ms
  static const _backdropOut = Interval(0.47, 1, curve: Curves.easeInOutCubic); // 700–1,500 ms
  static const _logoOut = Interval(0.53, 0.93, curve: Curves.easeInCubic); // 800–1,400 ms
  static const _letThrough = 0.47; // taps reach the app once it starts to appear

  late final AnimationController _controller = AnimationController(vsync: this);
  late bool _showing = widget.enabled && !EffectiveAiSplash._played;
  bool _reduced = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_showing || _started) return;
    _started = true;
    EffectiveAiSplash._played = true;
    _reduced = MediaQuery.disableAnimationsOf(context);
    // Decode the emblem before the first frame of the intro so it never pops in.
    precacheImage(const AssetImage(EffectiveAiSplash.logoAsset), context).catchError((_) {});
    _controller
      ..duration = _reduced ? EffectiveAiSplash.reducedDuration : EffectiveAiSplash.duration
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) setState(() => _showing = false);
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _at(Interval interval) => interval.transform(_controller.value);

  @override
  Widget build(BuildContext context) {
    // The app stays in the same place in the tree before, during and after the
    // intro, so it keeps its state when the splash leaves.
    final app = KeyedSubtree(key: const ValueKey('app'), child: widget.child);
    if (!_showing) {
      return Stack(children: [app, const SizedBox.shrink()]);
    }
    return AnimatedBuilder(
      animation: _controller,
      child: app,
      builder: (context, app) {
        final t = _controller.value;
        final appOpacity = _reduced ? Curves.easeOut.transform(t) : _at(_appIn);
        final backdrop = 1 - (_reduced ? Curves.easeIn.transform(t) : _at(_backdropOut));
        return Stack(
          children: [
            Opacity(opacity: appOpacity, child: app),
            IgnorePointer(
              ignoring: t >= _letThrough,
              child: Semantics(
                label: 'Effective AI',
                image: true,
                child: _reduced ? _reducedSplash(backdrop) : _splash(backdrop),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _splash(double backdrop) {
    final logoIn = _at(_logoIn);
    final logoOut = _at(_logoOut);
    final opacity = (logoIn * (1 - logoOut)).clamp(0.0, 1.0);
    final scale = 0.92 + 0.08 * logoIn - 0.04 * logoOut;
    final rise = 10 * (1 - logoIn);
    final sweep = _controller.value <= _sweep.begin || _controller.value >= _sweep.end ? null : _at(_sweep);
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(opacity: backdrop, child: const _LuminousBackdrop()),
        Center(
          child: Transform.translate(
            offset: Offset(0, rise),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: _Emblem(sweep: sweep),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _reducedSplash(double backdrop) => Opacity(
        opacity: backdrop,
        child: const Stack(
          fit: StackFit.expand,
          children: [_LuminousBackdrop(), Center(child: _Emblem(sweep: null))],
        ),
      );
}

/// Soft white to icy-blue light, brightest just above the centre.
class _LuminousBackdrop extends StatelessWidget {
  const _LuminousBackdrop();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.15),
            radius: 1.25,
            colors: [Color(0xFFFFFFFF), Color(0xFFF2F8FF), Color(0xFFE3EFFC)],
            stops: [0, 0.45, 1],
          ),
        ),
      );
}

/// The emblem over a restrained cyan glow. [sweep] (0–1) moves a soft band of
/// light across it; the band is drawn only inside the emblem's outline, so the
/// artwork itself is never altered.
class _Emblem extends StatelessWidget {
  const _Emblem({required this.sweep});

  final double? sweep;

  @override
  Widget build(BuildContext context) {
    const size = EffectiveAiSplash.logoSize;
    Widget logo = Image.asset(
      EffectiveAiSplash.logoAsset,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      excludeFromSemantics: true,
    );
    final s = sweep;
    if (s != null) {
      final logoOnly = logo;
      logo = Stack(children: [
        logoOnly,
        ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            final x = -1.4 + 2.8 * s; // band travels from left of the emblem to its right
            return LinearGradient(
              begin: Alignment(x - 0.6, -0.4),
              end: Alignment(x + 0.6, 0.4),
              colors: const [Color(0x00FFFFFF), Color(0x70FFFFFF), Color(0x00FFFFFF)],
              stops: const [0.2, 0.5, 0.8],
            ).createShader(rect);
          },
          child: logoOnly,
        ),
      ]);
    }
    return SizedBox(
      width: size * 2.6,
      height: size * 2.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cyan glow for depth: soft and low, never neon.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0x3322D3EE), Color(0x1438BDF8), Color(0x0038BDF8)],
                stops: [0, 0.45, 1],
              ),
            ),
            child: SizedBox.expand(),
          ),
          logo,
        ],
      ),
    );
  }
}
