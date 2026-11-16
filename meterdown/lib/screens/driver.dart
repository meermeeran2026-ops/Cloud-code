import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../l10n/l10n.dart';
import '../swipe.dart';
import '../theme.dart';
import '../widgets.dart';
import 'rider.dart';
import 'start.dart';

const _job = Trip(
  Place('City Mall', 'Main Road', 2.8),
  Vehicle('auto', false, 3, 30, 12, 4),
);
const _riderAt = Offset(95, 240);
const _meAt = Offset(215, 216);

/// ड्राइवर की हर स्क्रीन डार्क थीम में चलती है।
class _Dark extends StatelessWidget {
  final Widget child;
  const _Dark(this.child);

  @override
  Widget build(BuildContext context) => Theme(
    data: mdTheme(Brightness.dark),
    child: DefaultTextStyle.merge(
      style: const TextStyle(color: C.dki),
      child: child,
    ),
  );
}

void _goDark(BuildContext c, Widget w, {bool replace = false}) =>
    go(c, _Dark(w), replace: replace);

// ───────────────────────── टैब ─────────────────────────

class DriverShell extends StatefulWidget {
  final bool startOnline;
  const DriverShell({super.key, this.startOnline = false});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => _Dark(
    Builder(
      builder: (context) => Scaffold(
        body: IndexedStack(
          index: _tab,
          children: [
            DriverHome(startOnline: widget.startOnline),
            const EarningsTab(),
            const DriverProfileTab(),
          ],
        ),
        bottomNavigationBar: TabBarMD(
          index: _tab,
          onTap: (i) => setState(() => _tab = i),
          items: [
            (Icons.home_rounded, tr('tab_home')),
            (Icons.currency_rupee_rounded, tr('tab_earn')),
            (Icons.person_rounded, tr('tab_profile')),
          ],
        ),
      ),
    ),
  );
}

// ───────────────────────── होम: ऑनलाइन / ऑफ़लाइन ─────────────────────────

class DriverHome extends StatefulWidget {
  /// सिर्फ़ जाँच के लिए: खुलते ही ऑनलाइन हो जाए।
  final bool startOnline;
  const DriverHome({super.key, this.startOnline = false});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> with TickerProviderStateMixin {
  bool _online = false;
  bool _offer = false;
  Timer? _timer;
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final _count =
      AnimationController(vsync: this, duration: const Duration(seconds: 15))
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed && mounted) _closeOffer();
        });

  @override
  void initState() {
    super.initState();
    if (widget.startOnline) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _set(true));
    }
  }

  void _set(bool v) {
    setState(() {
      _online = v;
      if (!v) _offer = false;
    });
    _timer?.cancel();
    if (v) {
      _pulse.repeat();
      _timer = Timer(const Duration(milliseconds: 2600), _showOffer);
    } else {
      _pulse.stop();
      _pulse.value = 0;
      _count.stop();
    }
  }

  /// नई सवारी का कार्ड किनारे से आता है। दूसरी स्क्रीन खुली हो तो रुकता है।
  void _showOffer() {
    if (!mounted || !_online) return;
    if (ModalRoute.of(context)?.isCurrent != true) {
      _timer = Timer(const Duration(seconds: 3), _showOffer);
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() => _offer = true);
    _count.forward(from: 0);
  }

  void _closeOffer() {
    _count.stop();
    setState(() => _offer = false);
    _timer?.cancel();
    if (_online) _timer = Timer(const Duration(seconds: 6), _showOffer);
  }

  void _accept() {
    _closeOffer();
    _goDark(context, const PickupScreen());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    _count.dispose();
    super.dispose();
  }

  Widget _stat(String v, String l) => Expanded(
    child: Column(
      children: [
        Text(v, style: ts(22, FontWeight.w800, C.dki)),
        Text(
          l,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: ts(12, FontWeight.w500, C.dkm, 1.2),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => MapPage(
    map: MockMap(
      autos: const [_meAt],
      pickup: _offer ? _riderAt : (_online ? _meAt : null),
      route: _offer
          ? const [_meAt, Offset(215, 150), Offset(95, 150), _riderAt]
          : null,
      dotted: true,
      pulse: _pulse,
    ),
    top: Row(
      children: [
        const LogoMark(size: 46),
        const SizedBox(width: 10),
        MapPill(
          color: _online ? C.a : C.dk2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _online ? C.ink : C.dkm,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tr(_online ? 'online' : 'offline'),
                style: ts(15, FontWeight.w800, _online ? C.ink : C.dki),
              ),
            ],
          ),
        ),
        const Spacer(),
        MapPill(child: Text('₹840', style: ts(16, FontWeight.w800, C.a))),
      ],
    ),
    corner: IgnorePointer(
      ignoring: !_offer,
      child: AnimatedSlide(
        offset: _offer ? Offset.zero : Offset(isRtl ? -1.3 : 1.3, 0),
        duration: const Duration(milliseconds: 460),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _offer ? 1 : 0,
          duration: const Duration(milliseconds: 260),
          child: _OfferCard(
            count: _count,
            onAccept: _accept,
            onDecline: _closeOffer,
          ),
        ),
      ),
    ),
    sheet: [
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(_online ? 'wait_t' : 'off_t'),
                  style: ts(24, FontWeight.w800, C.dki, 1.2),
                ),
                Text(
                  tr(_online ? 'wait_s' : 'off_s'),
                  style: ts(14, FontWeight.w500, C.dkm),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const VehicleGlyph(width: 60, body: C.a, win: C.dk2),
        ],
      ),
      Panel(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        child: Row(
          children: [
            _stat('₹840', tr('earn_today')),
            _stat('11', tr('tab_rides')),
            _stat('6.5', tr('hours')),
          ],
        ),
      ),
      if (_online)
        BigButton(
          tr('go_offline'),
          soft: true,
          bg: C.dk3,
          fg: C.dki,
          onTap: () => _set(false),
        )
      else
        SwipeButton(tr('go_online'), height: 70, onDone: () => _set(true)),
    ],
  );
}

