import 'package:flutter/material.dart';

import '../navigation.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';
import '../theme/theme_controller.dart';
import '../widgets/logo_mark.dart';
import 'auth_screen.dart';

/// Landing colours for the theme on screen. No blue anywhere except the
/// headline's "that A". Light (the default): black text, icons and buttons on
/// white, with grey tints. Dark: a #0A0D16 page with
/// near-black panels, black buttons, and white text and icons.
///
/// [dark] is set by [WelcomeScreen] on every build; the page is rebuilt from
/// scratch when the theme changes, so every colour below is re-read.
abstract final class _Lp {
  static bool dark = false;

  static Color _pick(int light, int darkValue) => Color(dark ? darkValue : light);

  static Color get bg => _pick(0xFFFFFFFF, 0xFF0A0D16);
  static Color get panel => _pick(0xFFF7F7F7, 0xFF0A0A0A);
  static Color get panel2 => _pick(0xFFF2F2F2, 0xFF0F0F0F);
  static Color get deep => _pick(0xFFFAFAFA, 0xFF050505);
  static Color get stage => _pick(0xFFF0F0F0, 0xFF0D0D0D);
  static Color get line => _pick(0xFFE2E2E2, 0xFF2A2A2A);
  static Color get track => _pick(0xFFE4E4E4, 0xFF2A2A2A);
  static Color get dot => _pick(0xFFCFCFCF, 0xFF3A3A3A);

  /// Headlines and strong text.
  static Color get heading => _pick(0xFF000000, 0xFFFFFFFF);
  static Color get text => _pick(0xFF000000, 0xFFF2F2F2);
  static Color get soft => _pick(0xFF000000, 0xFFA8A8A8);

  /// Button and selected-item fill: black in both themes.
  static Color get blue => const Color(0xFF000000);

  /// Icons and accent text: black in light mode, white in dark mode.
  static Color get blue2 => _pick(0xFF000000, 0xFFFFFFFF);
  static Color get paleBlue => _pick(0xFF000000, 0xFFFFFFFF);

  /// The headline's "that A": black in light mode, the original blue gradient in dark mode.
  static LinearGradient get gradient => LinearGradient(
      colors: dark
          ? [const Color(0xFF5C7DFF), const Color(0xFFA9BBFF)]
          : [const Color(0xFF000000), const Color(0xFF000000)]);
  static Color get shadow => Colors.black.withValues(alpha: dark ? 0.6 : 0.08);
  static List<Color> get missionGradient => dark
      ? [const Color(0xFF0A0A0A), const Color(0xFF1F1F1F), const Color(0xFF0F0F0F)]
      : [const Color(0xFFF5F5F5), const Color(0xFFEAEAEA), const Color(0xFFF2F2F2)];
  static Color get missionText => _pick(0xFF000000, 0xFFCFCFCF);
  static Color get pill => dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.1);

  /// Translucent fills behind tags and chips: grey in both themes.
  static Color tint([double a = 0.16]) =>
      dark ? Colors.white.withValues(alpha: a * 0.6) : Colors.black.withValues(alpha: a * 0.6);
}

/// First page, before signing up.
///
/// Positioning: an exam-readiness engine for your course. The page sells the
/// loop that joins the features (diagnose the mistake → prioritise by weakness ×
/// exam frequency → fix it in your lecturer's terms → prove it on fresh
/// questions), not the features one by one. Copy rules: never name competitors
/// or say "better than"; make mechanism claims only; no grade predictions until
/// they are calibrated (say "exam readiness" and show a range).
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _scroll = ScrollController();
  final _keys = {
    for (final id in ['loop', 'diagnose', 'mission']) id: GlobalKey()
  };

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollTo(String id) {
    final ctx = _keys[id]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 600), curve: AppTheme.easeOutExpo);
    }
  }

  @override
  Widget build(BuildContext context) {
    _Lp.dark = Theme.of(context).brightness == Brightness.dark;
    // Keyed on the theme so the whole page (widgets included) is rebuilt
    // with the new colours; the scroll position is kept by the PageStorageKey.
    return KeyedSubtree(
      key: ValueKey(_Lp.dark),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = ScreenSize.of(constraints.maxWidth);
          final pad = size.isPhone ? 16.0 : 24.0;
          return Scaffold(
            backgroundColor: _Lp.bg,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _Nav(size: size, onScroll: _scrollTo),
                  Expanded(
                    child: SingleChildScrollView(
                      key: const PageStorageKey('welcome-scroll'),
                      controller: _scroll,
                      child: DefaultTextStyle.merge(
                        style: TextStyle(color: _Lp.text),
                        child: Column(
                          children: [
                            _Hero(size: size, pad: pad),
                            KeyedSubtree(key: _keys['loop'], child: _Loop(size: size, pad: pad)),
                            for (final (i, f) in _features.indexed)
                              KeyedSubtree(
                                key: f.id == 'diagnose' ? _keys['diagnose'] : null,
                                child: _FeatureSection(feature: f, flip: i.isOdd, size: size, pad: pad),
                              ),
                            KeyedSubtree(key: _keys['mission'], child: _Mission(size: size, pad: pad)),
                            _Footer(size: size, pad: pad),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Shared pieces ─────────────────────────────────────────────────────────

/// Centres content and caps it at [max] wide.
Widget _contained({required Widget child, double max = 1200, EdgeInsets padding = EdgeInsets.zero}) => Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max),
        child: Padding(padding: padding, child: child),
      ),
    );

/// Text painted with the blue gradient.
class _GradientText extends StatelessWidget {
  const _GradientText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (b) => _Lp.gradient.createShader(Offset.zero & b.size),
        child: Text(text, style: style),
      );
}

class _LpButton extends StatelessWidget {
  const _LpButton(this.label, {required this.onPressed, this.ghost = false, this.small = false});

  final String label;
  final VoidCallback onPressed;
  final bool ghost;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: ghost ? _Lp.deep : _Lp.blue,
        foregroundColor: ghost ? _Lp.heading : Colors.white,
        padding: small
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
            : const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
        textStyle: TextStyle(fontSize: small ? 14 : 17, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(small ? 10 : 12),
          // Dark mode: black buttons get a thin grey outline so they stand out.
          side: ghost
              ? BorderSide(color: _Lp.line)
              : (_Lp.dark ? const BorderSide(color: Color(0xFF3A3A3A)) : BorderSide.none),
        ),
        elevation: 0,
      ),
      child: !ghost && !small
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward, size: 18)
              ],
            )
          : Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({this.showName = true, this.size = 36});

  final bool showName;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LogoMark(size: size),
          if (showName) ...[
            const SizedBox(width: 10),
            Text('Effective AI', style: AppTheme.display(size * 0.55, color: _Lp.heading)),
          ],
        ],
      );
}

