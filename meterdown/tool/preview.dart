// सिर्फ़ जाँच के लिए: ?s=<स्क्रीन>&l=<भाषा> से कोई भी स्क्रीन सीधे खोलता है।
import 'package:material_ui/material_ui.dart';
import 'package:meterdown/data.dart';
import 'package:meterdown/l10n/l10n.dart';
import 'package:meterdown/screens/driver.dart';
import 'package:meterdown/screens/rider.dart';
import 'package:meterdown/screens/start.dart';
import 'package:meterdown/theme.dart';

void main() {
  final q = Uri.base.queryParameters;
  lang.value = q['l'] ?? 'en';
  const trip = Trip(Place('City Mall', 'Main Road', 2.8), Vehicle('auto', false, 3, 30, 12, 4));
  final dark = {'dhome', 'request', 'dpickup', 'dotp', 'dtrip', 'ddone', 'dearn'};
  final s = q['s'] ?? 'splash';
  final Widget w = switch (s) {
    'lang' => const LanguageScreen(),
    'onb' => const OnboardingScreen(),
    'login' => const LoginScreen(),
    'role' => const RoleScreen(),
    'home' => const RiderShell(),
    'search' => const SearchScreen(),
    'fare' => FareScreen(places[0]),
    'finding' => const FindingScreen(trip),
    'arriving' => const ArrivingScreen(trip),
    'trip' => const OnTripScreen(trip),
    'done' => const RideDoneScreen(trip),
    'dhome' => const DriverShell(),
    'request' => const RequestScreen(),
    'dpickup' => const PickupScreen(),
    'dotp' => const DriverOtpScreen(),
    'dtrip' => const DriverTripScreen(),
    'ddone' => const DriverDoneScreen(),
    _ => const SplashScreen(),
  };
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: mdTheme(Brightness.light),
    builder: (c, child) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!),
    home: dark.contains(s) && s != 'dhome'
        ? Theme(data: mdTheme(Brightness.dark), child: w)
        : w,
  ));
}