/// नई सवारी का छोटा कार्ड: किनारे से आता है, पूरी स्क्रीन नहीं घेरता।
/// (ऐप बंद या पीछे होने पर यही कार्ड फ़ोन की होम स्क्रीन के ऊपर दिखाना
/// अगला कदम है। उसके लिए "दूसरे ऐप के ऊपर दिखाएँ" अनुमति चाहिए।)
class _OfferCard extends StatelessWidget {
  final Animation<double> count;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  const _OfferCard({
    required this.count,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    Widget where(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: C.a),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ts(13, FontWeight.w600, C.dki),
            ),
          ),
        ],
      ),
    );
    return Container(
      width: 272,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: C.dk2,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: C.a, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('new_ride'),
                      style: ts(18, FontWeight.w800, C.dki, 1.2),
                    ),
                    Text(
                      '${tr('away', {'n': '0.8'})} · ${tr('min', {'n': 3})}',
                      style: ts(13, FontWeight.w500, C.dkm),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: count,
                builder: (_, _) => SizedBox(
                  width: 44,
                  height: 44,
                  child: CustomPaint(
                    painter: _RingPainter(1 - count.value),
                    child: Center(
                      child: Text(
                        '${(15 * (1 - count.value)).ceil()}',
                        style: ts(16, FontWeight.w800, C.dki, 1.2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '₹${_job.fare}',
                style: ts(
                  36,
                  FontWeight.w800,
                  C.a,
                  1.1,
                ).copyWith(letterSpacing: -1),
              ),
              const Spacer(),
              Tag(tr('cash')),
              const SizedBox(width: 6),
              Tag(tr('km', {'n': _job.place.km})),
            ],
          ),
          const SizedBox(height: 4),
          where(Icons.radio_button_checked_rounded, pickupName),
          where(Icons.place_rounded, '${_job.place.name}, ${_job.place.area}'),
          const SizedBox(height: 12),
          SwipeButton(tr('accept'), height: 56, bg: C.dk3, onDone: onAccept),
          TextButton(
            onPressed: onDecline,
            child: Text(tr('decline'), style: ts(14, FontWeight.w600, C.dkm)),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double v;
  _RingPainter(this.v);

  @override
  void paint(Canvas c, Size s) {
    final r = Rect.fromCircle(
      center: s.center(Offset.zero),
      radius: s.width / 2 - 3,
    );
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    c.drawArc(r, 0, math.pi * 2, false, p..color = C.dk3);
    c.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, p..color = C.a);
  }

  @override
  bool shouldRepaint(covariant _RingPainter o) => o.v != v;
}

/// एक बार चलने वाला एनिमेशन, जिससे मैप पर गाड़ी रास्ते पर चलती है।
class _Mover extends StatefulWidget {
  final int seconds;
  final Widget Function(BuildContext, Animation<double>) builder;
  const _Mover({required this.seconds, required this.builder});

  @override
  State<_Mover> createState() => _MoverState();
}

class _MoverState extends State<_Mover> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: Duration(seconds: widget.seconds),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _c);
}