/// A rounded pill label, like PRACTICE TESTS on the reference.
class _Badge extends StatelessWidget {
  const _Badge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(color: _Lp.tint(), borderRadius: BorderRadius.circular(999)),
        child: Text(text,
            style: TextStyle(color: _Lp.paleBlue, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.8)),
      );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        decoration: BoxDecoration(color: _Lp.tint(0.18), borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: TextStyle(color: _Lp.paleBlue, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}

/// Window chrome: three dots across the top, like a desktop app.
class _Window extends StatelessWidget {
  const _Window({required this.child, this.shadow = false});

  final Widget child;
  final bool shadow;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _Lp.deep,
          border: Border.all(color: _Lp.line),
          borderRadius: BorderRadius.circular(20),
          boxShadow: shadow ? [BoxShadow(color: _Lp.shadow, blurRadius: 90, offset: const Offset(0, 30))] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _Lp.line))),
              child: Row(children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    width: 11,
                    height: 11,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: _Lp.dot, shape: BoxShape.circle),
                  ),
              ]),
            ),
            child,
          ],
        ),
      );
}

/// One row in a mock: an outlined line with a leading icon.
class _Line extends StatelessWidget {
  const _Line({required this.child, required this.leading});

  final Widget child;
  final Widget leading;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(border: Border.all(color: _Lp.line), borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          leading,
          const SizedBox(width: 10),
          Expanded(child: DefaultTextStyle.merge(style: const TextStyle(fontSize: 13), child: child)),
        ]),
      );
}

class _Bar extends StatelessWidget {
  const _Bar(this.value);

  final double value;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 8,
          child: Stack(children: [
            Container(color: _Lp.track),
            FractionallySizedBox(
              widthFactor: value,
              child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [_Lp.blue, _Lp.blue2]))),
            ),
          ]),
        ),
      );
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: _Lp.panel2, border: Border.all(color: _Lp.line), borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 16, color: _Lp.blue2),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
            ]),
            const SizedBox(height: 6),
            Text(text, style: TextStyle(color: _Lp.soft, fontSize: 13, height: 1.5)),
          ],
        ),
      );
}

Widget _caption(String text, {Color? color}) => Text(text.toUpperCase(),
    style: TextStyle(color: color ?? _Lp.soft, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1));

Widget _gapSpaced(List<Widget> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, c) in children.indexed) ...[if (i > 0) const SizedBox(height: 12), c],
      ],
    );

Widget _muted(String text, {double size = 13}) =>
    Text(text, style: TextStyle(color: _Lp.soft, fontSize: size, height: 1.5));

/// A row of [icon] + text that wraps.
Widget _iconLine(IconData icon, String text, {Color? color}) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 1), child: Icon(icon, size: 16, color: _Lp.blue2)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: color ?? _Lp.soft, fontSize: 13, height: 1.45))),
      ],
    );

/// Mastery bars. Titled "Mastery" so a high score doesn't read as a weakness;
/// "Focus here" marks the weak ones.
Widget _mastery(List<(String, int)> rows) => _gapSpaced([
      _caption('Mastery'),
      for (final (name, v) in rows)
        Column(children: [
          Row(children: [
            Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
            if (v < 50) ...[const _Tag('Focus here'), const SizedBox(width: 8)],
            Text('$v%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
          const SizedBox(height: 6),
          _Bar(v / 100),
        ]),
    ]);

/// The differentiator: the misconception behind the wrong answers, not just the weak topic.
class _Misconception extends StatelessWidget {
  const _Misconception({this.big = false});

  final bool big;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_Lp.tint(0.22), _Lp.tint(0.08)]),
          border: Border.all(color: _Lp.blue2.withValues(alpha: 0.45)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: _gapSpaced([
          Row(children: [
            Icon(Icons.insights, size: 18, color: _Lp.paleBlue),
            const SizedBox(width: 8),
            Expanded(child: _caption('Misconception found', color: _Lp.paleBlue)),
            const _Tag('3rd time'),
          ]),
          Text('You mixed up L1 and L2 in 3 of your last 5 answers.',
              style: AppTheme.display(big ? 22 : 18, color: _Lp.heading).copyWith(height: 1.25)),
          if (big)
            for (final (day, what) in [
              ('Mon', 'Said L2 sets weights to exactly zero'),
              ('Wed', 'Chose L2 for feature selection'),
              ('Thu', 'Described lasso as a squared penalty'),
            ])
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                    width: 40, child: Text(day, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                Expanded(child: _muted(what)),
              ]),
          _iconLine(Icons.lightbulb_outline, 'Fix: a 5-minute L1 vs L2 contrast, from Lecture 6', color: _Lp.text),
        ]),
      );
}

