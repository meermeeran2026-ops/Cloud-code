import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets.dart';
import 'driver.dart';
import 'rider.dart';

// ───────────────────────── स्प्लैश ─────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashState();
}

/// खुलने का एनिमेशन: लोगो उछलकर आता है, सड़क खिंचती है, ऑटो और कार
/// दोनों ओर से आकर मिलते हैं, फिर हरा रंग पूरी स्क्रीन पर फैलकर ऐप खोलता है।
class _SplashState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _c =
      AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 3200),
        )
        ..forward()
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed && mounted) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder<void>(
                transitionDuration: const Duration(milliseconds: 520),
                pageBuilder: (_, _, _) => const LanguageScreen(),
                transitionsBuilder: (_, a, _, child) =>
                    FadeTransition(opacity: a, child: child),
              ),
            );
          }
        });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _iv(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_c.value - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.black,
    body: Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, box) => AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final w = box.maxWidth, h = box.maxHeight;
            final logo = _iv(0.0, 0.38, Curves.elasticOut);
            final road = _iv(0.12, 0.5);
            final drive = _iv(0.2, 0.68);
            final name = _iv(0.4, 0.68);
            final tag = _iv(0.6, 0.82);
            final flood = _iv(0.86, 1.0, Curves.easeInCubic);
            final roadY = h * 0.66;
            const vw = 86.0;
            return Stack(
              children: [
                // सड़क
                Positioned(
                  left: w / 2 - w * 0.5 * road,
                  top: roadY,
                  width: w * road,
                  height: 4,
                  child: CustomPaint(painter: _RoadPainter()),
                ),
                // ऑटो बाएँ से, कार दाएँ से
                Positioned(
                  left: -vw + (w / 2 - 8) * drive,
                  top: roadY - vw * 0.58,
                  child: const VehicleGlyph(width: vw, body: C.a, win: C.black),
                ),
                Positioned(
                  left: w - (w / 2 - 8) * drive,
                  top: roadY - vw * 0.58,
                  child: Transform.flip(
                    flipX: true,
                    child: const VehicleGlyph(
                      car: true,
                      width: vw,
                      body: C.p,
                      win: C.black,
                    ),
                  ),
                ),
                // लोगो, नाम और टैगलाइन
                Positioned(
                  left: 0,
                  right: 0,
                  top: h * 0.26,
                  child: Column(
                    children: [
                      Transform.scale(
                        scale: logo,
                        child: Transform.rotate(
                          angle: (1 - logo) * -0.5,
                          child: const LogoMark(size: 112),
                        ),
                      ),
                      const SizedBox(height: 22),
                      ClipRect(
                        child: Align(
                          widthFactor: name,
                          child: Opacity(
                            opacity: name,
                            child: const Wordmark(
                              size: 40,
                              onDark: true,
                              mark: false,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Opacity(
                        opacity: tag,
                        child: Transform.translate(
                          offset: Offset(0, 12 * (1 - tag)),
                          child: Text(
                            tr('tagline'),
                            style: ts(17, FontWeight.w500, Colors.white60),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // हरा रंग लोगो से फैलकर पूरी स्क्रीन भर देता है
                if (flood > 0)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _FloodPainter(
                        Offset(w / 2, h * 0.26 + 56),
                        flood,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = C.a
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (double x = 6; x < s.width - 6; x += 30) {
      c.drawLine(Offset(x, 2), Offset(x + 14, 2), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FloodPainter extends CustomPainter {
  final Offset from;
  final double v;
  _FloodPainter(this.from, this.v);

  @override
  void paint(Canvas c, Size s) =>
      c.drawCircle(from, v * s.longestSide * 1.1, Paint()..color = C.a);

  @override
  bool shouldRepaint(covariant _FloodPainter o) => o.v != v;
}

// ───────────────────────── भाषा चुनें ─────────────────────────

class LanguageScreen extends StatefulWidget {
  /// प्रोफ़ाइल से खोलने पर भाषा बदलते ही यह स्क्रीन दोबारा खुलती है।
  final Widget? returnTo;
  const LanguageScreen({super.key, this.returnTo});

  @override
  State<LanguageScreen> createState() => _LanguageState();
}

class _LanguageState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wordmark(size: 20),
            ),
            const SizedBox(height: 28),
            Text(tr('choose_lang'), style: ts(28, FontWeight.w800, C.ink, 1.2)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.3,
                children: [
                  for (final l in languages)
                    _LangCard(
                      native: l.$2,
                      english: l.$3,
                      font: l.$4,
                      on: lang.value == l.$1,
                      onTap: () => setState(() => lang.value = l.$1),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            BigButton(
              tr('continue'),
              onTap: () => widget.returnTo == null
                  ? go(context, const OnboardingScreen(), replace: true)
                  : goRoot(context, widget.returnTo!),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LangCard extends StatelessWidget {
  final String native, english, font;
  final bool on;
  final VoidCallback onTap;
  const _LangCard({
    required this.native,
    required this.english,
    required this.font,
    required this.on,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: on ? C.p : Colors.white,
    borderRadius: BorderRadius.circular(20),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    native,
                    maxLines: 1,
                    style: GoogleFonts.getFont(
                      font,
                      fontSize: 19,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: on ? Colors.white : C.ink,
                    ),
                  ),
                  Text(
                    english,
                    style: GoogleFonts.getFont(
                      'Anek Latin',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: on ? Colors.white70 : C.m,
                    ),
                  ),
                ],
              ),
            ),
            if (on)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: C.a,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 17, color: C.ink),
              ),
          ],
        ),
      ),
    ),
  );
}

// ───────────────────────── परिचय ─────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingScreen> {
  int _i = 0;

  void _next() {
    if (_i == 2) {
      go(context, const LoginScreen(), replace: true);
    } else {
      setState(() => _i++);
    }
  }

  /// तिरछा रखा हुआ मैप का टुकड़ा, ऊपर से हर पन्ने का अपना चित्र।
  Widget _art() {
    final badge = switch (_i) {
      0 => const VehicleGlyph(car: true, width: 150, body: C.p, win: C.a),
      1 => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const VehicleGlyph(width: 120, body: C.p, win: C.a),
          const SizedBox(height: 10),
          const FareChip(64, size: 34),
        ],
      ),
      _ => const IconDisc(Icons.verified_user_rounded, size: 120),
    };
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0011)
            ..rotateX(-1.02)
            ..rotateZ(0.72),
          child: Container(
            width: 300,
            height: 300,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55462BB5),
                  blurRadius: 0,
                  offset: Offset(14, 14),
                ),
              ],
            ),
            child: const MockMap(
              pickup: Offset(95, 262),
              drop: Offset(215, 150),
              route: [
                Offset(95, 262),
                Offset(95, 216),
                Offset(215, 216),
                Offset(215, 150),
              ],
            ),
          ),
        ),
        Align(alignment: const Alignment(0.55, 0.5), child: badge),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['ob1_t', 'ob2_t', 'ob3_t'];
    const subs = ['ob1_s', 'ob2_s', 'ob3_s'];
    return Scaffold(
      backgroundColor: C.a,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _DarkLogo(),
                        TextButton(
                          onPressed: () =>
                              go(context, const LoginScreen(), replace: true),
                          child: Text(
                            tr('skip'),
                            style: ts(15, FontWeight.w700, C.ink),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: KeyedSubtree(key: ValueKey(_i), child: _art()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(26, 30, 26, 22),
            decoration: const BoxDecoration(
              color: C.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tr(titles[_i]),
                    style: ts(27, FontWeight.w800, Colors.white, 1.2),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 72,
                    child: Text(
                      tr(subs[_i]),
                      style: ts(16, FontWeight.w500, Colors.white60, 1.45),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsetsDirectional.only(end: 7),
                          width: i == _i ? 26 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _i ? Colors.white : Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      const Spacer(),
                      SquareBtn(
                        isRtl
                            ? Icons.arrow_back_rounded
                            : Icons.arrow_forward_rounded,
                        size: 64,
                        onTap: _next,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// हरे बैकग्राउंड पर लोगो: काला चौकोर, ताकि हरे पर हरा न खो जाए।
class _DarkLogo extends StatelessWidget {
  const _DarkLogo();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
    decoration: BoxDecoration(
      color: C.black,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Wordmark(size: 17, onDark: true),
  );
}

// ───────────────────────── लॉगिन ─────────────────────────

class _FormPage extends StatelessWidget {
  final String title;
  final String sub;
  final Widget field;
  final String button;
  final VoidCallback onNext;
  final bool back;
  const _FormPage({
    required this.title,
    required this.sub,
    required this.field,
    required this.button,
    required this.onNext,
    this.back = false,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (back) ...[
                  RoundBtn(
                    isRtl
                        ? Icons.arrow_forward_rounded
                        : Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                ],
                const Wordmark(size: 20),
              ],
            ),
            const SizedBox(height: 40),
            Text(title, style: ts(30, FontWeight.w800, C.ink, 1.2)),
            const SizedBox(height: 8),
            Text(sub, style: ts(16, FontWeight.w500, C.m, 1.4)),
            const SizedBox(height: 26),
            field,
            const Spacer(),
            BigButton(button, onTap: onNext),
            const SizedBox(height: 12),
            Text(
              tr('terms'),
              textAlign: TextAlign.center,
              style: ts(13, FontWeight.w500, C.m),
            ),
          ],
        ),
      ),
    ),
  );
}

InputDecoration _input(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: ts(20, FontWeight.w500, C.m.withValues(alpha: 0.55)),
  counterText: '',
  filled: true,
  fillColor: Colors.white,
  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(22),
    borderSide: const BorderSide(color: C.p, width: 2),
  ),
);

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => _FormPage(
    title: tr('login_t'),
    sub: tr('login_s'),
    button: tr('send_otp'),
    onNext: () => go(context, const OtpScreen()),
    field: Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        keyboardType: TextInputType.phone,
        maxLength: 10,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: ts(22, FontWeight.w700, C.ink).copyWith(letterSpacing: 1.5),
        decoration: _input('98765 43210').copyWith(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Text('+91', style: ts(22, FontWeight.w700, C.p)),
          ),
          prefixIconConstraints: const BoxConstraints(),
        ),
      ),
    ),
  );
}

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) => _FormPage(
    back: true,
    title: tr('otp_t'),
    sub: tr('otp_s'),
    button: tr('continue'),
    onNext: () => go(context, const RoleScreen()),
    field: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: TextField(
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: ts(32, FontWeight.w800, C.ink).copyWith(letterSpacing: 22),
            decoration: _input('••••'),
          ),
        ),
        const SizedBox(height: 16),
        Text(tr('resend'), style: ts(15, FontWeight.w700, C.p)),
      ],
    ),
  );
}