// ───────────────────────── पिकअप पर जाएँ ─────────────────────────

Widget _navPill(IconData icon, String text) => MapPill(
  color: C.a,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: C.ink),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ts(15, FontWeight.w800, C.ink),
        ),
      ),
    ],
  ),
);

class PickupScreen extends StatelessWidget {
  const PickupScreen({super.key});

  @override
  Widget build(BuildContext context) => _Mover(
    seconds: 12,
    builder: (context, move) => MapPage(
      map: MockMap(
        pickup: _riderAt,
        route: const [
          _meAt,
          Offset(215, 150),
          Offset(95, 150),
          Offset(95, 228),
        ],
        mover: move,
      ),
      top: _navPill(Icons.turn_left_rounded, tr('nav_left')),
      sheet: [
        Text(tr('go_pickup'), style: ts(24, FontWeight.w800, C.dki, 1.2)),
        Panel(
          child: Row(
            children: [
              const Icon(Icons.place_rounded, color: C.a),
              const SizedBox(width: 10),
              Expanded(
                child: Text(pickupName, style: ts(16, FontWeight.w700, C.dki)),
              ),
              Text(tr('min', {'n': 2}), style: ts(15, FontWeight.w700, C.a)),
            ],
          ),
        ),
        PersonRow(
          riderName,
          '4.9',
          note: '₹${_job.fare} · ${tr('cash')}',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SquareBtn(Icons.call_rounded, size: 48),
              const SizedBox(width: 8),
              SquareBtn(
                Icons.sos_rounded,
                size: 48,
                bg: C.danger,
                fg: Colors.white,
                onTap: () => showSos(context),
              ),
            ],
          ),
        ),
        SwipeButton(
          tr('reached'),
          height: 72,
          onDone: () =>
              _goDark(context, const DriverOtpScreen(), replace: true),
        ),
      ],
    ),
  );
}

// ───────────────────────── OTP डालें ─────────────────────────

class DriverOtpScreen extends StatefulWidget {
  const DriverOtpScreen({super.key});

  @override
  State<DriverOtpScreen> createState() => _DriverOtpState();
}

class _DriverOtpState extends State<DriverOtpScreen> {
  String _otp = '';