/// A short written answer marked point by point against the rubric, with the missed point.
Widget _rubricMark() => _gapSpaced([
      Row(children: [
        Expanded(
          child: Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Past paper 2023, Q3', style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: ' · 4 marks', style: TextStyle(color: _Lp.soft)),
              ]),
              style: const TextStyle(fontSize: 13)),
        ),
        const _Tag('In 4 of 5 papers'),
      ]),
      const Text('Explain why L2 regularisation reduces overfitting.',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
            color: _Lp.deep, border: Border.all(color: _Lp.line), borderRadius: BorderRadius.circular(10)),
        child: const Text(
          'L2 adds a penalty on the size of the weights to the loss, so large weights cost more. The model ends '
          'up smoother and fits less noise in the training data.',
          style: TextStyle(fontFamily: 'Georgia', fontSize: 13, height: 1.55),
        ),
      ),
      _caption('Marked against the rubric'),
      for (final (ok, point) in [
        (true, 'Penalty on weight size added to the loss'),
        (true, 'Large weights shrink, giving a simpler model'),
        (true, 'Less fitting of noise in the training data'),
        (false, 'Links it to the bias–variance trade-off'),
      ])
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ok ? null : _Lp.tint(0.14),
            border: Border.all(color: ok ? _Lp.line : _Lp.blue2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Icon(ok ? Icons.check : Icons.close, size: 14, color: ok ? _Lp.blue2 : _Lp.heading),
            const SizedBox(width: 10),
            Expanded(child: Text(point, style: const TextStyle(fontSize: 13))),
            Text(ok ? '1' : '0', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ]),
        ),
      Row(children: [
        Expanded(child: Text('3 / 4 marks', style: TextStyle(fontWeight: FontWeight.w700, color: _Lp.heading))),
        Flexible(child: _muted('Missed point → Lecture 6, p. 5')),
      ]),
    ]);

/// Priority = how weak you are × how often the past papers ask it.
Widget _priorityTable() {
  const rows = [
    ('Regularisation', '41%', '4 of 5', 'First', true),
    ('Bias–variance', '52%', '3 of 5', 'Next', false),
    ('Overfitting', '74%', '5 of 5', 'Keep warm', false),
    ('Gradient descent', '88%', '2 of 5', 'Later', false),
  ];
  Widget cell(Widget child, {bool top = false, bool head = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        color: head ? _Lp.deep : (top ? _Lp.tint(0.14) : null),
        child: child,
      );
  TextStyle style(bool top) =>
      TextStyle(fontSize: 12, fontWeight: top ? FontWeight.w700 : FontWeight.w400, color: top ? _Lp.heading : _Lp.text);
  final headStyle = TextStyle(color: _Lp.soft, fontSize: 10, letterSpacing: 0.8);
  return _gapSpaced([
    _caption('Priority = how weak × how often examined'),
    ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border.all(color: _Lp.line), borderRadius: BorderRadius.circular(12)),
        child: Table(
          columnWidths: {
            0: const FlexColumnWidth(1.6),
            1: const FlexColumnWidth(),
            2: const FlexColumnWidth(),
            3: const FlexColumnWidth()
          },
          border: TableBorder(horizontalInside: BorderSide(color: _Lp.line)),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              for (final h in ['IDEA', 'MASTERY', 'PAST PAPERS', 'PRIORITY'])
                cell(Text(h, style: headStyle), head: true),
            ]),
            for (final (idea, mastery, papers, priority, top) in rows)
              TableRow(children: [
                cell(Text(idea, style: style(top)), top: top),
                cell(Text(mastery, style: style(top)), top: top),
                cell(Text(papers, style: style(top)), top: top),
                cell(
                    top
                        ? const Align(alignment: Alignment.centerLeft, child: _Tag('First'))
                        : Text(priority, style: TextStyle(color: _Lp.soft, fontSize: 12)),
                    top: top),
              ]),
          ],
        ),
      ),
    ),
    const _Note(
        icon: Icons.calendar_month_outlined,
        title: 'Today: Regularisation · 25 min',
        text: 'Weak, and asked in 4 of your 5 past papers.'),
  ]);
}

/// The student's course as linked ideas.
class _CourseMap extends StatelessWidget {
  const _CourseMap();

