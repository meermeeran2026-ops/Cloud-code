import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../l10n/l10n.dart';
import '../swipe.dart';
import '../theme.dart';
import '../widgets.dart';
import 'driver.dart';
import 'start.dart';

const _pickup = Offset(95, 300);
const _drop = Offset(215, 150);
const _route = [_pickup, Offset(95, 216), Offset(215, 216), _drop];

IconData get _back =>
    isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded;

/// सर्वर जुड़ने तक अगली स्क्रीन पर जाने का अस्थायी लिंक।
class DemoNext extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const DemoNext(this.label, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: onTap,
      child: Text('$label  →', style: ts(14, FontWeight.w600, context.muted)),
    ),
  );
}

// ───────────────────────── टैब ─────────────────────────

class RiderShell extends StatefulWidget {
  const RiderShell({super.key});

  @override
  State<RiderShell> createState() => _RiderShellState();
}

class _RiderShellState extends State<RiderShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _tab,
      children: const [RiderHome(), RidesTab(), RiderProfileTab()],
    ),
    bottomNavigationBar: TabBarMD(
      index: _tab,
      onTap: (i) => setState(() => _tab = i),
      items: [
        (Icons.home_rounded, tr('tab_home')),
        (Icons.receipt_long_rounded, tr('tab_rides')),
        (Icons.person_rounded, tr('tab_profile')),
      ],
    ),
  );
}

// ───────────────────────── 1 · होम ─────────────────────────

class RiderHome extends StatefulWidget {
  const RiderHome({super.key});

  @override
  State<RiderHome> createState() => _RiderHomeState();
}

