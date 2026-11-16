import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'l10n/l10n.dart';
import 'theme.dart';

void go(BuildContext c, Widget w, {bool replace = false}) {
  final r = MaterialPageRoute<void>(builder: (_) => w);
  if (replace) {
    Navigator.pushReplacement(c, r);
  } else {
    Navigator.push(c, r);
  }
}

void goRoot(BuildContext c, Widget w) => Navigator.pushAndRemoveUntil(
    c, MaterialPageRoute<void>(builder: (_) => w), (r) => false);

void goHome(BuildContext c) => Navigator.popUntil(c, (r) => r.isFirst);

List<Widget> gapped(List<Widget> items, double gap) => [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) SizedBox(height: gap),
        items[i],
      ]
    ];

// ───────────────────────── लोगो ─────────────────────────

/// MeterDown का लोगो: सफ़ेद गोल चौकोर में, जैसा ऐप आइकन में है।
class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.28)),
        child: Image.asset('assets/logo.png', filterQuality: FilterQuality.medium),
      );
}

/// लोगो + "MeterDown" नाम। नाम हमेशा अंग्रेज़ी में रहता है।
class Wordmark extends StatelessWidget {
  final double size;
  final bool onDark;
  final bool mark;
  const Wordmark(
      {super.key, this.size = 22, this.onDark = false, this.mark = true});

  @override
  Widget build(BuildContext context) {
    final style = ts(size, FontWeight.w800,
            onDark ? Colors.white : const Color(0xFF29313B), 1)
        .copyWith(letterSpacing: -0.4);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (mark) ...[LogoMark(size: size * 1.45), SizedBox(width: size * 0.4)],
        Text.rich(TextSpan(text: 'Meter', style: style, children: [
          TextSpan(
              text: 'Down', style: style.copyWith(color: C.a)),
        ])),
      ]),
    );
  }
}

// ───────────────────────── गाड़ियों के चित्र ─────────────────────────

void paintAuto(Canvas c, Offset o, double w,
    {required Color body,
    required Color win,
    required Color wheel,
    required Color hub}) {
  c.save();
  c.translate(o.dx, o.dy);
  c.scale(w / 48);
  c.drawPath(
      Path()
        ..moveTo(5, 23)
        ..lineTo(5, 12)
        ..quadraticBezierTo(5, 4, 14, 4)
        ..lineTo(29, 4)
        ..quadraticBezierTo(35, 4, 38, 10)
        ..lineTo(43, 19)
        ..quadraticBezierTo(44.5, 23, 41, 23)
        ..close(),
      Paint()..color = body);
  final wp = Paint()..color = win;
  c.drawPath(
      Path()
        ..moveTo(18, 8.5)
        ..lineTo(28, 8.5)
        ..quadraticBezierTo(31.5, 8.5, 33.2, 12)
        ..lineTo(35, 16)
        ..lineTo(18, 16)
        ..close(),
      wp);
  c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(8, 8.5, 6.5, 7.5),
          const Radius.circular(1.5)),
      wp);
  for (final x in [13.0, 36.0]) {
    c.drawCircle(Offset(x, 24.5), 5, Paint()..color = wheel);
    c.drawCircle(Offset(x, 24.5), 1.8, Paint()..color = hub);
  }
  c.restore();
}

void paintCar(Canvas c, Offset o, double w,
    {required Color body,
    required Color win,
    required Color wheel,
    required Color hub}) {
  c.save();
  c.translate(o.dx, o.dy);
  c.scale(w / 48);
  c.drawPath(
      Path()
        ..moveTo(3, 23)
        ..lineTo(3, 18.5)
        ..quadraticBezierTo(3, 15.5, 6.5, 14.8)
        ..lineTo(13, 13.5)
        ..lineTo(18.5, 7.5)
        ..quadraticBezierTo(19.8, 6, 22, 6)
        ..lineTo(31, 6)
        ..quadraticBezierTo(33.5, 6, 35, 8)
        ..lineTo(38.8, 13.2)
        ..lineTo(43.5, 14.6)
        ..quadraticBezierTo(46, 15.4, 46, 18.5)
        ..lineTo(46, 23)
        ..close(),
      Paint()..color = body);
  final wp = Paint()..color = win;
  c.drawPath(
      Path()
        ..moveTo(20, 8.6)
        ..lineTo(25.2, 8.6)
        ..lineTo(25.2, 13.2)
        ..lineTo(15.8, 13.2)
        ..close(),
      wp);
  c.drawPath(
      Path()
        ..moveTo(27.2, 8.6)
        ..lineTo(30.6, 8.6)
        ..quadraticBezierTo(32, 8.6, 32.9, 9.8)
        ..lineTo(35.4, 13.2)
        ..lineTo(27.2, 13.2)
        ..close(),
      wp);
  for (final x in [13.0, 36.5]) {
    c.drawCircle(Offset(x, 23.5), 4.8, Paint()..color = wheel);
    c.drawCircle(Offset(x, 23.5), 1.8, Paint()..color = hub);
  }
  c.restore();
}