  static const _nodes = [
    (Alignment(-0.6, -0.75), 'Loss function', false),
    (Alignment(0.6, -0.75), 'Overfitting', false),
    (Alignment(0, 0), 'Regularisation', true),
    (Alignment(-0.55, 0.75), 'Gradient descent', false),
    (Alignment(0.55, 0.75), 'Bias–variance', false),
  ];
  static const _links = [(0, 2), (1, 2), (2, 3), (2, 4), (1, 4), (0, 3)];

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 190,
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _MapLines([for (final n in _nodes) n.$1], _links))),
          for (final (at, label, on) in _nodes)
            Align(
              alignment: at,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: on ? _Lp.blue : _Lp.panel2,
                  border: Border.all(color: on ? _Lp.blue : _Lp.line),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(label, style: TextStyle(fontSize: 11, color: on ? Colors.white : _Lp.heading)),
              ),
            ),
        ]),
      );
}

class _MapLines extends CustomPainter {
  const _MapLines(this.points, this.links);

  final List<Alignment> points;
  final List<(int, int)> links;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _Lp.line
      ..strokeWidth = 2;
    Offset at(Alignment a) => a.alongSize(size);
    for (final (a, b) in links) {
      canvas.drawLine(at(points[a]), at(points[b]), paint);
    }
  }

  @override
  bool shouldRepaint(_MapLines oldDelegate) => false;
}

/// Before/after mastery on fresh questions: the light segment is "before".
class _BeforeAfter extends StatelessWidget {
  const _BeforeAfter(this.name, this.before, this.after);

  final String name;
  final int before;
  final int after;

  @override
  Widget build(BuildContext context) => Column(children: [
        Row(children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
          _muted('$before% → '),
          Text('$after%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Stack(children: [
              Container(color: _Lp.track),
              FractionallySizedBox(
                widthFactor: after / 100,
                child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [_Lp.blue, _Lp.blue2]))),
              ),
              FractionallySizedBox(
                  widthFactor: before / 100, child: Container(color: Colors.white.withValues(alpha: 0.28))),
            ]),
          ),
        ),
      ]);
}

// ─── Top bar ───────────────────────────────────────────────────────────────

class _Nav extends StatelessWidget {
  const _Nav({required this.size, required this.onScroll});

  final ScreenSize size;
  final void Function(String id) onScroll;

  @override
  Widget build(BuildContext context) {
    Widget link(String label, VoidCallback onTap) => TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
              foregroundColor: _Lp.soft, textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          child: Text(label),
        );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: size.isPhone ? 16 : 24, vertical: 12),
      decoration: BoxDecoration(color: _Lp.bg, border: Border(bottom: BorderSide(color: _Lp.line))),
      child: Row(
        children: [
          _Logo(showName: !size.isPhone),
          if (size.isDesktop) ...[
            const Spacer(),
            link('How it works', () => onScroll('loop')),
            const SizedBox(width: 12),
            link('Why you’re wrong', () => onScroll('diagnose')),
            const SizedBox(width: 12),
            link('Our mission', () => onScroll('mission')),
            const SizedBox(width: 12),
            link('Help', () => enterApp(section: AppSection.help)),
          ],
          const Spacer(),
          IconButton(
            onPressed: toggleThemeMode,
            tooltip: _Lp.dark ? 'Switch to light' : 'Switch to dark',
            icon: Icon(_Lp.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: _Lp.heading, size: 20),
          ),
          TextButton(
            onPressed: () => showAccountDialog(context, signUp: false),
            style: TextButton.styleFrom(
                foregroundColor: _Lp.heading, textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            child: const Text('Log in'),
          ),
          const SizedBox(width: 8),
          // A high flex so the button keeps its full label on phones; the spacer takes the rest.
          Flexible(
            flex: 8,
            child: _LpButton('Start your path to an A',
                small: true, ghost: true, onPressed: () => showAccountDialog(context, signUp: true)),
          ),
        ],
      ),
    );
  }
}

// ─── Hero and product showcase ─────────────────────────────────────────────

class _Hero extends StatefulWidget {
  const _Hero({required this.size, required this.pad});

  final ScreenSize size;
  final double pad;

  @override
  State<_Hero> createState() => _HeroState();
}

class _HeroState extends State<_Hero> {
  int _slide = 0;

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final headline = switch (size) {
      ScreenSize.phone => 32.0,
      ScreenSize.tablet => 44.0,
      ScreenSize.desktop => 58.0,
    };
    final h1 = AppTheme.display(headline, color: _Lp.heading).copyWith(height: 1.05, letterSpacing: -1);