  void _key(String k) => setState(() {
    if (k == '<') {
      if (_otp.isNotEmpty) _otp = _otp.substring(0, _otp.length - 1);
    } else if (_otp.length < 4) {
      _otp += k;
    }
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wordmark(size: 20, onDark: true),
            ),
            const SizedBox(height: 28),
            Text(tr('ask_otp'), style: ts(28, FontWeight.w800, C.dki, 1.2)),
            const SizedBox(height: 6),
            Text(tr('ask_otp_s'), style: ts(15, FontWeight.w500, C.dkm)),
            const SizedBox(height: 24),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 4; i++)
                    Container(
                      width: 62,
                      height: 74,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i < _otp.length ? C.a : C.dk2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: i == _otp.length ? C.a : C.dk3,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        i < _otp.length ? _otp[i] : '',
                        style: ts(34, FontWeight.w800, C.ink, 1.2),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  for (final row in const [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                    ['', '0', '<'],
                  ])
                    Row(
                      children: [
                        for (final k in row)
                          Expanded(
                            child: k.isEmpty
                                ? const SizedBox()
                                : InkWell(
                                    onTap: () => _key(k),
                                    borderRadius: BorderRadius.circular(18),
                                    child: SizedBox(
                                      height: 60,
                                      child: Center(
                                        child: k == '<'
                                            ? const Icon(
                                                Icons.backspace_outlined,
                                                color: C.dki,
                                              )
                                            : Text(
                                                k,
                                                style: ts(
                                                  28,
                                                  FontWeight.w700,
                                                  C.dki,
                                                  1.2,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            BigButton(
              tr('start_ride'),
              height: 72,
              onTap: _otp.length == 4
                  ? () => _goDark(
                      context,
                      const DriverTripScreen(),
                      replace: true,
                    )
                  : null,
            ),
          ],
        ),
      ),
    ),
  );
}

// ───────────────────────── सवारी चालू ─────────────────────────

class DriverTripScreen extends StatelessWidget {
  const DriverTripScreen({super.key});

  @override
  Widget build(BuildContext context) => _Mover(
    seconds: 16,
    builder: (context, move) => MapPage(
      map: MockMap(
        drop: const Offset(215, 71),
        route: const [
          Offset(95, 240),
          Offset(95, 150),
          Offset(215, 150),
          Offset(215, 84),
        ],
        mover: move,
      ),
      top: _navPill(Icons.straight_rounded, tr('nav_straight')),
      sheet: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: C.a,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          tr('meter_on'),
                          style: ts(14, FontWeight.w700, C.a),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_job.place.name}, ${_job.place.area}',
                    style: ts(21, FontWeight.w800, C.dki, 1.25),
                  ),
                  Text(
                    '${tr('km', {'n': _job.place.km})} · ${tr('min', {'n': _job.place.minutes})}',
                    style: ts(14, FontWeight.w500, C.dkm),
                  ),
                ],
              ),
            ),
            Text(
              '₹${_job.fare}',
              style: ts(
                42,
                FontWeight.w800,
                C.a,
                1,
              ).copyWith(letterSpacing: -1),
            ),
          ],
        ),
        PersonRow(
          riderName,
          '4.9',
          trailing: SquareBtn(
            Icons.sos_rounded,
            size: 48,
            bg: C.danger,
            fg: Colors.white,
            onTap: () => showSos(context),
          ),
        ),
        SwipeButton(
          tr('end_ride'),
          height: 72,
          onDone: () =>
              _goDark(context, const DriverDoneScreen(), replace: true),
        ),
      ],
    ),
  );
}

// ───────────────────────── किराया लें ─────────────────────────

class DriverDoneScreen extends StatefulWidget {
  const DriverDoneScreen({super.key});

  @override
  State<DriverDoneScreen> createState() => _DriverDoneState();
}

class _DriverDoneState extends State<DriverDoneScreen> {
  int _stars = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wordmark(size: 20, onDark: true),
            ),
            const Spacer(),
            Text(
              tr('collect'),
              textAlign: TextAlign.center,
              style: ts(19, FontWeight.w600, C.dkm),
            ),
            Text(
              '₹${_job.fare}',
              textAlign: TextAlign.center,
              style: ts(
                96,
                FontWeight.w800,
                C.a,
                1.1,
              ).copyWith(letterSpacing: -3),
            ),
            const SizedBox(height: 18),
            Panel(
              color: C.dk2,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tr('distance'),
                          style: ts(15, FontWeight.w500, C.dkm),
                        ),
                      ),
                      Text(
                        tr('km', {'n': _job.place.km}),
                        style: ts(15, FontWeight.w700, C.dki),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tr('total_today'),
                          style: ts(15, FontWeight.w500, C.dkm),
                        ),
                      ),
                      Text(
                        '₹${840 + _job.fare}',
                        style: ts(15, FontWeight.w700, C.dki),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              tr('rate_rider'),
              textAlign: TextAlign.center,
              style: ts(16, FontWeight.w700, C.dki),
            ),
            const SizedBox(height: 6),
            Stars(value: _stars, onChanged: (v) => setState(() => _stars = v)),
            const Spacer(flex: 2),
            SwipeButton(
              tr('cash_received'),
              height: 72,
              onDone: () => goHome(context),
            ),
          ],
        ),
      ),
    ),
  );
}

// ───────────────────────── कमाई ─────────────────────────

class EarningsTab extends StatelessWidget {
  const EarningsTab({super.key});