class VehicleGlyph extends StatelessWidget {
  final bool car;
  final double width;
  final Color? body;
  final Color? win;
  const VehicleGlyph(
      {super.key, this.car = false, this.width = 56, this.body, this.win});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(width, width * 30 / 48),
        painter: _VehiclePainter(car, body ?? C.p, win ?? context.card),
      );
}

class _VehiclePainter extends CustomPainter {
  final bool car;
  final Color body, win;
  _VehiclePainter(this.car, this.body, this.win);

  @override
  void paint(Canvas c, Size s) => (car ? paintCar : paintAuto)(
      c, Offset.zero, s.width,
      body: body, win: win, wheel: C.black, hub: C.a);

  @override
  bool shouldRepaint(covariant _VehiclePainter o) =>
      o.body != body || o.win != win || o.car != car;
}

// ───────────────────────── नमूना मैप ─────────────────────────
// असली मैप (OpenStreetMap) जुड़ने तक यह हाथ से बना मैप दिखता है।
// सारे बिंदु 300 × 400 के खाके में दिए जाते हैं।

class MockMap extends StatelessWidget {
  final List<Offset> autos;
  final List<Offset> cars;
  final Offset? me;
  final Offset? pickup;
  final Offset? drop;
  final List<Offset>? route;
  final bool dotted;
  final Animation<double>? pulse;

  const MockMap({
    super.key,
    this.autos = const [],
    this.cars = const [],
    this.me,
    this.pickup,
    this.drop,
    this.route,
    this.dotted = false,
    this.pulse,
  });

  static Color land(BuildContext c) =>
      c.dark ? const Color(0xFF1A1021) : const Color(0xFFF1EFF4);

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: CustomPaint(
          painter: _MapPainter(this, context.dark, pulse),
          size: Size.infinite,
        ),
      );
}

class _MapPainter extends CustomPainter {
  final MockMap m;
  final bool dark;
  final Animation<double>? pulse;
  _MapPainter(this.m, this.dark, this.pulse) : super(repaint: pulse);

  static const _blocks = [
    Rect.fromLTWH(8, 12, 26, 46),
    Rect.fromLTWH(48, 12, 36, 46),
    Rect.fromLTWH(108, 10, 42, 48),
    Rect.fromLTWH(166, 10, 36, 48),
    Rect.fromLTWH(8, 84, 74, 52),
    Rect.fromLTWH(108, 84, 94, 52),
    Rect.fromLTWH(230, 84, 62, 52),
    Rect.fromLTWH(8, 166, 24, 60),
    Rect.fromLTWH(50, 166, 32, 88),
    Rect.fromLTWH(230, 166, 62, 38),
    Rect.fromLTWH(166, 228, 36, 20),
    Rect.fromLTWH(8, 334, 74, 58),
    Rect.fromLTWH(108, 284, 94, 40),
    Rect.fromLTWH(108, 338, 94, 54),
    Rect.fromLTWH(230, 262, 62, 130),
    Rect.fromLTWH(-80, 12, 70, 120),
    Rect.fromLTWH(-80, 166, 70, 150),
    Rect.fromLTWH(310, 12, 70, 120),
    Rect.fromLTWH(310, 166, 70, 60),
  ];
  static const _parks = [
    Rect.fromLTWH(230, 10, 62, 48),
    Rect.fromLTWH(108, 166, 38, 78),
  ];

