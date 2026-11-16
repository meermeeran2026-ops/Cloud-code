import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// खिसकाकर पक्का करने वाला बटन: अंगूठे को आख़िर तक खींचने पर ही काम होता है।
class SwipeButton extends StatefulWidget {
  final String label;
  final VoidCallback onDone;
  final double height;
  final Color? bg;
  final Color? fg;
  const SwipeButton(
    this.label, {
    super.key,
    required this.onDone,
    this.height = 66,
    this.bg,
    this.fg,
  });

  @override
  State<SwipeButton> createState() => _SwipeState();
}

class _SwipeState extends State<SwipeButton> with TickerProviderStateMixin {
  late final _x = AnimationController(vsync: this, value: 0);
  late final _hint = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..repeat();
  bool _done = false;

  @override
  void dispose() {
    _x.dispose();
    _hint.dispose();
    super.dispose();
  }

  Future<void> _release() async {
    if (_done) return;
    if (_x.value < 0.82) {
      _x.animateTo(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
      );
      return;
    }
    setState(() => _done = true);
    HapticFeedback.mediumImpact();
    await _x.animateTo(
      1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );
    await Future<void>.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;
    widget.onDone();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _x.value = 0;
    setState(() => _done = false);
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    final bg = widget.bg ?? (context.dark ? C.dk3 : C.black);
    final fg = widget.fg ?? Colors.white;
    final knob = h - 12;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, box) {
          final travel = box.maxWidth - knob - 12;
          return GestureDetector(
            onHorizontalDragUpdate: (d) {
              if (!_done)
                _x.value = (_x.value + d.delta.dx / travel).clamp(0, 1);
            },
            onHorizontalDragEnd: (_) => _release(),
            onHorizontalDragCancel: _release,
            child: AnimatedBuilder(
              animation: Listenable.merge([_x, _hint]),
              builder: (context, _) {
                final x = _x.value.clamp(0.0, 1.0);
                final t = _hint.value * 1.8 - 0.4;
                return Container(
                  height: h,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(h * 0.36),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // भरा हुआ हिस्सा
                      Container(
                        width: knob + 12 + travel * x,
                        decoration: BoxDecoration(
                          color: C.a.withValues(alpha: 0.22 + 0.5 * x),
                          borderRadius: BorderRadius.circular(h * 0.36),
                        ),
                      ),
                      // चमकता हुआ लेबल
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.only(left: knob + 22, right: 18),
                          child: Opacity(
                            opacity: (1 - x * 1.6).clamp(0, 1),
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (r) => LinearGradient(
                                colors: [
                                  fg.withValues(alpha: 0.55),
                                  fg,
                                  fg.withValues(alpha: 0.55),
                                ],
                                stops: [
                                  (t - 0.25).clamp(0.0, 1.0),
                                  t.clamp(0.0, 1.0),
                                  (t + 0.25).clamp(0.0, 1.0),
                                ],
                              ).createShader(r),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    widget.label,
                                    style: ts(
                                      h >= 72 ? 20 : 17,
                                      FontWeight.w700,
                                      fg,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // अंगूठा
                      Positioned(
                        left: 6 + travel * x,
                        child: Container(
                          width: knob,
                          height: knob,
                          decoration: BoxDecoration(
                            color: C.a,
                            borderRadius: BorderRadius.circular(knob * 0.34),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x40000000),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (c, a) =>
                                ScaleTransition(scale: a, child: c),
                            child: Icon(
                              _done
                                  ? Icons.check_rounded
                                  : Icons.keyboard_double_arrow_right_rounded,
                              key: ValueKey(_done),
                              color: C.ink,
                              size: knob * 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// दबाने पर हल्का सिकुड़ने वाला असर।
class Pressable extends StatefulWidget {
  final Widget child;
  const Pressable({super.key, required this.child});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => setState(() => _down = true),
    onPointerUp: (_) => setState(() => _down = false),
    onPointerCancel: (_) => setState(() => _down = false),
    child: AnimatedScale(
      scale: _down ? 0.96 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: widget.child,
    ),
  );
}
