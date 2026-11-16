import 'package:material_ui/material_ui.dart';

import 'as.dart';
import 'bn.dart';
import 'en.dart';
import 'gu.dart';
import 'hi.dart';
import 'kn.dart';
import 'ml.dart';
import 'mr.dart';
import 'or.dart';
import 'pa.dart';
import 'ta.dart';
import 'te.dart';
import 'ur.dart';

/// चुनी हुई भाषा। डिफ़ॉल्ट अंग्रेज़ी।
final lang = ValueNotifier<String>('en');

/// (कोड, अपनी लिपि में नाम, अंग्रेज़ी नाम, फ़ॉन्ट)
const languages = [
  ('en', 'English', 'English', 'Anek Latin'),
  ('hi', 'हिन्दी', 'Hindi', 'Anek Devanagari'),
  ('bn', 'বাংলা', 'Bengali', 'Anek Bangla'),
  ('mr', 'मराठी', 'Marathi', 'Anek Devanagari'),
  ('te', 'తెలుగు', 'Telugu', 'Anek Telugu'),
  ('ta', 'தமிழ்', 'Tamil', 'Anek Tamil'),
  ('gu', 'ગુજરાતી', 'Gujarati', 'Anek Gujarati'),
  ('ur', 'اردو', 'Urdu', 'Noto Sans Arabic'),
  ('kn', 'ಕನ್ನಡ', 'Kannada', 'Anek Kannada'),
  ('or', 'ଓଡ଼ିଆ', 'Odia', 'Anek Odia'),
  ('ml', 'മലയാളം', 'Malayalam', 'Anek Malayalam'),
  ('pa', 'ਪੰਜਾਬੀ', 'Punjabi', 'Anek Gurmukhi'),
  ('as', 'অসমীয়া', 'Assamese', 'Anek Bangla'),
];

const strings = <String, Map<String, String>>{
  'en': en,
  'hi': hi,
  'bn': bn,
  'mr': mr,
  'te': te,
  'ta': ta,
  'gu': gu,
  'ur': ur,
  'kn': kn,
  'or': or,
  'ml': ml,
  'pa': pa,
  'as': asm,
};

String fontOf(String code) =>
    languages.firstWhere((l) => l.$1 == code, orElse: () => languages[0]).$4;

bool get isRtl => lang.value == 'ur';

/// अनुवाद। `{n}` जैसी जगहों में [a] के मान भरे जाते हैं।
String tr(String key, [Map<String, Object>? a]) {
  var s = strings[lang.value]?[key] ?? en[key] ?? key;
  a?.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
  return s;
}