  static const _week = [520, 760, 610, 900, 840, 0, 0];
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                tr('tab_earn'),
                style: ts(28, FontWeight.w800, C.dki),
              ),
            ),
            const LogoMark(size: 40),
          ],
        ),
        const SizedBox(height: 16),
        Panel(
          color: C.dk2,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('earn_today'), style: ts(15, FontWeight.w600, C.dkm)),
              Text(
                '₹840',
                style: ts(
                  54,
                  FontWeight.w800,
                  C.a,
                  1.1,
                ).copyWith(letterSpacing: -1.5),
              ),
              Text(
                '${tr('rides_count', {'n': 11})} · 6.5 ${tr('hours')}',
                style: ts(14, FontWeight.w500, C.dkm),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 130,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < 7; i++)
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 6 + 94 * _week[i] / 900,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: i == 4 ? C.a : C.dk3,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _days[i],
                                style: ts(
                                  13,
                                  i == 4 ? FontWeight.w800 : FontWeight.w500,
                                  i == 4 ? C.a : C.dkm,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Panel(
                color: C.dk2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('this_week'),
                      style: ts(14, FontWeight.w500, C.dkm),
                    ),
                    Text('₹3,630', style: ts(24, FontWeight.w800, C.dki)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Panel(
                color: C.dk2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('tab_rides'),
                      style: ts(14, FontWeight.w500, C.dkm),
                    ),
                    Text('47', style: ts(24, FontWeight.w800, C.dki)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(tr('today'), style: ts(16, FontWeight.w700, C.dkm)),
        const SizedBox(height: 10),
        for (final r in pastRides)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Panel(
              color: C.dk2,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.to, style: ts(16, FontWeight.w700, C.dki)),
                        Text(
                          '${r.when} · ${tr(r.upi ? 'upi' : 'cash')}',
                          style: ts(13, FontWeight.w500, C.dkm),
                        ),
                      ],
                    ),
                  ),
                  Text('₹${r.fare}', style: ts(19, FontWeight.w800, C.a)),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

// ───────────────────────── प्रोफ़ाइल और दस्तावेज़ ─────────────────────────

class DriverProfileTab extends StatelessWidget {
  const DriverProfileTab({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        PersonRow(
          driverName,
          '4.8',
          note: tr('rides_count', {'n': '1,240'}),
          trailing: const LogoMark(size: 42),
        ),
        const SizedBox(height: 18),
        Panel(
          color: C.dk2,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              MenuTile(
                Icons.electric_rickshaw_rounded,
                tr('vehicle'),
                value: '${tr('auto')} · AT 4821',
              ),
              MenuTile(
                Icons.badge_rounded,
                tr('docs'),
                value: '3 / 5',
                onTap: () => _goDark(context, const DocumentsScreen()),
              ),
              MenuTile(Icons.account_balance_rounded, tr('bank')),
              MenuTile(
                Icons.translate_rounded,
                tr('language'),
                value: languages.firstWhere((l) => l.$1 == lang.value).$3,
                onTap: () =>
                    go(context, const LanguageScreen(returnTo: DriverShell())),
              ),
              MenuTile(Icons.help_rounded, tr('help')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Panel(
          color: C.dk2,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              MenuTile(
                Icons.swap_horiz_rounded,
                tr('to_rider'),
                onTap: () => goRoot(context, const RiderShell()),
              ),
              MenuTile(
                Icons.logout_rounded,
                tr('logout'),
                color: const Color(0xFFFF7B7B),
                onTap: () => goRoot(context, const LoginScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'MeterDown · ${tr('version')}',
            style: ts(13, FontWeight.w500, C.dkm),
          ),
        ),
      ],
    ),
  );
}

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  static const _docs = [
    ('doc_dl', 0),
    ('doc_rc', 0),
    ('doc_ins', 0),
    ('doc_id', 1),
    ('doc_permit', 2),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              RoundBtn(
                isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(tr('docs'), style: ts(24, FontWeight.w800, C.dki)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(tr('docs_s'), style: ts(15, FontWeight.w500, C.dkm)),
          const SizedBox(height: 18),
          for (final d in _docs)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Panel(
                color: C.dk2,
                child: Row(
                  children: [
                    Icon(switch (d.$2) {
                      0 => Icons.check_circle_rounded,
                      1 => Icons.hourglass_top_rounded,
                      _ => Icons.upload_file_rounded,
                    }, color: d.$2 == 0 ? C.a : C.dkm),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        tr(d.$1),
                        style: ts(17, FontWeight.w700, C.dki),
                      ),
                    ),
                    Text(
                      tr(switch (d.$2) {
                        0 => 'approved',
                        1 => 'in_review',
                        _ => 'upload',
                      }),
                      style: ts(
                        14,
                        FontWeight.w700,
                        d.$2 == 0 ? C.a : (d.$2 == 2 ? C.dki : C.dkm),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