  @override
  void paint(Canvas c, Size s) {
    final sc = math.max(s.width / 300, s.height / 400);
    c.save();
    c.clipRect(Offset.zero & s);
    c.translate((s.width - 300 * sc) / 2, (s.height - 400 * sc) / 2);
    c.scale(sc);

    final land = dark ? const Color(0xFF1A1021) : const Color(0xFFF1EFF4);
    final block = dark ? const Color(0xFF22152B) : const Color(0xFFE7E3EC);
    final park = dark ? const Color(0xFF1D2A1C) : const Color(0xFFDDEFC6);
    final road = dark ? const Color(0xFF33213E) : Colors.white;
    final accent = dark ? C.a : C.p;

    c.drawRect(const Rect.fromLTWH(-200, -200, 700, 800), Paint()..color = land);
    for (final r in _blocks) {
      c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(5)),
          Paint()..color = block);
    }
    for (final r in _parks) {
      c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(9)),
          Paint()..color = park);
    }
    Paint rp(double w) => Paint()
      ..color = road
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    void line(double x1, double y1, double x2, double y2, double w) =>
        c.drawLine(Offset(x1, y1), Offset(x2, y2), rp(w));
    line(-200, 71, 500, 71, 6);
    line(95, 216, 500, 216, 6);
    line(156, 150, 156, 262, 6);
    line(41, 150, 41, 330, 6);
    line(95, -200, 95, 600, 11);
    line(215, -200, 215, 600, 11);
    c.drawPath(
        Path()
          ..moveTo(-200, 433)
          ..lineTo(-10, 332)
          ..lineTo(110, 268)
          ..lineTo(310, 240)
          ..lineTo(500, 213),
        rp(12));
    line(-200, 150, 500, 150, 15);

    // रास्ता
    final pts = m.route;
    if (pts != null && pts.length > 1) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final p in pts.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      if (!dark) c.drawPath(path, rp(10)..color = Colors.white);
      if (m.dotted) {
        for (final metric in path.computeMetrics()) {
          for (double d = 0; d < metric.length; d += 10) {
            final t = metric.getTangentForOffset(d);
            if (t != null) {
              c.drawCircle(t.position, 2.8, Paint()..color = accent);
            }
          }
        }
      } else {
        c.drawPath(path, rp(5.5)..color = accent);
      }
    }

    final v = pulse?.value ?? 0.0;
    void halo(Offset o, Color col) {
      c.drawCircle(o, 24 + 26 * v,
          Paint()..color = col.withValues(alpha: 0.22 * (1 - v * 0.8)));
    }

    final pk = m.pickup;
    if (pk != null) {
      halo(pk, dark ? C.a : C.p);
      c.drawCircle(pk, 11, Paint()..color = C.a);
      c.drawCircle(pk, 4.5, Paint()..color = C.ink);
    }
    final dp = m.drop;
    if (dp != null) {
      c.drawCircle(dp, 12, Paint()..color = C.black);
      c.drawCircle(dp, 5, Paint()..color = C.a);
    }
    final me = m.me;
    if (me != null) {
      halo(me, dark ? C.a : C.p);
      c.drawCircle(me, 11, Paint()..color = Colors.white);
      c.drawCircle(me, 7.5, Paint()..color = C.p);
    }
    void pin(Offset a, bool car) {
      c.drawCircle(
          a.translate(0, 2.5), 15, Paint()..color = const Color(0x2A000000));
      c.drawCircle(a, 15, Paint()..color = Colors.white);
      c.drawCircle(a, 12.5, Paint()..color = car ? C.black : C.p);
      (car ? paintCar : paintAuto)(c, a.translate(-9, -6.2), 18,
          body: C.a,
          win: car ? C.black : C.p,
          wheel: C.a,
          hub: car ? C.black : C.p);
    }

    for (final a in m.autos) {
      pin(a, false);
    }
    for (final a in m.cars) {
      pin(a, true);
    }
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _MapPainter o) => o.m != m || o.dark != dark;
}

// ───────────────────────── मैप + नीचे की शीट ─────────────────────────

class MapPage extends StatelessWidget {
  final MockMap map;
  final Widget? top;
  final Widget? corner;
  final List<Widget> sheet;
  const MapPage(
      {super.key,
      required this.map,
      this.top,
      this.corner,
      required this.sheet});

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.68;
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: Stack(fit: StackFit.expand, children: [
            map,
            if (top != null)
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Align(alignment: Alignment.topCenter, child: top),
                ),
              ),
            if (corner != null)
              PositionedDirectional(end: 16, bottom: 20, child: corner!),
          ]),
        ),
        ColoredBox(
          color: MockMap.land(context),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: maxH),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.card,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black
                        .withValues(alpha: context.dark ? 0.5 : 0.10),
                    blurRadius: 30,
                    offset: const Offset(0, -8)),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                            color: context.line,
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                    ...gapped(sheet, 14),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ───────────────────────── छोटे हिस्से ─────────────────────────

