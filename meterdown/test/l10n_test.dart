import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meterdown/l10n/en.dart';
import 'package:meterdown/l10n/l10n.dart';

void main() {
  test('हर भाषा में सारे शब्द हैं', () {
    for (final l in languages) {
      final m = strings[l.$1]!;
      expect(m.keys.toSet(), en.keys.toSet(), reason: l.$1);
      for (final e in en.entries) {
        for (final ph in RegExp(r'\{\w+\}').allMatches(e.value)) {
          expect(m[e.key], contains(ph.group(0)), reason: '${l.$1}:${e.key}');
        }
      }
    }
  });

  test('हर भाषा का फ़ॉन्ट मौजूद है', () {
    for (final l in languages) {
      expect(GoogleFonts.asMap().containsKey(l.$4), isTrue, reason: l.$4);
    }
  });
}