    // Plain background, the same as the rest of the page (no glow behind the headline).
    return Container(
      color: _Lp.bg,
      child: Column(
        children: [
          _contained(
            max: 1000,
            padding: EdgeInsets.fromLTRB(widget.pad, size.isPhone ? 44 : 64, widget.pad, 0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: _Lp.tint(0.1),
                    border: Border.all(color: _Lp.blue2.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: _Lp.blue2, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text('The exam-readiness engine for your course',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _Lp.paleBlue, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ]),
                ),
                const SizedBox(height: 26),
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'You’re closer to '),
                    WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: _GradientText('that A', style: h1)),
                    const TextSpan(text: ' than you think.'),
                  ]),
                  textAlign: TextAlign.center,
                  style: h1,
                ),
                const SizedBox(height: 22),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    'Your private study assistant learns from your books, notes and past exams, shows you '
                    'exactly what’s holding you back, and guides you step by step to the grade '
                    'you’ve been working for.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _Lp.soft, fontSize: size.isPhone ? 16 : 20, height: 1.6),
                  ),
                ),
                const SizedBox(height: 22),
                // The loop in three phrases.
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24,
                  runSpacing: 10,
                  children: [
                    for (final (icon, text) in [
                      (Icons.track_changes, 'What to study next'),
                      (Icons.insights, 'Why you keep getting it wrong'),
                      (Icons.check_circle_outline, 'Proof you’ve fixed it'),
                    ])
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(icon, size: 16, color: _Lp.blue2),
                        const SizedBox(width: 8),
                        Flexible(child: Text(text, style: TextStyle(color: _Lp.soft, fontSize: 15))),
                      ]),
                  ],
                ),
                const SizedBox(height: 30),
                Builder(builder: (context) {
                  final buttons = [
                    _LpButton('Sign up free', onPressed: () => showAccountDialog(context, signUp: true)),
                    _LpButton('Explore the demo', ghost: true, onPressed: () => enterApp()),
                  ];
                  // Full-width stack on phones; side by side (wrapping if needed) elsewhere.
                  return size.isPhone
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [buttons[0], const SizedBox(height: 14), buttons[1]])
                      : Wrap(alignment: WrapAlignment.center, spacing: 14, runSpacing: 14, children: buttons);
                }),
              ],
            ),
          ),
          _contained(
            max: 1180,
            padding: EdgeInsets.fromLTRB(size.isPhone ? 12 : 24, size.isPhone ? 36 : 48, size.isPhone ? 12 : 24, 0),
            child: _Showcase(slide: _slide, size: size),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Semantics(
                  button: true,
                  selected: i == _slide,
                  label: '${['Marking', 'Home', 'Diagnose'][i]} preview',
                  child: GestureDetector(
                    onTap: () => setState(() => _slide = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: AppTheme.easeOutExpo,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      width: i == _slide ? 36 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _slide ? _Lp.blue2 : _Lp.dot,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A window onto the app: sidebar, the chosen screen, and the study assistant.
class _Showcase extends StatelessWidget {
  const _Showcase({required this.slide, required this.size});

  final int slide;
  final ScreenSize size;

  static final _nav = [
    (Icons.home_outlined, 'Home'),
    (Icons.folder_copy_outlined, 'My library'),
    (Icons.forum_outlined, 'Ask'),
    (Icons.track_changes, 'Diagnose'),
    (Icons.assignment_outlined, 'Practice'),
    (Icons.calendar_month_outlined, 'My plan'),
    (Icons.bar_chart, 'Progress'),
  ];
  static final _active = [4, 0, 3];
  // Exam readiness is a range, not a grade prediction, until it is calibrated.
  static final _homeTiles = [
    (Icons.replay, '60–70%', 'READINESS'),
    (Icons.insights, '2 of 3', 'MISTAKES FIXED'),
    (Icons.lightbulb_outline, '72%', 'MASTERY'),
    (Icons.local_fire_department_outlined, '12 days', 'STREAK'),
  ];

  @override
  Widget build(BuildContext context) {
    final main = Padding(
      padding: EdgeInsets.all(size.isPhone ? 16 : 22),
      child: switch (slide) {
        0 => _markingSlide(),
        1 => _homeSlide(),
        _ => _gapSpaced([
            const _Misconception(),
            _mastery([
              ('Gradient descent', 88),
              ('Overfitting', 74),
              ('Bias–variance trade-off', 52),
              ('Regularisation', 41)
            ]),
          ]),
      },
    );

    return _Window(
      shadow: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!size.isPhone)
              Container(
                width: size.isDesktop ? 200 : 180,
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
                decoration: BoxDecoration(color: _Lp.panel, border: Border(right: BorderSide(color: _Lp.line))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                        padding: EdgeInsets.fromLTRB(6, 0, 0, 14),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: FittedBox(fit: BoxFit.scaleDown, child: _Logo(size: 28)))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 4),
                        child: Text('Study', style: TextStyle(color: _Lp.soft, fontSize: 11))),
                    for (final (i, (icon, label)) in _nav.indexed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: i == _active[slide] ? _Lp.tint(0.2) : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          Icon(icon, size: 16, color: _Lp.text),
                          const SizedBox(width: 10),
                          Flexible(
                              child:
                                  Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                        ]),
                      ),
                  ],
                ),
              ),
            Expanded(child: main),
            if (size.isDesktop)
              Container(
                width: 270,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(border: Border(left: BorderSide(color: _Lp.line))),
                child: _gapSpaced([
                  Row(children: [
                    const Expanded(
                        child: Text('Study assistant', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                    Icon(Icons.close, size: 16, color: _Lp.soft),
                  ]),
                  const _Bubble('Which point did I miss?', me: true),
                  const _Bubble(
                    'The bias–variance link. Your lecturer frames L2 as “trading a little bias for a lot less '
                    'variance” (Lecture 6, p. 5).\n\nCan you add one sentence that makes that link?',
                  ),
                  const Wrap(spacing: 8, runSpacing: 8, children: [_Tag('Lecture 6'), _Tag('Past papers')]),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _markingSlide() => _gapSpaced([
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Machine Learning: past paper practice',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text('Written answer, marked against the rubric', style: TextStyle(color: _Lp.soft, fontSize: 13)),
            ]),
          ),
          const _Tag('04:12'),
        ]),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: _Lp.panel2, border: Border.all(color: _Lp.line), borderRadius: BorderRadius.circular(14)),
          child: _rubricMark(),
        ),
        _iconLine(Icons.insights, 'Missed point logged as a misconception: L1 vs L2'),
      ]);

  Widget _homeSlide() => _gapSpaced([
        Wrap(crossAxisAlignment: WrapCrossAlignment.end, children: [
          Text('Welcome back, ', style: AppTheme.display(26, color: _Lp.heading)),
          _GradientText('Alex', style: AppTheme.display(26, color: _Lp.heading)),
        ]),
        _muted('Your exam is in 18 days.'),
        const _Note(
          icon: Icons.track_changes,
          title: 'Study next: Regularisation · 25 min',
          text: 'Mastery 41%, and asked in 4 of your 5 past papers.',
        ),
        // Rows of tiles rather than a grid: the showcase measures its height intrinsically.
        for (final row in size.isPhone ? [_homeTiles.sublist(0, 2), _homeTiles.sublist(2)] : [_homeTiles])
          Row(children: [
            for (final (i, (icon, value, label)) in row.indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _StatTile(icon: icon, value: value, label: label)),
            ],
          ]),
      ]);
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: _Lp.panel2, border: Border.all(color: _Lp.line), borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: _Lp.blue2),
            FittedBox(child: Text(value, style: AppTheme.display(22, color: _Lp.heading))),
            FittedBox(child: Text(label, style: TextStyle(color: _Lp.soft, fontSize: 10, letterSpacing: 0.8))),
          ],
        ),
      );
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.text, {this.me = false});

  final String text;
  final bool me;

  @override
  Widget build(BuildContext context) => Align(
        alignment: me ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: me ? _Lp.blue : _Lp.panel2, borderRadius: BorderRadius.circular(12)),
          child: Text(text, style: TextStyle(color: me ? Colors.white : _Lp.text, fontSize: 13, height: 1.55)),
        ),
      );
}