/// मुख्य बटन। डिफ़ॉल्ट: नींबू हरा, गहरा टेक्स्ट।
class BigButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? bg;
  final Color? fg;
  final bool soft;
  final double height;
  final IconData? icon;
  const BigButton(this.label,
      {super.key,
      this.onTap,
      this.trailing,
      this.bg,
      this.fg,
      this.soft = false,
      this.height = 60,
      this.icon});

  @override
  Widget build(BuildContext context) {
    final b = bg ?? (soft ? context.soft : C.a);
    final f = fg ?? (soft ? context.ink : C.ink);
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: Material(
        color: b,
        borderRadius: BorderRadius.circular(height * 0.34),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: height,
            padding: EdgeInsetsDirectional.only(
                start: 20, end: trailing == null ? 20 : 8),
            child: Row(
              mainAxisAlignment: trailing == null
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (icon != null) ...[
                        Icon(icon, color: f, size: height * 0.38),
                        const SizedBox(width: 10),
                      ],
                      Text(label,
                          style:
                              ts(height >= 70 ? 22 : 17, FontWeight.w700, f)),
                    ]),
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// चौकोर आइकन बटन (कॉल, मैसेज, समय)।
class SquareBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? bg;
  final Color? fg;
  final double size;
  const SquareBtn(this.icon,
      {super.key, this.onTap, this.bg, this.fg, this.size = 52});

  @override
  Widget build(BuildContext context) => Material(
        color: bg ?? C.a,
        borderRadius: BorderRadius.circular(size * 0.34),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ?? () {},
          child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: fg ?? C.ink, size: size * 0.42)),
        ),
      );
}

/// काले गोले में हरा आइकन।
class IconDisc extends StatelessWidget {
  final IconData icon;
  final double size;
  const IconDisc(this.icon, {super.key, this.size = 46});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: C.black, shape: BoxShape.circle),
        child: Icon(icon, color: C.a, size: size * 0.48),
      );
}

class FareChip extends StatelessWidget {
  final int fare;
  final double size;
  final Color bg;
  final Color fg;
  const FareChip(this.fare,
      {super.key, this.size = 17, this.bg = C.black, this.fg = C.a});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: size * 0.75, vertical: 8),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Text('₹$fare', style: ts(size, FontWeight.w800, fg, 1.2)),
      );
}

class RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? bg;
  final Color? fg;
  const RoundBtn(this.icon, {super.key, this.onTap, this.bg, this.fg});

  @override
  Widget build(BuildContext context) => Material(
        color: bg ?? context.card,
        shape: const CircleBorder(),
        elevation: 5,
        shadowColor: Colors.black26,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ?? () {},
          child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(icon, color: fg ?? context.ink, size: 22)),
        ),
      );
}

class MapPill extends StatelessWidget {
  final Widget child;
  final Color? color;
  const MapPill({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: color ?? context.card,
          borderRadius: BorderRadius.circular(99),
          boxShadow: const [
            BoxShadow(
                color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 6))
          ],
        ),
        child: child,
      );
}

/// नरम भराव वाला गोल कार्ड।
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final VoidCallback? onTap;
  const Panel(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.color,
      this.radius = 22,
      this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: color ?? context.soft,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      );
}

/// पिकअप और ड्रॉप की दो लाइनें।
class TripLines extends StatelessWidget {
  final String from;
  final String to;
  final String? fromNote;
  final String? toNote;
  const TripLines(
      {super.key,
      required this.from,
      required this.to,
      this.fromNote,
      this.toNote});

  @override
  Widget build(BuildContext context) {
    Widget row(Widget dot, String text, String? note) => Row(children: [
          SizedBox(width: 22, child: Center(child: dot)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts(15, FontWeight.w600))),
          if (note != null)
            Text(note, style: ts(13, FontWeight.w500, context.muted)),
        ]);
    return Panel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Column(children: [
        row(
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration:
                  const BoxDecoration(color: C.a, shape: BoxShape.circle),
              child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: C.ink, shape: BoxShape.circle)),
            ),
            from,
            fromNote),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
              margin: const EdgeInsetsDirectional.only(start: 10),
              width: 2,
              height: 12,
              color: context.line),
        ),
        row(
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: context.dark ? C.dki : C.black,
                  shape: BoxShape.circle),
              child: Container(
                  width: 7,
                  height: 7,
                  decoration:
                      const BoxDecoration(color: C.a, shape: BoxShape.circle)),
            ),
            to,
            toNote),
      ]),
    );
  }
}