// ───────────────────────── सवारी या ड्राइवर ─────────────────────────

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  Widget _card({
    required String title,
    required String sub,
    required Widget art,
    required bool darkCard,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: darkCard ? C.black : Colors.white,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: art,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: ts(
                              24,
                              FontWeight.w800,
                              darkCard ? Colors.white : C.ink,
                              1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            sub,
                            style: ts(
                              15,
                              FontWeight.w500,
                              darkCard ? Colors.white60 : C.m,
                              1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SquareBtn(
                      isRtl
                          ? Icons.arrow_back_rounded
                          : Icons.arrow_forward_rounded,
                      onTap: onTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wordmark(size: 20),
            ),
            const SizedBox(height: 30),
            Text(tr('role_t'), style: ts(28, FontWeight.w800, C.ink, 1.2)),
            const SizedBox(height: 6),
            Text(tr('role_s'), style: ts(15, FontWeight.w500, C.m)),
            const SizedBox(height: 20),
            _card(
              title: tr('role_ride'),
              sub: tr('role_ride_s'),
              darkCard: false,
              art: const IconDisc(Icons.person_pin_circle_rounded, size: 92),
              onTap: () => goRoot(context, const RiderShell()),
            ),
            const SizedBox(height: 14),
            _card(
              title: tr('role_drive'),
              sub: tr('role_drive_s'),
              darkCard: true,
              art: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  VehicleGlyph(width: 84, body: C.a, win: C.black),
                  SizedBox(width: 12),
                  VehicleGlyph(car: true, width: 84, body: C.p, win: C.black),
                ],
              ),
              onTap: () => goRoot(context, const DriverShell()),
            ),
          ],
        ),
      ),
    ),
  );
}