// ─── The loop ──────────────────────────────────────────────────────────────

/// The positioning: one loop that joins the features, built on the student's own course.
class _Loop extends StatelessWidget {
  const _Loop({required this.size, required this.pad});

  final ScreenSize size;
  final double pad;

  static final _steps = [
    (
      Icons.insights,
      'Diagnose the mistake',
      'Every wrong answer is tagged with the misconception behind it, not just the topic.'
    ),
    (Icons.track_changes, 'Prioritise what counts', 'Ranked by how weak you are × how often your past papers ask it.'),
    (
      Icons.lightbulb_outline,
      'Fix it your lecturer’s way',
      'Explained from your own pages, in the terms your course uses.'
    ),
    (Icons.replay, 'Prove it’s fixed', 'Retested on fresh questions you haven’t seen, never repeats.'),
  ];

  @override
  Widget build(BuildContext context) {
    Widget card(int i) {
      final (icon, title, text) = _steps[i];
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: _Lp.panel, border: Border.all(color: _Lp.line), borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${i + 1}', style: AppTheme.mono(12, color: _Lp.paleBlue)),
            const SizedBox(height: 10),
            Icon(icon, size: 22, color: _Lp.blue2),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: _Lp.heading, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(text, style: TextStyle(color: _Lp.soft, fontSize: 14, height: 1.55)),
          ],
        ),
      );
    }

    Widget arrow(IconData icon) => Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(color: _Lp.blue, shape: BoxShape.circle),
          child: Icon(icon, size: 15, color: Colors.white),
        );

    final Widget steps = switch (size) {
      ScreenSize.desktop => IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0)
                Center(
                    child:
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: arrow(Icons.arrow_forward))),
              Expanded(child: card(i)),
            ],
          ]),
        ),
      _ => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0)
              Center(
                  child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: arrow(Icons.arrow_downward))),
            card(i),
          ],
        ]),
    };

    return _contained(
      padding: EdgeInsets.fromLTRB(pad, size.isPhone ? 56 : 88, pad, 8),
      child: Column(
        children: [
          const _Badge('HOW IT WORKS'),
          const SizedBox(height: 20),
          Text(
            'One loop, built on your own course.',
            textAlign: TextAlign.center,
            style: AppTheme.display(size.isPhone ? 26 : 40, color: _Lp.heading).copyWith(height: 1.1),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(
              'Other study apps help you study. Effective AI tells you what to study next, why you keep getting it '
              'wrong, and shows when you’ve actually fixed it, using your own course and your own past papers.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _Lp.soft, fontSize: size.isPhone ? 16 : 19, height: 1.6),
            ),
          ),
          const SizedBox(height: 40),
          steps,
          const SizedBox(height: 22),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.refresh, size: 16, color: _Lp.blue2),
            const SizedBox(width: 8),
            Flexible(child: _muted('Then round again, until your weakest idea isn’t weak any more.', size: 15)),
          ]),
        ],
      ),
    );
  }
}

// ─── Feature sections ──────────────────────────────────────────────────────

class _Feature {
  const _Feature(this.id, this.section, this.badge, this.title, this.text, this.cta, this.connects, this.picture);