class Avatar extends StatelessWidget {
  final String name;
  final double size;
  const Avatar(this.name, {super.key, this.size = 50});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: C.p),
        child: Text(name.characters.first,
            style: ts(size * 0.42, FontWeight.w800, Colors.white, 1.2)),
      );
}

/// नाम + रेटिंग वाली पंक्ति।
class PersonRow extends StatelessWidget {
  final String name;
  final String rating;
  final String? note;
  final Widget? trailing;
  const PersonRow(this.name, this.rating,
      {super.key, this.note, this.trailing});

  @override
  Widget build(BuildContext context) => Row(children: [
        Avatar(name),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ts(17, FontWeight.w800)),
            Row(children: [
              const Icon(Icons.star_rounded, size: 17, color: Color(0xFFF5B301)),
              const SizedBox(width: 3),
              Text(rating, style: ts(14, FontWeight.w700)),
              if (note != null)
                Flexible(
                  child: Text('  ·  $note',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(13, FontWeight.w500, context.muted)),
                ),
            ]),
          ]),
        ),
        if (trailing != null) trailing!,
      ]);
}

class Plate extends StatelessWidget {
  final String number;
  final bool car;
  const Plate(this.number, {super.key, this.car = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
        decoration: BoxDecoration(
            color: context.soft, borderRadius: BorderRadius.circular(14)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          VehicleGlyph(car: car, width: 34, win: context.soft),
          const SizedBox(width: 8),
          Text(number,
              style: ts(15, FontWeight.w800, null, 1.2)
                  .copyWith(letterSpacing: 0.8)),
        ]),
      );
}

class Tag extends StatelessWidget {
  final String text;
  const Tag(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: context.soft, borderRadius: BorderRadius.circular(99)),
        child: Text(text, style: ts(13, FontWeight.w700)),
      );
}

class Stars extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;
  const Stars(
      {super.key, required this.value, required this.onChanged, this.size = 40});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 1; i <= 5; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(Icons.star_rounded,
                    size: size,
                    color: i <= value ? const Color(0xFFF5B301) : context.line),
              ),
            ),
        ],
      );
}

/// प्रोफ़ाइल जैसी सूचियों की एक पंक्ति।
class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Color? color;
  final VoidCallback? onTap;
  const MenuTile(this.icon, this.title,
      {super.key, this.value, this.color, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap ?? () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: context.card, borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, size: 20, color: color ?? context.ink),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(title,
                    style: ts(16, FontWeight.w600, color ?? context.ink))),
            if (value != null)
              Text(value!, style: ts(14, FontWeight.w500, context.muted)),
            const SizedBox(width: 4),
            Icon(
                isRtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: context.muted,
                size: 22),
          ]),
        ),
      );
}

/// नीचे की टैब पट्टी।
class TabBarMD extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<(IconData, String)> items;
  const TabBarMD(
      {super.key,
      required this.index,
      required this.onTap,
      required this.items});

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: context.card,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            child: Row(children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: i == index
                            ? (context.dark ? C.a : C.black)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(items[i].$1,
                                size: 22,
                                color: i == index
                                    ? (context.dark ? C.ink : C.a)
                                    : context.muted),
                            if (i == index) ...[
                              const SizedBox(width: 7),
                              Flexible(
                                child: Text(items[i].$2,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: ts(14, FontWeight.w700,
                                        context.dark ? C.ink : Colors.white)),
                              ),
                            ],
                          ]),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      );
}

void showSos(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.card,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(tr('sos_t'), style: ts(24, FontWeight.w800, context.ink)),
              const SizedBox(height: 4),
              Text(tr('sos_s'), style: ts(14, FontWeight.w500, context.muted)),
              const SizedBox(height: 18),
              BigButton(tr('sos_police'),
                  bg: C.danger,
                  fg: Colors.white,
                  icon: Icons.local_police_rounded,
                  onTap: () => Navigator.pop(c)),
              const SizedBox(height: 10),
              BigButton(tr('sos_share'),
                  soft: true,
                  bg: context.soft,
                  fg: context.ink,
                  icon: Icons.share_location_rounded,
                  onTap: () => Navigator.pop(c)),
            ]),
      ),
    ),
  );
}
