import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/l10n.dart';

/// MeterDown ब्रांड के रंग, लोगो से लिए गए (बैंगनी + हरा)।
class C {
  static const p = Color(0xFF724BF5);
  static const pd = Color(0xFF4A2BC2);
  static const a = Color(0xFFB4EC36);
  static const ink = Color(0xFF1B1222);
  static const black = Color(0xFF140C19);
  static const m = Color(0xFF857A8E);
  static const bg = Color(0xFFF6F4F9);
  static const soft = Color(0xFFF1EEF5);
  static const line = Color(0xFFE6E0EC);
  static const danger = Color(0xFFE5484D);
  static const dk = Color(0xFF140C19);
  static const dk2 = Color(0xFF1F1427);
  static const dk3 = Color(0xFF2E1F39);
  static const dki = Color(0xFFF3ECF7);
  static const dkm = Color(0xFFA696B2);
}

extension Pal on BuildContext {
  bool get dark => Theme.of(this).brightness == Brightness.dark;
  Color get ink => dark ? C.dki : C.ink;
  Color get muted => dark ? C.dkm : C.m;
  Color get card => dark ? C.dk2 : Colors.white;
  Color get soft => dark ? C.dk3 : C.soft;
  Color get line => dark ? C.dk3 : C.line;
  Color get bg => dark ? C.dk : C.bg;
  Color get brand => dark ? C.a : C.p;
}

/// चुनी हुई भाषा की लिपि के फ़ॉन्ट में टेक्स्ट स्टाइल।
TextStyle ts(double size,
        [FontWeight w = FontWeight.w500, Color? c, double h = 1.3]) =>
    GoogleFonts.getFont(fontOf(lang.value),
        fontSize: size, fontWeight: w, color: c, height: h);

ThemeData mdTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    scaffoldBackgroundColor: dark ? C.dk : C.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: C.p, brightness: b).copyWith(
      primary: dark ? C.a : C.p,
      onPrimary: dark ? C.ink : Colors.white,
      surface: dark ? C.dk : C.bg,
      onSurface: dark ? C.dki : C.ink,
    ),
  );
  return base.copyWith(
    textTheme:
        GoogleFonts.getTextTheme(fontOf(lang.value), base.textTheme).apply(
      bodyColor: dark ? C.dki : C.ink,
      displayColor: dark ? C.dki : C.ink,
    ),
  );
}