  final String id;
  final AppSection section;
  final String badge;
  final String title;
  final String text;
  final String cta;

  /// How this step feeds the next one: we sell the connections, not the features.
  final String connects;
  final Widget Function() picture;
}

final _features = <_Feature>[
  _Feature(
    'library',
    AppSection.library,
    'YOUR COURSE, MAPPED',
    'Your course becomes a map of linked ideas, not a folder of files.',
    'Upload your textbooks, lecture notes, slides and past exams. Effective AI pulls out the ideas in each one and '
        'links them across sources, so it knows how your course fits together.',
    'Map my course',
    'Every answer, diagnosis and practice question is built on this map',
    () => _gapSpaced([
      _caption('Your course map'),
      const _CourseMap(),
      const _Note(
        icon: Icons.hub_outlined,
        title: 'Regularisation',
        text: 'Lecture 6 p. 4–5 · Textbook ch. 3.1 · Past papers 2019, 2020, 2022, 2023',
      ),
      _iconLine(Icons.hub_outlined, '128 ideas linked across 4 sources'),
    ]),
  ),
  _Feature(
    'ask',
    AppSection.ask,
    'IN YOUR LECTURER’S TERMS',
    'Page-exact answers, framed the way your course teaches it.',
    'Every answer cites the page it came from and follows how your lecturer explains the idea. When your materials '
        'don’t cover something, it tells you, instead of guessing.',
    'Ask my notes',
    'When you fix a mistake, the explanation uses your lecturer’s framing too',
    () => _gapSpaced([
      const _Bubble('Why does L2 regularisation reduce overfitting?', me: true),
      const _Bubble(
        'It adds a penalty for large weights, so the model prefers simpler fits that generalise better [1]. '
        'Your lecturer links this to the bias–variance trade-off: a little more bias for much less variance [2].',
      ),
      _Line(
          leading: Icon(Icons.article_outlined, size: 16, color: _Lp.blue2),
          child: const Text('[1] Lecture 6: Regularisation, p. 4')),
      _Line(
          leading: Icon(Icons.article_outlined, size: 16, color: _Lp.blue2),
          child: const Text('[2] Lecture 6: Regularisation, p. 5')),
      const _Note(
        icon: Icons.help_outline,
        title: 'Not in your materials',
        text:
            '“Elastic net” isn’t covered in your 4 sources. Any answer to that would be general knowledge, not your course.',
      ),
    ]),
  ),
  _Feature(
    'diagnose',
    AppSection.diagnose,
    'WHY YOU’RE WRONG',
    'We find why you’re wrong, not just where.',
    'Each wrong answer is tagged with the misconception behind it and tracked over time. You see the mistake you '
        'keep making, not just a topic with a low score.',
    'Find my mistakes',
    'Each misconception decides what you study next',
    () => _gapSpaced([
      const _Misconception(big: true),
      _mastery([('Overfitting', 74), ('Bias–variance trade-off', 52), ('Regularisation', 41)]),
    ]),
  ),
  const _Feature(
    'plan',
    AppSection.plan,
    'WHAT TO STUDY NEXT',
    'Study what’s weak and what’s examined, first.',
    'Your plan is ranked by how weak you are on each idea multiplied by how often your past papers ask it. So your '
        'next 25 minutes always go where they count most.',
    'See what’s next',
    'Today’s top priority opens straight into practice',
    _priorityTable,
  ),
  const _Feature(
    'practice',
    AppSection.practice,
    'MARKED LIKE THE REAL EXAM',
    'Practice weighted to what examiners ask, marked against the real rubric.',
    'Write your answer the way you would in the exam. It’s marked point by point against the rubric, and the point '
        'you missed shows which idea to fix.',
    'Start practising',
    'A missed rubric point becomes a tagged misconception',
    _rubricMark,
  ),
  _Feature(
    'progress',
    AppSection.progress,
    'PROOF YOU FIXED IT',
    'Proof you fixed it, on questions you haven’t seen.',
    'Once you’ve worked on a mistake, you’re retested on fresh questions, never repeats. Mastery only goes up when '
        'you get new ones right.',
    'See my progress',
    'Then the loop picks your next focus',
    () => _gapSpaced([
      _caption('Retested on new questions'),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: _Lp.panel2, border: Border.all(color: _Lp.line), borderRadius: BorderRadius.circular(14)),
        child: _gapSpaced([
          const Text('L1 vs L2 mix-up', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          Row(children: [
            Expanded(child: _muted('Before: wrong in 3 of 5 answers')),
            const SizedBox(width: 8),
            Expanded(child: _muted('After: 0 of 4 new questions')),
          ]),
          const Align(alignment: Alignment.centerLeft, child: _Tag('Fixed')),
        ]),
      ),
      const _BeforeAfter('Regularisation', 41, 78),
      const _BeforeAfter('Bias–variance', 52, 69),
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Exam readiness', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            _muted('An estimate from fresh questions, not a grade prediction', size: 12),
          ]),
        ),
        Text('60–70%', style: AppTheme.display(20, color: _Lp.heading)),
      ]),
    ]),
  ),
];

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({required this.feature, required this.flip, required this.size, required this.pad});

  final _Feature feature;
  final bool flip;
  final ScreenSize size;
  final double pad;

  @override
  Widget build(BuildContext context) {
    final f = feature;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Badge(f.badge),
        const SizedBox(height: 20),
        Text(
          f.title,
          style: AppTheme.display(size.isPhone ? 26 : (size == ScreenSize.tablet ? 34 : 42), color: _Lp.heading)
              .copyWith(height: 1.08, letterSpacing: -0.5),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(f.text, style: TextStyle(color: _Lp.soft, fontSize: size.isPhone ? 16 : 19, height: 1.6)),
        ),
        const SizedBox(height: 30),
        _LpButton(f.cta, onPressed: () => enterApp(section: f.section)),
        const SizedBox(height: 24),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Icon(Icons.link, size: 18, color: _Lp.blue2)),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Connects: ', style: TextStyle(color: _Lp.text, fontWeight: FontWeight.w700)),
                TextSpan(text: f.connects),
              ]),
              style: TextStyle(color: _Lp.soft, fontSize: 15, height: 1.45),
            ),
          ),
        ]),
      ],
    );
    final picture = Container(
      padding: EdgeInsets.all(size.isPhone ? 8 : 14),
      decoration: BoxDecoration(color: _Lp.stage, borderRadius: BorderRadius.circular(24)),
      child: _Window(child: Padding(padding: EdgeInsets.all(size.isPhone ? 14 : 22), child: f.picture())),
    );

    final stacked = !size.isDesktop;
    return _contained(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: size.isPhone ? 44 : 72),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: [copy, const SizedBox(height: 32), picture])
          : Row(
              children: [
                Expanded(child: flip ? picture : copy),
                const SizedBox(width: 56),
                Expanded(child: flip ? copy : picture),
              ],
            ),
    );
  }
}