class _RiderHomeState extends State<RiderHome>
    with SingleTickerProviderStateMixin {
  late final _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  )..repeat();

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const quick = [
      (Icons.home_rounded, 'home', 1),
      (Icons.apartment_rounded, 'office', 0),
      (Icons.train_rounded, 'station', 2),
    ];
    return MapPage(
      map: MockMap(
        me: const Offset(95, 250),
        autos: const [Offset(200, 150), Offset(60, 332)],
        cars: const [Offset(156, 71), Offset(215, 216)],
        drift: _drift,
        pulse: _drift,
      ),
      top: Row(
        children: [
          const RoundBtn(Icons.menu_rounded),
          const Spacer(),
          const MapPill(child: Wordmark(size: 17)),
          const Spacer(),
          const Avatar(riderName, size: 48),
        ],
      ),
      corner: const RoundBtn(Icons.my_location_rounded, bg: C.a, fg: C.ink),
      sheet: [
        Panel(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          onTap: () => go(context, const SearchScreen()),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: C.ink),
              const SizedBox(width: 12),
              Text(tr('where'), style: ts(17, FontWeight.w600, C.m)),
            ],
          ),
        ),
        Row(
          children: [
            for (final (i, q) in quick.indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Panel(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 6,
                  ),
                  onTap: () => go(context, FareScreen(places[q.$3])),
                  child: Column(
                    children: [
                      IconDisc(q.$1),
                      const SizedBox(height: 10),
                      Text(
                        tr(q.$2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ts(15, FontWeight.w700),
                      ),
                      Text(
                        tr('min', {'n': places[q.$3].minutes}),
                        style: ts(13, FontWeight.w500, C.m),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        Row(
          children: [
            const Icon(
              Icons.radio_button_checked_rounded,
              size: 18,
              color: C.p,
            ),
            const SizedBox(width: 8),
            Text('${tr('pickup')}: ', style: ts(14, FontWeight.w500, C.m)),
            Expanded(
              child: Text(
                pickupName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ts(14, FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PlaceRow extends StatelessWidget {
  final Place place;
  const PlaceRow(this.place, {super.key});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => go(context, FareScreen(place)),
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: C.soft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.place_rounded, size: 21, color: C.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name, style: ts(16, FontWeight.w700)),
                Text(place.area, style: ts(13, FontWeight.w500, C.m)),
              ],
            ),
          ),
          Text(tr('km', {'n': place.km}), style: ts(14, FontWeight.w600, C.m)),
        ],
      ),
    ),
  );
}

// ───────────────────────── मंज़िल खोजें ─────────────────────────

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: [
                RoundBtn(
                  _back,
                  bg: C.soft,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    tr('choose_dest'),
                    style: ts(21, FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Panel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.radio_button_checked_rounded,
                          size: 18,
                          color: C.p,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            pickupName,
                            style: ts(16, FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: C.line),
                  TextField(
                    autofocus: true,
                    style: ts(16, FontWeight.w600, C.ink),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: tr('where'),
                      hintStyle: ts(16, FontWeight.w500, C.m),
                      icon: const Icon(
                        Icons.place_rounded,
                        size: 18,
                        color: C.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              children: [
                Text(tr('nearby'), style: ts(14, FontWeight.w700, C.m)),
                const SizedBox(height: 4),
                for (final p in places) PlaceRow(p),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ───────────────────────── 2 · गाड़ी चुनें और बुक करें ─────────────────────────

class FareScreen extends StatefulWidget {
  final Place place;
  const FareScreen(this.place, {super.key});

  @override
  State<FareScreen> createState() => _FareState();
}

class _FareState extends State<FareScreen> {
  int _v = 0;
  bool _upi = false;

  Widget _vehicleCard(int i) {
    final v = vehicles[i];
    final on = i == _v;
    return GestureDetector(
      onTap: () => setState(() => _v = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 132,
        margin: const EdgeInsetsDirectional.only(end: 10),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: on ? C.p : C.soft,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: VehicleGlyph(
                  car: v.car,
                  width: 82,
                  body: on ? C.a : C.p,
                  win: on ? C.p : C.soft,
                ),
              ),
            ),
            Text(
              tr(v.key),
              style: ts(16, FontWeight.w800, on ? Colors.white : C.ink),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${tr('min', {'n': v.eta})} · ${tr('seats', {'n': v.seats})}',
                style: ts(12, FontWeight.w500, on ? Colors.white70 : C.m),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '₹${v.fare(widget.place.km)}',
              style: ts(21, FontWeight.w800, on ? C.a : C.p, 1.1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.place;
    final v = vehicles[_v];
    final trip = Trip(p, v, upi: _upi);
    return MapPage(
      map: const MockMap(pickup: _pickup, drop: _drop, route: _route),
      top: Row(
        children: [
          RoundBtn(_back, onTap: () => Navigator.pop(context)),
          const SizedBox(width: 10),
          Expanded(
            child: MapPill(
              child: Row(
                children: [
                  const Icon(Icons.place_rounded, size: 18, color: C.p),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${p.name}, ${p.area}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(15, FontWeight.w700),
                    ),
                  ),
                  Text(
                    tr('min', {'n': p.minutes}),
                    style: ts(14, FontWeight.w700, C.p),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      sheet: [
        SizedBox(
          height: 178,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < vehicles.length; i++) _vehicleCard(i),
            ],
          ),
        ),
        Text(
          tr('fare_note', {'b': v.base, 'k': v.perKm}),
          style: ts(13, FontWeight.w500, C.m),
        ),
        Panel(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: () => setState(() => _upi = !_upi),
          child: Row(
            children: [
              Icon(
                _upi ? Icons.qr_code_rounded : Icons.payments_rounded,
                size: 22,
                color: C.ink,
              ),
              const SizedBox(width: 12),
              Text(tr('pay_with'), style: ts(14, FontWeight.w500, C.m)),
              const Spacer(),
              Text(tr(_upi ? 'upi' : 'cash'), style: ts(15, FontWeight.w800)),
              const SizedBox(width: 4),
              const Icon(Icons.unfold_more_rounded, size: 20, color: C.m),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SwipeButton(
                '${tr('book', {'v': tr(v.key)})} · ₹${trip.fare}',
                height: 60,
                onDone: () => go(context, FindingScreen(trip)),
              ),
            ),
            const SizedBox(width: 10),
            const SquareBtn(
              Icons.schedule_rounded,
              size: 60,
              bg: C.soft,
              fg: C.ink,
            ),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── ड्राइवर ढूँढ रहे हैं ─────────────────────────

class FindingScreen extends StatefulWidget {
  final Trip trip;
  const FindingScreen(this.trip, {super.key});

  @override
  State<FindingScreen> createState() => _FindingState();
}

class _FindingState extends State<FindingScreen>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) go(context, ArrivingScreen(widget.trip), replace: true);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    return MapPage(
      map: MockMap(
        pickup: _pickup,
        pulse: _pulse,
        autos: const [Offset(215, 150), Offset(41, 200)],
        cars: const [Offset(156, 216)],
      ),
      top: Row(
        children: [RoundBtn(_back, onTap: () => Navigator.pop(context))],
      ),
      sheet: [
        Center(
          child: Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: C.soft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: VehicleGlyph(car: t.vehicle.car, width: 58, win: C.soft),
          ),
        ),
        Column(
          children: [
            Text(
              tr('finding_t'),
              textAlign: TextAlign.center,
              style: ts(23, FontWeight.w800),
            ),
            Text(
              tr('finding_s'),
              textAlign: TextAlign.center,
              style: ts(15, FontWeight.w500, C.m),
            ),
          ],
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const LinearProgressIndicator(
            minHeight: 6,
            color: C.p,
            backgroundColor: C.soft,
          ),
        ),
        TripLines(
          from: pickupName,
          to: '${t.place.name}, ${t.place.area}',
          toNote: '₹${t.fare}',
        ),
        BigButton(
          tr('cancel'),
          soft: true,
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

// ───────────────────────── 3 · गाड़ी आ रही है ─────────────────────────

class ArrivingScreen extends StatefulWidget {
  final Trip trip;
  const ArrivingScreen(this.trip, {super.key});

  @override
  State<ArrivingScreen> createState() => _ArrivingState();
}

class _ArrivingState extends State<ArrivingScreen>
    with SingleTickerProviderStateMixin {
  late final _move = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..forward();

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final car = trip.vehicle.car;
    return MapPage(
      map: MockMap(
        pickup: const Offset(95, 262),
        route: const [
          Offset(215, 71),
          Offset(215, 150),
          Offset(95, 150),
          Offset(95, 250),
        ],
        mover: _move,
        moverCar: car,
      ),
      top: MapPill(
        color: C.black,
        child: AnimatedBuilder(
          animation: _move,
          builder: (_, _) => Text(
            tr('arriving', {'n': (3 * (1 - _move.value)).ceil().clamp(1, 3)}),
            style: ts(15, FontWeight.w700, C.a),
          ),
        ),
      ),
      sheet: [
        PersonRow(
          driverName,
          '4.8',
          note: tr('rides_count', {'n': '1,240'}),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SquareBtn(Icons.chat_bubble_rounded, size: 48),
              SizedBox(width: 8),
              SquareBtn(Icons.call_rounded, size: 48),
            ],
          ),
        ),
        Row(
          children: [
            Plate('AT 4821', car: car),
            const SizedBox(width: 8),
            Tag(tr(trip.vehicle.key)),
            const Spacer(),
            Text(
              '₹${trip.fare} · ${tr(trip.upi ? 'upi' : 'cash')}',
              style: ts(15, FontWeight.w800),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
          decoration: BoxDecoration(
            color: C.black,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  tr('tell_otp'),
                  style: ts(14, FontWeight.w600, Colors.white70, 1.35),
                ),
              ),
              const SizedBox(width: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final d in const ['4', '7', '2', '9'])
                      Container(
                        width: 36,
                        height: 46,
                        margin: const EdgeInsets.only(left: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: C.a,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          d,
                          style: ts(23, FontWeight.w800, C.ink, 1.2),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: BigButton(
                tr('cancel'),
                soft: true,
                height: 54,
                onTap: () => goHome(context),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 100,
              child: BigButton(
                tr('sos'),
                height: 54,
                bg: C.danger.withValues(alpha: 0.12),
                fg: C.danger,
                onTap: () => showSos(context),
              ),
            ),
          ],
        ),
        DemoNext(
          tr('demo_start'),
          () => go(context, OnTripScreen(trip), replace: true),
        ),
      ],
    );
  }
}

// ───────────────────────── सवारी चालू ─────────────────────────

class OnTripScreen extends StatefulWidget {
  final Trip trip;
  const OnTripScreen(this.trip, {super.key});

  @override
  State<OnTripScreen> createState() => _OnTripState();
}

class _OnTripState extends State<OnTripScreen>
    with SingleTickerProviderStateMixin {
  late final _move = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  )..forward();

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final car = trip.vehicle.car;
    final p = trip.place;
    final total = (p.minutes * 0.6).round();
    return MapPage(
      map: MockMap(drop: _drop, route: _route, mover: _move, moverCar: car),
      top: MapPill(
        color: C.black,
        child: AnimatedBuilder(
          animation: _move,
          builder: (_, _) => Text(
            '${p.name} · ${tr('min_left', {'n': (total * (1 - _move.value)).ceil().clamp(1, total)})}',
            style: ts(15, FontWeight.w700, C.a),
          ),
        ),
      ),
      sheet: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: C.black,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
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
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            tr('meter_on'),
                            style: ts(15, FontWeight.w700, Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tr(trip.vehicle.key)} · ${tr('km', {'n': p.km})}',
                      style: ts(14, FontWeight.w500, Colors.white60),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${trip.fare}',
                style: ts(
                  44,
                  FontWeight.w800,
                  C.a,
                  1,
                ).copyWith(letterSpacing: -1),
              ),
            ],
          ),
        ),
        PersonRow(driverName, '4.8', trailing: Plate('AT 4821', car: car)),
        Row(
          children: [
            Expanded(
              child: BigButton(
                tr('share_trip'),
                soft: true,
                height: 54,
                icon: Icons.ios_share_rounded,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 100,
              child: BigButton(
                tr('sos'),
                height: 54,
                bg: C.danger.withValues(alpha: 0.12),
                fg: C.danger,
                onTap: () => showSos(context),
              ),
            ),
          ],
        ),
        DemoNext(
          tr('demo_end'),
          () => go(context, RideDoneScreen(trip), replace: true),
        ),
      ],
    );
  }
}

// ───────────────────────── पहुँच गए: किराया और रेटिंग ─────────────────────────

class RideDoneScreen extends StatefulWidget {
  final Trip trip;
  const RideDoneScreen(this.trip, {super.key});

  @override
  State<RideDoneScreen> createState() => _RideDoneState();
}

class _RideDoneState extends State<RideDoneScreen> {
  int _stars = 0;
  bool _paid = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    Widget line(String a, String b, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              a,
              style: ts(
                bold ? 17 : 15,
                bold ? FontWeight.w800 : FontWeight.w500,
                bold ? C.ink : C.m,
              ),
            ),
          ),
          Text(
            b,
            style: ts(bold ? 21 : 15, bold ? FontWeight.w800 : FontWeight.w600),
          ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wordmark(size: 20),
              ),
              const SizedBox(height: 26),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: Curves.elasticOut,
                  transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
                  child: _paid
                      ? Container(
                          key: const ValueKey('paid'),
                          width: 84,
                          height: 84,
                          decoration: const BoxDecoration(
                            color: C.a,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 48,
                            color: C.ink,
                          ),
                        )
                      : const IconDisc(
                          Icons.flag_rounded,
                          key: ValueKey('arrived'),
                          size: 84,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr(_paid ? 'paid' : 'arrived_t'),
                textAlign: TextAlign.center,
                style: ts(28, FontWeight.w800),
              ),
              Text(
                _paid ? tr('arrived_s') : '${t.place.name}, ${t.place.area}',
                textAlign: TextAlign.center,
                style: ts(15, FontWeight.w500, C.m),
              ),
              const SizedBox(height: 22),
              Panel(
                child: Column(
                  children: [
                    line(tr('base_fare'), '₹${t.vehicle.base}'),
                    line(
                      '${tr('distance')} · ${tr('km', {'n': t.place.km})}',
                      '₹${t.fare - t.vehicle.base}',
                    ),
                    const Divider(color: C.line, height: 18),
                    line(
                      '${tr('total')} · ${tr(t.upi ? 'upi' : 'cash')}',
                      '₹${t.fare}',
                      bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: !_paid
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SwipeButton(
                          tr('swipe_pay', {'n': t.fare}),
                          height: 70,
                          onDone: () => setState(() => _paid = true),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Panel(
                            child: Column(
                              children: [
                                PersonRow(
                                  driverName,
                                  '4.8',
                                  trailing: Plate(
                                    'AT 4821',
                                    car: t.vehicle.car,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Stars(
                                  value: _stars,
                                  onChanged: (v) => setState(() => _stars = v),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            style: ts(16, FontWeight.w500, C.ink),
                            decoration: InputDecoration(
                              hintText: tr('comment'),
                              hintStyle: ts(16, FontWeight.w500, C.m),
                              filled: true,
                              fillColor: C.soft,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          BigButton(tr('done'), onTap: () => goHome(context)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── सवारियाँ ─────────────────────────

class RidesTab extends StatelessWidget {
  const RidesTab({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(tr('your_rides'), style: ts(28, FontWeight.w800)),
        const SizedBox(height: 16),
        for (final r in pastRides)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Panel(
              color: Colors.white,
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: C.soft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: VehicleGlyph(car: r.car, width: 40, win: C.soft),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.to, style: ts(17, FontWeight.w700)),
                        Text(
                          r.dayKey == null
                              ? r.when
                              : '${tr(r.dayKey!)} · ${r.when}',
                          style: ts(13, FontWeight.w500, C.m),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${r.fare}', style: ts(19, FontWeight.w800)),
                      Text(
                        tr(r.upi ? 'upi' : 'cash'),
                        style: ts(13, FontWeight.w500, C.m),
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

// ───────────────────────── प्रोफ़ाइल ─────────────────────────

class RiderProfileTab extends StatelessWidget {
  const RiderProfileTab({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const Avatar(riderName, size: 66),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(riderName, style: ts(24, FontWeight.w800)),
                  Text('+91 98765 43210', style: ts(15, FontWeight.w500, C.m)),
                ],
              ),
            ),
            const LogoMark(size: 42),
          ],
        ),
        const SizedBox(height: 22),
        Panel(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              MenuTile(
                Icons.account_balance_wallet_rounded,
                tr('payments'),
                value: tr('cash'),
              ),
              MenuTile(Icons.bookmark_rounded, tr('saved'), value: '3'),
              MenuTile(
                Icons.translate_rounded,
                tr('language'),
                value: languages.firstWhere((l) => l.$1 == lang.value).$3,
                onTap: () =>
                    go(context, const LanguageScreen(returnTo: RiderShell())),
              ),
              MenuTile(Icons.shield_rounded, tr('safety')),
              MenuTile(Icons.help_rounded, tr('help')),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Panel(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              MenuTile(
                Icons.swap_horiz_rounded,
                tr('to_driver'),
                onTap: () => goRoot(context, const DriverShell()),
              ),
              MenuTile(
                Icons.logout_rounded,
                tr('logout'),
                color: C.danger,
                onTap: () => goRoot(context, const LoginScreen()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'MeterDown · ${tr('version')}',
            style: ts(13, FontWeight.w500, C.m),
          ),
        ),
      ],
    ),
  );
}