// ─── Mission and footer ────────────────────────────────────────────────────

class _Mission extends StatelessWidget {
  const _Mission({required this.size, required this.pad});

  final ScreenSize size;
  final double pad;

  @override
  Widget build(BuildContext context) {
    final h2 = AppTheme.display(size.isPhone ? 26 : 40, color: _Lp.heading).copyWith(height: 1.1);
    return _contained(
      padding: EdgeInsets.fromLTRB(size.isPhone ? 12 : pad, 40, size.isPhone ? 12 : pad, 40),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size.isPhone ? 18 : 24, vertical: size.isPhone ? 44 : 64),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _Lp.missionGradient,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: _Lp.pill, borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.favorite_border, size: 16, color: _Lp.heading),
                const SizedBox(width: 8),
                const Text('Our mission', style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 18),
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Help every student reach '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: _GradientText('the grade they’ve earned', style: h2),
                ),
              ]),
              textAlign: TextAlign.center,
              style: h2,
            ),
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Text(
                'A great tutor shouldn’t depend on your budget. Effective AI turns the materials you already have '
                'into a tutor that knows your course, finds the mistake behind each wrong answer and shows you when it’s fixed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _Lp.missionText, fontSize: size.isPhone ? 16 : 18, height: 1.6),
              ),
            ),
            const SizedBox(height: 24),
            _LpButton('Sign up free', onPressed: () => showAccountDialog(context, signUp: true)),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.size, required this.pad});

  final ScreenSize size;
  final double pad;

  @override
  Widget build(BuildContext context) {
    Widget column(String title, List<(String, VoidCallback)> links) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: _Lp.heading, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            for (final (label, onTap) in links)
              TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  foregroundColor: _Lp.soft,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  minimumSize: Size.zero,
                  textStyle: const TextStyle(fontSize: 15),
                ),
                child: Text(label),
              ),
          ],
        );
    void go(AppSection s) => enterApp(section: s);
    final columns = [
      column('The loop', [
        ('Find your mistakes', () => go(AppSection.diagnose)),
        ('What to study next', () => go(AppSection.plan)),
        ('Practise past papers', () => go(AppSection.practice)),
        ('Proof of progress', () => go(AppSection.progress)),
      ]),
      column('Your course', [
        ('Course map', () => go(AppSection.library)),
        ('Ask your notes', () => go(AppSection.ask)),
        ('Explain a topic', () => go(AppSection.explain)),
        ('Mock exam', () => go(AppSection.exam)),
      ]),
      column('Account', [
        ('Log in', () => showAccountDialog(context, signUp: false)),
        ('Sign up free', () => showAccountDialog(context, signUp: true)),
        ('Help', () => go(AppSection.help)),
      ]),
    ];
    final about = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Logo(),
        const SizedBox(height: 14),
        SizedBox(
          width: 300,
          child: Text(
            'The exam-readiness engine for your course, built from your own books, notes and past exams.',
            style: TextStyle(color: _Lp.soft, height: 1.6, fontSize: 15),
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: _Lp.line))),
      child: _contained(
        padding: EdgeInsets.fromLTRB(pad, 56, pad, 40 + MediaQuery.paddingOf(context).bottom),
        child: size.isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(flex: 7, child: about), for (final c in columns) Expanded(flex: 5, child: c)],
              )
            : Wrap(spacing: 48, runSpacing: 32, children: [about, ...columns]),
      ),
    );
  }
}

/// Log in, "Start your path to an A" and "Sign up free" all open the sign-in
/// screen: Continue with Google, or email and password.
Future<void> showAccountDialog(BuildContext context, {required bool signUp}) =>
    showAuthDialog(context, signUp: signUp);
